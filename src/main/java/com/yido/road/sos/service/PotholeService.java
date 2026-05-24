package com.yido.road.sos.service;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.yido.road.sos.component.storage.S3StorageService;
import com.yido.road.sos.component.storage.UploadResult;
import com.yido.road.sos.enums.SmsTemplateCode;
import com.yido.road.sos.model.Pothole;
import com.yido.road.sos.model.PotholeHistory;
import com.yido.road.sos.model.PotholeImage;
import com.yido.road.sos.model.StaCalcResult;
import com.yido.road.sos.repository.main.AdminUserMapper;
import com.yido.road.sos.repository.main.PotholeImageMapper;
import com.yido.road.sos.repository.main.PotholeMapper;
import com.yido.road.sos.service.api.StaService;
import com.yido.road.sos.service.api.WeatherService;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.*;


@Slf4j
@Service
@RequiredArgsConstructor
public class PotholeService {

    private static final ZoneId ZONE_SEOUL = ZoneId.of("Asia/Seoul");
    private static final int MAX_PHOTO = 20;

    private final ObjectMapper objectMapper;
    private final PotholeMapper potholeMapper;
    private final PotholeImageMapper potholeImageMapper;
    private final S3StorageService storageService;
    private final WeatherService weatherService;
    private final CommonService commonService;
    private final StaService staService;
    private final AdminUserMapper adminUserMapper;

    public Pothole selectPotholeByReportNo(String reportNo) {
        return potholeMapper.selectPotholeByReportNo(reportNo);
    }

    public String selectNextDocNo(String docGb) {
        return potholeMapper.selectNextDocNo(docGb);
    }

