class AnalyticsEvent {
  const AnalyticsEvent(this.name, this.properties);

  final String name;
  final Map<String, Object?> properties;
}

abstract class AnalyticsService {
  void track(String name, [Map<String, Object?> properties = const {}]);
  List<AnalyticsEvent> get events;
}

class StubAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> _events = [];

  @override
  List<AnalyticsEvent> get events => List.unmodifiable(_events);

  @override
  void track(String name, [Map<String, Object?> properties = const {}]) {
    _events.add(AnalyticsEvent(name, properties));
  }
}
