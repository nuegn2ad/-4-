import 'package:flutter/material.dart';

import '../models/rental_item.dart';

/// 앱 시작 시 사용하는 기본 물품 목록
List<RentalItem> createInitialItems() {
  return [
    RentalItem(
      name: '농구공',
      description: '농구 연습 및 체육 활동에 사용하는 농구공입니다.',
      available: 5,
      icon: Icons.sports_basketball,
    ),
    RentalItem(
      name: '공기주입기',
      description: '농구공, 축구공 등 각종 공에 공기를 주입하는 도구입니다.',
      available: 3,
      icon: Icons.air,
    ),
    RentalItem(
      name: '천막',
      description: '야외 행사와 체육 활동에 사용하는 천막입니다.',
      available: 2,
      icon: Icons.campaign,
    ),
    RentalItem(
      name: '축구공',
      description: '축구 경기와 연습에 사용하는 공입니다.',
      available: 5,
      icon: Icons.sports_soccer,
    ),
    RentalItem(
      name: '풋살공',
      description: '풋살 경기와 연습에 사용하는 공입니다.',
      available: 4,
      icon: Icons.sports_soccer,
    ),
    RentalItem(
      name: '족구공',
      description: '족구 경기와 체육 활동에 사용하는 공입니다.',
      available: 4,
      icon: Icons.sports_volleyball,
    ),
    RentalItem(
      name: '배구공',
      description: '배구 경기와 연습에 사용하는 공입니다.',
      available: 5,
      icon: Icons.sports_volleyball,
    ),
    RentalItem(
      name: '팀조끼',
      description: '체육 활동이나 팀 경기에서 팀을 구분하는 조끼입니다.',
      available: 20,
      icon: Icons.checkroom,
    ),
    RentalItem(
      name: '삼각대',
      description: '촬영이나 발표 기록에 사용하는 카메라 삼각대입니다.',
      available: 3,
      icon: Icons.camera_alt,
    ),
    RentalItem(
      name: '공학용 계산기',
      description: '수학 및 공학 계산에 사용하는 계산기입니다.',
      available: 8,
      icon: Icons.calculate,
    ),
    RentalItem(
      name: '부심기',
      description: '축구 경기에서 부심이 사용하는 깃발입니다.',
      available: 2,
      icon: Icons.flag,
    ),
    RentalItem(
      name: '빔프로젝터',
      description: '수업, 회의 및 팀 프로젝트 발표에 사용하는 장비입니다.',
      available: 2,
      icon: Icons.videocam,
    ),
    RentalItem(
      name: '셔틀콕',
      description: '배드민턴 경기와 연습에 사용하는 셔틀콕입니다.',
      available: 12,
      icon: Icons.sports_tennis,
    ),
    RentalItem(
      name: '의료키트함',
      description: '체육 활동 및 행사에서 사용하는 응급처치 용품함입니다.',
      available: 2,
      icon: Icons.medical_services,
    ),
    RentalItem(
      name: '실험가운',
      description: '실험실 수업 및 실험 활동에 사용하는 가운입니다.',
      available: 10,
      icon: Icons.science,
    ),
    RentalItem(
      name: '무릎담요',
      description: '강의실이나 야외 활동에서 사용하는 무릎담요입니다.',
      available: 8,
      icon: Icons.weekend,
    ),
  ];
}
