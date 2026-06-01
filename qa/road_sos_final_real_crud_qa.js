const { chromium } = require('playwright');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';
const today = process.env.ROAD_SOS_QA_DATE || new Date().toISOString().slice(0, 10);
const token = `DAILY-QA-${Date.now()}`;

function assert(condition, message) {
  if (!condition) throw new Error(message || 'assertion failed');
}

function hasBrokenKorean(text) {
  const value = text || '';
  return value.includes('占') || value.includes('筌') || value.includes('�');
}

async function login(page, userId, userPwd, path) {
  await page.goto(`${baseUrl}${path}`, { waitUntil: 'domcontentloaded' });
  await page.fill('input[name="userId"]', userId);
  await page.fill('input[name="userPwd"]', userPwd);
  await page.click('button[type="submit"]');
  await page.waitForLoadState('networkidle');
}

async function createChecklist(request) {
  const params = new URLSearchParams();
  params.append('checklistName', `${token} 교량점검`);
  params.append('siteCd', '');
  params.append('commonYn', 'Y');
  params.append('useYn', 'Y');
  params.append('sortOrd', '1');

  [
    ['난간 및 포장 상태', 'SELECT', '정상,이상,확인 필요', 'Y', 'Y', '1'],
    ['배수구 막힘 여부', 'SELECT', '정상,이상,확인 필요', 'Y', 'Y', '2'],
    ['현장 특이사항', 'TEXT', '', 'N', 'Y', '3'],
  ].forEach(([itemName, inputType, optionValues, requiredYn, itemUseYn, itemSortOrd]) => {
    params.append('itemName', itemName);
    params.append('inputType', inputType);
    params.append('optionValues', optionValues);
    params.append('requiredYn', requiredYn);
    params.append('itemUseYn', itemUseYn);
    params.append('itemSortOrd', itemSortOrd);
  });

  const response = await request.post(`${baseUrl}/admin/daily-checklists/save`, {
    data: params.toString(),
    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
  });
  const json = await response.json();
  assert(json.code === '0000' && json.data && json.data.checklistId, `checklist create failed ${JSON.stringify(json)}`);
  return json.data.checklistId;
}

async function run() {
  const browser = await chromium.launch({ headless: true });
  const adminPage = await browser.newPage();
  const fieldPage = await browser.newPage({ viewport: { width: 430, height: 900 } });
  let checklistId;
  let checkId;

  fieldPage.on('dialog', (dialog) => dialog.accept());

  try {
    await login(adminPage, 'admin', 'admin123', '/admin/login');
    checklistId = await createChecklist(adminPage.request);

    const detailResponse = await adminPage.request.get(`${baseUrl}/admin/daily-checklists/${checklistId}`);
    const checklistDetail = await detailResponse.json();
    assert(checklistDetail.code === '0000', 'checklist detail failed');
    assert((checklistDetail.data.items || []).length === 3, 'checklist items missing');

    await login(fieldPage, 'field', 'field123', '/manage/login');
    await fieldPage.goto(`${baseUrl}/manage/daily-checks/form`, { waitUntil: 'networkidle' });
    await fieldPage.selectOption('#checklistId', String(checklistId));
    await fieldPage.fill('#checkTitle', `${token} bridge-1-up`);
    await fieldPage.waitForFunction(() => document.querySelectorAll('#itemList .quick-option').length >= 6);

    const bodyText = await fieldPage.locator('body').innerText();
    assert(!hasBrokenKorean(bodyText), 'daily check form has broken korean');
    assert(bodyText.includes('점검 대상/타이틀'), 'target title field missing');
    assert(bodyText.includes('정상') && bodyText.includes('이상') && bodyText.includes('확인 필요'), 'quick status buttons missing');

    await fieldPage.locator('#itemList .check-card').nth(0).locator('.quick-option', { hasText: '정상' }).click();
    await fieldPage.locator('#itemList .check-card').nth(1).locator('.quick-option', { hasText: '확인 필요' }).click();
    await fieldPage.locator('#itemList .check-card').nth(1).locator('.item-memo').fill(`${token} 배수 확인 필요`);
    await fieldPage.locator('textarea[name^="itemValue_"]').fill(`${token} 특이사항 없음`);
    await fieldPage.fill('#remark', `${token} 현장 일상점검 완료`);

    const saveWait = fieldPage.waitForResponse((res) => res.url().includes('/manage/daily-checks/save-with-photos') && res.request().method() === 'POST');
    await fieldPage.click('#btnDoneDailyCheck');
    const saveResponse = await saveWait;
    assert(saveResponse.ok(), `daily check save http ${saveResponse.status()}`);

    await fieldPage.waitForURL(/\/manage\/daily-checks$/, { timeout: 15000 }).catch(() => {});
    await fieldPage.fill('#keyword', token);
    await fieldPage.click('#btnSearch');
    await fieldPage.waitForTimeout(700);
    const historyText = await fieldPage.locator('#historyList').innerText();
    assert(historyText.includes(`${token} bridge-1-up`), 'daily check title not visible in history');
    assert(historyText.includes('점검완료'), 'daily check done status not visible');

    const dataResponse = await fieldPage.request.get(`${baseUrl}/manage/daily-checks/data`, {
      params: { startDate: today, endDate: today, keyword: token },
    });
    const dataJson = await dataResponse.json();
    checkId = dataJson.list && dataJson.list[0] && dataJson.list[0].checkId;
    assert(checkId, 'saved daily check id not found');

    const savedDetailResponse = await fieldPage.request.get(`${baseUrl}/manage/daily-checks/${checkId}`);
    const savedDetail = await savedDetailResponse.json();
    assert(savedDetail.code === '0000', 'field daily check detail failed');
    assert((savedDetail.data.checkTitle || '').includes('bridge-1-up'), 'check title not saved');
    assert((savedDetail.data.items || []).some((item) => item.checkValue === '확인 필요' && (item.checkMemo || '').includes('배수')), 'item memo not saved');

    console.log('DAILY_CHECK_FAST_UI_QA_RESULT=PASS');
  } finally {
    if (checklistId) {
      await adminPage.request.post(`${baseUrl}/admin/daily-checklists/delete`, { form: { checklistId } }).catch(() => {});
    }
    await browser.close();
  }
}

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
