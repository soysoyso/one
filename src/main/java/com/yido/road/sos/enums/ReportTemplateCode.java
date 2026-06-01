package com.yido.road.sos.enums;

public enum ReportTemplateCode {
    POTHOLE_LEDGER("포트홀 관리대장"),
    POTHOLE_SUMMARY("포트홀 집계표"),
    MAINTENANCE_LOG("유지보수 일지"),
    DAILY_CHECK_LOG("일상점검 일지"),
    DAILY_CHECK_RESULT("일상점검 결과보고서"),
    LANDSCAPE_DAILY_WORK("조경 작업일보"),
    MAINTENANCE_RESULT("유지관리 결과보고서"),
    PHOTO_BOARD("사진대지"),
    SITUATION_LOG("상황일지");

    private final String displayName;

    ReportTemplateCode(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    public static ReportTemplateCode from(String value) {
        if (value == null || value.trim().isEmpty()) {
            return POTHOLE_LEDGER;
        }

        String normalized = value.trim().toUpperCase();
        for (ReportTemplateCode code : values()) {
            if (code.name().equals(normalized)) {
                return code;
            }
        }

        throw new IllegalArgumentException("지원하지 않는 보고서 템플릿입니다: " + value);
    }
}
