/// 날짜를 'YYYY.MM.DD' 형식 문자열로 변환합니다.
String formatDate(DateTime date) {
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.'
      '${date.day.toString().padLeft(2, '0')}';
}

/// 시각을 제거하고 날짜만 남깁니다.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 날짜에 일수를 더합니다.
DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);