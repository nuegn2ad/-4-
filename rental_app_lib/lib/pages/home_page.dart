import 'package:flutter/material.dart';

import '../data/initial_items.dart';
import '../models/rental_item.dart';
import '../models/rental_record.dart';
import 'admin_page.dart';
import 'item_detail_page.dart';
import 'item_list_page.dart';
import 'my_rentals_page.dart';

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

  final List<RentalItem> items = createInitialItems();
  final List<RentalRecord> rentals = [];

  RentalRecord? completeReservation(
    RentalItem item,
    int quantity,
    DateTime startDate,
    DateTime returnDate,
  ) {
    if (quantity > item.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('남은 재고가 부족합니다.')),
      );
      return null;
    }

    final record = RentalRecord(
      itemName: item.name,
      quantity: quantity,
      startDate: startDate,
      returnDate: returnDate,
      studentId: widget.studentId,
    );

    setState(() {
      item.available -= quantity;
      rentals.add(record);
    });

    return record;
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ItemListPage(
        items: items,
        onSelect: (item) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetailPage(
                item: item,
                onReserve: completeReservation,
                onViewRentals: () => setState(() => selectedIndex = 1),
              ),
            ),
          );
        },
      ),
      MyRentalsPage(
        rentals: rentals,
        studentId: widget.studentId,
      ),
      if (widget.isAdmin)
        AdminPage(
          items: items,
          onAdd: (item) {
            setState(() => items.add(item));
          },
          onDelete: (item) {
            setState(() => items.remove(item));
          },
          onChangeStock: (item, quantity) {
            setState(() => item.available = quantity);
          },
        ),
    ];

    final titles = widget.isAdmin
        ? ['물품 목록', '대여 내역', '관리자 관리']
        : ['물품 목록', '내 대여 내역'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        backgroundColor: const Color(0xFFF5F7FC),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                widget.isAdmin ? '관리자' : '학번 ${widget.studentId}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: '물품 목록',
          ),
          const NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: '내 대여 내역',
          ),
          if (widget.isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings),
              label: '관리자',
            ),
        ],
      ),
    );
  }
}