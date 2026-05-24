package com.yido.road.sos.scheduler;

import com.yido.road.sos.service.batch.WeatherCollector;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class WeatherCollectScheduler {

    private final WeatherCollector weatherCollector;

    public WeatherCollectScheduler(WeatherCollector weatherCollector) {
        this.weatherCollector = weatherCollector;
    }

    /**
     * 포트홀 신고 좌표 기준으로
     * 기상청 단기예보를 주기적으로 수집하여
     * weather_vilage_cache 테이블에 저장
     *
     * - 15분 주기 실행
     * - 조회 성능 향상 및 외부 API 호출 최소화 목적
     */
    @Scheduled(cron = "0 */15 * * * *")
    public void collectWeather() {
        log.debug("스케줄러 시작");
        weatherCollector.collectLatest();
    }
}