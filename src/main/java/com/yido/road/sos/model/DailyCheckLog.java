package com.yido.road.sos.model;

import lombok.Data;

import java.util.List;

@Data
public class DailyCheckLog {
    private Long checkId;
    private String checkNo;
    private String checkDate;
    private Long checklistId;
    private String checklistName;
    private String siteCd;
    private String siteName;
    private String writerId;
    private String writerNm;
    private String statusCd;
    private String statusNm;
    private String weatherCd;
    private String remark;
    private String regDt;
    private String updDt;
    private List<DailyCheckLogItem> items;
}
