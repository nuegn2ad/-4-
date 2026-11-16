import 'package:flutter/material.dart';

import '../models/rental_record.dart';
import '../utils/date_format.dart';

class MyRentalsPage extends StatelessWidget {
  const MyRentalsPage({
    super.key,
    required this.rentals,
    required this.studentId,
  });

  final List<RentalRecord> rentals;
  final String studentId;

  Color _statusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.reserved:
        return const Color(0xFF3157D5);
      case RentalStatus.renting:
        return const Color(0xFF2E9E5B);
      case RentalStatus.returned:
        return Colors.grey;
      case RentalStatus.overdue:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myRentals = rentals
        .where((rental) => rental.studentId == studentId)
        .toList()
        .reversed
        .toList();

    if (myRentals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('아직 예약한 물품이 없습니다.'),
            SizedBox(height: 4),
            Text('물품 목록에서 원하는 물품을 예약해 보세요.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myRentals.length,
      itemBuilder: (context, index) {
        final rental = myRentals[index];
        final status = rental.status;
        final color = _statusColor(status);
        final today = DateUtils.dateOnly(DateTime.now());
        final daysLeft = DateUtils.dateOnly(rental.returnDate)
            .difference(today)
            .inDays;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rental.itemName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('수량: ${rental.quantity}개'),
                Text('대여 시작일: ${formatDate(rental.startDate)}'),
                Text('반납 예정일: ${formatDate(rental.returnDate)}'),
                if (status == RentalStatus.overdue)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '반납 예정일이 ${-daysLeft}일 지났습니다.',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (status != RentalStatus.returned) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      final message = daysLeft < 0
                          ? '반납 예정일이 지났습니다.'
                          : daysLeft == 0
                              ? '알림 시뮬레이션: 오늘은 반납 예정일입니다!'
                              : daysLeft == 1
                                  ? '알림 시뮬레이션: 내일 반납 예정입니다!'
                                  : '알림 시뮬레이션: 반납까지 $daysLeft일 남았습니다.';

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    },
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text('반납 알림 테스트'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}