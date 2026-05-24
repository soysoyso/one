/**
 * 가로, 세로 비율을 유지하면서 1200px 넓이로 리사이징
 */
async function resizeToWidth1200(file) {
    if (!file) return null;
    const imgUrl = URL.createObjectURL(file);
    try {
        const img = await new Promise((resolve, reject) => {
            const i = new Image();
            i.onload = () => resolve(i);
            i.onerror = reject;
            i.src = imgUrl;
        });

        const targetW = 1200;
        const srcW = img.naturalWidth || img.width;
        const srcH = img.naturalHeight || img.height;
        if (!srcW || !srcH) return file;

        const scale = targetW / srcW;
        const w = targetW;
        const h = Math.max(1, Math.round(srcH * scale));

        const canvas = document.createElement('canvas');
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext('2d');
        ctx.imageSmoothingEnabled = true;
        ctx.imageSmoothingQuality = 'high';
        ctx.drawImage(img, 0, 0, w, h);

        const blob = await new Promise(resolve => canvas.toBlob(resolve, 'image/jpeg', 0.92));
        return blob || file;
    } catch (e) {
        console.error('이미지 리사이즈 실패, 원본으로 진행합니다.', e);
        return file;
    } finally {
        URL.revokeObjectURL(imgUrl);
    }
}

function formatOcrTexts(src) {
    if (!Array.isArray(src) || src.length === 0) return '';
    let tempAText = '';
    let tempBText = '';
    // 2) 정규식 정의 (전체 일치 기준)
    //    A: 1~999 (선행 0 금지), B: 0~9 한 자리
    const regexA = /^(?:[1-9][0-9]{0,2})$/;
    const regexB = /^[0-9]$/;
    let isFirstCheck = false;
    for (let i = 0; i < src.length; i++) {
        if (!isFirstCheck) {
            if (regexA.test(src[i].text)) {
                isFirstCheck = true;
                tempAText = src[i].text;
            }
        }
        if (isFirstCheck) {
            if (regexB.test(src[i].text)) {
                isFirstCheck = true;
                tempBText = src[i].text;
            }
        }
    }

    let res = '';
    if (tempAText === '') {
        res = ''
    } else if (tempBText === '') {
        res = tempAText + 'KM';
    } else {
        res = tempAText + '.' + tempBText + 'KM';
    }
    $('#ocrReadKm').val(res?.replace('KM', ''));
    return res;
}


async function processOcr(localOCR, range, fileInput, options = {}) {
    const {debugMode     = false,
              binaryMode = false
          } = options;
    try {
        let cropCanvas = null;
        if (range === 'crop') {
            cropCanvas = cropSelectedArea();
        } else if (range === 'full') {
            const file = fileInput.files?.[0];
            if (!file) return;
            cropCanvas = await imgToCanvas(file);
        }

        // OCR에는 보정된 이미지(성공 시) 혹은 원본(실패 시) 전달
        const blob = await new Promise(resolve => cropCanvas.toBlob(resolve, 'image/jpeg', 0.95));
        const url = URL.createObjectURL(blob);

        // OCR 실행 UI 업데이트
        const box = document.getElementById('ocrResultBox');
        const out = document.getElementById('ocrText');
        out.textContent = 'OCR 인식 중...';
        box.style.display = 'block';

        const result = await localOCR.ocr(url);

        const formatted = formatOcrTexts(result && result.src);
        // OpenCV 보정 시도 (1차 결과를 바탕으로)
        if (result && result.src && result.src.length > 0) {
            const cvResult = warpByOcrResult(cropCanvas, result.src);

            // 2. [추가] 선명화 (화질 개선)
            // warped 이미지를 더 뚜렷하게 만듭니다.
            const enhancedCanvas = enhanceImageSharpness(cvResult.warped, binaryMode);
            if (debugMode) {
                // 디버그 모달에 표시 (OCR이 인식한 영역을 표시)
                showDebugModal(enhancedCanvas);
            }

            // 만약 포맷팅 결과가 비어있다면(숫자 인식 실패 등),
            // 보정된 이미지로 한 번 더 시도해 볼 가치가 있음 (옵션)
            /*
            if (!formatted) {
                console.log("1차 실패, 보정된 이미지로 재시도...");
                const blob2 = await new Promise(r => cvResult.warped.toBlob(r, 'image/jpeg', 0.95));
                const url2 = URL.createObjectURL(blob2);
                const result2 = await localOCR.ocr(url2);
                formatted = formatOcrTexts(result2 && result2.src);
                URL.revokeObjectURL(url2);
            }
            */
        }


        if (formatted && formatted.length > 0) {
            out.textContent = formatted;
        } else {
            out.textContent = '인식된 텍스트가 없습니다.';
        }

        URL.revokeObjectURL(url);
    } catch (e) {
        // ... error handling ...
        console.error('OCR 처리 중 오류:', e);
        const box = document.getElementById('ocrResultBox');
        const out = document.getElementById('ocrText');
        out.textContent = 'OCR 처리 중 오류가 발생했습니다.';
        box.style.display = 'block';
    }
}

