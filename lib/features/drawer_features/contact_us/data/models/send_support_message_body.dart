class SendSupportMessageBody {
  const SendSupportMessageBody({
    required this.subject,
    required this.message,
    this.tripId,
  });

  final String subject;
  final String message;
  final int? tripId;

  Map<String, dynamic> toJson() => {
    'subject': subject.trim(),
    'message': message.trim(),
    if (tripId != null) 'trip_id': tripId,
  };
}
