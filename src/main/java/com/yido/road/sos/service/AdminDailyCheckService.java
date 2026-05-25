package com.yido.road.sos.service;

import com.yido.road.sos.model.DailyCheckLog;
import com.yido.road.sos.repository.main.DailyCheckLogMapper;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AdminDailyCheckService {
    private final DailyCheckLogMapper dailyCheckLogMapper;

    public Map<String, Object> getDailyCheckListData(Map<String, Object> params) {
        Map<String, Object> searchParams = new HashMap<>();
        String startDate = Utils.getParam(params, "startDate");
        String endDate = Utils.getParam(params, "endDate");
        String siteCd = Utils.getParam(params, "siteCd");
        String keyword = Utils.getParam(params, "keyword");

        if (startDate.isEmpty() && endDate.isEmpty()) {
            String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
            startDate = today;
            endDate = today;
        }

        int page = parseInt(params.get("page"), 1);
        int pageSize = 10;
        int offset = (page - 1) * pageSize;

        searchParams.put("startDate", startDate);
        searchParams.put("endDate", endDate);
        searchParams.put("siteCd", siteCd);
        searchParams.put("keyword", keyword);
        searchParams.put("offset", offset);
        searchParams.put("pageSize", pageSize);

        List<DailyCheckLog> list = dailyCheckLogMapper.selectDailyCheckLogList(searchParams);
        int totalCount = dailyCheckLogMapper.selectDailyCheckLogCount(searchParams);

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

    public DailyCheckLog getDailyCheckDetail(Long checkId) {
        DailyCheckLog detail = dailyCheckLogMapper.selectDailyCheckLog(checkId);
        if (detail != null) {
            detail.setItems(dailyCheckLogMapper.selectDailyCheckLogItemList(checkId));
        }
        return detail;
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
}
