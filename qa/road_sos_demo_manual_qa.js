const { chromium } = require('playwright');
const zlib = require('zlib');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';
const stepMs = Number(process.env.DEMO_QA_STEP_MS || 1200);
const holdMs = Number(process.env.DEMO_QA_HOLD_MS || 20000);
const keepDemoData = process.env.KEEP_DEMO_DATA !== '0';

async function pause(page, label) {
  console.log(`SCENARIO ${label}`);
  await page.waitForTimeout(stepMs);
}

async function expectOk(name, condition) {
  if (!condition) throw new Error(`${name} failed`);
  console.log(`OK ${name}`);
}

async function login(page, userId, userPwd, loginPath) {
  await page.goto(`${baseUrl}${loginPath}`, { waitUntil: 'domcontentloaded' });
  await pause(page, `${loginPath} 로그인 화면`);
  await page.fill('input[name="userId"]', userId);
  await page.fill('input[name="userPwd"]', userPwd);
  await page.click('button[type="submit"]');
  await page.waitForLoadState('networkidle');
  await pause(page, `${userId} 로그인 완료`);
}

async function selectFirstNonEmpty(page, selector) {
  const value = await page.$eval(selector, (el) => {
    const options = Array.from(el.options || []);
    const found = options.find((option) => option.value);
    return found ? found.value : '';
  });
  await expectOk(`${selector} has selectable option`, !!value);
  await page.selectOption(selector, value);
  return value;
}

async function ensureAdminUsers(page) {
  let siteValue = await page.locator('#insSiteCd').inputValue();
  if (!siteValue) {
    siteValue = await selectFirstNonEmpty(page, '#insSiteCd');
  }
  await expectOk('site selected', !!siteValue);
  await page.dispatchEvent('#insSiteCd', 'change');
  await page.waitForFunction(() => {
    const receiver = document.querySelector('#insReceiverId');
    return receiver && Array.from(receiver.options || []).some((option) => option.value);
  });
}

function getZipEntry(buffer, entryName) {
  let eocd = -1;
  for (let i = buffer.length - 22; i >= 0; i -= 1) {
    if (buffer.readUInt32LE(i) === 0x06054b50) {
      eocd = i;
      break;
    }
  }
  if (eocd < 0) throw new Error('Zip end of central directory not found');

  const size = buffer.readUInt32LE(eocd + 12);
  const start = buffer.readUInt32LE(eocd + 16);
  let offset = start;
  const end = start + size;

  while (offset < end) {
    if (buffer.readUInt32LE(offset) !== 0x02014b50) {
      throw new Error(`Invalid central directory signature at ${offset}`);
    }
    const method = buffer.readUInt16LE(offset + 10);
    const compressedSize = buffer.readUInt32LE(offset + 20);
    const nameLength = buffer.readUInt16LE(offset + 28);
    const extraLength = buffer.readUInt16LE(offset + 30);
    const commentLength = buffer.readUInt16LE(offset + 32);
    const localHeaderOffset = buffer.readUInt32LE(offset + 42);
    const name = buffer.slice(offset + 46, offset + 46 + nameLength).toString('utf8');

    if (name === entryName) {
      const localNameLength = buffer.readUInt16LE(localHeaderOffset + 26);
      const localExtraLength = buffer.readUInt16LE(localHeaderOffset + 28);
      const dataStart = localHeaderOffset + 30 + localNameLength + localExtraLength;
      const compressed = buffer.slice(dataStart, dataStart + compressedSize);
      if (method === 0) return compressed.toString('utf8');
      if (method === 8) return zlib.inflateRawSync(compressed).toString('utf8');
      throw new Error(`Unsupported zip method ${method}`);
    }
    offset += 46 + nameLength + extraLength + commentLength;
  }
  throw new Error(`Zip entry not found: ${entryName}`);
}

function xmlText(xml) {
  return xml.replace(/<[^>]+>/g, '');
}

async function verifyReportPackage(request, format, reportNo, expectedValues) {
  const response = await request.post(`${baseUrl}/admin/reports/export`, {
    form: {
      reportNos: reportNo,
      template: 'MAINTENANCE_RESULT',
      format
    }
  });
  await expectOk(`${format} report export API`, response.ok());
  const body = await response.body();
  const entry = format === 'docx' ? 'word/document.xml' : 'Contents/section0.xml';
  const text = xmlText(getZipEntry(body, entry));
  for (const expected of expectedValues) {
    await expectOk(`${format} includes ${expected}`, text.includes(expected));
  }
}

