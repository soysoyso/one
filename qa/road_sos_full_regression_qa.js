const { chromium } = require('playwright');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';
const today = process.env.ROAD_SOS_QA_DATE || '2026-05-25';

const reportTemplates = [
  'POTHOLE_LEDGER',
  'POTHOLE_SUMMARY',
  'MAINTENANCE_LOG',
  'LANDSCAPE_DAILY_WORK',
  'MAINTENANCE_RESULT',
  'PHOTO_BOARD'
];

function isZipPackage(buffer) {
  return buffer && buffer.length > 2 && buffer[0] === 0x50 && buffer[1] === 0x4b;
}

async function expectOk(name, condition) {
  if (!condition) {
    throw new Error(`${name} failed`);
  }
  console.log(`OK ${name}`);
}

async function login(page, userId, userPwd, loginPath) {
  await page.goto(`${baseUrl}${loginPath}`, { waitUntil: 'domcontentloaded' });
  await page.fill('input[name="userId"]', userId);
  await page.fill('input[name="userPwd"]', userPwd);
  await page.click('button[type="submit"]');
  await page.waitForLoadState('networkidle');
}

async function assertCleanKorean(page, name) {
  const text = await page.locator('body').innerText();
  const brokenPattern = /�|泥|愿|珥|嫄|異쒕|議고|誘몄|\?꾩|\?뚮|\?쇱|\?곹|\?ㅼ|\?섏|\?대|\?쒖|\?묒|\?/;
  await expectOk(`${name} Korean text`, !brokenPattern.test(text));
}

async function expectDocument(request, name, method, url, options = {}) {
  const response = method === 'post' ? await request.post(url, options) : await request.get(url, options);
  await expectOk(`${name} status`, response.ok());
  const buffer = await response.body();
  await expectOk(`${name} zip package`, isZipPackage(buffer));
}

async function expectPdf(request, name, method, url, options = {}) {
  const response = method === 'post' ? await request.post(url, options) : await request.get(url, options);
  await expectOk(`${name} status`, response.ok());
  const buffer = await response.body();
  await expectOk(`${name} pdf package`, buffer && buffer.slice(0, 4).toString('utf8') === '%PDF');
}

async function createChecklist(request, name) {
  const params = new URLSearchParams();
  params.append('checklistName', name);
  params.append('siteCd', '');
  params.append('commonYn', 'Y');
  params.append('useYn', 'Y');
  params.append('sortOrd', '0');
  [
    ['포장 상태', 'CHECK', 'Y', 'Y', '1'],
    ['배수 상태', 'CHECK', 'Y', 'Y', '2'],
    ['특이사항', 'TEXT', 'N', 'Y', '3']
  ].forEach(([itemName, inputType, requiredYn, itemUseYn, itemSortOrd]) => {
    params.append('itemName', itemName);
    params.append('inputType', inputType);
    params.append('requiredYn', requiredYn);
    params.append('itemUseYn', itemUseYn);
    params.append('itemSortOrd', itemSortOrd);
  });

  const response = await request.post(`${baseUrl}/admin/daily-checklists/save`, {
    data: params.toString(),
    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' }
  });
  const raw = await response.text();
  let json;
  try {
    json = JSON.parse(raw);
  } catch (e) {
    json = { status: response.status(), raw: raw.slice(0, 300) };
  }
  console.log(`STATE daily checklist create ${JSON.stringify(json)}`);
  await expectOk('daily checklist create', json.code === '0000' && json.data && json.data.checklistId);
  return json.data.checklistId;
}

async function deleteChecklist(request, checklistId) {
  if (!checklistId) return;
  const response = await request.post(`${baseUrl}/admin/daily-checklists/delete`, {
    form: { checklistId }
  });
  const json = await response.json();
  await expectOk('daily checklist delete', json.code === '0000');
}

async function createNotificationRecipient(request) {
  const response = await request.post(`${baseUrl}/admin/notification/recipients/save`, {
    form: {
      notificationType: 'POTHOLE_RECEIPT',
      recipientNm: 'Full Regression Recipient',
      phoneNo: '01012345678',
      siteCd: '',
      useYn: 'Y',
      sortOrd: '0',
      remark: 'Full regression masking and CRUD check'
    }
  });
  const json = await response.json();
  await expectOk('notification recipient create', json.code === '0000' && json.data && json.data.recipientId);
  return json.data.recipientId;
}

async function deleteNotificationRecipient(request, recipientId) {
  if (!recipientId) return;
  const response = await request.post(`${baseUrl}/admin/notification/recipients/delete`, {
    form: { recipientId }
  });
  const json = await response.json();
  await expectOk('notification recipient delete', json.code === '0000');
}

