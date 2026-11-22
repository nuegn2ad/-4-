import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/rental_item.dart';
import '../models/rental_record.dart';
import '../utils/date_format.dart';
import 'initial_items.dart';
import 'rental_policy.dart';

/// 앱 전체에서 공유하는 물품/대여 데이터 저장소
class RentalStore extends ChangeNotifier {
  static const _storageKey = 'rental_store_v1';

  final List<RentalItem> items = createInitialItems();
  final List<RentalRecord> rentals = [];

  // ───────── 기간별 재고 계산 ─────────

  /// 특정 날짜에 점유 중인 수량
  int usedOn(RentalItem item, DateTime day) {
    var used = 0;
    for (final r in rentals) {
      if (r.item != item || !r.occupiesStock) continue;
      if (!day.isBefore(r.startDate) && !day.isAfter(r.occupiedUntil)) {
        used += r.quantity;
      }
    }
    return used;
  }

  /// 선택한 기간(시작~반납) 동안 신청 가능한 수량
  int availableFor(RentalItem item, DateTime start, DateTime end) {
    final last = dateOnly(end);
    var maxUsed = 0;
    for (var d = dateOnly(start); !d.isAfter(last); d = addDays(d, 1)) {
      final used = usedOn(item, d);
      if (used > maxUsed) maxUsed = used;
    }
    final left = item.total - maxUsed;
    return left < 0 ? 0 : left;
  }

  /// 오늘 기준 남은 수량
  int currentAvailable(RentalItem item) {
    final today = dateOnly(DateTime.now());
    return availableFor(item, today, today);
  }

  /// 현재 대여 중인 수량 (대여중 + 연체)
  int rentingQty(RentalItem item) {
    var qty = 0;
    for (final r in rentals) {
      if (r.item != item) continue;
      if (r.status == RentalStatus.renting ||
          r.status == RentalStatus.overdue) {
        qty += r.quantity;
      }
    }
    return qty;
  }

  /// 앞으로 예약 가능한 기간 전체에서 가장 많이 점유되는 수량
  /// (전체 수량을 이보다 적게 줄이면 이미 받은 예약을 지킬 수 없습니다.)
  int peakUsed(RentalItem item) {
    final today = dateOnly(DateTime.now());
    final last = addDays(
      today,
      RentalPolicy.maxAdvanceDays + RentalPolicy.maxDays,
    );
    var peak = 0;
    for (var d = today; !d.isAfter(last); d = addDays(d, 1)) {
      final used = usedOn(item, d);
      if (used > peak) peak = used;
    }
    return peak;
  }

  // ───────── 신청 검증 ─────────

  /// 문제가 있으면 안내 문구를, 없으면 null을 돌려줍니다.
  String? validateRequest({
    required RentalItem item,
    required int quantity,
    required DateTime startDate,
    required DateTime returnDate,
    required String studentId,
  }) {
    final today = dateOnly(DateTime.now());

    if (startDate.isBefore(today)) {
      return '대여 시작일은 오늘 이후여야 합니다.';
    }
    if (!returnDate.isAfter(startDate)) {
      return '반납 예정일은 대여 시작일 이후여야 합니다.';
    }
    final days = returnDate.difference(startDate).inDays;
    if (days > RentalPolicy.maxDays) {
      return '최대 ${RentalPolicy.maxDays}일까지 대여할 수 있습니다.';
    }
    if (quantity < 1) {
      return '수량을 선택해 주세요.';
    }

    final maxQty = RentalPolicy.maxQuantity(item);
    if (quantity > maxQty) {
      return '이 물품은 한 번에 최대 $maxQty개까지 신청할 수 있습니다.';
    }

    final mine = rentals.where((r) => r.studentId == studentId);
    if (mine.any((r) => r.status == RentalStatus.overdue)) {
      return '연체 중인 물품이 있어 신청할 수 없습니다. 먼저 반납해 주세요.';
    }
    final active = mine.where((r) => r.occupiesStock).length;
    if (active >= RentalPolicy.maxActivePerStudent) {
      return '진행 중인 신청/대여는 최대 ${RentalPolicy.maxActivePerStudent}건입니다.';
    }

    final available = availableFor(item, startDate, returnDate);
    if (quantity > available) {
      return available == 0
          ? '선택한 기간에는 신청 가능한 수량이 없습니다. 다른 날짜를 선택해 주세요.'
          : '선택한 기간에 신청 가능한 수량은 $available개입니다.';
    }
    return null;
  }

  // ───────── 학생 기능 ─────────

