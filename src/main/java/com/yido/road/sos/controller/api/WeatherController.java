package com.yido.road.sos.controller.api;

import com.yido.road.sos.service.api.WeatherService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/weather")
@Slf4j
public class WeatherController {

    private final WeatherService weatherService;

    public WeatherController(WeatherService weatherService) {
        this.weatherService = weatherService;
    }

    /**
     * 위도/경도 기준 날씨 요약 조회
     *
     * - weather_vilage_cache 테이블에 저장된
     *   최신 날씨 정보를 우선 사용
     * - 캐시 데이터가 없을 경우 해당 좌표 기준으로
     *   날씨 정보를 1회 수집 후 저장
     */
    @GetMapping("/summary")
    public Map<String, Object> summary(@RequestParam("lat") double lat,
                                       @RequestParam("lng") double lng) {

        Map<String, Object> out = new HashMap<>();

        try {
            log.debug("[날씨조회] 시작 (lat={}, lng={})", lat, lng);

            Map<String, Object> weather = weatherService.getWeather(lat, lng);

            log.debug(
                    "[날씨조회] 완료 (temp={}°, pty={}, ptySummary={}, skyCode={}, weatherCd={})",
                    weather.get("temp"),
                    weather.get("pty"),
                    weather.get("ptySummary"),
                    weather.get("skyCode"),
                    weather.get("weatherCd")
            );

            // 프론트로 그대로 전달
            out.putAll(weather);

        } catch (Exception e) {
            log.error("[날씨조회] 오류", e);
            out.put("pty", null);
            out.put("ptySummary", "확인불가");
            out.put("skyCode", "default");
            out.put("weatherCd", "999");   // ✅ 확인불가 코드
        }

        return out;
    }


}
