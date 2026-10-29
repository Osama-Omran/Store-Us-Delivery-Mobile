import 'package:flutter/material.dart';

import '../widgets/direct_sale_page.dart';
import '../widgets/direct_sale_footer_buttons.dart';
import '../widgets/direct_sale_new_customer_body.dart';

class DirectSaleNewCustomerScreen extends StatelessWidget {
  const DirectSaleNewCustomerScreen({super.key});
  @override
  Widget build(BuildContext context) => DirectSalePage(
    newCustomer: true,
    footer: const DirectSaleNewCustomerFooter(),
    child: const DirectSaleNewCustomerBody(),
  );
}
