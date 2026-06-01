SET NAMES utf8mb4;
USE road_sos;

INSERT INTO cd_common (cd_div, cd_div_nm, cd_code, cd_code_nm, cd_sort, use_yn) VALUES
('001', '접수방법', 'MTD001', '전화', 1, 'Y'),
('001', '접수방법', 'MTD002', '모바일', 2, 'Y'),
('002', '처리상태', 'STS001', '접수', 1, 'Y'),
('002', '처리상태', 'STS002', '처리중', 2, 'Y'),
('002', '처리상태', 'STS003', '완료', 3, 'Y'),
('002', '처리상태', 'STS004', '취소', 4, 'Y'),
('003', '권한', 'ATH100', '시스템 관리자', 1, 'Y'),
('003', '권한', 'ATH200', '현장 관리자', 2, 'Y'),
('003', '권한', 'ATH300', '현장 사용자', 3, 'Y'),
('003', '권한', 'ATH400', '신고접수 관리자', 4, 'Y'),
('005', '포트홀상태', 'STS001', '접수', 1, 'Y'),
('006', '접수구분', 'RCV001', '민원', 1, 'Y'),
('007', '날씨', 'SUN', '맑음', 1, 'Y'),
('ROAD_DIR', '방향', 'UP', '상행', 1, 'Y'),
('ROAD_DIR', '방향', 'DOWN', '하행', 2, 'Y'),
('SITUATION_SHIFT', '상황일지 주야간', 'DAY', '주간', 1, 'Y'),
('SITUATION_SHIFT', '상황일지 주야간', 'NIGHT', '야간', 2, 'Y'),
('CHECK_INPUT_TYPE', '점검 입력형식', 'CHECK', '체크', 1, 'Y'),
('CHECK_INPUT_TYPE', '점검 입력형식', 'TEXT', '텍스트', 2, 'Y'),
('CHECK_INPUT_TYPE', '점검 입력형식', 'NUMBER', '숫자', 3, 'Y'),
('CHECK_INPUT_TYPE', '점검 입력형식', 'SELECT', '선택', 4, 'Y'),
('DEPT', '팀', 'ROAD', '도로관리팀', 1, 'Y'),
('DEPT', '팀', 'TRAFFIC', '교통관제팀', 2, 'Y'),
('DEPT', '팀', 'SAFETY', '안전점검팀', 3, 'Y'),
('DEPT', '팀', 'DEV', '로컬개발팀', 9, 'Y'),
('NOTI_TYPE', '알림톡 유형', 'POTHOLE_RECEIPT', '포트홀 접수', 1, 'Y'),
('NOTI_TYPE', '알림톡 유형', 'POTHOLE_COMPLETE', '포트홀 처리완료', 2, 'Y'),
('NOTI_TYPE', '알림톡 유형', 'DAILY_CHECK', '일상점검', 3, 'Y'),
('NOTI_TYPE', '알림톡 유형', 'SITUATION_LOG', '상황일지', 4, 'Y')
ON DUPLICATE KEY UPDATE cd_div_nm = VALUES(cd_div_nm), cd_code_nm = VALUES(cd_code_nm), cd_sort = VALUES(cd_sort), use_yn = VALUES(use_yn);

INSERT INTO site_info (site_cd, parent_site_cd, site_name, call_center_no, del_yn) VALUES
('LOCAL', NULL, '이도테스트 고속도로', '02-0000-0000', 'N'),
('LOCAL-01', 'LOCAL', '이도테스트 1공구', '02-0000-0000', 'N')
ON DUPLICATE KEY UPDATE parent_site_cd = VALUES(parent_site_cd), site_name = VALUES(site_name), call_center_no = VALUES(call_center_no), del_yn = VALUES(del_yn);

