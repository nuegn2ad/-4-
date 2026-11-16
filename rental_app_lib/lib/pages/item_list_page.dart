import 'package:flutter/material.dart';

import '../models/rental_item.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({
    super.key,
    required this.items,
    required this.onSelect,
  });

  final List<RentalItem> items;
  final ValueChanged<RentalItem> onSelect;

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  String keyword = '';

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((item) {
      return item.name.toLowerCase().contains(keyword.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: '물품 이름 검색',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => keyword = value);
            },
          ),
        ),
        Expanded(
          child: filteredItems.isEmpty
              ? const Center(child: Text('검색 결과가 없습니다.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final available = item.available > 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 26,
                          child: Icon(item.icon, size: 28),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            available
                                ? '대여 가능 · 남은 수량 ${item.available}개'
                                : '대여 가능 수량 없음',
                            style: TextStyle(
                              color: available
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => widget.onSelect(item),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
