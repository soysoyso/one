package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.Incident;
import com.yido.road.sos.model.SiteInfo;
import com.yido.road.sos.util.GridXY;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface SiteInfoMapper {

    /* 현장목록 조회 */
    public List<SiteInfo> selectSiteList(SiteInfo siteInfo);

    /* 현장목록 조회 */
    public List<SiteInfo> selectSiteList2(SiteInfo siteInfo);

	/* 현장코드로 현장정보 조회 */
	public SiteInfo getSiteInfoBySiteCd(String siteCd);

    /* 관리대상 현장목록 조회  */
    public List<SiteInfo> getManageSiteByUserId(String siteCd);

    List<SiteInfo> selectSiteListByParent(List<String> siteCdList);

    /* 전체 현장코드 조회 */
    public List<String> selectAllSite(String adminId);

    /* 사용자 위치 기반으로 근처 고속도로 추천 */
    public List<Map<String, Object>> selectNearbySections(Map<String, Object> params);

    /* 전체 고속도로 조회 */
    public List<Map<String, Object>> selectAllSections(Map<String, Object> params);

    /* 전체 현장코드 조회 */
    List<String> selectAllSiteCds();
}
