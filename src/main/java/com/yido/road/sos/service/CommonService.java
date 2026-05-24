package com.yido.road.sos.service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.yido.road.sos.enums.SmsTemplateCode;
import com.yido.road.sos.model.CdCommon;
import com.yido.road.sos.model.Pothole;
import com.yido.road.sos.repository.main.AdminUserMapper;
import com.yido.road.sos.repository.main.CommonMapper;
import com.yido.road.sos.repository.main.PotholeMapper;
import com.yido.road.sos.repository.yido.SmsSendMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;


@Service
@Slf4j
public class CommonService {
	
	@Autowired
	private CommonMapper commonMapper;
    @Autowired
    private SmsSendMapper smsSendMapper;
    @Autowired
    private AdminUserMapper adminUserMapper;
    @Autowired
    private PotholeMapper potholeMapper;

    public CdCommon getCommonCode(CdCommon cdCommon) {
    	return commonMapper.getCommonCode(cdCommon);
    }

    public List<CdCommon> getCommonCodeList(CdCommon cdCommon) {
    	return commonMapper.getCommonCodeList(cdCommon);
    }

    public List<CdCommon> selectCommonList(Map<String, Object> params) {
        return commonMapper.selectCommonList(params);
    }

    /* 사이트코드 기준으로 도로 방향(공통코드) 목록 조회 */
    public List<CdCommon> getRoadDirListBySiteCd(String siteCd) {
        if (siteCd == null || "".equals(siteCd)) {
            return java.util.Collections.emptyList();
        }

        Map<String, Object> param = new HashMap<>();
        param.put("cdDiv", "ROAD_DIR");
        param.put("siteCd", siteCd);

        return commonMapper.selectRoadDirList(param);
    }

    /**
     * DB 트랜잭션 커밋 이후에만 SMS 발송 (롤백 시 문자 발송 방지)
     */
    public void sendSmsAfterCommit(String reportNo, SmsTemplateCode tpl, String bizDivCd) {
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                try {
                    sendSmsToUsers(reportNo, tpl, bizDivCd);
                } catch (Exception e) {
                    log.error("SMS 실패 reportNo={}", reportNo, e);
                }
            }
        });
    }

    /**
     * 접수번호 기준으로 대상자 조회 후 SMS 일괄 발송
     */
    private void sendSmsToUsers(String reportNo, SmsTemplateCode tpl, String bizDivCd) throws Exception {

        StringBuilder sb = new StringBuilder();
        Pothole pothole = potholeMapper.selectPotholeByReportNo(reportNo);

        log.debug("[sendSmsToUsers] pothole:{}", pothole);

        Map<String, Object> param = new HashMap<>();
        //param.put("siteCd", pothole.getSiteCd());

        String smsSiteCd = pothole.getSiteCd();

        Map<String, Object> siteParam = new HashMap<>();
        siteParam.put("siteCd", pothole.getSiteCd());

        String parentSiteCd = potholeMapper.selectParentSiteCd(siteParam);

        if (parentSiteCd != null && !"".equals(parentSiteCd.trim())) {
            smsSiteCd = parentSiteCd;
        }

        param.put("siteCd", smsSiteCd);

        if (!"ALL".equals(bizDivCd)) {
            param.put("bizDivCd", bizDivCd);
        }

        List<Map<String, Object>> users = adminUserMapper.selectUsersBySiteAndBiz(param);

        if (users == null || users.isEmpty()) {
            return;
        }

        for (Map<String, Object> user : users) {
            String userId = (String) user.get("userId");
            if (userId != null && !"".equals(userId)) {
                if (sb.length() > 0) sb.append(",");
                sb.append(userId);
            }
        }

        log.debug("[고속도로 운영관리 SMS 대상자] {}", sb.toString());

        // 상태별 기준 일시 / 라벨명
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
        } else if (tpl == SmsTemplateCode.WORK_HOLD) {
            targetDt = pothole.getReportDate();
            dateLabel = "접수일";
            timeLabel = "접수시간";
        } else {
            targetDt = pothole.getReportDate();
            dateLabel = "접수일";
            timeLabel = "접수시간";
        }

        // null 방어
        if (targetDt == null) {
            targetDt = pothole.getReportDate();
        }

        String dateStr = "-";
        String timeStr = "-";

        if (targetDt != null) {
            dateStr = String.valueOf(targetDt.toLocalDate());
            timeStr = String.valueOf(targetDt.toLocalTime()).substring(0, 5);
        }

        for (Map<String, Object> user : users) {

            String cellPhone = (String) user.get("cellPhone");

            if (cellPhone == null
                    || "".equals(cellPhone.trim())
                    || "null".equalsIgnoreCase(cellPhone.trim())) {
                log.debug("[고속도로 운영관리 SMS발송] 핸드폰번호 없음 - [아이디: {}]", user.get("userId"));
                continue;
            }

            String msg =
                    pothole.getSiteName() + " 작업이 " + tpl.getDesc() + " 되었습니다.\n\n" +
                            "▷유형: " + nvl(pothole.getReceiptGbNm()) + "\n\n" +
                            "▷" + dateLabel + ": " + dateStr + "\n\n" +
                            "▷" + timeLabel + ": " + timeStr + "\n\n" +
                            "▷위치: " + nvl(pothole.getAddr()) + "\n\n" +
                            "▷STA: " + nvl(pothole.getStaText()) + "\n\n" +
                            "▷방향: " + nvl(pothole.getDirectionNm()) + "\n\n" +
                            "▷추가: - " + "\n\n" +
                            "▼ 현장 이미지 및 상세 정보 확인\n" +
                            "https://sos.yido.com/pothole/detail/" + pothole.getReportNo();

            Map<String, Object> p = new HashMap<>();
            p.put("msg", msg);
            p.put("title", "[고속도로]");
            p.put("cellPhone", cellPhone.replaceAll("-", ""));
            p.put("tplCode", tpl.getCode());

            log.debug("[고속도로 운영관리 SMS발송] {}", p);
            smsSendMapper.sendSms(p);
        }

        log.debug("[고속도로 운영관리 SMS 대상자] {}", sb.toString());
    }

    private String nvl(String str) {
        return str == null ? "-" : str;
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

        return SmsTemplateCode.WORK_START; // 기본값
    }


    public List<CdCommon> codes(String division) {
        CdCommon c = new CdCommon();
        c.setCdDiv(division);
        return this.getCommonCodeList(c);
    }

}