DELETE FROM daily_check_log_item WHERE check_id IN (SELECT check_id FROM daily_check_log WHERE writer_id = 'testf' OR check_no LIKE 'TDC%');
DELETE FROM daily_check_log WHERE writer_id = 'testf' OR check_no LIKE 'TDC%';
DELETE FROM daily_checklist_item WHERE checklist_id IN (SELECT checklist_id FROM daily_checklist WHERE reg_id = 'testa' OR checklist_name LIKE '[시연]%');
DELETE FROM daily_checklist WHERE reg_id = 'testa' OR checklist_name LIKE '[시연]%';
DELETE FROM situation_log WHERE reg_id IN ('testa', 'testf') OR title LIKE '[시연]%';
DELETE FROM pothole_work_scope WHERE report_no LIKE 'DEMO%';
DELETE FROM pothole_work_equipment WHERE report_no LIKE 'DEMO%';
DELETE FROM pothole_work_personnel WHERE report_no LIKE 'DEMO%';
DELETE FROM pothole_work_material WHERE report_no LIKE 'DEMO%';
DELETE FROM pothole_photo WHERE report_no LIKE 'DEMO%';
DELETE FROM pothole_history WHERE report_no LIKE 'DEMO%';
DELETE FROM pothole WHERE report_no LIKE 'DEMO%';
DELETE FROM notification_recipient WHERE user_id IN ('testa', 'testf') OR remark LIKE '시연%';
DELETE FROM admin_user_site WHERE user_id IN ('testa', 'testf');
DELETE FROM admin_user WHERE user_id IN ('testa', 'testf');

INSERT INTO admin_user (
  user_id, user_nm, user_pwd, user_mail, user_tel, user_auth, dept_cd, biz_div_cd, last_receipt_gb_cd,
  use_yn, input_staff, input_datetime, input_ip, reg_id, reg_dt
) VALUES
('testa', '시연 관리자', '{noop}testa123',
 HEX(AES_ENCRYPT('testa@yido.test', 'RSOS')), HEX(AES_ENCRYPT('010-9000-1000', 'RSOS')),
 'ATH100', 'ROAD', 'LOCAL', 'RCV001', 1, 'system', NOW(), '127.0.0.1', 'system', NOW()),
('testf', '시연 현장사용자', '{noop}testf123',
 HEX(AES_ENCRYPT('testf@yido.test', 'RSOS')), HEX(AES_ENCRYPT('010-9000-2000', 'RSOS')),
 'ATH300', 'SAFETY', 'APPLY', 'RCV001', 1, 'system', NOW(), '127.0.0.1', 'system', NOW());

INSERT INTO admin_user_site (user_id, site_cd) VALUES
('testa', 'LOCAL'),
('testa', 'LOCAL-01'),
('testf', 'LOCAL');

INSERT INTO notification_template_setting
(notification_type, template_code, template_title, default_dept_cds, use_yn, remark, reg_id, reg_dt, upd_id, upd_dt)
VALUES
('POTHOLE_RECEIPT', 'ATK_DEMO_RECEIPT', '포트홀 접수 알림', 'ROAD,SAFETY', 'Y', '시연용 기본 매핑', 'testa', NOW(), 'testa', NOW()),
('POTHOLE_COMPLETE', 'ATK_DEMO_DONE', '포트홀 처리완료 알림', 'ROAD,TRAFFIC', 'Y', '시연용 기본 매핑', 'testa', NOW(), 'testa', NOW()),
('DAILY_CHECK', 'ATK_DEMO_DAILY', '일상점검 등록 알림', 'SAFETY,ROAD', 'Y', '시연용 기본 매핑', 'testa', NOW(), 'testa', NOW()),
('SITUATION_LOG', 'ATK_DEMO_SITUATION', '상황일지 등록 알림', 'TRAFFIC,SAFETY', 'Y', '시연용 기본 매핑', 'testa', NOW(), 'testa', NOW())
ON DUPLICATE KEY UPDATE
  template_code = VALUES(template_code),
  template_title = VALUES(template_title),
  default_dept_cds = VALUES(default_dept_cds),
  use_yn = VALUES(use_yn),
  remark = VALUES(remark),
  upd_id = VALUES(upd_id),
  upd_dt = VALUES(upd_dt);

