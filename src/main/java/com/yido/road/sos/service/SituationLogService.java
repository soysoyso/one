package com.yido.road.sos.service;

import com.yido.road.sos.model.SituationLog;
import com.yido.road.sos.repository.main.SituationLogMapper;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.util.ResultVO;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SituationLogService {
    private final SituationLogMapper situationLogMapper;

    public Map<String, Object> getSituationLogListData(Map<String, Object> params) {
        Map<String, Object> searchParams = new HashMap<>();
        String startDate = Utils.getParam(params, "startDate");
        String endDate = Utils.getParam(params, "endDate");
        String shiftCd = Utils.getParam(params, "shiftCd");
        String siteCd = Utils.getParam(params, "siteCd");
        String useYn = Utils.getParam(params, "useYn");
        String keyword = Utils.getParam(params, "keyword");

        if (startDate.isEmpty() && endDate.isEmpty()) {
            String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
            startDate = today;
            endDate = today;
        }
        if (useYn.isEmpty()) {
            useYn = "Y";
        }

        int page = parseInt(params.get("page"), 1);
        int pageSize = 10;
        int offset = (page - 1) * pageSize;

        searchParams.put("startDate", startDate);
        searchParams.put("endDate", endDate);
        searchParams.put("shiftCd", shiftCd);
        searchParams.put("siteCd", siteCd);
        searchParams.put("useYn", useYn);
        searchParams.put("keyword", keyword);
        searchParams.put("offset", offset);
        searchParams.put("pageSize", pageSize);

        List<SituationLog> list = situationLogMapper.selectSituationLogList(searchParams);
        int totalCount = situationLogMapper.selectSituationLogCount(searchParams);

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

    public SituationLog getSituationLog(Long situationId) {
        return situationLogMapper.selectSituationLog(situationId);
    }

    @Transactional
    public ResultVO saveSituationLog(Map<String, Object> params, UserCustom loginUser) {
        ResultVO result = validate(params);
        if (!"0000".equals(result.getCode())) {
            return result;
        }

        SituationLog log = toSituationLog(params);
        String userId = loginUser == null ? "system" : loginUser.getUserId();
        Long situationId = parseLong(params.get("situationId"));
        log.setSituationId(situationId);

        if (situationId == null) {
            log.setRegId(userId);
            situationLogMapper.insertSituationLog(log);
            result.setMessage("상황일지가 등록되었습니다.");
        } else {
            log.setUpdId(userId);
            situationLogMapper.updateSituationLog(log);
            result.setMessage("상황일지가 수정되었습니다.");
        }

        result.setData(log);
        return result;
    }

    @Transactional
    public ResultVO deleteSituationLog(Long situationId, UserCustom loginUser) {
        ResultVO result = new ResultVO();
        if (situationId == null) {
            result.setCode("9999");
            result.setMessage("삭제할 상황일지를 선택하세요.");
            return result;
        }

        SituationLog log = new SituationLog();
        log.setSituationId(situationId);
        log.setUpdId(loginUser == null ? "system" : loginUser.getUserId());
        situationLogMapper.deleteSituationLog(log);
        result.setMessage("상황일지가 삭제되었습니다.");
        return result;
    }

    private ResultVO validate(Map<String, Object> params) {
        ResultVO result = new ResultVO();
        String logDate = Utils.getParam(params, "logDate");
        String shiftCd = Utils.getParam(params, "shiftCd");
        String eventTime = Utils.getParam(params, "eventTime");
        String content = Utils.getParam(params, "content");

        if (logDate.isEmpty() || !Utils.isDate(logDate, "yyyy-MM-dd")) {
            result.setCode("9999");
            result.setMessage("상황 일자를 입력하세요.");
            return result;
        }
        if (shiftCd.isEmpty()) {
            result.setCode("9999");
            result.setMessage("주/야간 구분을 선택하세요.");
            return result;
        }
        if (eventTime.isEmpty() || !Utils.isDate(eventTime, "HH:mm")) {
            result.setCode("9999");
            result.setMessage("상황 시간을 입력하세요.");
            return result;
        }
        if (content.isEmpty()) {
            result.setCode("9999");
            result.setMessage("상황 내용을 입력하세요.");
        }
        return result;
    }

    private SituationLog toSituationLog(Map<String, Object> params) {
        SituationLog log = new SituationLog();
        log.setLogDate(Utils.getParam(params, "logDate"));
        log.setShiftCd(Utils.getParam(params, "shiftCd"));
        log.setEventTime(Utils.getParam(params, "eventTime"));
        log.setTitle(Utils.getParam(params, "title"));
        log.setContent(Utils.getParam(params, "content"));
        log.setSiteCd(Utils.getParam(params, "siteCd"));
        String useYn = Utils.getParam(params, "useYn");
        log.setUseYn(useYn.isEmpty() ? "Y" : useYn);
        return log;
    }

    private int parseInt(Object value, int defaultValue) {
        if (value == null || value.toString().trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.toString().trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private Long parseLong(Object value) {
        if (value == null || value.toString().trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(value.toString().trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
