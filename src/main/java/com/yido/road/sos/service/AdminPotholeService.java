package com.yido.road.sos.service;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.yido.road.sos.component.storage.S3StorageService;
import com.yido.road.sos.component.storage.UploadResult;
import com.yido.road.sos.enums.SmsTemplateCode;
import com.yido.road.sos.model.Pothole;
import com.yido.road.sos.model.PotholeHistory;
import com.yido.road.sos.model.PotholeImage;
import com.yido.road.sos.model.SiteInfo;
import com.yido.road.sos.model.work.WorkInfoPayload;
import com.yido.road.sos.repository.main.AdminPotholeMapper;
import com.yido.road.sos.repository.main.PotholeImageMapper;
import com.yido.road.sos.repository.main.PotholeMapper;
import com.yido.road.sos.repository.main.SiteInfoMapper;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.*;


@Slf4j
@Service
@RequiredArgsConstructor
public class AdminPotholeService {

    private static final ZoneId ZONE_SEOUL = ZoneId.of("Asia/Seoul");
    private static final int MAX_PHOTO = 20;

    private final AdminPotholeMapper adminPotholeMapper;
    private final PotholeMapper potholeMapper;
    private final PotholeImageMapper potholeImageMapper;
    private final S3StorageService storageService;
    private final ObjectMapper objectMapper;
    private final CommonService commonService;

    // 업로드 루트(서버 물리경로) - 너 프로젝트 방식대로 properties로 빼도 됨
    private final String uploadRoot = "D:/upload"; // 예시
    private final SiteInfoMapper siteInfoMapper;

    /**
     * 현장관리 목록 조회(관리자)
     */
    public List<Map<String, Object>> selectImsPotholeList(Map<String, Object> param) {
        return adminPotholeMapper.selectImsPotholeList(param);
    }

    /**
     * 현장관리 건수 조회(관리자)
     */
    public int selectImsPotholeCount(Map<String, Object> param) {
        return adminPotholeMapper.selectImsPotholeCount(param);
    }

    /* 접수내용 상세보기 */
    public Map<String, Object> selectImsPotholeDetail(String reportNo) {
        return adminPotholeMapper.selectImsPotholeDetail(reportNo);
    }

    // 포트홀 이력 목록 조회
    public List<Map<String, Object>> selectPotholeHistoryByReportNo(String reportNo) {
        return adminPotholeMapper.selectPotholeHistoryByReportNo(reportNo);
    }

    /** 현장관리 등록/수정 시 접수정보·사진·작업정보를 통합 저장한다. */
    @Transactional
    public void savePotholeAllWithPhotosForAdmin(
            Pothole pothole,
            String updaterId,
            HttpServletRequest request,
            String delBeforeSortOrds,
            String delAfterSortOrds,
            String workInfoJson,
            String mainBeforeFrom, String mainBeforeKey,
            String mainAfterFrom,  String mainAfterKey,
            String photoMoveJson
    ) {
        String mode = pothole.getImsMode();
        if (mode == null) mode = "";

        String reportNo = "";
        Pothole before = null;

        if ("INSERT".equals(mode)) {

            // INSERT면 reportNo 채번
            reportNo = potholeMapper.selectNextReportNo();
            pothole.setReportNo(reportNo);

            // ✅ 작업시작일시: 비어있으면 현재일시로
            if (pothole.getWorkStartAt() == null) {
                pothole.setWorkStartAt(LocalDateTime.now());
            }

            // ✅ 작업종료일시: 완료 상태일 때만, 비어있으면 현재일시로
            String statusCd = pothole.getStatusCd();
            boolean isDone = "DONE".equals(statusCd) || "COMPLETE".equals(statusCd);

            if (isDone) {
                if (pothole.getWorkEndAt() == null) {
                    pothole.setWorkEndAt(LocalDateTime.now());
                }
            }

            // ✅ 문서번호(관리자: A) - 비어있으면 채번
            if (pothole.getDocNo() == null || "".equals(pothole.getDocNo().trim())) {
                pothole.setDocNo(potholeMapper.selectNextDocNo("A"));
            }

            adminPotholeMapper.insertPotholeAll(pothole);

        } else {

            reportNo = pothole.getReportNo();
            before = potholeMapper.selectPotholeByReportNo(reportNo);

            // ✅ UPDATE에서도 동일 정책 적용
            if (pothole.getWorkStartAt() == null) {
                pothole.setWorkStartAt(LocalDateTime.now());
            }

            String statusCd = pothole.getStatusCd();
            boolean isDone = "DONE".equals(statusCd) || "COMPLETE".equals(statusCd);

            if (isDone) {
                if (pothole.getWorkEndAt() == null) {
                    pothole.setWorkEndAt(LocalDateTime.now());
                }
            }

            String beforeReceiptGbCd = before != null ? Utils.safe(before.getReceiptGbCd()) : "";
            String afterReceiptGbCd = Utils.safe(pothole.getReceiptGbCd());

            if (!beforeReceiptGbCd.equals(afterReceiptGbCd)) {
                renamePhotosByReceiptGbCd(reportNo, afterReceiptGbCd);
            }

            adminPotholeMapper.updatePotholeAll(pothole);
        }

        if (reportNo == null || "".equals(reportNo)) {
            throw new RuntimeException("reportNo is empty");
        }

        // pothole 본테이블 이력 저장
        Pothole after = potholeMapper.selectPotholeByReportNo(reportNo);

        if ("INSERT".equals(mode)) {
            saveCreateHistory(after, updaterId);
        } else {
            savePotholeHistory(before, after, updaterId, "UPDATE", "관리자 포트홀 수정");
        }

        // 1) 삭제 대상 사진 먼저 삭제
        deletePhotosByCsv(reportNo, "BEFORE", delBeforeSortOrds);
        deletePhotosByCsv(reportNo, "AFTER",  delAfterSortOrds);

        // 2) 남아있는 사진 기준으로 작업 전/후 이동 및 정렬 반영
        applyPhotoMove(reportNo, photoMoveJson);

        // 3) 신규 사진 저장 + 이번 요청에서 실제로 들어간 sortOrd 목록 확보
        List<Integer> beforeInsertedSortOrds =
                saveNewPhotosReturnSortOrds(
                        reportNo,
                        "BEFORE",
                        pothole.getPhotos(),
                        updaterId,
                        pothole.getReceiptGbCd()
                );

        List<Integer> afterInsertedSortOrds =
                saveNewPhotosReturnSortOrds(
                        reportNo,
                        "AFTER",
                        pothole.getWorkPhotos(),
                        updaterId,
                        pothole.getReceiptGbCd()
                );
        // 4) ✅ 대표사진 반영(사용자 선택 우선)
        applyMainPhoto(reportNo, "BEFORE", mainBeforeFrom, mainBeforeKey, beforeInsertedSortOrds);
        applyMainPhoto(reportNo, "AFTER",  mainAfterFrom,  mainAfterKey,  afterInsertedSortOrds);

        // 5) 대표사진 보정(선택 없거나 잘못된 값일 때)
        ensureMainPhoto(reportNo, "BEFORE");
        ensureMainPhoto(reportNo, "AFTER");

        // 6) 작업정보 저장
        saveWorkInfo(reportNo, workInfoJson);

        // 알림톡 발송
        boolean shouldSend = "Y".equals(pothole.getAlarmSendYn());

        if (shouldSend) {
            boolean changed = true;

            if (before != null && before.getStatusCd() != null && pothole.getStatusCd() != null) {
                changed = !pothole.getStatusCd().equals(before.getStatusCd());
            }

            if (changed) {

                SmsTemplateCode tpl = commonService.getTplByStatus(pothole.getStatusCd());
                commonService.sendSmsAfterCommit(reportNo, tpl, "ALL");
            }
        }
    }

