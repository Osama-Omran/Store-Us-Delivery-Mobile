import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/layout_content.dart';

class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ======= Current User ======= //
        BlocProvider<AccountCubit>(
          create: (_) => getIt<AccountCubit>()..getMe(),
        ),

        // ======= Notifications ======= //
        BlocProvider<NotificationsCubit>(
          create: (_) => getIt<NotificationsCubit>()..getNotifications(),
        ),

        // ======= Current Trip ======= //
        BlocProvider<TripTabCubit>(
          lazy: false,
          create: (_) => getIt<TripTabCubit>()..getCurrentTrip(),
        ),

        // ======= Stock Transfers ======= //
        BlocProvider<StockTransferCubit>(
          lazy: false,
          create: (_) => getIt<StockTransferCubit>()..load(),
        ),
      ],
      child: const LayoutContent(),
    );
  }
}
