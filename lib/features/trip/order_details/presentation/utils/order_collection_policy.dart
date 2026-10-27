/// Shared rule for the collection CTA and the collection submission guard.
///
/// A partially collected order is intentionally treated as NOT eligible
/// for the collection action, as required by the product flow.
class OrderCollectionPolicy {
  const OrderCollectionPolicy._();

  static String normalize(String? raw) =>
      (raw ?? '').trim().toUpperCase().replaceAll(RegExp(r'[\s-]+'), '_');

  static bool isFullyCollected(String? raw) => const {
        'PAID',
        'COLLECTED',
        'FULLY_PAID',
        'FULLY_COLLECTED',
      }.contains(normalize(raw));

  static bool isPartiallyCollected(String? raw) => const {
        'PARTIAL',
        'PARTIALLY_PAID',
        'PARTIAL_PAID',
        'PARTIALLY_COLLECTED',
        'PARTIAL_COLLECTED',
      }.contains(normalize(raw));

  /// Show the button for ALL other statuses (e.g. PENDING, UNPAID, FAILED).
  /// Visibility does NOT authorize a financial request. The backend's
  /// can_retry_collection and original client_operation_id still gate send.
  static bool showCollectButton(String? raw) =>
      !isFullyCollected(raw) && !isPartiallyCollected(raw);
}