    /* 접수유형 변경 시 reportNo의 작업 전/후 사진 파일명을 새로운 접수유형 기준으로 일괄 변경한다. */
    private void renamePhotosByReceiptGbCd(String reportNo, String receiptGbCd) {

        receiptGbCd = Utils.safe(receiptGbCd);
        if ("".equals(receiptGbCd.trim())) {
            receiptGbCd = "POTHOLE";
        }

        renamePhotosByGb(reportNo, "BEFORE", receiptGbCd);
        renamePhotosByGb(reportNo, "AFTER", receiptGbCd);
    }

    /* 특정 사진구분(BEFORE/AFTER)의 기존 파일을 새 파일명으로 복사 후 기존 파일 삭제 및 DB 파일명을 갱신한다. */
    private void renamePhotosByGb(String reportNo, String photoGb, String receiptGbCd) {

        List<PotholeImage> list = potholeImageMapper.selectPotholeImagesByReportNo(reportNo, photoGb);

        if (list == null || list.isEmpty()) return;

        for (PotholeImage img : list) {

            if (img == null || img.getSortOrd() == null) continue;

            String oldPath = Utils.safe(img.getImgPath());
            String oldName = Utils.safe(img.getImgName());

            if ("".equals(oldPath.trim()) || "".equals(oldName.trim())) continue;

            String ext = "";
            int dot = oldName.lastIndexOf(".");
            if (dot > -1) {
                ext = oldName.substring(dot);
            }

            String seq = String.format("%02d", img.getSortOrd());

            String newName = receiptGbCd + "_" + reportNo + "_" + photoGb + "_" + seq + ext;

            if (oldName.equals(newName)) continue;

            String newPath = oldPath.replaceFirst(
                    "^[^/]+/",
                    receiptGbCd.toLowerCase() + "/"
            );

            UploadResult renamed =
                    storageService.renameObject(
                            oldPath,
                            oldName,
                            newPath,
                            newName
                    );
            if (renamed == null) continue;

            img.setReportNo(reportNo);
            img.setImgPath(renamed.getPath());
            img.setImgName(renamed.getName());
            potholeImageMapper.updateImagePathAndName(img);
        }
    }

    /**
     * 신규 사진 저장(빈 슬롯 채우기) + "이번 요청에서 저장된 sortOrd"를 업로드 순서대로 반환
     * - 프론트에서 mainKey를 0-base index로 보내면 여기 반환 리스트에서 매핑 가능
     */
    private List<Integer> saveNewPhotosReturnSortOrds(
            String reportNo,
            String photoGb,
            MultipartFile[] files,
            String writerId,
            String receiptGbCd
    ) {

        List<Integer> insertedSortOrds = new ArrayList<>();

        if (files == null || files.length == 0) return insertedSortOrds;

        List<Integer> used = potholeImageMapper.selectUsedSortOrds(reportNo, photoGb);
        if (used == null) used = new ArrayList<>();

        // 빈 슬롯(1~20)
        List<Integer> slots = new ArrayList<>();
        for (int i = 1; i <= MAX_PHOTO; i++) {
            boolean exists = false;
            for (int j = 0; j < used.size(); j++) {
                Integer u = used.get(j);
                if (u != null && u.intValue() == i) { exists = true; break; }
            }
            if (!exists) slots.add(i);
        }
        if (slots.isEmpty()) return insertedSortOrds;

        int slotIdx = 0;

        for (int i = 0; i < files.length; i++) {

            if (slotIdx >= slots.size()) break;

            MultipartFile mf = files[i];
            if (mf == null || mf.isEmpty()) continue;

            String ct = mf.getContentType();
            if (ct == null || !ct.startsWith("image/")) continue;

            int sortOrd = slots.get(slotIdx++);

            String seq = String.format("%02d", sortOrd);

            receiptGbCd = Utils.safe(receiptGbCd);

            if ("".equals(receiptGbCd.trim())) {
                receiptGbCd = "POTHOLE";
            }

            String fileName = receiptGbCd + "_" + reportNo + "_" + photoGb + "_" + seq;

            String folder = "AFTER".equals(photoGb) ? "pothole/after" : "pothole/before";

            UploadResult up;

            if ("AFTER".equals(photoGb)) {
                up = storageService.uploadPotholeAfter(reportNo, sortOrd, receiptGbCd, mf);
            } else {
                up = storageService.uploadPotholeBefore(reportNo, sortOrd, receiptGbCd, mf);
            }

            if (up == null) continue;

            PotholeImage pi = new PotholeImage();
            pi.setReportNo(reportNo);
            pi.setPhotoGb(photoGb);
            pi.setSortOrd(sortOrd);
            pi.setImgPath(up.getPath());
            pi.setImgName(up.getName());
            pi.setIsMain("N"); // 일단 N

            potholeImageMapper.upsertPotholePhoto(pi);

            // ✅ 업로드 순서대로 "저장된 sortOrd"를 기록
            insertedSortOrds.add(sortOrd);
        }

        return insertedSortOrds;
    }