async function createDailyCheck(fieldRequest, checklistId, itemValues) {
  const form = {
    checklistId: String(checklistId),
    checkDate: today,
    remark: 'Full regression daily check'
  };
  for (const [itemId, value] of Object.entries(itemValues)) {
    form[`itemValue_${itemId}`] = value;
  }

  const image = Buffer.from(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAFgwJ/lm2lXwAAAABJRU5ErkJggg==',
    'base64'
  );
  const response = await fieldRequest.post(`${baseUrl}/manage/daily-checks/save-with-photos`, {
    multipart: {
      ...form,
      beforePhotos: { name: 'before.png', mimeType: 'image/png', buffer: image },
      afterPhotos: { name: 'after.png', mimeType: 'image/png', buffer: image }
    }
  });
  const json = await response.json();
  await expectOk('field daily check save with photos', json.code === '0000' && json.data && json.data.checkId);
  return json.data.checkId;
}

async function createSituation(request) {
  const response = await request.post(`${baseUrl}/admin/situation-logs/save`, {
    form: {
      logDate: today,
      shiftCd: 'DAY',
      eventTime: '09:30',
      title: 'Full Regression Situation',
      content: 'Full regression situation content',
      siteCd: 'LOCAL',
      useYn: 'Y'
    }
  });
  const json = await response.json();
  await expectOk('situation create', json.code === '0000' && json.data && json.data.situationId);
  return json.data.situationId;
}

