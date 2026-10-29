import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/delivery_outcome_cubit.dart';
import '../cubit/delivery_outcome_state.dart';

class DeliveryOutcomeBackGuard extends StatelessWidget {
  const DeliveryOutcomeBackGuard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      BlocSelector<DeliveryOutcomeCubit, DeliveryOutcomeState, bool>(
        selector: (state) => state is DeliveryOutcomeLoading,
        builder: (context, loading) => PopScope(canPop: !loading, child: child),
      );
}
