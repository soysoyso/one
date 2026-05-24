package com.yido.road.sos.service.api;


import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.yido.road.sos.model.StaCalcResult;
import com.yido.road.sos.model.StaLinePoint;
import com.yido.road.sos.repository.main.StaLineMapper;

import com.yido.road.sos.util.StaCalculator;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;


import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Slf4j
public class StaService {

    private final com.fasterxml.jackson.databind.ObjectMapper om = new com.fasterxml.jackson.databind.ObjectMapper();

    private final StaLineMapper staLineMapper;
    private final ObjectMapper objectMapper;
    private final StaCalculator staCalculator = new StaCalculator();

    public StaCalcResult calcSta(String siteCd, String directionCd, double lat, double lng) {

        Map<String, Object> param = new HashMap<String, Object>();
        param.put("siteCd", siteCd);
        param.put("directionCd", directionCd);

        List<Map<String, Object>> rows = staLineMapper.selectStaLineSegs(param);
        if (rows == null || rows.isEmpty()) {
            log.warn("[STA] 선형정보 없음 - siteCd=" + siteCd
                    + ", 방향=" + directionCd
                    + ", 입력좌표=(" + lat + "," + lng + ")");
            return null;
        }

        StaCalculator.Result bestR = null;
        Map<String, Object> bestRow = null;
        int bestCoordsCnt = 0;

        if (log.isDebugEnabled()) {
            log.debug("[STA] 후보목록 - siteCd=" + siteCd
                    + ", 방향=" + directionCd
                    + ", 구간수=" + rows.size()
                    + ", 입력좌표=(" + lat + "," + lng + ")");
        }

        for (Map<String, Object> row : rows) {

            String lineJson = (String) row.get("lineJson");
            if (lineJson == null || lineJson.trim().isEmpty()) continue;

            List<StaCalculator.Pt> line = parseLineJsonFlexible(lineJson);
            if (line == null || line.size() < 2) continue;

            StaCalculator.Result r = staCalculator.calc(line, lat, lng);
            if (r == null) continue;

            double dist = r.snapDistanceMeters;

            if (log.isDebugEnabled()) {
                log.debug("[STA] 후보 - siteCd=" + siteCd
                        + ", 방향=" + directionCd
                        + ", 구간번호=" + String.valueOf(row.get("segNo"))
                        + ", 구간시작STA(km)=" + String.valueOf(row.get("staBaseKm"))
                        + ", 보정값(km)=" + String.valueOf(row.get("staOffsetKm"))
                        + ", 구간좌표수=" + line.size()
                        + ", 선형이격거리(m)=" + Math.round(dist));
            }

            if (bestR == null || dist < bestR.snapDistanceMeters) {
                bestR = r;
                bestRow = row;
                bestCoordsCnt = line.size();
            }
        }

        if (bestR == null || bestRow == null) {
            log.warn("[STA] 스냅 실패 - siteCd=" + siteCd
                    + ", 방향=" + directionCd
                    + ", 입력좌표=(" + lat + "," + lng + ")");
            return null;
        }

        BigDecimal staBaseKm = BigDecimal.ZERO;
        Object baseObj = bestRow.get("staBaseKm");
        if (baseObj != null) {
            try { staBaseKm = new BigDecimal(String.valueOf(baseObj)); } catch (Exception ignore) {}
        }

        BigDecimal offsetKm = BigDecimal.ZERO;
        Object offObj = bestRow.get("staOffsetKm");
        if (offObj != null) {
            try { offsetKm = new BigDecimal(String.valueOf(offObj)); } catch (Exception ignore) {}
        }

        long baseMeters = (long) bestR.staMeters;

        long baseStartMeters = staBaseKm
                .multiply(new BigDecimal("1000"))
                .setScale(0, RoundingMode.HALF_UP)
                .longValue();

        long offsetMeters = offsetKm
                .multiply(new BigDecimal("1000"))
                .setScale(0, RoundingMode.HALF_UP)
                .longValue();

        long finalMeters = baseStartMeters + baseMeters + offsetMeters;

        BigDecimal kmDecimal = new BigDecimal(String.valueOf(finalMeters))
                .divide(new BigDecimal("1000"), 1, RoundingMode.HALF_UP);

        // ✅ 운영용 핵심 로그 1줄(필수 정보만)
        log.info("[STA] 계산완료 - siteCd=" + siteCd
                + ", 방향=" + directionCd
                + ", 선택구간(segNo)=" + String.valueOf(bestRow.get("segNo"))
                + ", 구간좌표수=" + bestCoordsCnt
                + ", 입력좌표=(" + lat + "," + lng + ")"
                + ", 스냅좌표=(" + bestR.snapLat + "," + bestR.snapLng + ")"
                + ", 선형이격거리(m)=" + Math.round(bestR.snapDistanceMeters)
                + ", 구간시작STA(km)=" + staBaseKm.toPlainString()
                + ", 구간누적거리(m)=" + baseMeters
                + ", 보정값(km)=" + offsetKm.toPlainString()
                + ", 최종STA=" + kmDecimal.toPlainString());

        StaCalcResult out = new StaCalcResult();
        out.setSiteCd(siteCd);
        out.setDirectionCd(directionCd);
        out.setStaMeters(finalMeters);
        out.setStaKmDecimal(kmDecimal);
        out.setStaText("STA " + kmDecimal.toPlainString());
        out.setSnapLat(bestR.snapLat);
        out.setSnapLng(bestR.snapLng);
        out.setDistM(bestR.snapDistanceMeters);
        out.setStaStatus("OK");
        out.setStaMessage("");
        return out;
    }


