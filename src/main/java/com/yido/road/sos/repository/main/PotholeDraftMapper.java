package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.PotholeDraftDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

@Mapper
@Repository
public interface PotholeDraftMapper {

    /* 임시 저장 데이터 저장 */
    int insertDraft(PotholeDraftDto dto);

    /* 임시 저장 데이터 조회 */
    PotholeDraftDto selectDraftById(@Param("draftId") Long draftId);

    /* 임시 저장 데이터 삭제 */
    int deleteDraft(@Param("draftId") Long draftId);
}