package com.yido.road.sos.model;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/*
 * 포트홀 접수 임시저장(DRAFT)용 DTO
 * - 접수 작성 중 페이지 이탈/중단 시 데이터 보존 목적
 * - 최종 접수 전 상태를 저장하며, 이후 정식 접수 데이터로 전환됨
 */
@Data
public class PotholeDraftDto {

    private Long draftId;

    private String statusCd;      // DRAFT
    private String receiptGbCd; // 접수유형
    private String reportDate;    // "2025-01-13"
    private LocalDateTime reportDateTime;

    private String siteCd;                 // 현장코드
    private String adminSiteCd;            // 관할대표 현장코드 (부모코드)
    private String directionCd;   // UP / DOWN
    private BigDecimal lat;
    private BigDecimal lng;
    private Integer accuracyM;
    private LocalDateTime capturedAt;
    private Long capturedTs;

    private String addr;
    private String detailInfo;         // 터널, 기점표지판 등
    private String deliveryNote;      // 접수내용

    private String writerId;      // 작성자
    private String weatherCd;  // 날씨정보 (공통코드 007)
    private Integer temp;       // 기온

    private Long staMeters;
    private BigDecimal staKmDecimal;
    private String staText;

}
