import 'package:flutter/material.dart';

import '../widgets/direct_sale_page.dart';
import '../widgets/direct_sale_footer_buttons.dart';
import '../widgets/direct_sale_customer_selection_body.dart';

class DirectSaleCustomerSelectionScreen extends StatelessWidget {
  const DirectSaleCustomerSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) => DirectSalePage(
    footer: const DirectSaleCustomerSelectionFooter(),
    child: const DirectSaleCustomerSelectionBody(),
  );
}