INSERT INTO notification_recipient
(notification_type, recipient_nm, phone_no, user_id, site_cd, use_yn, sort_ord, remark, reg_id, reg_dt, upd_id, upd_dt)
VALUES
('POTHOLE_RECEIPT', '시연 관리자', '010-9000-1000', 'testa', 'LOCAL', 'Y', 1, '시연 접수 알림 기본 수신자', 'testa', NOW(), 'testa', NOW()),
('DAILY_CHECK', '시연 현장사용자', '010-9000-2000', 'testf', 'LOCAL', 'Y', 1, '시연 일상점검 알림 기본 수신자', 'testa', NOW(), 'testa', NOW()),
('SITUATION_LOG', '시연 현장사용자', '010-9000-2000', 'testf', 'LOCAL', 'Y', 1, '시연 상황일지 알림 기본 수신자', 'testa', NOW(), 'testa', NOW());

INSERT INTO daily_checklist (checklist_name, site_cd, common_yn, use_yn, sort_ord, reg_id, reg_dt)
VALUES
('[시연] 교량 일상점검', 'LOCAL', 'Y', 'Y', 10, 'testa', NOW()),
('[시연] 터널/지하차도 일상점검', 'LOCAL', 'Y', 'Y', 20, 'testa', NOW()),
('[시연] 배수시설 일상점검', 'LOCAL', 'Y', 'Y', 30, 'testa', NOW());

SET @bridge_id := (SELECT checklist_id FROM daily_checklist WHERE checklist_name = '[시연] 교량 일상점검' ORDER BY checklist_id DESC LIMIT 1);
SET @tunnel_id := (SELECT checklist_id FROM daily_checklist WHERE checklist_name = '[시연] 터널/지하차도 일상점검' ORDER BY checklist_id DESC LIMIT 1);
SET @drain_id := (SELECT checklist_id FROM daily_checklist WHERE checklist_name = '[시연] 배수시설 일상점검' ORDER BY checklist_id DESC LIMIT 1);

INSERT INTO daily_checklist_item (checklist_id, item_name, input_type, option_values, required_yn, use_yn, sort_ord) VALUES
(@bridge_id, '교량 신축이음부 파손 여부', 'CHECK', '정상,이상,확인 필요', 'Y', 'Y', 1),
(@bridge_id, '난간/방호울타리 변형 여부', 'CHECK', '정상,이상,확인 필요', 'Y', 'Y', 2),
(@bridge_id, '교면 포장 균열 및 포트홀', 'CHECK', '정상,이상,확인 필요', 'Y', 'Y', 3),
(@bridge_id, '배수구 막힘 또는 토사 퇴적', 'CHECK', '정상,이상,확인 필요', 'Y', 'Y', 4),
(@bridge_id, '현장 특이사항', 'TEXT', NULL, 'N', 'Y', 5),
(@tunnel_id, '조명 점등 상태', 'CHECK', '정상,이상,확인 필요', 'Y', 'Y', 1),
(@tunnel_id, 'CCTV/비상벨 작동 상태', 'CHECK', '정상,이상,확인 필요', 'Y', 'Y', 2),
(@tunnel_id, '누수/결빙 위험 여부', 'CHECK', '정상,이상,확인 필요', 'Y', 'Y', 3),
(@tunnel_id, '환기설비 이상 여부', 'CHECK', '정상,이상,확인 필요', 'Y', 'Y', 4),
(@drain_id, '측구 및 집수정 퇴적 상태', 'CHECK', '정상,이상,확인 필요', 'Y', 'Y', 1),
(@drain_id, '배수로 유실/파손 여부', 'CHECK', '정상,이상,확인 필요', 'Y', 'Y', 2),
(@drain_id, '우수 유입부 막힘 여부', 'CHECK', '정상,이상,확인 필요', 'Y', 'Y', 3),
(@drain_id, '정비 필요 수량', 'NUMBER', NULL, 'N', 'Y', 4);

