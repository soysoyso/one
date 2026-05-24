package com.yido.road.sos.service.api;

import com.yido.road.sos.client.weather.WeatherApiClient;
import com.yido.road.sos.repository.main.WeatherCacheMapper;
import com.yido.road.sos.util.*;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
public class WeatherService {

    @Autowired private WeatherCacheMapper weatherCacheMapper;
    @Autowired private WeatherApiClient apiClient;

    public Map<String, Object> getWeather(double lat, double lng) {

        Map<String, Object> out = new HashMap<>();

        GridXY g = GridConverter.toGrid(lat, lng);

        // 1) 캐시 조회
        log.debug("[getWeather] 캐시(weather_vilage_cache) 조회 ");
        Map<String, Object> cache = weatherCacheMapper.selectWeatherWithFetchedAt(g.nx, g.ny);

        if (cache != null) {

            log.debug("[getWeather] 캐시(weather_vilage_cache) 에 있는 날씨데이터 사용 ");
            Integer pty = (cache.get("pty") instanceof Integer) ? (Integer) cache.get("pty") : null;
            Integer sky = (cache.get("sky") instanceof Integer) ? (Integer) cache.get("sky") : null;
            String weatherCd = (String) cache.get("weather_cd");
            LocalDateTime fetchedAt = (LocalDateTime) cache.get("fetched_at");

            if (fetchedAt != null && fetchedAt.isAfter(LocalDateTime.now().minusHours(2))) {

                if (weatherCd == null || weatherCd.isEmpty()) weatherCd = "W999";

                String skyCode = Utils.skyToCode(sky);
                String weatherText = Utils.toWeatherText(pty, sky);
                String weatherIcon = Utils.toWeatherIcon(pty, sky, skyCode);

                Integer tmp = (cache.get("tmp") instanceof Integer) ? (Integer) cache.get("tmp") : null;

                out.put("weatherCd", weatherCd);
                out.put("weatherText", weatherText);
                out.put("weatherIcon", weatherIcon);
                out.put("temp", tmp);
                return out;
            }
        }

        // 2) 캐시 없거나 만료 → 외부 API 호출
        int cooldownMinutes = 5;
        int ok = weatherCacheMapper.canRequestNow(g.nx, g.ny, cooldownMinutes);

        if (ok == 1) {

            weatherCacheMapper.touchLastRequest(g.nx, g.ny);

            BaseDt bt = BaseTimeUtil.recentVilageBase();

            try {
                log.debug("[getWeather] 캐시 데이터 없음, 외부 API 호출 (nx={}, ny={} / lat={}, lng={})", g.nx, g.ny, lat, lng);

                String xml = apiClient.getVilageFcstXml(bt.baseDate, bt.baseTime, g.nx, g.ny);

                Integer pty = WeatherXmlParser.pickPty(xml);
                Integer sky = WeatherXmlParser.pickSky(xml);
                Integer tmp = WeatherXmlParser.pickTmp(xml);

                String ptySummary = Utils.ptyToSummary(pty); // 캐시 저장용
                String weatherCd = Utils.toWeatherCd(pty, sky);
                String weatherText = Utils.toWeatherText(pty, sky);
                String skyCode = Utils.skyToCode(sky);
                String weatherIcon = Utils.toWeatherIcon(pty, sky, skyCode);

                Map<String, Object> params = new HashMap<>();

                params.put("nx", g.nx);
                params.put("ny", g.ny);
                params.put("baseDate", bt.baseDate);
                params.put("baseTime", bt.baseTime);
                params.put("pty", pty);
                params.put("sky", sky);
                params.put("tmp", tmp);
                params.put("weatherCd", weatherCd);

                weatherCacheMapper.upsertSuccess(params);

                out.put("weatherCd", weatherCd);
                out.put("weatherText", weatherText);
                out.put("weatherIcon", weatherIcon);
                out.put("temp", tmp);

                return out;

            } catch (Exception e) {
                String msg = (e.getMessage() == null) ? "error" : e.getMessage();
                if (msg.length() > 180) msg = msg.substring(0, 180);
                weatherCacheMapper.updateFail(g.nx, g.ny, msg);
            }
        }

        // 3) 최종 fallback
        out.put("weatherCd", "W999");
        out.put("weatherText", "확인불가");
        out.put("weatherIcon", "-");

        return out;
    }

    /**
     * 위경도 + 기준시간 → 날씨코드 반환
     */
    public String getWeatherCdByLatLngAt(double lat, double lng, LocalDateTime baseDateTime) {

        try {

            if (baseDateTime == null) return "W999";

            GridXY g = GridConverter.toGrid(lat, lng);
            BaseDt bt = BaseTimeUtil.vilageBaseAt(baseDateTime);
            String xml = apiClient.getVilageFcstXml(bt.baseDate,bt.baseTime, g.nx, g.ny);

            Integer pty = WeatherXmlParser.pickPty(xml);
            Integer sky = WeatherXmlParser.pickSky(xml);

            String weatherCd = Utils.toWeatherCd(pty, sky);

            if (weatherCd == null || weatherCd.isEmpty()) {
                weatherCd = "W999";
            }

            return weatherCd;

        } catch (Exception e) {
            log.warn("[WeatherService] 날씨 조회 실패", e);
            return "W999";
        }
    }

    public String getTempByLatLngAt(double lat, double lng, LocalDateTime baseDateTime) {

        try {
            log.debug("==== getTempByLatLngAt ====");
            if (baseDateTime == null) return "";

            GridXY g = GridConverter.toGrid(lat, lng);
            BaseDt bt = BaseTimeUtil.vilageBaseAt(baseDateTime);
            String xml = apiClient.getVilageFcstXml(bt.baseDate, bt.baseTime, g.nx, g.ny);

            log.debug("==== xml ==== " + xml);
            Integer tmp = WeatherXmlParser.pickTmp(xml);
            log.debug("==== tmp ==== " + tmp);

            return tmp != null ? String.valueOf(tmp) : "";

        } catch (Exception e) {
            log.warn("[WeatherService] 기온 조회 실패", e);
            return "";
        }
    }

}
