enum RentalStatus { reserved, renting, returned, overdue }

extension RentalStatusLabel on RentalStatus {
  String get label {
    switch (this) {
      case RentalStatus.reserved:
        return '예약중';
      case RentalStatus.renting:
        return '대여중';
      case RentalStatus.returned:
        return '반납완료';
      case RentalStatus.overdue:
        return '연체';
    }
  }
}

class RentalRecord {
  RentalRecord({
    required this.itemName,
    required this.quantity,
    required this.startDate,
    required this.returnDate,
    required this.studentId,
    this.returned = false,
  });

  String itemName;
  int quantity;
  DateTime startDate;
  DateTime returnDate;
  String studentId;
  bool returned;

  int get days => returnDate.difference(startDate).inDays;

  RentalStatus get status {
    if (returned) return RentalStatus.returned;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (today.isAfter(returnDate)) return RentalStatus.overdue;
    if (today.isBefore(startDate)) return RentalStatus.reserved;
    return RentalStatus.renting;
  }
}