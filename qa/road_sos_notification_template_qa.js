const { chromium } = require('playwright');

const baseUrl = process.env.ROAD_SOS_BASE_URL || 'http://localhost:8703';
const token = `NOTI-TPL-QA-${Date.now()}`;
const headed = process.env.VISIBLE_QA === '1';
const holdMs = Number(process.env.VISIBLE_QA_HOLD_MS || 30000);
const stepMs = Number(process.env.VISIBLE_QA_STEP_MS || 900);

function assert(condition, message) {
  if (!condition) throw new Error(message || 'assertion failed');
}

async function login(page) {
  await page.goto(`${baseUrl}/admin/login`, { waitUntil: 'domcontentloaded' });
  await page.fill('input[name="userId"]', 'admin');
  await page.fill('input[name="userPwd"]', 'admin123');
  await page.click('button[type="submit"]');
  await page.waitForLoadState('networkidle');
}

async function mark(page, label) {
  console.log(`SCENARIO ${label}`);
  if (!headed) return;
  await page.evaluate((text) => {
    let banner = document.getElementById('codex-demo-banner');
    if (!banner) {
      banner = document.createElement('div');
      banner.id = 'codex-demo-banner';
      banner.style.cssText = 'position:fixed;left:16px;right:16px;top:12px;z-index:99999;background:#0f172a;color:#fff;padding:12px 16px;border-radius:8px;font:700 16px/1.4 system-ui;box-shadow:0 12px 30px rgba(15,23,42,.25);';
      document.body.appendChild(banner);
    }
    banner.textContent = text;
  }, label).catch(() => {});
  await page.waitForTimeout(stepMs);
}

async function run() {
  const browser = await chromium.launch({ headless: !headed, slowMo: headed ? 140 : 0 });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  try {
    await mark(page, '관리자 로그인');
    await login(page);
    await page.goto(`${baseUrl}/admin/notification/recipients`, { waitUntil: 'networkidle' });
    await mark(page, '알림톡 수신자 설정 화면');

    if (headed) {
      await page.locator('.type-card').first().click();
      await page.fill('#templateCode', `${token}-CODE`);
      await page.fill('#templateTitle', `${token} 접수 알림`);
      await page.locator('.default-dept-check[value="DEV"]').check();
      await mark(page, '외부 템플릿 코드/타이틀/기본 팀 선택');
    }

    const save = await page.request.post(`${baseUrl}/admin/notification/template/save`, {
      form: {
        notificationType: 'POTHOLE_RECEIPT',
        templateCode: `${token}-CODE`,
        templateTitle: `${token} 접수 알림`,
        defaultDeptCds: 'DEV',
        useYn: 'Y',
        autoApplyYn: 'Y',
      },
    });
    const saveJson = await save.json();
    assert(saveJson.code === '0000', `template save failed ${JSON.stringify(saveJson)}`);
    if (headed) {
      await page.reload({ waitUntil: 'networkidle' });
      await page.locator('.type-card').first().click();
      await mark(page, '템플릿 설정 저장 및 재조회');
    }

    const get = await page.request.get(`${baseUrl}/admin/notification/template/POTHOLE_RECEIPT`);
    const getJson = await get.json();
    assert(getJson.code === '0000', 'template get failed');
    assert(getJson.data.templateCode === `${token}-CODE`, 'template code not saved');
    assert((getJson.data.defaultDeptCds || '').includes('DEV'), 'default dept not saved');

    const list = await page.request.get(`${baseUrl}/admin/notification/recipients/data`, {
      params: { notificationType: 'POTHOLE_RECEIPT', useYn: 'Y', page: 1, pageSize: 500 },
    });
    const listJson = await list.json();
    assert((listJson.list || []).some((row) => row.userId), 'default team users not auto assigned');

    const blocked = await page.request.post(`${baseUrl}/admin/notification/recipients/save`, {
      form: {
        notificationType: 'POTHOLE_RECEIPT',
        recipientNm: `${token} 외부번호`,
        phoneNo: '010-9999-9999',
        siteCd: '',
        useYn: 'Y',
      },
    });
    const blockedJson = await blocked.json();
    assert(blockedJson.code !== '0000', 'external recipient should be rejected');

    const autoUserId = `notiqa_${Date.now()}`;
    const createUser = await page.request.post(`${baseUrl}/admin/insertAdminUser`, {
      form: {
        insUserName: `${token} 자동배정`,
        insUserId: autoUserId,
        insUserPw: 'test1234!',
        userTel: '010-1234-5678',
        userMail: `${autoUserId}@example.com`,
        deptCd: 'DEV',
        bizDivCd: 'APPLY',
        siteCodesJoined: '',
        userRole: ['ATH300'],
      },
    });
    const createUserJson = await createUser.json();
    assert(createUserJson.code === '0000', `admin user create failed ${JSON.stringify(createUserJson)}`);
    if (headed) {
      await page.goto(`${baseUrl}/admin/user/setting`, { waitUntil: 'networkidle' });
      await mark(page, '관리자 사용자 추가 시 팀 선택 완료');
    }

    const autoList = await page.request.get(`${baseUrl}/admin/notification/recipients/data`, {
      params: { notificationType: 'POTHOLE_RECEIPT', useYn: 'Y', keyword: autoUserId, page: 1, pageSize: 500 },
    });
    const autoListJson = await autoList.json();
    const autoRecipient = (autoListJson.list || []).find((row) => row.userId === autoUserId);
    assert(autoRecipient, 'new admin user was not auto assigned by team');
    if (headed) {
      await page.goto(`${baseUrl}/admin/notification/recipients`, { waitUntil: 'networkidle' });
      await page.locator('.type-card').first().click();
      await page.fill('#keyword', autoUserId);
      await page.click('#btnSearch');
      await page.waitForTimeout(1000);
      await mark(page, '팀 기준으로 자동 배정된 사용자 확인');
    }

    console.log('NOTIFICATION_TEMPLATE_QA_RESULT=PASS');
    if (headed) {
      await mark(page, 'QA 완료: 브라우저를 잠시 열어둡니다');
      await page.waitForTimeout(holdMs);
    }
  } finally {
    await browser.close();
  }
}

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
