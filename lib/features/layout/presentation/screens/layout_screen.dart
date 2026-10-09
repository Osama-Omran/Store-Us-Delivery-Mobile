
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_state.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_nav_bar.dart';

class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: BlocBuilder<LayoutCubit, LayoutState>(
        builder: (_, _) =>
        LayoutCubit.get(context).currentScreen,
      ),

      bottomNavigationBar: const AppNavBar(),

      drawer: AppMenuDrawer(
        userName: 'أحمد محمد',
        userRole: 'مندوب توصيل',
        isOnTrip: true,
        pendingDeliveriesCount: 4,
        pendingTransfersCount: 3,
        selectedSection: AppMenuSection.deliveries,

        onAccountTap: () {},
        onTopRankTap: () {},
        onTreasuryTap: () {},
        onDeliveriesTap: () {},
        onStockTransferTap: () {},
        onDirectSaleTap: () {},
        onCustomersTap: () {},
        onAreasTap: () {},
        onReportsTap: () {},
        onContactUsTap: () {},
        onReceiveCustodyTap: () {},
        onLogoutTap: () {},
      ),
    );
  }
}
