package com.yido.road.sos.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 사고접수 히스토리를 조회하기 위한 DTO
 */
@Data
@EqualsAndHashCode(callSuper = false)
public class TimelineItem {

    private String eventDt;     // "yyyy-MM-dd HH:mm:ss" or 원하는 포맷
    private String statusNm;    // 상태이름
    private String userNm;        // 관리자이름
}