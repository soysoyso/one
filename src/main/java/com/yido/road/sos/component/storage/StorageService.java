package com.yido.road.sos.component.storage;

import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.net.URI;
import java.nio.file.Path;
import java.time.Duration;

/**
 * S3 호환 스토리지를 추상화한 공통 인터페이스.
 * - 업로드/다운로드/삭제/URL 생성/존재 확인
 * - 구현체 예: S3StorageService (AWS SDK v2, NCP 호환)
 */
public interface StorageService {

    /** 파일 업로드 */
    UploadResult upload(MultipartFile file, String folder);
    UploadResult upload(MultipartFile file, String folder, String fileName);

    /** 객체 삭제 */
    void delete(String key);

    /** 퍼블릭 객체 접근 URL (CDN/엔드포인트 기반) */
    String getPublicUrl(String key);

    /** 브라우저로 직접 스트리밍 다운로드 (Content-Disposition: attachment) */
    void streamToResponse(String key, String downloadName, HttpServletResponse response);

    /** S3 객체를 로컬 파일로 저장 */
    Path downloadToFile(String key, Path destination);

    /** S3 객체를 메모리로 로드 (대용량은 비추, 스트리밍 권장) */
    byte[] downloadBytes(String key);

    /** Private 객체 접근용 프리사인드 GET URL 발급 */
    URI getPresignedGetUrl(String key, Duration ttl);

    /** 객체 존재 여부 확인 */
    boolean exists(String key);

    /* ===================== 편의 메서드 (기본 구현) ===================== */

    /**
     * v1 스타일 시그니처와 유사한 오버로드 (folder + objectName → key)
     */
    default Path downloadToFile(String folder, String objectName, Path destination) {
        String key = buildKey(folder, objectName);
        return downloadToFile(key, destination);
    }

    /**
     * folder와 filename을 안전하게 결합해 key 생성.
     * 예) ("sos-field", "a.jpg") → "sos-field/a.jpg"
     */
    default String buildKey(String folder, String filename) {
        return normalizeFolder(folder) + (filename == null ? "" : filename);
    }

    /**
     * "sos" → "sos/" 로 정규화. 앞의 "/"는 제거.
     */
    static String normalizeFolder(String folder) {
        if (!StringUtils.hasText(folder)) return "";
        String f = folder.trim();
        if (f.startsWith("/")) f = f.substring(1);
        if (!f.endsWith("/")) f += "/";
        return f;
    }

    void streamInline(String key, HttpServletResponse response);
}
