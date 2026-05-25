package com.yido.road.sos.model;

import lombok.Data;

@Data
public class DailyCheckPhoto {
    private Long photoId;
    private Long checkId;
    private String photoGb;
    private String imgPath;
    private String imgName;
    private Integer sortOrd;
    private String regDt;
}
