package com.yido.road.sos.service.api;

import com.yido.road.sos.model.GeocodeResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Collections;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class GeocodeService {

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${kakao.local.key}")
    private String kakaoRestKey;

    @Value("${kakao.local.search.address.url}")
    private String addressUrl;

    @Value("${kakao.local.search.keyword.url}")
    private String keywordUrl;

    public GeocodeResponse geocode(String addr) {
        // 1) 도로명/지번 주소검색
        GeocodeResponse r1 = searchAddress(addr);
        if (r1.getLat() != null && r1.getLng() != null) return r1;

        // 2) 주소검색이 실패하면 키워드검색(“OOIC”, “OO휴게소” 같은 케이스)
        GeocodeResponse r2 = searchKeyword(addr);
        if (r2.getLat() != null && r2.getLng() != null) return r2;

        return GeocodeResponse.fail("not found");
    }

    private GeocodeResponse searchAddress(String query) {
        try {
            String url = UriComponentsBuilder
                    .fromHttpUrl(addressUrl)
                    .queryParam("query", query)
                    .queryParam("size", "1")
                    .build(false) // 인코딩은 RestTemplate이 처리
                    .toUriString();

            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<Map> resp = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);

            Map body = resp.getBody();
            if (body == null) return GeocodeResponse.fail("empty response");

            List docs = (List) body.get("documents");
            if (docs == null || docs.isEmpty()) return GeocodeResponse.fail("no address documents");

            Map first = (Map) docs.get(0);
            // 카카오: x=경도, y=위도
            String x = first.get("x") == null ? null : String.valueOf(first.get("x"));
            String y = first.get("y") == null ? null : String.valueOf(first.get("y"));

            if (x == null || y == null) return GeocodeResponse.fail("no x/y");
            return GeocodeResponse.ok(y, x, "address");

        } catch (Exception e) {
            return GeocodeResponse.fail("address search error");
        }
    }

    private GeocodeResponse searchKeyword(String query) {
        try {
            String url = UriComponentsBuilder
                    .fromHttpUrl(keywordUrl)
                    .queryParam("query", query)
                    .queryParam("size", "1")
                    .build(false)
                    .toUriString();

            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<Map> resp = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);

            Map body = resp.getBody();
            if (body == null) return GeocodeResponse.fail("empty response");

            List docs = (List) body.get("documents");
            if (docs == null || docs.isEmpty()) return GeocodeResponse.fail("no keyword documents");

            Map first = (Map) docs.get(0);
            String x = first.get("x") == null ? null : String.valueOf(first.get("x"));
            String y = first.get("y") == null ? null : String.valueOf(first.get("y"));

            if (x == null || y == null) return GeocodeResponse.fail("no x/y");
            return GeocodeResponse.ok(y, x, "keyword");

        } catch (Exception e) {
            return GeocodeResponse.fail("keyword search error");
        }
    }

    private HttpHeaders buildHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "KakaoAK " + kakaoRestKey);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        return headers;
    }


}
