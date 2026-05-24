package com.yido.road.sos.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.format.annotation.DateTimeFormat;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Data
@EqualsAndHashCode(callSuper = false)
public class Incident {

    private String siteName;
    private String statusNm;
    private String locationText;

    private String reportNo;               // 접수번호 (CN2509100001)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime reportDate;      // 접수일시 (권장: LocalDateTime)
    private String intakeMethodCd;         // 접수방법 (MTD001 전화 / MTD002 온라인)
    private String intakeMethodNm;
    private String statusCd;               // 상태코드 (STS001~STS004)
    private String siteCd;                 // 현장코드 (ex: 0002)
    private String siteCdList;             // 현장코드 <- 알수없음 선택시 (ex: 0002,0003,0004)

    private BigDecimal lat;                // 위도
    private BigDecimal lng;                // 경도
    private Integer accuracyM;             // 정확도(m) = DB accuracy_m (NULL 가능)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime capturedAt;      // 좌표취득시간 (선택, 클라가 보낸 readable 값)
    private Long capturedTs;               // 좌표취득시각 epoch ms (DB captured_ts)
    private Integer coordAgeMs;            // 좌표 신선도(ms; DB 생성칼럼이면 읽기전용)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss.SSS", timezone = "Asia/Seoul")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss.SSS")
    private LocalDateTime serverReceivedAt;// 서버 수신시각(DB server_received_at)

    private String addr;                   // 역지오코딩 주소
    private String cellPhone;              // 접수자 연락처

    private String rptImgPath;             // 접수이미지 경로
    private String rptImgName;             // 접수이미지 파일명
    private String processNote;            // 처리내용

    private String imgPath;                // 현장이미지1 경로
    private String imgName;                // 현장이미지1 파일명
    private String imgPath2;
    private String imgName2;
    private String imgPath3;
    private String imgName3;
    private String imgPath4;
    private String imgName4;

    private String managerId;              // 담당자ID (FK admin_user.USER_ID)
    private String managerNm;
    private String updateIp;               // 수정IP

    private String ocrReadKm;              // OCR에서 read된 값 빈 값일 수 있음.
    private String latLng;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateDatetime;  // 수정일시

    // 접수시간
    public String getReportDateFmt() {
        return reportDate == null ? "" :
                reportDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    // 완료시간
    public String getUpdateDateFmt() {
        return updateDatetime == null ? "" :
                updateDatetime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    public String getCellPhone() {
        if (this.cellPhone == null || "".equals(this.cellPhone)) {
            return null;
        }

        // 숫자만 추출
        String digits = this.cellPhone.replaceAll("[^0-9]", "");

        // 정규식으로 3-4-4 패턴 맞추기
        if (digits.matches("(\\d{3})(\\d{3,4})(\\d{4})")) {
            return digits.replaceAll("(\\d{3})(\\d{3,4})(\\d{4})", "$1-$2-$3");
        }

        // 규칙에 맞지 않으면 원본 리턴
        return this.cellPhone;
    }
}
