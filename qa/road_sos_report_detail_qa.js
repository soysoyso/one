const { chromium } = require('playwright');
const zlib = require('zlib');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';

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

function getZipEntry(buffer, entryName) {
  let eocd = -1;
  for (let i = buffer.length - 22; i >= 0; i -= 1) {
    if (buffer.readUInt32LE(i) === 0x06054b50) {
      eocd = i;
      break;
    }
  }
  if (eocd < 0) throw new Error('Zip end of central directory not found');

  const centralDirectorySize = buffer.readUInt32LE(eocd + 12);
  const centralDirectoryOffset = buffer.readUInt32LE(eocd + 16);
  let offset = centralDirectoryOffset;
  const end = centralDirectoryOffset + centralDirectorySize;

  while (offset < end) {
    const sig = buffer.readUInt32LE(offset);
    if (sig !== 0x02014b50) throw new Error(`Invalid central directory signature at ${offset}`);

    const method = buffer.readUInt16LE(offset + 10);
    const compressedSize = buffer.readUInt32LE(offset + 20);
    const fileNameLength = buffer.readUInt16LE(offset + 28);
    const extraLength = buffer.readUInt16LE(offset + 30);
    const commentLength = buffer.readUInt16LE(offset + 32);
    const localHeaderOffset = buffer.readUInt32LE(offset + 42);
    const name = buffer.slice(offset + 46, offset + 46 + fileNameLength).toString('utf8');

    if (name === entryName) {
      const localNameLength = buffer.readUInt16LE(localHeaderOffset + 26);
      const localExtraLength = buffer.readUInt16LE(localHeaderOffset + 28);
      const dataStart = localHeaderOffset + 30 + localNameLength + localExtraLength;
      const dataEnd = dataStart + compressedSize;
      const compressed = buffer.slice(dataStart, dataEnd);
      if (method === 0) return compressed.toString('utf8');
      if (method === 8) return zlib.inflateRawSync(compressed).toString('utf8');
      throw new Error(`Unsupported zip method ${method} for ${entryName}`);
    }
    offset += 46 + fileNameLength + extraLength + commentLength;
  }
  throw new Error(`Zip entry not found: ${entryName}`);
}

function xmlIncludes(xml, text) {
  return xml.replace(/<[^>]+>/g, '').includes(text);
}

