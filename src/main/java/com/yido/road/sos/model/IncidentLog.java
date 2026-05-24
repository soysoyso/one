package com.yido.road.sos.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.format.annotation.DateTimeFormat;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper=false)
public class IncidentLog {

	private int incidentLogSeq;		   // 시퀀스
	private String reportNo;           // 접수번호 (ex: CN2509100001)
	private String reportDate;         // 접수일시
	private String intakeMethodCd;     // 접수방법
	private String statusCd;           // 상태코드
	private String siteCd;             // 현장코드 FK
	private String directionCd;        // 방향
	private BigDecimal lat;            // 위도
	private BigDecimal lng;            // 경도
	private BigDecimal accuracyM;      // 정확도 반경(미터)

	@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
	@DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
	private LocalDateTime capturedAt;  // 좌표취득시간

	private String locationText;       // 위치
	private String cellPhone;          // 접수자연락처
	private String rptImgPath;         // 접수이미지 경로
	private String rptImgName;         // 접수이미지 파일명
	private String processNote;        // 처리내용

	private String imgPath;            // 현장이미지 경로1
	private String imgName;            // 현장이미지 파일명1
	private String imgPath2;           // 현장이미지 경로2
	private String imgName2;           // 현장이미지 파일명2
	private String imgPath3;           // 현장이미지 경로3
	private String imgName3;           // 현장이미지 파일명3
	private String imgPath4;           // 현장이미지 경로4
	private String imgName4;           // 현장이미지 파일명4

	private String managerId;          // 담당자 아이디
	private String updateIp;           // 수정IP

	@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
	@DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
	private LocalDateTime updateDatetime;  // 수정일시
}