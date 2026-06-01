const { chromium } = require('playwright');
const zlib = require('zlib');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';

async function login(page) {
  await page.goto(`${baseUrl}/admin/login`, { waitUntil: 'domcontentloaded' });
  await page.fill('input[name="userId"]', 'admin');
  await page.fill('input[name="userPwd"]', 'admin123');
  await page.click('button[type="submit"]');
  await page.waitForLoadState('networkidle');
}

async function ok(name, condition) {
  if (!condition) throw new Error(`${name} failed`);
  console.log(`OK ${name}`);
}

async function exportReport(request, reportNo, template, format) {
  return request.post(`${baseUrl}/admin/reports/export`, {
    form: { reportNos: reportNo, template, format }
  });
}

function extractZipEntry(buffer, entryName) {
  const eocdSig = 0x06054b50;
  let eocdOffset = -1;
  for (let i = buffer.length - 22; i >= 0; i--) {
    if (buffer.readUInt32LE(i) === eocdSig) {
      eocdOffset = i;
      break;
    }
  }
  if (eocdOffset < 0) return '';

  const centralDirSize = buffer.readUInt32LE(eocdOffset + 12);
  const centralDirOffset = buffer.readUInt32LE(eocdOffset + 16);
  let offset = centralDirOffset;
  const end = centralDirOffset + centralDirSize;

  while (offset < end && buffer.readUInt32LE(offset) === 0x02014b50) {
    const method = buffer.readUInt16LE(offset + 10);
    const compressedSize = buffer.readUInt32LE(offset + 20);
    const uncompressedSize = buffer.readUInt32LE(offset + 24);
    const nameLength = buffer.readUInt16LE(offset + 28);
    const extraLength = buffer.readUInt16LE(offset + 30);
    const commentLength = buffer.readUInt16LE(offset + 32);
    const localHeaderOffset = buffer.readUInt32LE(offset + 42);
    const name = buffer.slice(offset + 46, offset + 46 + nameLength).toString('utf8');

    if (name === entryName) {
      const localNameLength = buffer.readUInt16LE(localHeaderOffset + 26);
      const localExtraLength = buffer.readUInt16LE(localHeaderOffset + 28);
      const dataOffset = localHeaderOffset + 30 + localNameLength + localExtraLength;
      const data = buffer.slice(dataOffset, dataOffset + compressedSize);
      if (method === 0) return data.toString('utf8');
      if (method === 8) return zlib.inflateRawSync(data, { finishFlush: zlib.constants.Z_SYNC_FLUSH, chunkSize: uncompressedSize || 16384 }).toString('utf8');
      return '';
    }

    offset += 46 + nameLength + extraLength + commentLength;
  }

  return '';
}

function docxText(buffer) {
  return extractZipEntry(buffer, 'word/document.xml').replace(/<[^>]+>/g, '');
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  try {
    await login(page);
    await ok('admin login', page.url().includes('/admin/'));

    const list = await page.request.get(`${baseUrl}/admin/ims/data`, {
      params: { page: '1', pageSize: '1' }
    });
    const listJson = await list.json();
    const reportNo = listJson.list && listJson.list[0] && listJson.list[0].reportNo;
    await ok('report no found', Boolean(reportNo));

    const templates = [
      ['POTHOLE_LEDGER', '도로파손(포트홀) 관리대장'],
      ['POTHOLE_SUMMARY', '포트홀 집계표'],
      ['MAINTENANCE_LOG', '유지보수 일지'],
      ['LANDSCAPE_DAILY_WORK', '조경 작업일보'],
      ['MAINTENANCE_RESULT', '유지관리 결과보고서'],
      ['PHOTO_BOARD', '사진대지']
    ];
    for (const [template, expectedTitle] of templates) {
      const docx = await exportReport(page.request, reportNo, template, 'docx');
      await ok(`${template} docx status`, docx.ok());
      const docxBody = await docx.body();
      await ok(`${template} docx package`, docxBody[0] === 0x50 && docxBody[1] === 0x4b && docxBody.length > 2000);
      await ok(`${template} docx title`, docxText(docxBody).includes(expectedTitle));

      const pdf = await exportReport(page.request, reportNo, template, 'pdf');
      await ok(`${template} pdf status`, pdf.ok());
      const pdfBody = await pdf.body();
      await ok(`${template} pdf package`, pdfBody.slice(0, 4).toString() === '%PDF' && pdfBody.length > 1000);
    }
  } finally {
    await browser.close();
  }
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
