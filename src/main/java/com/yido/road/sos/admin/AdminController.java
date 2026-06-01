package com.yido.road.sos.admin;

import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.model.CdCommon;
import com.yido.road.sos.model.NotificationRecipient;
import com.yido.road.sos.model.SiteInfo;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.*;
import com.yido.road.sos.util.ResultVO;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/admin")
public class AdminController {

    private final SiteInfoService siteInfoService;
    private final CommonService commonService;
    private final IncidentService incidentService;
    private final AdminUserService adminUserService;
    private final NotificationRecipientService notificationRecipientService;

    @GetMapping({"", "/"})
    public String root() {
        return "redirect:/admin/main";
    }

    /**
     * ✅ admin 영역 엔트리 포인트
     * - 권한별로 갈 곳을 정해준다.
     * - ATH300(오케이로드)은 admin 화면이 없으니 manage로 보내야 함.
     */
    //@PreAuthorize("hasAnyAuthority('ATH100','ATH200','ATH300','ATH400')")
    @GetMapping("/main")
    public String main(HttpServletRequest req,@AuthenticationPrincipal UserCustom loginUser) {

        boolean isAth100 = hasAuth(loginUser, "ATH100");
        boolean isAth200 = hasAuth(loginUser, "ATH200");
        boolean isAth300 = hasAuth(loginUser, "ATH300");
        boolean isAth400 = hasAuth(loginUser, "ATH400");

        log.debug("AUTH = " + SecurityContextHolder.getContext().getAuthentication().getAuthorities());
        log.debug("URI  = " + req.getRequestURI());
        log.debug("loginUser:" + loginUser);

        // ✅ /admin 접근 시에는 ATH200 우선!
        if (isAth200 || isAth100) {
            return "redirect:/admin/ims/dashboard";
        }

        if (isAth400) {
            return "redirect:/admin/dashboard";
        }

        log.debug("2");
        // ATH300만 있는 경우엔 admin에 메인이 없으니 manage로
        if (isAth300) {
            return "redirect:/manage";
        }

        log.debug("4");
        return "redirect:/admin/login-error";
    }
    /** 권한 체크 유틸 */
    private boolean hasAuth(UserCustom user, String auth) {
        if (user == null || user.getAuthorities() == null) return false;
        return user.getAuthorities().stream()
                .anyMatch(a -> auth.equals(a.getAuthority()));
    }


    /**
     * 사고접수 관리화면
     *
     * @param model
     * @param req
     * @return
     */
    @PreAuthorize("hasAnyAuthority('ATH100','ATH400')")
    @RequestMapping("/dashboard")
    public String dashboard(Model model, HttpServletRequest req,  @AuthenticationPrincipal UserCustom loginUser) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        List<SiteInfo> siteList = new ArrayList<>();
        List<String> siteCdList = new ArrayList<>();

        // 관리대상 현장목록 조회
        String userId = loginUser.getUserId();
        List<SiteInfo> manageSiteList = siteInfoService.getManageSiteByUserId(userId);

        if (manageSiteList.size() > 0) {
            // 관리대상 현장코드 추출
            for (SiteInfo site : manageSiteList) {
                siteCdList.add(site.getSiteCd());
            }
            siteList = manageSiteList;
        } else {
            // 관리대상이 전체인경우.. 별도 조회
            siteCdList = siteInfoService.selectAllSite(auth.getName());

            siteList = siteInfoService.selectSiteList(new SiteInfo());

        }
        model.addAttribute("siteList", siteList);
        model.addAttribute("siteCdList", siteCdList.toString());

        // 접수방법 공통코드
        model.addAttribute("methodList", commonService.codes("001"));

        // 처리상태 공통코드
        model.addAttribute("statusList", commonService.codes("002"));

