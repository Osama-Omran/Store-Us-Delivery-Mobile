import 'top_rank_entry.dart';

class TopRankResponse {
  const TopRankResponse({required this.success, this.data, this.message});

  final bool success;
  final TopRankData? data;
  final String? message;

  factory TopRankResponse.fromJson(Map<String, dynamic> json) {
    return TopRankResponse(
      success: json['success'] == true,
      data: json['data'] is Map
          ? TopRankData.fromJson(Map<String, dynamic>.from(json['data'] as Map))
          : null,
      message: json['message']?.toString(),
    );
  }
}

class TopRankData {
  const TopRankData({
    required this.categories,
    required this.period,
    required this.warnings,
    this.detail,
    this.financialVisible = false,
    this.scope,
  });

  final Map<String, TopRankCategory> categories;
  final TopRankPeriodData period;
  final List<String> warnings;
  final TopRankEntry? detail;
  final bool financialVisible;
  final String? scope;

  factory TopRankData.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'] is Map
        ? Map<String, dynamic>.from(json['categories'] as Map)
        : <String, dynamic>{};

    return TopRankData(
      period: TopRankPeriodData.fromJson(
        json['period'] is Map
            ? Map<String, dynamic>.from(json['period'] as Map)
            : {},
      ),
      categories: {
        for (final entry in rawCategories.entries)
          if (entry.value is Map)
            entry.key: TopRankCategory.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            ),
      },
      detail: _parseDetail(json['detail']),
      financialVisible: json['financial_visible'] == true,
      scope: json['scope']?.toString(),
      warnings: [
        for (final value
            in json['warnings'] is List ? json['warnings'] as List : const [])
          value.toString(),
      ],
    );
  }

  // Supports direct detail or nested entry/entity forms.
  // Unknown detail structures are not guessed.
  static TopRankEntry? _parseDetail(dynamic raw) {
    if (raw is! Map) return null;

    final json = Map<String, dynamic>.from(raw);

    if (json.containsKey('score') && json.containsKey('breakdown')) {
      return TopRankEntry.fromJson(json);
    }

    for (final key in ['entry', 'entity', 'ranking']) {
      final value = json[key];

      if (value is Map &&
          value.containsKey('score') &&
          value.containsKey('breakdown')) {
        return TopRankEntry.fromJson(Map<String, dynamic>.from(value));
      }
    }

    return null;
  }
}

class TopRankPeriodData {
  const TopRankPeriodData({this.range, this.from, this.to});

  final String? range;
  final DateTime? from;
  final DateTime? to;

  factory TopRankPeriodData.fromJson(Map<String, dynamic> json) {
    return TopRankPeriodData(
      range: json['range']?.toString(),
      from: DateTime.tryParse(json['from']?.toString() ?? ''),
      to: DateTime.tryParse(json['to']?.toString() ?? ''),
    );
  }
}

class TopRankCategory {
  const TopRankCategory({
    required this.key,
    required this.label,
    required this.winnerLabel,
    required this.ranked,
    this.winner,
    this.pagination = const TopRankPagination(),
  });

  final String key;
  final String label;
  final String winnerLabel;

  final TopRankEntry? winner;
  final List<TopRankEntry> ranked;
  final TopRankPagination pagination;

  factory TopRankCategory.fromJson(Map<String, dynamic> json) {
    return TopRankCategory(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      winnerLabel: json['winner_label']?.toString() ?? '',
      winner: json['winner'] is Map
          ? TopRankEntry.fromJson(
              Map<String, dynamic>.from(json['winner'] as Map),
            )
          : null,
      ranked: [
        for (final value
            in json['ranked'] is List ? json['ranked'] as List : const [])
          if (value is Map)
            TopRankEntry.fromJson(Map<String, dynamic>.from(value)),
      ],
      pagination: TopRankPagination.fromJson(
        json['pagination'] is Map
            ? Map<String, dynamic>.from(json['pagination'] as Map)
            : {},
      ),
    );
  }
}

class TopRankPagination {
  const TopRankPagination({
    this.page = 1,
    this.perPage = 20,
    this.total = 0,
    this.lastPage = 1,
  });

  final int page;
  final int perPage;
  final int total;
  final int lastPage;

  factory TopRankPagination.fromJson(Map<String, dynamic> json) {
    int read(String key, int fallback) {
      final value = json[key];
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return TopRankPagination(
      page: read('page', 1),
      perPage: read('per_page', 20),
      total: read('total', 0),
      lastPage: read('last_page', 1),
    );
  }
}
