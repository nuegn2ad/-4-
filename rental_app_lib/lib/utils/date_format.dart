/// 날짜를 'YYYY.MM.DD' 형식 문자열로 변환합니다.
String formatDate(DateTime date) {
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.'
      '${date.day.toString().padLeft(2, '0')}';
}
