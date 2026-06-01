const { chromium } = require('playwright');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';
const stepMs = Number(process.env.DEMO_QA_STEP_MS || 1600);
const holdMs = Number(process.env.DEMO_QA_HOLD_MS || 90000);
const token = `화면시연-${Date.now()}`;
const today = new Date().toISOString().slice(0, 10);
const cleanups = [];

async function wait(ms = stepMs) {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

async function mark(page, label) {
  console.log(`SCENARIO ${label}`);
  await page.evaluate((text) => {
    let banner = document.getElementById('codex-demo-banner');
    if (!banner) {
      banner = document.createElement('div');
      banner.id = 'codex-demo-banner';
      banner.style.cssText = [
        'position:fixed',
        'left:16px',
        'top:16px',
        'z-index:2147483647',
        'background:#0f172a',
        'color:#fff',
        'padding:12px 16px',
        'border-radius:8px',
        'font:700 16px Malgun Gothic, sans-serif',
        'box-shadow:0 10px 30px rgba(0,0,0,.25)',
        'max-width:720px',
      ].join(';');
      document.body.appendChild(banner);
    }
    banner.textContent = text;
  }, label).catch(() => {});
  await wait();
}

async function ok(name, condition) {
  if (!condition) throw new Error(`${name} failed`);
  console.log(`OK ${name}`);
}

async function login(page, userId, userPwd, path) {
  await page.goto(`${baseUrl}${path}`, { waitUntil: 'domcontentloaded' });
  await mark(page, `${userId} 로그인 화면`);
  await page.fill('input[name="userId"]', userId);
  await page.fill('input[name="userPwd"]', userPwd);
  await page.click('button[type="submit"]');
  await page.waitForLoadState('networkidle');
  await mark(page, `${userId} 로그인 완료`);
}

async function createChecklistByUi(page) {
  await page.goto(`${baseUrl}/admin/daily-checklists/setting`, { waitUntil: 'networkidle' });
  await mark(page, '시나리오 3. 일상점검 체크리스트 설정 화면');

  await page.click('#btnAddChecklist');
  await page.waitForSelector('#layout.panel-open #sidePanel');
  await mark(page, '체크리스트 추가 패널 열림');

  await page.fill('#checklistName', `${token} 체크리스트`);
  const itemRows = page.locator('#itemTableBody tr');
  await itemRows.nth(0).locator('input[name="itemName"]').fill('배수로 상태');
  await itemRows.nth(0).locator('select[name="inputType"]').selectOption('SELECT');
  await itemRows.nth(0).locator('input[name="optionValues"]').fill('양호,주의,불량');
  await itemRows.nth(0).locator('select[name="requiredYn"]').selectOption('Y');

  await page.click('#btnAddItem');
  await itemRows.nth(1).locator('input[name="itemName"]').fill('조명 상태');
  await itemRows.nth(1).locator('select[name="inputType"]').selectOption('SELECT');
  await itemRows.nth(1).locator('input[name="optionValues"]').fill('정상,점검필요,고장');
  await itemRows.nth(1).locator('select[name="requiredYn"]').selectOption('Y');

  await mark(page, '체크리스트명, 유형별 항목, 답변 옵션 입력');
  const saveResponse = page.waitForResponse((res) => res.url().includes('/admin/daily-checklists/save') && res.request().method() === 'POST');
  await page.click('#btnSave');
  const json = await (await saveResponse).json();
  await ok('checklist saved', json.code === '0000' && json.data && json.data.checklistId);
  const checklistId = json.data.checklistId;
  cleanups.push(() => page.request.post(`${baseUrl}/admin/daily-checklists/delete`, { form: { checklistId } }));
  await mark(page, '체크리스트 저장 완료');

  await page.fill('#keyword', token);
  await page.click('#btnSearch');
  await wait();
  await ok('checklist visible in list', (await page.locator('#checklistTableBody').innerText()).includes(token));
  await mark(page, '저장한 체크리스트 목록 조회 확인');
  return checklistId;
}

async function createDailyCheckByFieldUi(page, checklistId) {
  await page.goto(`${baseUrl}/manage/daily-checks/form`, { waitUntil: 'networkidle' });
  await mark(page, '시나리오 4. 현장 사용자 일상점검 작성 화면');
  await page.selectOption('#checklistId', String(checklistId));
  await page.fill('#checkTitle', `${token} bridge-1-up`);
  await page.waitForFunction(() => document.querySelectorAll('#itemList .quick-option').length >= 3);
  await mark(page, '관리자가 등록한 체크리스트 항목과 답변 옵션 렌더링');

  await page.locator('#itemList .check-card').nth(0).locator('.quick-option', { hasText: '정상' }).click();
  await page.locator('#itemList .check-card').nth(1).locator('.quick-option', { hasText: '확인 필요' }).click();
  await page.locator('#itemList .check-card').nth(1).locator('.item-memo').fill(`${token} item memo`);
  await page.fill('#remark', `${token} 현장 점검 완료`);
  await mark(page, '항목별 답변 및 비고 입력');

  const saveResponse = page.waitForResponse((res) => res.url().includes('/manage/daily-checks/save-with-photos') && res.request().method() === 'POST');
  await page.click('#btnDoneDailyCheck');
  const response = await saveResponse;
  await ok('daily check save response', response.ok());
  await page.waitForURL(/\/manage\/daily-checks$/, { timeout: 15000 }).catch(() => {});
  await mark(page, '일상점검 저장 완료');

  await page.goto(`${baseUrl}/manage/daily-checks`, { waitUntil: 'networkidle' });
  await page.fill('#keyword', token);
  await page.click('#btnSearch');
  await wait();
  await ok('daily history visible', (await page.locator('#historyList').innerText()).includes(token));
  await mark(page, '현장 사용자 일상점검 이력 조회 확인');

  const history = await page.request.get(`${baseUrl}/manage/daily-checks/data`, {
    params: { startDate: today, endDate: today, keyword: token },
  });
  const historyJson = await history.json();
  const found = (historyJson.list || []).find((row) => String(row.remark || '').includes(token) || String(row.checklistName || '').includes(token));
  await ok('daily check id found', Boolean(found && found.checkId));
  const checkId = found.checkId;
  return checkId;
}

async function scenarioNotification(page) {
  await page.goto(`${baseUrl}/admin/notification/recipients`, { waitUntil: 'networkidle' });
  await mark(page, '시나리오 2. 알림톡 수신자 관리 화면');

  await page.locator('.type-card').first().click();
  await wait();
  await mark(page, '알림 유형 선택, 미등록/등록 수신자 영역 확인');

  const firstEnabled = page.locator('.available-check:not([disabled])').first();
  if (await firstEnabled.count()) {
    await firstEnabled.check();
    await page.click('#btnAssign');
    await wait(2200);
    await ok('notification assign visible', await page.locator('.assigned-check').count() > 0);
    await mark(page, '미등록 사용자 → 등록 수신자 배정 확인');

    await page.locator('.assigned-check').first().check();
    await page.click('#btnUnassign');
    await wait(1800);
    await mark(page, '등록 수신자 해제 확인');
  } else {
    await mark(page, '배정 가능한 사용자가 없어 화면 구조만 확인');
  }
}

async function scenarioAdminSituation(page) {
  await page.goto(`${baseUrl}/admin/situation-logs`, { waitUntil: 'networkidle' });
  await mark(page, '시나리오 6. 관리자 상황일지 화면');

  await page.click('#btnNewSituation');
  await page.waitForSelector('#layout.panel-open #sidePanel');
  await page.fill('#eventTime', '09:30');
  await page.fill('#title', `${token} 관리자 상황`);
  await page.fill('#content', `${token} 관리자 상황일지 등록 내용`);
  await mark(page, '상황 등록 패널 입력');

  const saveResponse = page.waitForResponse((res) => res.url().includes('/admin/situation-logs/save') && res.request().method() === 'POST');
  await page.click('#btnSaveSituation');
  const json = await (await saveResponse).json();
  await ok('admin situation saved', json.code === '0000' && json.data && json.data.situationId);
  const situationId = json.data.situationId;
  cleanups.push(() => page.request.post(`${baseUrl}/admin/situation-logs/delete`, { form: { situationId } }));
  await mark(page, '관리자 상황일지 저장 완료');
  if (await page.locator('.swal2-confirm').isVisible().catch(() => false)) {
    await page.locator('.swal2-confirm').click();
    await page.waitForTimeout(300);
  }

  await page.fill('#keyword', token);
  await page.click('#btnSearch');
  await wait();
  await ok('admin situation visible', (await page.locator('#situationTableBody').innerText()).includes(token));
  await mark(page, '관리자 상황일지 목록 조회 확인');
}

async function scenarioFieldSituation(page) {
  await page.goto(`${baseUrl}/manage/situation-logs`, { waitUntil: 'networkidle' });
  await mark(page, '시나리오 7. 현장 사용자 상황일지 화면');

  await page.click('#btnNew');
  await page.waitForSelector('#situationModal.show');
  await page.fill('#eventTime', '11:20');
  await page.fill('#title', `${token} 현장 상황`);
  await page.fill('#content', `${token} 현장 사용자가 등록한 시간대별 상황`);
  await mark(page, '현장 사용자 상황 등록 모달 입력');

  const saveResponse = page.waitForResponse((res) => res.url().includes('/manage/situation-logs/save') && res.request().method() === 'POST');
  await page.click('#btnSave');
  const json = await (await saveResponse).json();
  await ok('field situation saved', json.code === '0000' && json.data && json.data.situationId);
  const situationId = json.data.situationId;
  cleanups.push(() => page.request.post(`${baseUrl}/manage/situation-logs/delete`, { form: { situationId } }));
  await mark(page, '현장 사용자 상황일지 저장 완료');
  if (await page.locator('.swal2-confirm').isVisible().catch(() => false)) {
    await page.locator('.swal2-confirm').click();
    await page.waitForTimeout(300);
  }

  await page.fill('#keyword', token);
  await page.click('#btnSearch');
  await wait();
  await ok('field situation visible', (await page.locator('#situationList').innerText()).includes(token));
  await mark(page, '현장 사용자 상황일지 목록 조회 확인');
}

async function scenarioReports(page) {
  await page.goto(`${baseUrl}/admin/ims/dashboard`, { waitUntil: 'networkidle' });
  await mark(page, '시나리오 1. 현장관리 보고서 양식 선택');
  await page.selectOption('#ledgerExportTemplate', 'PHOTO_BOARD');
  await page.selectOption('#ledgerExportFormat', 'pdf');
  await mark(page, '사진대지 + PDF 선택 가능 확인');
  await page.selectOption('#ledgerExportTemplate', 'MAINTENANCE_RESULT');
  await page.selectOption('#ledgerExportFormat', 'docx');
  await mark(page, '유지관리 결과보고서 + DOCX 선택 확인');
}

async function scenarioAdminDailyDetail(page, checkId) {
  await page.goto(`${baseUrl}/admin/daily-checks`, { waitUntil: 'networkidle' });
  await page.fill('#keyword', token);
  await page.click('#btnSearch');
  await wait();
  await mark(page, '시나리오 5. 관리자 일상점검 목록 조회');
  await ok('admin daily list visible', (await page.locator('#dailyCheckTableBody').innerText()).includes(token));
  await page.evaluate((id) => window.loadDailyCheckDetail && window.loadDailyCheckDetail(id), checkId);
  await page.waitForSelector('#layout.panel-open #sidePanel');
  await mark(page, '관리자 일상점검 상세 및 DOCX 출력 버튼 확인');
}

async function main() {
  const browser = await chromium.launch({ headless: false, slowMo: 160 });
  const adminPage = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  const fieldPage = await browser.newPage({ viewport: { width: 430, height: 900 } });
  let checkId = null;

  try {
    await login(adminPage, 'admin', 'admin123', '/admin/login');
    await scenarioReports(adminPage);
    await scenarioNotification(adminPage);
    const checklistId = await createChecklistByUi(adminPage);

    await login(fieldPage, 'field', 'field123', '/manage/login');
    checkId = await createDailyCheckByFieldUi(fieldPage, checklistId);

    await scenarioAdminDailyDetail(adminPage, checkId);
    await scenarioAdminSituation(adminPage);
    await scenarioFieldSituation(fieldPage);

    await mark(adminPage, '시연 QA 완료: 브라우저를 잠시 열어둡니다.');
    await mark(fieldPage, '시연 QA 완료: 브라우저를 잠시 열어둡니다.');
    console.log('VISIBLE_DEMO_QA_RESULT=PASS');
    await wait(holdMs);
  } finally {
    for (const cleanup of cleanups.reverse()) {
      await cleanup().catch(() => {});
    }
    await browser.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
