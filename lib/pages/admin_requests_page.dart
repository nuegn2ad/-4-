import 'package:flutter/material.dart';

import '../models/rental_record.dart';

/// 관리자: 승인 대기 중인 예약 신청을 승인/거절하는 화면
class AdminRequestsPage extends StatelessWidget {
  const AdminRequestsPage({
    super.key,
    required this.rentals,
    required this.onApprove,
    required this.onReject,
  });

  final List<RentalRecord> rentals;
  final void Function(RentalRecord) onApprove;
  final void Function(RentalRecord) onReject;

  String _date(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.'
      '${d.day.toString().padLeft(2, '0')}';

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
    // 오래 기다린 신청부터 위에 표시
    final pending = rentals
        .where((r) => r.stage == RentalStage.pending)
        .toList()
      ..sort((a, b) => a.requestedAt.compareTo(b.requestedAt));

    if (pending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fact_check_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('승인 대기 중인 예약이 없습니다.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final r = pending[index];

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
                        color: Colors.orange.shade800.withAlpha(32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r.status.label,
                        style: TextStyle(
                          color: Colors.orange.shade800,
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
                  '대여 기간: ${_date(r.startDate)} ~ ${_date(r.returnDate)} '
                  '(${r.days}일)',
                ),
                Text('신청일: ${_date(r.requestedAt)}'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => onApprove(r),
                      icon: const Icon(Icons.check),
                      label: const Text('승인'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await _confirm(
                          context,
                          title: '예약 거절',
                          message:
                              '학번 ${r.studentId}의 "${r.itemName}" 신청을 거절할까요?',
                        );
                        if (ok) onReject(r);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('거절'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}