INSERT INTO daily_check_log
(check_no, check_date, check_title, checklist_id, site_cd, writer_id, status_cd, weather_cd, remark, reg_dt, upd_dt)
VALUES
('TDC202606010001', CURDATE(), '한강1교 상행 12.4km 오전점검', @bridge_id, 'LOCAL', 'testf', 'DONE', 'SUN', '신축이음부 주변 이물 확인, 오후 순찰 시 재확인 예정', NOW() - INTERVAL 3 HOUR, NOW() - INTERVAL 3 HOUR),
('TDC202606010002', CURDATE(), '한강2교 하행 13.1km 우천대비 점검', @bridge_id, 'LOCAL', 'testf', 'DONE', 'SUN', '배수구 일부 낙엽 제거 완료', NOW() - INTERVAL 90 MINUTE, NOW() - INTERVAL 90 MINUTE),
('TDC202606010003', CURDATE(), '터널 A구간 야간 인수점검', @tunnel_id, 'LOCAL', 'testf', 'SAVED', 'SUN', '야간 근무자 인수인계용 임시저장', NOW() - INTERVAL 30 MINUTE, NOW() - INTERVAL 30 MINUTE),
('TDC202605310001', CURDATE() - INTERVAL 1 DAY, '집수정 집중호우 사전점검', @drain_id, 'LOCAL', 'testf', 'DONE', 'SUN', '퇴적물 2개소 정비 요청', NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 1 DAY);

SET @log1 := (SELECT check_id FROM daily_check_log WHERE check_no = 'TDC202606010001');
SET @log2 := (SELECT check_id FROM daily_check_log WHERE check_no = 'TDC202606010002');
SET @log3 := (SELECT check_id FROM daily_check_log WHERE check_no = 'TDC202606010003');
SET @log4 := (SELECT check_id FROM daily_check_log WHERE check_no = 'TDC202605310001');

INSERT INTO daily_check_log_item (check_id, item_id, item_name, input_type, required_yn, check_value, check_memo, sort_ord)
SELECT @log1, item_id, item_name, input_type, required_yn,
       CASE WHEN sort_ord IN (1,2,3) THEN '정상' WHEN sort_ord = 4 THEN '확인 필요' ELSE '특이사항 없음' END,
       CASE WHEN sort_ord = 4 THEN '배수구 낙엽 일부 확인' ELSE NULL END,
       sort_ord
FROM daily_checklist_item WHERE checklist_id = @bridge_id;

INSERT INTO daily_check_log_item (check_id, item_id, item_name, input_type, required_yn, check_value, check_memo, sort_ord)
SELECT @log2, item_id, item_name, input_type, required_yn,
       CASE WHEN sort_ord = 3 THEN '이상' WHEN sort_ord = 5 THEN '하행 차로 포장 보수 필요' ELSE '정상' END,
       CASE WHEN sort_ord = 3 THEN '교면 포장 균열 1개소 발견' ELSE NULL END,
       sort_ord
FROM daily_checklist_item WHERE checklist_id = @bridge_id;

INSERT INTO daily_check_log_item (check_id, item_id, item_name, input_type, required_yn, check_value, check_memo, sort_ord)
SELECT @log3, item_id, item_name, input_type, required_yn,
       CASE WHEN sort_ord = 2 THEN '확인 필요' ELSE '정상' END,
       CASE WHEN sort_ord = 2 THEN 'CCTV 3번 화면 흔들림, 관제팀 확인 요청' ELSE NULL END,
       sort_ord
FROM daily_checklist_item WHERE checklist_id = @tunnel_id;

INSERT INTO daily_check_log_item (check_id, item_id, item_name, input_type, required_yn, check_value, check_memo, sort_ord)
SELECT @log4, item_id, item_name, input_type, required_yn,
       CASE WHEN sort_ord IN (1,2,3) THEN '이상' WHEN sort_ord = 4 THEN '2' ELSE '정상' END,
       CASE WHEN sort_ord IN (1,2,3) THEN '집중호우 대비 정비 필요' ELSE NULL END,
       sort_ord
