import 'package:flutter/material.dart';

import '../models/rental_item.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onDelete,
    required this.onChangeStock,
  });

  final List<RentalItem> items;
  final ValueChanged<RentalItem> onAdd;
  final ValueChanged<RentalItem> onDelete;
  final void Function(RentalItem, int) onChangeStock;

  Future<void> addItem(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final stockController = TextEditingController(text: '1');

    final result = await showDialog<RentalItem>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('새 물품 등록'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '물품 이름'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: '물품 설명'),
                ),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '재고 수량'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final stock = int.tryParse(stockController.text) ?? -1;

                if (name.isEmpty ||
                    stock < 0 ||
                    descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('물품 이름, 설명, 올바른 재고 수량을 입력해 주세요.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  RentalItem(
                    name: name,
                    description: descriptionController.text.trim(),
                    available: stock,
                    icon: Icons.inventory_2_outlined,
                  ),
                );
              },
              child: const Text('등록'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    stockController.dispose();

    if (result != null) {
      onAdd(result);
    }
  }

  Future<void> editStock(
    BuildContext context,
    RentalItem item,
  ) async {
    final controller = TextEditingController(
      text: item.available.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${item.name} 재고 수정'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '현재 대여 가능한 수량',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                final quantity = int.tryParse(controller.text);
                if (quantity == null || quantity < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('0 이상의 정수를 입력해 주세요.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, quantity);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result != null) {
      onChangeStock(item, result);
    }
  }

  Future<void> deleteItem(
    BuildContext context,
    RentalItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('물품 삭제'),
        content: Text('"${item.name}" 물품을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () => addItem(context),
              icon: const Icon(Icons.add),
              label: const Text('새 물품 등록'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('대여 가능 수량: ${item.available}개'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () => editStock(context, item),
                            child: const Text('재고 수정'),
                          ),
                          OutlinedButton(
                            onPressed: () => deleteItem(context, item),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