    /**
     * 대표사진 지정
     * - from=db  : key=sortOrd
     * - from=new : key=0-base index -> insertedSortOrds.get(index) 로 실제 sortOrd 매핑
     */
    private void applyMainPhoto(String reportNo, String photoGb, String from, String key, List<Integer> insertedSortOrds) {

        if (from == null) from = "";
        if (key == null) key = "";

        from = from.trim();
        key  = key.trim();

        if ("".equals(from) || "".equals(key)) return;

        Integer targetSortOrd = null;

        if ("db".equals(from)) {
            targetSortOrd = parseIntOrNull(key);

        } else if ("new".equals(from)) {
            Integer idx = parseIntOrNull(key);
            if (idx != null && idx >= 0 && insertedSortOrds != null && idx < insertedSortOrds.size()) {
                targetSortOrd = insertedSortOrds.get(idx);
            }
        }

        if (targetSortOrd == null) return;

        potholeImageMapper.updateIsMainAllN(reportNo, photoGb);
        potholeImageMapper.updateIsMainOneY(reportNo, photoGb, targetSortOrd);
    }

    private Integer parseIntOrNull(String s) {
        try { return Integer.valueOf(Integer.parseInt(s)); }
        catch (Exception e) { return null; }
    }


    /** 작업정보(장비/인력/자재/범위)를 JSON으로 받아 기존 데이터 삭제 후 재저장한다. */
    @Transactional
    public void saveWorkInfo(String reportNo, String workInfoJson) {

        // 1) 기존 전부 삭제 (테이블별로)
        adminPotholeMapper.deleteWorkEquipmentByReportNo(reportNo);
        adminPotholeMapper.deleteWorkPersonnelByReportNo(reportNo);
        adminPotholeMapper.deleteWorkMaterialByReportNo(reportNo);
        adminPotholeMapper.deleteWorkScopeByReportNo(reportNo);

        // 2) 넘어온게 없으면 삭제만 하고 끝
        if (workInfoJson == null || workInfoJson.trim().isEmpty()) return;

        try {
            WorkInfoPayload payload = objectMapper.readValue(workInfoJson, WorkInfoPayload.class);

            // 3) 있으면 배치 insert
            if (payload.getEquipments() != null && !payload.getEquipments().isEmpty()) {
                adminPotholeMapper.insertWorkEquipmentBatch(reportNo, payload.getEquipments());
            }

            if (payload.getPersonnels() != null && !payload.getPersonnels().isEmpty()) {
                adminPotholeMapper.insertWorkPersonnelBatch(reportNo, payload.getPersonnels());
            }

            if (payload.getMaterials() != null && !payload.getMaterials().isEmpty()) {
                adminPotholeMapper.insertWorkMaterialBatch(reportNo, payload.getMaterials());
            }

            if (payload.getScopes() != null && !payload.getScopes().isEmpty()) {
                adminPotholeMapper.insertWorkScopeBatch(reportNo, payload.getScopes());
            }

        } catch (Exception e) {
            throw new RuntimeException("작업정보 저장 실패", e);
        }
    }

