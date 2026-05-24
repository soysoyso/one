package com.yido.road.sos.repository.main;

import java.util.List;
import java.util.Map;

import com.yido.road.sos.model.CdCommon;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;


@Mapper
public interface CommonMapper {

	public CdCommon getCommonCode(CdCommon cdCommon);
	
	public List<CdCommon> getCommonCodeList(CdCommon cdCommon);

    public List<CdCommon> selectCommonList(Map<String, Object> params);

	public List<CdCommon> selectRoadDirList(Map<String, Object> params);
}