  /// 예약 신청: '승인 대기' 상태로 등록합니다. (실패하면 null)
  RentalRecord? requestRental({
    required RentalItem item,
    required int quantity,
    required DateTime startDate,
    required DateTime returnDate,
    required String studentId,
  }) {
    final error = validateRequest(
      item: item,
      quantity: quantity,
      startDate: startDate,
      returnDate: returnDate,
      studentId: studentId,
    );
    if (error != null) return null;

    final record = RentalRecord(
      item: item,
      quantity: quantity,
      startDate: startDate,
      returnDate: returnDate,
      studentId: studentId,
    );
    rentals.add(record);
    notifyListeners();
    return record;
  }

  /// 승인 대기 중인 신청 취소 (재고는 기간 계산으로 자동 복구)
  bool cancelRequest(RentalRecord record) {
    if (record.stage != RentalStage.pending) return false;
    record.stage = RentalStage.cancelled;
    notifyListeners();
    return true;
  }

  // ───────── 관리자 기능 ─────────

  /// 승인 대기 → 승인
  bool approve(RentalRecord record) {
    if (record.stage != RentalStage.pending) return false;
    record.stage = RentalStage.approved;
    notifyListeners();
    return true;
  }

  /// 승인 대기 → 거절 (재고는 기간 계산으로 자동 복구)
  bool reject(RentalRecord record) {
    if (record.stage != RentalStage.pending) return false;
    record.stage = RentalStage.rejected;
    notifyListeners();
    return true;
  }

  /// 반납 확인: 승인된 건(대여중·연체 모두)을 반납 완료로 변경
  bool markReturned(RentalRecord record) {
    if (record.stage != RentalStage.approved) return false;
    record.stage = RentalStage.returned;
    notifyListeners();
    return true;
  }

  // ───────── 물품 관리 ─────────

  void addItem(RentalItem item) {
    items.add(item);
    notifyListeners();
  }

  void removeItem(RentalItem item) {
    items.remove(item);
    notifyListeners();
  }

  void changeTotal(RentalItem item, int total) {
    item.total = total;
    notifyListeners();
  }

  /// 물품 설명과 특이사항 수정
  void updateItemInfo(
    RentalItem item, {
    required String description,
    required String note,
  }) {
    item.description = description;
    item.note = note;
    notifyListeners();
  }

  // ───────── 저장 / 불러오기 ─────────

  Map<String, dynamic> _toJson() => {
        'items': [
          for (final i in items)
            {
              'name': i.name,
              'description': i.description,
              'total': i.total,
              'note': i.note,
            },
        ],
        'rentals': [
          for (final r in rentals)
            {
              'item': r.item.name,
              'quantity': r.quantity,
              'startDate': r.startDate.toIso8601String(),
              'returnDate': r.returnDate.toIso8601String(),
              'studentId': r.studentId,
              'stage': r.stage.name,
              'requestedAt': r.requestedAt.toIso8601String(),
            },
        ],
      };

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;

      final data = jsonDecode(raw) as Map<String, dynamic>;
      final iconByName = {
        for (final i in createInitialItems()) i.name: i.icon,
      };

      final loadedItems = <RentalItem>[
        for (final e in data['items'] as List)
          RentalItem(
            name: e['name'] as String,
            description: e['description'] as String,
            total: e['total'] as int,
            icon: iconByName[e['name']] ?? Icons.inventory_2_outlined,
            // 예전에 저장된 데이터에는 note가 없으므로 빈 글자로 처리합니다.
            note: (e['note'] as String?) ?? '',
          ),
      ];

      final byName = {for (final i in loadedItems) i.name: i};
      final loadedRentals = <RentalRecord>[];
      for (final e in data['rentals'] as List) {
        final item = byName[e['item']];
        if (item == null) continue;
        loadedRentals.add(
          RentalRecord(
            item: item,
            quantity: e['quantity'] as int,
            startDate: DateTime.parse(e['startDate'] as String),
            returnDate: DateTime.parse(e['returnDate'] as String),
            studentId: e['studentId'] as String,
            stage: RentalStage.values.byName(e['stage'] as String),
            requestedAt: DateTime.parse(e['requestedAt'] as String),
          ),
        );
      }

      items
        ..clear()
        ..addAll(loadedItems);
      rentals
        ..clear()
        ..addAll(loadedRentals);
    } catch (_) {
      // 저장된 데이터가 깨졌으면 기본 데이터로 시작합니다.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_toJson()));
    } catch (_) {}
  }

  /// 시연용: 모든 데이터를 처음 상태로 되돌립니다.
  Future<void> resetAll() async {
    items
      ..clear()
      ..addAll(createInitialItems());
    rentals.clear();
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _save();
  }
}

final rentalStore = RentalStore();