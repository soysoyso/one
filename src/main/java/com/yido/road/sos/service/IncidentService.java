package com.yido.road.sos.service;

import com.yido.road.sos.component.AlertStreamManager;

import com.yido.road.sos.model.Incident;
import com.yido.road.sos.model.IncidentDetailDto;
import com.yido.road.sos.model.SiteInfo;
import com.yido.road.sos.model.SmsSendLog;
import com.yido.road.sos.repository.main.IncidentLogMapper;
import com.yido.road.sos.repository.main.IncidentMapper;
import com.yido.road.sos.repository.main.SiteInfoMapper;
import com.yido.road.sos.repository.main.SmsLogMapper;
import com.yido.road.sos.repository.yido.SmsSendMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class IncidentService {

    private static final ZoneId ZONE_SEOUL = ZoneId.of("Asia/Seoul");

    private final AlertStreamManager streamManager;

    @Autowired private IncidentMapper incidentMapper;
    @Autowired private IncidentLogMapper incidentLogMapper;
    @Autowired private SiteInfoMapper siteInfoMapper;
    @Autowired private SmsSendMapper smsSendMapper;
    @Autowired private SmsLogMapper smsLogMapper;

    /* 접수내역 조회 */
    public Incident selectIncidentByReportNo(String reportNo) {
        return incidentMapper.selectIncidentByReportNo(reportNo);
    }

    /* 접수내역 조회 (상세+타임라인) */
    public IncidentDetailDto getIncidentDetail(String reportNo) {
        IncidentDetailDto dto = new IncidentDetailDto();
        dto.setIncident(incidentMapper.selectIncidentDetailByReportNo(reportNo));
        dto.setTimeline(incidentLogMapper.selectTimelineByReportNo(reportNo));
        return dto;
    }

    /* 상태별 건수 집계 (당일꺼만) */
    public Map<String, Object> getIncidentStatusSummaryByDate(Map<String, Object> params) {
        LocalDate today = LocalDate.now(ZONE_SEOUL);
        String ymd = today.format(DateTimeFormatter.ISO_DATE); // yyyy-MM-dd
        params.put("todayDt", ymd);
        return incidentMapper.getIncidentStatusSummaryByDate(params);
    }

    /* 접수번호로 사고접수 이미지조회 */
    public Incident selectIncidentImgByReportNo(String reportNo) {
        return incidentMapper.selectIncidentImgByReportNo(reportNo);
    }

    /**
     * 어드민 사고접수 저장(1건) + 접수번호 발급 + 로그
     */
    @Transactional
    public Map<String, Object> insertAdminIncident(Incident incident) {

        applyLatLngFromLatLngText(incident);

        // 1) 공통 전처리
        if (incident.getCellPhone() != null) {
            incident.setCellPhone(incident.getCellPhone().replace("-", ""));
        }

        // 2) 접수번호 발급(1개) - 기존 규칙 유지: PREFIX + yyMMdd + 4자리
        String reportNo = selectAndSetReportNoByPrefixRule(incident);

        log.debug("[insertIncidentWithReportNo] reportNo:" + reportNo);

        // 3) incident 1건 insert + log 1건
        incidentMapper.insertIncident(incident);
        incidentLogMapper.insertIncidentLog(incident);

        // 4) 응답
        Map<String, Object> out = new HashMap<String, Object>();
        //out.put("reportNo", reportNo);
        //out.put("siteCd", incident.getSiteCd());         // 직접선택이면 값, 알수없음이면 null
        //out.put("siteCdList", incident.getSiteCdList()); // 알수없음이면 CSV
        return out;
    }


    /**
     * 사고접수 저장(1건) + 접수번호 발급 + 로그 + 커밋 후 SSE
     * 정책:
     * - 직접선택: site_cd='0002', site_cd_list=''
     * - 알수없음: site_cd=NULL, site_cd_list='0002,0003'
     */
    @Transactional
    public Map<String, Object> insertIncidentWithReportNo(Incident incident) {

        // 1) 공통 전처리
        if (incident.getCellPhone() != null) {
            incident.setCellPhone(incident.getCellPhone().replace("-", ""));
        }

        if (incident.getCapturedTs() != null) {
            LocalDateTime kst = Instant.ofEpochMilli(incident.getCapturedTs())
                    .atZone(ZONE_SEOUL)
                    .toLocalDateTime();
            incident.setCapturedAt(kst);
        }

        // 2) site 필드 정규화 (정책 반영)
        log.debug("[insertIncidentWithReportNo] incident:" + incident);
        List<String> allSiteCds = siteInfoMapper.selectAllSiteCds();
        normalizeSiteFields(incident, allSiteCds);
        log.debug("[insertIncidentWithReportNo] 정규화된 incident:" + incident);

        // 3) 접수번호 발급(1개) - 기존 규칙 유지: PREFIX + yyMMdd + 4자리
        String reportNo = selectAndSetReportNoByPrefixRule(incident);

        log.debug("[insertIncidentWithReportNo] reportNo:" + reportNo);

        // 4) incident 1건 insert + log 1건
        incidentMapper.insertIncident(incident);
        incidentLogMapper.insertIncidentLog(incident);

        // 5) 커밋 후 SSE (직접선택 1곳 / 알수없음 후보 모두)
        registerAfterCommitSse(incident);

        // 6) 응답
        Map<String, Object> out = new HashMap<String, Object>();
        out.put("reportNo", reportNo);
        out.put("siteCd", incident.getSiteCd());         // 직접선택이면 값, 알수없음이면 null
        out.put("siteCdList", incident.getSiteCdList()); // 알수없음이면 CSV
        return out;
    }

    /**
     * siteCd / siteCdList 정책 정규화
     *
     * 1) siteCd 존재 → 직접 선택 (siteCd만 사용)
     * 2) siteCdList 존재 → 알수없음/다중 선택
     * 3) 둘 다 없음 → 전체 고속도로(allSiteCds)로 접수
     */
    private void normalizeSiteFields(Incident incident, List<String> allSiteCds) {

        String siteCd = incident.getSiteCd() != null ? incident.getSiteCd().trim() : "";
        String siteCdList = incident.getSiteCdList() != null ? incident.getSiteCdList().trim() : "";

        // 직접선택
        if (!siteCd.isEmpty()) {
            incident.setSiteCd(siteCd);
            incident.setSiteCdList("");
            return;
        }

        // 알수없음(다중 선택)
        if (!siteCdList.isEmpty()) {
            String normalized = siteCdList.replace("[", "").replace("]", "");
            String[] arr = normalized.split(",");

            LinkedHashSet<String> set = new LinkedHashSet<String>();
            for (int i = 0; i < arr.length; i++) {
                String v = arr[i] != null ? arr[i].trim() : "";
                if (!v.isEmpty()) set.add(v);
            }

            incident.setSiteCd(null);
            incident.setSiteCdList(String.join(",", set));
            return;
        }

        // ✅ 둘 다 없으면: 전체 고속도로로 접수
        LinkedHashSet<String> set = new LinkedHashSet<String>();
        if (allSiteCds != null) {
            for (int i = 0; i < allSiteCds.size(); i++) {
                String v = allSiteCds.get(i) != null ? allSiteCds.get(i).trim() : "";
                if (!v.isEmpty()) set.add(v);
            }
        }

        incident.setSiteCd(null);
        incident.setSiteCdList(String.join(",", set));
    }

    /**
     * 기존 규칙 유지 채번:
     * ex) CN2509100001 (prefix + yyMMdd + 4자리)
     *
     * - prefix는 "채번 기준 siteCd"로 site_info에서 가져옴
     * - 알수없음(siteCd=null)이면: siteCdList의 첫 번째 후보로 prefix를 결정
     */
    private String selectAndSetReportNoByPrefixRule(Incident incident) {

        // 1) 오늘 날짜 (yyMMdd)
        String today = new SimpleDateFormat("yyMMdd").format(new Date());

        String prefix;

        // 2) 알수없음이면 prefix = "UN"
        if (incident.getSiteCd() == null || incident.getSiteCd().trim().isEmpty()) {
            prefix = "UN";
        }
        // 3) 직접선택이면 site prefix 사용
        else {
            SiteInfo siteInfo = siteInfoMapper.getSiteInfoBySiteCd(incident.getSiteCd());
            prefix = (siteInfo != null && siteInfo.getReportPrefixCd() != null)
                    ? siteInfo.getReportPrefixCd()
                    : "";
        }

        // 4) 오늘 + prefix 기준 max 조회
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("today", today);
        params.put("prefix", prefix);

        String maxReportNo = incidentMapper.selectMaxReportNoByDate(params);
        // ex) UN2509100003

        int nextSeq = 1;
        if (maxReportNo != null && maxReportNo.length() >= (prefix.length() + 6 + 4)) {
            String lastSeqStr = maxReportNo.substring(maxReportNo.length() - 4);
            try {
                nextSeq = Integer.parseInt(lastSeqStr) + 1;
            } catch (Exception e) {
                nextSeq = 1;
            }
        }

        String newReportNo = prefix + today + String.format("%04d", nextSeq);
        incident.setReportNo(newReportNo);
        return newReportNo;
    }


    /**
     * 채번 기준 siteCd 결정:
     * - siteCd 있으면 그 값
     * - siteCd 없으면 siteCdList 첫 번째 후보
     * - 그래도 없으면 fallback "0000" (운영정책에 맞게)
     */
    private String resolveSeqSiteCd(Incident incident) {
        String siteCd = incident.getSiteCd() != null ? incident.getSiteCd().trim() : "";
        if (!siteCd.isEmpty()) return siteCd;

        String csv = incident.getSiteCdList() != null ? incident.getSiteCdList().trim() : "";
        if (csv.isEmpty()) return "0000";

        String normalized = csv.replace("[", "").replace("]", "");
        String[] arr = normalized.split(",");
        String first = arr.length > 0 ? arr[0].trim() : "";
        return first.isEmpty() ? "0000" : first;
    }

    /**
     * 커밋 후 SSE 전송
     * - 직접선택: 해당 site 1곳
     * - 알수없음: siteCdList 후보 모두
     */
    private void registerAfterCommitSse(Incident incident) {
        org.springframework.transaction.support.TransactionSynchronizationManager.registerSynchronization(
                new org.springframework.transaction.support.TransactionSynchronization() {
                    @Override
                    public void afterCommit() {

                        Map<String, Object> payload = new HashMap<String, Object>();
                        payload.put("reportNo", incident.getReportNo());
                        payload.put("siteCd", incident.getSiteCd());
                        payload.put("siteCdList", incident.getSiteCdList());
                        payload.put("statusCd", incident.getStatusCd());
                        payload.put("reportDate", incident.getReportDate());

                        String siteCd = incident.getSiteCd() != null ? incident.getSiteCd().trim() : "";
                        if (!siteCd.isEmpty()) {
                            streamManager.sendToSite(siteCd, "incident-created", payload);
                            return;
                        }

                        Set<String> targets = parseCsvSites(incident.getSiteCdList());
                        for (String s : targets) {
                            streamManager.sendToSite(s, "incident-created", payload);
                        }
                    }
                }
        );
    }

    private Set<String> parseCsvSites(String csv) {
        LinkedHashSet<String> set = new LinkedHashSet<String>();
        if (csv == null) return set;

        String normalized = csv.trim().replace("[", "").replace("]", "");
        if (normalized.isEmpty()) return set;

        String[] arr = normalized.split(",");
        for (int i = 0; i < arr.length; i++) {
            String v = arr[i] != null ? arr[i].trim() : "";
            if (!v.isEmpty()) set.add(v);
        }
        return set;
    }

    /* 사고접수 조회 */
    public List<Incident> selectIncidentList(Map<String, Object> params) {
        return incidentMapper.selectIncidentList(params);
    }

    /* 사고접수 건수 */
    public int selectIncidentCount(Map<String, Object> params) {
        return incidentMapper.selectIncidentCount(params);
    }

    /* 사고접수 이력 insert */
    public int insertIncidentLog(Incident incident) {
        if (incident.getCellPhone() != null) incident.setCellPhone(incident.getCellPhone().replace("-", ""));
        return incidentLogMapper.insertIncidentLog(incident);
    }

    /* (관리자) 사고접수 수정 and 이력 남기기 */
    public int updateIncidentAndLog(Incident incident) {

        applyLatLngFromLatLngText(incident);

        int cnt = incidentMapper.updateInCident(incident);
        if (cnt > 0) {
            incidentLogMapper.insertFromIncident(incident.getReportNo());
        }
        return cnt;
    }

    /**
     * 사고접수 접수번호 추출
     * ex: CN2509100001
     *
     * @param siteCd - 현장코드
     * @return
     */
    public String selectMaxReportNoByDate(String siteCd) {

        // 현장코드로 접수번호 prefix 획득
        SiteInfo siteInfo = siteInfoMapper.getSiteInfoBySiteCd(siteCd);

        // 1. 오늘 날짜 문자열 생성
        String today = new SimpleDateFormat("yyMMdd").format(new Date());

        // 2. DB에서 오늘 날짜의 최대 ReportNo 조회
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("today", today);
        params.put("siteCd", siteCd);
        String maxReportNo = incidentMapper.selectMaxReportNoByDate(params); // ex) "CN2509100001"

        int nextSeq = 1;
        if (maxReportNo != null && maxReportNo.length() == 12) {
            String lastSeqStr = maxReportNo.substring(8); // "0001"
            try {
                nextSeq = Integer.parseInt(lastSeqStr) + 1;
            } catch (NumberFormatException e) {
                nextSeq = 1; // fallback
            }
        }

        // 3. 새로운 inquiry_no 생성
        String newReportNo = siteInfo.getReportPrefixCd() + today + String.format("%04d", nextSeq);

        return newReportNo;
    }


    /**
     * 관리자 > 전화접수 > URL 전송
     */
    public void sendSms(Map<String, Object> params) throws Exception {

        final String rawPhone   = (String) params.get("cellPhone");
        final String phoneDigits= normalizeDigits(rawPhone);
        final String title      = (String) params.getOrDefault("title", null);
        final String msg        = (String) params.get("msg");

        final String adminId    = (String) params.getOrDefault("adminId", null);
        final String adminIp    = (String) params.getOrDefault("adminIp", null);
        final String siteCd     = (String) params.getOrDefault("siteCd", null);

        SmsSendLog logObj = new SmsSendLog();
        logObj.setAdminId(adminId);
        logObj.setAdminIp(adminIp);
        logObj.setSiteCd(siteCd);
        logObj.setReceiveMobileNo(phoneDigits);
        logObj.setSendTitle(title);
        logObj.setSendMessage(msg);

        smsLogMapper.insertLog(logObj);

        Map<String, Object> spParams = new HashMap<String, Object>();
        spParams.put("cellPhone", phoneDigits);
        spParams.put("title", title);
        spParams.put("msg", msg);
        spParams.put("tplCode", "");

        smsSendMapper.sendSms(spParams);
    }

    private String normalizeDigits(Object phone) {
        if (phone == null) return null;
        return phone.toString().replaceAll("\\D", "");
    }

    /**
     * siteCdList (ex: "0002,0003") 를 고속도로명 문자열로 변환
     * 결과: "비봉매송고속도로, 수원고속도로"
     */
    public String getSiteNamesFromSiteCdList(String siteCdList) {

        if (siteCdList == null || siteCdList.trim().isEmpty()) {
            return "";
        }

        // code -> name 맵
        SiteInfo siteInfo = new SiteInfo();

        List<SiteInfo> list = siteInfoMapper.selectSiteList(siteInfo);
        Map<String, String> siteMap = new HashMap<>();

        for (SiteInfo code : list) {
            siteMap.put(code.getSiteCd(), code.getSiteName());
        }

        String normalized = siteCdList.replace("[", "").replace("]", "");
        String[] codes = normalized.split(",");

        List<String> names = new ArrayList<String>();
        for (int i = 0; i < codes.length; i++) {
            String code = codes[i] != null ? codes[i].trim() : "";
            if (code.isEmpty()) continue;

            String name = siteMap.get(code);
            if (name != null && !name.isEmpty()) {
                names.add(name);
            }
        }

        return String.join(", ", names);
    }

    private void applyLatLngFromLatLngText(Incident incident) {

        String latLng = incident.getLatLng(); // "37.504152, 126.896694"

        if (latLng == null || latLng.trim().isEmpty()) {
            return; // 입력 없으면 좌표 세팅 안 함(기존값 유지)
        }

        String[] parts = latLng.split(",");
        if (parts.length != 2) {
            throw new IllegalArgumentException("좌표 형식 오류 (위도,경도)");
        }

        try {
            BigDecimal lat = new BigDecimal(parts[0].trim());
            BigDecimal lng = new BigDecimal(parts[1].trim());

            incident.setLat(lat);
            incident.setLng(lng);

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("좌표 값이 숫자 형식이 아닙니다.", e);
        }
    }

}
