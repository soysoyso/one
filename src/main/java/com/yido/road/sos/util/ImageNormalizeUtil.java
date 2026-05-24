package com.yido.road.sos.util;

import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.Metadata;
import com.drew.metadata.exif.ExifIFD0Directory;
import lombok.extern.slf4j.Slf4j;

import javax.imageio.ImageIO;
import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.*;

/**
 * 이미지 업로드 시 EXIF Orientation 기준으로 회전 보정하는 유틸 클래스
 * - 모바일 촬영 이미지 방향 깨짐 현상 방지
 */
@Slf4j
public class ImageNormalizeUtil {

    /**
     * 업로드 파일이 이미지 정규화(회전 보정) 대상인지 판단
     * - contentType 또는 확장자 기준으로 이미지 여부 체크
     */
    public static boolean isCandidateImage(String contentType, String ext) {
        String ct = (contentType == null) ? "" : contentType.toLowerCase();
        String e = (ext == null) ? "" : ext.toLowerCase();

        // jpg/jpeg/png 위주 (heic는 ImageIO 기본으로는 처리 안 되는 경우 많음)
        if (ct.startsWith("image/")) return true;
        if ("jpg".equals(e) || "jpeg".equals(e) || "png".equals(e)) return true;
        return false;
    }


    /**
     * EXIF Orientation 기반으로 이미지 회전 보정
     * - 모바일 촬영 이미지가 누워서 저장되는 문제 대응
     * - 실패 시 원본 바이트 그대로 반환(업로드 흐름 유지)
     */
    public static byte[] normalizeOrientation(byte[] inputBytes, String ext) {
        try {
            int orientation = readExifOrientation(inputBytes);
            if (orientation == 1) return inputBytes;

            BufferedImage src = ImageIO.read(new ByteArrayInputStream(inputBytes));
            if (src == null) return inputBytes;

            BufferedImage dst = transformByOrientation(src, orientation);

            // 포맷 결정: png면 png, 나머진 jpg로
            String format = "png".equalsIgnoreCase(ext) ? "png" : "jpg";

            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ImageIO.write(dst, format, bos);
            return bos.toByteArray();
        } catch (Exception e) {
            // 정규화 실패 시 원본 유지(업로드는 되게)
            return inputBytes;
        }
    }

    /**
     * 이미지 EXIF Orientation 값 조회 (없으면 1)
     */
    private static int readExifOrientation(byte[] bytes) {
        try {
            Metadata metadata = ImageMetadataReader.readMetadata(new ByteArrayInputStream(bytes));
            ExifIFD0Directory dir = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
            if (dir != null && dir.containsTag(ExifIFD0Directory.TAG_ORIENTATION)) {
                return dir.getInt(ExifIFD0Directory.TAG_ORIENTATION);
            }
        } catch (Exception ignore) {}
        return 1;
    }

    /**
     * Orientation 값에 따라 BufferedImage 회전/변환 처리
     * - 현재 3(180), 6(90CW), 8(270CW)만 지원 (미러 계열은 필요 시 확장)
     */
    private static BufferedImage transformByOrientation(BufferedImage src, int orientation) {
        if (orientation == 1) return src;

        int w = src.getWidth();
        int h = src.getHeight();

        AffineTransform tx = new AffineTransform();
        int newW = w, newH = h;

        if (orientation == 6) { // 90 CW
            tx.translate(h, 0);
            tx.rotate(Math.toRadians(90));
            newW = h; newH = w;
        } else if (orientation == 3) { // 180
            tx.translate(w, h);
            tx.rotate(Math.toRadians(180));
        } else if (orientation == 8) { // 270 CW (90 CCW)
            tx.translate(0, w);
            tx.rotate(Math.toRadians(270));
            newW = h; newH = w;
        } else {
            // 2/4/5/7(미러)까지 필요하면 여기 확장
            return src;
        }

        // PNG 투명 고려를 안 해도 된다면 TYPE_INT_RGB면 OK
        BufferedImage dst = new BufferedImage(newW, newH, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = dst.createGraphics();
        g2d.setTransform(tx);
        g2d.drawImage(src, 0, 0, null);
        g2d.dispose();
        return dst;
    }

	    
}// end class