    /**
     * 접수 완료 후 담당자(RECEIPT)에게 SMS 발송 (트랜잭션 커밋 이후 실행)
     */
    @Transactional
    public String insertPothole(Pothole pothole, HttpServletRequest request) {

        // 1. 기본값 보정
        if (pothole.getDirectionCd() == null || pothole.getDirectionCd().trim().isEmpty()) {
            pothole.setDirectionCd("UP");
        }

        if (pothole.getReceiptGbCd() == null || pothole.getReceiptGbCd().trim().isEmpty()) {
            pothole.setReceiptGbCd("POTHOLE");
        }

        if (pothole.getReportDate() == null) {
            pothole.setReportDate(LocalDateTime.now());
        }

        pothole.setRegIp(Utils.getClientIpAddress(request));
        pothole.setServerReceivedAt(LocalDateTime.now());
        pothole.setStatusCd("RECEIVED");

        // 2. capturedTs -> capturedAt 변환
        if (pothole.getCapturedTs() != null) {
            LocalDateTime capturedAt = LocalDateTime.ofInstant(
                    Instant.ofEpochMilli(pothole.getCapturedTs()),
                    ZoneId.systemDefault()
            );
            pothole.setCapturedAt(capturedAt);
        }

        // 3. 접수번호 / 문서번호 생성
        String reportNo = potholeMapper.selectNextReportNo();
        String docNo = potholeMapper.selectNextDocNo("U");

        pothole.setReportNo(reportNo);
        pothole.setDocNo(docNo);

        pothole.setRegDatetime(LocalDateTime.now());
        pothole.setUpdateDatetime(LocalDateTime.now());

        // 5. STA 계산
        if (pothole.getLat() != null
                && pothole.getLng() != null
                && pothole.getSiteCd() != null && !pothole.getSiteCd().trim().isEmpty()
                && pothole.getDirectionCd() != null && !pothole.getDirectionCd().trim().isEmpty()) {

            try {
                StaCalcResult sta = staService.calcSta(
                        pothole.getSiteCd(),
                        pothole.getDirectionCd(),
                        pothole.getLat().doubleValue(),
                        pothole.getLng().doubleValue()
                );

                log.debug("[insertPothole] sta = " + sta);
                if (sta != null && sta.getStaMeters() != null) {
                    pothole.setStaMeters(sta.getStaMeters());

                    if (sta.getStaMeters() != null) {
                        pothole.setStaKmDecimal(
                                new java.math.BigDecimal(sta.getStaMeters())
                                        .divide(new java.math.BigDecimal("1000"), 3, java.math.RoundingMode.DOWN)
                        );
                    } else {
                        pothole.setStaKmDecimal(sta.getStaKmDecimal());
                    }

                    pothole.setStaText(sta.getStaText());
                }

                log.debug("[insertPothole] pothole = " + pothole);
            } catch (Exception e) {
                log.warn("[포트홀 접수] STA 계산 실패. siteCd={}, directionCd={}, lat={}, lng={}",
                        pothole.getSiteCd(), pothole.getDirectionCd(), pothole.getLat(), pothole.getLng(), e);
            }
        }

        // 6. 본문 저장
        potholeMapper.insertPothole(pothole);

        // 마지막 접수유형 저장
        if (pothole.getReceiverId() != null
                && !pothole.getReceiverId().trim().isEmpty()
                && pothole.getReceiptGbCd() != null
                && !pothole.getReceiptGbCd().trim().isEmpty()) {

            Map<String, Object> param = new HashMap<>();
            param.put("userId", pothole.getReceiverId());
            param.put("lastReceiptGbCd", pothole.getReceiptGbCd());

            adminUserMapper.updateLastReceiptGbCd(param);
        }

        // 7. 이력 저장
        saveCreateHistory(pothole, pothole.getReceiverId());

        // 8. 사진 저장
        MultipartFile[] photos = pothole.getPhotos();
        List<Integer> photoIndexes = pothole.getPhotoIndexes();
        String mainIndex = pothole.getMainIndex();

        if (photos != null && photos.length > 0) {
            int sortOrd = 1;

            for (int i = 0; i < photos.length; i++) {
                MultipartFile file = photos[i];

                if (file == null || file.isEmpty()) {
                    continue;
                }

                if (sortOrd > MAX_PHOTO) {
                    break;
                }

                UploadResult uploadResult = storageService.uploadPotholeBefore(
                        reportNo,
                        sortOrd,
                        pothole.getReceiptGbCd(),
                        file
                );

                Integer originIdx = null;
                if (photoIndexes != null && photoIndexes.size() > i) {
                    originIdx = photoIndexes.get(i);
                }

                String isMain = "N";

                if (mainIndex != null && !mainIndex.trim().isEmpty() && originIdx != null) {
                    if (mainIndex.equals(String.valueOf(originIdx))) {
                        isMain = "Y";
                    }
                }

                // 대표사진 미지정 시 첫 번째 사진 대표 처리
                if ((mainIndex == null || mainIndex.trim().isEmpty()) && sortOrd == 1) {
                    isMain = "Y";
                }

                PotholeImage image = new PotholeImage();
                image.setReportNo(reportNo);
                image.setPhotoGb("BEFORE");
                image.setImgPath(uploadResult.getPath());
                image.setImgName(uploadResult.getName());
                image.setSortOrd(sortOrd);
                image.setIsMain(isMain);

                potholeImageMapper.insertPotholeImage(image);

                sortOrd++;
            }
        }

        // SMS 발송
        commonService.sendSmsAfterCommit(pothole.getReportNo(), SmsTemplateCode.WORK_START, "APPLY");
        return reportNo;
    }


