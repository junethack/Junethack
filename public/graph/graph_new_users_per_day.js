$(document).ready(function() {
  var chartDom = document.getElementById('chart_new_users_per_day');
  if (!chartDom) return;
  var chart = echarts.init(chartDom, null, { renderer: 'svg' });
  var pointStart = Date.UTC(2026, 5, 1); // 2026-06-01
  var pointInterval = 24 * 3600 * 1000; // one day

  $.ajax({
    url: '/tmp/new_users_per_day.csv',
    dataType: 'text',
    success: function(data) {
      var lines = data.split('\n');
      var values = lines[0].split(',').map(parseFloat);
      var seriesData = values.map(function(v, i) {
        return [pointStart + i * pointInterval, v];
      });

      chart.setOption({
        title: { text: 'New Players per Day', left: 'center' },
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'time' },
        yAxis: { type: 'value', name: 'New Players per Day' },
        series: [{ type: 'bar', data: seriesData }],
        legend: { show: false },
        animation: false
      });
    }
  });
});
