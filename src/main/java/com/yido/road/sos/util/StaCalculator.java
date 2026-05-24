package com.yido.road.sos.util;

import java.util.*;

/**
 * 도로 선형(polyline) 기준으로 좌표를 스냅하여
 * STA(누적거리, m)와 보정 좌표를 계산하는 유틸 클래스
 * - 포트홀 위치를 노선 기준 거리로 환산할 때 사용
 */
public class StaCalculator {

    // 지구 반경(미터)
    private static final double R = 6371000.0;

    public static class Pt {
        public double lat;
        public double lng;
        public Pt(double lat, double lng) { this.lat = lat; this.lng = lng; }
    }

    public static class Result {
        public long staMeters;
        public double snapLat;
        public double snapLng;
        public double snapDistanceMeters;
    }

    // 메인: polyline(순서대로) + 포트홀 좌표 -> 누적거리(m)
    public Result calc(List<Pt> line, double pLat, double pLng) {
        Result out = new Result();
        if (line == null || line.size() < 2) return null;

        Pt p = new Pt(pLat, pLng);

        // 기준 위도(로컬 좌표 변환용): 포인트 근처 위도를 쓰면 안정적
        double baseLatRad = Math.toRadians(pLat);

        double bestDist = Double.MAX_VALUE;
        int bestSegIdx = -1;
        double bestT = 0.0;
        double bestQx = 0.0;
        double bestQy = 0.0;

        // 각 선분 검사(로컬 xy로 투영해서 선분 투영 t 구함)
        for (int i = 0; i < line.size() - 1; i++) {
            Pt a = line.get(i);
            Pt b = line.get(i + 1);

            double ax = toX(a.lng, baseLatRad);
            double ay = toY(a.lat);
            double bx = toX(b.lng, baseLatRad);
            double by = toY(b.lat);
            double px = toX(p.lng, baseLatRad);
            double py = toY(p.lat);

            double abx = bx - ax;
            double aby = by - ay;
            double apx = px - ax;
            double apy = py - ay;

            double ab2 = abx * abx + aby * aby;
            if (ab2 == 0) continue;

            double t = (apx * abx + apy * aby) / ab2;
            if (t < 0) t = 0;
            if (t > 1) t = 1;

            double qx = ax + t * abx;
            double qy = ay + t * aby;

            double dx = px - qx;
            double dy = py - qy;
            double dist = Math.sqrt(dx * dx + dy * dy); // meters (로컬 xy가 meter 단위)


            if (dist < bestDist) {
                bestDist = dist;
                bestSegIdx = i;
                bestT = t;
                bestQx = qx;
                bestQy = qy;

            }
        }

        if (bestSegIdx < 0) return null;

        // 누적거리 계산
        double acc = 0.0;
        for (int i = 0; i < bestSegIdx; i++) {
            acc += segmentLenMeters(line.get(i), line.get(i + 1));
        }

        // 마지막 선택 선분은 A->Q 까지만 더함
        Pt a = line.get(bestSegIdx);
        Pt b = line.get(bestSegIdx + 1);
        double segLen = segmentLenMeters(a, b);
        acc += segLen * bestT;

        // 스냅 좌표 역변환(로컬 xy -> lat/lng)
        double snapLat = fromY(bestQy);
        double snapLng = fromX(bestQx, baseLatRad);

        out.staMeters = Math.round(acc);
        out.snapLat = snapLat;
        out.snapLng = snapLng;
        out.snapDistanceMeters = bestDist;

        return out;
    }

    // 로컬 투영: lng -> x(m)
    private double toX(double lng, double baseLatRad) {
        return Math.toRadians(lng) * R * Math.cos(baseLatRad);
    }

    // 로컬 투영: lat -> y(m)
    private double toY(double lat) {
        return Math.toRadians(lat) * R;
    }

    private double fromX(double x, double baseLatRad) {
        return Math.toDegrees(x / (R * Math.cos(baseLatRad)));
    }

    private double fromY(double y) {
        return Math.toDegrees(y / R);
    }

    // 두 위경도 점 사이 선분 길이(미터) - Haversine
    private double segmentLenMeters(Pt a, Pt b) {
        double lat1 = Math.toRadians(a.lat);
        double lat2 = Math.toRadians(b.lat);
        double dLat = lat2 - lat1;
        double dLng = Math.toRadians(b.lng - a.lng);

        double sin1 = Math.sin(dLat / 2.0);
        double sin2 = Math.sin(dLng / 2.0);

        double h = sin1 * sin1 + Math.cos(lat1) * Math.cos(lat2) * sin2 * sin2;
        double c = 2.0 * Math.atan2(Math.sqrt(h), Math.sqrt(1.0 - h));
        return R * c;
    }

    public int toStaKm(long staMeters) {
        if (staMeters < 0) return 0;
        return (int)(staMeters / 1000);
    }

    public String formatStaText(int staKm, String refName) {
        String s = "STA " + staKm;
        if (refName != null && refName.trim().length() > 0) {
            s = s + " (" + refName.trim() + ")";
        }
        return s;
    }
}