package com.yido.road.sos.model.work;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

/** 작업정보 > 투입 인력 1행 DTO */
@Data
@EqualsAndHashCode(callSuper=false)
public class PersonnelRow {

	private Integer sortOrd;
	private String personName;
	private String deptName;
	private BigDecimal laborCost;
}
