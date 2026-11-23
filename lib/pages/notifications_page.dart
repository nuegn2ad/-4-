import 'package:flutter/material.dart';

import '../data/notifications.dart';
import '../data/rental_store.dart';

/// 상단 알림 아이콘을 누르면 열리는 알림 목록 화면
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
    required this.isAdmin,
    required this.studentId,
    required this.enabled,
  });

  final bool isAdmin;
  final String studentId;
  final bool enabled;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: rentalStore,
      builder: (context, _) {
        final list = buildNotifications(
          isAdmin: widget.isAdmin,
          studentId: widget.studentId,
          rentals: rentalStore.rentals,
          enabled: widget.enabled,
        );
        final unread =
            list.where((n) => !readNotificationIds.contains(n.id)).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('알림'),
            backgroundColor: const Color(0xFFF5F7FC),
            actions: [
              TextButton(
                onPressed: unread == 0
                    ? null
                    : () {
                        setState(() {
                          readNotificationIds.addAll(list.map((n) => n.id));
                        });
                      },
                child: const Text('모두 읽음'),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      const Text('새로운 알림이 없습니다.'),
                      if (!widget.enabled) ...[
                        const SizedBox(height: 4),
                        const Text(
                          '마이페이지에서 알림 설정이 꺼져 있는지 확인해 보세요.',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final n = list[index];
                    final isRead = readNotificationIds.contains(n.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: isRead ? null : n.color.withValues(alpha: 0.06),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: n.color.withValues(alpha: 0.12),
                          child: Icon(n.icon, color: n.color),
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(n.message),
                        ),
                        trailing: isRead
                            ? null
                            : Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: n.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                        onTap: () {
                          setState(() => readNotificationIds.add(n.id));
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}