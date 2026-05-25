const { chromium } = require('playwright');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';
const holdMs = Number(process.env.VISIBLE_QA_HOLD_MS || 5000);
const stepMs = Number(process.env.VISIBLE_QA_STEP_MS || 900);

async function pause(page, label) {
  console.log(`VIEW ${label}`);
  await page.waitForTimeout(stepMs);
}

async function expectOk(name, condition) {
  if (!condition) {
    throw new Error(`${name} failed`);
  }
  console.log(`OK ${name}`);
}

async function bodyHas(page, expected) {
  const text = await page.locator('body').innerText();
  return text.includes(expected);
}

async function login(page, userId, userPwd, loginPath) {
  await page.goto(`${baseUrl}${loginPath}`, { waitUntil: 'domcontentloaded' });
  await pause(page, `${loginPath} loaded`);
  await page.fill('input[name="userId"]', userId);
  await page.fill('input[name="userPwd"]', userPwd);
  await page.click('button[type="submit"]');
  await page.waitForLoadState('networkidle');
  await pause(page, `${userId} logged in`);
}

async function createQaRecipient(page) {
  const save = await page.request.post(`${baseUrl}/admin/notification/recipients/save`, {
    form: {
      notificationType: 'POTHOLE_RECEIPT',
      recipientNm: 'Visible QA Recipient',
      phoneNo: '010-9876-1234',
      siteCd: '',
      useYn: 'Y',
      sortOrd: '0',
      remark: 'Visible QA masking check'
    }
  });
  const saved = await save.json();
  await expectOk('visible recipient create', saved.code === '0000' && saved.data && saved.data.recipientId);
  return saved.data.recipientId;
}

async function deleteQaRecipient(page, recipientId) {
  if (!recipientId) return;
  const remove = await page.request.post(`${baseUrl}/admin/notification/recipients/delete`, {
    form: { recipientId }
  });
  const removed = await remove.json();
  await expectOk('visible recipient delete', removed.code === '0000');
}

async function main() {
  const browser = await chromium.launch({
    headless: false,
    slowMo: 150
  });

  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  let recipientId = null;

  try {
    await login(page, 'admin', 'admin123', '/admin/login');

    await page.goto(`${baseUrl}/admin/ims/dashboard`, { waitUntil: 'domcontentloaded' });
    await pause(page, '현장관리 보고서 출력 UI');
    await expectOk('IMS page visible', await bodyHas(page, '현장관리'));
    await expectOk('template select visible', await page.locator('#ledgerExportTemplate').isVisible());
    await expectOk('format select visible', await page.locator('#ledgerExportFormat').isVisible());
    await page.selectOption('#ledgerExportTemplate', 'PHOTO_BOARD');
    await pause(page, '사진대지 선택 및 PDF 비활성화');
    const exportState = await page.evaluate(() => ({
      template: document.querySelector('#ledgerExportTemplate')?.value,
      format: document.querySelector('#ledgerExportFormat')?.value,
      pdfDisabled: document.querySelector('#ledgerExportFormat option[value="pdf"]')?.disabled
    }));
    console.log(`STATE export controls ${JSON.stringify(exportState)}`);
    await expectOk('pdf disabled for non-ledger template', await page.locator('#ledgerExportFormat option[value="pdf"]').isDisabled());
    await expectOk('format switched to docx', await page.locator('#ledgerExportFormat').inputValue() === 'docx');

    await page.goto(`${baseUrl}/admin/notification/recipients`, { waitUntil: 'domcontentloaded' });
    await pause(page, '알림톡 수신자 설정');
    await expectOk('recipient page visible', await bodyHas(page, '알림톡 수신자'));
    recipientId = await createQaRecipient(page);
    await page.fill('#keyword', 'Visible QA Recipient');
    await page.click('#btnSearch');
    await page.waitForTimeout(700);
    await pause(page, '알림톡 휴대전화번호 마스킹 확인');
    const recipientText = await page.locator('#recipientTableBody').innerText();
    await expectOk('visible phone masked', recipientText.includes('010-****-1234') && !recipientText.includes('010-9876-1234'));
    await deleteQaRecipient(page, recipientId);
    recipientId = null;

    await page.goto(`${baseUrl}/admin/daily-checklists/setting`, { waitUntil: 'domcontentloaded' });
    await pause(page, '일상점검 체크리스트 설정');
    await expectOk('checklist setting visible', await bodyHas(page, '체크리스트'));

    await page.goto(`${baseUrl}/admin/daily-checks`, { waitUntil: 'domcontentloaded' });
    await pause(page, '관리자 일상점검 조회');
    await expectOk('daily check page visible', await bodyHas(page, '일상점검'));
    await expectOk('daily check exports visible', await page.locator('#btnDailyCheckDocx').isVisible() && await page.locator('#btnDailyCheckHwpx').isVisible());

    await page.goto(`${baseUrl}/admin/situation-logs`, { waitUntil: 'domcontentloaded' });
    await pause(page, '상황일지 관리');
    await expectOk('situation page visible', await bodyHas(page, '상황일지'));
    await expectOk('situation exports visible', await page.locator('#btnExportSituationDocx').isVisible() && await page.locator('#btnExportSituationHwpx').isVisible());

    const mobile = await browser.newPage({ viewport: { width: 390, height: 844 } });
    await login(mobile, 'field', 'field123', '/manage/login');
    await mobile.goto(`${baseUrl}/manage/daily-checks/form`, { waitUntil: 'domcontentloaded' });
    await pause(mobile, '모바일 현장 사용자 일상점검 작성');
    await expectOk('field daily check visible', await bodyHas(mobile, '일상점검'));

    console.log(`VISIBLE QA DONE. Browser will stay open for ${holdMs}ms.`);
    await page.waitForTimeout(holdMs);
  } finally {
    if (recipientId) {
      await deleteQaRecipient(page, recipientId).catch(() => {});
    }
    await browser.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
