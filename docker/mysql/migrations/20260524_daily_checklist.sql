USE road_sos;

CREATE TABLE IF NOT EXISTS daily_checklist (
  checklist_id bigint NOT NULL AUTO_INCREMENT,
  checklist_name varchar(100) NOT NULL,
  site_cd varchar(50),
  common_yn varchar(1) DEFAULT 'Y',
  use_yn varchar(1) DEFAULT 'Y',
  sort_ord int DEFAULT 0,
  reg_id varchar(100),
  reg_dt datetime,
  upd_id varchar(100),
  upd_dt datetime,
  PRIMARY KEY (checklist_id),
  KEY idx_daily_checklist_site (site_cd),
  KEY idx_daily_checklist_use (use_yn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS daily_checklist_item (
  item_id bigint NOT NULL AUTO_INCREMENT,
  checklist_id bigint NOT NULL,
  item_name varchar(200) NOT NULL,
  input_type varchar(20) DEFAULT 'CHECK',
  option_values varchar(1000),
  required_yn varchar(1) DEFAULT 'N',
  use_yn varchar(1) DEFAULT 'Y',
  sort_ord int DEFAULT 0,
  PRIMARY KEY (item_id),
  KEY idx_daily_checklist_item_parent (checklist_id),
  KEY idx_daily_checklist_item_use (use_yn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO cd_common (cd_div, cd_div_nm, cd_code, cd_code_nm, cd_sort, use_yn) VALUES
('CHECK_INPUT_TYPE', '점검 입력형식', 'CHECK', '체크', 1, 'Y'),
('CHECK_INPUT_TYPE', '점검 입력형식', 'TEXT', '텍스트', 2, 'Y'),
('CHECK_INPUT_TYPE', '점검 입력형식', 'NUMBER', '숫자', 3, 'Y'),
('CHECK_INPUT_TYPE', '점검 입력형식', 'SELECT', '선택', 4, 'Y')
ON DUPLICATE KEY UPDATE cd_code_nm = VALUES(cd_code_nm), cd_sort = VALUES(cd_sort), use_yn = VALUES(use_yn);
