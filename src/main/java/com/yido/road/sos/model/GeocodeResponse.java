package com.yido.road.sos.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

/*
 * 지오코딩(주소/키워드 → 좌표) 결과 응답 DTO
 * - 외부 API(카카오) 호출 결과를 공통 포맷으로 전달
 * - 성공 시 좌표 정보, 실패 시 메시지 반환
 */
public class GeocodeResponse {
    private String lat;     // 위도 (y)
    private String lng;     // 경도 (x)
    private String provider; // "kakao"
    private String type;     // "address" | "keyword"
    private String message;  // 실패 사유 등

    public GeocodeResponse() {}

    public GeocodeResponse(String lat, String lng, String provider, String type, String message) {
        this.lat = lat;
        this.lng = lng;
        this.provider = provider;
        this.type = type;
        this.message = message;
    }

    public static GeocodeResponse ok(String lat, String lng, String type) {
        return new GeocodeResponse(lat, lng, "kakao", type, null);
    }

    public static GeocodeResponse fail(String msg) {
        return new GeocodeResponse(null, null, "kakao", null, msg);
    }

    public String getLat() { return lat; }
    public void setLat(String lat) { this.lat = lat; }
    public String getLng() { return lng; }
    public void setLng(String lng) { this.lng = lng; }
    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