async function exportText(request, format, reportNo) {
  const response = await request.post(`${baseUrl}/admin/reports/export`, {
    form: {
      reportNos: reportNo,
      template: 'MAINTENANCE_RESULT',
      format
    }
  });
  await expectOk(`maintenance result ${format} status`, response.ok());
  const body = await response.body();
  const entry = format === 'docx' ? 'word/document.xml' : 'Contents/section0.xml';
  return getZipEntry(body, entry);
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  let reportNo = '';
  const token = `QA-REPORT-FIELDS-${Date.now()}`;
  const docNo = `QA-DOC-${Date.now()}`;

  const expected = {
    addr: `서울 QA 도로 ${token}`,
    detailInfo: 'QA 상세위치 12차로',
    deliveryNote: 'QA 접수 전달사항',
    processNote: 'QA 포장 보수 완료',
    laneInfo: 'QA 2차로',
    reportRemark: 'QA 보고서 비고 반영',
    equipment: 'QA 굴삭기',
    personnel: 'QA 작업자',
    material: 'QA 아스콘'
  };

  try {
    await login(page, 'admin', 'admin123', '/admin/login');
    await page.goto(`${baseUrl}/admin/ims/dashboard`, { waitUntil: 'domcontentloaded' });

    const requiredSelectors = [
      '#insDocNo',
      '#insLaneInfo',
      '#insReportRemark',
      '#insWorkQty',
      '#insConvertWorkQty',
      '#insAccountWorkQty',
      '#body-equipment',
      '#body-personnel',
      '#body-material',
      '#body-scope'
    ];
    for (const selector of requiredSelectors) {
      await expectOk(`receipt detail field ${selector}`, await page.locator(selector).count() === 1);
    }

    const workInfo = {
      equipments: [{ sortOrd: 1, equipName: expected.equipment, ownQty: 2, useQty: 1, remark: 'QA 장비비고' }],
      personnels: [{ sortOrd: 1, personName: expected.personnel, deptName: 'QA 보수팀', laborCost: 12345 }],
      materials: [{ sortOrd: 1, materialName: expected.material, spec: '13mm', unit: '톤', useQty: 3.5, remainQty: 0.5, amount: 77777 }],
      scopes: [{ sortOrd: 1, widthM: 2.1, heightM: 1.2, areaM2: 2.52, depthCm: 6, spanM: 0 }]
    };

    const save = await page.request.post(`${baseUrl}/admin/ims/save`, {
      multipart: {
        imsMode: 'INSERT',
        docNo,
        reportDate: '2026-05-25 09:10:00',
        statusCd: 'DONE',
        siteCd: 'LOCAL',
        receiptGbCd: 'POTHOLE',
        receiverId: 'admin',
        managerId: 'admin',
        weatherCd: 'W001',
        workWeatherCd: 'W001',
        directionCd: 'UP',
        addr: expected.addr,
        detailInfo: expected.detailInfo,
        deliveryNote: expected.deliveryNote,
        processNote: expected.processNote,
        laneInfo: expected.laneInfo,
        reportRemark: expected.reportRemark,
        workQty: '12.34',
        convertWorkQty: '56.78',
        accountWorkQty: '90.12',
        workStartAt: '2026-05-25 10:00:00',
        workEndAt: '2026-05-25 11:30:00',
        staText: '1+234',
        staMeters: '1234',
        staKmDecimal: '1.234',
        pavementTypeCds: 'ASP',
        occurPlaceCds: 'EARTH',
        workInfoJson: JSON.stringify(workInfo),
        alarmSendYn: 'N'
      }
    });
    const saveJson = await save.json();
    console.log(`STATE receipt detail save ${JSON.stringify(saveJson)}`);
    await expectOk('receipt detail save', saveJson.code === '0000');

    const list = await page.request.get(`${baseUrl}/admin/ims/data`, {
      params: {
        page: '1',
        pageSize: '10',
        keyword: token,
        strtDt: '2026-05-25 00:00:00',
        endDt: '2026-05-25 23:59:59'
      }
    });
    const listJson = await list.json();
    reportNo = listJson.list && listJson.list[0] && listJson.list[0].reportNo;
    await expectOk('saved receipt searchable', !!reportNo);

    const detail = await page.request.get(`${baseUrl}/admin/ims/detail`, { params: { reportNo } });
    const detailJson = await detail.json();
    const d = detailJson.detail || {};
    await expectOk('detail docNo saved', d.docNo === docNo);
    await expectOk('detail detailInfo saved', d.detailInfo === expected.detailInfo);
    await expectOk('detail deliveryNote saved', d.deliveryNote === expected.deliveryNote);
    await expectOk('detail processNote saved', d.processNote === expected.processNote);
    await expectOk('detail laneInfo saved', d.laneInfo === expected.laneInfo);
    await expectOk('detail reportRemark saved', d.reportRemark === expected.reportRemark);
    await expectOk('detail workQty saved', String(d.workQty) === '12.34');
    await expectOk('detail convertWorkQty saved', String(d.convertWorkQty) === '56.78');
    await expectOk('detail accountWorkQty saved', String(d.accountWorkQty) === '90.12');
    await expectOk('detail pavement type saved', d.pavementTypeCds === 'ASP');
    await expectOk('detail occur place saved', d.occurPlaceCds === 'EARTH');
    await expectOk('detail equipment saved', (detailJson.equipments || []).some(row => row.equipName === expected.equipment));
    await expectOk('detail personnel saved', (detailJson.personnels || []).some(row => row.personName === expected.personnel));
    await expectOk('detail material saved', (detailJson.materials || []).some(row => row.materialName === expected.material));
    await expectOk('detail scope saved', (detailJson.scopes || []).some(row => String(row.areaM2) === '2.52'));

    const docxText = await exportText(page.request, 'docx', reportNo);
    await expectOk('docx includes lane info', xmlIncludes(docxText, expected.laneInfo));
    await expectOk('docx includes report remark', xmlIncludes(docxText, expected.reportRemark));
    await expectOk('docx includes detail info', xmlIncludes(docxText, expected.detailInfo));
    await expectOk('docx includes work quantity', xmlIncludes(docxText, '12.34'));

    const hwpxText = await exportText(page.request, 'hwpx', reportNo);
    await expectOk('hwpx includes lane info', xmlIncludes(hwpxText, expected.laneInfo));
    await expectOk('hwpx includes report remark', xmlIncludes(hwpxText, expected.reportRemark));
    await expectOk('hwpx includes detail info', xmlIncludes(hwpxText, expected.detailInfo));
    await expectOk('hwpx includes work quantity', xmlIncludes(hwpxText, '12.34'));
  } finally {
    if (reportNo) {
      await page.request.post(`${baseUrl}/admin/ims/delete`, { form: { reportNo } }).catch(() => {});
    }
    await browser.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
