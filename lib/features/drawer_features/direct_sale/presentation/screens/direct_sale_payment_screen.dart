import 'package:flutter/material.dart';

import '../widgets/direct_sale_page.dart';
import '../widgets/direct_sale_footer_buttons.dart';
import '../widgets/direct_sale_payment_body.dart';

class DirectSalePaymentScreen extends StatelessWidget {
  const DirectSalePaymentScreen({super.key});
  @override
  Widget build(BuildContext context) => DirectSalePage(
    footer: const DirectSalePaymentFooter(),
    child: const DirectSalePaymentBody(),
  );
}
