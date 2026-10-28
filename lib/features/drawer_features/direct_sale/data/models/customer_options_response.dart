/// The server owns the allowed customer territories. Keep `name` unchanged.
class CustomerOptionsResponse {
  const CustomerOptionsResponse({
    required this.territories,
    required this.page,
    required this.hasMore,
  });

  final List<String> territories;
  final int page;
  final bool hasMore;

  factory CustomerOptionsResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] != true) {
      throw const FormatException('Customer options request was not successful');
    }
    final rawData = json['data'];
    if (rawData is! Map) {
      throw const FormatException('Missing customer options data');
    }
    final rawTerritories = rawData['territories'];
    if (rawTerritories is! List) {
      throw const FormatException('Missing territories list');
    }

    final territories = <String>[];
    for (final entry in rawTerritories) {
      if (entry is! Map) continue;
      final name = entry['name'];
      if (name is String && name.trim().isNotEmpty) {
        // Do not localize or trim the value submitted to the backend.
        territories.add(name);
      }
    }
    final rawPage = rawData['page'];
    final page = rawPage is int
        ? rawPage
        : int.tryParse(rawPage?.toString() ?? '') ?? 1;

    return CustomerOptionsResponse(
      territories: List.unmodifiable(territories),
      page: page,
      hasMore: rawData['has_more'] == true,
    );
  }
}
