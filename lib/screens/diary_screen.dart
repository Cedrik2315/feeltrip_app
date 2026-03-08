import 'package:flutter/material.dart';

import '../services/database_service.dart';
import 'diario_screen.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({
    super.key,
    this.enableAds = true,
    this.databaseService,
    this.enableCamera = true,
  });

  final bool enableAds;
  final DatabaseService? databaseService;
  final bool enableCamera;

  @override
  Widget build(BuildContext context) {
    return DiarioScreen(enableAds: enableAds);
  }
}
