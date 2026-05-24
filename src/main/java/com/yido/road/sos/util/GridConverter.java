package com.yido.road.sos.util;

import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.Metadata;
import com.drew.metadata.exif.ExifIFD0Directory;
import lombok.extern.slf4j.Slf4j;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

public class GridConverter {

    // 기상청 격자 변환 (LCC DFS) 표준 상수
    // (기상청 예보 API에서 널리 쓰는 값)
    private static final double RE = 6371.00877; // 지구 반경(km)
    private static final double GRID = 5.0;      // 격자 간격(km)
    private static final double SLAT1 = 30.0;    // 투영 위도1(degree)
    private static final double SLAT2 = 60.0;    // 투영 위도2(degree)
    private static final double OLON = 126.0;    // 기준 경도(degree)
    private static final double OLAT = 38.0;     // 기준 위도(degree)
    private static final double XO = 43.0;       // 기준점 X좌표(GRID)
    private static final double YO = 136.0;      // 기준점 Y좌표(GRID)

    public static GridXY toGrid(double lat, double lng) {
        double degrad = Math.PI / 180.0;

        double re = RE / GRID;
        double slat1 = SLAT1 * degrad;
        double slat2 = SLAT2 * degrad;
        double olon = OLON * degrad;
        double olat = OLAT * degrad;

        double sn = Math.tan(Math.PI * 0.25 + slat2 * 0.5) / Math.tan(Math.PI * 0.25 + slat1 * 0.5);
        sn = Math.log(Math.cos(slat1) / Math.cos(slat2)) / Math.log(sn);

        double sf = Math.tan(Math.PI * 0.25 + slat1 * 0.5);
        sf = Math.pow(sf, sn) * Math.cos(slat1) / sn;

        double ro = Math.tan(Math.PI * 0.25 + olat * 0.5);
        ro = re * sf / Math.pow(ro, sn);

        double ra = Math.tan(Math.PI * 0.25 + (lat * degrad) * 0.5);
        ra = re * sf / Math.pow(ra, sn);

        double theta = (lng * degrad) - olon;
        if (theta > Math.PI) theta -= 2.0 * Math.PI;
        if (theta < -Math.PI) theta += 2.0 * Math.PI;
        theta *= sn;

        double x = ra * Math.sin(theta) + XO;
        double y = ro - ra * Math.cos(theta) + YO;

        // 기상청 예제 관례대로 반올림(+0.5 후 int)
        int nx = (int) Math.floor(x + 0.5);
        int ny = (int) Math.floor(y + 0.5);

        return new GridXY(nx, ny, lat, lng);
    }
}
