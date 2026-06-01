const { chromium } = require('playwright');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';

async function login(page, userId, userPwd, path) {
  await page.goto(`${baseUrl}${path}`, { waitUntil: 'domcontentloaded' });
  await page.fill('input[name="userId"]', userId);
  await page.fill('input[name="userPwd"]', userPwd);
  await page.click('button[type="submit"]');
  await page.waitForLoadState('networkidle');
}

function hasBrokenKorean(text) {
  return /[�]|[?][가-힣]|[泥愿蹂湲諛醫嫄]|ì|í|ë|ê/.test(text);
}

async function ok(name, condition, extra = '') {
  if (!condition) throw new Error(`${name} failed ${extra}`);
  console.log(`OK ${name}`);
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  try {
    await login(page, 'admin', 'admin123', '/admin/login');

    const pages = [
      ['/admin/ims/dashboard', '현장관리'],
      ['/admin/daily-checklists/setting', '일상점검 체크리스트 설정'],
      ['/admin/daily-checks', '일상점검 관리'],
      ['/admin/situation-logs', '상황일지 관리'],
      ['/admin/notification/recipients', '알림톡 수신자 관리'],
    ];
    for (const [path, expected] of pages) {
      await page.goto(`${baseUrl}${path}`, { waitUntil: 'networkidle' });
      const text = await page.locator('body').innerText();
      await ok(`${path} expected text`, text.includes(expected), text.slice(0, 200));
      await ok(`${path} no broken korean`, !hasBrokenKorean(text), text.match(/[�]|[?][가-힣]|[泥愿蹂湲諛醫嫄]|ì|í|ë|ê/)?.[0] || '');
    }

    const templates = await page.request.get(`${baseUrl}/admin/reports/templates`);
    const templatesJson = await templates.json();
    const names = (templatesJson.data || []).map(t => t.templateName).join(',');
    console.log(`STATE template names ${names}`);
    await ok('template names no broken korean', !hasBrokenKorean(names), names);
  } finally {
    await browser.close();
  }
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
