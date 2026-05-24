package com.yido.road.sos.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class BaseDt {
    public final String baseDate; // yyyyMMdd
    public final String baseTime; // HHmm

    public BaseDt(String baseDate, String baseTime) {
        this.baseDate = baseDate;
        this.baseTime = baseTime;
    }
}
