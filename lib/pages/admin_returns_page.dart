import 'package:flutter/material.dart';

import '../models/rental_record.dart';

/// 관리자: 승인된 예약의 대여 현황을 보고 반납을 확인하는 화면
class AdminReturnsPage extends StatelessWidget {
  const AdminReturnsPage({
    super.key,
    required this.rentals,
    required this.onReturn,
  });

  final List<RentalRecord> rentals;
  final void Function(RentalRecord) onReturn;

  String _date(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.'
      '${d.day.toString().padLeft(2, '0')}';

  Color _statusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return Colors.orange.shade800;
      case RentalStatus.reserved:
        return Colors.blue.shade700;
      case RentalStatus.renting:
        return Colors.indigo.shade700;
      case RentalStatus.overdue:
        return Colors.red.shade700;
      case RentalStatus.returned:
        return Colors.green.shade700;
      case RentalStatus.rejected:
        return Colors.red.shade700;
      case RentalStatus.cancelled:
        return Colors.grey.shade700;
    }
  }

  int _rank(RentalStatus status) {
    switch (status) {
      case RentalStatus.overdue:
        return 0;
      case RentalStatus.renting:
        return 1;
      default:
        return 2;
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('아니오'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('예'),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    // 승인된 건만 표시: 연체 → 대여중 → 예약 확정 순
    final list = rentals
        .where((r) => r.stage == RentalStage.approved)
        .toList()
      ..sort((a, b) {
        final byRank = _rank(a.status).compareTo(_rank(b.status));
        if (byRank != 0) return byRank;
        return a.returnDate.compareTo(b.returnDate);
      });

    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_horiz, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('처리할 대여·반납 내역이 없습니다.'),
          ],
        ),
      );
    }

    final today = DateUtils.dateOnly(DateTime.now());

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final r = list[index];
        final status = r.status;
        final color = _statusColor(status);
        final canReturn =
            status == RentalStatus.renting || status == RentalStatus.overdue;
        final overdueDays =
            today.difference(DateUtils.dateOnly(r.returnDate)).inDays;

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
                        r.itemName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('신청자: 학번 ${r.studentId}'),
                Text('수량: ${r.quantity}개'),
                Text(
                  '대여 기간: ${_date(r.startDate)} ~ ${_date(r.returnDate)}',
                ),
                if (status == RentalStatus.overdue && overdueDays > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '연체 $overdueDays일째',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (status == RentalStatus.reserved)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '대여 시작일 전입니다.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                if (canReturn) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final ok = await _confirm(
                        context,
                        title: '반납 확인',
                        message:
                            '학번 ${r.studentId}의 "${r.itemName}" ${r.quantity}개를 '
                            '반납 처리할까요?',
                      );
                      if (ok) onReturn(r);
                    },
                    icon: const Icon(Icons.assignment_return),
                    label: const Text('반납 확인'),
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