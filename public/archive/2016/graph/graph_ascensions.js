$(document).ready(function() {

	var options = {
		chart: {
			renderTo: 'chart_ascensions',
			type: 'column'
		},
		title: {
			text: 'Ascensions per Day'
		},
		xAxis: {
			type: 'datetime',
		},
		yAxis: {
			title: {
				text: 'Ascensions'
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
	$.get('/tmp/activity.csv', function(data) {
		// Split the lines
		var lines = data.split('\n');
		$.each(lines, function(lineNo, line) {
			if (lineNo == 0) {
			var items = line.split(',');
			var series = {
				data: [],
				pointStart: Date.UTC(2016, 05, 01), // 2016-06-01
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
