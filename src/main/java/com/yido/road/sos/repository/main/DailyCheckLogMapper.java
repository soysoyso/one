package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.DailyCheckLog;
import com.yido.road.sos.model.DailyCheckLogItem;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

@Mapper
@Repository
public interface DailyCheckLogMapper {
    String selectNextDailyCheckNo(String ymd);

    void insertDailyCheckLog(DailyCheckLog log);

    void insertDailyCheckLogItem(DailyCheckLogItem item);
}
