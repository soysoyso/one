USE road_sos;

CREATE TABLE IF NOT EXISTS notification_recipient (
  recipient_id bigint NOT NULL AUTO_INCREMENT,
  notification_type varchar(50) NOT NULL,
  recipient_nm varchar(100) NOT NULL,
  phone_no varchar(50) NOT NULL,
  user_id varchar(100),
  site_cd varchar(50),
  use_yn varchar(1) DEFAULT 'Y',
  sort_ord int DEFAULT 0,
  remark varchar(1000),
  reg_id varchar(100),
  reg_dt datetime,
  upd_id varchar(100),
  upd_dt datetime,
  PRIMARY KEY (recipient_id),
  KEY idx_notification_recipient_type (notification_type),
  KEY idx_notification_recipient_site (site_cd),
  KEY idx_notification_recipient_use (use_yn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO cd_common (cd_div, cd_div_nm, cd_code, cd_code_nm, cd_sort, use_yn) VALUES
('NOTI_TYPE', '알림톡 유형', 'POTHOLE_RECEIPT', '포트홀 접수', 1, 'Y'),
('NOTI_TYPE', '알림톡 유형', 'POTHOLE_COMPLETE', '포트홀 처리완료', 2, 'Y'),
('NOTI_TYPE', '알림톡 유형', 'DAILY_CHECK', '일상점검', 3, 'Y'),
('NOTI_TYPE', '알림톡 유형', 'SITUATION_LOG', '상황일지', 4, 'Y')
ON DUPLICATE KEY UPDATE cd_code_nm = VALUES(cd_code_nm), cd_sort = VALUES(cd_sort), use_yn = VALUES(use_yn);
