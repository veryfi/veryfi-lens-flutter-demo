class AnalyticsEvent {
  final String name;
  final Map<Object?, Object?>? params;

  const AnalyticsEvent({
    required this.name,
    this.params
  });
}
