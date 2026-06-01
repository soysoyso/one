package com.yido.road.sos.service;

import com.yido.road.sos.model.DailyCheckLog;
import com.yido.road.sos.model.DailyCheckLogItem;
import com.yido.road.sos.model.DailyCheckPhoto;
import com.yido.road.sos.model.DailyChecklist;
import com.yido.road.sos.model.DailyChecklistItem;
import com.yido.road.sos.repository.main.DailyCheckLogMapper;
import com.yido.road.sos.repository.main.DailyCheckPhotoMapper;
import com.yido.road.sos.repository.main.DailyChecklistMapper;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.util.ResultVO;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DailyCheckService {
    private final DailyChecklistMapper dailyChecklistMapper;
    private final DailyCheckLogMapper dailyCheckLogMapper;
    private final DailyCheckPhotoMapper dailyCheckPhotoMapper;

    @Value("${Globals.File.UploadPath}")
    private String uploadRoot;

    public List<DailyChecklist> getUsableChecklists(UserCustom loginUser) {
        String siteCd = getSiteCd(loginUser);
        return dailyChecklistMapper.selectUsableDailyChecklists(siteCd);
    }

    public DailyChecklist getFormChecklist(Long checklistId) {
        DailyChecklist checklist = dailyChecklistMapper.selectDailyChecklist(checklistId);
        if (checklist != null && "Y".equals(checklist.getUseYn())) {
            checklist.setItems(dailyChecklistMapper.selectDailyChecklistItemList(checklistId));
        }
        return checklist;
    }

    public Map<String, Object> getMyDailyCheckListData(Map<String, Object> params, UserCustom loginUser) {
        Map<String, Object> searchParams = new HashMap<>();
        String startDate = Utils.getParam(params, "startDate");
        String endDate = Utils.getParam(params, "endDate");
        String keyword = Utils.getParam(params, "keyword");

        if (startDate.isEmpty() && endDate.isEmpty()) {
            String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
            startDate = today;
            endDate = today;
        }

        int page = parseInt(params.get("page"), 1);
        int pageSize = 10;
        int offset = (page - 1) * pageSize;

        searchParams.put("startDate", startDate);
        searchParams.put("endDate", endDate);
        searchParams.put("siteCd", getSiteCd(loginUser));
        searchParams.put("writerId", loginUser == null ? "" : loginUser.getUserId());
        searchParams.put("keyword", keyword);
        searchParams.put("offset", offset);
        searchParams.put("pageSize", pageSize);

        List<DailyCheckLog> list = dailyCheckLogMapper.selectDailyCheckLogList(searchParams);
        int totalCount = dailyCheckLogMapper.selectDailyCheckLogCount(searchParams);

        Map<String, Object> pageInfo = new HashMap<>();
        pageInfo.put("currentPage", page);
        pageInfo.put("pageSize", pageSize);
        pageInfo.put("totalPages", (int) Math.ceil(totalCount / (double) pageSize));

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("pageInfo", pageInfo);
        result.put("totalCount", totalCount);
        return result;
    }

    public DailyCheckLog getMyDailyCheckDetail(Long checkId, UserCustom loginUser) {
        DailyCheckLog detail = dailyCheckLogMapper.selectDailyCheckLog(checkId);
        if (detail == null) {
            return null;
        }
        String userId = loginUser == null ? "" : loginUser.getUserId();
        String siteCd = getSiteCd(loginUser);
        if (!userId.equals(detail.getWriterId()) || (!siteCd.isEmpty() && !siteCd.equals(detail.getSiteCd()))) {
            return null;
        }
        detail.setItems(dailyCheckLogMapper.selectDailyCheckLogItemList(checkId));
        detail.setPhotos(dailyCheckPhotoMapper.selectDailyCheckPhotos(checkId));
        return detail;
    }

    @Transactional
    public ResultVO saveDailyCheck(Map<String, Object> params, UserCustom loginUser) {
        ResultVO result = new ResultVO();
        Long checklistId = parseLong(params.get("checklistId"));
        String checkDate = Utils.getParam(params, "checkDate");
        if (checklistId == null) {
            result.setCode("9999");
            result.setMessage("체크리스트를 선택해주세요.");
            return result;
        }
        if (isBlank(checkDate)) {
            result.setCode("9999");
            result.setMessage("점검일자를 입력해주세요.");
            return result;
        }

        DailyChecklist checklist = getFormChecklist(checklistId);
        if (checklist == null) {
            result.setCode("9999");
            result.setMessage("사용 가능한 체크리스트가 아닙니다.");
            return result;
        }

        String statusCd = Utils.getParam(params, "statusCd");
        if (isBlank(statusCd)) {
            statusCd = "SAVED";
        }
        if (!"DONE".equals(statusCd)) {
            statusCd = "SAVED";
        }

        List<DailyCheckLogItem> items = toLogItems(params, checklist);
        String validationMessage = "DONE".equals(statusCd) ? validateRequiredItems(items) : "";
        if (!isBlank(validationMessage)) {
            result.setCode("9999");
            result.setMessage(validationMessage);
            return result;
        }

        String ymd = checkDate.replaceAll("[^0-9]", "");
        if (ymd.length() != 8) {
            ymd = new SimpleDateFormat("yyyyMMdd").format(new Date());
        }

        DailyCheckLog log = new DailyCheckLog();
        log.setCheckNo(dailyCheckLogMapper.selectNextDailyCheckNo(ymd));
        log.setCheckDate(checkDate);
        log.setCheckTitle(Utils.getParam(params, "checkTitle"));
        log.setChecklistId(checklistId);
        log.setSiteCd(getSiteCd(loginUser));
        log.setWriterId(loginUser == null ? "" : loginUser.getUserId());
        log.setStatusCd(statusCd);
        log.setWeatherCd(Utils.getParam(params, "weatherCd"));
        log.setRemark(Utils.getParam(params, "remark"));
        dailyCheckLogMapper.insertDailyCheckLog(log);

        for (DailyCheckLogItem item : items) {
            item.setCheckId(log.getCheckId());
            dailyCheckLogMapper.insertDailyCheckLogItem(item);
        }

        result.setData(log);
        return result;
    }

    @Transactional
    public ResultVO saveDailyCheck(Map<String, Object> params, MultipartFile[] beforePhotos,
                                   MultipartFile[] afterPhotos, UserCustom loginUser) {
        ResultVO result = saveDailyCheck(params, loginUser);
        if (!"0000".equals(result.getCode())) {
            return result;
        }

        DailyCheckLog log = (DailyCheckLog) result.getData();
        savePhotos(log.getCheckId(), "BEFORE", beforePhotos);
        savePhotos(log.getCheckId(), "AFTER", afterPhotos);
        return result;
    }

    private List<DailyCheckLogItem> toLogItems(Map<String, Object> params, DailyChecklist checklist) {
        Map<String, String> valueMap = new HashMap<>();
        Map<String, String> memoMap = new HashMap<>();
        for (Map.Entry<String, Object> entry : params.entrySet()) {
            if (entry.getKey() != null && entry.getKey().startsWith("itemValue_")) {
                valueMap.put(entry.getKey().substring("itemValue_".length()), entry.getValue() == null ? "" : entry.getValue().toString().trim());
            }
            if (entry.getKey() != null && entry.getKey().startsWith("itemMemo_")) {
                memoMap.put(entry.getKey().substring("itemMemo_".length()), entry.getValue() == null ? "" : entry.getValue().toString().trim());
            }
        }

        List<DailyCheckLogItem> result = new ArrayList<>();
        List<DailyChecklistItem> checklistItems = checklist.getItems() == null ? new ArrayList<DailyChecklistItem>() : checklist.getItems();
        for (DailyChecklistItem source : checklistItems) {
            if (!"Y".equals(source.getUseYn())) {
                continue;
            }
            DailyCheckLogItem item = new DailyCheckLogItem();
            item.setItemId(source.getItemId());
            item.setItemName(source.getItemName());
            item.setInputType(source.getInputType());
            item.setRequiredYn(source.getRequiredYn());
            item.setSortOrd(String.valueOf(source.getSortOrd() == null ? 0 : source.getSortOrd()));
            item.setCheckValue(valueMap.getOrDefault(String.valueOf(source.getItemId()), ""));
            item.setCheckMemo(memoMap.getOrDefault(String.valueOf(source.getItemId()), ""));
            result.add(item);
        }
        return result;
    }

    private String validateRequiredItems(List<DailyCheckLogItem> items) {
        for (DailyCheckLogItem item : items) {
            if ("Y".equals(item.getRequiredYn()) && isBlank(item.getCheckValue())) {
                return item.getItemName() + " 항목을 입력해주세요.";
            }
        }
        return "";
    }

    private String getSiteCd(UserCustom loginUser) {
        if (loginUser == null || loginUser.getSiteInfo() == null) {
            return "";
        }
        return loginUser.getSiteInfo().getSiteCd();
    }

    private void savePhotos(Long checkId, String photoGb, MultipartFile[] photos) {
        if (checkId == null || photos == null || photos.length == 0) {
            return;
        }

        int sortOrd = 1;
        for (MultipartFile photo : photos) {
            if (photo == null || photo.isEmpty()) {
                continue;
            }

            DailyCheckPhoto saved = savePhotoFile(checkId, photoGb, sortOrd, photo);
            dailyCheckPhotoMapper.insertDailyCheckPhoto(saved);
            sortOrd++;
        }
    }

    private DailyCheckPhoto savePhotoFile(Long checkId, String photoGb, int sortOrd, MultipartFile file) {
        String ext = StringUtils.getFilenameExtension(file.getOriginalFilename());
        if (ext == null || ext.trim().isEmpty()) {
            ext = "jpg";
        }
        ext = ext.toLowerCase();

        String relativePath = "daily-check/" + checkId + "/" + photoGb.toLowerCase() + "/";
        File dir = new File(uploadRoot, relativePath);
        if (!dir.exists() && !dir.mkdirs()) {
            throw new IllegalStateException("사진 저장 폴더를 만들 수 없습니다.");
        }

        String fileName = "daily_" + checkId + "_" + photoGb + "_" + sortOrd + "_" + System.currentTimeMillis() + "." + ext;
        File target = new File(dir, fileName);
        try {
            file.transferTo(target);
        } catch (IOException e) {
            throw new UncheckedIOException("사진 저장 중 오류가 발생했습니다.", e);
        }

        DailyCheckPhoto photo = new DailyCheckPhoto();
        photo.setCheckId(checkId);
        photo.setPhotoGb(photoGb);
        photo.setImgPath(relativePath);
        photo.setImgName(fileName);
        photo.setSortOrd(sortOrd);
        return photo;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private Long parseLong(Object value) {
        if (value == null || value.toString().trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(value.toString().trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parseInt(Object value, int defaultValue) {
        if (value == null || value.toString().trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.toString().trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
