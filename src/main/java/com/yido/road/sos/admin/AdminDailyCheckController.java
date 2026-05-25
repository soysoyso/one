package com.yido.road.sos.admin;

import com.yido.road.sos.model.DailyCheckLog;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.AdminDailyCheckService;
import com.yido.road.sos.service.AdminUserService;
import com.yido.road.sos.util.ResultVO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/daily-checks")
public class AdminDailyCheckController {
    private final AdminDailyCheckService adminDailyCheckService;
    private final AdminUserService adminUserService;

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("")
    public String list(Model model, @AuthenticationPrincipal UserCustom loginUser) {
        String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        model.addAttribute("today", today);
        model.addAttribute("siteList", adminUserService.getAvailableSiteList(loginUser));
        return "admin/dailyCheckList";
    }

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("/data")
    @ResponseBody
    public Map<String, Object> data(@RequestParam Map<String, Object> params) {
        return adminDailyCheckService.getDailyCheckListData(params);
    }

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("/{checkId}")
    @ResponseBody
    public ResultVO detail(@PathVariable("checkId") Long checkId) {
        ResultVO result = new ResultVO();
        DailyCheckLog detail = adminDailyCheckService.getDailyCheckDetail(checkId);
        if (detail == null) {
            result.setCode("9999");
            result.setMessage("일상점검 정보를 찾을 수 없습니다.");
            return result;
        }
        result.setData(detail);
        return result;
    }
}
