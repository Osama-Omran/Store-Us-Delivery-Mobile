import 'package:flutter/cupertino.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/widgets/custom_text_field.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/custom_trip_container.dart';

class VanProducts extends StatelessWidget {
  const VanProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        CustomTextField(
          hint: context.strings.search_for_a_product,
          prefixIcon: Icon(CupertinoIcons.search),
        ),
        ...List.generate(
          10,
          (_) => ProductWidget(
            product: ProductModel(
              id: 'ITEM-001',
              name: 'مياه معدنية 600 مل',
              unit: 'كرتونة',
              slogan: 'من طلبات الرحلة',
              qty: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class ProductWidget extends StatelessWidget {
  const ProductWidget({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return CustomTripContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(spacing: 4, children: [Text(product.name)]),
        ],
      ),
    );
  }
}

class ProductModel {
  final String id, name, unit, slogan;
  final int qty;
  ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.slogan,
    required this.qty,
  });
}
