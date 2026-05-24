package com.yido.road.sos.model;

import lombok.Data;

@Data
public class DailyCheckLogItem {
    private Long logItemId;
    private Long checkId;
    private Long itemId;
    private String itemName;
    private String inputType;
    private String requiredYn;
    private String checkValue;
    private String sortOrd;
}
