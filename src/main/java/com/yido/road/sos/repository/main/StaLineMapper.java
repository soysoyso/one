package com.yido.road.sos.repository.main;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/* STA 선형 정보 조회 및 계산 결과 반영을 담당하는 Mapper */
@Mapper
public interface StaLineMapper {

    /**
     * site_cd + direction_cd 로 단일 STA 선형(line_json, 보정치 등) 조회
     */
    Map<String, Object> selectStaLine(Map<String, Object> param);

    /**
     * 대표 노선(parentSiteCd)에 속한 하위 노선 후보 목록(line_json 포함) 조회
     */
    List<Map<String, Object>> selectStaLinesByParent(Map<String, Object> param);

    List<Map<String, Object>> selectStaLineSegs(Map<String, Object> param);

    /**
     * 대표 노선(parentSiteCd)에 하위 노선이 존재하는지 여부 확인 (count 반환)
     */
    int countSubRoutes(Map<String, Object> p);

    /**
     * 특정 노선의 현재 line_json 선형 데이터를 조회 (reverse 등 가공용)
     */
    String selectLineJson(@Param("siteCd") String siteCd,
                          @Param("directionCd") String directionCd,
                          @Param("segNo") int segNo);

    /**
     * line_json 을 업데이트하고 시작 좌표(start_lng, start_lat)도 함께 갱신
     */
    int updateLineJson(@Param("siteCd") String siteCd,
                       @Param("directionCd") String directionCd,
                       @Param("segNo") int segNo,
                       @Param("lineJson") String lineJson,
                       @Param("startLng") BigDecimal startLng,
                       @Param("startLat") BigDecimal startLat);
}