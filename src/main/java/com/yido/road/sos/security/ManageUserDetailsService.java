package com.yido.road.sos.security;

import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.model.SiteInfo;
import com.yido.road.sos.repository.main.AdminUserMapper;
import com.yido.road.sos.service.SiteInfoService;
import com.yido.road.sos.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

@Service
@Slf4j
public class ManageUserDetailsService implements UserDetailsService {

    @Autowired private UserService userService;
    @Autowired private SiteInfoService siteInfoService;

    @Override
    public UserDetails loadUserByUsername(String userId) throws UsernameNotFoundException {

        AdminUser user = userService.getAdminUser(AdminUser.builder().userId(userId).build());
        log.debug("[ManageUserDetailsService] loadUserByUsername userId={}", userId);

        if (user == null) {
            throw new BadCredentialsException("사용자 찾을수 없음");
        }

        /*
        if (user.getUseYn() != null && !"Y".equals(user.getUseYn())) {
            throw new DisabledException("사용 중지된 계정입니다.");
        }*/
        log.debug("[사용자 로그인 정보] user : " + user);

        if (!"ATH300".equals(user.getUserAuth())) {
            log.debug("사용자 계정이 아님");
            throw new BadCredentialsException("사용자 계정이 아닙니다.");
        }
        log.debug("[ManageUserDetailsService] loadUserByUsername user={}", user);

        String siteCdList = user.getSiteCdList();
        if (siteCdList != null && !"".equals(siteCdList) && !siteCdList.contains(",")) {
            SiteInfo siteInfo = siteInfoService.getSiteInfoBySiteCd(siteCdList);
            user.setSiteInfo(siteInfo);
        }

        List<GrantedAuthority> authorities =
                Collections.singletonList(new SimpleGrantedAuthority(user.getUserAuth()));

        return new UserCustom(user.getUserId(), user.getUserPwd(), authorities, user.getUserAuthNm(), user);
    }
}