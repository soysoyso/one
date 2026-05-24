package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.CdCommon;
import com.yido.road.sos.model.SmsSendLog;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;


@Mapper
public interface SmsLogMapper {

	/* SMS 전송 로그 */
	int insertLog(SmsSendLog log);

}