FROM daily_checklist_item WHERE checklist_id = @drain_id;

INSERT INTO situation_log (log_date, shift_cd, event_time, title, content, site_cd, use_yn, reg_id, reg_dt)
VALUES
(CURDATE(), 'DAY', '08:20:00', '[시연] 주간 근무 인수인계', '야간 특이사항 없음. 금일 교량 2개소와 터널 A구간 일상점검 예정.', 'LOCAL', 'Y', 'testf', NOW() - INTERVAL 5 HOUR),
(CURDATE(), 'DAY', '10:35:00', '[시연] 교량 점검 특이사항', '한강2교 하행 13.1km 교면 균열 1개소 확인. 보수 우선순위 검토 요청.', 'LOCAL', 'Y', 'testf', NOW() - INTERVAL 3 HOUR),
(CURDATE(), 'NIGHT', '19:10:00', '[시연] 야간 근무 계획', '터널 A구간 CCTV 흔들림 확인 및 관제팀 연계 점검 예정.', 'LOCAL', 'Y', 'testf', NOW() - INTERVAL 1 HOUR),
(CURDATE() - INTERVAL 1 DAY, 'NIGHT', '22:40:00', '[시연] 집중호우 대비 배수 점검', '집수정 2개소 퇴적물 확인. 익일 오전 장비 투입 요청.', 'LOCAL', 'Y', 'testf', NOW() - INTERVAL 1 DAY);

INSERT INTO pothole
(report_no, doc_no, report_date, receipt_gb_cd, status_cd, site_cd, admin_site_cd, receiver_id, manager_id,
 weather_cd, work_weather_cd, direction_cd, lat, lng, addr, process_note, lane_info, report_remark,
 work_qty, convert_work_qty, account_work_qty, detail_info, delivery_note, pavement_type_cds, occur_place_cds,
 sta_text, sta_ref_name, sta_meters, sta_km_decimal, accuracy_m, captured_at, captured_ts, temp, work_temp,
 work_start_at, work_end_at, reg_datetime, update_datetime, del_yn, cell_phone)
VALUES
('DEMO202606010001', 'DOC-DEMO-001', NOW() - INTERVAL 6 HOUR, 'RCV001', 'STS001', 'LOCAL-01', 'LOCAL', 'testa', 'testf',
 'SUN', NULL, 'UP', 37.5665000000, 126.9780000000, '이도테스트 1공구 상행 12.4km 갓길',
 '모바일 신고 접수. 현장 확인 대기.', '상행 2차로', '시연용 접수 상태 데이터',
 NULL, NULL, NULL, '포트홀 의심 신고, 차량 진동 발생', '안전조치 후 작업 배정 필요', '아스팔트', '본선',
 '12.4km', '한강1교', 12400, 12.400, 8.50, NOW() - INTERVAL 6 HOUR, UNIX_TIMESTAMP(NOW() - INTERVAL 6 HOUR) * 1000, 24, NULL,
 NULL, NULL, NOW() - INTERVAL 6 HOUR, NOW() - INTERVAL 6 HOUR, 'N', HEX(AES_ENCRYPT('010-1111-3333', 'RSOS'))),
('DEMO202606010002', 'DOC-DEMO-002', NOW() - INTERVAL 4 HOUR, 'RCV001', 'STS002', 'LOCAL-01', 'LOCAL', 'testa', 'testf',
 'SUN', 'SUN', 'DOWN', 37.5682000000, 126.9821000000, '이도테스트 1공구 하행 13.1km 교량 접속부',
 '현장 출동 후 임시 보수 진행 중.', '하행 1차로', '시연용 처리중 상태 데이터',
 1.25, 1.25, 1.00, '교면 균열 및 소형 포트홀', '라바콘 설치 후 보수재 포설', '아스팔트', '교량',
 '13.1km', '한강2교', 13100, 13.100, 6.20, NOW() - INTERVAL 4 HOUR, UNIX_TIMESTAMP(NOW() - INTERVAL 4 HOUR) * 1000, 25, 26,
 NOW() - INTERVAL 3 HOUR, NULL, NOW() - INTERVAL 4 HOUR, NOW() - INTERVAL 2 HOUR, 'N', HEX(AES_ENCRYPT('010-1111-4444', 'RSOS'))),
