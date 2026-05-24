package com.yido.road.sos.service.batch;

import com.yido.road.sos.client.weather.WeatherApiClient;
import com.yido.road.sos.model.LatLng;
import com.yido.road.sos.repository.main.WeatherCacheMapper;
import com.yido.road.sos.repository.main.WeatherCollectSourceMapper;
import com.yido.road.sos.util.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * incident + pothole 좌표를 가져온다
 *
 * Java에서 GridConverter.toGrid()로 nx/ny 변환
 * Set으로 중복 제거
 * 중복 제거된 격자만 외부 API 호출 → 캐시 저장
 *
 * 변경사항:
 * - PTY(강수형태) 기반으로 summary 저장
 * - SKY도 함께 저장 (캐시 hit일 때 skyCode default 방지)
 * - 이모지는 제외 (프론트에서 처리)
 */
@Service
public class WeatherCollector {

    private final WeatherApiClient apiClient;
    private final WeatherCacheMapper weatherCacheMapper;
    private final WeatherCollectSourceMapper sourceMapper;

    public WeatherCollector(WeatherApiClient apiClient,
                            WeatherCacheMapper weatherCacheMapper,
                            WeatherCollectSourceMapper sourceMapper) {
        this.apiClient = apiClient;
        this.weatherCacheMapper = weatherCacheMapper;
        this.sourceMapper = sourceMapper;
    }

    @Transactional
    public void collectLatest() {

        BaseDt bt = BaseTimeUtil.recentVilageBase();

        int days = 14;

        List<LatLng> points = new ArrayList<>();
        points.addAll(sourceMapper.selectIncidentLatLng(days));
        points.addAll(sourceMapper.selectPotholeLatLng(days));

        // 좌표 -> 격자 변환 후 중복 제거 + 대표 lat/lng 보관
        Set<String> dedup = new HashSet<>();
        List<GridXY> grids = new ArrayList<>();

        Map<String, LatLng> gridKeyToLatLng = new HashMap<>();

        for (LatLng p : points) {
            GridXY g = GridConverter.toGrid(p.lat, p.lng);
            String key = g.nx + "_" + g.ny;

            if (dedup.add(key)) {
                grids.add(g);

                LatLng ll = new LatLng();
                ll.lat = p.lat;
                ll.lng = p.lng;
                gridKeyToLatLng.put(key, ll);
            }
        }

// 격자별 수집
        for (GridXY g : grids) {
            String gridKey = g.nx + "_" + g.ny;
            LatLng ll = gridKeyToLatLng.get(gridKey);

            Double lat = (ll != null ? ll.lat : null);
            Double lng = (ll != null ? ll.lng : null);

            try {
                String xml = apiClient.getVilageFcstXml(bt.baseDate, bt.baseTime, g.nx, g.ny);

                Integer pty = WeatherXmlParser.pickPty(xml);
                Integer sky = WeatherXmlParser.pickSky(xml);
                Integer tmp = WeatherXmlParser.pickTmp(xml);

                String weatherCd = Utils.toWeatherCd(pty, sky);
                String weatherText = Utils.toWeatherText(pty, sky);

                Map<String, Object> params = new HashMap<>();
                params.put("nx", g.nx);
                params.put("ny", g.ny);
                params.put("lat", lat);
                params.put("lng", lng);
                params.put("baseDate", bt.baseDate);
                params.put("baseTime", bt.baseTime);
                params.put("pty", pty);
                params.put("sky", sky);
                params.put("tmp", tmp);
                params.put("weatherCd", weatherCd);
                params.put("weatherText", weatherText);

                weatherCacheMapper.upsertSuccess(params);

            } catch (Exception e) {
                String msg = (e.getMessage() == null) ? "error" : e.getMessage();
                if (msg.length() > 180) msg = msg.substring(0, 180);
                weatherCacheMapper.updateFail(g.nx, g.ny, msg);
            }
        }
    }


    /**
     * PTY (강수형태) 코드 요약
     * 0: 없음
     * 1: 비
     * 2: 비/눈
     * 3: 눈
     * 5: 빗방울
     * 6: 빗방울/눈날림
     * 7: 눈날림
     */
    private String ptyToSummary(Integer pty) {
        if (pty == null) return "확인불가";

        switch (pty.intValue()) {
            case 0: return "없음";
            case 1: return "비";
            case 2: return "비/눈";
            case 3: return "눈";
            case 5: return "빗방울";
            case 6: return "빗방울/눈날림";
            case 7: return "눈날림";
            default: return "확인불가";
        }
    }
}
