import 'rental_item.dart';

/// 저장되는 처리 단계 (관리자 처리에 따라 바뀜)
enum RentalStage { pending, approved, rejected, cancelled, returned }

/// 화면에 보여 주는 상태 (날짜에 따라 자동 계산)
enum RentalStatus {
  pending,
  reserved,
  renting,
  overdue,
  returned,
  rejected,
  cancelled,
}

extension RentalStatusLabel on RentalStatus {
  String get label {
    switch (this) {
      case RentalStatus.pending:
        return '승인 대기';
      case RentalStatus.reserved:
        return '예약 확정';
      case RentalStatus.renting:
        return '대여중';
      case RentalStatus.overdue:
        return '연체';
      case RentalStatus.returned:
        return '반납완료';
      case RentalStatus.rejected:
        return '거절됨';
      case RentalStatus.cancelled:
        return '취소됨';
    }
  }
}

class RentalRecord {
  RentalRecord({
    required this.item,
    required this.quantity,
    required this.startDate,
    required this.returnDate,
    required this.studentId,
    this.stage = RentalStage.pending,
    DateTime? requestedAt,
  }) : requestedAt = requestedAt ?? DateTime.now();

  final RentalItem item;
  int quantity;
  DateTime startDate;
  DateTime returnDate;
  String studentId;
  RentalStage stage;
  final DateTime requestedAt;

  String get itemName => item.name;

  /// 대여 기간(일)
  int get days => returnDate.difference(startDate).inDays;

  /// 재고를 점유하고 있는지 (승인 대기 또는 승인됨)
  bool get occupiesStock =>
      stage == RentalStage.pending || stage == RentalStage.approved;

  /// 재고를 점유하는 마지막 날 (연체 중이면 반납될 때까지 계속 점유)
  DateTime get occupiedUntil =>
      status == RentalStatus.overdue ? DateTime(9999, 12, 31) : returnDate;

  RentalStatus get status {
    switch (stage) {
      case RentalStage.pending:
        return RentalStatus.pending;
      case RentalStage.rejected:
        return RentalStatus.rejected;
      case RentalStage.cancelled:
        return RentalStatus.cancelled;
      case RentalStage.returned:
        return RentalStatus.returned;
      case RentalStage.approved:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        if (today.isAfter(returnDate)) return RentalStatus.overdue;
        if (today.isBefore(startDate)) return RentalStatus.reserved;
        return RentalStatus.renting;
    }
  }
}