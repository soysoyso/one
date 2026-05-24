package com.yido.road.sos.model.work;

import lombok.Data;
import lombok.EqualsAndHashCode;

/** 작업정보 > 투입 장비 1행 DTO */
@Data
@EqualsAndHashCode(callSuper=false)
public class EquipmentRow {

	private Integer sortOrd;
	private String equipName;
	private Integer ownQty;
	private Integer useQty;
	private String remark;
}
