package com.yido.road.sos.model;

import lombok.Data;

@Data
public class DailyChecklistItem {
    private Long itemId;
    private Long checklistId;
    private String itemName;
    private String inputType;
    private String inputTypeNm;
    private String requiredYn;
    private String useYn;
    private Integer sortOrd;
}
