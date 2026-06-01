package com.yido.road.sos.controller;

import com.yido.road.sos.model.DailyChecklist;
import com.yido.road.sos.model.DailyCheckPhoto;
import com.yido.road.sos.repository.main.DailyCheckPhotoMapper;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.DailyCheckService;
import com.yido.road.sos.util.ResultVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.MultiValueMap;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/manage/daily-checks")
public class DailyCheckController {
    private final DailyCheckService dailyCheckService;
    private final DailyCheckPhotoMapper dailyCheckPhotoMapper;

    @Value("${Globals.File.UploadPath}")
    private String uploadRoot;

    @PreAuthorize("hasAuthority('ATH300')")
    @GetMapping("/form")
    public String form(Model model, @AuthenticationPrincipal UserCustom loginUser) {
        List<DailyChecklist> checklists = dailyCheckService.getUsableChecklists(loginUser);
        model.addAttribute("checklistList", checklists);
        model.addAttribute("today", new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
        model.addAttribute("siteInfo", loginUser == null ? null : loginUser.getSiteInfo());
        return "ims/daily-check/form";
    }

    @PreAuthorize("hasAuthority('ATH300')")
    @GetMapping("")
    public String list(Model model, @AuthenticationPrincipal UserCustom loginUser) {
        model.addAttribute("today", new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
        model.addAttribute("siteInfo", loginUser == null ? null : loginUser.getSiteInfo());
        return "ims/daily-check/list";
    }

    @PreAuthorize("hasAuthority('ATH300')")
    @GetMapping("/data")
    @ResponseBody
    public Map<String, Object> data(@RequestParam Map<String, Object> params,
                                    @AuthenticationPrincipal UserCustom loginUser) {
        return dailyCheckService.getMyDailyCheckListData(params, loginUser);
    }

    @PreAuthorize("hasAuthority('ATH300')")
    @GetMapping("/{checkId}")
    @ResponseBody
    public ResultVO detail(@PathVariable("checkId") Long checkId,
                           @AuthenticationPrincipal UserCustom loginUser) {
        ResultVO result = new ResultVO();
        Object detail = dailyCheckService.getMyDailyCheckDetail(checkId, loginUser);
        if (detail == null) {
            result.setCode("9999");
            result.setMessage("일상점검 이력을 찾을 수 없습니다.");
            return result;
        }
        result.setData(detail);
        return result;
    }

    @PreAuthorize("hasAuthority('ATH300')")
    @GetMapping("/checklists/{checklistId}")
    @ResponseBody
    public ResultVO checklist(@PathVariable("checklistId") Long checklistId) {
        ResultVO result = new ResultVO();
        DailyChecklist checklist = dailyCheckService.getFormChecklist(checklistId);
        if (checklist == null) {
            result.setCode("9999");
            result.setMessage("체크리스트 정보를 찾을 수 없습니다.");
            return result;
        }
        result.setData(checklist);
        return result;
    }

    @PreAuthorize("hasAuthority('ATH300')")
    @PostMapping("/save")
    @ResponseBody
    public ResultVO save(@RequestParam MultiValueMap<String, String> params,
                         @AuthenticationPrincipal UserCustom loginUser) {
        return dailyCheckService.saveDailyCheck(toParamMap(params), loginUser);
    }

    @PreAuthorize("hasAuthority('ATH300')")
    @PostMapping("/save-with-photos")
    @ResponseBody
    public ResultVO saveWithPhotos(@RequestParam MultiValueMap<String, String> params,
                                   @RequestParam(value = "beforePhotos", required = false) MultipartFile[] beforePhotos,
                                   @RequestParam(value = "afterPhotos", required = false) MultipartFile[] afterPhotos,
                                   @AuthenticationPrincipal UserCustom loginUser) {
        return dailyCheckService.saveDailyCheck(toParamMap(params), beforePhotos, afterPhotos, loginUser);
    }

    @GetMapping("/photos/{photoId}")
    public void photo(@PathVariable("photoId") Long photoId, HttpServletResponse response) throws IOException {
        DailyCheckPhoto photo = dailyCheckPhotoMapper.selectDailyCheckPhoto(photoId);
        if (photo == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        File file = new File(new File(uploadRoot, photo.getImgPath()), photo.getImgName());
        if (!file.exists() || !file.isFile()) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        response.setContentType(resolveContentType(photo.getImgName()));
        response.setContentLengthLong(file.length());
        FileCopyUtils.copy(new FileInputStream(file), response.getOutputStream());
    }

    private Map<String, Object> toParamMap(MultiValueMap<String, String> params) {
        Map<String, Object> result = new HashMap<>();
        for (Map.Entry<String, List<String>> entry : params.entrySet()) {
            List<String> values = entry.getValue();
            if (values == null || values.isEmpty()) {
                result.put(entry.getKey(), "");
            } else if (values.size() == 1) {
                result.put(entry.getKey(), values.get(0));
            } else {
                result.put(entry.getKey(), values.toArray(new String[0]));
            }
        }
        return result;
    }

    private String resolveContentType(String fileName) {
        String lower = fileName == null ? "" : fileName.toLowerCase();
        if (lower.endsWith(".png")) {
            return "image/png";
        }
        if (lower.endsWith(".gif")) {
            return "image/gif";
        }
        if (lower.endsWith(".webp")) {
            return "image/webp";
        }
        return "image/jpeg";
    }
}
