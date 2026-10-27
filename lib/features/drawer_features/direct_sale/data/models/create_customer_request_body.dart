class CreateCustomerRequestBody {
  const CreateCustomerRequestBody({
    required this.idempotencyKey,
    required this.customerName,
    required this.phone,
    required this.customerType,
    required this.customerGroup,
    required this.territory,
  });

  final String idempotencyKey;
  final String customerName;
  final String phone;
  final String customerType;
  final String customerGroup;
  final String territory;

  Map<String, dynamic> toJson() => {
    'idempotency_key': idempotencyKey,
    'customer_name': customerName,
    'phone': phone,
    'customer_type': customerType,
    'customer_group': customerGroup,
    'territory': territory,
  };
}
