package com.yido.road.sos.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.model.UserInfo;
import com.yido.road.sos.repository.main.UserMapper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;


import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class UserService {

	private final UserMapper userMapper;
	private final PasswordEncoder passwordEncoder;

	public UserService(UserMapper userMapper, PasswordEncoder passwordEncoder) {
		this.userMapper = userMapper;
		this.passwordEncoder = passwordEncoder;
	}


    public AdminUser getAdminUser(AdminUser adminUser) {
        return userMapper.selectAdminUser(adminUser);
    }
/*

	public String encodePassword(String password) {
		return passwordEncoder.encode(password);
	}


	public UserInfo selectUserInfo(UserInfo user) {
		return userMapper.selectUserInfo(user);
	}

	public List<UserInfo> selectUserList(UserInfo user) {
		return userMapper.selectUserList(user);
	}

	public int insertUserInfo(UserInfo user) {
		user.setUserPwd(encodePassword(user.getUserPwd()));
		return userMapper.insertUserInfo(user);
	}

	public int updateUserInfo(UserInfo user) {
		if (user.getUserPwd() != null && !user.getUserPwd().isEmpty()) {
			user.setUserPwd(encodePassword(user.getUserPwd()));
		}
		return userMapper.updateUserInfo(user);
	}
*/
	/**
	 * 정보수정
	 *
	 * @param userId
	 * @param userNm
	 * @param currentPassword
	 * @param newPassword
	 * @param tel
	 * @param email
	 * @param updId
	 */
	public void updateMyPage(String userId, String userNm, String currentPassword,
							 String newPassword, String tel, String email, String updId) {

		Map<String, Object> param = new HashMap<>();
		param.put("userId", userId);
		param.put("userNm", userNm);
		param.put("tel", tel);
		param.put("email", email);
		param.put("updId", updId);

		if (newPassword != null && !"".equals(newPassword)) {
			if (currentPassword == null || "".equals(currentPassword)) {
				throw new IllegalArgumentException("기존 비밀번호를 입력해주세요.");
			}

			String dbHash = userMapper.selectUserPwd(userId);
			if (dbHash == null || "".equals(dbHash)) {
				throw new IllegalArgumentException("사용자 정보를 찾을 수 없습니다.");
			}

			if (!passwordEncoder.matches(currentPassword, dbHash)) {
				throw new IllegalArgumentException("기존 비밀번호가 일치하지 않습니다.");
			}

			param.put("password", passwordEncoder.encode(newPassword));
		}

		userMapper.updateMyPage(param);
	}

}
