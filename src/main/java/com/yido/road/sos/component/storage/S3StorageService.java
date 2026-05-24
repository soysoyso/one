package com.yido.road.sos.component.storage;

import com.yido.road.sos.util.ImageNormalizeUtil;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.ResponseBytes;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;

import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.time.Duration;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;

@Service
@Slf4j
public class S3StorageService implements StorageService {

    private final S3Client s3;
    private final S3Presigner presigner;
    private final StorageProperties props;

    public S3StorageService(
            @Qualifier("ncpS3v2Client") S3Client s3,
            @Qualifier("ncpS3v2Presigner") S3Presigner presigner,
            StorageProperties props
    ) {
        this.s3 = s3;
        this.presigner = presigner;
        this.props = props;
    }


    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("yyyy/MM/dd");

    @Override
    public UploadResult upload(MultipartFile file, String folder) {
        if (file == null || file.isEmpty()) return null;

        final String base = normalizeFolder(folder);
        final String dated = base + LocalDate.now().format(DATE) + "/";

        // 확장자
        String ext = StringUtils.getFilenameExtension(file.getOriginalFilename());
        if (ext != null) ext = ext.toLowerCase(Locale.ROOT);

        // 파일명: epoch-uuid.ext
        String filename = System.currentTimeMillis() + "-" + UUID.randomUUID();
        if (StringUtils.hasText(ext)) filename += "." + ext;

        final String key = dated + filename;

        return uploadByKey(file, key, ext);
    }

    @Override
    public UploadResult upload(MultipartFile file, String folder, String fileName) {
        if (file == null || file.isEmpty()) return null;

        final String base = normalizeFolder(folder);
        final String dated = base + LocalDate.now().format(DATE) + "/";

        // 확장자
        String ext = StringUtils.getFilenameExtension(file.getOriginalFilename());
        if (ext != null) ext = ext.toLowerCase(Locale.ROOT);

        // 전달된 파일명 사용 + 확장자 보정
        String filename = fileName;
        if (StringUtils.hasText(ext) && !filename.toLowerCase(Locale.ROOT).endsWith("." + ext)) {
            filename += "." + ext;
        }

        final String key = dated + filename;

        return uploadByKey(file, key, ext);
    }

    /** key가 확정된 상태로 실제 putObject 하는 공통 로직 */
    private UploadResult uploadByKey(MultipartFile file, String key, String ext) {

        String contentType = safeContentType(file.getContentType());

        PutObjectRequest.Builder pb = PutObjectRequest.builder()
                .bucket(props.getBucket())
                .key(key)
                .contentType(contentType);

        pb.acl(ObjectCannedACL.PUBLIC_READ);

        try {

            byte[] bytes = file.getBytes();

            if (ImageNormalizeUtil.isCandidateImage(contentType, ext)) {
                bytes = ImageNormalizeUtil.normalizeOrientation(bytes, ext);
            }

            s3.putObject(pb.build(), RequestBody.fromBytes(bytes));

        } catch (IOException e) {
            throw new UncheckedIOException("파일 업로드 실패", e);
        }

        int i = key.lastIndexOf('/');
        String path = (i >= 0) ? key.substring(0, i + 1) : "";
        String name = (i >= 0) ? key.substring(i + 1) : key;

        UploadResult r = new UploadResult();
        r.setBucket(props.getBucket());
        r.setKey(key);
        r.setPath(path);
        r.setName(name);
        r.setSize(file.getSize());
        r.setContentType(contentType);
        r.setPublicUrl(getPublicUrl(key));
        return r;
    }

    @Override
    public void delete(String key) {
        s3.deleteObject(b -> b.bucket(props.getBucket()).key(key));
    }

    @Override
    public String getPublicUrl(String key) {
        String base = props.getPublicBaseUrl();
        if (!StringUtils.hasText(base)) return key; // fallback (디버깅용)
        if (!base.endsWith("/")) base += "/";
        return base + key;
    }

