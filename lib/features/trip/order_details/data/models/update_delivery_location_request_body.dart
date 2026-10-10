
class UpdateDeliveryLocationBody {
  const UpdateDeliveryLocationBody({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.notes,
    this.city,
    this.country,
  });

  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String? notes;
  final String? city;
  final String? country;

  Map<String, dynamic> toJson() {
    return {
      'address': address.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone.trim(),
      'notes': notes?.trim(),
      'city': city?.trim(),
      'country': country?.trim(),
    };
  }
}
