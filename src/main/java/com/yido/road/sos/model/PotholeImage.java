package com.yido.road.sos.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.format.annotation.DateTimeFormat;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 포트홀 접수 이미지
 */
@Data
@EqualsAndHashCode(callSuper = false)
public class PotholeImage {

    private Integer photoId;
    private String reportNo;

    private String photoGb; // 작업 전 = BEFORE / 작업 후 = AFTER
    private Integer sortOrd;   // 1~5

    private String imgPath;
    private String imgName;
    
    private String isMain; // 대표사진여부
}
