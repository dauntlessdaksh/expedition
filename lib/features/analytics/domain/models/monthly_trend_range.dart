/// Time window options for the monthly distance trend chart.
enum MonthlyTrendRange {
  last30Days('Last 30 Days', 30),
  last90Days('Last 90 Days', 90),
  lastYear('Last Year', 365);

  const MonthlyTrendRange(this.label, this.days);

  final String label;
  final int days;
}