    public Map<String, Object> getImsListData(Map<String, Object> params, UserCustom loginUser) {

        log.debug("[getImsListData] params : {}", params);

        Map<String, Object> searchParams = new HashMap<>();

        // ====== 검색 파라미터 ======
        String strtDt   = params.get("strtDt") != null ? params.get("strtDt").toString().trim() : "";
        String endDt    = params.get("endDt") != null ? params.get("endDt").toString().trim() : "";
        String siteCd   = params.get("siteCd") != null ? params.get("siteCd").toString().trim() : "";
        String statusCd = params.get("statusCd") != null ? params.get("statusCd").toString().trim() : "";
        String reportNo = params.get("reportNo") != null ? params.get("reportNo").toString().trim() : "";
        String workTypeCd  = params.get("workTypeCd") != null ? params.get("workTypeCd").toString().trim() : "";

        // ====== 페이징 ======
        int page = Integer.parseInt(params.getOrDefault("page", "1").toString());
        int pageSize = Integer.parseInt(params.getOrDefault("pageSize", "10").toString());
        int offset = (page - 1) * pageSize;

        searchParams.put("offset", offset);
        searchParams.put("pageSize", pageSize);

        // ====== 검색조건 ======
        if (!strtDt.isEmpty()) {
            searchParams.put("strtDt", strtDt);
        }

        if (!endDt.isEmpty()) {
            searchParams.put("endDt", endDt);
        }

        if (!statusCd.isEmpty()) {
            searchParams.put("statusCd", statusCd);
        }

        if (!reportNo.isEmpty()) {
            searchParams.put("reportNo", reportNo);
        }

        if (!workTypeCd.isEmpty()) {
            searchParams.put("workTypeCd", workTypeCd);
        }

        // ====== 관리대상 고속도로 조건 ======
        // 화면에서 직접 siteCd 선택 시 해당 값 우선 적용
        if (!siteCd.isEmpty()) {
            searchParams.put("siteCd", siteCd);
        } else {

            // 로그인 사용자 ID
            String userId = loginUser != null ? loginUser.getUserId() : null;

            // 관리대상 부모 현장 조회
            List<SiteInfo> manageSiteList = siteInfoMapper.getManageSiteByUserId(userId);

            // 부모 → 자식 포함해서 siteCdList 생성
            List<String> siteCdList = new ArrayList<>();

            if (manageSiteList != null && !manageSiteList.isEmpty()) {
                // 부모 코드 추출
                List<String> parentSiteCds = new ArrayList<>();
                for (SiteInfo site : manageSiteList) {
                    parentSiteCds.add(site.getSiteCd());
                }

                // 자식 현장 조회
                List<SiteInfo> childSites = siteInfoMapper.selectSiteListByParent(parentSiteCds);

                for (SiteInfo site : childSites) {
                    siteCdList.add(site.getSiteCd());
                }
            }

            log.debug("[getImsListData] siteCdList : " + siteCdList);

            // 관리대상 고속도로 제한
            if (!siteCdList.isEmpty()) {
                searchParams.put("siteCdList", siteCdList);
            }
        }

        log.debug("[getImsListData] searchParams : {}", searchParams);

        // ====== 목록 / 건수 ======
        List<Map<String, Object>> list = adminPotholeMapper.selectImsPotholeList(searchParams);
        int totalCount = adminPotholeMapper.selectImsPotholeCount(searchParams);

        // ====== 상태별 건수 ======
        Map<String, Object> sumParams = new HashMap<>(searchParams);
        sumParams.remove("offset");
        sumParams.remove("pageSize");

        Map<String, Object> summary = adminPotholeMapper.getImsStatusSummary(sumParams);
        if (summary == null) {
            summary = new HashMap<>();
        }

        // ====== 페이징 정보 ======
        Map<String, Object> pageInfo = new HashMap<>();
        pageInfo.put("currentPage", page);
        pageInfo.put("pageSize", pageSize);
        pageInfo.put("totalPages", (int) Math.ceil(totalCount / (double) pageSize));

        // ====== 결과 ======
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("pageInfo", pageInfo);
        result.put("totalCount", totalCount);
        result.put("summary", summary);

        return result;
    }

    /*  상태별 건수 집계 */
    public Map<String, Object> getImsStatusSummary(Map<String, Object> params) {
        return adminPotholeMapper.getImsStatusSummary(params);
    }

    private void deletePhotosByCsv(String reportNo, String photoGb, String csv) {

        List<Integer> sortOrds = Utils.parseCsvInt(csv);
        if (sortOrds.isEmpty()) return;

        for (int i = 0; i < sortOrds.size(); i++) {

            Integer sortOrd = sortOrds.get(i);
            if (sortOrd == null) continue;

            // 1) DB에서 key 조회 (✅ 이미 존재하는 selectPotholeImageOne 사용)
            PotholeImage p = potholeImageMapper.selectPotholeImageOne(reportNo, photoGb, sortOrd);

            // 2) S3 삭제
            if (p != null) {
                String key = (p.getImgPath() == null ? "" : p.getImgPath())
                        + (p.getImgName() == null ? "" : p.getImgName());

                if (!"".equals(key)) {
                    try { storageService.delete(key); } catch (Exception ignore) {}
                }
            }

            // 3) DB 삭제 (✅ 이미 존재하는 단건 delete)
            potholeImageMapper.deletePotholePhotoOne(reportNo, photoGb, sortOrd);
        }
    }

    private void ensureMainPhoto(String reportNo, String photoGb) {

        // 현재 사진 목록 조회 (✅ 이미 존재: selectPotholeImagesByReportNo)
        List<PotholeImage> list = potholeImageMapper.selectPotholeImagesByReportNo(reportNo, photoGb);
        if (list == null || list.isEmpty()) return;

        // 대표(Y)가 있으면 끝
        for (int i = 0; i < list.size(); i++) {
            PotholeImage p = list.get(i);
            if (p != null && "Y".equals(p.getIsMain())) return;
        }

        // 없으면 가장 작은 sortOrd를 대표로
        Integer minSort = null;
        for (int i = 0; i < list.size(); i++) {
            PotholeImage p = list.get(i);
            if (p == null || p.getSortOrd() == null) continue;
            if (minSort == null || p.getSortOrd() < minSort) minSort = p.getSortOrd();
        }
        if (minSort == null) return;

        potholeImageMapper.updateIsMainAllN(reportNo, photoGb);
        potholeImageMapper.updateIsMainOneY(reportNo, photoGb, minSort);
    }

    /** 작업정보(장비/인력/자재/범위)를 접수번호 기준으로 조회하여 반환한다. */
    public Map<String, Object> selectWorkInfoByReportNo(String reportNo) {

        Map<String, Object> out = new HashMap<>();

        out.put("equipments", adminPotholeMapper.selectWorkEquipmentByReportNo(reportNo));
        out.put("personnels", adminPotholeMapper.selectWorkPersonnelByReportNo(reportNo));
        out.put("materials",  adminPotholeMapper.selectWorkMaterialByReportNo(reportNo));
        out.put("scopes",     adminPotholeMapper.selectWorkScopeByReportNo(reportNo));

        return out;
    }

