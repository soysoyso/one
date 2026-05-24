package com.yido.road.sos.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper=false)
public class UserInfo{

	private String userId;
	private String userNm;
	private String userPwd;
	private String userMail;
	private String deptCd;
	private String deptNm;
	private Boolean useYn;
	private String userAuth;
}