import 'package:flutter/material.dart';

class RentalItem {
  RentalItem({
    required this.name,
    required this.description,
    required this.available,
    required this.icon,
  });

  String name;
  String description;
  int available;
  IconData icon;
}
