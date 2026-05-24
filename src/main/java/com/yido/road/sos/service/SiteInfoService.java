package com.yido.road.sos.service;

import com.yido.road.sos.model.SiteInfo;
import com.yido.road.sos.repository.main.SiteInfoMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.management.ObjectName;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class SiteInfoService {

    @Autowired
    private SiteInfoMapper siteInfoMapper;

    /* 현장목록 조회 */
    public List<SiteInfo> selectSiteList(SiteInfo siteInfo) {
        return siteInfoMapper.selectSiteList(siteInfo);
    }

    /* 현장목록 조회 */
    public List<SiteInfo> selectSiteList2(SiteInfo siteInfo) {
        return siteInfoMapper.selectSiteList2(siteInfo);
    }

    /* 전체 현장코드 조회 */
    public List<String> selectAllSite(String adminId) {
        return siteInfoMapper.selectAllSite(adminId);
    }

	/* 현장코드로 현장정보 조회 */
	public SiteInfo getSiteInfoBySiteCd(String siteCd) {
		return siteInfoMapper.getSiteInfoBySiteCd(siteCd);
	}

    /* 관리대상 현장목록 조회 */
    public List<SiteInfo> getManageSiteByUserId(String siteCd) {
        return siteInfoMapper.getManageSiteByUserId(siteCd);
    }

    public Map<String, String> getCodeMap(SiteInfo siteInfo) {
        Map<String, Object> params = new HashMap<>();

        List<SiteInfo> list = siteInfoMapper.selectSiteList2(siteInfo);
        Map<String, String> result = new HashMap<>();

        for (SiteInfo code : list) {
            result.put(code.getSiteCd(), code.getSiteName());
        }

        return result;
    }

    public List<SiteInfo> selectSiteListByParent(List<String> siteCdList) {
        if (siteCdList == null || siteCdList.isEmpty()) {
            return new ArrayList<>();
        }
        return siteInfoMapper.selectSiteListByParent(siteCdList);
    }
    /* 사용자 위치 기반으로 근처 고속도로 추천 */
    public List<Map<String, Object>> selectNearbySections(Map<String, Object> params) {
        return siteInfoMapper.selectNearbySections(params);
    }

    /* 전체 고속도로 조회 */
    public List<Map<String, Object>> selectAllSections(Map<String, Object> params) {
        return siteInfoMapper.selectAllSections(params);
    }

}
