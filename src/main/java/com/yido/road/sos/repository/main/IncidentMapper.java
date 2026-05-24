package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.Incident;
import com.yido.road.sos.model.TimelineItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface IncidentMapper {

	/* 접수번호 추출 */
	public String selectMaxReportNoByDate(Map<String, Object> params);

	/* 접수내역 조회 */
	public Incident selectIncidentByReportNo(String reportNo);

	/* 접수내역 조회 (상세) */
	public Incident selectIncidentDetailByReportNo(String reportNo);

	/* 상태별 건수 집계 (일자 기준) */
	Map<String, Object> getIncidentStatusSummaryByDate(Map<String, Object> params);

	/* 사고접수 insert */
	public int insertIncident(Incident incident);

	/* 사고접수 수정 */
	public int updateInCident(Incident incident);

	/* 사고접수 조회 */
	public List<Incident> selectIncidentList(Map<String, Object> params);

	/* 사고접수 건수 */
	public int selectIncidentCount(Map<String, Object> params);

	/* 접수번호로 사고접수 이미지조회 */
	public Incident selectIncidentImgByReportNo(String reportNo);


}
