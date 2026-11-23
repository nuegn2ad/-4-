import 'package:flutter/material.dart';

import '../models/rental_item.dart';
import '../models/rental_record.dart';

/// 관리자 마이페이지: 계정 정보, 통계, 관리자 메뉴, 알림 설정, 로그아웃
class AdminMyPage extends StatelessWidget {
  const AdminMyPage({
    super.key,
    required this.items,
    required this.rentals,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.onOpenItems,
    required this.onOpenRequests,
    required this.onOpenReturns,
    required this.onLogout,
  });

  final List<RentalItem> items;
  final List<RentalRecord> rentals;
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onOpenItems;
  final VoidCallback onOpenRequests;
  final VoidCallback onOpenReturns;
  final VoidCallback onLogout;

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

  @override
  Widget build(BuildContext context) {
    // 총 대여 건수: 승인된 적 있는 대여 (대기·거절·취소 제외)
    final totalRentals = rentals
        .where((r) =>
            r.stage == RentalStage.approved || r.stage == RentalStage.returned)
        .length;
    final pending =
        rentals.where((r) => r.status == RentalStatus.pending).length;
    final renting = rentals
        .where((r) =>
            r.status == RentalStatus.renting ||
            r.status == RentalStatus.overdue)
        .length;
    final overdue =
        rentals.where((r) => r.status == RentalStatus.overdue).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 계정 정보
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.admin_panel_settings, size: 32),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '관리자',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '물품 관리자 계정',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 통계
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: '전체 등록 물품',
                    value: '${items.length}종',
                    color: const Color(0xFF039BE5),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '총 대여 건수',
                    value: '$totalRentals건',
                    color: const Color(0xFF2E9E5B),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: '승인 대기',
                    value: '$pending',
                    color: const Color(0xFFB26A00),
                    small: true,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '대여 중',
                    value: '$renting',
                    color: const Color(0xFF2E9E5B),
                    small: true,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '연체',
                    value: '$overdue',
                    color: overdue > 0 ? Colors.red : Colors.grey,
                    small: true,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 관리자 메뉴
        const SizedBox(height: 8),
        const Text(
          '관리자 메뉴',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('물품 관리'),
            subtitle: const Text('물품 등록 · 재고 수정 · 삭제'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenItems,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: const Text('예약 승인'),
            subtitle: Text(
              pending > 0 ? '승인 대기 $pending건' : '승인 대기 중인 신청이 없습니다.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenRequests,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('대여 현황 관리'),
            subtitle: Text('대여 중 $renting건 · 연체 $overdue건'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenReturns,
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
            title: const Text('관리자 알림'),
            subtitle: const Text('새 예약 신청과 연체를 알려 줍니다.'),
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
    this.small = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: small ? 22 : 26,
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