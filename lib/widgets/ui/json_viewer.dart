import 'package:flutter/material.dart';
import 'dart:convert';

class JsonViewer extends StatelessWidget {
  final Map<String, dynamic> _eventData;

  const JsonViewer(this._eventData, {super.key});

  @override
  Widget build(BuildContext context) {
    return _buildJsonDataView();
  }

  Widget _buildJsonDataView() {
    if (_eventData.isEmpty) {
      return const Center(child: Text('No JSON data'));
    }

    Map<String, dynamic> jsonMap = json.decode(json.encode(_eventData));

    List<TextSpan> spans = _createSpans(jsonMap);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        text: TextSpan(
          children: spans,
          style: const TextStyle(color: Colors.black, fontSize: 14.0),
        ),
      ),
    );
  }

  List<TextSpan> _createSpans(dynamic value, {String indent = ''}) {
    List<TextSpan> spans = [];

    if (value is Map<String, dynamic>) {
      spans.add(
          const TextSpan(text: '{\n', style: TextStyle(color: Colors.black)));
      value.forEach((key, val) {
        spans.add(TextSpan(
            text: '$indent  "$key": ',
            style: const TextStyle(color: Colors.black)));
        spans.addAll(_createSpans(val, indent: '$indent  '));
        spans.add(
            const TextSpan(text: ',\n', style: TextStyle(color: Colors.black)));
      });
      spans.add(TextSpan(
          text: '$indent}', style: const TextStyle(color: Colors.black)));
    } else if (value is List) {
      spans.add(
          const TextSpan(text: '[\n', style: TextStyle(color: Colors.black)));
      for (var val in value) {
        spans.addAll(_createSpans(val, indent: '$indent  '));
        spans.add(
            const TextSpan(text: ',\n', style: TextStyle(color: Colors.black)));
      }
      spans.add(TextSpan(
          text: '$indent]', style: const TextStyle(color: Colors.black)));
    } else {
      spans.add(_formatValueSpan(value));
    }

    return spans;
  }

  TextSpan _formatValueSpan(dynamic value) {
    Color color;
    String text;

    if (value is String) {
      color = const Color(0xFF00AA00);
      text = '"$value"';
    } else if (value is int) {
      color = Colors.red;
      text = value.toString();
    } else if (value is bool) {
      color = Colors.red;
      text = value.toString();
    } else if (value is double) {
      color = Colors.orange;
      text = value.toString();
    } else {
      color = Colors.grey;
      text = value.toString();
    }

    return TextSpan(text: text, style: TextStyle(color: color));
  }
}