    /** reportNo 기준 보고서 출력용 데이터 생성 */
    public Map<String, Object> getReportData(String reportNo) throws Exception {

        Map<String, Object> detail = adminPotholeMapper.selectImsPotholeDetail(reportNo);
        if (detail == null) detail = new HashMap<>();

        List<Map<String, Object>> scopes  = adminPotholeMapper.selectWorkScopeByReportNo(reportNo);
        List<Map<String, Object>> persons = adminPotholeMapper.selectWorkPersonnelByReportNo(reportNo);
        List<Map<String, Object>> equips  = adminPotholeMapper.selectWorkEquipmentByReportNo(reportNo);
        List<Map<String, Object>> mats    = adminPotholeMapper.selectWorkMaterialByReportNo(reportNo);

        Map<String, Object> data = new HashMap<>();

        // ===== 상단 문서번호 =====
        data.put("docNo", nvl(detail.get("docNo")));       // pothole.doc_no / 문서번호 (JSP: 상단 NO)
        if ("".equals(nvl(data.get("docNo")))) {
            data.put("docNo", reportNo);                   // fallback → report_no
        }

        // ===== 발생위치 =====
        data.put("region", nvl(detail.get("addr")));       // pothole.addr / 행정구역
        data.put("roadInfo", buildRoadInfo(detail));       // STA + 방향 + 노선정보 조합 문자열

        // ===== 체크박스 (포장형식 / 발생장소) =====
        String pavingType = nvl(detail.get("pavementTypeCds"));  // pothole.pavement_type_cds (예: ASP,CON)
        String placeType  = nvl(detail.get("occurPlaceCds"));    // pothole.occur_place_cds   (예: ROAD,BRIDGE)

        data.put("isAsp", hasToken(pavingType, "ASP"));
        data.put("isCon", hasToken(pavingType, "CONC"));     // ✅ CON -> CONC

        data.put("isRoad",   hasToken(placeType, "EARTH"));  // ✅ ROAD -> EARTH
        data.put("isBridge", hasToken(placeType, "BRIDGE"));
        data.put("isTunnel", hasToken(placeType, "TUNNEL"));


        // ===== 발생현황 =====
        String reportDateTime = nvl(detail.get("reportDate"));   // pothole.report_date
        data.put("reportDate", onlyDate(reportDateTime));        // 발생일자
        data.put("reportTime", onlyTime(reportDateTime));        // 발생시간
        data.put("reportYear", extractYear(reportDateTime));     // 보고서 상단 연도 표시

        data.put("weatherNm", nvl(detail.get("weatherNm")));     // 기상코드명 (CD_COMMON 조인)

        // ===== 발생수량 =====
        Map<String, Object> scope0 = pickFirstScope(scopes);     // pothole_work_scope 첫번째 row

        data.put("widthM",  nvl(scope0.get("widthM")));          // width_m  / 가로(m)
        data.put("heightM", nvl(scope0.get("heightM")));         // height_m / 세로(m)
        data.put("areaM2",  nvl(scope0.get("areaM2")));          // area_m2  / 면적(㎡)
        data.put("depthCm", nvl(scope0.get("depthCm")));         // depth_cm / 깊이(cm)

        // ===== 조치현황 =====
        String workEndAt   = nvl(detail.get("workEndAt"));       // pothole.work_end_at
        String workStartAt = nvl(detail.get("workStartAt"));     // pothole.work_start_at
        String workDateTime = !"".equals(workEndAt) ? workEndAt : workStartAt;

        data.put("workDate", onlyDate(workDateTime));            // 조치일자
        data.put("workTime", onlyTime(workDateTime));            // 조치시간
        data.put("workWeatherNm", nvl(detail.get("workWeatherNm"))); // 조치 당시 날씨

        // ===== 투입인원 =====
        int workerCnt = (persons == null ? 0 : persons.size());  // pothole_work_personnel row count
        data.put("workers", workerCnt > 0 ? ("총 " + workerCnt + "명") : "");

        // ===== 투입장비 =====
        data.put("equip", buildEquipText(equips));               // 장비명 콤마 join

        // ===== 투입자재 =====
        data.put("material", buildMaterialText(mats));           // 자재명 콤마 join

        // ===== 사진 =====
        data.put("beforeImgBase64", getMainPhotoBase64(reportNo, "BEFORE")); // 조치 전 대표사진
        data.put("afterImgBase64",  getMainPhotoBase64(reportNo, "AFTER"));  // 조치 후 대표사진

        return data;
    }


    private String getMainPhotoBase64(String reportNo, String photoGb) {

        try {
            if (!isLedgerPhotoBase64Enabled()) return "";
            PotholeImage main = findMainPhoto(reportNo, photoGb);
            if (main == null) return "";

            String key = buildS3Key(main.getImgPath(), main.getImgName());
            if ("".equals(key)) return "";

            byte[] bytes = storageService.downloadBytes(key);
            if (bytes == null || bytes.length == 0) return "";

            String mime = guessMime(main.getImgName());
            String b64  = Base64.getEncoder().encodeToString(bytes);

            return "data:" + mime + ";base64," + b64;

        } catch (Exception e) {
            log.warn("대표사진 base64 변환 실패 reportNo=" + reportNo + " photoGb=" + photoGb, e);
            return "";
        }
    }

    private boolean isLedgerPhotoBase64Enabled() {
        return false;
    }

    private String buildS3Key(String imgPath, String imgName) {

        String p = (imgPath == null ? "" : imgPath.trim());
        String n = (imgName == null ? "" : imgName.trim());

        if ("".equals(p) || "".equals(n)) return "";

        if (!p.endsWith("/")) p = p + "/";

        return p + n;
    }

    private String guessMime(String fileName) {
        String f = (fileName == null ? "" : fileName.toLowerCase());
        if (f.endsWith(".png")) return "image/png";
        if (f.endsWith(".gif")) return "image/gif";
        if (f.endsWith(".webp")) return "image/webp";
        return "image/jpeg"; // jpg/jpeg 기본
    }

    private PotholeImage findMainPhoto(String reportNo, String photoGb) {

        List<PotholeImage> list = potholeImageMapper.selectPotholeImagesByReportNo(reportNo, photoGb);
        if (list == null || list.isEmpty()) return null;

        PotholeImage min = null;
        Integer minOrd = null;

        for (int i = 0; i < list.size(); i++) {
            PotholeImage p = list.get(i);
            if (p == null) continue;

            if ("Y".equals(p.getIsMain())) return p;

            Integer ord = p.getSortOrd();
            if (ord == null) continue;

            if (min == null || minOrd == null || ord < minOrd) {
                min = p;
                minOrd = ord;
            }
        }
        return min;
    }


