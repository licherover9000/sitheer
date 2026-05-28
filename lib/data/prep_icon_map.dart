import 'package:flutter/material.dart';

/// Maps icon keys stored in Firestore to [IconData].
const prepIconByKey = <String, IconData>{
  'account_tree_outlined': Icons.account_tree_outlined,
  'storage_outlined': Icons.storage_outlined,
  'memory_outlined': Icons.memory_outlined,
  'table_chart_outlined': Icons.table_chart_outlined,
  'hub_outlined': Icons.hub_outlined,
  'schema_outlined': Icons.schema_outlined,
  'functions': Icons.functions,
  'psychology_alt_outlined': Icons.psychology_alt_outlined,
  'code_outlined': Icons.code_outlined,
  'bar_chart_outlined': Icons.bar_chart_outlined,
  'model_training_outlined': Icons.model_training_outlined,
};

String prepIconKey(IconData icon) {
  for (final entry in prepIconByKey.entries) {
    if (entry.value.codePoint == icon.codePoint) return entry.key;
  }
  return 'account_tree_outlined';
}

IconData prepIconFromKey(String? key) =>
    prepIconByKey[key] ?? Icons.menu_book_outlined;
