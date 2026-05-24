package com.yido.road.sos.controller.api;

import com.yido.road.sos.util.Globals;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Map;

/**
 * 좌표 기반 주소 조회 (카카오 Reverse Geocoding API)
 */
@RestController
@Slf4j
@RequestMapping("/api/geo")
@RequiredArgsConstructor
public class GeoController {

    private final RestTemplate rt = new RestTemplate();

    @GetMapping("/rev")
    public Map<String, Object> reverse(@RequestParam double lat, @RequestParam double lng) {

        String url = UriComponentsBuilder.fromHttpUrl(Globals.kakaoLocalEndpoint)
                .queryParam("x", lng)             // x = 경도(lng)
                .queryParam("y", lat)             // y = 위도(lat)
                .queryParam("input_coord", "WGS84")
                .toUriString();

        HttpHeaders h = new HttpHeaders();
        h.set("Authorization", "KakaoAK " + Globals.kakaoLocalKey);

        ResponseEntity<Map> res = rt.exchange(url, HttpMethod.GET, new HttpEntity<>(h), Map.class);

        String address = "";
        Map body = res.getBody();
        if (body != null) {
            java.util.List docs = (java.util.List) body.get("documents");
            if (docs != null && !docs.isEmpty()) {
                Map first = (Map) docs.get(0);
                Map road = (Map) first.get("road_address");
                Map parcel = (Map) first.get("address");
                Object a = road != null ? road.get("address_name")
                        : (parcel != null ? parcel.get("address_name") : null);
                address = a != null ? a.toString() : "";
            }
        }
        return java.util.Collections.singletonMap("address", address);
    }
}