async function imgToCanvas(file) {
    const imgUrl = URL.createObjectURL(file);
    try {
        const img = await new Promise((resolve, reject) => {
            const i = new Image();
            i.onload = () => resolve(i);
            i.onerror = reject;
            i.src = imgUrl;
        });

        const targetW = 1200;
        const srcW = img.naturalWidth || img.width;
        const srcH = img.naturalHeight || img.height;
        if (!srcW || !srcH) return file;

        const scale = targetW / srcW;
        const w = targetW;
        const h = Math.max(1, Math.round(srcH * scale));

        const canvas = document.createElement('canvas');
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext('2d');
        ctx.imageSmoothingEnabled = true;
        ctx.imageSmoothingQuality = 'high';
        ctx.drawImage(img, 0, 0, w, h);
        return canvas
    } catch (e) {
        console.error('이미지 리사이즈 실패, 원본으로 진행합니다.', e);
        return file;
    } finally {
        URL.revokeObjectURL(imgUrl);
    }
}

/**
 * OpenCV.js를 이용한 투영 변환 및 디버깅 이미지 생성
 */
function warpPerspective(sourceCanvas) {
    const result = {
        warped: sourceCanvas, // 기본값: 원본
        debug : sourceCanvas   // 기본값: 원본
    };

    if (typeof cv === 'undefined' || !cv.Mat) {
        console.warn('OpenCV.js not loaded.');
        return result;
    }

    let src     = null,
        dst     = null,
        gray    = null,
        blurred = null,
        edges   = null;
    let contours    = null,
        hierarchy   = null,
        approxCurve = null;
    let srcTri = null,
        dstTri = null,
        M      = null;

    try {
        src = cv.imread(sourceCanvas);
        dst = new cv.Mat();

        // 디버깅용 이미지 (여기에 선을 그립니다)
        let debugMat = src.clone();

        // 1. 전처리
        gray = new cv.Mat();
        blurred = new cv.Mat();
        edges = new cv.Mat();

        cv.cvtColor(src, gray, cv.COLOR_RGBA2GRAY, 0);
        // 가우시안 블러로 노이즈 제거 (커널 크기 5x5)
        cv.GaussianBlur(gray, blurred, new cv.Size(5, 5), 0);
        // Canny 엣지 검출 (임계값 조정 가능)
        cv.Canny(blurred, edges, 50, 150);

        // 2. 윤곽선 검출
        contours = new cv.MatVector();
        hierarchy = new cv.Mat();
        cv.findContours(edges, contours, hierarchy, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);

        // 가장 큰 사각형 찾기
        let maxArea = 0;
        let maxContourIdx = -1;
        approxCurve = new cv.Mat();
        let foundCurve = null; // 찾은 사각형 좌표 저장용

        for (let i = 0; i < contours.size(); ++i) {
            let cnt = contours.get(i);
            let area = cv.contourArea(cnt);

            // 작은 노이즈 무시 (이미지 크기에 따라 조절 필요, 여기선 2000)
            if (area > 2000) {
                let peri = cv.arcLength(cnt, true);
                let tmpCurve = new cv.Mat();

                // 윤곽선 단순화 (epsilon 값 0.02 -> 0.04 정도로 늘려서 둥근 모서리 허용치 증가)
                cv.approxPolyDP(cnt, tmpCurve, 0.02 * peri, true);

                // 꼭짓점이 4개인 것만 찾음 (사각형)
                if (tmpCurve.rows === 4 && area > maxArea) {
                    maxArea = area;
                    maxContourIdx = i;
                    if (foundCurve) foundCurve.delete();
                    foundCurve = tmpCurve.clone();
                }

                // 디버깅: 감지된 모든 큰 윤곽선을 노란색으로 그림
                let color = new cv.Scalar(255, 255, 0, 255); // Yellow
                cv.drawContours(debugMat, contours, i, color, 2, cv.LINE_8, hierarchy, 0);

                tmpCurve.delete();
            }
        }

        if (maxContourIdx !== -1 && foundCurve) {
            // 찾은 사각형을 빨간색으로 진하게 그림 (디버깅용)
            let colorRed = new cv.Scalar(255, 0, 0, 255);
            cv.drawContours(debugMat, contours, maxContourIdx, colorRed, 4, cv.LINE_8, hierarchy, 0);

            // 3. 좌표 정렬 및 투영 변환
            let points = [];
            for (let i = 0; i < 4; i++) {
                points.push({
                    x: foundCurve.data32S[i * 2],
                    y: foundCurve.data32S[i * 2 + 1]
                });
            }

            // (1) y 좌표 기준으로 상단 2개, 하단 2개 분리 (간단한 정렬)
            points.sort((a, b) => a.y - b.y);
            let topPoints = points.slice(0, 2).sort((a, b) => a.x - b.x); // 상단: x좌표로 좌/우 구분
            let bottomPoints = points.slice(2, 4).sort((a, b) => a.x - b.x); // 하단: x좌표로 좌/우 구분

            let tl = topPoints[0]; // 좌상
            let tr = topPoints[1]; // 우상
            let bl = bottomPoints[0]; // 좌하
            let br = bottomPoints[1]; // 우하

            // 변환될 크기 계산
            let widthTop = Math.hypot(tr.x - tl.x, tr.y - tl.y);
            let widthBottom = Math.hypot(br.x - bl.x, br.y - bl.y);
            let maxWidth = Math.max(widthTop, widthBottom);

            let heightLeft = Math.hypot(tl.x - bl.x, tl.y - bl.y);
            let heightRight = Math.hypot(tr.x - br.x, tr.y - br.y);
            let maxHeight = Math.max(heightLeft, heightRight);

            srcTri = cv.matFromName(4, 1, cv.CV_32FC2, [
                tl.x, tl.y, tr.x, tr.y, br.x, br.y, bl.x, bl.y
            ]);

            dstTri = cv.matFromName(4, 1, cv.CV_32FC2, [
                0, 0, maxWidth, 0, maxWidth, maxHeight, 0, maxHeight
            ]);

            M = cv.getPerspectiveTransform(srcTri, dstTri);
            cv.warpPerspective(src, dst, M, new cv.Size(maxWidth, maxHeight), cv.INTER_LINEAR, cv.BORDER_CONSTANT, new cv.Scalar());

            // 결과 변환
            let warpedCanvas = document.createElement('canvas');
            cv.imshow(warpedCanvas, dst);
            result.warped = warpedCanvas;

            // 디버깅용 캔버스 생성
            let debugCanvas = document.createElement('canvas');
            cv.imshow(debugCanvas, debugMat);
            result.debug = debugCanvas;

        } else {
            // 사각형을 못 찾음: 디버깅 이미지에 텍스트 표시
            // console.log("사각형 검출 실패");
            cv.putText(debugMat, "No Rectangle Found", {
                x: 50,
                y: 50
            }, cv.FONT_HERSHEY_SIMPLEX, 1.5, [255, 0, 0, 255], 2);
            let debugCanvas = document.createElement('canvas');
            cv.imshow(debugCanvas, debugMat);
            result.debug = debugCanvas;
        }

        if (foundCurve) foundCurve.delete();

        return result;

    } catch (e) {
        console.error("OpenCV Processing Error:", e);
        return result;
    } finally {
        // 메모리 해제
        if (src) src.delete();
        if (dst) dst.delete();
        if (gray) gray.delete();
        if (blurred) blurred.delete();
        if (edges) edges.delete();
        if (contours) contours.delete();
        if (hierarchy) hierarchy.delete();
        if (approxCurve) approxCurve.delete();
        if (srcTri) srcTri.delete();
        if (dstTri) dstTri.delete();
        if (M) M.delete();
    }
}


