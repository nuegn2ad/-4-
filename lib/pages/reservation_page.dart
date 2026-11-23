import 'dart:math';

import 'package:flutter/material.dart';

import '../data/rental_policy.dart';
import '../data/rental_store.dart';
import '../models/rental_item.dart';
import '../utils/date_format.dart';
import 'reservation_complete_page.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({
    super.key,
    required this.item,
    required this.studentId,
    required this.onViewRentals,
  });

  final RentalItem item;
  final String studentId;
  final VoidCallback onViewRentals;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late DateTime startDate;
  late DateTime returnDate;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    startDate = dateOnly(DateTime.now());
    returnDate = addDays(startDate, 1);
  }

  /// 선택한 기간에 신청 가능한 수량
  int get _available =>
      rentalStore.availableFor(widget.item, startDate, returnDate);

  /// 이번 신청에서 고를 수 있는 최대 수량
  int get _maxQuantity =>
      min(_available, RentalPolicy.maxQuantity(widget.item));

  void _clampQuantity() {
    final maxQty = _maxQuantity;
    if (maxQty >= 1 && quantity > maxQty) quantity = maxQty;
    if (quantity < 1) quantity = 1;
  }

  Future<void> chooseDate(bool isStart) async {
    final today = dateOnly(DateTime.now());
    final DateTime first;
    final DateTime last;

    if (isStart) {
      first = today;
      last = addDays(today, RentalPolicy.maxAdvanceDays);
    } else {
      first = addDays(startDate, 1);
      last = addDays(startDate, RentalPolicy.maxDays);
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : returnDate,
      firstDate: first,
      lastDate: last,
      helpText: isStart
          ? '대여 시작일 선택'
          : '반납 예정일 선택 (최대 ${RentalPolicy.maxDays}일)',
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        startDate = dateOnly(picked);
        final days = returnDate.difference(startDate).inDays;
        if (days < 1 || days > RentalPolicy.maxDays) {
          returnDate = addDays(startDate, 1);
        }
      } else {
        returnDate = dateOnly(picked);
      }
      _clampQuantity();
    });
  }

  void _submit() {
    final record = rentalStore.requestRental(
      item: widget.item,
      quantity: quantity,
      startDate: startDate,
      returnDate: returnDate,
      studentId: widget.studentId,
    );

    if (record == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신청할 수 없습니다. 입력 내용을 확인해 주세요.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReservationCompletePage(
          record: record,
          onViewRentals: widget.onViewRentals,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = returnDate.difference(startDate).inDays;
    final available = _available;
    final maxQty = _maxQuantity;

    final error = rentalStore.validateRequest(
      item: widget.item,
      quantity: quantity,
      startDate: startDate,
      returnDate: returnDate,
      studentId: widget.studentId,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('예약 신청')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            widget.item.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '전체 ${widget.item.total}개 · '
            '선택한 기간 신청 가능 수량 $available개',
          ),
          const SizedBox(height: 24),
          const Text(
            '대여 시작일',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => chooseDate(true),
            icon: const Icon(Icons.calendar_today),
            label: Text(formatDate(startDate)),
          ),
          const SizedBox(height: 20),
          const Text(
            '반납 예정일',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => chooseDate(false),
            icon: const Icon(Icons.event),
            label: Text(formatDate(returnDate)),
          ),
          const SizedBox(height: 8),
          Text(
            '대여 기간: $days일 (최대 ${RentalPolicy.maxDays}일)',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          const Text(
            '대여 수량',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                onPressed: quantity > 1
                    ? () => setState(() => quantity--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$quantity개',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: quantity < maxQty
                    ? () => setState(() => quantity++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
              const SizedBox(width: 8),
              Text(
                '(한 번에 최대 ${RentalPolicy.maxQuantity(widget.item)}개)',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (error != null)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF3157D5)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '예약은 관리자 승인 후 확정됩니다.\n'
                    '신청하면 수량이 먼저 확보되고, 취소하거나 거절되면 복구됩니다.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: error == null ? _submit : null,
              child: const Text('예약 신청하기'),
            ),
          ),
        ],
      ),
    );
  }
}