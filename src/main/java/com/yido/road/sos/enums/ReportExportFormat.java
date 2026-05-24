package com.yido.road.sos.enums;

public enum ReportExportFormat {
    PDF("pdf", "application/pdf"),
    DOCX("docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"),
    HWPX("hwpx", "application/hwp+zip");

    private final String extension;
    private final String contentType;

    ReportExportFormat(String extension, String contentType) {
        this.extension = extension;
        this.contentType = contentType;
    }

    public String getExtension() {
        return extension;
    }

    public String getContentType() {
        return contentType;
    }

    public static ReportExportFormat from(String value) {
        if (value == null || value.trim().isEmpty()) {
            return PDF;
        }

        String normalized = value.trim().toUpperCase();
        for (ReportExportFormat format : values()) {
            if (format.name().equals(normalized) || format.extension.equalsIgnoreCase(value)) {
                return format;
            }
        }

        throw new IllegalArgumentException("지원하지 않는 보고서 출력 형식입니다: " + value);
    }
}