    private List<StaCalculator.Pt> parseLineJsonFlexible(String lineJson) {
        try {
            com.fasterxml.jackson.databind.JsonNode root = om.readTree(lineJson.trim());

            com.fasterxml.jackson.databind.JsonNode coordsNode = null;

            // 1) 좌표 배열 자체: [[lng,lat],...]
            if (root.isArray()) {
                coordsNode = root;
            } else {
                String type = root.path("type").asText("");

                // 2) Feature
                if ("Feature".equalsIgnoreCase(type)) {
                    coordsNode = root.path("geometry").path("coordinates");
                }
                // 3) FeatureCollection
                else if ("FeatureCollection".equalsIgnoreCase(type)) {
                    com.fasterxml.jackson.databind.JsonNode feats = root.path("features");
                    if (feats.isArray() && feats.size() > 0) {
                        coordsNode = feats.get(0).path("geometry").path("coordinates");
                    }
                }
                // 4) 변형: {"coordinates":[...]}
                else if (root.has("coordinates")) {
                    coordsNode = root.path("coordinates");
                }
            }

            if (coordsNode == null || !coordsNode.isArray() || coordsNode.size() < 2) return null;

            List<StaCalculator.Pt> out = new ArrayList<>();

            for (com.fasterxml.jackson.databind.JsonNode p : coordsNode) {
                if (!p.isArray() || p.size() < 2) continue;

                double lng = p.get(0).asDouble();
                double lat = p.get(1).asDouble();

                StaCalculator.Pt pt = new StaCalculator.Pt(lat, lng);
                out.add(pt);
            }


            return out.size() >= 2 ? out : null;

        } catch (Exception e) {
            log.debug("parseLineJsonFlexible fail: " + e.getMessage());
            return null;
        }
    }

    public Map<String, Object> matchBestSite(String parentSiteCd, String directionCd, double lat, double lng) {

        if (directionCd == null || directionCd.trim().isEmpty()) directionCd = "ALL";

        Map<String, Object> param = new HashMap<String, Object>();
        param.put("parentSiteCd", parentSiteCd);
        param.put("directionCd", directionCd);

        List<Map<String, Object>> rows = staLineMapper.selectStaLinesByParent(param);
        if (CollectionUtils.isEmpty(rows)) {
            log.warn("[STA] 하위노선 선형정보 없음 - 대표siteCd=" + parentSiteCd
                    + ", 방향=" + directionCd
                    + ", 입력좌표=(" + lat + "," + lng + ")");
            return null;
        }

        double maxCandidateM = 1000.0;
        int maxShowCount = 3;
        double needChoiceGapM = 30.0;
        double needChoiceSecondMaxM = 300.0;

        // ✅ seg 결과를 siteCd 단위로 압축(최소 dist만 유지)
        Map<String, Map<String, Object>> bestBySite = new HashMap<String, Map<String, Object>>();

        for (Map<String, Object> row : rows) {

            String siteCd = String.valueOf(row.get("siteCd"));
            String lineJson = (String) row.get("lineJson");
            if (lineJson == null || lineJson.trim().isEmpty()) continue;

            List<StaCalculator.Pt> line = parseLineJsonFlexible(lineJson);
            if (line == null || line.size() < 2) continue;

            StaCalculator.Result r = staCalculator.calc(line, lat, lng);
            if (r == null) continue;

            double distM = r.snapDistanceMeters;
            if (distM > maxCandidateM) continue;

            if (log.isDebugEnabled()) {
                log.debug("[STA] 하위노선 후보 - 대표siteCd=" + parentSiteCd
                        + ", siteCd=" + siteCd
                        + ", 구간번호=" + String.valueOf(row.get("segNo"))
                        + ", 구간좌표수=" + line.size()
                        + ", 선형이격거리(m)=" + Math.round(distM));
            }

            Map<String, Object> prev = bestBySite.get(siteCd);
            if (prev == null) {
                Map<String, Object> c = new HashMap<String, Object>();
                c.put("siteCd", siteCd);
                c.put("directionCd", directionCd);
                c.put("distM", distM);
                c.put("siteName", row.get("siteName"));
                if (row.get("segNo") != null) c.put("segNo", row.get("segNo"));
                bestBySite.put(siteCd, c);
            } else {
                double prevDist = Double.parseDouble(String.valueOf(prev.get("distM")));
                if (distM < prevDist) {
                    prev.put("distM", distM);
                    if (row.get("segNo") != null) prev.put("segNo", row.get("segNo"));
                }
            }
        }

        if (bestBySite.isEmpty()) {
            log.warn("[STA] 하위노선 후보 없음(거리초과/파싱실패 등) - 대표siteCd=" + parentSiteCd
                    + ", 방향=" + directionCd
                    + ", 입력좌표=(" + lat + "," + lng + ")");
            return null;
        }

        List<Map<String, Object>> candidates = new ArrayList<Map<String, Object>>(bestBySite.values());
        candidates.sort((a, b) -> Double.compare(
                Double.parseDouble(String.valueOf(a.get("distM"))),
                Double.parseDouble(String.valueOf(b.get("distM")))
        ));

        String bestSiteCd = String.valueOf(candidates.get(0).get("siteCd"));

        // 상위 N개만 유지
        List<Map<String, Object>> top = candidates;
        if (top.size() > maxShowCount) {
            top = new ArrayList<Map<String, Object>>(top.subList(0, maxShowCount));
        }

        boolean needChoice = false;
        if (top.size() >= 2) {
            double d1 = Double.parseDouble(String.valueOf(top.get(0).get("distM")));
            double d2 = Double.parseDouble(String.valueOf(top.get(1).get("distM")));
            if (d2 <= needChoiceSecondMaxM && (d2 - d1) <= needChoiceGapM) {
                needChoice = true;
            }
        }

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < top.size(); i++) {
            Map<String, Object> c = top.get(i);
            if (i > 0) sb.append(" | ");
            sb.append(String.valueOf(c.get("siteCd")));
            sb.append("(");
            sb.append(String.valueOf(c.get("siteName")));
            sb.append(", ");
            sb.append(Math.round(Double.parseDouble(String.valueOf(c.get("distM")))));
            sb.append("m");
            if (c.get("segNo") != null) {
                sb.append(", 구간=");
                sb.append(String.valueOf(c.get("segNo")));
            }
            sb.append(")");
        }

