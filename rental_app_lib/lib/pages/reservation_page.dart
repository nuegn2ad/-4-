import 'package:flutter/material.dart';

import '../models/rental_item.dart';
import '../models/rental_record.dart';
import '../utils/date_format.dart';
import 'reservation_complete_page.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({
    super.key,
    required this.item,
    required this.onComplete,
    required this.onViewRentals,
  });

  final RentalItem item;
  final RentalRecord? Function(
    RentalItem,
    int,
    DateTime,
    DateTime,
  ) onComplete;
  final VoidCallback onViewRentals;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime startDate = DateUtils.dateOnly(DateTime.now());
  late DateTime returnDate;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    returnDate = startDate.add(const Duration(days: 1));
  }

  Future<void> chooseDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : returnDate,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: isStart ? '대여 시작일 선택' : '반납 예정일 선택',
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        startDate = picked;
        if (!returnDate.isAfter(startDate)) {
          returnDate = startDate.add(const Duration(days: 1));
        }
      } else {
        if (picked.isAfter(startDate)) {
          returnDate = picked;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('물품 예약')),
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
          Text('예약 가능한 수량: ${widget.item.available}개'),
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
                onPressed: quantity < widget.item.available
                    ? () => setState(() => quantity++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: widget.item.available < 1
                  ? null
                  : () {
                      final record = widget.onComplete(
                        widget.item,
                        quantity,
                        startDate,
                        returnDate,
                      );
                      if (record == null) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReservationCompletePage(
                            record: record,
                            onViewRentals: widget.onViewRentals,
                          ),
                        ),
                      );
                    },
              child: const Text('예약 완료'),
            ),
          ),
        ],
      ),
    );
  }
}