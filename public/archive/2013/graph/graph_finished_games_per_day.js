$(document).ready(function() {

	var options = {
		chart: {
			renderTo: 'chart_finished_games_per_day',
			type: 'column'
		},
		title: {
			text: 'Finished Games per Day'
		},
		xAxis: {
			type: 'datetime',
		},
		yAxis: {
			title: {
				text: 'Finished Games per Day'
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
	$.get('/tmp/finished_games_per_day.csv', function(data) {
		// Split the lines
		var lines = data.split('\n');
		$.each(lines, function(lineNo, line) {
			if (lineNo == 0) {
			var items = line.split(',');
			var series = {
				data: [],
				pointStart: Date.UTC(2012, 05, 01), // 2012-06-01
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
