package com.yido.road.sos.model.work;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

/** 작업정보 > 작업 범위 1행 DTO */
@Data
@EqualsAndHashCode(callSuper=false)
public class ScopeRow {
	private Integer sortOrd;
	private BigDecimal widthM;
	private BigDecimal heightM;
	private BigDecimal areaM2;
	private BigDecimal depthCm;
	private BigDecimal spanM;
}