package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.DailyCheckPhoto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Mapper
@Repository
public interface DailyCheckPhotoMapper {
    void insertDailyCheckPhoto(DailyCheckPhoto photo);

    List<DailyCheckPhoto> selectDailyCheckPhotos(@Param("checkId") Long checkId);

    DailyCheckPhoto selectDailyCheckPhoto(@Param("photoId") Long photoId);
}
