package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.DailyCheckLog;
import com.yido.road.sos.model.DailyCheckLogItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface DailyCheckLogMapper {
    List<DailyCheckLog> selectDailyCheckLogList(Map<String, Object> params);

    int selectDailyCheckLogCount(Map<String, Object> params);

    DailyCheckLog selectDailyCheckLog(@Param("checkId") Long checkId);

    List<DailyCheckLogItem> selectDailyCheckLogItemList(@Param("checkId") Long checkId);

    String selectNextDailyCheckNo(String ymd);

    void insertDailyCheckLog(DailyCheckLog log);

    void insertDailyCheckLogItem(DailyCheckLogItem item);
}
