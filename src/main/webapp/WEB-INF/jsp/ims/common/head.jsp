<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, shrink-to-fit=no"/>
    <meta charset="UTF-8">
    <title>인프라현장관리</title>

    <meta property="og:type" content="website">
    <meta property="og:title" content="이도테라원">
    <meta property="og:description" content="이도테라원 인프라 현장 관리 및 보고서를 작성할 수 있습니다.">
    <meta property="og:url" content="https://sos.yido.com/manage">
    <meta property="og:image" content="/img/porthole-thumbnail.jpg">
    <!-- 앱 -->
    <meta name="application-name" content="이도테라원">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="theme-color" content="#ffffff">
    <link rel="manifest" href="/manifest.json"><!-- 홈화면에추가 -->
    <!-- iOS -->
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-title" content="이도테라원">
    <link rel="apple-touch-icon" href="/img/icon-192.png">

    <link rel="manifest" href="/img/manifest.json">
    <link rel="stylesheet" href="/css/rwd-icons.min.css">
    <link rel="stylesheet" href="/css/rwd.min.css">
    <link rel="stylesheet" href="/css/ims.css">

    <script src="/js/rwd.min.js"></script>
    <script src="/js/jquery-3.7.1.min.js"></script>
    <script src="/js/location-service.js?v=1.7"></script>
    <script src="/js/ims.js?v=1.1"></script>
    <script>
        let deferredPrompt;

        window.addEventListener('beforeinstallprompt', (e) => {
            e.preventDefault();
            deferredPrompt = e;
            console.log('Android 설치 이벤트');
        });

        document.addEventListener('DOMContentLoaded', () => {
            document.getElementById('install-btn').addEventListener('click', async () => {
                const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
                const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);

                if (deferredPrompt) {
                    // 안드로이드 크롬 시스템 팝업
                    deferredPrompt.prompt();
                    const { outcome } = await deferredPrompt.userChoice;
                    deferredPrompt = null;

                } else if (isIOS && isSafari) {
                    // iOS Safari 모달 안내
                    const modal = new bootstrap.Modal(document.getElementById('ios-guide-modal'));
                    modal.show();

                } else if (isIOS && !isSafari) {
                    alert('Safari 브라우저에서 열어주세요!');

                } else {
                    // 안드로이드 오류 or 이미 설치됨
                    alert('이미 설치되어 있거나, 지원하지 않은 브라우저입니다.');
                }
            });
        });
    </script>
</head>