CREATE TABLE IF NOT EXISTS notification_template_setting (
  notification_type varchar(50) NOT NULL,
  template_code varchar(100),
  template_title varchar(200),
  default_dept_cds varchar(500),
  use_yn varchar(1) DEFAULT 'Y',
  remark varchar(1000),
  reg_id varchar(100),
  reg_dt datetime,
  upd_id varchar(100),
  upd_dt datetime,
  PRIMARY KEY (notification_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
