package com.yido.road.sos.service;

import com.yido.road.sos.enums.SmsTemplateCode;
import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.model.Pothole;
import com.yido.road.sos.model.SiteInfo;
import com.yido.road.sos.repository.main.AdminUserMapper;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.util.ResultVO;
import com.yido.road.sos.util.Utils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Service
@Slf4j
public class AdminUserService {

    @Autowired
    public AdminUserMapper adminUserMapper;
    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private SiteInfoService siteInfoService;

    public String encodePassword(String password) {
        return passwordEncoder.encode(password);
    }

    public AdminUser getAdminUser(AdminUser adminUser) {
        return adminUserMapper.selectAdminUser(adminUser);
    }

    /* 관리자 내역 */
    public List<AdminUser> selectAdminUserList(Map<String, Object> params) {
        return adminUserMapper.selectAdminUserList(params);
    }

    // 관리자 목록 조회 (검색조건 및 로그인 사용자 관리대상 고속도로 기준 필터링)
    public Map<String, Object> getAdminUserListData(Map<String, Object> params, UserCustom loginUser) {

        log.debug("[getAdminUserListData] params : {}", params);

        Map<String, Object> searchParams = new HashMap<>();

        String searchCompany = params.get("searchCompany") != null ? params.get("searchCompany").toString().trim() : "";
        String searchUserName = params.get("searchUserName") != null ? params.get("searchUserName").toString().trim() : "";
        String searchRole = params.get("searchRole") != null ? params.get("searchRole").toString().trim() : "";
        String searchSiteCd = params.get("searchSiteCd") != null ? params.get("searchSiteCd").toString().trim() : "";
        String searchKeyword = params.get("searchKeyword") != null ? params.get("searchKeyword").toString().trim() : "";

        int page = Integer.parseInt(params.getOrDefault("page", "1").toString());
        int pageSize = 10;
        int offset = (page - 1) * pageSize;

        searchParams.put("offset", offset);
        searchParams.put("pageSize", pageSize);

        if (!searchCompany.isEmpty()) {
            searchParams.put("searchCompany", searchCompany);
        }

        if (!searchUserName.isEmpty()) {
            searchParams.put("searchUserName", searchUserName);
        }

        if (!searchRole.isEmpty()) {
            searchParams.put("searchRole", searchRole);
        }
        if (!searchKeyword.isEmpty()) {
            searchParams.put("searchKeyword", searchKeyword);
        }
        // 화면에서 특정 고속도로를 선택한 경우 우선 적용
        if (!searchSiteCd.isEmpty()) {
            searchParams.put("searchSiteCd", searchSiteCd);
        } else {
            List<String> siteCdList = Utils.parseSiteCdList(loginUser != null ? loginUser.getSiteCdList() : null);

            // 로그인 사용자 관리대상 고속도로가 있으면 그 범위만 조회
            if (!siteCdList.isEmpty()) {
                searchParams.put("siteCdList", siteCdList);
            }
        }

        log.debug("[getAdminUserListData] searchParams : {}", searchParams);

        // 조회
        List<AdminUser> list = adminUserMapper.selectAdminUserList(searchParams);
        int totalCount = adminUserMapper.selectAdminUserCount(searchParams);

        SiteInfo siteInfo = new SiteInfo();
        Map<String, String> siteMap = siteInfoService.getCodeMap(siteInfo);

        // 각 사용자 객체에 고속도로명 세팅
        for (AdminUser user : list) {
            String managedCodes = user.getSiteCdList();
            if (managedCodes != null && !managedCodes.trim().isEmpty()) {
                String[] codes = managedCodes.split(",");
                List<String> names = new ArrayList<>();

                for (String code : codes) {
                    String name = siteMap.get(code.trim());
                    if (name != null) {
                        names.add(name);
                    }
                }

                user.setSiteCdListNm(String.join(", ", names));
            }
        }

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

    // 로그인 사용자의 관리대상 고속도로 목록 조회 (없으면 전체 반환)
    public List<SiteInfo> getAvailableSiteList(UserCustom loginUser) {

        List<SiteInfo> siteList = new ArrayList<>();

        if (loginUser == null || loginUser.getUserId() == null || loginUser.getUserId().trim().isEmpty()) {
            return siteInfoService.selectSiteList(new SiteInfo());
        }

        String userId = loginUser.getUserId();
        List<SiteInfo> manageSiteList = siteInfoService.getManageSiteByUserId(userId);

        if (manageSiteList != null && !manageSiteList.isEmpty()) {
            siteList = manageSiteList;
        } else {
            siteList = siteInfoService.selectSiteList2(new SiteInfo());
        }

        return siteList;
    }

    public List<AdminUser> selectPotholeAssigneeUsersBySiteCd(String siteCd, String userAuth) {

        Map<String, Object> param = new HashMap<String, Object>();
        param.put("siteCd", siteCd);
        /*
        if (userAuth != null && !"".equals(userAuth)) {
            param.put("userAuth", userAuth);
        }*/

        return adminUserMapper.selectPotholeAssigneeUsersBySiteCd(param);
    }

    /* 관리자 내역 건수 */
    public int selectAdminUserCount(Map<String, Object> params) {
        return adminUserMapper.selectAdminUserCount(params);
    }

    /* 아이디로 중복 여부 확인 */
    public int chkUserId(String userId) {
        return adminUserMapper.chkUserId(userId);
    }

    /* 관리자 등록 */
    @Transactional
    public ResultVO insertAdminUser(Map<String, Object> params) {
        ResultVO result = new ResultVO();
        AdminUser user = new AdminUser();
        String userName   = Utils.getParam(params, "insUserName");
        String userId     = Utils.getParam(params, "insUserId");
        String userPw     = Utils.getParam(params, "insUserPw");
        String siteCdList = Utils.getParam(params, "siteCodesJoined");
        String bizDivCd   = Utils.getParam(params, "bizDivCd");   // 화면 구분 (접수/처리)
        String deptCd     = Utils.getParam(params, "deptCd");     // 소속
        String userTel    = Utils.getParam(params, "userTel");
        String userMail   = Utils.getParam(params, "userMail");

        // ✅ 권한 리스트 받기
        @SuppressWarnings("unchecked")
        List<String> userRoleList = (List<String>) params.get("userRoleList");

        // ✅ 콤마로 합치기(없으면 빈값)
        String userAuth = "";
        if (userRoleList != null && userRoleList.isEmpty() == false) {
            userAuth = String.join(",", userRoleList);
        }

        if ("".equals(userAuth)) {
            result.setCode("9999");
            result.setMessage("권한을 하나 이상 선택하세요.");
            return result;
        }

        int chkUserId = adminUserMapper.chkUserId(userId);
        if (chkUserId > 0) {
            result.setCode("9999");
            result.setMessage("이미 사용중인 아이디입니다.");
            return result;
        }

        boolean hasFieldUser = userAuth.contains("ATH300"); // 현장사용자
        boolean hasGuard = userAuth.contains("ATH200");     // 현장관리자

        // 소속: 현장관리자 + 현장사용자 필수
        if (hasGuard || hasFieldUser) {
            if (deptCd == null || deptCd.trim().isEmpty()) {
                result.setCode("9999");
                result.setMessage("소속을 선택하세요.");
                return result;
            }
        } else {
            deptCd = null;
        }

        // 화면: 현장사용자만 필수
        if (hasFieldUser) {
            if (bizDivCd == null || bizDivCd.trim().isEmpty()) {
                result.setCode("9999");
                result.setMessage("현장사용자 화면을 선택하세요.");
                return result;
            }
        } else {
            bizDivCd = null;
        }

        user.setUserAuth(userAuth);
        user.setBizDivCd(bizDivCd);
        user.setDeptCd(deptCd);
        user.setBizDivCd(bizDivCd);

        user.setUserNm(userName);
        user.setUserId(userId);
        user.setUserPwd(encodePassword(userPw));
        user.setUserTel(userTel);
        user.setUserMail(userMail);
        user.setInputStaff(params.get("userId").toString());
        user.setInputIp(params.get("ipAddr").toString());

        adminUserMapper.insertAdminUser(user);
        user.setLogDiv("I");
        adminUserMapper.insertAdminUserLog(user);

        // 관리현장(기존 로직 유지)
        if ("".equals(siteCdList) == false) {
            String[] codes = siteCdList.split(",");
            Map<String, Object> map = new HashMap<>();
            map.put("userId", userId);
            for (String code : codes) {
                map.put("siteCd", code);
                adminUserMapper.insertAdminUserSite(map);
            }
        }

        return result;
    }


    @Transactional
    public ResultVO updateAdminUser(Map<String, Object> params) {

        ResultVO result = new ResultVO();

        // ===== 1) 파라미터 수집 =====
        String userAuth   = Utils.getParam(params, "userAuth");        // "ATH200,ATH300"
        String userName   = Utils.getParam(params, "insUserName");
        String userId     = Utils.getParam(params, "insUserId");
        String userPw     = Utils.getParam(params, "insUserPw");       // 빈값 가능
        String siteCdList = Utils.getParam(params, "siteCodesJoined"); // "" 이면 전체
        String bizDivCd   = Utils.getParam(params, "bizDivCd");        // 화면 구분 (접수/처리)
        String deptCd     = Utils.getParam(params, "deptCd");          // 소속
        String userTel    = Utils.getParam(params, "userTel");
        String userMail   = Utils.getParam(params, "userMail");

        // ===== 2) 기본 검증 =====
        if (userId == null || userId.trim().isEmpty()) {
            result.setCode("9999");
            result.setMessage("아이디가 누락되었습니다.");
            return result;
        }

        if (userName == null || userName.trim().isEmpty()) {
            result.setCode("9999");
            result.setMessage("이름을 입력하세요.");
            return result;
        }

        if (userAuth == null || userAuth.trim().isEmpty()) {
            result.setCode("9999");
            result.setMessage("권한을 하나 이상 선택하세요.");
            return result;
        }

        boolean hasFieldUser = userAuth.contains("ATH300"); // 현장사용자
        boolean hasGuard = userAuth.contains("ATH200");     // 현장관리자

        if (hasGuard || hasFieldUser) {
            if (deptCd == null || deptCd.trim().isEmpty()) {
                result.setCode("9999");
                result.setMessage("소속을 선택하세요.");
                return result;
            }
        } else {
            deptCd = null;
        }

        if (hasFieldUser) {
            if (bizDivCd == null || bizDivCd.trim().isEmpty()) {
                result.setCode("9999");
                result.setMessage("현장사용자 화면을 선택하세요.");
                return result;
            }
        } else {
            bizDivCd = null;
        }

        // ===== 4) 업데이트 대상 객체 구성 =====
        AdminUser user = new AdminUser();
        user.setUserId(userId);
        user.setUserNm(userName);
        user.setUserAuth(userAuth);
        user.setBizDivCd(bizDivCd);
        user.setDeptCd(deptCd);
        user.setBizDivCd(bizDivCd);
        user.setUserTel(userTel);
        user.setUserMail(userMail);

        // 수정자
        String updaterId = (params.get("userId") == null) ? "" : params.get("userId").toString();
        user.setUpdateStaff(updaterId);

        // 비밀번호: 입력했을 때만 변경 (미입력 시 null 유지)
        if (userPw != null && userPw.trim().isEmpty() == false) {
            user.setUserPwd(encodePassword(userPw.trim()));
        } else {
            user.setUserPwd(null);
        }

        log.debug("[updateAdminUser] user : " + user);

        // ===== 5) 관리자 기본정보 업데이트 =====
        adminUserMapper.updateAdminUser(user);

        // ===== 6) 로그 =====
        user.setLogDiv("U");
        user.setInputStaff(updaterId);
        adminUserMapper.insertAdminUserLog(user);

        // ===== 7) 관리대상(현장) 갱신: 전체삭제 후 재등록 =====
        adminUserMapper.deleteAdminUserSite(userId);

        // siteCdList = "" 이면 전체 컨셉(= admin_user_site insert 안함)
        if (siteCdList != null && siteCdList.trim().isEmpty() == false) {

            String[] codes = siteCdList.split(",");
            Map<String, Object> map = new HashMap<>();
            map.put("userId", userId);

            for (int i = 0; i < codes.length; i++) {
                String code = (codes[i] == null) ? "" : codes[i].trim();
                if (code.isEmpty()) continue;

                map.put("siteCd", code);
                adminUserMapper.insertAdminUserSite(map);
            }
        }

        result.setCode("0000");
        result.setMessage("수정이 완료되었습니다.");
        return result;
    }


    /* 관리자 삭제 */
    @Transactional
    public ResultVO deleteAdminUser(Map<String, Object> params) {
        ResultVO result = new ResultVO();
        AdminUser user = new AdminUser();

        String userId = Utils.getParam(params, "insUserId");

        user.setUserId(userId);
        user.setInputStaff(params.get("userId").toString());
        user.setInputIp(params.get("ipAddr").toString());

        log.debug("[deleteAdminUser] user : " + user);

        // 삭제
        adminUserMapper.deleteAdminUserSite(userId);
        adminUserMapper.deleteAdminUser(user);
        user.setLogDiv("D");
        adminUserMapper.insertAdminUserLog(user);

        return result;
    }

    /* 마지막 접수유형 조회 */
    public String selectLastReceiptGbCd(String userId) {
        return adminUserMapper.selectLastReceiptGbCd(userId);
    }
}
