package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.DailyChecklist;
import com.yido.road.sos.model.DailyChecklistItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface DailyChecklistMapper {
    List<DailyChecklist> selectDailyChecklistList(Map<String, Object> params);

    int selectDailyChecklistCount(Map<String, Object> params);

    DailyChecklist selectDailyChecklist(@Param("checklistId") Long checklistId);

    List<DailyChecklistItem> selectDailyChecklistItemList(@Param("checklistId") Long checklistId);

    void insertDailyChecklist(DailyChecklist checklist);

    void updateDailyChecklist(DailyChecklist checklist);

    void deleteDailyChecklist(DailyChecklist checklist);

    void deleteDailyChecklistItems(@Param("checklistId") Long checklistId);

    void insertDailyChecklistItem(DailyChecklistItem item);
}
