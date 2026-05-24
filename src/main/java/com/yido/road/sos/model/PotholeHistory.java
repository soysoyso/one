package com.yido.road.sos.model;

import lombok.Data;

@Data
public class PotholeHistory {
    private Long historyId;
    private String reportNo;
    private String actionType;
    private String changedFields;
    private String beforeData;
    private String afterData;
    private String actionUserId;
    private String actionUserIp;
    private String actionMemo;
    private String actionDatetime;
}