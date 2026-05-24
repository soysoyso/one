package com.yido.road.sos.model;

import lombok.Data;

@Data
public class NotificationRecipient {
    private Long recipientId;
    private String notificationType;
    private String notificationTypeNm;
    private String recipientNm;
    private String phoneNo;
    private String userId;
    private String siteCd;
    private String siteName;
    private String useYn;
    private Integer sortOrd;
    private String remark;
    private String regId;
    private String regDt;
    private String updId;
    private String updDt;
}