    /* 포트홀 최초 접수 등록 시 pothole 테이블 생성 이력을 저장한다. */
    private void saveCreateHistory(Pothole pothole, String userId) {
        try {
            if (pothole == null) {
                return;
            }

            java.util.Map<String, Object> afterMap = new java.util.LinkedHashMap<String, Object>();
            afterMap.put("reportNo", pothole.getReportNo());
            afterMap.put("docNo", pothole.getDocNo());
            afterMap.put("reportDate", pothole.getReportDate());
            afterMap.put("statusCd", pothole.getStatusCd());
            afterMap.put("siteCd", pothole.getSiteCd());
            afterMap.put("adminSiteCd", pothole.getAdminSiteCd());
            afterMap.put("lat", pothole.getLat());
            afterMap.put("lng", pothole.getLng());
            afterMap.put("accuracyM", pothole.getAccuracyM());
            afterMap.put("capturedAt", pothole.getCapturedAt());
            afterMap.put("capturedTs", pothole.getCapturedTs());
            afterMap.put("addr", pothole.getAddr());
            afterMap.put("detailInfo", pothole.getDetailInfo());
            afterMap.put("deliveryNote", pothole.getDeliveryNote());
            afterMap.put("receiverId", pothole.getReceiverId());
            afterMap.put("directionCd", pothole.getDirectionCd());
            afterMap.put("weatherCd", pothole.getWeatherCd());
            afterMap.put("temp", pothole.getTemp());
            afterMap.put("workTemp", pothole.getWorkTemp());

            afterMap.put("staMeters", pothole.getStaMeters());
            afterMap.put("staKmDecimal", pothole.getStaKmDecimal());
            afterMap.put("staText", pothole.getStaText());

            PotholeHistory history = new PotholeHistory();
            history.setReportNo(pothole.getReportNo());
            history.setActionType("CREATE");
            history.setChangedFields("reportNo,docNo,reportDate,statusCd,siteCd,adminSiteCd,lat,lng,accuracyM,capturedAt,capturedTs,addr,detailInfo,deliveryNote,receiverId,directionCd,weatherCd,temp,staMeters,staKmDecimal,staText");
            history.setBeforeData(null);
            history.setAfterData(objectMapper.writeValueAsString(afterMap));
            history.setActionUserId(userId);
            history.setActionMemo("최초 접수 등록");

            potholeMapper.insertPotholeHistory(history);

        } catch (Exception e) {
            log.error("포트홀 생성 이력 저장 실패. reportNo=" + (pothole == null ? "" : pothole.getReportNo()), e);
        }
    }

