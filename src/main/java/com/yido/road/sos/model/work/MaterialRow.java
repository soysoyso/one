package com.yido.road.sos.model.work;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.util.List;

/** 작업정보 > 투입 자재 1행 DTO */
@Data
@EqualsAndHashCode(callSuper=false)
public class MaterialRow {
	private Integer sortOrd;
	private String materialName;
	private String spec;
	private String unit;
	private BigDecimal useQty;
	private BigDecimal remainQty;
	private BigDecimal amount;
}
