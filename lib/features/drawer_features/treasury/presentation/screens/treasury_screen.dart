import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';

import '../cubit/treasury_cubit.dart';
import '../widgets/treasury_body.dart';

class TreasuryScreen extends StatelessWidget {
  const TreasuryScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<TreasuryCubit>()..loadWallet(),
    child: const TreasuryBody(),
  );
}
