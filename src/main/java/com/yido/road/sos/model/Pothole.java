package com.yido.road.sos.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.format.annotation.DateTimeFormat;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Data
@EqualsAndHashCode(callSuper = false)
public class Pothole {

    private String siteName;
    private String statusNm;
    private String locationText;

    private String reportNo;               // 접수번호 (I + YYMMDD + NNN)
    private String docNo;               // 문서번호 YYYY-시퀀스3자리
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime reportDate;      // 접수일시

    private String statusCd;               // 작업상태 코드(공통코드 005)
    private String siteCd;                 // 현장코드
    private String adminSiteCd;            // 관할대표 현장코드 (부모코드)

    private BigDecimal lat;                // 위도
    private BigDecimal lng;                // 경도
    private Integer accuracyM;             // 정확도(m)

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime capturedAt;      // 좌표취득시간(클라가 보낸 readable 값)

    private Long capturedTs;               // 클라측 측정시각 epoch ms
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss.SSS", timezone = "Asia/Seoul")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss.SSS")
    private LocalDateTime serverReceivedAt;// 서버 수신시각

    private String addr;                   // 주소
    private String cellPhone;              // 접수자 연락처
    private String detailInfo;             // 상세정보(교량/터널 등)
    private String deliveryNote;           // 전달사항

    private String receiverId;             // 접수자 계정ID
    private String userNm;                 // 접수자 이름
    private String managerNm;              // 작업자 이름
    private String receiptGbCd;            // 접수구분(공통코드 006) = 작업유형
    private String receiptGbNm;

    private String regIp;                  // 등록자 IP

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime regDatetime;     // 등록일시

    private String processNote;            // 작업내용
    private String managerId;              // 담당자 계정ID

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateDatetime;  // 수정일시

    private String updateIp;               // 수정IP

    private Integer coordAgeMs;            // 좌표 신선도(ms; DB 생성 칼럼)

    private String directionCd;            // 진행방향(UP/DOWN)
    private String directionNm;            // 진행방향명(조인/표시용)

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime workStartAt;  // 작업시작일시

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime workEndAt;  // 작업완료일시

    private String workEndDateTimeFmt;  // 작업완료일시

    private String weatherCd;       // 날씨정보 (공통코드 007)
    private String workWeatherCd;  // 날씨정보 (공통코드 007)
    private Integer temp;
    private Integer workTemp; // 작업 시점 기온

    private Long staMeters;
    private BigDecimal staKmDecimal;
    private String staKmDecimalText;  // 표시용
    private String staText;
    private String latLng;

    private String pavementTypeCds; // 포장형식 코드들 "A,B,C"
    private String occurPlaceCds;   // 발생장소 코드들 "X,Y"
    private String alarmSendYn; // 알림톡 발송 여부

    // 보고서 추가정보
    private String laneInfo;              // 차선/위치 보조 정보
    private String reportRemark;          // 보고서 비고
    private BigDecimal workQty;           // 실작업량
    private BigDecimal convertWorkQty;    // 환산작업량계
    private BigDecimal accountWorkQty;    // 작업량계상


    // 접수시간 포맷
    public String getReportDateFmt() {
        return reportDate == null ? "" :
                reportDate.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
    }
    public String getReportDateFmt2() {
        return reportDate == null ? "" :
                reportDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }
    // 접수일시 (yyyy-MM-dd HH:mm)
    public String getReportDateTimeFmt() {
        return reportDate == null ? "" :
                reportDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }
    // 작업시작일시 (yyyy-MM-dd HH:mm)
    public String getWorkStartDateTimeFmt() {
        return workStartAt == null ? "" :
                workStartAt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }
    // 수정시간 포맷
    public String getUpdateDateFmt() {
        return updateDatetime == null ? "" :
                updateDatetime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    // 연락처 포맷 (3-3/4-4)
    public String getCellPhone() {
        if (this.cellPhone == null || "".equals(this.cellPhone)) {
            return null;
        }

        // 숫자만 추출
        String digits = this.cellPhone.replaceAll("[^0-9]", "");

        // 3-3/4-4 패턴 맞추기
        if (digits.matches("(\\d{3})(\\d{3,4})(\\d{4})")) {
            return digits.replaceAll("(\\d{3})(\\d{3,4})(\\d{4})", "$1-$2-$3");
        }

        // 규칙에 맞지 않으면 원본 리턴
        return this.cellPhone;
    }

    private String imsMode; // 삭제 or 수정
    private List<PotholeImage> imageList;

    // 수정 화면용(업데이트 요청에서만 사용)
    private List<Integer> deleteSortOrds;
    private List<Integer> deleteWorkSortOrds; // 작업(After) 사진 삭제용
    private org.springframework.web.multipart.MultipartFile[] photos;

    private String beforeMainSortOrd;
    private String beforeMainNewIndex;

    private String mainIndex;
    private List<Integer> photoIndexes;

    // 작업(After) 수정 화면용
    private org.springframework.web.multipart.MultipartFile[] workPhotos;
    private List<Integer> workPhotoIndexes;
    private String workMainIndex;
    private String workMainSortOrd;

}
