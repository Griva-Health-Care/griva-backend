import 'package:flutter/foundation.dart';

@immutable
class FeatureRow {
  final String id;
  final String title;
  final List<String> col0;
  final List<String> col1;
  final List<String> col2;
  const FeatureRow({required this.id, required this.title, required this.col0, required this.col1, required this.col2});
}


