package com.yido.road.sos.model;

import lombok.Data;

@Data
public class SituationLog {
    private Long situationId;
    private String logDate;
    private String shiftCd;
    private String shiftNm;
    private String eventTime;
    private String title;
    private String content;
    private String siteCd;
    private String siteName;
    private String useYn;
    private String regId;
    private String regNm;
    private String regDt;
    private String updId;
    private String updDt;
}