('DEMO202605310001', 'DOC-DEMO-003', NOW() - INTERVAL 1 DAY, 'RCV001', 'STS003', 'LOCAL-01', 'LOCAL', 'testa', 'testf',
 'SUN', 'SUN', 'UP', 37.5710000000, 126.9900000000, '이도테스트 1공구 상행 15.0km 졸음쉼터 진입부',
 '보수 완료 및 사진 보고 완료.', '상행 갓길', '시연용 완료 상태 데이터',
 2.10, 2.10, 2.00, '갓길 포장 파손', '긴급 보수 완료', '아스팔트', '갓길',
 '15.0km', '졸음쉼터 진입부', 15000, 15.000, 5.00, NOW() - INTERVAL 1 DAY, UNIX_TIMESTAMP(NOW() - INTERVAL 1 DAY) * 1000, 23, 25,
 NOW() - INTERVAL 1 DAY + INTERVAL 1 HOUR, NOW() - INTERVAL 1 DAY + INTERVAL 3 HOUR, NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 1 DAY + INTERVAL 3 HOUR, 'N', HEX(AES_ENCRYPT('010-1111-5555', 'RSOS')));

INSERT INTO pothole_work_scope (report_no, scope_nm, qty, unit, sort_ord, width_m, height_m, area_m2, depth_cm, span_m) VALUES
('DEMO202606010002', '임시 보수 범위', 1.25, '㎡', 1, 1.00, 1.25, 1.25, 4.00, NULL),
('DEMO202605310001', '아스콘 보수 범위', 2.10, '㎡', 1, 1.40, 1.50, 2.10, 5.00, NULL);

INSERT INTO pothole_work_equipment (report_no, equipment_nm, qty, unit, remark, sort_ord, equip_name, own_qty, use_qty) VALUES
('DEMO202606010002', '작업차량', 1, '대', '1톤 작업차', 1, '작업차량', 2, 1),
('DEMO202605310001', '콤팩터', 1, '대', '다짐 작업', 1, '콤팩터', 1, 1);

INSERT INTO pothole_work_personnel (report_no, personnel_nm, qty, unit, labor_cost, sort_ord, person_name, dept_name) VALUES
('DEMO202606010002', '도로보수 작업자', 2, '명', 260000, 1, '시연 현장사용자 외 1명', '안전점검팀'),
('DEMO202605310001', '도로보수 작업자', 3, '명', 390000, 1, '시연 현장사용자 외 2명', '안전점검팀');

INSERT INTO pothole_work_material (report_no, material_nm, qty, unit, remain_qty, amount, sort_ord, material_name, spec, use_qty) VALUES
('DEMO202606010002', '상온 아스콘', 3, '포', 7, 45000, 1, '상온 아스콘', '20kg', 3),
('DEMO202605310001', '상온 아스콘', 5, '포', 2, 75000, 1, '상온 아스콘', '20kg', 5);

INSERT INTO pothole_history (report_no, action_user_id, action_cd, action_note, action_datetime, action_type, changed_fields, action_memo) VALUES
('DEMO202606010001', 'testa', 'REGISTER', '시연 접수 등록', NOW() - INTERVAL 6 HOUR, 'CREATE', 'status_cd,manager_id', '접수 후 현장 배정'),
('DEMO202606010002', 'testf', 'WORKING', '현장 출동 및 임시 보수 진행', NOW() - INTERVAL 2 HOUR, 'UPDATE', 'status_cd,work_start_at', '처리중으로 상태 변경'),
('DEMO202605310001', 'testf', 'DONE', '보수 완료', NOW() - INTERVAL 1 DAY + INTERVAL 3 HOUR, 'UPDATE', 'status_cd,work_end_at', '완료 처리');
