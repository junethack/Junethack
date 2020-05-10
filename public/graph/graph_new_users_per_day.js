$(document).ready(function() {

	var options = {
		chart: {
			renderTo: 'chart_new_users_per_day',
			type: 'column'
		},
		title: {
			text: 'New Users per Day'
		},
		xAxis: {
			type: 'datetime',
		},
		yAxis: {
			title: {
				text: 'New Users per Day'
			},
		},
		series: [],
		tooltip: {
			shared: true,
		},
		legend: {
			enabled: false
		},
	};
	
	/* Load the data from the CSV file. */
	$.get('/tmp/new_users_per_day.csv', function(data) {
		// Split the lines
		var lines = data.split('\n');
		$.each(lines, function(lineNo, line) {
			if (lineNo == 0) {
			var items = line.split(',');
			var series = {
				data: [],
				pointStart: Date.UTC(2020, 04, 27), // 2020-05-27
				pointInterval: 24 * 3600 * 1000, // one day
			};
			$.each(items, function(itemNo, item) {
				series.data.push(parseFloat(item));
			});
			
			options.series.push(series);
			}
		});
		
		var chart = new Highcharts.Chart(options);
	});
	
	
});
