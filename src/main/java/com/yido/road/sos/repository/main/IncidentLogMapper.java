package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.Incident;
import com.yido.road.sos.model.TimelineItem;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface IncidentLogMapper {

	/* 사고접수 이력 insert */
	public int insertIncidentLog(Incident incident);

	public int insertFromIncident(String reportNo);

	/* 사고 타임라인(상태변경 이력) 조회 */
	public List<TimelineItem> selectTimelineByReportNo(String reportNo);

}
