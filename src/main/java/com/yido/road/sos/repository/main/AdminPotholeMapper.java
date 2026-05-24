package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.Pothole;
import com.yido.road.sos.model.PotholeImage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;
import com.yido.road.sos.model.work.EquipmentRow;
import com.yido.road.sos.model.work.PersonnelRow;
import com.yido.road.sos.model.work.MaterialRow;
import com.yido.road.sos.model.work.ScopeRow;
import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface AdminPotholeMapper {

    /* 현장관리 목록 조회(관리자 화면) */
    List<Map<String, Object>> selectImsPotholeList(Map<String, Object> param);

    /* 현장관리 건수 조회(관리자 화면) */
    int selectImsPotholeCount(Map<String, Object> param);

    /* 현장관리 상태 일괄 변경 */
    int updatePotholeStatusBulk(Map<String, Object> param);

    /* 접수내용 상세보기 */
    Map<String, Object> selectImsPotholeDetail(String reportNo);

    int updatePotholeAll(Pothole pothole);

    int insertPotholeAll(Pothole pothole);

    // ✅ 작업정보: 장비
    void deleteWorkEquipmentByReportNo(@Param("reportNo") String reportNo);
    void insertWorkEquipmentBatch(@Param("reportNo") String reportNo,
                                  @Param("list") List<EquipmentRow> list);

    // ✅ 작업정보: 인력
    void deleteWorkPersonnelByReportNo(@Param("reportNo") String reportNo);
    void insertWorkPersonnelBatch(@Param("reportNo") String reportNo,
                                  @Param("list") List<PersonnelRow> list);

    // ✅ 작업정보: 자재
    void deleteWorkMaterialByReportNo(@Param("reportNo") String reportNo);
    void insertWorkMaterialBatch(@Param("reportNo") String reportNo,
                                 @Param("list") List<MaterialRow> list);

    // ✅ 작업정보: 범위
    void deleteWorkScopeByReportNo(@Param("reportNo") String reportNo);
    void insertWorkScopeBatch(@Param("reportNo") String reportNo,
                              @Param("list") List<ScopeRow> list);

    List<Map<String, Object>> selectWorkEquipmentByReportNo(@Param("reportNo") String reportNo);
    List<Map<String, Object>> selectWorkPersonnelByReportNo(@Param("reportNo") String reportNo);
    List<Map<String, Object>> selectWorkMaterialByReportNo(@Param("reportNo") String reportNo);
    List<Map<String, Object>> selectWorkScopeByReportNo(@Param("reportNo") String reportNo);

    // 보고서용 BEFORE/AFTER 대표 사진 1장씩
    Map<String, Object> selectReportPhotoMain(@Param("reportNo") String reportNo,
                                              @Param("photoGb") String photoGb);

    // 상태별 건수 집계
    Map<String, Object> getImsStatusSummary(Map<String, Object> params);

    List<Map<String, Object>> selectPotholeHistoryByReportNo(String reportNo);

    List<Map<String, Object>> selectLedgerRows(List<String> reportNos);

}
