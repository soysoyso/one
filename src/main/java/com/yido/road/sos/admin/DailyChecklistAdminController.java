package com.yido.road.sos.admin;

import com.yido.road.sos.model.DailyChecklist;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.AdminUserService;
import com.yido.road.sos.service.CommonService;
import com.yido.road.sos.service.DailyChecklistService;
import com.yido.road.sos.util.ResultVO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/daily-checklists")
public class DailyChecklistAdminController {
    private final DailyChecklistService dailyChecklistService;
    private final AdminUserService adminUserService;
    private final CommonService commonService;

    @PreAuthorize("hasAnyAuthority('ATH100')")
    @GetMapping("/setting")
    public String setting(Model model, @AuthenticationPrincipal UserCustom loginUser) {
        model.addAttribute("siteList", adminUserService.getAvailableSiteList(loginUser));
        model.addAttribute("inputTypeList", commonService.codes("CHECK_INPUT_TYPE"));
        return "admin/dailyChecklistSetting";
    }

    @PreAuthorize("hasAnyAuthority('ATH100')")
    @GetMapping("/data")
    @ResponseBody
    public Map<String, Object> data(@RequestParam Map<String, Object> params) {
        return dailyChecklistService.getChecklistListData(params);
    }

    @PreAuthorize("hasAnyAuthority('ATH100')")
    @GetMapping("/{checklistId}")
    @ResponseBody
    public ResultVO detail(@PathVariable("checklistId") Long checklistId) {
        ResultVO result = new ResultVO();
        DailyChecklist checklist = dailyChecklistService.getChecklist(checklistId);
        if (checklist == null) {
            result.setCode("9999");
            result.setMessage("체크리스트 정보를 찾을 수 없습니다.");
            return result;
        }
        result.setData(checklist);
        return result;
    }

    @PreAuthorize("hasAnyAuthority('ATH100')")
    @PostMapping("/save")
    @ResponseBody
    public ResultVO save(@RequestParam MultiValueMap<String, String> params,
                         @AuthenticationPrincipal UserCustom loginUser) {
        return dailyChecklistService.saveChecklist(toParamMap(params), loginUser);
    }

    @PreAuthorize("hasAnyAuthority('ATH100')")
    @PostMapping("/delete")
    @ResponseBody
    public ResultVO delete(@RequestParam("checklistId") Long checklistId,
                           @AuthenticationPrincipal UserCustom loginUser) {
        return dailyChecklistService.deleteChecklist(checklistId, loginUser);
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
}
