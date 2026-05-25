package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.SituationLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface SituationLogMapper {
    List<SituationLog> selectSituationLogList(Map<String, Object> params);

    int selectSituationLogCount(Map<String, Object> params);

    SituationLog selectSituationLog(@Param("situationId") Long situationId);

    void insertSituationLog(SituationLog situationLog);

    void updateSituationLog(SituationLog situationLog);

    void deleteSituationLog(SituationLog situationLog);
}
