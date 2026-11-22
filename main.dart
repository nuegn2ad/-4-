import 'package:flutter/material.dart';

import 'app.dart';
import 'data/rental_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await rentalStore.load();
  runApp(const RentalApp());
}