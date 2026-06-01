package com.yido.road.sos.model;

import lombok.Data;

@Data
public class NotificationTemplateSetting {
    private String notificationType;
    private String templateCode;
    private String templateTitle;
    private String defaultDeptCds;
    private String useYn;
    private String remark;
    private String regId;
    private String regDt;
    private String updId;
    private String updDt;
}
