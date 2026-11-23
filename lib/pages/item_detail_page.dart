import 'package:flutter/material.dart';

import '../data/rental_policy.dart';
import '../data/rental_store.dart';
import '../models/rental_item.dart';
import 'reservation_page.dart';

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({
    super.key,
    required this.item,
    required this.studentId,
    required this.onViewRentals,
  });

  final RentalItem item;
  final String studentId;
  final VoidCallback onViewRentals;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: rentalStore,
      builder: (context, _) {
        final left = rentalStore.currentAvailable(item);
        final availableToday = left > 0;

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
                    availableToday ? Icons.check_circle : Icons.info,
                    color: availableToday ? Colors.green : Colors.orange,
                  ),
                  title: Text(
                    availableToday ? '오늘 대여 가능' : '오늘은 남은 수량 없음',
                  ),
                  subtitle: Text(
                    '오늘 남은 수량: $left개 / 전체 ${item.total}개',
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.rule),
                  title: const Text('대여 규칙'),
                  subtitle: Text(
                    '최대 ${RentalPolicy.maxDays}일 대여 · '
                    '한 번에 최대 ${RentalPolicy.maxQuantity(item)}개\n'
                    '날짜를 선택하면 해당 기간의 신청 가능 수량을 확인할 수 있습니다.',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: item.total > 0
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReservationPage(
                                item: item,
                                studentId: studentId,
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
      },
    );
  }
}