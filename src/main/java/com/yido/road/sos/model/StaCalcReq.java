package com.yido.road.sos.model;

import lombok.Data;
import lombok.EqualsAndHashCode;


@Data
@EqualsAndHashCode(callSuper = false)
public class StaCalcReq {
    private String siteCd;
    private String directionCd;
    private Double lat;
    private Double lng;
}