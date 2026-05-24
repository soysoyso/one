package com.yido.road.sos.util;

public class Globals {
	public static String serverType;

	// 카카오 지도 JavaScript SDK APP KEY
	// 지도 표시 및 프론트 지도 기능에서 사용
	public static String kakaoMapKey;

	// 카카오 Local REST API 인증 KEY
	// 좌표 → 주소 변환, 좌표 검색 등 서버 Geo API 호출 시 사용
	public static String kakaoLocalKey;

	// 카카오 Local API 호출 Endpoint URL
	// 좌표 → 주소 변환(Reverse Geocoding) 등 Geo API 요청 시 사용
	public static String kakaoLocalEndpoint;
}