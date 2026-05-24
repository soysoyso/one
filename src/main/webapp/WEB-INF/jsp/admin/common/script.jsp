<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="/js/rwd.min.js"></script>
<script src="/js/jquery-3.7.1.min.js"></script>
<script src="/js/flatpickr/flatpickr.min.js"></script>
<script src="/js/flatpickr/ko.js"></script>
<script src="/js/admin.js?v=1"></script>
<script src="/js/location-service.js?v=1.4"></script>
<!-- Custom scripts for all pages-->
<script src="/js/chart/sb-admin-2.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/Sortable.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<%--
<!-- Page level plugins -->
<script src="/js/chart/Chart.min.js"></script>
<!-- Page level custom scripts -->
<script src="/js/chart/chart-area-demo.js"></script>
<script src="/js/chart/chart-pie-demo.js"></script>
<script src="/js/chart/chart-bar-demo.js"></script>--%>

<script>
    const currentPath = window.location.pathname;

    document.querySelectorAll('.menu a').forEach(a => {
        const href = a.getAttribute('href');
        if (currentPath === href) {
            a.classList.add('active');
        }
    });

    // 공통 알림
    function showMsg(icon, title, text) {
        Swal.fire({
            icon: icon,
            title: title,
            text: text,
            confirmButtonText: '확인'
        });
    }

    function showSwal(icon, title, text) {
        return Swal.fire({
            icon: icon,
            title: title,
            text: text,
            confirmButtonText: '확인'
        });
    }

    function showConfirmSwal(title, text) {
        return Swal.fire({
            icon: 'warning',
            text: text || '',
            showCancelButton: true,
            confirmButtonText: '확인',
            cancelButtonText: '취소',
            reverseButtons: true
        });
    }

    function showSuccessSwal(text) {
        return Swal.fire({
            icon: 'success',
            title: '완료',
            text: text,
            timer: 1500,
            showConfirmButton: false
        });
    }

    // 정보수정 버튼 클릭
    $('#btnModify').on('click', function () {

        var currentPassword = $("#currentPassword").val();
        var newPassword = $("#newPassword").val();
        var newPassword2 = $("#newPassword2").val();

        var userTel = $("#userTel").val();
        var userMail = $("#userMail").val();
        var regExp = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d!@#$%^&*()\-+=<>?/[\]{},.:;]{6,20}$/;

        if (newPassword || newPassword2 || currentPassword) {
            if (!currentPassword) {
                showMsg('warning', '확인 필요', '기존 비밀번호를 입력해주세요.');
                return false;
            }
            if (!newPassword || !newPassword2) {
                showMsg('warning', '확인 필요', '변경할 비밀번호를 두 칸 모두 입력해주세요.');
                return false;
            }
            if (newPassword != newPassword2) {
                showMsg('warning', '확인 필요', '변경할 비밀번호가 일치하지 않습니다.');
                return false;
            }

            if (!regExp.test(newPassword)) {
                showMsg('warning', '확인 필요', '비밀번호는 영문, 숫자를 포함한 6자리 이상 20자리 이하입니다.');
                return false;
            }

            $("#password").val(newPassword);
        } else {
            $("#password").val("");
        }

        var cleanTel = (userTel || '').replace(/[^0-9]/g, '');

        if (cleanTel && !/^01[016789]\d{7,8}$/.test(cleanTel)) {
            showMsg('warning', '확인 필요', '올바른 전화번호 형식이 아닙니다.');
            return false;
        }

        if (cleanTel.length === 11) {
            userTel = cleanTel.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
        } else if (cleanTel.length === 10) {
            userTel = cleanTel.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
        }

        $("#userTel").val(userTel);

        if (userMail && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(userMail)) {
            showMsg('warning', '확인 필요', '올바른 이메일 형식이 아닙니다.');
            return false;
        }

        Swal.fire({
            title: '수정하시겠습니까?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: '수정',
            cancelButtonText: '취소'
        }).then(function (result) {

            if (!result.isConfirmed) return;

            $.ajax({
                url: '/user/personalInfoSave',
                type: "post",
                dataType: 'json',
                data: $('#userForm').serialize(),
                contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
                success: function (data) {
                    if (data.result) {
                        Swal.fire({
                            icon: 'success',
                            title: '수정 완료',
                            text: '개인 정보가 수정되었습니다.',
                            timer: 1500,
                            showConfirmButton: false
                        }).then(function () {
                            location.reload();
                        });
                    } else {
                        showMsg('error', '처리 실패', data.message || '처리 실패');
                    }
                },
                error: function () {
                    showMsg('error', '오류 발생', '개인 정보 수정 중 오류가 발생하였습니다.');
                }
            });
        });
    });

    $("#userTel").on("input", function () {
        let val = this.value.replace(/[^0-9]/g, '').slice(0, 11);

        if (val.length > 3 && val.length <= 7) {
            val = val.replace(/(\d{3})(\d+)/, "$1-$2");
        } else if (val.length > 7) {
            val = val.replace(/(\d{3})(\d{4})(\d{0,4})/, "$1-$2-$3");
        }

        this.value = val;
    });
</script>