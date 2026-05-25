const { chromium } = require('playwright');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';

async function login(page, userId, userPwd, loginPath) {
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

function isZipPackage(buffer) {
  return buffer && buffer.length > 2 && buffer[0] === 0x50 && buffer[1] === 0x4b;
}

async function expectDocumentDownload(request, name, url) {
  const response = await request.get(url);
  await expectOk(`${name} status`, response.ok());
  const buffer = await response.body();
  await expectOk(`${name} package`, isZipPackage(buffer));
}

async function expectReportExportDownload(request, name, format) {
  const response = await request.post(`${baseUrl}/admin/reports/export`, {
    form: {
      reportNos: 'LOCAL-QA-REPORT',
      template: 'POTHOLE_LEDGER',
      format
    }
  });
  await expectOk(`${name} status`, response.ok());
  const buffer = await response.body();
  await expectOk(`${name} package`, isZipPackage(buffer));
}

async function expectTemplateExportDownload(request, name, template, format) {
  const response = await request.post(`${baseUrl}/admin/reports/export`, {
    form: {
      reportNos: 'LOCAL-QA-REPORT',
      template,
      format
    }
  });
  await expectOk(`${name} status`, response.ok());
  const buffer = await response.body();
  await expectOk(`${name} package`, isZipPackage(buffer));
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  try {
    await login(page, 'admin', 'admin123', '/admin/login');
    await expectOk('admin login', page.url().includes('/admin/'));

    await page.goto(`${baseUrl}/admin/ims/dashboard`, { waitUntil: 'domcontentloaded' });
    await expectOk('ims dashboard page', await page.locator('body').innerText().then(t => t.includes('현장') || t.includes('접수')));
    await expectOk('ledger export template select', await page.locator('#ledgerExportTemplate option').evaluateAll(options => {
      const values = options.map(option => option.value);
      return values.includes('POTHOLE_LEDGER') && values.includes('PHOTO_BOARD') && values.includes('MAINTENANCE_RESULT');
    }));
    await expectOk('ledger export format select', await page.locator('#ledgerExportFormat option').evaluateAll(options => {
      return options.map(option => option.value).join(',') === 'pdf,docx,hwpx';
    }));

    await page.goto(`${baseUrl}/admin/notification/recipients`, { waitUntil: 'domcontentloaded' });
    await expectOk('notification recipient page', await page.locator('body').innerText().then(t => t.includes('알림') || t.includes('수신')));

    await page.goto(`${baseUrl}/admin/daily-checklists/setting`, { waitUntil: 'domcontentloaded' });
    await expectOk('daily checklist setting page', await page.locator('body').innerText().then(t => t.includes('체크리스트')));

    await page.goto(`${baseUrl}/admin/daily-checks`, { waitUntil: 'domcontentloaded' });
    await expectOk('admin daily check page', await page.locator('body').innerText().then(t => t.includes('일상점검')));
    await expectOk('daily check export buttons', await page.locator('#btnDailyCheckDocx').count() === 1 && await page.locator('#btnDailyCheckHwpx').count() === 1);

    await page.goto(`${baseUrl}/admin/situation-logs`, { waitUntil: 'domcontentloaded' });
    await expectOk('situation log page', await page.locator('body').innerText().then(t => t.includes('상황일지')));
    await expectOk('situation export buttons', await page.locator('#btnExportSituationDocx').count() === 1 && await page.locator('#btnExportSituationHwpx').count() === 1);

    const templates = await page.request.get(`${baseUrl}/admin/reports/templates`);
    const templatesJson = await templates.json();
    await expectOk('report template list', templatesJson.success === true && Array.isArray(templatesJson.data) && templatesJson.data.length >= 9);
    await expectReportExportDownload(page.request, 'pothole ledger docx export', 'docx');
    await expectReportExportDownload(page.request, 'pothole ledger hwpx export', 'hwpx');
    await expectTemplateExportDownload(page.request, 'photo board docx export', 'PHOTO_BOARD', 'docx');
    await expectTemplateExportDownload(page.request, 'maintenance result hwpx export', 'MAINTENANCE_RESULT', 'hwpx');

    const unsupportedPdf = await page.request.post(`${baseUrl}/admin/reports/export`, {
      form: {
        reportNos: 'LOCAL-QA-REPORT',
        template: 'PHOTO_BOARD',
        format: 'pdf'
      }
    });
    await expectOk('non ledger pdf rejected', unsupportedPdf.status() === 400);

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

    await expectDocumentDownload(
      page.request,
      'situation docx export',
      `${baseUrl}/admin/situation-logs/export?startDate=2026-05-25&endDate=2026-05-25&keyword=Playwright%20QA%20Situation&format=docx`
    );
    await expectDocumentDownload(
      page.request,
      'situation hwpx export',
      `${baseUrl}/admin/situation-logs/export?startDate=2026-05-25&endDate=2026-05-25&keyword=Playwright%20QA%20Situation&format=hwpx`
    );

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
    await login(fieldPage, 'field', 'field123', '/manage/login');
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
