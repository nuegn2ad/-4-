import 'package:flutter/material.dart';

import '../models/rental_record.dart';
import '../utils/date_format.dart';

/// 화면에 보여 주는 알림 한 건
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.priority,
    required this.time,
  });

  final String id;
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  /// 작을수록 위에 표시 (0: 연체, 1: 오늘·내일 반납/새 신청, 2: 승인·거절 결과)
  final int priority;
  final DateTime time;
}

/// 읽은 알림 id 목록 (앱을 완전히 껐다 켜면 초기화됩니다. Firebase 연동 후 서버에 저장 예정)
final Set<String> readNotificationIds = <String>{};

const Color _green = Color(0xFF2E9E5B);
const Color _orange = Color(0xFFE67E00);
const Color _red = Colors.red;
const Color _blue = Color(0xFF039BE5);

/// 로그인한 사용자(학생/관리자)에 맞는 알림 목록을 만듭니다.
///
/// [enabled]가 꺼져 있으면 학생은 반납 관련 알림을, 관리자는 모든 알림을 받지 않습니다.
List<AppNotification> buildNotifications({
  required bool isAdmin,
  required String studentId,
  required List<RentalRecord> rentals,
  required bool enabled,
}) {
  final list = isAdmin
      ? _adminNotifications(rentals, enabled)
      : _studentNotifications(rentals, studentId, enabled);

  list.sort((a, b) {
    final byPriority = a.priority.compareTo(b.priority);
    if (byPriority != 0) return byPriority;
    return b.time.compareTo(a.time);
  });
  return list;
}

List<AppNotification> _studentNotifications(
  List<RentalRecord> rentals,
  String studentId,
  bool includeDue,
) {
  final today = DateUtils.dateOnly(DateTime.now());
  final result = <AppNotification>[];

  for (final r in rentals) {
    if (r.studentId != studentId) continue;

    final key = '$studentId-${r.requestedAt.microsecondsSinceEpoch}';
    final status = r.status;
    final daysLeft = DateUtils.dateOnly(r.returnDate).difference(today).inDays;
    final what = '${r.itemName} ${r.quantity}개';
    final period = '${formatDate(r.startDate)} ~ ${formatDate(r.returnDate)}';

    // 승인 결과
    if (status == RentalStatus.reserved || status == RentalStatus.renting) {
      result.add(
        AppNotification(
          id: '$key-approved',
          title: '예약이 승인되었습니다',
          message: '$what · $period',
          icon: Icons.check_circle_outline,
          color: _green,
          priority: 2,
          time: r.requestedAt,
        ),
      );
    }

    // 거절 결과
    if (status == RentalStatus.rejected) {
      result.add(
        AppNotification(
          id: '$key-rejected',
          title: '예약 신청이 거절되었습니다',
          message: '$what · 수량이 복구되었습니다.',
          icon: Icons.highlight_off,
          color: const Color(0xFFE57373),
          priority: 2,
          time: r.requestedAt,
        ),
      );
    }

    // 반납 관련 알림 (알림 설정이 켜져 있을 때만)
    if (!includeDue) continue;

    if (status == RentalStatus.renting && daysLeft == 1) {
      result.add(
        AppNotification(
          id: '$key-due1',
          title: '내일 반납 예정입니다',
          message: '$what · ${formatDate(r.returnDate)}까지 반납해 주세요.',
          icon: Icons.schedule,
          color: _orange,
          priority: 1,
          time: r.requestedAt,
        ),
      );
    }

    if (status == RentalStatus.renting && daysLeft == 0) {
      result.add(
        AppNotification(
          id: '$key-due0',
          title: '오늘 반납 예정일입니다',
          message: '$what · 오늘 안에 반납해 주세요.',
          icon: Icons.alarm,
          color: _red,
          priority: 1,
          time: r.requestedAt,
        ),
      );
    }

    if (status == RentalStatus.overdue) {
      result.add(
        AppNotification(
          id: '$key-overdue',
          title: '반납 기한이 ${-daysLeft}일 지났습니다',
          message: '$what · 바로 반납해 주세요. 반납 전에는 새 신청이 제한됩니다.',
          icon: Icons.warning_amber_rounded,
          color: _red,
          priority: 0,
          time: r.requestedAt,
        ),
      );
    }
  }

  return result;
}

List<AppNotification> _adminNotifications(
  List<RentalRecord> rentals,
  bool enabled,
) {
  if (!enabled) return [];

  final today = DateUtils.dateOnly(DateTime.now());
  final result = <AppNotification>[];

  for (final r in rentals) {
    final key = 'admin-${r.studentId}-${r.requestedAt.microsecondsSinceEpoch}';
    final what = '${r.itemName} ${r.quantity}개';

    if (r.status == RentalStatus.pending) {
      result.add(
        AppNotification(
          id: '$key-new',
          title: '새 예약 신청이 있습니다',
          message: '학번 ${r.studentId} · $what',
          icon: Icons.fact_check_outlined,
          color: _blue,
          priority: 1,
          time: r.requestedAt,
        ),
      );
    }

    if (r.status == RentalStatus.overdue) {
      final late = today.difference(DateUtils.dateOnly(r.returnDate)).inDays;
      result.add(
        AppNotification(
          id: '$key-overdue',
          title: '연체 중인 대여가 있습니다',
          message: '학번 ${r.studentId} · $what · $late일 연체',
          icon: Icons.warning_amber_rounded,
          color: _red,
          priority: 0,
          time: r.requestedAt,
        ),
      );
    }
  }

  return result;
}