import 'package:timeago/timeago.dart' as timeago;

class CustomIdMessages implements timeago.LookupMessages {
  @override String prefixAgo() => '';
  @override String prefixFromNow() => '';
  @override String suffixAgo() => 'yang lalu';
  @override String suffixFromNow() => 'dari sekarang';
  @override String lessThanOneMinute(int seconds) => 'beberapa detik';
  @override String aboutAMinute(int minutes) => '1 menit';
  @override String minutes(int minutes) => '$minutes menit';
  @override String aboutAnHour(int minutes) => '1 jam';
  @override String hours(int hours) => '$hours jam';
  @override String aDay(int hours) => '1 hari';
  @override String days(int days) => '$days hari';
  @override String aboutAMonth(int days) => '1 bulan';
  @override String months(int months) => '$months bulan';
  @override String aboutAYear(int year) => '1 tahun';
  @override String years(int years) => '$years tahun';
  @override String wordSeparator() => ' ';
}
