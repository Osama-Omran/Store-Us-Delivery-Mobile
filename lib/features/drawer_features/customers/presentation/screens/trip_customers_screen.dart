import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';

import '../cubit/trip_customers_cubit.dart';
import '../widgets/trip_customers_body.dart';

class TripCustomersScreen extends StatelessWidget {
  const TripCustomersScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => BlocProvider<TripCustomersCubit>(
    create: (_) => getIt<TripCustomersCubit>()..load(),
    child: TripCustomersBody(onBack: onBack),
  );
}
