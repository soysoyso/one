package com.yido.road.sos.security;

import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.model.SiteInfo;
import com.yido.road.sos.service.SiteInfoService;
import com.yido.road.sos.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service("commonUserDetailsService")
@Slf4j
public class CommonUserDetailsService implements UserDetailsService {

    private final UserService userService;
    private final SiteInfoService siteInfoService;

    public CommonUserDetailsService(UserService userService, SiteInfoService siteInfoService) {
        this.userService = userService;
        this.siteInfoService = siteInfoService;
    }

    @Override
    public UserDetails loadUserByUsername(String userId) throws UsernameNotFoundException {

        AdminUser user = userService.getAdminUser(AdminUser.builder().userId(userId).build());
        log.debug("[CommonUserDetailsService] loadUserByUsername userId={}", userId);

        if (user == null) {
            throw new BadCredentialsException("사용자 찾을수 없음");
        }

        // ✅ 멀티 권한: "ATH200,ATH300" 같은 문자열을 List로 만들기 (임시/빠른 방식)
        String authRaw = user.getUserAuth(); // 지금은 단일일 수 있음. 이후 멀티로 확장
        List<GrantedAuthority> authorities = new ArrayList<>();

        if (authRaw != null && !"".equals(authRaw.trim())) {
            String[] parts = authRaw.split(",");
            for (int i = 0; i < parts.length; i++) {
                String code = parts[i] != null ? parts[i].trim() : "";
                if (!"".equals(code)) {
                    authorities.add(new SimpleGrantedAuthority(code));
                }
            }
        }

        // ✅ 오케이로드(ATH300)가 있으면 siteInfo 세팅(기존 ManageUserDetailsService 로직 유지)
        boolean hasManage = false;
        for (int i = 0; i < authorities.size(); i++) {
            if ("ATH300".equals(authorities.get(i).getAuthority())) {
                hasManage = true;
                break;
            }
        }

        if (hasManage) {
            String siteCdList = user.getSiteCdList();
            if (siteCdList != null && !"".equals(siteCdList) && !siteCdList.contains(",")) {
                SiteInfo siteInfo = siteInfoService.getSiteInfoBySiteCd(siteCdList);
                user.setSiteInfo(siteInfo);
            }
        }

        return new UserCustom(user.getUserId(), user.getUserPwd(), authorities, user.getUserAuthNm(), user);
    }
}
