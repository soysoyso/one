package com.yido.road.sos.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;

/**
 * 최근 좌표 목록 조회용 VO
 */
public class LatLng {
    public double lat;
    public double lng;
}