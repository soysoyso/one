package com.yido.road.sos.client.weather;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

@Component
@Slf4j
public class WeatherApiClient {

    private final String serviceKey;
    private final String apiUrl;
    private final RestTemplate restTemplate;

    public WeatherApiClient(
            RestTemplate restTemplate,
            @Value("${weather.forecast.service-key}") String serviceKey,
            @Value("${weather.forecast.api-url}") String apiUrl
    ) {
        this.restTemplate = restTemplate;
        this.serviceKey = serviceKey;
        this.apiUrl = apiUrl;
    }

    public String getVilageFcstXml(String baseDate, String baseTime, int nx, int ny) {

        String url = apiUrl
                + "?serviceKey=" + serviceKey
                + "&base_date=" + baseDate
                + "&base_time=" + baseTime
                + "&nx=" + nx
                + "&ny=" + ny
                + "&dataType=XML"
                + "&numOfRows=200"
                + "&pageNo=1";

        log.debug("날씨정보 가져오기..>> url={}", url);
        return restTemplate.getForObject(java.net.URI.create(url), String.class);

    }
}