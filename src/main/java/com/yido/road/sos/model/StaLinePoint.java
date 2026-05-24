package com.yido.road.sos.model;


import lombok.Data;


/**
 * STA 계산을 위한 도로 선형(polyline) 구성 포인트 모델
 * - 노선/방향별로 정렬된 위경도 좌표를 관리
 * - 포트홀 좌표를 선형에 스냅하여 누적거리 계산 시 사용
 */
@Data
public class StaLinePoint {
    private String siteCd;
    private String directionCd;   // UP / DOWN
    private String lineId;        // 라인 그룹 키 (없으면 null 가능)
    private Integer seq;          // 정렬용
    private Double staKm;         // 또는 staM (너 테이블 맞춰)
    private Double lat;
    private Double lng;
}