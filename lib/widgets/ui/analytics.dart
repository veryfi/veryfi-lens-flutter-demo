import 'package:flutter/material.dart';
import 'package:veryfi_flutter_lens_demo/models/analytics_event.dart';

class AnalyticsWidget extends StatelessWidget {
  final List<AnalyticsEvent> _analytics;

  const AnalyticsWidget(this._analytics, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE9ECE4),
        body: _analytics.isEmpty
            ? const Center(child: Text('There is no data'))
            : _buildAnalyticsScreen());
  }

  Widget _buildAnalyticsScreen() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Text(
            "The following events represent the user's interactions with Lens:",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Expanded(
              child: ListView.builder(
                  itemCount: _analytics.length,
                  itemBuilder: (context, index) {
                    AnalyticsEvent event = _analytics[index];
                    return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(event.name),
                          subtitle: _getSubtitle(event.params),
                        ));
                  }))
        ],
      ),
    );
  }

  String mapToString(Map<Object?, Object?>? map) {
    return map != null ? map.entries
        .map((entry) => "${entry.key}: ${entry.value.toString()}")
        .join(', ') : "";
  }

  Widget _getSubtitle(Map<Object?, Object?>? params) {
    return params != null && params.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: params.entries.map((entry) {
              return Text("${entry.key}: ${entry.value}");
            }).toList(),
          )
        : const Text('No additional parameters');
  }
}
