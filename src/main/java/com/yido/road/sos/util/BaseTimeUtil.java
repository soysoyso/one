package com.yido.road.sos.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class BaseTimeUtil {

    private static final int PUBLISH_DELAY_MIN = 40; // 발표 지연 안전 버퍼

    public static BaseDt recentVilageBase() {

        LocalDateTime now = LocalDateTime.now().minusMinutes(PUBLISH_DELAY_MIN);
        int hhmm = now.getHour() * 100 + now.getMinute();

        String baseTime;
        LocalDateTime baseDateTime = now;

        if (hhmm < 210) {            // 00:00~02:09
            baseTime = "2300";
            baseDateTime = now.minusDays(1);
        } else if (hhmm < 510) {     // 02:10~05:09
            baseTime = "0200";
        } else if (hhmm < 810) {     // 05:10~08:09
            baseTime = "0500";
        } else if (hhmm < 1110) {    // 08:10~11:09
            baseTime = "0800";
        } else if (hhmm < 1410) {    // 11:10~14:09
            baseTime = "1100";
        } else if (hhmm < 1710) {    // 14:10~17:09
            baseTime = "1400";
        } else if (hhmm < 2010) {    // 17:10~20:09
            baseTime = "1700";
        } else if (hhmm < 2310) {    // 20:10~23:09
            baseTime = "2000";
        } else {                     // 23:10~23:59
            baseTime = "2300";
        }

        String baseDate = baseDateTime.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        return new BaseDt(baseDate, baseTime);
    }

    public static BaseDt vilageBaseAt(LocalDateTime t) {

        // 단기예보 baseTime 후보 (기상청 발표 시각)
        String[] baseTimes = new String[]{
                "2300","2000","1700","1400","1100","0800","0500","0200"
        };

        String ymd = t.format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd"));
        int hhmm = Integer.parseInt(t.format(java.time.format.DateTimeFormatter.ofPattern("HHmm")));

        for (int i = 0; i < baseTimes.length; i++) {
            int bt = Integer.parseInt(baseTimes[i]);
            if (hhmm >= bt) {
                return new BaseDt(ymd, baseTimes[i]);
            }
        }

        // 00:00~01:59면 전날 23:00 사용
        LocalDateTime prev = t.minusDays(1);
        String ymdPrev = prev.format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd"));
        return new BaseDt(ymdPrev, "2300");
    }

}
