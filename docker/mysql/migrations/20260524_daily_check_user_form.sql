USE road_sos;

CREATE TABLE IF NOT EXISTS daily_check_log (
  check_id bigint NOT NULL AUTO_INCREMENT,
  check_no varchar(30) NOT NULL,
  check_date date NOT NULL,
  checklist_id bigint NOT NULL,
  site_cd varchar(50),
  writer_id varchar(100),
  status_cd varchar(50) DEFAULT 'SAVED',
  weather_cd varchar(50),
  remark text,
  reg_dt datetime,
  upd_dt datetime,
  PRIMARY KEY (check_id),
  UNIQUE KEY uk_daily_check_log_no (check_no),
  KEY idx_daily_check_log_date (check_date),
  KEY idx_daily_check_log_site (site_cd),
  KEY idx_daily_check_log_writer (writer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS daily_check_log_item (
  log_item_id bigint NOT NULL AUTO_INCREMENT,
  check_id bigint NOT NULL,
  item_id bigint,
  item_name varchar(200),
  input_type varchar(20),
  required_yn varchar(1),
  check_value text,
  sort_ord int DEFAULT 0,
  PRIMARY KEY (log_item_id),
  KEY idx_daily_check_log_item_parent (check_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO admin_user (
  user_id, user_nm, user_pwd, user_mail, user_tel, user_auth, dept_cd, biz_div_cd,
  use_yn, input_staff, input_datetime, input_ip
) VALUES (
  'field', '로컬 현장사용자', '{noop}field123',
  HEX(AES_ENCRYPT('local-field@example.com', 'RSOS')),
  HEX(AES_ENCRYPT('010-1111-2222', 'RSOS')),
  'ATH300', 'DEV', 'APPLY', 1, 'system', NOW(), '127.0.0.1'
)
ON DUPLICATE KEY UPDATE user_pwd = VALUES(user_pwd), user_auth = VALUES(user_auth), biz_div_cd = VALUES(biz_div_cd), use_yn = 1;

INSERT INTO admin_user_site (user_id, site_cd) VALUES
('field', 'LOCAL')
ON DUPLICATE KEY UPDATE site_cd = VALUES(site_cd);
