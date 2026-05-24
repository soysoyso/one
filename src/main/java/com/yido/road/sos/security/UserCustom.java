package com.yido.road.sos.security;

import java.util.Collection;

import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.model.SiteInfo;
import org.springframework.security.core.SpringSecurityCoreVersion;
import org.springframework.security.core.userdetails.User;

import com.yido.road.sos.model.UserInfo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter @Setter @ToString
public class UserCustom extends User {
    private static final long serialVersionUID = SpringSecurityCoreVersion.SERIAL_VERSION_UID;

    // 유저의 정보를 더 추가하고 싶다면 이곳과, 아래의 생성자 파라미터를 조절해야 한다.
    private String userId;
    private String userName;
    private String userAuth;
    private String userAuthNm;
    private String deptCd;          // 소속코드
    private String deptNm;          // 소속코드 이름
    private String bizDivCd;        // 화면구분 (접수 / 처리)
    private String siteCdList;      // 괸리대상 고속도로
    private SiteInfo siteInfo;      // 괸리대상 고속도로
    private String userTel;
    private String userMail;

    public UserCustom(String username, String password, Collection authorities
            , String authorityname, AdminUser adminUser) {

        super(username, password, authorities);

        this.userId = adminUser.getUserId();
        this.userName = adminUser.getUserNm();
        this.userAuth = adminUser.getUserAuth();
        this.userAuthNm = adminUser.getUserAuthNm();
        this.siteCdList = adminUser.getSiteCdList();
        this.siteInfo = adminUser.getSiteInfo();
        this.deptCd = adminUser.getDeptCd();
        this.deptNm = adminUser.getDeptNm();
        this.bizDivCd = adminUser.getBizDivCd();
        this.userTel = adminUser.getUserTel();
        this.userMail = adminUser.getUserMail();
    }



}