/**
 * 보정된 Canvas 이미지를 모달창에 표시하는 함수
 */
function showDebugModal(canvas) {
    // Canvas를 Data URL로 변환
    const dataUrl = canvas.toDataURL('image/jpeg');

    // 모달 내 이미지 태그 찾기
    const imgEl = document.getElementById('debugResultImage');
    if (imgEl) {
        imgEl.src = dataUrl;

        // Bootstrap 5 모달 인스턴스 생성 및 표시
        // (jQuery가 있다면 $('#debugImageModal').modal('show') 사용 가능)
        if (typeof bootstrap !== 'undefined') {
            const modalEl = document.getElementById('debugImageModal');
            const modal = new bootstrap.Modal(modalEl);
            modal.show();
        } else if (window.jQuery) {
            $('#debugImageModal').modal('show');
        }
    }
}


/**
 * OCR 결과의 박스 좌표들을 이용해 이미지를 보정(투영 변환)합니다.
 * - 개선: 회전된 사각형(Rotated Rect)을 찾아 기울기까지 보정
 */
function warpByOcrResult(sourceCanvas, ocrResultSrc) {
    const result = {
        warped: sourceCanvas,
        debug : sourceCanvas
    };

    if (typeof cv === 'undefined' || !cv.Mat || !ocrResultSrc || ocrResultSrc.length === 0) {
        return result;
    }

    let src       = null,
        dst       = null,
        M         = null,
        srcTri    = null,
        dstTri    = null,
        pointsMat = null;

    try {
        src = cv.imread(sourceCanvas);

        // 디버깅용 이미지
        let debugMat = src.clone();

        // 1. 모든 텍스트 박스의 좌표 수집
        let allPoints = [];
        ocrResultSrc.forEach(item => {
            if (item.box) {
                item.box.forEach(pt => {
                    allPoints.push({
                        x: pt[0],
                        y: pt[1]
                    });
                });
                // 디버깅: 개별 텍스트 박스 그리기 (초록색)
                // ... (생략 가능)
            }
        });

        if (allPoints.length < 4) {
            let debugCanvas = document.createElement('canvas');
            cv.imshow(debugCanvas, debugMat);
            result.debug = debugCanvas;
            src.delete();
            debugMat.delete();
            return result;
        }

        // [핵심 변경] 2. 회전된 외곽 사각형 구하기 (Rotated Rectangle)
        // 점들을 OpenCV Mat으로 변환
        pointsMat = new cv.Mat(allPoints.length, 1, cv.CV_32SC2);
        for (let i = 0; i < allPoints.length; i++) {
            pointsMat.data32S[i * 2] = allPoints[i].x;
            pointsMat.data32S[i * 2 + 1] = allPoints[i].y;
        }

        // 최소 면적 회전 사각형 구하기 (기울기 정보 포함)
        let rotatedRect = cv.minAreaRect(pointsMat);

        // 여백(Padding) 추가: 사각형 크기 확장
        // 표지판 테두리 여백을 고려해 1.3배(30%) 정도 키웁니다.
        const scale = 1.3;
        rotatedRect.size.width *= scale;
        rotatedRect.size.height *= scale;

        // 회전된 사각형의 4개 꼭짓점 좌표 계산
        let vertices = cv.RotatedRect.points(rotatedRect);

        // 4개 점 정렬 (좌상, 우상, 우하, 좌하 순서 맞추기)
        // 정렬이 잘못되면 이미지가 뒤집히거나 꼬입니다.
        // 합(x+y)과 차(y-x)를 이용한 정렬 방식이 가장 안정적입니다.
        let pts = [
            {
                x: vertices[0].x,
                y: vertices[0].y
            },
            {
                x: vertices[1].x,
                y: vertices[1].y
            },
            {
                x: vertices[2].x,
                y: vertices[2].y
            },
            {
                x: vertices[3].x,
                y: vertices[3].y
            }
        ];

        // tl: x+y가 최소 / br: x+y가 최대
        // tr: y-x가 최소 / bl: y-x가 최대
        pts.sort((a, b) => (a.x + a.y) - (b.x + b.y));
        let tl = pts[0];
        let br = pts[3];

        let sub = pts.slice(1, 3).sort((a, b) => (a.y - a.x) - (b.y - b.x));
        let tr = sub[0];
        let bl = sub[1];

        // 디버깅: 회전된 영역 그리기 (빨간색)
        cv.line(debugMat, new cv.Point(tl.x, tl.y), new cv.Point(tr.x, tr.y), new cv.Scalar(255, 0, 0, 255), 3);
        cv.line(debugMat, new cv.Point(tr.x, tr.y), new cv.Point(br.x, br.y), new cv.Scalar(255, 0, 0, 255), 3);
        cv.line(debugMat, new cv.Point(br.x, br.y), new cv.Point(bl.x, bl.y), new cv.Scalar(255, 0, 0, 255), 3);
        cv.line(debugMat, new cv.Point(bl.x, bl.y), new cv.Point(tl.x, tl.y), new cv.Scalar(255, 0, 0, 255), 3);

        // 3. 투영 변환 실행
        // 변환될 이미지의 너비/높이 계산
        let widthTop = Math.hypot(tr.x - tl.x, tr.y - tl.y);
        let widthBottom = Math.hypot(br.x - bl.x, br.y - bl.y);
        let maxWidth = Math.max(widthTop, widthBottom);

        let heightLeft = Math.hypot(tl.x - bl.x, tl.y - bl.y);
        let heightRight = Math.hypot(tr.x - br.x, tr.y - br.y);
        let maxHeight = Math.max(heightLeft, heightRight);

        srcTri = new cv.Mat(4, 1, cv.CV_32FC2);
        srcTri.data32F.set([tl.x, tl.y, tr.x, tr.y, br.x, br.y, bl.x, bl.y]);

        dstTri = new cv.Mat(4, 1, cv.CV_32FC2);
        dstTri.data32F.set([0, 0, maxWidth, 0, maxWidth, maxHeight, 0, maxHeight]);

        dst = new cv.Mat();
        M = cv.getPerspectiveTransform(srcTri, dstTri);

        // 변환 수행
        cv.warpPerspective(src, dst, M, new cv.Size(maxWidth, maxHeight), cv.INTER_LINEAR, cv.BORDER_CONSTANT, new cv.Scalar());

        let warpedCanvas = document.createElement('canvas');
        cv.imshow(warpedCanvas, dst);
        result.warped = warpedCanvas;

        let debugCanvas = document.createElement('canvas');
        cv.imshow(debugCanvas, debugMat);
        result.debug = debugCanvas;

    } catch (e) {
        console.error("Warp by OCR failed", e);
    } finally {
        // 메모리 정리
        if (src) src.delete();
        if (dst) dst.delete();
        if (srcTri) srcTri.delete();
        if (dstTri) dstTri.delete();
        if (M) M.delete();
        if (pointsMat) pointsMat.delete();
    }

    return result;
}

