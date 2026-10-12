enum TopRankPeriod {
  month('month'),
  last30Days('30d');

  const TopRankPeriod(this.apiValue);

  final String apiValue;
}

enum TopRankRole {
  representatives('representatives'),
  drivers('drivers'),
  dispatchers('dispatchers'),
  warehouses('warehouses'),
  warehouseStaff('warehouse-staff'),
  vehicles('vehicles');

  const TopRankRole(this.apiValue);

  final String apiValue;
}

num? _number(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
}

Map<String, dynamic> _map(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
}

class TopRankMetric {
  const TopRankMetric({
    required this.key,
    required this.label,
    this.unit,
    this.direction,
    this.weight,
    this.target,
    this.value,
    this.points,
  });

  final String key;
  final String label;
  final String? unit;
  final String? direction;
  final num? weight;
  final num? target;
  final num? value;
  final num? points;

  bool get hasCalculatedPoints =>
      points != null && weight != null && weight! > 0;

  factory TopRankMetric.fromJson(String key, Map<String, dynamic> json) {
    return TopRankMetric(
      key: key,
      label: json['label']?.toString() ?? key,
      unit: json['unit']?.toString(),
      direction: json['direction']?.toString(),
      weight: _number(json['weight']),
      target: _number(json['target']),
      value: _number(json['value']),
      points: _number(json['points']),
    );
  }

  double get progress {
    if (!hasCalculatedPoints) return 0;

    return (points!.toDouble() / weight!.toDouble()).clamp(0.0, 1.0);
  }
}

class TopRankAdviceAction {
  const TopRankAdviceAction({
    required this.message,
    this.metric,
    this.priority,
    this.impact,
  });

  final String message;
  final String? metric;
  final String? priority;
  final num? impact;

  factory TopRankAdviceAction.fromJson(Map<String, dynamic> json) {
    return TopRankAdviceAction(
      message: json['message']?.toString() ?? '',
      metric: json['metric']?.toString(),
      priority: json['priority']?.toString(),
      impact: _number(json['impact']),
    );
  }
}

class TopRankAdvice {
  const TopRankAdvice({this.actions = const [], this.strengths = const []});

  final List<TopRankAdviceAction> actions;
  final List<String> strengths;

  factory TopRankAdvice.fromJson(Map<String, dynamic> json) {
    return TopRankAdvice(
      actions: [
        for (final item
            in json['actions'] is List ? json['actions'] as List : const [])
          if (item is Map) TopRankAdviceAction.fromJson(_map(item)),
      ],
      strengths: [
        for (final item
            in json['strengths'] is List ? json['strengths'] as List : const [])
          if (item is String) item,
      ],
    );
  }
}

class TopRankEntry {
  const TopRankEntry({
    required this.id,
    required this.name,
    this.rank,
    this.score,
    this.previousRank,
    this.previousScore,
    this.movement,
    this.gap,
    this.provisional = false,
    this.trips,
    this.orders,
    this.operations,
    this.breakdown = const {},
    this.missing = const [],
    this.advice = const TopRankAdvice(),
  });

  final String id;
  final String name;

  final int? rank;
  final num? score;
  final int? previousRank;
  final num? previousScore;
  final int? movement;
  final num? gap;

  final bool provisional;
  final int? trips;
  final int? orders;
  final int? operations;

  final Map<String, TopRankMetric> breakdown;
  final List<String> missing;
  final TopRankAdvice advice;

  bool get hasScore => score != null;

  bool get hasPreviousRanking => previousRank != null;

  List<TopRankMetric> get metrics => breakdown.values.toList(growable: false);

  factory TopRankEntry.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = _map(json['breakdown']);

    return TopRankEntry(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      rank: _number(json['rank'])?.toInt(),
      score: _number(json['score']),
      previousRank: _number(json['previous_rank'])?.toInt(),
      previousScore: _number(json['previous_score']),
      movement: _number(json['movement'])?.toInt(),
      gap: _number(json['gap']),
      provisional: json['provisional'] == true,
      trips: _number(json['trips'])?.toInt(),
      orders: _number(json['orders'])?.toInt(),
      operations: _number(json['operations'])?.toInt(),
      breakdown: {
        for (final entry in rawBreakdown.entries)
          entry.key: TopRankMetric.fromJson(entry.key, _map(entry.value)),
      },
      missing: [
        for (final value
            in json['missing'] is List ? json['missing'] as List : const [])
          value.toString(),
      ],
      advice: TopRankAdvice.fromJson(_map(json['advice'])),
    );
  }
}
