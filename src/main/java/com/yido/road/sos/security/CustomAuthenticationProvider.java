package com.yido.road.sos.security;

import java.util.Collection;

import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class CustomAuthenticationProvider implements AuthenticationProvider {

	private AdminUserDetailsService userDetailService;

	private PasswordEncoder passwordEncoder;

	public CustomAuthenticationProvider(AdminUserDetailsService adminUserDetailsService, PasswordEncoder passwordEncoder) {
		this.userDetailService = adminUserDetailsService;
		this.passwordEncoder = passwordEncoder;
	}

	@Override
	public Authentication authenticate(Authentication authentication) throws AuthenticationException {

		String username = authentication.getName();
		String password = authentication.getCredentials().toString();

		UserDetails userDetails;
		try {
			userDetails = userDetailService.loadUserByUsername(username);

		} catch(Exception e) {
			throw new BadCredentialsException("ID 또는 비밀번호가 일치하지 않습니다.");
		}

		Collection<? extends GrantedAuthority> authorities = userDetails.getAuthorities();

		if (passwordEncoder.matches(password, userDetails.getPassword()) ) {
        	return new UsernamePasswordAuthenticationToken(userDetails, null, authorities);
        } else {
        	throw new BadCredentialsException("ID 또는 비밀번호가 일치하지 않습니다.");
        }
	}

	@Override
	public boolean supports(Class<?> authentication) {
		return authentication.equals(UsernamePasswordAuthenticationToken.class);
	}

}
