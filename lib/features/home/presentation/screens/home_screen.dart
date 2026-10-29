import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_cubit.dart';

import 'package:storeus_delivery/features/home/presentation/widgets/home_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (_) => getIt<HomeCubit>()..getCurrentTrip(),
        ),
        BlocProvider<HomeHistoryCubit>(
          create: (_) => getIt<HomeHistoryCubit>()..getTripHistory(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.grey0,
        body: const SafeArea(child: HomeBody()),
      ),
    );
  }
}