    /* 접수하기 */
    @Transactional
    public void updatePotholeWithPhotos(Pothole pothole, String userId, javax.servlet.http.HttpServletRequest request) {

        String reportNo = pothole.getReportNo();
        Pothole before = potholeMapper.selectPotholeByReportNo(reportNo);

        // =========================
        // 1) pothole 텍스트 업데이트
        // =========================
        Map<String, Object> p = new HashMap<>();
        p.put("reportNo", pothole.getReportNo());
        p.put("receiverId", pothole.getReceiverId());
        p.put("receiptGbCd", pothole.getReceiptGbCd());
        p.put("updateId", userId);
        p.put("updateIp", Utils.getClientIpAddress(request));
        p.put("reportDate", pothole.getReportDate());
        p.put("directionCd", pothole.getDirectionCd());
        p.put("detailInfo", pothole.getDetailInfo());
        p.put("deliveryNote", pothole.getDeliveryNote());

        // 위치/주소/날씨는 “화면에서 locationUpdated=Y 일 때만” 값이 들어올 수 있음
        p.put("lat", pothole.getLat());
        p.put("lng", pothole.getLng());
        p.put("accuracyM", pothole.getAccuracyM());
        p.put("capturedAt", pothole.getCapturedAt());
        p.put("capturedTs", pothole.getCapturedTs());
        p.put("addr", pothole.getAddr());
        p.put("weatherCd", pothole.getWeatherCd());

        potholeMapper.updatePotholeText(p);

        Pothole after = potholeMapper.selectPotholeByReportNo(reportNo);
        savePotholeHistory(before, after, userId, "UPDATE", "접수내용 수정");

        // ==========================================
        // 2) BEFORE 사진 삭제/추가 + 대표 정리
        // ==========================================
        final String photoGb = "BEFORE";

        // 대표값(프론트에서 넘어옴)
        final String beforeMainSortOrdStr = Utils.safeTrim(pothole.getBeforeMainSortOrd());     // 기존 대표 sortOrd
        final String beforeMainNewIndexStr = Utils.safeTrim(pothole.getBeforeMainNewIndex());  // 신규 대표 newIndex

        // 삭제할 sortOrd 목록
        List<Integer> deleteSortOrds = pothole.getDeleteSortOrds();

        // 신규 업로드 파일 + 그 파일의 editNewFiles 인덱스(프론트가 같이 보내줘야 정확히 대표 매칭 가능)
        MultipartFile[] photos = pothole.getPhotos();
        List<Integer> photoIndexes = pothole.getPhotoIndexes();

        // (1) 기존 목록 로드(삭제 시 S3 key 찾기 용도)
        List<PotholeImage> existing =
                potholeImageMapper.selectPotholeImagesByReportNo(reportNo, photoGb);

        // (2) 삭제 처리: DB 삭제 + 스토리지 삭제
        if (deleteSortOrds != null && !deleteSortOrds.isEmpty()) {
            for (Integer ord : deleteSortOrds) {
                if (ord == null) continue;

                PotholeImage img = findBySortOrd(existing, ord);
                if (img != null) {
                    String key = Utils.safe(img.getImgPath()) + Utils.safe(img.getImgName());
                    if (!"".equals(key.trim())) {
                        storageService.delete(key);
                    }
                }
                potholeImageMapper.deletePotholePhotoOne(reportNo, photoGb, ord);
            }
        }

        // (3) 빈 슬롯 계산(1~5)
        List<Integer> used = potholeImageMapper.selectUsedSortOrds(reportNo, photoGb);
        List<Integer> empty = new ArrayList<>();
        for (int i = 1; i <= MAX_PHOTO; i++) {
            if (used == null || !used.contains(i)) empty.add(i);
        }

        // (4) 신규 newIndex -> 실제 저장된 sortOrd 매핑
        Map<Integer, Integer> newIndexToOrd = new HashMap<>();

        // (5) 추가 처리
        if (photos != null && photos.length > 0 && !empty.isEmpty()) {

            int slotIdx = 0;

            for (int k = 0; k < photos.length; k++) {
                MultipartFile f = photos[k];
                if (f == null || f.isEmpty()) continue;
                if (slotIdx >= empty.size()) break;

                Integer ord = empty.get(slotIdx);

                UploadResult up = storageService.uploadPotholeBefore(
                        reportNo,
                        ord,
                        pothole.getReceiptGbCd(),
                        f
                );
                if (up == null) continue;

                // ✅ 이 파일의 원래 editNewFiles 인덱스(newIndex)
                Integer newIndex = null;
                if (photoIndexes != null && photoIndexes.size() > k) {
                    newIndex = photoIndexes.get(k);
                }

                // ✅ NOT NULL 컬럼 대응: 기본값 'N' 무조건 세팅
                PotholeImage pi = new PotholeImage();
                pi.setReportNo(reportNo);
                pi.setPhotoGb(photoGb);
                pi.setSortOrd(ord);
                pi.setImgPath(up.getPath());
                pi.setImgName(up.getName());
                pi.setIsMain("N");

                potholeImageMapper.upsertPotholePhoto(pi);

                if (newIndex != null) {
                    newIndexToOrd.put(newIndex, ord);
                }

                slotIdx++;
            }
        }

        // (6) 대표 1개만 Y로 정리
        List<PotholeImage> afterList =
                potholeImageMapper.selectPotholeImagesByReportNo(reportNo, photoGb);

        if (afterList != null && !afterList.isEmpty()) {

            Integer mainOrd = null;

            // 1) 신규 대표 우선: beforeMainNewIndex -> (newIndexToOrd) -> sortOrd
            if (!"".equals(beforeMainNewIndexStr)) {
                try {
                    int ni = Integer.parseInt(beforeMainNewIndexStr);
                    mainOrd = newIndexToOrd.get(ni);
                } catch (Exception ignore) {
                    // 숫자 변환 실패 등은 무시하고 다음 로직으로
                }
            }

            // 2) 기존 대표: beforeMainSortOrd
            if (mainOrd == null && !"".equals(beforeMainSortOrdStr)) {
                try {
                    mainOrd = Integer.parseInt(beforeMainSortOrdStr);
                } catch (Exception ignore) {}
            }

            // 3) fallback: 첫번째(정렬 기준이 필요하면 sortOrd 기준으로 정렬)
            if (mainOrd == null) {
                afterList.sort(Comparator.comparingInt(PotholeImage::getSortOrd));
                mainOrd = afterList.get(0).getSortOrd();
            }

            potholeImageMapper.updateIsMainAllN(reportNo, photoGb);
            potholeImageMapper.updateIsMainOneY(reportNo, photoGb, mainOrd);

        }
    }

