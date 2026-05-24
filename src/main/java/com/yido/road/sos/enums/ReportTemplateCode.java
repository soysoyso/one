package com.yido.road.sos.enums;

public enum ReportTemplateCode {
    POTHOLE_LEDGER("도로파손 관리대장");

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

