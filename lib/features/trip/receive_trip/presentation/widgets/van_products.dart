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
          prefixIcon: const Icon(CupertinoIcons.search),
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
        // ضيف الكميات من تحميل الرحلة المعتمد — لا يمكن تعديلها هنا
      ],
    );
  }
}

class ProductWidget extends StatelessWidget {
  const ProductWidget({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return CustomTripContainer(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF102344),
                    ),
                  ),
                  Text(
                    '${product.id} • الوحدة: ${product.unit}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF72819B),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF2F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.slogan,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF75849B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                const Text(
                  'الكمية المحملة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8291AA),
                  ),
                ),
                Text(
                  product.qty.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF071B3C),
                  ),
                ),
              ],
            ),
          ],
        ),
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
