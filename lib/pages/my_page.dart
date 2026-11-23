import 'package:flutter/material.dart';

import '../models/rental_record.dart';
import '../utils/date_format.dart';

/// 반납까지 남은 기간 표시 정보 (D-day 배지 + 색상)
class _Due {
  const _Due(this.label, this.color);

  final String label;
  final Color color;
}

/// 사용자 마이페이지: 계정 정보, 대여 현황, 알림 설정, 로그아웃
class MyPage extends StatelessWidget {
  const MyPage({
    super.key,
    required this.studentId,
    required this.rentals,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.onViewAll,
    required this.onLogout,
  });

  final String studentId;
  final List<RentalRecord> rentals;
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onViewAll;
  final VoidCallback onLogout;

  // 남은 기간 색상 (여유 / 임박 / 당일·연체)
  static const Color _safeColor = Color(0xFF2E9E5B);
  static const Color _soonColor = Color(0xFFE67E00);
  static const Color _urgentColor = Colors.red;

  _Due _dueOf(int daysLeft) {
    if (daysLeft < 0) return _Due('연체 ${-daysLeft}일', _urgentColor);
    if (daysLeft == 0) return const _Due('오늘 반납', _urgentColor);
    if (daysLeft <= 2) return _Due('D-$daysLeft', _soonColor);
    return _Due('D-$daysLeft', _safeColor);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (ok == true) {
      onLogout();
    }
  }

  Widget _currentCard(RentalRecord r, DateTime today) {
    final daysLeft = DateUtils.dateOnly(r.returnDate).difference(today).inDays;
    final due = _dueOf(daysLeft);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          '${r.itemName} · ${r.quantity}개',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${formatDate(r.startDate)} ~ ${formatDate(r.returnDate)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: due.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            due.label,
            style: TextStyle(
              color: due.color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mine = rentals.where((r) => r.studentId == studentId).toList();

    // 총 대여 횟수: 승인된 적 있는 대여 (승인 대기·거절·취소는 제외)
    final totalCount = mine
        .where((r) =>
            r.stage == RentalStage.approved || r.stage == RentalStage.returned)
        .length;
    final pendingCount =
        mine.where((r) => r.status == RentalStatus.pending).length;
    final reservedCount =
        mine.where((r) => r.status == RentalStatus.reserved).length;

    // 현재 대여 중(대여중·연체): 반납일이 가까운 순서
    final current = mine
        .where((r) =>
            r.status == RentalStatus.renting ||
            r.status == RentalStatus.overdue)
        .toList()
      ..sort((a, b) => a.returnDate.compareTo(b.returnDate));

    final today = DateUtils.dateOnly(DateTime.now());
    final shown = current.take(3).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 계정 정보
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '학번 $studentId',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '일반 사용자',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('총 대여 횟수'),
                    Text(
                      '$totalCount회',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '승인된 대여 기준 (대기·거절·취소 제외)',
                    style: TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 진행 현황 요약
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: '승인 대기',
                    value: pendingCount,
                    color: const Color(0xFFB26A00),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '예약 확정',
                    value: reservedCount,
                    color: const Color(0xFF039BE5),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '대여 중',
                    value: current.length,
                    color: _safeColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 현재 대여 중인 물품
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              '현재 대여 중인 물품',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: onViewAll,
              child: const Text('더보기'),
            ),
          ],
        ),
        if (shown.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  '현재 대여 중인 물품이 없습니다.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          )
        else
          for (final r in shown) _currentCard(r, today),
        if (current.length > shown.length)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              '외 ${current.length - shown.length}건은 "더보기"에서 확인하세요.',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),

        // 설정
        const SizedBox(height: 16),
        const Text(
          '설정',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('반납 알림'),
            subtitle: const Text('반납 예정일 하루 전에 알려 줍니다.'),
            value: notificationsEnabled,
            onChanged: onNotificationsChanged,
          ),
        ),

        // 로그아웃
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text('로그아웃'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}