    private boolean hasToken(String csv, String token) {
        if (csv == null) return false;

        String s = csv.trim();
        if (s.isEmpty()) return false;

        // "ASP, CON" 같이 공백 섞여도 처리
        String[] arr = s.split(",");

        for (int i = 0; i < arr.length; i++) {
            String t = arr[i] == null ? "" : arr[i].trim();
            if (token.equals(t)) return true;
        }
        return false;
    }


    private Map<String, Object> pickFirstScope(List<Map<String, Object>> scopes) {
        if (scopes == null || scopes.isEmpty()) return new HashMap<>();

        Map<String, Object> best = null;
        Integer bestOrd = null;

        for (int i = 0; i < scopes.size(); i++) {
            Map<String, Object> r = scopes.get(i);
            if (r == null) continue;

            Integer ord = null;
            Object v = r.get("sortOrd");
            if (v != null) {
                try { ord = Integer.valueOf(String.valueOf(v)); } catch (Exception ignore) {}
            }

            if (best == null) {
                best = r;
                bestOrd = ord;
            } else {
                if (ord != null && (bestOrd == null || ord < bestOrd)) {
                    best = r;
                    bestOrd = ord;
                }
            }
        }
        return best == null ? new HashMap<>() : best;
    }

    private String extractYear(String dt) {

        if (dt == null || dt.length() < 4) return "";

        return dt.substring(0, 4);
    }

    private String buildRoadInfo(Map<String, Object> detail) {
        String staText = nvl(detail.get("staText"));
        String staRef  = nvl(detail.get("staRefName"));
        if (staText.isEmpty()) return "";
        if (!staRef.isEmpty()) return "STA " + staText + "(" + staRef + ")";
        return "STA " + staText;
    }

