package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.Pothole;
import com.yido.road.sos.model.PotholeImage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface PotholeImageMapper {

    void insertPotholeImage(PotholeImage image);

    PotholeImage selectPotholeImageOne(@Param("reportNo") String reportNo,
                                       @Param("photoGb") String photoGb,
                                       @Param("sortOrd") Integer sortOrd);


    List<PotholeImage> selectPotholeImagesByReportNo(String reportNo,
                                                     @Param("photoGb") String photoGb);

    List<Integer> selectUsedSortOrds(@Param("reportNo") String reportNo,
                                     @Param("photoGb") String photoGb);

    int deletePotholePhotoOne(@Param("reportNo") String reportNo,
                              @Param("photoGb") String photoGb,
                              @Param("sortOrd") Integer sortOrd);

    int upsertPotholePhoto(PotholeImage img);


    // ✅ 기존: 전체 대표 해제
    int updateIsMainAllN(@Param("reportNo") String reportNo,
                         @Param("photoGb") String photoGb);

    // ✅ 신규 1️⃣ : 특정 사진을 대표(Y)로 지정
    int updateIsMainOneY(@Param("reportNo") String reportNo,
                         @Param("photoGb") String photoGb,
                         @Param("sortOrd") Integer sortOrd);

    int movePhotoToTempSortOrd(Map<String, Object> param);

    int movePhotoToFinalGbAndSortOrd(Map<String, Object> param);

    void updateImagePathAndName(PotholeImage image);
}
