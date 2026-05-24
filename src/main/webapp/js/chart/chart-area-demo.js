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

// --- 데이터 생성 (1일~30일, 임시 데이터 0~100) ---
var daysLabels = [];
var dataReceipt = []; // 접수
var dataProcess = []; // 처리
var dataHold = [];    // 보류

for (var i = 1; i <= 30; i++) {
    daysLabels.push(i + "일");
    dataReceipt.push(Math.floor(Math.random() * 100));
    dataProcess.push(Math.floor(Math.random() * 100));
    dataHold.push(Math.floor(Math.random() * 100));
}
// ------------------------------------------------

// Area Chart Example
var ctx = document.getElementById("myAreaChart");
var myLineChart = new Chart(ctx, {
    type: 'line',
    data: {
        labels: daysLabels, // 1일 ~ 30일
        datasets: [
            {
                label: "접수", // 파란색
                lineTension: 0.3,
                backgroundColor: "rgba(78, 115, 223, 0.05)",
                borderColor: "rgba(78, 115, 223, 1)",
                pointRadius: 3,
                pointBackgroundColor: "rgba(78, 115, 223, 1)",
                pointBorderColor: "rgba(78, 115, 223, 1)",
                pointHoverRadius: 3,
                pointHoverBackgroundColor: "rgba(78, 115, 223, 1)",
                pointHoverBorderColor: "rgba(78, 115, 223, 1)",
                pointHitRadius: 10,
                pointBorderWidth: 2,
                data: dataReceipt,
            },
            {
                label: "처리", // 검정색 (다크 그레이)
                lineTension: 0.3,
                backgroundColor: "rgba(46, 46, 46, 0.05)",
                borderColor: "rgba(46, 46, 46, 1)",
                pointRadius: 3,
                pointBackgroundColor: "rgba(46, 46, 46, 1)",
                pointBorderColor: "rgba(46, 46, 46, 1)",
                pointHoverRadius: 3,
                pointHoverBackgroundColor: "rgba(46, 46, 46, 1)",
                pointHoverBorderColor: "rgba(46, 46, 46, 1)",
                pointHitRadius: 10,
                pointBorderWidth: 2,
                data: dataProcess,
            },
            {
                label: "보류", // 노란색
                lineTension: 0.3,
                backgroundColor: "rgba(246, 194, 62, 0.05)",
                borderColor: "rgba(246, 194, 62, 1)",
                pointRadius: 3,
                pointBackgroundColor: "rgba(246, 194, 62, 1)",
                pointBorderColor: "rgba(246, 194, 62, 1)",
                pointHoverRadius: 3,
                pointHoverBackgroundColor: "rgba(246, 194, 62, 1)",
                pointHoverBorderColor: "rgba(246, 194, 62, 1)",
                pointHitRadius: 10,
                pointBorderWidth: 2,
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
                    unit: 'date'
                },
                gridLines: {
                    display: false,
                    drawBorder: false
                },
                ticks: {
                    maxTicksLimit: 10 // 30일이므로 라벨 표시 개수 조정
                }
            }],
            yAxes: [{
                ticks: {
                    min: 0,
                    max: 100,
                    stepSize: 20, // 0, 20, 40, 60, 80, 100
                    maxTicksLimit: 5,
                    padding: 10,
                    callback: function(value, index, values) {
                        return number_format(value) + '건'; // '$' 제거하고 '건' 추가
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
            display: true, // 선이 3개이므로 범례를 켜두는 것이 좋습니다.
            position: 'bottom'
        },
        tooltips: {
            backgroundColor: "rgb(255,255,255)",
            bodyFontColor: "#858796",
            titleMarginBottom: 10,
            titleFontColor: '#6e707e',
            titleFontSize: 14,
            borderColor: '#dddfeb',
            borderWidth: 1,
            xPadding: 15,
            yPadding: 15,
            displayColors: true, // 툴팁 내 색상 표시
            intersect: false,
            mode: 'index',
            caretPadding: 10,
            callbacks: {
                label: function(tooltipItem, chart) {
                    var datasetLabel = chart.datasets[tooltipItem.datasetIndex].label || '';
                    return datasetLabel + ': ' + number_format(tooltipItem.yLabel) + '건';
                }
            }
        }
    }
});