    @Override
    public void streamToResponse(String key, String downloadName, HttpServletResponse response) {
        GetObjectRequest gor = GetObjectRequest.builder()
                .bucket(props.getBucket())
                .key(key)
                .build();

        String finalName = StringUtils.hasText(downloadName) ? downloadName : extractFileName(key);

        try (ResponseInputStream<GetObjectResponse> s3is = s3.getObject(gor)) {
            GetObjectResponse meta = s3is.response();

            String contentType = Optional.ofNullable(meta.contentType())
                    .filter(StringUtils::hasText)
                    .orElse("application/octet-stream");
            Long contentLength = meta.contentLength();

            response.setContentType(contentType);
            if (contentLength != null && contentLength >= 0) {
                response.setHeader(HttpHeaders.CONTENT_LENGTH, String.valueOf(contentLength));
            }

            ContentDisposition cd = ContentDisposition.attachment()
                    .filename(finalName, StandardCharsets.UTF_8)
                    .build();
            response.setHeader(HttpHeaders.CONTENT_DISPOSITION, cd.toString());
            response.setHeader(HttpHeaders.CACHE_CONTROL, "no-cache, no-store, must-revalidate");
            response.setHeader(HttpHeaders.PRAGMA, "no-cache");

            StreamUtils.copy(s3is, response.getOutputStream());
            response.flushBuffer();

        } catch (NoSuchKeyException e) { // ← 먼저
            log.warn("S3 객체가 존재하지 않음 (key={})", key);
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);

        } catch (S3Exception e) {        // ← 그 다음
            log.error("S3 예외 (key={}, status={}, code={}, msg={})",
                    key, e.statusCode(),
                    (e.awsErrorDetails()!=null? e.awsErrorDetails().errorCode(): "N/A"),
                    e.getMessage());
            // 권한 문제면 403, 그 외는 500 등으로 맵핑 가능
            response.setStatus(e.statusCode() == 403
                    ? HttpServletResponse.SC_FORBIDDEN
                    : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

        } catch (IOException ioe) {      // ← 마지막
            log.error("다운로드 스트리밍 실패 (key={})", key, ioe);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    public URI getPresignedGetUrl(String key, Duration ttl) {
        GetObjectRequest gor = GetObjectRequest.builder()
                .bucket(props.getBucket())
                .key(key)
                .build();

        GetObjectPresignRequest por = GetObjectPresignRequest.builder()
                .signatureDuration(ttl)
                .getObjectRequest(gor)
                .build();

        // URL -> String -> URI (체크예외 없음)
        return URI.create(presigner.presignGetObject(por).url().toString());
    }

    @Override
    public boolean exists(String key) {
        try {
            s3.headObject(b -> b.bucket(props.getBucket()).key(key));
            return true;
        } catch (NoSuchKeyException e) {
            return false;
        } catch (S3Exception e) {
            // 권한 문제 등으로도 예외가 날 수 있음
            log.warn("S3 headObject 예외 (key={}): {}", key, e.awsErrorDetails() != null ? e.awsErrorDetails().errorMessage() : e.getMessage());
            return false;
        }
    }

    @Override
    public Path downloadToFile(String key, Path destination) {
        try {
            Path parent = destination.getParent();
            if (parent != null && !Files.exists(parent)) {
                Files.createDirectories(parent);
            }
        } catch (IOException ioe) {
            throw new UncheckedIOException("로컬 경로 생성 실패: " + destination, ioe);
        }

        GetObjectRequest req = GetObjectRequest.builder()
                .bucket(props.getBucket())
                .key(key)
                .build();

        try (ResponseInputStream<GetObjectResponse> in = s3.getObject(req)) {
            Files.copy(in, destination, StandardCopyOption.REPLACE_EXISTING);
            return destination;

        } catch (NoSuchKeyException e) {
            throw new RuntimeException("객체가 존재하지 않습니다. key=" + key, e);
        } catch (S3Exception e) {
            throw new RuntimeException("S3 오류(key=" + key + "): " +
                    (e.awsErrorDetails() != null ? e.awsErrorDetails().errorMessage() : e.getMessage()), e);
        } catch (IOException e) {
            throw new RuntimeException("다운로드 I/O 오류(key=" + key + ", path=" + destination + ")", e);
        }
    }

    @Override
    public byte[] downloadBytes(String key) {
        GetObjectRequest req = GetObjectRequest.builder()
                .bucket(props.getBucket())
                .key(key)
                .build();
        try {
            ResponseBytes<GetObjectResponse> bytes = s3.getObjectAsBytes(req);
            return bytes.asByteArray();
        } catch (NoSuchKeyException e) {
            throw new RuntimeException("객체가 존재하지 않습니다. key=" + key, e);
        } catch (S3Exception e) {
            throw new RuntimeException("S3 오류(key=" + key + "): " +
                    (e.awsErrorDetails() != null ? e.awsErrorDetails().errorMessage() : e.getMessage()), e);
        }
    }

    /* ===== 유틸 ===== */

    private static String normalizeFolder(String folder) {
        if (!StringUtils.hasText(folder)) return "";
        String f = folder.trim();
        if (f.startsWith("/")) f = f.substring(1);
        if (!f.endsWith("/")) f += "/";
        return f;
    }

    private static String extractFileName(String key) {
        if (!StringUtils.hasText(key)) return "download";
        int i = key.lastIndexOf('/');
        String name = (i >= 0) ? key.substring(i + 1) : key;
        return StringUtils.hasText(name) ? name : "download";
    }

    private static String safeContentType(String maybe) {
        return (StringUtils.hasText(maybe)) ? maybe : "application/octet-stream";
    }

    @Override
    public void streamInline(String key, HttpServletResponse response) {
        GetObjectRequest gor = GetObjectRequest.builder()
                .bucket(props.getBucket())
                .key(key)
                .build();
        try (ResponseInputStream<GetObjectResponse> s3is = s3.getObject(gor)) {
            GetObjectResponse meta = s3is.response();
            String contentType = Optional.ofNullable(meta.contentType())
                    .filter(StringUtils::hasText)
                    .orElse("application/octet-stream");
            Long contentLength = meta.contentLength();

            response.setContentType(contentType);
            if (contentLength != null && contentLength >= 0) {
                response.setHeader(HttpHeaders.CONTENT_LENGTH, String.valueOf(contentLength));
            }
            // inline 렌더링
            // response.setHeader(HttpHeaders.CONTENT_DISPOSITION, "inline");
            // 캐시 (원하면 조정)
            response.setHeader(HttpHeaders.CACHE_CONTROL, "private, max-age=300");

            StreamUtils.copy(s3is, response.getOutputStream());
            response.flushBuffer();

        } catch (NoSuchKeyException e) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        } catch (S3Exception e) {
            response.setStatus(e.statusCode() == 403
                    ? HttpServletResponse.SC_FORBIDDEN
                    : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } catch (IOException ioe) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /* 작업 전(BEFORE) 사진 업로드 */
    public UploadResult uploadPotholeBefore(String reportNo, int sortOrd, String receiptGbCd, MultipartFile file) {

        if (!StringUtils.hasText(receiptGbCd)) {
            receiptGbCd = "POTHOLE";
        }

        receiptGbCd = receiptGbCd.trim();

        String folder = receiptGbCd.toLowerCase() + "/before";
        String seq = String.format("%02d", sortOrd);
        String fileName = receiptGbCd + "_" + reportNo + "_BEFORE_" + seq;

        return upload(file, folder, fileName);
    }

    /* 작업 후(AFTER) 사진 업로드 */
    public UploadResult uploadPotholeAfter(String reportNo, int sortOrd, String receiptGbCd, MultipartFile file) {

        if (!StringUtils.hasText(receiptGbCd)) {
            receiptGbCd = "POTHOLE";
        }

        receiptGbCd = receiptGbCd.trim();

        String folder = receiptGbCd.toLowerCase() + "/after";
        String seq = String.format("%02d", sortOrd);
        String fileName = receiptGbCd + "_" + reportNo + "_AFTER_" + seq;

        return upload(file, folder, fileName);
    }
    public java.io.InputStream getInputStream(String key) {

        GetObjectRequest req = GetObjectRequest.builder()
                .bucket(props.getBucket())
                .key(key)
                .build();

        return s3.getObject(req);
    }

    /* 스토리지 객체를 새 파일명으로 복사한 뒤 기존 객체를 삭제하여 파일명을 변경한다. */
    public UploadResult renameObject(String oldPath, String oldName, String newPath, String newName) {

        oldPath = Utils.safe(oldPath);
        newPath = Utils.safe(newPath);

        if (!oldPath.endsWith("/")) {
            oldPath += "/";
        }

        if (!newPath.endsWith("/")) {
            newPath += "/";
        }

        String oldKey = oldPath + oldName;
        String newKey = newPath + newName;

        log.info("[renameObject] oldKey={}", oldKey);
        log.info("[renameObject] newKey={}", newKey);

        // 1) copy
        CopyObjectRequest copyReq = CopyObjectRequest.builder()
                .sourceBucket(props.getBucket())
                .sourceKey(oldKey)
                .destinationBucket(props.getBucket())
                .destinationKey(newKey)
                .acl(ObjectCannedACL.PUBLIC_READ)
                .build();

        s3.copyObject(copyReq);

        // 2) delete old
        delete(oldKey);

        // 3) return
        UploadResult r = new UploadResult();
        r.setBucket(props.getBucket());
        r.setKey(newKey);
        r.setPath(newPath);
        r.setName(newName);
        r.setPublicUrl(getPublicUrl(newKey));

        return r;
    }

}
