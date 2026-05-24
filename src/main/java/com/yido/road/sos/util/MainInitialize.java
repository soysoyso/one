package com.yido.road.sos.util;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.annotation.PropertySources;
import org.springframework.stereotype.Service;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@PropertySources({ @PropertySource("classpath:application.properties") })
public class MainInitialize {
	
	@Value("${spring.profiles.active}")
	public String serverType;

	@PostConstruct
	public void init() {
		try {
			log.info("======================= Initialize Start =======================");
			Globals.serverType = serverType;
			log.info("serverType : " + Globals.serverType);
			Globals.kakaoMapKey = Utils.getPropertiesByType("kakao.map.key", "", serverType);
			Globals.kakaoLocalKey = Utils.getPropertiesByType("kakao.local.key", "", serverType);
			Globals.kakaoLocalEndpoint = Utils.getPropertiesByType("kakao.local.endpoint", "", serverType);
			log.info("======================= Initialize End =======================");
		} catch (Exception e) {
			System.out.println(e);
		}
	}
	
}
