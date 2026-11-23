import 'package:flutter/material.dart';

import '../data/notifications.dart';
import '../data/rental_store.dart';
import '../models/rental_record.dart';
import 'admin_my_page.dart';
import 'admin_page.dart';
import 'admin_requests_page.dart';
import 'admin_returns_page.dart';
import 'item_detail_page.dart';
import 'item_list_page.dart';
import 'login_page.dart';
import 'my_page.dart';
import 'my_rentals_page.dart';
import 'notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.studentId,
    required this.isAdmin,
  });

  final String studentId;
  final bool isAdmin;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  // 알림 설정 (Firebase 연동 전까지는 앱을 닫으면 초기화됩니다)
  bool notificationsEnabled = true;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _cancelRequest(RentalRecord record) {
    final ok = rentalStore.cancelRequest(record);
    _showMessage(
      ok ? '신청이 취소되었습니다.' : '승인 대기 중인 신청만 취소할 수 있습니다.',
    );
  }

  void _approve(RentalRecord record) {
    final ok = rentalStore.approve(record);
    _showMessage(
      ok ? '예약을 승인했습니다.' : '승인 대기 중인 신청만 승인할 수 있습니다.',
    );
  }

  void _reject(RentalRecord record) {
    final ok = rentalStore.reject(record);
    _showMessage(
      ok ? '예약을 거절했습니다.' : '승인 대기 중인 신청만 거절할 수 있습니다.',
    );
  }

  void _markReturned(RentalRecord record) {
    final ok = rentalStore.markReturned(record);
    _showMessage(
      ok ? '반납 처리되었습니다.' : '승인된 대여만 반납 처리할 수 있습니다.',
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsPage(
          isAdmin: widget.isAdmin,
          studentId: widget.studentId,
          enabled: notificationsEnabled,
        ),
      ),
    );
    // 알림을 읽고 돌아오면 배지 숫자를 갱신합니다.
    if (mounted) setState(() {});
  }

  /// 관리자: 마이페이지의 '물품 관리' 메뉴 → 물품 관리 화면
  void _openItemManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('물품 관리'),
            backgroundColor: const Color(0xFFF5F7FC),
          ),
          body: ListenableBuilder(
            listenable: rentalStore,
            builder: (context, _) {
              return AdminPage(
                items: rentalStore.items,
                onAdd: rentalStore.addItem,
                onDelete: rentalStore.removeItem,
                onChangeStock: rentalStore.changeTotal,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: rentalStore,
      builder: (context, _) {
        final itemListPage = ItemListPage(
          items: rentalStore.items,
          onSelect: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailPage(
                  item: item,
                  studentId: widget.studentId,
                  onViewRentals: () => setState(() => selectedIndex = 1),
                ),
              ),
            );
          },
        );

        final pendingCount = rentalStore.rentals
            .where((r) => r.stage == RentalStage.pending)
            .length;

        // 안 읽은 알림 수 (상단 알림 아이콘 배지)
        final unreadCount = buildNotifications(
          isAdmin: widget.isAdmin,
          studentId: widget.studentId,
          rentals: rentalStore.rentals,
          enabled: notificationsEnabled,
        ).where((n) => !readNotificationIds.contains(n.id)).length;

        final List<Widget> pages;
        final List<String> titles;
        final List<NavigationDestination> destinations;

        if (widget.isAdmin) {
          pages = [
            itemListPage,
            AdminRequestsPage(
              rentals: rentalStore.rentals,
              onApprove: _approve,
              onReject: _reject,
            ),
            AdminReturnsPage(
              rentals: rentalStore.rentals,
              onReturn: _markReturned,
            ),
            AdminMyPage(
              items: rentalStore.items,
              rentals: rentalStore.rentals,
              notificationsEnabled: notificationsEnabled,
              onNotificationsChanged: (value) {
                setState(() => notificationsEnabled = value);
              },
              onOpenItems: _openItemManagement,
              onOpenRequests: () => setState(() => selectedIndex = 1),
              onOpenReturns: () => setState(() => selectedIndex = 2),
              onLogout: _logout,
            ),
          ];
          titles = ['물품 목록', '예약 승인', '반납 관리', '마이페이지'];
          destinations = [
            const NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: '물품 목록',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.fact_check_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.fact_check),
              ),
              label: '예약 승인',
            ),
            const NavigationDestination(
              icon: Icon(Icons.swap_horiz_outlined),
              selectedIcon: Icon(Icons.swap_horiz),
              label: '반납 관리',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: '마이페이지',
            ),
          ];
        } else {
          pages = [
            itemListPage,
            MyRentalsPage(
              rentals: rentalStore.rentals,
              studentId: widget.studentId,
              onCancel: _cancelRequest,
            ),
            MyPage(
              studentId: widget.studentId,
              rentals: rentalStore.rentals,
              notificationsEnabled: notificationsEnabled,
              onNotificationsChanged: (value) {
                setState(() => notificationsEnabled = value);
              },
              onViewAll: () => setState(() => selectedIndex = 1),
              onLogout: _logout,
            ),
          ];
          titles = ['물품 목록', '예약 내역', '마이페이지'];
          destinations = const [
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: '물품 목록',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: '예약 내역',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: '마이페이지',
            ),
          ];
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(titles[selectedIndex]),
            backgroundColor: const Color(0xFFF5F7FC),
            actions: [
              Center(
                child: Text(
                  widget.isAdmin ? '관리자' : '학번 ${widget.studentId}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              IconButton(
                tooltip: '알림',
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: _openNotifications,
              ),
              IconButton(
                tooltip: '로그아웃',
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: pages[selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
            },
            destinations: destinations,
          ),
        );
      },
    );
  }
}