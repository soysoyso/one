const { chromium } = require('playwright');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';

async function login(page, userId, userPwd, loginPath) {
  await page.goto(`${baseUrl}${loginPath}`, { waitUntil: 'domcontentloaded' });
  await page.fill('input[name="userId"]', userId);
  await page.fill('input[name="userPwd"]', userPwd);
  await page.click('button[type="submit"]');
  await page.waitForLoadState('networkidle');
}

async function ok(name, condition) {
  if (!condition) throw new Error(`${name} failed`);
  console.log(`OK ${name}`);
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const admin = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  const field = await browser.newPage({ viewport: { width: 390, height: 844 } });
  let checklistId = null;
  let situationId = null;

  try {
    await login(admin, 'admin', 'admin123', '/admin/login');
    await ok('admin login', admin.url().includes('/admin/'));

    await admin.goto(`${baseUrl}/admin/daily-checklists/setting`, { waitUntil: 'networkidle' });
    await admin.click('#btnAddChecklist');
    await admin.waitForTimeout(400);
    await ok('checklist add click opens panel', await admin.locator('#layout.panel-open #sidePanel').count() === 1);

    const title = `Click QA Checklist ${Date.now()}`;
    await admin.fill('#checklistName', title);
    await admin.fill('input[name="itemName"]', '배수로 상태');
    await admin.selectOption('select[name="inputType"]', 'SELECT');
    await admin.fill('input[name="optionValues"]', '양호,주의,불량');
    await admin.selectOption('select[name="requiredYn"]', 'Y');

    const checklistSave = admin.waitForResponse(resp => resp.url().includes('/admin/daily-checklists/save') && resp.request().method() === 'POST');
    await admin.click('#btnSave');
    const checklistResponse = await checklistSave;
    const checklistJson = await checklistResponse.json();
    await ok('checklist ui save response', checklistJson.code === '0000');
    checklistId = checklistJson.data && checklistJson.data.checklistId;
    await ok('checklist id returned', Boolean(checklistId));

    const checklistDetail = await admin.request.get(`${baseUrl}/admin/daily-checklists/${checklistId}`);
    const checklistDetailJson = await checklistDetail.json();
    await ok('checklist option saved', checklistDetailJson.data.items[0].optionValues === '양호,주의,불량');

    await login(field, 'field', 'field123', '/manage/login');
    field.on('dialog', dialog => dialog.accept());
    await field.goto(`${baseUrl}/manage/daily-checks/form`, { waitUntil: 'networkidle' });
    await field.selectOption('#checklistId', String(checklistId));
    await field.waitForFunction(() => document.querySelectorAll('select[name^="itemValue_"] option[value="주의"]').length > 0);
    await ok('field form renders custom answers', await field.locator('select[name^="itemValue_"] option[value="불량"]').count() === 1);
    await field.selectOption('select[name^="itemValue_"]', '주의');
    const dailySave = field.waitForResponse(resp => resp.url().includes('/manage/daily-checks/save-with-photos') && resp.request().method() === 'POST');
    await field.click('#btnSaveDailyCheck');
    const dailyResponse = await dailySave;
    await ok('field daily check save', dailyResponse.ok());
    await field.waitForURL(/\/manage\/daily-checks$/, { timeout: 10000 });
    await field.waitForSelector('#historyList .card');
    await ok('field daily history page', await field.locator('body').innerText().then(text => text.includes('일상점검 이력')));
    await field.locator('#historyList .card').first().click();
    await field.waitForSelector('#detailModal.show');
    await ok('field daily history detail', await field.locator('#detailItems').innerText().then(text => text.includes('배수로 상태')));

    await admin.goto(`${baseUrl}/admin/situation-logs`, { waitUntil: 'networkidle' });
    await admin.click('#btnNewSituation');
    await admin.waitForTimeout(400);
    await ok('situation add click opens panel', await admin.locator('#layout.panel-open #sidePanel').count() === 1);
    await admin.fill('#eventTime', '09:30');
    await admin.fill('#title', `Click QA Situation ${Date.now()}`);
    await admin.fill('#content', '시간대별 상황 등록 QA');

    const situationSave = admin.waitForResponse(resp => resp.url().includes('/admin/situation-logs/save') && resp.request().method() === 'POST');
    await admin.click('#btnSaveSituation');
    const situationResponse = await situationSave;
    const situationJson = await situationResponse.json();
    await ok('situation ui save response', situationJson.code === '0000');
    situationId = situationJson.data && situationJson.data.situationId;
    await ok('situation id returned', Boolean(situationId));

    const situationDetail = await admin.request.get(`${baseUrl}/admin/situation-logs/${situationId}`);
    const situationDetailJson = await situationDetail.json();
    await ok('situation detail saved', situationDetailJson.data.content === '시간대별 상황 등록 QA');

    await admin.goto(`${baseUrl}/admin/situation-logs`, { waitUntil: 'networkidle' });
    await ok('situation hwpx removed', await admin.locator('#btnExportSituationHwpx').count() === 0);
    await admin.goto(`${baseUrl}/admin/daily-checks`, { waitUntil: 'networkidle' });
    await ok('daily check hwpx removed', await admin.locator('#btnDailyCheckHwpx').count() === 0);
  } finally {
    if (situationId) {
      await admin.request.post(`${baseUrl}/admin/situation-logs/delete`, { form: { situationId } }).catch(() => {});
    }
    if (checklistId) {
      await admin.request.post(`${baseUrl}/admin/daily-checklists/delete`, { form: { checklistId } }).catch(() => {});
    }
    await browser.close();
  }
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
