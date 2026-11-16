import 'package:flutter/material.dart';

import '../models/rental_item.dart';
import '../models/rental_record.dart';
import 'reservation_page.dart';

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({
    super.key,
    required this.item,
    required this.onReserve,
    required this.onViewRentals,
  });

  final RentalItem item;
  final RentalRecord? Function(
    RentalItem,
    int,
    DateTime,
    DateTime,
  ) onReserve;
  final VoidCallback onViewRentals;

  @override
  Widget build(BuildContext context) {
    final available = item.available > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('물품 상세 정보')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              item.icon,
              size: 100,
              color: const Color(0xFF3157D5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(item.description),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(
                available ? Icons.check_circle : Icons.cancel,
                color: available ? Colors.green : Colors.red,
              ),
              title: Text(available ? '대여 가능' : '현재 대여 불가'),
              subtitle: Text('남은 수량: ${item.available}개'),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: available
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReservationPage(
                            item: item,
                            onComplete: onReserve,
                            onViewRentals: onViewRentals,
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.event_available),
              label: const Text('대여 예약하기'),
            ),
          ),
        ],
      ),
    );
  }
}