    @Transactional
    public String insertWorkCompletePothole(Pothole pothole, HttpServletRequest request) {

        // 작업완료는 최초 저장부터 DONE 상태
        pothole.setStatusCd("DONE");

        // BEFORE 저장 막기 위해 사진 제거
        MultipartFile[] workPhotos = pothole.getPhotos();
        List<Integer> workPhotoIndexes = pothole.getPhotoIndexes();
        String workMainIndex = pothole.getMainIndex();

        pothole.setPhotos(null);
        pothole.setPhotoIndexes(null);
        pothole.setMainIndex(null);

        // pothole 본문만 생성
        String reportNo = insertPothole(pothole, request);

        Pothole work = new Pothole();

        work.setReportNo(reportNo);
        work.setManagerId(pothole.getManagerId());
        work.setStatusCd("DONE");
        work.setWorkStartAt(LocalDateTime.now());
        work.setWorkEndAt(LocalDateTime.now());
        work.setProcessNote(pothole.getProcessNote());

        work.setPhotos(workPhotos);
        work.setPhotoIndexes(workPhotoIndexes);
        work.setMainIndex(workMainIndex);

        updateWorkWithPhotos(work, pothole.getManagerId(), request);

        return reportNo;
    }

    /** existing list에서 sortOrd로 찾기 */
    private PotholeImage findBySortOrd(List<PotholeImage> list, Integer ord) {
        if (list == null || ord == null) return null;
        for (PotholeImage img : list) {
            if (img != null && img.getSortOrd() != null && img.getSortOrd().intValue() == ord.intValue()) {
                return img;
            }
        }
        return null;
    }

