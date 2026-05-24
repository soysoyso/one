package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.AdminUser;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface AdminUserMapper {

    public AdminUser selectAdminUser(AdminUser adminUser);

    /* 관리자 내역 */
    public List<AdminUser> selectAdminUserList(Map<String, Object> params);

    public List<AdminUser> selectPotholeAssigneeUsersBySiteCd(Map<String, Object> params);

    /* 관리자 내역 건수 */
    public int selectAdminUserCount(Map<String, Object> params);

    /* 아이디로 중복 여부 확인 */
    public int chkUserId(String userId);

    /* 관리자 등록 */
    public void insertAdminUser(AdminUser adminUser);

    /* 관리자 로그 */
    public void insertAdminUserLog(AdminUser adminUser);

    /* 관리자 수정 */
    public void updateAdminUser(AdminUser adminUser);

    /* 관리자 삭제 */
    public void deleteAdminUser(AdminUser adminUser);

    public void deleteAdminUserSite(String userId);

    public void insertAdminUserSite(Map<String, Object> params);

    /*  특정 현장 기준 사용자 목록 조회 (bizDivCd 조건 선택 적용, SMS 발송 대상 조회용) */
    public List<Map<String, Object>> selectUsersBySiteAndBiz(Map<String, Object> param);

    /* 마지막 접수유형 기록 */
    public void updateLastReceiptGbCd(Map<String, Object> params);

    /* 마지막 접수유형 조회 */
    String selectLastReceiptGbCd(String userId);
}