    private String buildEquipText(List<Map<String, Object>> equips) {
        if (equips == null || equips.isEmpty()) return "";
        // 예: "컷팅기, 파괴함마, 다짐장비"
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < equips.size(); i++) {
            String name = nvl(equips.get(i).get("equipName"));
            if (name.isEmpty()) continue;
            if (sb.length() > 0) sb.append(", ");
            sb.append(name);
        }
        return sb.toString();
    }

    private String buildMaterialText(List<Map<String, Object>> mats) {
        if (mats == null || mats.isEmpty()) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < mats.size(); i++) {
            String name = nvl(mats.get(i).get("materialName"));
            if (name.isEmpty()) continue;
            if (sb.length() > 0) sb.append(", ");
            sb.append(name);
        }
        return sb.toString();
    }

    private String onlyDate(String dt) {
        if (dt == null) return "";
        int sp = dt.indexOf(" ");
        return sp > 0 ? dt.substring(0, sp) : dt;
    }

    private String onlyTime(String dt) {

        if (dt == null || dt.isEmpty()) return "";

        int sp = dt.indexOf(" ");
        if (sp < 0) return "";

        String t = dt.substring(sp + 1); // HH:mm:ss

        if (t.length() < 5) return "";

        String hh = t.substring(0, 2);
        String mm = t.substring(3, 5);

        int hour;
        try {
            hour = Integer.parseInt(hh);
        } catch (Exception e) {
            return "";
        }

        String ampm = (hour < 12) ? "AM" : "PM";

        int displayHour = hour % 12;
        if (displayHour == 0) displayHour = 12;

        return String.format("%02d:%s", displayHour, mm) + " " +  ampm ;
    }

    private String nvl(Object v) {
        return v == null ? "" : String.valueOf(v);
    }

    // 포트홀 최초 생성(CREATE) 이력 저장
    private void saveCreateHistory(Pothole pothole, String userId) {
        try {
            if (pothole == null) return;

            Map<String, Object> afterMap = buildHistoryTargetMap(pothole);

            PotholeHistory history = new PotholeHistory();
            history.setReportNo(pothole.getReportNo());
            history.setActionType("CREATE");
            history.setChangedFields(String.join(",", afterMap.keySet()));
            history.setBeforeData(null);
            history.setAfterData(objectMapper.writeValueAsString(afterMap));
            history.setActionUserId(userId);
            history.setActionMemo("관리자 포트홀 등록");

            potholeMapper.insertPotholeHistory(history);

        } catch (Exception e) {
            log.error("관리자 포트홀 생성 이력 저장 실패. reportNo=" + (pothole == null ? "" : pothole.getReportNo()), e);
        }
    }

    // 포트홀 수정 이력 저장 (before/after 비교)
    private void savePotholeHistory(
            Pothole before,
            Pothole after,
            String userId,
            String actionTypeDefault,
            String actionMemoDefault
    ) {
        try {
            if (before == null || after == null) return;

            Map<String, Object> beforeMap = buildHistoryTargetMap(before);
            Map<String, Object> afterMap = buildHistoryTargetMap(after);

            Map<String, Object> changedBefore = new LinkedHashMap<String, Object>();
            Map<String, Object> changedAfter = new LinkedHashMap<String, Object>();
            List<String> changedFields = new ArrayList<String>();

            for (String key : beforeMap.keySet()) {
                Object beforeValue = beforeMap.get(key);
                Object afterValue = afterMap.get(key);

                String beforeStr = beforeValue == null ? null : String.valueOf(beforeValue);
                String afterStr = afterValue == null ? null : String.valueOf(afterValue);

                if (!java.util.Objects.equals(beforeStr, afterStr)) {
                    changedFields.add(key);
                    changedBefore.put(key, beforeValue);
                    changedAfter.put(key, afterValue);
                }
            }

            if (changedFields.isEmpty()) return;

            String actionType = resolveActionType(changedFields, actionTypeDefault);
            String actionMemo = buildActionMemo(changedFields, actionMemoDefault);

            PotholeHistory history = new PotholeHistory();
            history.setReportNo(after.getReportNo());
            history.setActionType(actionType);
            history.setChangedFields(String.join(",", changedFields));
            history.setBeforeData(objectMapper.writeValueAsString(changedBefore));
            history.setAfterData(objectMapper.writeValueAsString(changedAfter));
            history.setActionUserId(userId);
            history.setActionMemo(actionMemo);

            potholeMapper.insertPotholeHistory(history);

        } catch (Exception e) {
            log.error("관리자 포트홀 수정 이력 저장 실패. reportNo=" + (after == null ? "" : after.getReportNo()), e);
        }
    }

    // 포트홀 이력 비교 대상 컬럼 맵 생성
    private Map<String, Object> buildHistoryTargetMap(Pothole p) {
        Map<String, Object> map = new LinkedHashMap<String, Object>();

        map.put("reportDate", p.getReportDate());
        map.put("statusCd", p.getStatusCd());
        map.put("siteCd", p.getSiteCd());
        map.put("adminSiteCd", p.getAdminSiteCd());
        map.put("directionCd", p.getDirectionCd());
        map.put("addr", p.getAddr());
        map.put("detailInfo", p.getDetailInfo());
        map.put("deliveryNote", p.getDeliveryNote());
        map.put("receiverId", p.getReceiverId());
        map.put("managerId", p.getManagerId());
        map.put("processNote", p.getProcessNote());
        map.put("workStartAt", p.getWorkStartAt());
        map.put("workEndAt", p.getWorkEndAt());
        map.put("weatherCd", p.getWeatherCd());
        map.put("workWeatherCd", p.getWorkWeatherCd());
        map.put("receiptGbCd", p.getReceiptGbCd());
        map.put("staMeters", p.getStaMeters());
        map.put("staKmDecimal", p.getStaKmDecimal());
        map.put("staText", p.getStaText());
        map.put("pavementTypeCds", p.getPavementTypeCds());
        map.put("occurPlaceCds", p.getOccurPlaceCds());
        map.put("docNo", p.getDocNo());

        return map;
    }

    // 변경 컬럼 기준으로 action_type 판별
    private String resolveActionType(List<String> changedFields, String defaultActionType) {

        if (changedFields.size() == 1 && changedFields.contains("statusCd")) {
            return "STATUS_CHANGE";
        }

        if (changedFields.size() == 1 && changedFields.contains("managerId")) {
            return "ASSIGN";
        }

        if (changedFields.size() == 1 && changedFields.contains("workStartAt")) {
            return "WORK_START";
        }

        if (changedFields.size() == 1 && changedFields.contains("workEndAt")) {
            return "WORK_END";
        }

        return defaultActionType;
    }

    /* 변경 컬럼 정보를 포함한 action_memo 생성
    private String buildActionMemo(List<String> changedFields, String defaultMemo) {
        if (changedFields == null || changedFields.isEmpty()) {
            return defaultMemo;
        }
        return defaultMemo + " [" + String.join(", ", changedFields) + "]";
    }*/

    // 변경 컬럼 정보를 포함한 action_memo 생성
    private String buildActionMemo(List<String> changedFields, String defaultMemo) {
        return defaultMemo;
    }

    // 관리대장 PDF에 사용할 전체 데이터를 생성 (조회 → 가공 → 월별 그룹화)
    public Map<String, Object> getLedgerPdfData(List<String> reportNos, UserCustom loginUser) {

        Map<String, Object> result = new HashMap<String, Object>();

        // 관리대장 행 데이터 조회
        List<Map<String, Object>> rows = adminPotholeMapper.selectLedgerRowsForReportExport(reportNos);

        // 포장/발생위치 체크박스용 플래그 생성
        applyLedgerFlags(rows);

        // 대표사진을 Base64로 변환하여 row에 추가
        applyLedgerPhotoBase64(rows);

        String reportYear = "";
        String siteName = "";

        if (rows != null && !rows.isEmpty()) {

            // 첫 번째 데이터에서 보고서 연도 추출
            Object yearObj = rows.get(0).get("reportYear");
            reportYear = yearObj != null ? String.valueOf(yearObj) : "";

            // 첫 번째 데이터에서 현장명(siteName) 추출 → 표지에 사용
            Object siteObj = rows.get(0).get("siteName");
            siteName = siteObj != null ? String.valueOf(siteObj) : "";
        }

        // 월별로 데이터 그룹화
        List<Map<String, Object>> monthGroups = buildMonthGroups(rows, reportYear);

        // 연간 합계 데이터 생성
        Map<String, Object> yearSummary = new HashMap<String, Object>();
        yearSummary.put("potholeCount", rows == null ? 0 : rows.size());
        yearSummary.put("patchCount", 0);
        yearSummary.put("etcCount", 0);

        // JSP에서 사용할 데이터 세팅
        result.put("reportYear", reportYear);   // 보고서 연도
        result.put("siteName", siteName);       // 표지에 표시할 현장명
        result.put("yearSummary", yearSummary); // 연간 합계
        result.put("monthGroups", monthGroups); // 월별 데이터

        return result;
    }


    // 각 row에 대표사진(BEFORE/AFTER)을 Base64 이미지로 추가
    private void applyLedgerPhotoBase64(List<Map<String, Object>> rows) {

        if (rows == null) return;

        for (Map<String, Object> row : rows) {

            String reportNo = row.get("reportNo") == null ? "" : String.valueOf(row.get("reportNo"));

            row.put("beforeImgBase64", getMainPhotoBase64(reportNo, "BEFORE"));
            row.put("afterImgBase64", getMainPhotoBase64(reportNo, "AFTER"));

        }
    }


    // 조회된 행 데이터를 월 기준으로 그룹화하여 관리대장 구조 생성
    private List<Map<String, Object>> buildMonthGroups(List<Map<String, Object>> rows, String reportYear) {

        List<Map<String, Object>> monthGroups = new ArrayList<Map<String, Object>>();
        if (rows == null || rows.isEmpty()) return monthGroups;

        Map<String, Map<String, Object>> grouped = new LinkedHashMap<String, Map<String, Object>>();

        for (Map<String, Object> row : rows) {

            String month = row.get("reportMonth") != null ? String.valueOf(row.get("reportMonth")) : "";

            Map<String, Object> group = grouped.get(month);

            // 월 그룹이 없으면 생성
            if (group == null) {
                group = new HashMap<String, Object>();
                group.put("month", month);
                group.put("reportYear", reportYear);
                group.put("rows", new ArrayList<Map<String, Object>>());
                grouped.put(month, group);
            }

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> groupRows = (List<Map<String, Object>>) group.get("rows");

            // 해당 월 그룹에 row 추가
            groupRows.add(row);
        }

        // 월별 요약정보 생성
        for (Map<String, Object> group : grouped.values()) {

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> groupRows = (List<Map<String, Object>>) group.get("rows");

            Map<String, Object> summary = new HashMap<String, Object>();
            summary.put("potholeCount", groupRows.size());
            summary.put("patchCount", 0);
            summary.put("etcCount", 0);

            group.put("summary", summary);

            monthGroups.add(group);
        }

        return monthGroups;
    }


    // 포장형식 및 발생위치 코드값을 체크박스 플래그 및 표시 텍스트로 변환
    private void applyLedgerFlags(List<Map<String, Object>> rows) {

        if (rows == null || rows.isEmpty()) return;

        for (Map<String, Object> row : rows) {

            String pavement = row.get("pavementTypeCds") != null ? String.valueOf(row.get("pavementTypeCds")) : "";
            String occur = row.get("occurPlaceCds") != null ? String.valueOf(row.get("occurPlaceCds")) : "";

            // 포장형식 체크
            row.put("isAsp", pavement.contains("008001"));
            row.put("isCon", pavement.contains("008002"));

            // 발생위치 체크
            row.put("isRoad", occur.contains("009001"));
            row.put("isBridge", occur.contains("009002"));
            row.put("isTunnel", occur.contains("009003"));

            // 표시용 텍스트 생성
            row.put("pavementText", buildPavementText(
                    (Boolean) row.get("isAsp"),
                    (Boolean) row.get("isCon")
            ));

            row.put("occurPlaceText", buildOccurPlaceText(
                    (Boolean) row.get("isRoad"),
                    (Boolean) row.get("isBridge"),
                    (Boolean) row.get("isTunnel")
            ));
        }
    }


    // 포장형식 표시 문자열 생성
    private String buildPavementText(Boolean isAsp, Boolean isCon) {

        StringBuilder sb = new StringBuilder();

        if (Boolean.TRUE.equals(isAsp)) sb.append("아스팔트");

        if (Boolean.TRUE.equals(isCon)) {
            if (sb.length() > 0) sb.append(", ");
            sb.append("콘크리트");
        }

        return sb.toString();
    }


    // 발생위치 표시 문자열 생성
    private String buildOccurPlaceText(Boolean isRoad, Boolean isBridge, Boolean isTunnel) {

        StringBuilder sb = new StringBuilder();

        if (Boolean.TRUE.equals(isRoad)) sb.append("도로부");

        if (Boolean.TRUE.equals(isBridge)) {
            if (sb.length() > 0) sb.append(", ");
            sb.append("교량부");
        }

        if (Boolean.TRUE.equals(isTunnel)) {
            if (sb.length() > 0) sb.append(", ");
            sb.append("터널부");
        }

        return sb.toString();
    }

    /**
     * 상세모달에서 드래그로 변경된 작업 전/후 사진 위치 및 정렬순서를 DB에 반영한다.
     *
     * @param reportNo
     * @param photoMoveJson
     */
    @SuppressWarnings("unchecked")
    private void applyPhotoMove(String reportNo, String photoMoveJson) {
        if (photoMoveJson == null || photoMoveJson.trim().isEmpty()) return;

        try {
            List<Map<String, Object>> list =
                    objectMapper.readValue(photoMoveJson, List.class);

            if (list == null || list.isEmpty()) return;

            // 1차: 전부 임시 sort_ord로 이동해서 UNIQUE 충돌 방지
            for (int i = 0; i < list.size(); i++) {
                Map<String, Object> item = list.get(i);

                String fromPhotoGb = Utils.safeStr(item.get("fromPhotoGb"));
                Integer fromSortOrd = Utils.toInt(item.get("fromSortOrd"));

                if ("".equals(fromPhotoGb) || fromSortOrd == null) {
                    continue;
                }

                Map<String, Object> param = new HashMap<>();
                param.put("reportNo", reportNo);
                param.put("fromPhotoGb", fromPhotoGb);
                param.put("fromSortOrd", fromSortOrd);
                param.put("tempSortOrd", 1000 + i);

                potholeImageMapper.movePhotoToTempSortOrd(param);
            }

            // 2차: 최종 photo_gb / sort_ord 반영
            for (int i = 0; i < list.size(); i++) {
                Map<String, Object> item = list.get(i);

                String fromPhotoGb = Utils.safeStr(item.get("fromPhotoGb"));
                String toPhotoGb = Utils.safeStr(item.get("toPhotoGb"));
                Integer toSortOrd = Utils.toInt(item.get("toSortOrd"));

                if ("".equals(fromPhotoGb) || "".equals(toPhotoGb) || toSortOrd == null) {
                    continue;
                }

                Map<String, Object> param = new HashMap<>();
                param.put("reportNo", reportNo);
                param.put("fromPhotoGb", fromPhotoGb);
                param.put("tempSortOrd", 1000 + i);
                param.put("toPhotoGb", toPhotoGb);
                param.put("toSortOrd", toSortOrd);

                potholeImageMapper.movePhotoToFinalGbAndSortOrd(param);
            }

        } catch (Exception e) {
            throw new RuntimeException("사진 이동 정보 저장 실패", e);
        }
    }


}
