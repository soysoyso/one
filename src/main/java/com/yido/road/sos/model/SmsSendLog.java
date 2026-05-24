package com.yido.road.sos.model;

import lombok.Data;

/**
 * SMS 전송 로그
 */
@Data
public class SmsSendLog {
    private String adminId;           // nullable
    private String adminName;         // nullable
    private String adminIp;           // nullable
    private String siteCd;            // nullable
    private String receiveMobileNo;   // required (숫자만)
    private String sendTitle;         // nullable
    private String sendMessage;       // required
}