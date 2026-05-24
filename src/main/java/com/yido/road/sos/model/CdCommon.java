package com.yido.road.sos.model;

import java.time.LocalDateTime;
import org.springframework.format.annotation.DateTimeFormat;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 테이블명 : CO_COMMON
 * 테이블 설명 : 공통코드
 * 
 * @author bae
 *
 */
@Data
@EqualsAndHashCode(callSuper = false)
public class CdCommon {

	private String cdDiv;
	private String cdDivNm;
	private String cdCode;
	private String cdCodeNm;
	private String cdValue1;
	private String cdValue2;
	private String cdValue3;
	private String cdValue4;
	private String cdRefer;
	private String cdExp;
	private int cdSort;
	private String useYn;

}