    /**
     * 작업시작
     */
    @Transactional
    public void updateWorkWithPhotos(Pothole work, String userId, HttpServletRequest request) {
        log.info("deleteSortOrds={}", work.getDeleteSortOrds());
        log.info("workMainSortOrd={}", work.getWorkMainSortOrd());
        final String reportNo = work.getReportNo();
        Pothole before = potholeMapper.selectPotholeByReportNo(reportNo);

        // 1) pothole 작업정보 업데이트
        Map<String, Object> p = new HashMap<String, Object>();
        p.put("reportNo", work.getReportNo());
        p.put("managerId", work.getManagerId());
        p.put("workStartAt", work.getWorkStartAt());
        p.put("processNote", work.getProcessNote());
        p.put("statusCd", work.getStatusCd());
        p.put("updateId", userId);
        p.put("updateIp", Utils.getClientIpAddress(request));

        // reportNo로 좌표/주소 조회
        Map<String, Object> base = potholeMapper.selectWeatherBaseByReportNo(work.getReportNo());

        Double latD = null;
        Double lngD = null;

        if (base != null) {
            Object latObj = base.get("lat");
            Object lngObj = base.get("lng");

            if (latObj != null) latD = Double.valueOf(String.valueOf(latObj));
            if (lngObj != null) lngD = Double.valueOf(String.valueOf(lngObj));
        }

        log.debug("날씨 정보 가져올 좌표값 - latD:{}, lngD:{}", latD, lngD);
        String workWeatherCd = "W999";
        if (latD != null && lngD != null) {
            workWeatherCd = weatherService.getWeatherCdByLatLngAt(latD, lngD, work.getWorkStartAt());
        }

        p.put("workWeatherCd", workWeatherCd);

        // 기온
        String tempC = "";
        if (latD != null && lngD != null) {
            tempC = weatherService.getTempByLatLngAt(latD, lngD, work.getWorkStartAt());
        }
        p.put("workTempC", tempC);

        potholeMapper.updatePotholeWork(p);

        Pothole after = potholeMapper.selectPotholeByReportNo(reportNo);
        savePotholeHistory(before, after, userId, "UPDATE", "접수내용 수정");

        final String photoGb = "AFTER";

        // 2) AFTER 사진 삭제/추가
        List<Integer> deleteSortOrds = work.getDeleteSortOrds();
        MultipartFile[] photos = work.getPhotos();

        // 신규 대표 (신규 업로드 파일 중에서 선택한 인덱스)
        String mainIndex = work.getMainIndex(); // workMainIndex가 updatePotholeAllWithPhotos에서 mainIndex로 매핑됨
        List<Integer> photoIndexes = work.getPhotoIndexes();

        // 기존 대표 (기존 AFTER 사진 sortOrd)
        String workMainSortOrdStr = Utils.safeTrim(work.getWorkMainSortOrd());

        boolean hasMainFromExisting = !"".equals(workMainSortOrdStr);
        boolean hasMainFromNew = Utils.safeTrim(mainIndex).length() > 0;

        log.info("[updateWorkWithPhotos] reportNo=" + reportNo
                + " mainIndex=" + mainIndex
                + " workMainSortOrd=" + workMainSortOrdStr
                + " photoIndexesSize=" + (photoIndexes == null ? 0 : photoIndexes.size())
                + " photosLen=" + (photos == null ? 0 : photos.length)
        );

        List<PotholeImage> existing =
                potholeImageMapper.selectPotholeImagesByReportNo(reportNo, photoGb);

        // (1) 삭제
        if (deleteSortOrds != null && !deleteSortOrds.isEmpty()) {
            for (Integer ord : deleteSortOrds) {
                PotholeImage img = Utils.findBySortOrd(existing, ord);
                if (img != null) {
                    String key = (img.getImgPath() == null ? "" : img.getImgPath())
                            + (img.getImgName() == null ? "" : img.getImgName());
                    if (!"".equals(key.trim())) storageService.delete(key);

                    potholeImageMapper.deletePotholePhotoOne(reportNo, photoGb, ord);
                }
            }
        }

        // 빈 슬롯 계산(1~5)
        List<Integer> used = potholeImageMapper.selectUsedSortOrds(reportNo, photoGb);
        List<Integer> empty = new ArrayList<Integer>();
        for (int i = 1; i <= MAX_PHOTO ; i++) {
            if (used == null || !used.contains(i)) empty.add(i);
        }

        // ✅ 대표 리셋은 "대표 변경 요청이 있을 때만"
        if (hasMainFromExisting || hasMainFromNew) {
            int n = potholeImageMapper.updateIsMainAllN(reportNo, photoGb);
            log.info("[updateWorkWithPhotos] is_main reset count=" + n + " (reportNo=" + reportNo + ", gb=AFTER)");
        }

        // ✅ (2) 기존 사진을 대표로 선택한 경우: 업로드 없어도 대표 지정 가능해야 함
        if (hasMainFromExisting) {
            try {
                Integer ord = Integer.parseInt(workMainSortOrdStr);
                potholeImageMapper.updateIsMainOneY(reportNo, photoGb, ord);
                log.info("[updateWorkWithPhotos] set main from existing sortOrd=" + ord);
            } catch (Exception e) {
                log.warn("[updateWorkWithPhotos] workMainSortOrd parse fail: " + workMainSortOrdStr);
            }
        }

        // ✅ (3) 신규 업로드
        if (photos != null && photos.length > 0 && !empty.isEmpty()) {

            int slotIdx = 0;

            for (int k = 0; k < photos.length; k++) {
                MultipartFile f = photos[k];
                if (f == null || f.isEmpty()) continue;
                if (slotIdx >= empty.size()) break;

                Integer ord = empty.get(slotIdx);

                String receiptGbCd = potholeMapper.selectReceiptGbCdByReportNo(reportNo);

                UploadResult up = storageService.uploadPotholeAfter(
                        reportNo,
                        ord,
                        receiptGbCd,
                        f
                );
                if (up == null) continue;

                Integer originIdx = (photoIndexes != null && photoIndexes.size() > k) ? photoIndexes.get(k) : null;

                String isMain = "N";
                // 신규 대표는 "hasMainFromNew"일 때만 판단
                if (hasMainFromNew && originIdx != null && mainIndex != null) {
                    isMain = mainIndex.equals(String.valueOf(originIdx)) ? "Y" : "N";
                }

                PotholeImage pi = new PotholeImage();
                pi.setReportNo(reportNo);
                pi.setPhotoGb(photoGb);
                pi.setSortOrd(ord);
                pi.setImgPath(up.getPath());
                pi.setImgName(up.getName());
                pi.setIsMain(isMain);

                potholeImageMapper.upsertPotholePhoto(pi);

                // 신규 대표로 선택된 파일이면 확정적으로 Y 보장 (혹시 upsert가 N으로 들어갈 위험 방지)
                if ("Y".equals(isMain)) {
                    potholeImageMapper.updateIsMainOneY(reportNo, photoGb, ord);
                    log.info("[updateWorkWithPhotos] set main from new upload sortOrd=" + ord + " originIdx=" + originIdx);
                }

                slotIdx++;
            }
        }

        // 상태 변경 없으면 SMS 발송 안함
        if (before != null
                && before.getStatusCd() != null
                && work.getStatusCd() != null
                && work.getStatusCd().equals(before.getStatusCd())) {

            log.debug("[SMS 발송 제외] 상태 변경 없음 reportNo={}, statusCd={}", reportNo, work.getStatusCd());
            return;
        }

        // SMS 발송
        SmsTemplateCode tpl = commonService.getTplByStatus(work.getStatusCd());
        commonService.sendSmsAfterCommit(reportNo, tpl, "ALL");

    }