        return "/admin/dashboard";
    }

    /* 관리자 설정 페이지 */
    @PreAuthorize("hasAnyAuthority('ATH100')")
    @GetMapping("/user/setting")
    public String userSetting(Model model, @AuthenticationPrincipal UserCustom loginUser) {

        Map<String, Object> params = new HashMap<>();
        params.put("cdDiv", "003");

        List<CdCommon> authList = commonService.selectCommonList(params);
        model.addAttribute("authList", authList);

        List<SiteInfo> siteList = adminUserService.getAvailableSiteList(loginUser);
        model.addAttribute("siteList", siteList);
        model.addAttribute("deptList", commonService.codes("DEPT"));

        return "admin/userSetting";
    }

    /* 알림톡 수신자 설정 페이지 */
    @PreAuthorize("hasAnyAuthority('ATH100')")
    @GetMapping("/notification/recipients")
    public String notificationRecipients(Model model, @AuthenticationPrincipal UserCustom loginUser) {
        model.addAttribute("notificationTypeList", commonService.codes("NOTI_TYPE"));
        model.addAttribute("siteList", adminUserService.getAvailableSiteList(loginUser));
        model.addAttribute("deptList", commonService.codes("DEPT"));
        return "admin/notificationRecipients";
    }

    /* 알림톡 수신자 목록 조회 */
    @PreAuthorize("hasAnyAuthority('ATH100')")
    @GetMapping("/notification/recipients/data")
    @ResponseBody
    public Map<String, Object> getNotificationRecipientData(@RequestParam Map<String, Object> params) {
        return notificationRecipientService.getRecipientListData(params);
    }

    /* 알림톡 수신자 상세 조회 */
    @PreAuthorize("hasAnyAuthority('ATH100')")
    @GetMapping("/notification/recipients/{recipientId}")
    @ResponseBody
    public ResultVO getNotificationRecipient(@PathVariable("recipientId") Long recipientId) {
        ResultVO result = new ResultVO();
        NotificationRecipient recipient = notificationRecipientService.getRecipient(recipientId);
        if (recipient == null) {
            result.setCode("9999");
            result.setMessage("수신자 정보를 찾을 수 없습니다.");
            return result;
        }
        result.setData(recipient);
        return result;
    }

    /* 알림톡 수신자 저장 */
    @PreAuthorize("hasAnyAuthority('ATH100')")
    @PostMapping("/notification/recipients/save")
    @ResponseBody
    public ResultVO saveNotificationRecipient(@RequestParam Map<String, Object> params,
                                              @AuthenticationPrincipal UserCustom loginUser) {
        return notificationRecipientService.saveRecipient(params, loginUser);
    }

    /* 알림톡 수신자 삭제 */
    @PreAuthorize("hasAnyAuthority('ATH100')")
    @PostMapping("/notification/recipients/delete")
    @ResponseBody
    public ResultVO deleteNotificationRecipient(@RequestParam("recipientId") Long recipientId,
                                                @AuthenticationPrincipal UserCustom loginUser) {
        return notificationRecipientService.deleteRecipient(recipientId, loginUser);
    }

    @PreAuthorize("hasAnyAuthority('ATH100')")
    @GetMapping("/notification/template/{notificationType}")
    @ResponseBody
    public ResultVO getNotificationTemplateSetting(@PathVariable("notificationType") String notificationType) {
        ResultVO result = new ResultVO();
        result.setData(notificationRecipientService.getTemplateSetting(notificationType));
        return result;
    }

    @PreAuthorize("hasAnyAuthority('ATH100')")
    @PostMapping("/notification/template/save")
    @ResponseBody
    public ResultVO saveNotificationTemplateSetting(@RequestParam Map<String, Object> params,
                                                    @AuthenticationPrincipal UserCustom loginUser) {
        return notificationRecipientService.saveTemplateSetting(params, loginUser);
    }

    /**
     * 관리자 목록 조회
     */
    @GetMapping("/user/data")
    @ResponseBody
    public Map<String, Object> getAdminUserListData(@RequestParam Map<String, Object> params,
                                                    @AuthenticationPrincipal UserCustom loginUser) {
        return adminUserService.getAdminUserListData(params, loginUser);
    }

    /* 아이디 중복체크  */
    @RequestMapping("/checkUserId")
    @ResponseBody
    public ResultVO checkUserId(HttpServletRequest req, @RequestParam Map<String, Object> params) {

        ResultVO result = new ResultVO();
        String userId = params.get("insUserId") == null ? "" : params.get("insUserId").toString();

        int checkUserId = adminUserService.chkUserId(userId);

        if (checkUserId > 0) {
            result.setCode("9999");
            result.setMessage("이미 사용중인 아이디입니다.");
        }
        return result;
    }

    /* 직원등록  */
    @PreAuthorize("hasAnyAuthority('ATH100')")
    @RequestMapping("/insertAdminUser")
    @ResponseBody
    public ResultVO insertAdminUser(HttpServletRequest req
            , @AuthenticationPrincipal UserCustom loginUser
            , @RequestParam Map<String, Object> params
            , @RequestParam(value = "userRole", required = false) List<String> userRoleList) {

        ResultVO result = new ResultVO();
        String ipAddr = Utils.getClientIpAddress(req);
        String userId = loginUser.getUserId() == null ? "" : loginUser.getUserId();

        try {
            params.put("userId", userId);
            params.put("ipAddr", ipAddr);
            params.put("userRoleList", userRoleList);

            log.debug("[insertAdminUser] " + params);
            result = adminUserService.insertAdminUser(params);

        } catch (Exception e) {
            log.error("insertAdminUser 오류", e);
            result.setCode("9999");
            result.setMessage("저장 중 오류가 발생했습니다.");
        }
        return result;
    }

    /* 아이디로 관리자정보 조회 */
    @PreAuthorize("hasAnyAuthority('ATH100', 'ATH200')")
    @GetMapping("/user/detail/{userId}")
    @ResponseBody
    public ResultVO getAdminUserByUserId(@PathVariable("userId") String userId) {
        ResultVO result = new ResultVO();

        if (userId == null || userId.trim().isEmpty()) {
            result.setCode("9999");
            result.setMessage("아이디가 누락되었습니다.");
            return result;
        }

        AdminUser user = new AdminUser();
        user.setUserId(userId);
        user = adminUserService.getAdminUser(user);

        if (user == null) {
            result.setCode("9999");
            result.setMessage("정보를 찾을 수 없습니다.");
            return result;
        }

        result.setData(user);
        return result;
    }

    /* 직원수정 */
    @PreAuthorize("hasAnyAuthority('ATH100', 'ATH200')")
    @RequestMapping("/updateAdminUser")
    @ResponseBody
    public ResultVO updateAdminUser(HttpServletRequest req
            , @AuthenticationPrincipal UserCustom loginUser
            , @RequestParam Map<String, Object> params) {

        ResultVO result = new ResultVO();
        String ipAddr = Utils.getClientIpAddress(req);

        try {
            params.put("userId", loginUser.getUserId());
            params.put("ipAddr", ipAddr);

            log.debug("[updateAdminUser] " + params);
            result = adminUserService.updateAdminUser(params);

        } catch (Exception e) {
            log.error("updateAdminUser 오류", e);
            result.setCode("9999");
            result.setMessage("저장 중 오류가 발생했습니다.");
        }
        return result;
    }

    /* 직원삭제 */
    @PreAuthorize("hasAnyAuthority('ATH100', 'ATH200')")
    @RequestMapping("/deleteAdminUser")
    @ResponseBody
    public ResultVO deleteAdminUser(HttpServletRequest req
            , @AuthenticationPrincipal UserCustom loginUser
            , @RequestParam Map<String, Object> params) {

        ResultVO result = new ResultVO();
        String ipAddr = Utils.getClientIpAddress(req);

        try {
            params.put("userId", loginUser.getUserId());
            params.put("ipAddr", ipAddr);

            log.debug("[deleteAdminUser] " + params);
            result = adminUserService.deleteAdminUser(params);

        } catch (Exception e) {
            log.error("deleteAdminUser 오류", e);
            result.setCode("9999");
            result.setMessage("삭제 중 오류가 발생했습니다.");
        }
        return result;
    }

    @RequestMapping(value = "/mypage")
    public String mypage(Model model, HttpServletRequest req) {
        return "/admin/mypage";
    }

}
