package com.yido.road.sos.service;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.yido.road.sos.component.storage.StorageService;
import com.yido.road.sos.component.storage.UploadResult;
import com.yido.road.sos.model.*;
import com.yido.road.sos.repository.main.PotholeDraftMapper;
import com.yido.road.sos.repository.main.PotholeImageMapper;
import com.yido.road.sos.repository.main.PotholeMapper;
import com.yido.road.sos.service.api.StaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PotholeDraftService {

    private final ObjectMapper objectMapper;
    private final PotholeDraftMapper potholeDraftMapper;
    private final PotholeMapper potholeMapper;
    private final PotholeImageMapper potholeImageMapper;
    private final StorageService storageService;
    private final StaService staService;

    @Transactional
    public Long insertDraft(PotholeDraftDto dto) {
        // 방향 기본값
        if (dto.getDirectionCd() == null || dto.getDirectionCd().isEmpty()) {
            dto.setDirectionCd("UP");
        }

        // reportDate 처리
        // 화면에서 넘어온 값: YYYY-MM-DD
        if (dto.getReportDate() != null && !dto.getReportDate().isEmpty()) {

            LocalDate selectedDate = LocalDate.parse(dto.getReportDate());
            LocalDate today = LocalDate.now();

            if (selectedDate.isEqual(today)) {
                // 오늘이면 NOW()
                dto.setReportDateTime(LocalDateTime.now());
            } else {
                // 오늘이 아니면 00:00:00
                dto.setReportDateTime(selectedDate.atStartOfDay());
            }

        } else {
            // 값 없으면 그냥 NOW()
            dto.setReportDateTime(LocalDateTime.now());
        }

        //  capturedAt 처리
        if (dto.getCapturedTs() != null) {
            LocalDateTime capturedAt = LocalDateTime.ofInstant(
                    Instant.ofEpochMilli(dto.getCapturedTs()),
                    ZoneId.systemDefault()
            );
            dto.setCapturedAt(capturedAt);
        }


        // STA 계산
        if (dto.getLat() != null && dto.getLng() != null
                && dto.getSiteCd() != null && !dto.getSiteCd().isEmpty()
                && dto.getDirectionCd() != null && !dto.getDirectionCd().isEmpty()) {

            try {
                StaCalcResult sta = staService.calcSta(
                        dto.getSiteCd(),
                        dto.getDirectionCd(),
                        dto.getLat().doubleValue(),
                        dto.getLng().doubleValue()
                );

                if (sta != null && sta.getStaMeters() != null) {
                    dto.setStaMeters(sta.getStaMeters());           // BIGINT
                    dto.setStaKmDecimal(sta.getStaKmDecimal());     // DECIMAL(10,1)
                    dto.setStaText(sta.getStaText());               // "STA 10.9"
                } else {
                    // 계산 실패 시 기존값 날리지 않으려면 주석 유지 (선택)
                    // dto.setStaMeters(null);
                    // dto.setStaKmDecimal(null);
                    // dto.setStaText(null);
                }

            } catch (Exception ex) {
                log.warn("[포트홀 draft 저장] STA 계산 실패 lat={}, lng={}", dto.getLat(), dto.getLng(), ex);
            }
        }

        // insert
        int r = potholeDraftMapper.insertDraft(dto);

        if (r != 1 || dto.getDraftId() == null) {
            throw new RuntimeException("draft insert failed");
        }

        log.debug("[포트홀 draft 저장] draftId={}, lat={}, lng={}, addr={}",
                dto.getDraftId(), dto.getLat(), dto.getLng(), dto.getAddr());

        return dto.getDraftId();
    }

    /**
     * 포트홀 임시저장(draft)을 최종 접수 처리한다.
     * - draft → pothole 본테이블 생성
     * - 사진 업로드 및 pothole_photo 저장
     * - 처리 완료 후 draft 삭제

    @Transactional
    public String completeDraft(Long draftId,
                                MultipartFile[] photos,
                                String writerId,
                                HttpServletRequest request,
                                String mainIndex,
                                List<Integer> photoIndexes) {

        // 1) draft 조회
        PotholeDraftDto draft = potholeDraftMapper.selectDraftById(draftId);
        if (draft == null) {
            throw new RuntimeException("draft not found. draftId=" + draftId);
        }

        // 2) reportNo 생성 (I+YYMMDD+NNN)
        String reportNo = potholeMapper.selectNextReportNo();

        // ✅ docNo 생성 (YYYY-U-001)
        String docNo = potholeMapper.selectNextDocNo("U");

        // 3) pothole insert
        Pothole pothole = new Pothole();
        pothole.setReportNo(reportNo);
        pothole.setDocNo(docNo);
        pothole.setReportDate(draft.getReportDateTime());
        pothole.setStatusCd("RECEIVED");
        pothole.setSiteCd(draft.getSiteCd());
        pothole.setAdminSiteCd(draft.getAdminSiteCd());
        pothole.setLat(draft.getLat());
        pothole.setLng(draft.getLng());
        pothole.setAccuracyM(draft.getAccuracyM());
        pothole.setCapturedAt(draft.getCapturedAt());
        pothole.setCapturedTs(draft.getCapturedTs());
        pothole.setAddr(draft.getAddr());
        pothole.setDetailInfo(draft.getDetailInfo());  // 터널, 기점표지판 등
        pothole.setDeliveryNote(draft.getDeliveryNote());  // 접수내용
        pothole.setWeatherCd(draft.getWeatherCd());  // 날씨정보
        pothole.setTemp(draft.getTemp()); // 기온
        pothole.setStaMeters(draft.getStaMeters());
        pothole.setStaKmDecimal(draft.getStaKmDecimal());
        pothole.setStaText(draft.getStaText());
        pothole.setReceiptGbCd(draft.getReceiptGbCd()); // 접수유형

        pothole.setReceiverId(writerId);        // 접수자
        pothole.setDirectionCd(draft.getDirectionCd()); // 방향
        pothole.setReceiptGbCd(draft.getReceiptGbCd()); // 접수유형

        log.debug("pothole >> " + pothole);
        potholeMapper.insertPothole(pothole);
        saveCreateHistory(pothole, writerId);

        List<PotholeImage> imageList = new ArrayList<PotholeImage>();

        // 4) 사진 업로드 + pothole_photo insert
        if (photos != null && photos.length > 0) {

            int order = 1;

            for (int i = 0; i < photos.length; i++) {

                MultipartFile f = photos[i];
                if (f == null || f.isEmpty()) continue;
                if (order > 5) break;

                String seq = String.format("%02d", order);
                String fileName = "POTHOLE_" + reportNo + "_BEFORE_" + seq;
                UploadResult up = storageService.upload(f, "pothole/before", fileName);

                // ✅ 프론트에서 보낸 원본 인덱스(대표 매칭용)
                Integer originIdx = (photoIndexes != null && photoIndexes.size() > i) ? photoIndexes.get(i) : null;

                // ✅ 대표 판단
                String isMain = "N";
                if (mainIndex != null && !"".equals(mainIndex.trim()) && originIdx != null) {
                    if (mainIndex.equals(String.valueOf(originIdx))) {
                        isMain = "Y";
                    }
                }

                // ✅ 대표가 아무것도 안 넘어오면 첫 사진을 대표로(안전장치)
                if ((mainIndex == null || "".equals(mainIndex.trim())) && order == 1) {
                    isMain = "Y";
                }

                PotholeImage img = new PotholeImage();
                img.setReportNo(reportNo);
                img.setPhotoGb("BEFORE");
                img.setImgPath(up.getPath());
                img.setImgName(up.getName());
                img.setSortOrd(order++);
                img.setIsMain(isMain); // ✅ 추가

                potholeImageMapper.insertPotholeImage(img);
            }
        }


        // 5) draft 처리 (삭제 or 완료처리)
        potholeDraftMapper.deleteDraft(draftId);

        return reportNo;
    }  */

}