    /* (사용자) 접수내용 + 작업내용 수정 */
    @Transactional
    public void updatePotholeAllWithPhotos(Pothole pothole, String userId, HttpServletRequest request) {

        // 1) 접수 + BEFORE (기존 필드 그대로 사용)
        updatePotholeWithPhotos(pothole, userId, request);

        // 2) 작업 + AFTER
        // updateWorkWithPhotos()는 photos/photoIndexes/mainIndex를 사용하니까
        // work용 필드를 임시로 "photos 세트"에 갈아끼워서 호출한다.

        org.springframework.web.multipart.MultipartFile[] savedPhotos = pothole.getPhotos();
        List<Integer> savedPhotoIndexes = pothole.getPhotoIndexes();
        String savedMainIndex = pothole.getMainIndex();

        List<Integer> savedDeleteSortOrds = pothole.getDeleteSortOrds();

        try {
            // ✅ work 전용 필드를 workWithPhotos가 읽을 수 있게 매핑
            pothole.setPhotos(pothole.getWorkPhotos());
            pothole.setPhotoIndexes(pothole.getWorkPhotoIndexes());
            pothole.setMainIndex(pothole.getWorkMainIndex());
            pothole.setDeleteSortOrds(pothole.getDeleteWorkSortOrds());

            updateWorkWithPhotos(pothole, userId, request);

        } finally {
            // ✅ 원복 (혹시 아래 로직 더 있을 때 안전)
            pothole.setPhotos(savedPhotos);
            pothole.setPhotoIndexes(savedPhotoIndexes);
            pothole.setMainIndex(savedMainIndex);
            pothole.setDeleteSortOrds(savedDeleteSortOrds);
        }
    }



    public Map<String, Object> selectTodayStatusCounts(Map<String, Object> param) {

        Map<String, Object> row = potholeMapper.selectTodayStatusCounts(param);

        // null 방어(혹시 매퍼가 null 리턴하면)
        if (row == null) row = new HashMap<>();

        // 프론트/컨트롤러에서 쓰기 편하게 기본값 세팅(선택)
        if (!row.containsKey("today_received_cnt")) row.put("today_received_cnt", 0);
        if (!row.containsKey("today_processing_cnt")) row.put("today_processing_cnt", 0);

        return row;
    }

    /* 포트홀 접수내역 조회 */
    public List<Map<String, Object>> selectRecentPotholeList(Map<String, Object> param) {
        return potholeMapper.selectRecentPotholeList(param);
    }

    public int countTodayPotholeByUserSite(Map<String, Object> param) {
        return potholeMapper.countTodayPotholeByUserSite(param);
    }

