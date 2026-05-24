SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

CREATE DATABASE IF NOT EXISTS road_sos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS yidohome CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON road_sos.* TO 'roadsos'@'%';
GRANT ALL PRIVILEGES ON yidohome.* TO 'roadsos'@'%';
FLUSH PRIVILEGES;

USE road_sos;

CREATE TABLE IF NOT EXISTS cd_common (
  cd_div varchar(50) NOT NULL,
  cd_div_nm varchar(100),
  cd_code varchar(50) NOT NULL,
  cd_code_nm varchar(200),
  cd_value_1 varchar(200),
  cd_sort int DEFAULT 0,
  use_yn varchar(1) DEFAULT 'Y',
  PRIMARY KEY (cd_div, cd_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS site_info (
  site_cd varchar(50) NOT NULL,
  parent_site_cd varchar(50),
  site_name varchar(200),
  call_center_no varchar(50),
  del_yn varchar(1) DEFAULT 'N',
  PRIMARY KEY (site_cd)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS admin_user (
  user_id varchar(100) NOT NULL,
  user_nm varchar(100),
  user_pwd varchar(255),
  user_mail varchar(500),
  user_tel varchar(500),
  user_auth varchar(50),
  dept_cd varchar(50),
  biz_div_cd varchar(50),
  use_yn tinyint DEFAULT 1,
  reg_dt datetime,
  reg_id varchar(100),
  upd_dt datetime,
  upd_id varchar(100),
  input_staff varchar(100),
  input_datetime datetime,
  input_ip varchar(50),
  update_staff varchar(100),
  update_datetime datetime,
  update_ip varchar(50),
  PRIMARY KEY (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS admin_user_site (
  user_id varchar(100) NOT NULL,
  site_cd varchar(50) NOT NULL,
  PRIMARY KEY (user_id, site_cd)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS admin_user_log (
  log_id bigint NOT NULL AUTO_INCREMENT,
  user_id varchar(100),
  user_nm varchar(100),
  user_mail varchar(500),
  user_tel varchar(500),
  user_auth varchar(50),
  dept_cd varchar(50),
  biz_div_cd varchar(50),
  log_div varchar(10),
  input_staff varchar(100),
  input_datetime datetime,
  input_ip varchar(50),
  PRIMARY KEY (log_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS incident (
  report_no varchar(50) NOT NULL,
  report_date datetime,
  intake_method_cd varchar(50),
  status_cd varchar(50),
  site_cd varchar(50),
  site_cd_list varchar(500),
  lat decimal(16,10),
  lng decimal(16,10),
  accuracy_m int,
  captured_at datetime,
  captured_ts bigint,
  server_received_at datetime DEFAULT CURRENT_TIMESTAMP,
  addr varchar(1000),
  cell_phone varchar(500),
  rpt_img_path varchar(1000),
  rpt_img_name varchar(500),
  process_note text,
  img_path varchar(1000),
  img_name varchar(500),
  img_path2 varchar(1000),
  img_name2 varchar(500),
  img_path3 varchar(1000),
  img_name3 varchar(500),
  img_path4 varchar(1000),
  img_name4 varchar(500),
  manager_id varchar(100),
  update_datetime datetime,
  update_ip varchar(50),
  ocr_read_km varchar(100),
  PRIMARY KEY (report_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS incident_log (
  log_id bigint NOT NULL AUTO_INCREMENT,
  report_no varchar(50),
  report_date datetime,
  intake_method_cd varchar(50),
  status_cd varchar(50),
  site_cd varchar(50),
  site_cd_list varchar(500),
  lat decimal(16,10),
  lng decimal(16,10),
  accuracy_m int,
  captured_at datetime,
  captured_ts bigint,
  server_received_at datetime,
  addr varchar(1000),
  cell_phone varchar(500),
  rpt_img_path varchar(1000),
  rpt_img_name varchar(500),
  process_note text,
  img_path varchar(1000),
  img_name varchar(500),
  img_path2 varchar(1000),
  img_name2 varchar(500),
  img_path3 varchar(1000),
  img_name3 varchar(500),
  img_path4 varchar(1000),
  img_name4 varchar(500),
  manager_id varchar(100),
  update_datetime datetime,
  update_ip varchar(50),
  ocr_read_km varchar(100),
  PRIMARY KEY (log_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS pothole (
  report_no varchar(50) NOT NULL,
  report_date datetime,
  receipt_gb_cd varchar(50),
  status_cd varchar(50),
  site_cd varchar(50),
  receiver_id varchar(100),
  manager_id varchar(100),
  weather_cd varchar(50),
  work_weather_cd varchar(50),
  direction_cd varchar(50),
  lat decimal(16,10),
  lng decimal(16,10),
  addr varchar(1000),
  detail_info varchar(1000),
  delivery_note text,
  doc_no varchar(50),
  pavement_type_cds varchar(200),
  occur_place_cds varchar(200),
  sta_text varchar(100),
  sta_meters bigint,
  sta_km_decimal decimal(12,3),
  temp int,
  work_temp int,
  work_start_at datetime,
  work_end_at datetime,
  lane_info varchar(200),
  report_remark text,
  work_qty decimal(12,2),
  convert_work_qty decimal(12,2),
  account_work_qty decimal(12,2),
  process_note text,
  update_datetime datetime,
  ocr_read_km varchar(100),
  PRIMARY KEY (report_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS pothole_photo (
  photo_id bigint NOT NULL AUTO_INCREMENT,
  report_no varchar(50),
  photo_gb varchar(50),
  img_path varchar(1000),
  img_name varchar(500),
  is_main varchar(1) DEFAULT 'N',
  sort_ord int DEFAULT 0,
  input_datetime datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (photo_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS pothole_history (
  history_id bigint NOT NULL AUTO_INCREMENT,
  report_no varchar(50),
  action_user_id varchar(100),
  action_cd varchar(50),
  action_note text,
  action_datetime datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (history_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS pothole_draft (
  draft_id bigint NOT NULL AUTO_INCREMENT,
  user_id varchar(100),
  payload_json longtext,
  input_datetime datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (draft_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS pothole_work_equipment (
  id bigint NOT NULL AUTO_INCREMENT,
  report_no varchar(50),
  sort_ord int,
  equip_name varchar(200),
  own_qty int,
  use_qty int,
  remark varchar(500),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS pothole_work_personnel (
  id bigint NOT NULL AUTO_INCREMENT,
  report_no varchar(50),
  sort_ord int,
  person_name varchar(200),
  dept_name varchar(200),
  labor_cost decimal(14,2),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS pothole_work_material (
  id bigint NOT NULL AUTO_INCREMENT,
  report_no varchar(50),
  sort_ord int,
  material_name varchar(200),
  spec varchar(200),
  unit varchar(50),
  use_qty decimal(12,2),
  remain_qty decimal(12,2),
  amount decimal(14,2),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS pothole_work_scope (
  id bigint NOT NULL AUTO_INCREMENT,
  report_no varchar(50),
  sort_ord int,
  width_m decimal(12,2),
  height_m decimal(12,2),
  area_m2 decimal(12,2),
  depth_cm decimal(12,2),
  span_m decimal(12,2),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS site_section (
  section_id bigint NOT NULL AUTO_INCREMENT,
  site_cd varchar(50),
  section_name varchar(200),
  start_lat decimal(16,10),
  start_lng decimal(16,10),
  end_lat decimal(16,10),
  end_lng decimal(16,10),
  min_lat decimal(16,10),
  max_lat decimal(16,10),
  min_lng decimal(16,10),
  max_lng decimal(16,10),
  use_yn varchar(1) DEFAULT 'Y',
  PRIMARY KEY (section_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS site_sta_line (
  line_id bigint NOT NULL AUTO_INCREMENT,
  site_cd varchar(50),
  line_name varchar(200),
  direction_cd varchar(50),
  use_yn varchar(1) DEFAULT 'Y',
  PRIMARY KEY (line_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS weather_vilage_cache (
  cache_id bigint NOT NULL AUTO_INCREMENT,
  nx int,
  ny int,
  base_date varchar(20),
  base_time varchar(20),
  payload_json longtext,
  update_datetime datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (cache_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sos_sms_send_log (
  sms_id bigint NOT NULL AUTO_INCREMENT,
  msg text,
  title varchar(200),
  cell_phone varchar(100),
  tpl_code varchar(100),
  input_datetime datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (sms_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO cd_common (cd_div, cd_div_nm, cd_code, cd_code_nm, cd_sort, use_yn) VALUES
('001', '접수방법', 'MTD001', '전화', 1, 'Y'),
('001', '접수방법', 'MTD002', '온라인', 2, 'Y'),
('002', '처리상태', 'STS001', '접수', 1, 'Y'),
('002', '처리상태', 'STS002', '처리중', 2, 'Y'),
('002', '처리상태', 'STS003', '완료', 3, 'Y'),
('002', '처리상태', 'STS004', '취소', 4, 'Y'),
('003', '권한', 'ATH100', '시스템 관리자', 1, 'Y'),
('003', '권한', 'ATH200', '관리자', 2, 'Y'),
('003', '권한', 'ATH300', '현장 담당자', 3, 'Y'),
('003', '권한', 'ATH400', '조회 담당자', 4, 'Y'),
('DEPT', '부서', 'DEV', '로컬개발팀', 1, 'Y'),
('005', '포트홀상태', 'STS001', '접수', 1, 'Y'),
('006', '접수구분', 'RCV001', '민원', 1, 'Y'),
('007', '날씨', 'SUN', '맑음', 1, 'Y'),
('ROAD_DIR', '방향', 'UP', '상행', 1, 'Y'),
('ROAD_DIR', '방향', 'DOWN', '하행', 2, 'Y')
ON DUPLICATE KEY UPDATE cd_code_nm = VALUES(cd_code_nm), use_yn = VALUES(use_yn);

INSERT INTO site_info (site_cd, parent_site_cd, site_name, call_center_no, del_yn) VALUES
('LOCAL', NULL, '로컬 테스트 현장', '02-0000-0000', 'N'),
('LOCAL-01', 'LOCAL', '로컬 테스트 구간', '02-0000-0000', 'N')
ON DUPLICATE KEY UPDATE site_name = VALUES(site_name), del_yn = VALUES(del_yn);

INSERT INTO admin_user (
  user_id, user_nm, user_pwd, user_mail, user_tel, user_auth, dept_cd, biz_div_cd,
  use_yn, input_staff, input_datetime, input_ip
) VALUES (
  'admin', '로컬 관리자', '{noop}admin123',
  HEX(AES_ENCRYPT('local-admin@example.com', 'RSOS')),
  HEX(AES_ENCRYPT('010-0000-0000', 'RSOS')),
  'ATH100', 'DEV', 'LOCAL', 1, 'system', NOW(), '127.0.0.1'
)
ON DUPLICATE KEY UPDATE user_pwd = VALUES(user_pwd), user_auth = VALUES(user_auth), use_yn = 1;

INSERT INTO admin_user_site (user_id, site_cd) VALUES
('admin', 'LOCAL'),
('admin', 'LOCAL-01')
ON DUPLICATE KEY UPDATE site_cd = VALUES(site_cd);

INSERT INTO incident (
  report_no, report_date, intake_method_cd, status_cd, site_cd, lat, lng, addr,
  cell_phone, process_note, manager_id
) VALUES (
  'LC2605220001', NOW(), 'MTD002', 'STS001', 'LOCAL-01', 37.5665000000, 126.9780000000,
  '서울특별시 로컬 테스트 주소',
  HEX(AES_ENCRYPT('010-1234-5678', 'RSOS')),
  '로컬 개발용 샘플 신고', 'admin'
)
ON DUPLICATE KEY UPDATE process_note = VALUES(process_note);

USE yidohome;

CREATE TABLE IF NOT EXISTS sms_send_log (
  sms_id bigint NOT NULL AUTO_INCREMENT,
  msg text,
  title varchar(200),
  cell_phone varchar(100),
  tpl_code varchar(100),
  input_datetime datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (sms_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER //
CREATE PROCEDURE SP_SOS_SMS_SEND(
  IN p_msg text,
  IN p_title varchar(200),
  IN p_cell_phone varchar(100),
  IN p_tpl_code varchar(100)
)
BEGIN
  INSERT INTO sms_send_log (msg, title, cell_phone, tpl_code)
  VALUES (p_msg, p_title, p_cell_phone, p_tpl_code);
END//
DELIMITER ;
