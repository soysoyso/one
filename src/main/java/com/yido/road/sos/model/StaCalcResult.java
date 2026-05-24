package com.yido.road.sos.model;

import lombok.Data;

import java.math.BigDecimal;

/*
 * STA(누적거리) 계산 결과 DTO
 * - 좌표를 도로 선형에 스냅한 뒤 누적거리 및 보정 좌표 반환
 * - 포트홀 위치를 노선 기준 거리(STA)로 환산할 때 사용
 */
@Data
public class StaCalcResult {

    private String siteCd;
    private String directionCd;

    private Double snapLat;
    private Double snapLng;

    private Double distM;         // 스냅 거리(m)

    private Long staMeters;       // 최종 STA (보정 포함, meters)
    private BigDecimal staKmDecimal; // 최종 STA km (소수)
    private String staText;       // "STA 14.4"

    private String staStatus;     // OK / TOO_FAR
    private String staMessage;    // 안내 메시지
}
