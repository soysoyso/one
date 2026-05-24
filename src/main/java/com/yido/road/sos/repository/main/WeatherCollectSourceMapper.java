package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.LatLng;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface WeatherCollectSourceMapper {

    List<LatLng> selectIncidentLatLng(@Param("days") int days);

    List<LatLng> selectPotholeLatLng(@Param("days") int days);
}