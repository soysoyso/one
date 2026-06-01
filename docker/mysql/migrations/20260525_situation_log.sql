USE road_sos;

CREATE TABLE IF NOT EXISTS situation_log (
  situation_id bigint NOT NULL AUTO_INCREMENT,
  log_date date NOT NULL,
  shift_cd varchar(20) NOT NULL,
  event_time time NOT NULL,
  title varchar(200),
  content text NOT NULL,
  site_cd varchar(50),
  use_yn varchar(1) DEFAULT 'Y',
  reg_id varchar(100),
  reg_dt datetime DEFAULT CURRENT_TIMESTAMP,
  upd_id varchar(100),
  upd_dt datetime,
  PRIMARY KEY (situation_id),
  KEY idx_situation_log_date (log_date),
  KEY idx_situation_log_site (site_cd),
  KEY idx_situation_log_use (use_yn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO cd_common (cd_div, cd_div_nm, cd_code, cd_code_nm, cd_sort, use_yn) VALUES
('SITUATION_SHIFT', '상황일지 주야간', 'DAY', '주간', 1, 'Y'),
('SITUATION_SHIFT', '상황일지 주야간', 'NIGHT', '야간', 2, 'Y')
ON DUPLICATE KEY UPDATE cd_code_nm = VALUES(cd_code_nm), cd_sort = VALUES(cd_sort), use_yn = VALUES(use_yn);
