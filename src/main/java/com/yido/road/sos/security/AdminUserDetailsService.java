package com.yido.road.sos.security;

import java.util.Collections;
import java.util.List;

import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.yido.road.sos.model.UserInfo;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class AdminUserDetailsService implements UserDetailsService {

	@Autowired
	private UserService userService;

    @Override
    public UserDetails loadUserByUsername(String userId) throws UsernameNotFoundException {

        AdminUser user = userService.getAdminUser(AdminUser.builder().userId(userId).build());
        log.debug("[AdminUserDetailsService] loadUserByUsername userId={}", userId);

        if(user == null) {
            throw new BadCredentialsException("사용자 찾을수 없음");
        }

        log.debug("[관리자 로그인 정보] user : " + user);

        String auth = user.getUserAuth();
        if (!"ATH100".equals(auth) && !"ATH200".equals(auth)) {
            log.debug("관리자 계정이 아님");
            throw new AccessDeniedException("관리자 계정이 아닙니다.");
        }

        List<GrantedAuthority> authorities = Collections.singletonList(new SimpleGrantedAuthority(user.getUserAuth()));

        //return new User(user.getUserId(), user.getUserPw(), authorities);
        return new UserCustom(user.getUserId(), user.getUserPwd(), authorities, user.getUserAuthNm(), user);


    }

}
