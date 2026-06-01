USE road_sos;

UPDATE admin_user
SET user_nm = '로컬 관리자'
WHERE user_id = 'admin';

UPDATE admin_user
SET user_nm = '로컬 현장사용자'
WHERE user_id = 'field';

UPDATE site_info
SET site_name = '로컬 테스트 현장'
WHERE site_cd = 'LOCAL';

UPDATE site_info
SET site_name = '로컬 테스트 구간'
WHERE site_cd = 'LOCAL-01';

UPDATE cd_common
SET cd_code_nm = '주간'
WHERE cd_div = 'SITUATION_SHIFT'
  AND cd_code = 'DAY';

UPDATE cd_common
SET cd_code_nm = '야간'
WHERE cd_div = 'SITUATION_SHIFT'
  AND cd_code = 'NIGHT';

UPDATE cd_common
SET cd_code_nm = '포트홀 접수'
WHERE cd_div = 'NOTI_TYPE'
  AND cd_code = 'POTHOLE_RECEIPT';

UPDATE cd_common
SET cd_code_nm = '포트홀 처리완료'
WHERE cd_div = 'NOTI_TYPE'
  AND cd_code = 'POTHOLE_COMPLETE';

UPDATE cd_common
SET cd_code_nm = '일상점검'
WHERE cd_div = 'NOTI_TYPE'
  AND cd_code = 'DAILY_CHECK';

UPDATE cd_common
SET cd_code_nm = '상황일지'
WHERE cd_div = 'NOTI_TYPE'
  AND cd_code = 'SITUATION_LOG';
