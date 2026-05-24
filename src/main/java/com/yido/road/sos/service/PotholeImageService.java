package com.yido.road.sos.service;


import com.yido.road.sos.component.storage.S3StorageService;
import com.yido.road.sos.component.storage.UploadResult;
import com.yido.road.sos.model.Pothole;
import com.yido.road.sos.model.PotholeImage;
import com.yido.road.sos.repository.main.PotholeImageMapper;
import com.yido.road.sos.repository.main.PotholeMapper;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.*;


@Slf4j
@Service
@RequiredArgsConstructor
public class PotholeImageService {

    private final PotholeImageMapper potholeImageMapper;
    private final PotholeMapper potholeMapper;
    private final S3StorageService storageService;

    public PotholeImage selectPotholeImageOne(String reportNo, String photoGb, Integer sortOrd) {
        return potholeImageMapper.selectPotholeImageOne(reportNo, photoGb, sortOrd);
    }

    public List<PotholeImage> selectPotholeImagesByReportNo(String reportNo, String photoGb) {
        return potholeImageMapper.selectPotholeImagesByReportNo(reportNo, photoGb);
    }

    /**
     * 이미지 일괄 다운로드
     *
     * @param reportNos
     * @param response
     * @throws Exception
     */
    public void downloadSelectedPhotos(List<String> reportNos,
                                       HttpServletResponse response) throws Exception {

        String zipName = "현장사진_" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + ".zip";
        String encodedName = java.net.URLEncoder.encode(zipName, "UTF-8").replace("+", "%20");

        response.setContentType("application/zip");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedName);

        String[] photoGbs = {"BEFORE", "AFTER"};

        try (java.util.zip.ZipOutputStream zos =
                     new java.util.zip.ZipOutputStream(response.getOutputStream())) {

            for (String reportNo : reportNos) {

                String receiptGbCd = potholeMapper.selectReceiptGbCdByReportNo(reportNo);
                receiptGbCd = Utils.safe(receiptGbCd);

                if ("".equals(receiptGbCd.trim())) {
                    receiptGbCd = "UNKNOWN";
                }

                receiptGbCd = receiptGbCd.replaceAll("[\\\\/:*?\"<>|]", "_");

                for (String photoGb : photoGbs) {

                    List<PotholeImage> images =
                            potholeImageMapper.selectPotholeImagesByReportNo(reportNo, photoGb);

                    for (PotholeImage img : images) {

                        String key = Utils.safe(img.getImgPath()) + Utils.safe(img.getImgName());

                        if ("".equals(key.trim())) {
                            continue;
                        }

                        if (!storageService.exists(key)) {
                            log.warn("[이미지 일괄다운로드] 스토리지 파일 없음. reportNo={}, photoGb={}, sortOrd={}, key={}",
                                    reportNo, photoGb, img.getSortOrd(), key);
                            continue;
                        }

                        String gbNm = "BEFORE".equals(photoGb) ? "작업전" : "작업후";

                        String zipFileName = receiptGbCd + "/" + reportNo + "_" + gbNm + "_" + img.getSortOrd() + "_" + img.getImgName();

                        try (java.io.InputStream is = storageService.getInputStream(key)) {

                            zos.putNextEntry(new java.util.zip.ZipEntry(zipFileName));

                            byte[] buffer = new byte[4096];
                            int len;

                            while ((len = is.read(buffer)) != -1) {
                                zos.write(buffer, 0, len);
                            }

                            zos.closeEntry();
                        }
                    }
                }
            }

            zos.finish();
        }
    }

}
