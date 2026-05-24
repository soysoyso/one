package com.yido.road.sos.model.work;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;

/** 작업정보(장비/인력/자재/범위) JSON 묶음 Payload DTO */
@Data
@EqualsAndHashCode(callSuper=false)
public class WorkInfoPayload {

	private List<EquipmentRow> equipments;
	private List<PersonnelRow> personnels;
	private List<MaterialRow> materials;
	private List<ScopeRow> scopes;
}