import 'dart:math';

import 'package:flutter/material.dart';

import '../data/rental_store.dart';
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
    final result = await showDialog<_ItemFormResult>(
      context: context,
      builder: (_) => _ItemFormDialog(
        existingNames: items.map((e) => e.name).toList(),
      ),
    );

    if (result == null) return;

    onAdd(
      RentalItem(
        name: result.name,
        description: result.description,
        total: result.total,
        icon: Icons.inventory_2_outlined,
        note: result.note,
      ),
    );
  }

  Future<void> editItem(BuildContext context, RentalItem item) async {
    // 이미 받은 예약을 지킬 수 있는 최소 전체 수량
    final minTotal = max(1, rentalStore.peakUsed(item));

    final result = await showDialog<_ItemFormResult>(
      context: context,
      builder: (_) => _ItemFormDialog(item: item, minTotal: minTotal),
    );

    if (result == null) return;

    rentalStore.updateItemInfo(
      item,
      description: result.description,
      note: result.note,
    );
    if (result.total != item.total) {
      onChangeStock(item, result.total);
    }
  }

  Future<void> deleteItem(BuildContext context, RentalItem item) async {
    // 진행 중인 예약이 있는 물품은 삭제하지 못하게 막습니다.
    final inUse = rentalStore.rentals.any(
      (r) => r.item == item && r.occupiesStock,
    );
    if (inUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('진행 중인 예약이 있어 삭제할 수 없습니다.'),
        ),
      );
      return;
    }

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
              final available = rentalStore.currentAvailable(item);
              final renting = rentalStore.rentingQty(item);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
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
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      if (item.note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Color(0xFFE67E00),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '특이사항: ${item.note}',
                                style: const TextStyle(
                                  color: Color(0xFFB26A00),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F9FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                label: '전체 보유',
                                value: item.total,
                                color: Colors.black87,
                              ),
                            ),
                            Expanded(
                              child: _MiniStat(
                                label: '오늘 대여 가능',
                                value: available,
                                color: available > 0
                                    ? const Color(0xFF2E9E5B)
                                    : Colors.red,
                              ),
                            ),
                            Expanded(
                              child: _MiniStat(
                                label: '대여 중',
                                value: renting,
                                color: const Color(0xFF039BE5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => editItem(context, item),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('수정'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => deleteItem(context, item),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('삭제'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}

/// 등록·수정 대화상자가 돌려주는 값
class _ItemFormResult {
  const _ItemFormResult({
    required this.name,
    required this.description,
    required this.note,
    required this.total,
  });

  final String name;
  final String description;
  final String note;
  final int total;
}

/// 물품 등록(item == null) / 수정(item != null) 대화상자
class _ItemFormDialog extends StatefulWidget {
  const _ItemFormDialog({
    this.item,
    this.existingNames = const [],
    this.minTotal = 1,
  });

  final RentalItem? item;
  final List<String> existingNames;

  /// 전체 수량으로 입력할 수 있는 최솟값
  final int minTotal;

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController noteController;
  late final TextEditingController totalController;
  String? error;

  bool get isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    nameController = TextEditingController(text: item?.name ?? '');
    descriptionController = TextEditingController(text: item?.description ?? '');
    noteController = TextEditingController(text: item?.note ?? '');
    totalController = TextEditingController(text: '${item?.total ?? 1}');
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    noteController.dispose();
    totalController.dispose();
    super.dispose();
  }

  void save() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final note = noteController.text.trim();
    final total = int.tryParse(totalController.text.trim());

    if (name.isEmpty || description.isEmpty) {
      setState(() => error = '물품 이름과 설명을 입력해 주세요.');
      return;
    }
    if (!isEdit && widget.existingNames.contains(name)) {
      setState(() => error = '이미 등록된 물품입니다. 기존 물품을 수정해 주세요.');
      return;
    }
    if (total == null || total < 1) {
      setState(() => error = '전체 수량은 1 이상의 정수로 입력해 주세요.');
      return;
    }
    if (total < widget.minTotal) {
      setState(() {
        error = '예약·대여 중인 수량이 있어 전체 수량을 '
            '${widget.minTotal}개 미만으로 줄일 수 없습니다.';
      });
      return;
    }

    Navigator.pop(
      context,
      _ItemFormResult(
        name: name,
        description: description,
        note: note,
        total: total,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEdit ? '${widget.item!.name} 정보 수정' : '새 물품 등록'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              enabled: !isEdit,
              decoration: const InputDecoration(labelText: '물품 이름'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: '물품 설명'),
            ),
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '전체 보유 수량',
                helperText:
                    isEdit && widget.minTotal > 1 ? '최소 ${widget.minTotal}개' : null,
              ),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: '특이사항 (선택)',
                hintText: '예: 공기가 빠진 상태로 보관, 반납 시 세척 필요',
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Icon(Icons.image_outlined, size: 18, color: Colors.black45),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '사진 첨부는 서버 연동 후 지원됩니다.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: save,
          child: Text(isEdit ? '저장' : '등록 완료'),
        ),
      ],
    );
  }
}