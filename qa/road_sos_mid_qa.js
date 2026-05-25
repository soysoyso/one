const { chromium } = require('playwright');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';

async function login(page, userId, userPwd, loginType, loginPath) {
  await page.goto(`${baseUrl}${loginPath}`, { waitUntil: 'domcontentloaded' });
  await page.fill('input[name="userId"]', userId);
  await page.fill('input[name="userPwd"]', userPwd);
  await page.click('button[type="submit"]');
  await page.waitForLoadState('networkidle');
}

async function expectOk(name, condition) {
  if (!condition) {
    throw new Error(`${name} failed`);
  }
  console.log(`OK ${name}`);
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  try {
    await login(page, 'admin', 'admin123', 'admin', '/admin/login');
    await expectOk('admin login', page.url().includes('/admin/'));

    await page.goto(`${baseUrl}/admin/notification/recipients`, { waitUntil: 'domcontentloaded' });
    await expectOk('notification recipient page', await page.locator('body').innerText().then(t => t.includes('알림') || t.includes('수신')));

    await page.goto(`${baseUrl}/admin/daily-checklists/setting`, { waitUntil: 'domcontentloaded' });
    await expectOk('daily checklist setting page', await page.locator('body').innerText().then(t => t.includes('체크리스트')));

    await page.goto(`${baseUrl}/admin/daily-checks`, { waitUntil: 'domcontentloaded' });
    await expectOk('admin daily check page', await page.locator('body').innerText().then(t => t.includes('일상점검')));

    await page.goto(`${baseUrl}/admin/situation-logs`, { waitUntil: 'domcontentloaded' });
    await expectOk('situation log page', await page.locator('body').innerText().then(t => t.includes('상황일지')));

    const badSave = await page.request.post(`${baseUrl}/admin/situation-logs/save`, {
      form: {
        logDate: '2026-05-25',
        shiftCd: 'DAY',
        eventTime: '09:30',
        title: 'QA Missing Content',
        content: '',
        siteCd: 'LOCAL',
        useYn: 'Y'
      }
    });
    const badJson = await badSave.json();
    await expectOk('situation required validation', badJson.code === '9999');

    const save = await page.request.post(`${baseUrl}/admin/situation-logs/save`, {
      form: {
        logDate: '2026-05-25',
        shiftCd: 'DAY',
        eventTime: '09:30',
        title: 'Playwright QA Situation',
        content: 'Playwright QA situation content',
        siteCd: 'LOCAL',
        useYn: 'Y'
      }
    });
    const saved = await save.json();
    await expectOk('situation create', saved.code === '0000' && saved.data && saved.data.situationId);

    const situationId = saved.data.situationId;
    const detail = await page.request.get(`${baseUrl}/admin/situation-logs/${situationId}`);
    const detailJson = await detail.json();
    await expectOk('situation detail', detailJson.code === '0000' && detailJson.data.title === 'Playwright QA Situation');

    const update = await page.request.post(`${baseUrl}/admin/situation-logs/save`, {
      form: {
        situationId,
        logDate: '2026-05-25',
        shiftCd: 'NIGHT',
        eventTime: '21:10',
        title: 'Playwright QA Situation Updated',
        content: 'Playwright QA situation content updated',
        siteCd: 'LOCAL',
        useYn: 'Y'
      }
    });
    const updated = await update.json();
    await expectOk('situation update', updated.code === '0000');

    const remove = await page.request.post(`${baseUrl}/admin/situation-logs/delete`, {
      form: { situationId }
    });
    const removed = await remove.json();
    await expectOk('situation delete', removed.code === '0000');

    const fieldContext = await browser.newContext({ viewport: { width: 390, height: 844 } });
    const fieldPage = await fieldContext.newPage();
    await login(fieldPage, 'field', 'field123', 'manage', '/manage/login');
    await fieldPage.goto(`${baseUrl}/manage/daily-checks/form`, { waitUntil: 'domcontentloaded' });
    await expectOk('field daily check form page', await fieldPage.locator('body').innerText().then(t => t.includes('일상점검') || t.includes('점검')));
    await fieldContext.close();
  } finally {
    await browser.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
