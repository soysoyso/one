package com.yido.road.sos.service;

import com.yido.road.sos.model.NotificationRecipient;
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

    public Map<String, Object> getRecipientListData(Map<String, Object> params) {
        Map<String, Object> searchParams = new HashMap<>();
        String keyword = Utils.getParam(params, "keyword");
        String notificationType = Utils.getParam(params, "notificationType");
        String siteCd = Utils.getParam(params, "siteCd");
        String useYn = Utils.getParam(params, "useYn");

        int page = parseInt(params.get("page"), 1);
        int pageSize = 10;
        int offset = (page - 1) * pageSize;

        searchParams.put("offset", offset);
        searchParams.put("pageSize", pageSize);
        searchParams.put("keyword", keyword);
        searchParams.put("notificationType", notificationType);
        searchParams.put("siteCd", siteCd);
        searchParams.put("useYn", useYn);

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

    @Transactional
    public ResultVO saveRecipient(Map<String, Object> params, UserCustom loginUser) {
        ResultVO result = new ResultVO();
        NotificationRecipient recipient = toRecipient(params);

        if (isBlank(recipient.getNotificationType())) {
            result.setCode("9999");
            result.setMessage("알림 유형을 선택해주세요.");
            return result;
        }
        if (isBlank(recipient.getRecipientNm())) {
            result.setCode("9999");
            result.setMessage("수신자명을 입력해주세요.");
            return result;
        }
        if (isBlank(recipient.getPhoneNo())) {
            result.setCode("9999");
            result.setMessage("휴대폰 번호를 입력해주세요.");
            return result;
        }

        String userId = loginUser == null ? "" : loginUser.getUserId();
        if (recipient.getRecipientId() == null) {
            recipient.setRegId(userId);
            notificationRecipientMapper.insertNotificationRecipient(recipient);
        } else {
            recipient.setUpdId(userId);
            notificationRecipientMapper.updateNotificationRecipient(recipient);
        }

        result.setData(recipient);
        return result;
    }

    @Transactional
    public ResultVO deleteRecipient(Long recipientId, UserCustom loginUser) {
        ResultVO result = new ResultVO();
        if (recipientId == null) {
            result.setCode("9999");
            result.setMessage("삭제할 수신자 정보가 없습니다.");
            return result;
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