async function createReceiptByUi(page) {
  const token = `DEMO-${Date.now()}`;
  const expected = {
    token,
    address: `서울특별시 QA 도로 ${token}`,
    detailInfo: 'QA 상세위치 12차로',
    deliveryNote: 'QA 접수 전달사항',
    processNote: 'QA 포장 보수 완료',
    laneInfo: 'QA 2차로',
    reportRemark: 'QA 보고서 비고 반영',
    equipment: 'QA 굴삭기',
    personnel: 'QA 작업자',
    material: 'QA 아스콘',
    workQty: '12.34'
  };

  await page.goto(`${baseUrl}/admin/ims/dashboard`, { waitUntil: 'domcontentloaded' });
  await pause(page, '현장관리 목록 및 보고서 출력 도구 확인');
  await expectOk('receipt registration button visible', await page.locator('#btnImsAdd').isVisible());

  await page.click('#btnImsAdd');
  await page.waitForSelector('#ims-add-modal.show');
  await pause(page, '접수 등록 모달 오픈');

  await ensureAdminUsers(page);
  await selectFirstNonEmpty(page, '#insReceiptGbCd');
  await selectFirstNonEmpty(page, '#insStatusCd');
  await selectFirstNonEmpty(page, '#insReceiverId');
  await page.selectOption('#insManagerId', 'admin').catch(async () => {
    await selectFirstNonEmpty(page, '#insManagerId');
  });
  await selectFirstNonEmpty(page, '#insWeatherCd');
  await selectFirstNonEmpty(page, '#insWorkweatherCd');
  await page.fill('#insTemp', '23');
  await page.fill('#insWorkTemp', '24');
  await page.fill('#insReportDt', '2026-05-26 09:10');
  await page.fill('#insWorkStartAt', '2026-05-26 10:00');
  await page.fill('#insWorkEndAt', '2026-05-26 11:30');
  await page.selectOption('#inDirectionCd', 'UP').catch(() => {});
  await pause(page, '공통 필수항목 입력');

  await page.fill('#insAddr', expected.address);
  await page.fill('#insDetailInfo', expected.detailInfo);
  await page.fill('#insStaKmView', '1.234');
  await page.dispatchEvent('#insStaKmView', 'input').catch(() => {});
  await page.fill('#insDeliveryNote', expected.deliveryNote);
  await page.fill('#insProcessNote', expected.processNote);
  await pause(page, '위치정보와 접수/작업 내용 입력');

  await page.locator('.choice-pavement').first().check().catch(() => {});
  await page.locator('.choice-occur').first().check().catch(() => {});

  await page.locator('#body-equipment .equip-name').first().fill(expected.equipment);
  await page.locator('#body-equipment .equip-own').first().fill('2');
  await page.locator('#body-equipment .equip-use').first().fill('1');
  await page.locator('#body-equipment .equip-remark').first().fill('QA 장비비고');

  await page.locator('#body-personnel .person-name').first().fill(expected.personnel);
  await page.locator('#body-personnel .person-dept').first().fill('QA 보수팀');
  await page.locator('#body-personnel .person-labor').first().fill('12345');

  await page.locator('#body-material .mat-name').first().fill(expected.material);
  await page.locator('#body-material .mat-spec').first().fill('13mm');
  await page.locator('#body-material .mat-unit').first().fill('톤');
  await page.locator('#body-material .mat-use').first().fill('3.5');
  await page.locator('#body-material .mat-remain').first().fill('0.5');
  await page.locator('#body-material .mat-amount').first().fill('77777');

  await page.locator('#body-scope .sc-width').first().fill('2.1');
  await page.locator('#body-scope .sc-height').first().fill('1.2');
  await page.locator('#body-scope .sc-area').first().fill('2.52');
  await page.locator('#body-scope .sc-depth').first().fill('6');
  await page.locator('#body-scope .sc-span').first().fill('0');
  await pause(page, '작업정보 장비/인력/자재/범위 입력');

  await page.fill('#insLaneInfo', expected.laneInfo);
  await page.fill('#insWorkQty', expected.workQty);
  await page.fill('#insConvertWorkQty', '56.78');
  await page.fill('#insAccountWorkQty', '90.12');
  await page.fill('#insReportRemark', expected.reportRemark);
  await page.locator('#insAlarmSendYn').uncheck().catch(() => {});
  await pause(page, '보고서 추가정보 입력');

  await page.click('#btnSave');
  await page.waitForSelector('.swal2-confirm');
  await pause(page, '저장 확인 모달');
  await page.click('.swal2-confirm');
  await page.waitForSelector('.swal2-popup', { state: 'hidden', timeout: 15000 }).catch(() => {});
  await page.waitForLoadState('networkidle').catch(() => {});
  await pause(page, '접수 등록 저장 완료');

  const list = await page.request.get(`${baseUrl}/admin/ims/data`, {
    params: {
      page: '1',
      pageSize: '10',
      keyword: token,
      strtDt: '2026-05-26 00:00:00',
      endDt: '2026-05-26 23:59:59'
    }
  });
  const listJson = await list.json();
  const reportNo = listJson.list && listJson.list[0] && listJson.list[0].reportNo;
  await expectOk('created receipt searchable by API', !!reportNo);

  await page.evaluate((rn) => window.openImsDetail && window.openImsDetail(rn), reportNo);
  await page.waitForSelector('#ims-add-modal.show');
  await pause(page, `등록 접수 상세 재조회: ${reportNo}`);

  const detail = await page.request.get(`${baseUrl}/admin/ims/detail`, { params: { reportNo } });
  const detailJson = await detail.json();
  const d = detailJson.detail || {};
  await expectOk('detail lane info saved', d.laneInfo === expected.laneInfo);
  await expectOk('detail report remark saved', d.reportRemark === expected.reportRemark);
  await expectOk('detail work info saved', (detailJson.equipments || []).some((row) => row.equipName === expected.equipment));

  await page.click('#ims-add-modal [data-bs-dismiss="modal"]');
  await page.waitForSelector('#ims-add-modal.show', { state: 'detached', timeout: 2000 }).catch(() => {});

  await page.goto(`${baseUrl}/admin/ims/dashboard`, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(1000);
  await page.evaluate((rn) => {
    const checkbox = document.querySelector(`#imsTableBody .rowCheck[value="${rn}"]`);
    if (checkbox) checkbox.checked = true;
  }, reportNo);
  await page.selectOption('#ledgerExportTemplate', 'MAINTENANCE_RESULT');
  await page.selectOption('#ledgerExportFormat', 'docx');
  await pause(page, '유지관리 결과보고서 DOCX 출력 선택');

  const download = await Promise.all([
    page.waitForEvent('download'),
    page.click('#btnLedgerDownload')
  ]);
  console.log(`DOWNLOAD ${await download[0].suggestedFilename()}`);
  await pause(page, '보고서 다운로드 완료');

  await verifyReportPackage(page.request, 'docx', reportNo, [
    expected.laneInfo,
    expected.reportRemark,
    expected.detailInfo,
    expected.workQty
  ]);
  await verifyReportPackage(page.request, 'hwpx', reportNo, [
    expected.laneInfo,
    expected.reportRemark,
    expected.detailInfo,
    expected.workQty
  ]);

  return { reportNo, expected };
}

async function showAdditionalFeatureManual(browser, page) {
  await page.goto(`${baseUrl}/admin/notification/recipients`, { waitUntil: 'domcontentloaded' });
  await pause(page, '추가기능 1. 알림톡 수신자 설정: 수신자 추가/검색/마스킹 관리 화면');
  await expectOk('notification page', await page.locator('#btnAddRecipient').isVisible());

  await page.goto(`${baseUrl}/admin/daily-checklists/setting`, { waitUntil: 'domcontentloaded' });
  await pause(page, '추가기능 2. 일상점검 체크리스트 설정: 점검 양식과 필수 항목 관리');
  await expectOk('daily checklist setting page', await page.locator('#btnAddChecklist').isVisible());

  const mobile = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await login(mobile, 'field', 'field123', '/manage/login');
  await mobile.goto(`${baseUrl}/manage/daily-checks/form`, { waitUntil: 'domcontentloaded' });
  await pause(mobile, '추가기능 3. 현장 사용자 일상점검 작성: 모바일 점검 등록 화면');
  await expectOk('field daily form page', (await mobile.locator('body').innerText()).includes('일상점검'));
  await mobile.close();

  await page.goto(`${baseUrl}/admin/daily-checks`, { waitUntil: 'domcontentloaded' });
  await pause(page, '추가기능 4. 관리자 일상점검 조회 및 DOCX/HWPX 출력');
  await expectOk('admin daily exports', await page.locator('#btnDailyCheckDocx').isVisible() && await page.locator('#btnDailyCheckHwpx').isVisible());

  await page.goto(`${baseUrl}/admin/situation-logs`, { waitUntil: 'domcontentloaded' });
  await pause(page, '추가기능 5. 상황일지 등록/조회 및 DOCX/HWPX 출력');
  await expectOk('situation exports', await page.locator('#btnExportSituationDocx').isVisible() && await page.locator('#btnExportSituationHwpx').isVisible());

  await page.goto(`${baseUrl}/admin/ims/dashboard`, { waitUntil: 'domcontentloaded' });
  await page.selectOption('#ledgerExportTemplate', 'PHOTO_BOARD');
  await pause(page, '추가기능 6. 보고서 템플릿별 출력 형식 제어: 사진대지는 PDF 비활성화, DOCX/HWPX 사용');
  await expectOk('non-ledger pdf disabled', await page.locator('#ledgerExportFormat option[value="pdf"]').isDisabled());
}

async function main() {
  const browser = await chromium.launch({ headless: false, slowMo: 120 });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  let reportNo = '';

  try {
    await login(page, 'admin', 'admin123', '/admin/login');
    const created = await createReceiptByUi(page);
    reportNo = created.reportNo;
    await showAdditionalFeatureManual(browser, page);
    console.log(`DEMO QA DONE reportNo=${reportNo}`);
    console.log(`Browser will stay open for ${holdMs}ms.`);
    await page.waitForTimeout(holdMs);
  } finally {
    if (!keepDemoData && reportNo) {
      await page.request.post(`${baseUrl}/admin/ims/delete`, { form: { reportNo } }).catch(() => {});
    }
    await browser.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
