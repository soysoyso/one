package com.yido.road.sos.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;

/**
 * 테이블명 : ADMIN_USER
 * 테이블 설명 : 어드민 유저 테이블
 */

@Data
@Builder(toBuilder = true)   
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class AdminUser {

	private String userId;	
	private String userNm;
    private String userMail;
    private String userTel;
    private String userPwd;
	private String userAuth;	
	private String userAuthNm;
    private SiteInfo siteInfo;      // 괸리대상 고속도로
    private String siteCdList;      // 괸리대상 고속도로
    private String siteCdListNm;    // 괸리대상 고속도로
    private String deptCd;          // 소속코드
	private String deptNm;          // 소속코드 이름
    private String bizDivCd;        // 화면구분 (접수 / 처리)
	private String inputStaff;


	@JsonFormat(pattern="yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
	@DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
	private LocalDateTime inputDatetime;	
	private String inputIp;	
	
	private String updateStaff;
	
	@JsonFormat(pattern="yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
	@DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
	private LocalDateTime updateDatetime;	
	private String updateIp;

    private String logDiv;		// 로그종류(I:등록, U:수정, D: 삭제)
	
}


