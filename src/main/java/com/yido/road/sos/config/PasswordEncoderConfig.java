package com.yido.road.sos.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.DelegatingPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class PasswordEncoderConfig {
	@Bean
	public PasswordEncoder passwordEncoder() {
		PasswordEncoder passwordEncoder = PasswordEncoderFactories.createDelegatingPasswordEncoder();
		if (passwordEncoder instanceof DelegatingPasswordEncoder) {
			((DelegatingPasswordEncoder) passwordEncoder).setDefaultPasswordEncoderForMatches(new BCryptPasswordEncoder());
		}
		return passwordEncoder;
	}
}
