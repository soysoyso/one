package com.yido.road.sos.repository.main;

import java.util.List;
import java.util.Map;

import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.model.UserInfo;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

@Mapper
@Repository
public interface UserMapper {

    public AdminUser selectAdminUser(AdminUser adminUser);

	public UserInfo selectUserInfo(UserInfo user);

	public List<UserInfo> selectUserList(UserInfo user);

	public int insertUserInfo(UserInfo user);

	public int updateUserInfo(UserInfo user);

    /* 마이페이지 정보수정 */
    public int updateMyPage(Map<String, Object> param);

	/* 기존 비밀번호 조회 */
	String selectUserPwd(String userId);

}
