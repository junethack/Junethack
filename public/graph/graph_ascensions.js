$(document).ready(function() {
  var chartDom = document.getElementById('chart_ascensions');
  if (!chartDom) return;
  var chart = echarts.init(chartDom, null, { renderer: 'svg' });
  var pointStart = Date.UTC(2026, 5, 1); // 2026-06-01
  var pointInterval = 24 * 3600 * 1000; // one day

  $.ajax({
    url: '/tmp/activity.csv',
    dataType: 'text',
    success: function(data) {
      var lines = data.split('\n');
      var values = lines[0].split(',').map(parseFloat);
      var seriesData = values.map(function(v, i) {
        return [pointStart + i * pointInterval, v];
      });

      chart.setOption({
        title: { text: 'Ascensions per Day', left: 'center' },
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'time' },
        yAxis: { type: 'value', name: 'Ascensions' },
        series: [{ type: 'bar', data: seriesData }],
        legend: { show: false },
        animation: false
      });
    }
  });
});
