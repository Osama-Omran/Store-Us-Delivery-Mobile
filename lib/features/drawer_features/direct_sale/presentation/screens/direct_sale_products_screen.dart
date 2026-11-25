import 'package:material_ui/material_ui.dart';

import '../widgets/direct_sale_page.dart';
import '../widgets/direct_sale_footer_buttons.dart';
import '../widgets/direct_sale_products_body.dart';

class DirectSaleProductsScreen extends StatelessWidget {
  const DirectSaleProductsScreen({super.key});
  @override
  Widget build(BuildContext context) => DirectSalePage(
    footer: const DirectSaleProductsFooter(),
    child: const DirectSaleProductsBody(),
  );
}