        // ✅ 운영용 핵심 로그 1줄(Top 후보만)
        log.info("[STA] 하위노선 매칭완료 - 대표siteCd=" + parentSiteCd
                + ", 방향=" + directionCd
                + ", 입력좌표=(" + lat + "," + lng + ")"
                + ", 최종선택siteCd=" + bestSiteCd
                + ", 사용자선택필요=" + needChoice
                + ", 상위후보=" + sb.toString());

        Map<String, Object> out = new HashMap<String, Object>();
        out.put("needChoice", needChoice);
        out.put("candidates", top);
        out.put("bestSiteCd", bestSiteCd);
        out.put("directionCd", directionCd);

        return out;
    }

    public boolean hasSubRoutes(String parentSiteCd) {
        if (parentSiteCd == null || parentSiteCd.trim().length() == 0) return false;

        Map<String, Object> p = new HashMap<String, Object>();
        p.put("parentSiteCd", parentSiteCd);

        int cnt = staLineMapper.countSubRoutes(p);
        return cnt > 0;
    }

    @Transactional
    public int reverseAndSaveLineJson(String siteCd, String directionCd, int segNo) {

        String lineJson = staLineMapper.selectLineJson(siteCd, directionCd, segNo);
        if (lineJson == null || lineJson.trim().isEmpty()) {
            return 0;
        }

        try {
            JsonNode root = objectMapper.readTree(lineJson);

            JsonNode geometry = root.get("geometry");
            if (geometry == null || geometry.isNull()) return 0;

            JsonNode coordsNode = geometry.get("coordinates");
            if (coordsNode == null || !coordsNode.isArray()) return 0;

            ArrayNode coordsArray = (ArrayNode) coordsNode;

            List<JsonNode> list = new ArrayList<>();
            for (JsonNode n : coordsArray) list.add(n);
            Collections.reverse(list);

            ArrayNode newCoords = objectMapper.createArrayNode();
            for (JsonNode n : list) newCoords.add(n);

            ((ObjectNode) geometry).set("coordinates", newCoords);

            String newLineJson = objectMapper.writeValueAsString(root);

            BigDecimal startLng = null;
            BigDecimal startLat = null;

            if (newCoords.size() > 0 && newCoords.get(0).isArray() && newCoords.get(0).size() >= 2) {
                startLng = new BigDecimal(newCoords.get(0).get(0).asText());
                startLat = new BigDecimal(newCoords.get(0).get(1).asText());
            }

            return staLineMapper.updateLineJson(siteCd, directionCd, segNo, newLineJson, startLng, startLat);

        } catch (Exception e) {
            throw new RuntimeException(
                    "Failed to reverse line_json. siteCd=" + siteCd
                            + ", directionCd=" + directionCd
                            + ", segNo=" + segNo,
                    e
            );
        }
    }
}