    /*  포트홀 정보 수정 시 변경된 필드를 비교하여 pothole 이력을 저장한다. */
    private void savePotholeHistory(
            Pothole before,
            Pothole after,
            String userId,
            String actionTypeDefault,
            String actionMemoDefault
    ) {
        try {
            if (before == null || after == null) {
                return;
            }

            Map<String, Object> beforeMap = new LinkedHashMap<String, Object>();
            Map<String, Object> afterMap = new LinkedHashMap<String, Object>();

            beforeMap.put("reportDate", before.getReportDate());
            beforeMap.put("receiverId", before.getReceiverId());
            beforeMap.put("directionCd", before.getDirectionCd());
            beforeMap.put("detailInfo", before.getDetailInfo());
            beforeMap.put("deliveryNote", before.getDeliveryNote());
            beforeMap.put("addr", before.getAddr());
            beforeMap.put("weatherCd", before.getWeatherCd());
            beforeMap.put("managerId", before.getManagerId());
            beforeMap.put("workStartAt", before.getWorkStartAt());
            beforeMap.put("workEndAt", before.getWorkEndAt());
            beforeMap.put("processNote", before.getProcessNote());
            beforeMap.put("statusCd", before.getStatusCd());
            beforeMap.put("siteCd", before.getSiteCd());
            beforeMap.put("adminSiteCd", before.getAdminSiteCd());
            beforeMap.put("staMeters", before.getStaMeters());
            beforeMap.put("staKmDecimal", before.getStaKmDecimal());
            beforeMap.put("staText", before.getStaText());

            afterMap.put("reportDate", after.getReportDate());
            afterMap.put("receiverId", after.getReceiverId());
            afterMap.put("directionCd", after.getDirectionCd());
            afterMap.put("detailInfo", after.getDetailInfo());
            afterMap.put("deliveryNote", after.getDeliveryNote());
            afterMap.put("addr", after.getAddr());
            afterMap.put("weatherCd", after.getWeatherCd());
            afterMap.put("managerId", after.getManagerId());
            afterMap.put("workStartAt", after.getWorkStartAt());
            afterMap.put("workEndAt", after.getWorkEndAt());
            afterMap.put("processNote", after.getProcessNote());
            afterMap.put("statusCd", after.getStatusCd());
            afterMap.put("siteCd", after.getSiteCd());
            afterMap.put("adminSiteCd", after.getAdminSiteCd());
            afterMap.put("staMeters", after.getStaMeters());
            afterMap.put("staKmDecimal", after.getStaKmDecimal());
            afterMap.put("staText", after.getStaText());

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

            if (changedFields.isEmpty()) {
                return;
            }

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
            log.error("포트홀 이력 저장 실패. reportNo=" + (after == null ? "" : after.getReportNo()), e);
        }
    }

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

    private String buildActionMemo(List<String> changedFields, String defaultMemo) {
        if (changedFields == null || changedFields.isEmpty()) {
            return defaultMemo;
        }
        return defaultMemo + " [" + String.join(", ", changedFields) + "]";
    }

    // 접수 내역 삭제
    @Transactional
    public void deletePothole(String reportNo, String userId, String updateIp) {

        if (reportNo == null || reportNo.trim().isEmpty()) {
            throw new IllegalArgumentException("접수번호 없음");
        }

        // 삭제 전 원본 조회
        Pothole before = potholeMapper.selectPotholeByReportNo(reportNo);

        // 삭제 이력 저장
        saveDeleteHistory(before, userId);

        // 사진 삭제
        potholeMapper.deletePotholePhotos(reportNo);

        // 본문 삭제여부 처리
        potholeMapper.updatePotholeDeleteYn(reportNo, userId, updateIp);
    }
    private void saveDeleteHistory(Pothole pothole, String userId) {

        try {

            if (pothole == null) {
                return;
            }

            Map<String, Object> beforeMap = new LinkedHashMap<>();

            beforeMap.put("reportNo", pothole.getReportNo());
            beforeMap.put("statusCd", pothole.getStatusCd());
            beforeMap.put("receiverId", pothole.getReceiverId());
            beforeMap.put("managerId", pothole.getManagerId());
            beforeMap.put("reportDate", pothole.getReportDate());
            beforeMap.put("directionCd", pothole.getDirectionCd());
            beforeMap.put("detailInfo", pothole.getDetailInfo());
            beforeMap.put("deliveryNote", pothole.getDeliveryNote());

            PotholeHistory history = new PotholeHistory();

            history.setReportNo(pothole.getReportNo());
            history.setActionType("DELETE");
            history.setChangedFields("DELETE");
            history.setBeforeData(objectMapper.writeValueAsString(beforeMap));
            history.setAfterData(null);
            history.setActionUserId(userId);
            history.setActionMemo("접수 삭제");

            potholeMapper.insertPotholeHistory(history);

        } catch (Exception e) {
            log.error("삭제 이력 저장 실패", e);
        }
    }

}