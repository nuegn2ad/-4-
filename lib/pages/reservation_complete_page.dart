import 'package:flutter/material.dart';

import '../models/rental_record.dart';
import '../utils/date_format.dart';

class ReservationCompletePage extends StatelessWidget {
  const ReservationCompletePage({
    super.key,
    required this.record,
    required this.onViewRentals,
  });

  final RentalRecord record;
  final VoidCallback onViewRentals;

  void _goHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 신청 완료'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 12),
          Icon(
            Icons.pending_actions_rounded,
            size: 88,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            '예약 신청이 접수되었습니다!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '관리자가 승인하면 예약이 확정됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _InfoRow(label: '물품', value: record.itemName),
                  _InfoRow(label: '수량', value: '${record.quantity}개'),
                  _InfoRow(
                    label: '대여 시작일',
                    value: formatDate(record.startDate),
                  ),
                  _InfoRow(
                    label: '반납 예정일',
                    value: formatDate(record.returnDate),
                  ),
                  _InfoRow(label: '대여 기간', value: '${record.days}일'),
                  _InfoRow(label: '신청자', value: record.studentId),
                  _InfoRow(label: '상태', value: record.status.label),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: Color(0xFFB26A00)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '진행 상황은 "예약 내역"에서 확인할 수 있고, '
                    '승인 전에는 신청을 취소할 수 있습니다.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                _goHome(context);
                onViewRentals();
              },
              icon: const Icon(Icons.assignment),
              label: const Text('예약 내역 보기'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _goHome(context),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('물품 목록으로'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}