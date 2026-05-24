package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.LatLng;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface WeatherCacheMapper {

    int upsertSuccess(Map<String, Object> params);

    public void updateFail(
            @Param("nx") int nx,
            @Param("ny") int ny,
            @Param("errMsg") String errMsg
    );

    public String selectSummary(
            @Param("nx") int nx,
            @Param("ny") int ny
    );

    public Integer canRequestNow(int nx, int ny, int cooldownMinutes);

    public void touchLastRequest(int nx, int ny);

    public Map<String, Object> selectWeatherWithFetchedAt(
            @Param("nx") int nx,
            @Param("ny") int ny
    );
}