/**
 * OpenCV를 이용한 이미지 선명화 (Sharpening)
 * - 텍스트의 경계선을 뚜렷하게 만들어 OCR 인식률을 높임
 */
function enhanceImageSharpness(sourceCanvas, applyBinary = false) {
    if (typeof cv === 'undefined' || !cv.Mat) return sourceCanvas;

    let src    = null,
        dst    = null,
        kernel = null;

    try {
        src = cv.imread(sourceCanvas);
        dst = new cv.Mat();

        // 샤픈 커널 (Sharpening Kernel) 생성
        // 중심 픽셀을 강조하고 주변 픽셀을 빼서 경계 대비를 높임
        // [ -1, -1, -1 ]
        // [ -1,  9, -1 ]
        // [ -1, -1, -1 ]
        kernel = new cv.Mat(3, 3, cv.CV_32F);
        kernel.data32F.set([-1, -1, -1, -1, 9, -1, -1, -1, -1]);

        // 필터 적용
        cv.filter2D(src, dst, -1, kernel);

        if(applyBinary){
            // (선택사항) 흑백 이진화 (Thresholding)
            // 그림자가 심하거나 대비가 낮을 때 텍스트만 남기고 싶으면 주석 해제
            cv.cvtColor(dst, dst, cv.COLOR_RGBA2GRAY, 0);
            cv.threshold(dst, dst, 0, 255, cv.THRESH_BINARY + cv.THRESH_OTSU);
            cv.cvtColor(dst, dst, cv.COLOR_GRAY2RGBA, 0); // 다시 RGBA로 변환해줘야 캔버스에 그려짐
        }

        let outputCanvas = document.createElement('canvas');
        cv.imshow(outputCanvas, dst);

        return outputCanvas;

    } catch (e) {
        console.error("Image Enhancement failed", e);
        return sourceCanvas;
    } finally {
        if (src) src.delete();
        if (dst) dst.delete();
        if (kernel) kernel.delete();
    }
}
