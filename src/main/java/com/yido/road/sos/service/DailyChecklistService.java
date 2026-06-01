package com.yido.road.sos.service;

import com.yido.road.sos.model.DailyChecklist;
import com.yido.road.sos.model.DailyChecklistItem;
import com.yido.road.sos.repository.main.DailyChecklistMapper;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.util.ResultVO;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DailyChecklistService {
    private final DailyChecklistMapper dailyChecklistMapper;

    public Map<String, Object> getChecklistListData(Map<String, Object> params) {
        Map<String, Object> searchParams = new HashMap<>();
        String keyword = Utils.getParam(params, "keyword");
        String siteCd = Utils.getParam(params, "siteCd");
        String useYn = Utils.getParam(params, "useYn");

        int page = parseInt(params.get("page"), 1);
        int pageSize = 10;
        int offset = (page - 1) * pageSize;

        searchParams.put("keyword", keyword);
        searchParams.put("siteCd", siteCd);
        searchParams.put("useYn", useYn);
        searchParams.put("offset", offset);
        searchParams.put("pageSize", pageSize);

        List<DailyChecklist> list = dailyChecklistMapper.selectDailyChecklistList(searchParams);
        int totalCount = dailyChecklistMapper.selectDailyChecklistCount(searchParams);

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

    public DailyChecklist getChecklist(Long checklistId) {
        DailyChecklist checklist = dailyChecklistMapper.selectDailyChecklist(checklistId);
        if (checklist != null) {
            checklist.setItems(dailyChecklistMapper.selectDailyChecklistItemList(checklistId));
        }
        return checklist;
    }

    @Transactional
    public ResultVO saveChecklist(Map<String, Object> params, UserCustom loginUser) {
        ResultVO result = new ResultVO();
        DailyChecklist checklist = toChecklist(params);

        if (isBlank(checklist.getChecklistName())) {
            result.setCode("9999");
            result.setMessage("체크리스트명을 입력해주세요.");
            return result;
        }

        List<DailyChecklistItem> items = toItems(params, checklist.getChecklistId());
        if (!hasValidItem(items)) {
            result.setCode("9999");
            result.setMessage("점검 항목을 1개 이상 입력해주세요.");
            return result;
        }

        String userId = loginUser == null ? "" : loginUser.getUserId();
        if (checklist.getChecklistId() == null) {
            checklist.setRegId(userId);
            dailyChecklistMapper.insertDailyChecklist(checklist);
        } else {
            checklist.setUpdId(userId);
            dailyChecklistMapper.updateDailyChecklist(checklist);
            dailyChecklistMapper.deleteDailyChecklistItems(checklist.getChecklistId());
        }

        int sortOrd = 1;
        for (DailyChecklistItem item : items) {
            if (isBlank(item.getItemName())) {
                continue;
            }
            item.setChecklistId(checklist.getChecklistId());
            if (item.getSortOrd() == null || item.getSortOrd() == 0) {
                item.setSortOrd(sortOrd);
            }
            dailyChecklistMapper.insertDailyChecklistItem(item);
            sortOrd++;
        }

        result.setData(checklist);
        return result;
    }

    @Transactional
    public ResultVO deleteChecklist(Long checklistId, UserCustom loginUser) {
        ResultVO result = new ResultVO();
        if (checklistId == null) {
            result.setCode("9999");
            result.setMessage("삭제할 체크리스트 정보가 없습니다.");
            return result;
        }

        DailyChecklist checklist = new DailyChecklist();
        checklist.setChecklistId(checklistId);
        checklist.setUpdId(loginUser == null ? "" : loginUser.getUserId());
        dailyChecklistMapper.deleteDailyChecklist(checklist);
        return result;
    }

    private DailyChecklist toChecklist(Map<String, Object> params) {
        DailyChecklist checklist = new DailyChecklist();
        checklist.setChecklistId(parseLong(params.get("checklistId")));
        checklist.setChecklistName(Utils.getParam(params, "checklistName"));
        checklist.setSiteCd(Utils.getParam(params, "siteCd"));
        checklist.setCommonYn(defaultValue(Utils.getParam(params, "commonYn"), "Y"));
        checklist.setUseYn(defaultValue(Utils.getParam(params, "useYn"), "Y"));
        checklist.setSortOrd(parseInt(params.get("sortOrd"), 0));
        return checklist;
    }

    private List<DailyChecklistItem> toItems(Map<String, Object> params, Long checklistId) {
        List<String> itemNames = getParamList(params, "itemName");
        List<String> inputTypes = getParamList(params, "inputType");
        List<String> optionValues = getParamList(params, "optionValues");
        List<String> requiredYns = getParamList(params, "requiredYn");
        List<String> useYns = getParamList(params, "itemUseYn");
        List<String> sortOrds = getParamList(params, "itemSortOrd");

        int max = itemNames.size();
        List<DailyChecklistItem> items = new ArrayList<>();
        for (int i = 0; i < max; i++) {
            DailyChecklistItem item = new DailyChecklistItem();
            item.setChecklistId(checklistId);
            item.setItemName(getAt(itemNames, i));
            item.setInputType(defaultValue(getAt(inputTypes, i), "CHECK"));
            item.setOptionValues(getAt(optionValues, i));
            item.setRequiredYn(defaultValue(getAt(requiredYns, i), "N"));
            item.setUseYn(defaultValue(getAt(useYns, i), "Y"));
            item.setSortOrd(parseInt(getAt(sortOrds, i), i + 1));
            items.add(item);
        }
        return items;
    }

    private List<String> getParamList(Map<String, Object> params, String key) {
        Object value = params.get(key);
        List<String> values = new ArrayList<>();
        if (value == null) {
            return values;
        }
        if (value instanceof String[]) {
            String[] arr = (String[]) value;
            for (String item : arr) {
                values.add(item == null ? "" : item.trim());
            }
            return values;
        }
        values.add(value.toString().trim());
        return values;
    }

    private String getAt(List<String> values, int index) {
        return index < values.size() ? values.get(index) : "";
    }

    private boolean hasValidItem(List<DailyChecklistItem> items) {
        for (DailyChecklistItem item : items) {
            if (!isBlank(item.getItemName())) {
                return true;
            }
        }
        return false;
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
        try {
            return Long.parseLong(value.toString().trim());
        } catch (NumberFormatException e) {
            return null;
        }
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
