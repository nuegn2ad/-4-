import 'package:flutter/material.dart';

class RentalItem {
  RentalItem({
    required this.name,
    required this.description,
    required this.total,
    required this.icon,
    this.note = '',
  });

  String name;
  String description;

  /// 전체 보유 수량 (남은 수량은 기간별로 계산합니다)
  int total;
  IconData icon;

  /// 특이사항 (관리자가 입력하는 선택 항목)
  String note;
}