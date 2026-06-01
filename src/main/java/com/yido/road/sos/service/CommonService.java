package com.yido.road.sos.service;

import com.yido.road.sos.enums.SmsTemplateCode;
import com.yido.road.sos.model.CdCommon;
import com.yido.road.sos.model.NotificationRecipient;
import com.yido.road.sos.model.NotificationTemplateSetting;
import com.yido.road.sos.model.Pothole;
import com.yido.road.sos.repository.main.CommonMapper;
import com.yido.road.sos.repository.main.NotificationRecipientMapper;
import com.yido.road.sos.repository.main.PotholeMapper;
import com.yido.road.sos.repository.yido.SmsSendMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class CommonService {
    @Autowired
    private CommonMapper commonMapper;
    @Autowired
    private SmsSendMapper smsSendMapper;
    @Autowired
    private PotholeMapper potholeMapper;
    @Autowired
    private NotificationRecipientMapper notificationRecipientMapper;

    @Value("${notification.send.local-stub:false}")
    private boolean notificationSendLocalStub;

    public CdCommon getCommonCode(CdCommon cdCommon) {
        return commonMapper.getCommonCode(cdCommon);
    }

    public List<CdCommon> getCommonCodeList(CdCommon cdCommon) {
        return commonMapper.getCommonCodeList(cdCommon);
    }

    public List<CdCommon> selectCommonList(Map<String, Object> params) {
        return commonMapper.selectCommonList(params);
    }

    public List<CdCommon> getRoadDirListBySiteCd(String siteCd) {
        Map<String, Object> params = new HashMap<>();
        params.put("siteCd", siteCd);
        return commonMapper.selectRoadDirList(params);
    }

    public void sendSmsAfterCommit(String reportNo, SmsTemplateCode tpl, String bizDivCd) {
        if (isBlank(reportNo) || tpl == null) {
            return;
        }
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    try {
                        sendSmsToUsers(reportNo, tpl, bizDivCd);
                    } catch (Exception e) {
                        log.error("[알림톡 발송 실패] reportNo={}, tpl={}", reportNo, tpl, e);
                    }
                }
            });
            return;
        }
        try {
            sendSmsToUsers(reportNo, tpl, bizDivCd);
        } catch (Exception e) {
            log.error("[알림톡 발송 실패] reportNo={}, tpl={}", reportNo, tpl, e);
        }
    }

    private void sendSmsToUsers(String reportNo, SmsTemplateCode tpl, String bizDivCd) throws Exception {
        Pothole pothole = potholeMapper.selectPotholeByReportNo(reportNo);
        if (pothole == null) {
            log.warn("[알림톡 발송 제외] 접수 정보를 찾을 수 없습니다. reportNo={}", reportNo);
            return;
        }

        String smsSiteCd = pothole.getSiteCd();
        Map<String, Object> siteParam = new HashMap<>();
        siteParam.put("siteCd", pothole.getSiteCd());
        String parentSiteCd = potholeMapper.selectParentSiteCd(siteParam);
        if (!isBlank(parentSiteCd)) {
            smsSiteCd = parentSiteCd;
        }

        if (notificationSendLocalStub) {
            sendLocalNotificationStub(reportNo, tpl, smsSiteCd, pothole);
            return;
        }

        String notificationType = resolveNotificationType(tpl);
        Map<String, Object> params = new HashMap<>();
        params.put("notificationType", notificationType);
        params.put("siteCd", smsSiteCd);

        NotificationTemplateSetting templateSetting = notificationRecipientMapper.selectNotificationTemplateSetting(notificationType);
        List<NotificationRecipient> recipients = notificationRecipientMapper.selectActiveRecipientsForSend(params);
        if (recipients == null || recipients.isEmpty()) {
            log.info("[알림톡 발송 대상 없음] reportNo={}, notificationType={}, siteCd={}", reportNo, notificationType, smsSiteCd);
            return;
        }

        LocalDateTime targetDt = pothole.getReportDate();
        String dateLabel = "접수일";
        String timeLabel = "접수시간";
        if (tpl == SmsTemplateCode.WORK_PROGRESS) {
            targetDt = pothole.getWorkStartAt();
            dateLabel = "시작일";
            timeLabel = "시작시간";
        } else if (tpl == SmsTemplateCode.WORK_COMPLETE) {
            targetDt = pothole.getWorkEndAt();
            dateLabel = "완료일";
            timeLabel = "완료시간";
        }
        if (targetDt == null) {
            targetDt = pothole.getReportDate();
        }

        String dateStr = targetDt == null ? "-" : String.valueOf(targetDt.toLocalDate());
        String timeStr = targetDt == null ? "-" : String.valueOf(targetDt.toLocalTime()).substring(0, 5);
        String templateCode = templateSetting != null && !isBlank(templateSetting.getTemplateCode())
                ? templateSetting.getTemplateCode()
                : tpl.getCode();
        String templateTitle = templateSetting != null && !isBlank(templateSetting.getTemplateTitle())
                ? templateSetting.getTemplateTitle()
                : "[고속도로]";

        for (NotificationRecipient recipient : recipients) {
            String cellPhone = recipient.getPhoneNo();
            if (isBlank(cellPhone) || "null".equalsIgnoreCase(cellPhone.trim())) {
                log.debug("[알림톡 발송 제외] 휴대폰 번호 없음 - userId={}", recipient.getUserId());
                continue;
            }

            String msg =
                    nvl(pothole.getSiteName()) + " 작업이 " + tpl.getDesc() + " 되었습니다.\n\n" +
                    "유형: " + nvl(pothole.getReceiptGbNm()) + "\n\n" +
                    dateLabel + ": " + dateStr + "\n\n" +
                    timeLabel + ": " + timeStr + "\n\n" +
                    "위치: " + nvl(pothole.getAddr()) + "\n\n" +
                    "STA: " + nvl(pothole.getStaText()) + "\n\n" +
                    "방향: " + nvl(pothole.getDirectionNm()) + "\n\n" +
                    "접수번호: " + nvl(pothole.getReportNo());

            Map<String, Object> payload = new HashMap<>();
            payload.put("msg", msg);
            payload.put("title", templateTitle);
            payload.put("cellPhone", cellPhone.replaceAll("-", ""));
            payload.put("tplCode", templateCode);
            smsSendMapper.sendSms(payload);
        }
    }

    private void sendLocalNotificationStub(String reportNo, SmsTemplateCode tpl, String siteCd, Pothole pothole) {
        String notificationType = resolveNotificationType(tpl);
        Map<String, Object> params = new HashMap<>();
        params.put("notificationType", notificationType);
        params.put("siteCd", siteCd);

        List<NotificationRecipient> recipients = notificationRecipientMapper.selectActiveRecipientsForSend(params);
        if (recipients == null || recipients.isEmpty()) {
            log.info("[로컬 알림톡 스텁] 발송 대상 없음 reportNo={} notificationType={} siteCd={}", reportNo, notificationType, siteCd);
            return;
        }

        for (NotificationRecipient recipient : recipients) {
            log.info("[로컬 알림톡 스텁] reportNo={} notificationType={} template={} recipient={} phone={} siteCd={} message={}",
                    reportNo,
                    notificationType,
                    tpl.name(),
                    nvl(recipient.getRecipientNm()),
                    nvl(recipient.getPhoneNo()),
                    nvl(recipient.getSiteCd()),
                    buildSmsPreviewMessage(pothole, tpl));
        }
    }

    private String resolveNotificationType(SmsTemplateCode tpl) {
        if (tpl == SmsTemplateCode.WORK_COMPLETE) {
            return "POTHOLE_COMPLETE";
        }
        return "POTHOLE_RECEIPT";
    }

    private String buildSmsPreviewMessage(Pothole pothole, SmsTemplateCode tpl) {
        return nvl(pothole.getSiteName()) + " 작업이 " + tpl.getDesc() + " 되었습니다. 접수번호: " + nvl(pothole.getReportNo());
    }

    private String nvl(String str) {
        return str == null ? "-" : str;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    public SmsTemplateCode getTplByStatus(String statusCd) {
        if ("WORKING".equals(statusCd)) {
            return SmsTemplateCode.WORK_PROGRESS;
        }
        if ("DONE".equals(statusCd)) {
            return SmsTemplateCode.WORK_COMPLETE;
        }
        if ("HOLD".equals(statusCd)) {
            return SmsTemplateCode.WORK_HOLD;
        }
        return SmsTemplateCode.WORK_START;
    }

    public List<CdCommon> codes(String division) {
        CdCommon c = new CdCommon();
        c.setCdDiv(division);
        return this.getCommonCodeList(c);
    }
}
