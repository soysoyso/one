package com.yido.road.sos.model;

import lombok.Data;

import java.util.List;

@Data
public class DailyChecklist {
    private Long checklistId;
    private String checklistName;
    private String siteCd;
    private String siteName;
    private String commonYn;
    private String useYn;
    private Integer sortOrd;
    private String regId;
    private String regDt;
    private String updId;
    private String updDt;
    private Integer itemCount;
    private List<DailyChecklistItem> items;
}
