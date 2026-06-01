package com.yido.road.sos.service;

import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.model.NotificationRecipient;
import com.yido.road.sos.model.NotificationTemplateSetting;
import com.yido.road.sos.repository.main.AdminUserMapper;
import com.yido.road.sos.repository.main.NotificationRecipientMapper;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.util.ResultVO;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class NotificationRecipientService {
    private final NotificationRecipientMapper notificationRecipientMapper;
    private final AdminUserMapper adminUserMapper;

    public Map<String, Object> getRecipientListData(Map<String, Object> params) {
        Map<String, Object> searchParams = new HashMap<>();
        int page = parseInt(params.get("page"), 1);
        int pageSize = parseInt(params.get("pageSize"), 10);
        if (pageSize <= 0) {
            pageSize = 10;
        }
        if (pageSize > 500) {
            pageSize = 500;
        }

        searchParams.put("offset", (page - 1) * pageSize);
        searchParams.put("pageSize", pageSize);
        searchParams.put("keyword", Utils.getParam(params, "keyword"));
        searchParams.put("notificationType", Utils.getParam(params, "notificationType"));
        searchParams.put("siteCd", Utils.getParam(params, "siteCd"));
        searchParams.put("useYn", Utils.getParam(params, "useYn"));

        List<NotificationRecipient> list = notificationRecipientMapper.selectNotificationRecipientList(searchParams);
        int totalCount = notificationRecipientMapper.selectNotificationRecipientCount(searchParams);

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

    public NotificationRecipient getRecipient(Long recipientId) {
        return notificationRecipientMapper.selectNotificationRecipient(recipientId);
    }

    public NotificationTemplateSetting getTemplateSetting(String notificationType) {
        if (isBlank(notificationType)) {
            return null;
        }
        return notificationRecipientMapper.selectNotificationTemplateSetting(notificationType);
    }

    @Transactional
    public void syncUserDefaultRecipients(AdminUser user, String actorId) {
        if (user == null || isBlank(user.getUserId()) || isBlank(user.getDeptCd()) || isBlank(user.getUserTel())) {
            return;
        }
        List<NotificationTemplateSetting> settings = notificationRecipientMapper.selectNotificationTemplateSettingsByDept(user.getDeptCd());
        if (settings == null || settings.isEmpty()) {
            return;
        }
        for (NotificationTemplateSetting setting : settings) {
            NotificationRecipient recipient = new NotificationRecipient();
            recipient.setNotificationType(setting.getNotificationType());
            recipient.setRecipientNm(user.getUserNm());
            recipient.setPhoneNo(normalizePhone(user.getUserTel()));
            recipient.setUserId(user.getUserId());
            recipient.setSiteCd("");
            recipient.setUseYn("Y");
            recipient.setSortOrd(0);
            recipient.setRemark("관리자 팀 기준 자동 배정");

            NotificationRecipient existing = notificationRecipientMapper.selectExistingNotificationRecipient(recipient);
            if (existing != null && existing.getRecipientId() != null) {
                recipient.setRecipientId(existing.getRecipientId());
                recipient.setUpdId(actorId);
                notificationRecipientMapper.updateNotificationRecipient(recipient);
            } else {
                recipient.setRegId(actorId);
                notificationRecipientMapper.insertNotificationRecipient(recipient);
            }
        }
    }

    @Transactional
    public ResultVO saveTemplateSetting(Map<String, Object> params, UserCustom loginUser) {
        ResultVO result = new ResultVO();
        NotificationTemplateSetting setting = toTemplateSetting(params);
        if (isBlank(setting.getNotificationType())) {
            return fail(result, "알림 유형을 선택하세요.");
        }
        if (isBlank(setting.getTemplateCode())) {
            return fail(result, "외부 솔루션 템플릿 코드를 입력하세요.");
        }
        if (isBlank(setting.getTemplateTitle())) {
            return fail(result, "알림톡 타이틀을 입력하세요.");
        }

        String userId = loginUser == null ? "" : loginUser.getUserId();
        NotificationTemplateSetting existing = notificationRecipientMapper.selectNotificationTemplateSetting(setting.getNotificationType());
        if (existing == null) {
            setting.setRegId(userId);
            notificationRecipientMapper.insertNotificationTemplateSetting(setting);
        } else {
            setting.setUpdId(userId);
            notificationRecipientMapper.updateNotificationTemplateSetting(setting);
        }

        if ("Y".equals(Utils.getParam(params, "autoApplyYn"))) {
            syncDefaultTeamRecipients(setting, userId);
        }

        result.setData(setting);
        return result;
    }

    @Transactional
    public ResultVO saveRecipient(Map<String, Object> params, UserCustom loginUser) {
        ResultVO result = new ResultVO();
        NotificationRecipient recipient = toRecipient(params);

        if (isBlank(recipient.getNotificationType())) {
            return fail(result, "알림 유형을 선택하세요.");
        }
        if (isBlank(recipient.getUserId())) {
            return fail(result, "관리자 사용자 목록에서 수신자를 선택하세요.");
        }
        AdminUser selectedUser = findAdminUser(recipient.getUserId());
        if (selectedUser == null) {
            return fail(result, "관리자에 등록된 사용자만 알림톡 수신자로 지정할 수 있습니다.");
        }
        if (isBlank(recipient.getRecipientNm())) {
            recipient.setRecipientNm(selectedUser.getUserNm());
        }
        if (isBlank(recipient.getPhoneNo())) {
            recipient.setPhoneNo(normalizePhone(selectedUser.getUserTel()));
        }
        if (isBlank(recipient.getPhoneNo())) {
            return fail(result, "선택한 관리자 사용자에 휴대폰 번호가 없습니다.");
        }

        String actorId = loginUser == null ? "" : loginUser.getUserId();
        if (recipient.getRecipientId() == null) {
            NotificationRecipient existing = notificationRecipientMapper.selectExistingNotificationRecipient(recipient);
            if (existing != null && existing.getRecipientId() != null) {
                recipient.setRecipientId(existing.getRecipientId());
            }
        }

        if (recipient.getRecipientId() == null) {
            recipient.setRegId(actorId);
            notificationRecipientMapper.insertNotificationRecipient(recipient);
        } else {
            recipient.setUpdId(actorId);
            notificationRecipientMapper.updateNotificationRecipient(recipient);
        }

        result.setData(recipient);
        return result;
    }

    @Transactional
    public ResultVO deleteRecipient(Long recipientId, UserCustom loginUser) {
        ResultVO result = new ResultVO();
        if (recipientId == null) {
            return fail(result, "삭제할 수신자 정보가 없습니다.");
        }

        NotificationRecipient recipient = new NotificationRecipient();
        recipient.setRecipientId(recipientId);
        recipient.setUpdId(loginUser == null ? "" : loginUser.getUserId());
        notificationRecipientMapper.deleteNotificationRecipient(recipient);
        return result;
    }

    private NotificationRecipient toRecipient(Map<String, Object> params) {
        NotificationRecipient recipient = new NotificationRecipient();
        recipient.setRecipientId(parseLong(params.get("recipientId")));
        recipient.setNotificationType(Utils.getParam(params, "notificationType"));
        recipient.setRecipientNm(Utils.getParam(params, "recipientNm"));
        recipient.setPhoneNo(normalizePhone(Utils.getParam(params, "phoneNo")));
        recipient.setUserId(Utils.getParam(params, "userId"));
        recipient.setSiteCd(Utils.getParam(params, "siteCd"));
        recipient.setUseYn(defaultValue(Utils.getParam(params, "useYn"), "Y"));
        recipient.setSortOrd(parseInt(params.get("sortOrd"), 0));
        recipient.setRemark(Utils.getParam(params, "remark"));
        return recipient;
    }

    private NotificationTemplateSetting toTemplateSetting(Map<String, Object> params) {
        NotificationTemplateSetting setting = new NotificationTemplateSetting();
        setting.setNotificationType(Utils.getParam(params, "notificationType"));
        setting.setTemplateCode(Utils.getParam(params, "templateCode"));
        setting.setTemplateTitle(Utils.getParam(params, "templateTitle"));
        setting.setDefaultDeptCds(joinMultiParam(params.get("defaultDeptCds")));
        setting.setUseYn(defaultValue(Utils.getParam(params, "useYn"), "Y"));
        setting.setRemark(Utils.getParam(params, "remark"));
        return setting;
    }

    private void syncDefaultTeamRecipients(NotificationTemplateSetting setting, String actorId) {
        if (setting == null || isBlank(setting.getDefaultDeptCds())) {
            return;
        }
        String[] deptCds = setting.getDefaultDeptCds().split(",");
        int sort = 1;
        for (String deptCd : deptCds) {
            if (isBlank(deptCd)) {
                continue;
            }
            Map<String, Object> search = new HashMap<>();
            search.put("offset", 0);
            search.put("pageSize", 500);
            search.put("searchDeptCd", deptCd.trim());
            List<AdminUser> users = adminUserMapper.selectAdminUserList(search);
            for (AdminUser user : users) {
                if (user == null || isBlank(user.getUserId()) || isBlank(user.getUserTel())) {
                    continue;
                }
                NotificationRecipient recipient = new NotificationRecipient();
                recipient.setNotificationType(setting.getNotificationType());
                recipient.setRecipientNm(user.getUserNm());
                recipient.setPhoneNo(normalizePhone(user.getUserTel()));
                recipient.setUserId(user.getUserId());
                recipient.setSiteCd("");
                recipient.setUseYn("Y");
                recipient.setSortOrd(sort++);
                recipient.setRemark("기본 매칭 팀 자동 배정");

                NotificationRecipient existing = notificationRecipientMapper.selectExistingNotificationRecipient(recipient);
                if (existing != null && existing.getRecipientId() != null) {
                    recipient.setRecipientId(existing.getRecipientId());
                    recipient.setUpdId(actorId);
                    notificationRecipientMapper.updateNotificationRecipient(recipient);
                } else {
                    recipient.setRegId(actorId);
                    notificationRecipientMapper.insertNotificationRecipient(recipient);
                }
            }
        }
    }

    private AdminUser findAdminUser(String userId) {
        if (isBlank(userId)) {
            return null;
        }
        AdminUser query = new AdminUser();
        query.setUserId(userId);
        return adminUserMapper.selectAdminUser(query);
    }

    private ResultVO fail(ResultVO result, String message) {
        result.setCode("9999");
        result.setMessage(message);
        return result;
    }

    private String joinMultiParam(Object value) {
        if (value == null) {
            return "";
        }
        if (value instanceof String[]) {
            StringBuilder sb = new StringBuilder();
            for (String item : (String[]) value) {
                if (isBlank(item)) {
                    continue;
                }
                if (sb.length() > 0) {
                    sb.append(",");
                }
                sb.append(item.trim());
            }
            return sb.toString();
        }
        return value.toString().trim();
    }

    private String normalizePhone(String phoneNo) {
        if (phoneNo == null) {
            return "";
        }
        String digits = phoneNo.replaceAll("[^0-9]", "");
        if (digits.length() == 11) {
            return digits.replaceAll("(\\d{3})(\\d{4})(\\d{4})", "$1-$2-$3");
        }
        if (digits.length() == 10) {
            return digits.replaceAll("(\\d{3})(\\d{3})(\\d{4})", "$1-$2-$3");
        }
        return phoneNo.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String defaultValue(String value, String defaultValue) {
        return isBlank(value) ? defaultValue : value;
    }

    private Long parseLong(Object value) {
        if (value == null || value.toString().trim().isEmpty()) {
            return null;
        }
        return Long.parseLong(value.toString());
    }

    private int parseInt(Object value, int defaultValue) {
        if (value == null || value.toString().trim().isEmpty()) {
            return defaultValue;
        }
        return Integer.parseInt(value.toString());
    }
}
