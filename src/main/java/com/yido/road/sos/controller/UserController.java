package com.yido.road.sos.controller;

import com.yido.road.sos.component.storage.S3StorageService;
import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.model.Pothole;
import com.yido.road.sos.model.PotholeDraftDto;
import com.yido.road.sos.model.PotholeImage;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Slf4j
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * 정보수정
     *
     * @param req
     * @param userId
     * @param userNm
     * @param currentPassword
     * @param password
     * @param userTel
     * @param userMail
     * @return
     */
    @PostMapping("/personalInfoSave")
    @ResponseBody
    public Map<String, Object> personalInfoSave(HttpServletRequest req,
                                                @RequestParam("userId") String userId,
                                                @RequestParam(value="userNm", required=false) String userNm,
                                                @RequestParam(value="currentPassword", required=false) String currentPassword,
                                                @RequestParam(value="password", required=false) String password,
                                                @RequestParam(value="userTel", required=false) String userTel,
                                                @RequestParam(value="userMail", required=false) String userMail) {

        Map<String, Object> res = new HashMap<>();

        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            UserCustom me = (UserCustom) auth.getPrincipal();

            String loginUserId = me.getUserId() != null ? me.getUserId().trim() : "";
            String reqUserId = userId != null ? userId.trim() : "";

            if (!loginUserId.equals(reqUserId)) {
                res.put("result", false);
                res.put("message", "본인 정보만 수정할 수 있습니다.");
                return res;
            }

            userService.updateMyPage(userId, userNm, currentPassword, password, userTel, userMail, userId);

            // 세션/principal 값 갱신
            me.setUserName(userNm);
            me.setUserTel(userTel);
            me.setUserMail(userMail);

            req.getSession().setAttribute("session", me);

            res.put("result", true);
            res.put("message", "OK");

        } catch (IllegalArgumentException e) {
            res.put("result", false);
            res.put("message", e.getMessage());
        } catch (Exception e) {
            log.error("개인정보 수정 오류", e);
            res.put("result", false);
            res.put("message", "저장 중 오류가 발생했습니다.");
        }

        return res;
    }
}

