import 'package:flutter/material.dart';

import '../models/rental_record.dart';
import '../utils/date_format.dart';

/// 반납까지 남은 기간 표시 정보 (D-day 배지 + 색상)
class _DueInfo {
  const _DueInfo(this.label, this.color);

  final String label;
  final Color color;
}

class MyRentalsPage extends StatefulWidget {
  const MyRentalsPage({
    super.key,
    required this.rentals,
    required this.studentId,
    required this.onCancel,
  });

  final List<RentalRecord> rentals;
  final String studentId;
  final void Function(RentalRecord) onCancel;

  @override
  State<MyRentalsPage> createState() => _MyRentalsPageState();
}

class _MyRentalsPageState extends State<MyRentalsPage> {
  int filterIndex = 0;

  static const filterLabels = ['전체', '승인 대기', '진행중', '종료'];

  // 남은 기간 색상 (여유 / 임박 / 당일·연체)
  static const Color _safeColor = Color(0xFF2E9E5B);
  static const Color _soonColor = Color(0xFFE67E00);
  static const Color _urgentColor = Colors.red;

  bool _matches(int index, RentalStatus s) {
    switch (index) {
      case 1:
        return s == RentalStatus.pending;
      case 2:
        return s == RentalStatus.reserved ||
            s == RentalStatus.renting ||
            s == RentalStatus.overdue;
      case 3:
        return s == RentalStatus.returned ||
            s == RentalStatus.rejected ||
            s == RentalStatus.cancelled;
      default:
        return true;
    }
  }

  Color _statusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return const Color(0xFFB26A00);
      case RentalStatus.reserved:
        return const Color(0xFF3157D5);
      case RentalStatus.renting:
        return const Color(0xFF2E9E5B);
      case RentalStatus.overdue:
        return Colors.red;
      case RentalStatus.returned:
        return Colors.grey;
      case RentalStatus.rejected:
        return const Color(0xFFE57373);
      case RentalStatus.cancelled:
        return Colors.grey;
    }
  }

  /// 진행 중인 건(예약 확정·대여중·연체)만 남은 기간을 표시합니다.
  _DueInfo? _dueInfo(RentalStatus status, int daysLeft) {
    final active = status == RentalStatus.reserved ||
        status == RentalStatus.renting ||
        status == RentalStatus.overdue;
    if (!active) return null;

    if (daysLeft < 0) {
      return _DueInfo('연체 ${-daysLeft}일', _urgentColor);
    }
    if (daysLeft == 0) {
      return const _DueInfo('오늘 반납', _urgentColor);
    }
    if (daysLeft <= 2) {
      return _DueInfo('D-$daysLeft', _soonColor);
    }
    return _DueInfo('D-$daysLeft', _safeColor);
  }

  String _description(RentalStatus status, int daysLeft) {
    switch (status) {
      case RentalStatus.pending:
        return '관리자 승인을 기다리고 있습니다.';
      case RentalStatus.reserved:
        return '승인되었습니다. 대여 시작일에 물품을 수령하세요.';
      case RentalStatus.renting:
        return '대여 중입니다. 반납 예정일까지 반납해 주세요.';
      case RentalStatus.overdue:
        return '반납 예정일이 ${-daysLeft}일 지났습니다. 바로 반납해 주세요.';
      case RentalStatus.returned:
        return '반납이 완료되었습니다.';
      case RentalStatus.rejected:
        return '신청이 거절되어 수량이 복구되었습니다.';
      case RentalStatus.cancelled:
        return '신청이 취소되어 수량이 복구되었습니다.';
    }
  }

  Future<void> _confirmCancel(RentalRecord rental) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('신청 취소'),
        content: Text(
          '"${rental.itemName}" ${rental.quantity}개 예약 신청을 취소할까요?\n'
          '취소하면 수량이 복구됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('닫기'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('신청 취소'),
          ),
        ],
      ),
    );

    if (ok == true) {
      widget.onCancel(rental);
    }
  }

  Widget _badge(String text, Color color, {double fontSize = 13}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildCard(RentalRecord rental) {
    final status = rental.status;
    final color = _statusColor(status);
    final today = DateUtils.dateOnly(DateTime.now());
    final daysLeft =
        DateUtils.dateOnly(rental.returnDate).difference(today).inDays;
    final due = _dueInfo(status, daysLeft);

    // 반납이 임박했거나 연체이면 카드 테두리로도 눈에 띄게 표시
    final highlight = due != null && due.color != _safeColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: highlight
            ? BorderSide(color: due.color, width: 1.5)
            : BorderSide.none,
      ),
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
                _badge(status.label, color),
              ],
            ),
            if (due != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: due.color),
                  const SizedBox(width: 6),
                  Text(
                    '반납까지 ',
                    style: TextStyle(color: due.color, fontSize: 13),
                  ),
                  _badge(due.label, due.color, fontSize: 14),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Text('수량: ${rental.quantity}개'),
            Text('대여 시작일: ${formatDate(rental.startDate)}'),
            Text('반납 예정일: ${formatDate(rental.returnDate)}'),
            Text('대여 기간: ${rental.days}일'),
            Text('신청일: ${formatDate(rental.requestedAt)}'),
            const SizedBox(height: 10),
            Text(
              _description(status, daysLeft),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (status == RentalStatus.pending) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _confirmCancel(rental),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('신청 취소'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mine = widget.rentals
        .where((rental) => rental.studentId == widget.studentId)
        .toList()
        .reversed
        .toList();

    if (mine.isEmpty) {
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

    final counts = List.generate(
      filterLabels.length,
      (i) => mine.where((r) => _matches(i, r.status)).length,
    );
    final filtered =
        mine.where((r) => _matches(filterIndex, r.status)).toList();

    // '진행중' 탭은 반납일이 가까운 순서로 정렬해서 급한 것이 위에 오게 합니다.
    if (filterIndex == 2) {
      filtered.sort((a, b) => a.returnDate.compareTo(b.returnDate));
    }

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            itemCount: filterLabels.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              return ChoiceChip(
                label: Text('${filterLabels[i]} (${counts[i]})'),
                selected: filterIndex == i,
                onSelected: (_) => setState(() => filterIndex = i),
              );
            },
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('해당하는 내역이 없습니다.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildCard(filtered[index]);
                  },
                ),
        ),
      ],
    );
  }
}