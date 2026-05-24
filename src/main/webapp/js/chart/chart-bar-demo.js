// Set new default font family and font color to mimic Bootstrap's default styling
Chart.defaults.global.defaultFontFamily = 'Nunito', '-apple-system,system-ui,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif';
Chart.defaults.global.defaultFontColor = '#858796';

function number_format(number, decimals, dec_point, thousands_sep) {
    // * example: number_format(1234.56, 2, ',', ' ');
    // * return: '1 234,56'
    number = (number + '').replace(',', '').replace(' ', '');
    var n = !isFinite(+number) ? 0 : +number,
        prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
        sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep,
        dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
        s = '',
        toFixedFix = function(n, prec) {
            var k = Math.pow(10, prec);
            return '' + Math.round(n * k) / k;
        };
    // Fix for IE parseFloat(0.55).toFixed(0) = 0;
    s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
    if (s[0].length > 3) {
        s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
    }
    if ((s[1] || '').length < prec) {
        s[1] = s[1] || '';
        s[1] += new Array(prec - s[1].length + 1).join('0');
    }
    return s.join(dec);
}

// --- 데이터 생성 (1주차 ~ 5주차, 임시 데이터 0~100) ---
var weeksLabels = ["1주차", "2주차", "3주차", "4주차", "5주차"];
var dataReceipt = []; // 접수
var dataProcess = []; // 처리
var dataHold = [];    // 보류

// 5주차 분량의 임시 데이터 생성
for (var i = 0; i < 5; i++) {
    dataReceipt.push(Math.floor(Math.random() * 100));
    dataProcess.push(Math.floor(Math.random() * 100));
    dataHold.push(Math.floor(Math.random() * 100));
}
// ------------------------------------------------

// Bar Chart Example
var ctx = document.getElementById("myBarChart");
var myBarChart = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: weeksLabels, // 1주차~5주차
        datasets: [
            {
                label: "접수",
                backgroundColor: "#4e73df", // 파란색
                hoverBackgroundColor: "#2e59d9",
                borderColor: "#4e73df",
                data: dataReceipt,
            },
            {
                label: "처리",
                backgroundColor: "#2e2e2e", // 검정색 (진한 회색)
                hoverBackgroundColor: "#1a1a1a",
                borderColor: "#2e2e2e",
                data: dataProcess,
            },
            {
                label: "보류",
                backgroundColor: "#f6c23e", // 노란색
                hoverBackgroundColor: "#dda20a",
                borderColor: "#f6c23e",
                data: dataHold,
            }
        ],
    },
    options: {
        maintainAspectRatio: false,
        layout: {
            padding: {
                left: 10,
                right: 25,
                top: 25,
                bottom: 0
            }
        },
        scales: {
            xAxes: [{
                time: {
                    unit: 'week'
                },
                gridLines: {
                    display: false,
                    drawBorder: false
                },
                ticks: {
                    maxTicksLimit: 6
                },
                maxBarThickness: 25, // 막대 두께
            }],
            yAxes: [{
                ticks: {
                    min: 0,
                    max: 100,
                    stepSize: 20, // 0, 20, 40, 60, 80, 100 간격
                    maxTicksLimit: 5,
                    padding: 10,
                    callback: function(value, index, values) {
                        return number_format(value) + '건'; // '$' -> '건'
                    }
                },
                gridLines: {
                    color: "rgb(234, 236, 244)",
                    zeroLineColor: "rgb(234, 236, 244)",
                    drawBorder: false,
                    borderDash: [2],
                    zeroLineBorderDash: [2]
                }
            }],
        },
        legend: {
            display: true, // 범례 표시 (접수/처리/보류 구분)
            position: 'bottom'
        },
        tooltips: {
            titleMarginBottom: 10,
            titleFontColor: '#6e707e',
            titleFontSize: 14,
            backgroundColor: "rgb(255,255,255)",
            bodyFontColor: "#858796",
            borderColor: '#dddfeb',
            borderWidth: 1,
            xPadding: 15,
            yPadding: 15,
            displayColors: true, // 툴팁 색상 박스 표시
            caretPadding: 10,
            callbacks: {
                label: function(tooltipItem, chart) {
                    var datasetLabel = chart.datasets[tooltipItem.datasetIndex].label || '';
                    return datasetLabel + ': ' + number_format(tooltipItem.yLabel) + '건';
                }
            }
        },
    }
});