async function deleteSituation(request, situationId) {
  if (!situationId) return;
  const response = await request.post(`${baseUrl}/admin/situation-logs/delete`, {
    form: { situationId }
  });
  const json = await response.json();
  await expectOk('situation delete', json.code === '0000');
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const adminPage = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  let checklistId = null;
  let recipientId = null;
  let situationId = null;

  try {
    await login(adminPage, 'admin', 'admin123', '/admin/login');
    await expectOk('admin login', adminPage.url().includes('/admin/'));

    const screenChecks = [
      ['/admin/ims/dashboard', '현장관리', '#ledgerExportTemplate'],
      ['/admin/notification/recipients', '알림톡 수신자 설정', '#recipientTableBody'],
      ['/admin/daily-checklists/setting', '일상점검 체크리스트 설정', '#checklistTableBody'],
      ['/admin/daily-checks', '일상점검 관리', '#dailyCheckTableBody'],
      ['/admin/situation-logs', '상황일지 관리', '#situationTableBody']
    ];

    for (const [path, expectedText, selector] of screenChecks) {
      await adminPage.goto(`${baseUrl}${path}`, { waitUntil: 'domcontentloaded' });
      await expectOk(`${path} visible`, await adminPage.locator('body').innerText().then(text => text.includes(expectedText)));
      await expectOk(`${path} selector`, await adminPage.locator(selector).count() === 1);
      await assertCleanKorean(adminPage, path);
    }

    await adminPage.goto(`${baseUrl}/admin/ims/dashboard`, { waitUntil: 'domcontentloaded' });
    await adminPage.selectOption('#ledgerExportTemplate', 'PHOTO_BOARD');
    await expectOk('non-ledger pdf option disabled', await adminPage.locator('#ledgerExportFormat option[value="pdf"]').isDisabled());
    await expectOk('non-ledger format auto docx', await adminPage.locator('#ledgerExportFormat').inputValue() === 'docx');

    const templates = await adminPage.request.get(`${baseUrl}/admin/reports/templates`);
    const templateJson = await templates.json();
    await expectOk('report template list API', templateJson.success === true && templateJson.data.length >= 9);
    for (const template of reportTemplates) {
      await expectDocument(adminPage.request, `${template} docx export`, 'post', `${baseUrl}/admin/reports/export`, {
        form: { reportNos: 'LOCAL-QA-REPORT', template, format: 'docx' }
      });
      await expectDocument(adminPage.request, `${template} hwpx export`, 'post', `${baseUrl}/admin/reports/export`, {
        form: { reportNos: 'LOCAL-QA-REPORT', template, format: 'hwpx' }
      });
    }
    await expectPdf(adminPage.request, 'pothole ledger pdf export', 'post', `${baseUrl}/admin/reports/export`, {
      form: { reportNos: 'LOCAL-QA-REPORT', template: 'POTHOLE_LEDGER', format: 'pdf' }
    });
    const badPdf = await adminPage.request.post(`${baseUrl}/admin/reports/export`, {
      form: { reportNos: 'LOCAL-QA-REPORT', template: 'PHOTO_BOARD', format: 'pdf' }
    });
    await expectOk('non-ledger pdf rejected', badPdf.status() === 400);

    recipientId = await createNotificationRecipient(adminPage.request);
    await adminPage.goto(`${baseUrl}/admin/notification/recipients`, { waitUntil: 'domcontentloaded' });
    await adminPage.fill('#keyword', 'Full Regression Recipient');
    await adminPage.click('#btnSearch');
    await adminPage.waitForTimeout(500);
    const recipientText = await adminPage.locator('#recipientTableBody').innerText();
    await expectOk('notification phone masked in list', recipientText.includes('010-****-5678') && !recipientText.includes('010-1234-5678'));
    const recipientDetail = await adminPage.request.get(`${baseUrl}/admin/notification/recipients/${recipientId}`);
    const recipientDetailJson = await recipientDetail.json();
    await expectOk('notification recipient detail full phone', recipientDetailJson.code === '0000' && recipientDetailJson.data.phoneNo === '010-1234-5678');

    checklistId = await createChecklist(adminPage.request, 'Full Regression Checklist');
    const checklistDetail = await adminPage.request.get(`${baseUrl}/admin/daily-checklists/${checklistId}`);
    const checklistJson = await checklistDetail.json();
    await expectOk('daily checklist detail', checklistJson.code === '0000' && checklistJson.data.items.length === 3);

    const fieldContext = await browser.newContext({ viewport: { width: 390, height: 844 } });
    const fieldPage = await fieldContext.newPage();
    await login(fieldPage, 'field', 'field123', '/manage/login');
    await fieldPage.goto(`${baseUrl}/manage/daily-checks/form`, { waitUntil: 'domcontentloaded' });
    await expectOk('field daily form visible', await fieldPage.locator('body').innerText().then(text => text.includes('일상점검')));
    await assertCleanKorean(fieldPage, 'field daily form');

    const itemValues = {};
    for (const item of checklistJson.data.items) {
      itemValues[item.itemId] = item.inputType === 'TEXT' ? '특이사항 없음' : 'Y';
    }
    const checkId = await createDailyCheck(fieldPage.request, checklistId, itemValues);
    await fieldContext.close();

    const dailyDetail = await adminPage.request.get(`${baseUrl}/admin/daily-checks/${checkId}`);
    const dailyJson = await dailyDetail.json();
    await expectOk('admin daily check detail', dailyJson.code === '0000' && dailyJson.data.items.length >= 3);
    await expectOk('admin daily check photos', Array.isArray(dailyJson.data.photos) && dailyJson.data.photos.length >= 2);
    await expectDocument(adminPage.request, 'daily check docx export', 'get', `${baseUrl}/admin/daily-checks/export?checkIds=${checkId}&format=docx`);
    await expectDocument(adminPage.request, 'daily check hwpx export', 'get', `${baseUrl}/admin/daily-checks/export?checkIds=${checkId}&format=hwpx`);

    const badSituation = await adminPage.request.post(`${baseUrl}/admin/situation-logs/save`, {
      form: { logDate: today, shiftCd: 'DAY', eventTime: '10:00', title: 'Missing Content', content: '', siteCd: 'LOCAL', useYn: 'Y' }
    });
    await expectOk('situation required validation', (await badSituation.json()).code === '9999');
    situationId = await createSituation(adminPage.request);
    const situationDetail = await adminPage.request.get(`${baseUrl}/admin/situation-logs/${situationId}`);
    const situationJson = await situationDetail.json();
    await expectOk('situation detail', situationJson.code === '0000' && situationJson.data.title === 'Full Regression Situation');
    await expectDocument(adminPage.request, 'situation docx export', 'get', `${baseUrl}/admin/situation-logs/export?startDate=${today}&endDate=${today}&keyword=Full%20Regression%20Situation&format=docx`);
    await expectDocument(adminPage.request, 'situation hwpx export', 'get', `${baseUrl}/admin/situation-logs/export?startDate=${today}&endDate=${today}&keyword=Full%20Regression%20Situation&format=hwpx`);

    const fieldAdminAccess = await fieldPageRequest(browser, '/admin/daily-checks');
    console.log(`STATE field admin access ${JSON.stringify(fieldAdminAccess)}`);
    await expectOk(
      'field account admin access blocked',
      fieldAdminAccess.status === 403 ||
        fieldAdminAccess.url.includes('/admin/login') ||
        fieldAdminAccess.url.includes('/manage/login') ||
        fieldAdminAccess.url.includes('/login-error')
    );
  } finally {
    await deleteSituation(adminPage.request, situationId).catch(() => {});
    await deleteNotificationRecipient(adminPage.request, recipientId).catch(() => {});
    await deleteChecklist(adminPage.request, checklistId).catch(() => {});
    await browser.close();
  }
}

async function fieldPageRequest(browser, path) {
  const context = await browser.newContext();
  const page = await context.newPage();
  await login(page, 'field', 'field123', '/manage/login');
  const response = await page.goto(`${baseUrl}${path}`, { waitUntil: 'domcontentloaded' });
  const url = page.url();
  const status = response ? response.status() : 0;
  await context.close();
  return { url, status };
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
