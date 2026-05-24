package com.yido.road.sos.enums;

public enum SmsTemplateCode {

    WORK_START("10037", "접수"),
    WORK_PROGRESS("10038", "시작"),
    WORK_COMPLETE("10039", "완료"),
    WORK_HOLD("10045", "보류");

    private final String code;
    private final String desc;

    SmsTemplateCode(String code, String desc) {
        this.code = code;
        this.desc = desc;
    }

    public String getCode() {
        return code;
    }

    public String getDesc() {
        return desc;
    }
}