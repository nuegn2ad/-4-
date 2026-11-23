import '../models/rental_item.dart';

/// 대여 규칙 (숫자만 바꾸면 전체에 적용됩니다)
class RentalPolicy {
  /// 최대 대여 기간(일)
  static const int maxDays = 7;

  /// 오늘부터 며칠 뒤까지 예약할 수 있는지
  static const int maxAdvanceDays = 60;

  /// 한 학생이 동시에 진행할 수 있는 신청/대여 건수
  static const int maxActivePerStudent = 3;

  /// 한 번에 신청할 수 있는 수량 (전체 수량의 절반, 최소 1개)
  static int maxQuantity(RentalItem item) {
    final half = item.total ~/ 2;
    return half < 1 ? 1 : half;
  }
}