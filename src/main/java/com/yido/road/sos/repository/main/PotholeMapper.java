package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.Incident;
import com.yido.road.sos.model.Pothole;
import com.yido.road.sos.model.PotholeHistory;
import com.yido.road.sos.model.PotholeImage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface PotholeMapper {

    /* 접수번호 추출 */
    public String selectMaxReportNoByDate(Map<String, Object> params);

    /* 포트홀접수 */
    void insertPothole(Pothole pothole);

    /* 접수번호 생성  */
    String selectNextReportNo();

    /* 문서번호 생성  */
    String selectNextDocNo(String docGb);

    Pothole selectPotholeByReportNo(String reportNo);

    /* 접수내용수정 */
    int updatePotholeText(Map<String, Object> param);

    /* 작업하기 */
    int updatePotholeWork(Map<String, Object> param);

    /* 작업현황 건수 */
    Map<String, Object> selectTodayStatusCounts(Map<String, Object> param);

    /* 포트홀 접수내역 조회 */
    List<Map<String, Object>> selectRecentPotholeList(Map<String, Object> param);

    int countTodayPotholeByUserSite(Map<String, Object> param);

    // 작업날씨 재조회용(좌표/주소 베이스)
    Map<String, Object> selectWeatherBaseByReportNo(String reportNo);

    // 접수이력 히스토리 관리
    int insertPotholeHistory(PotholeHistory history);

    // 접수사진 삭제
    void deletePotholePhotos(@Param("reportNo") String reportNo);

    // 접수상태 변경 (식제처리)
    void updatePotholeDeleteYn(@Param("reportNo") String reportNo,
                               @Param("userId") String userId,
                               @Param("updateIp") String updateIp);
    String selectReceiptGbCdByReportNo(String reportNo);

    String selectParentSiteCd(Map<String, Object> param);

}
