package com.yido.road.sos.repository.yido;

import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

@Mapper
public interface SmsSendMapper {
	
	/* SMS 전송 */
	public void sendSms(Map<String, Object> params) throws Exception;

}
