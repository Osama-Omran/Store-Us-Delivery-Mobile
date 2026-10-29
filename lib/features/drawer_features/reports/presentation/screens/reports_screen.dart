import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';

import '../cubit/reports_cubit.dart';
import '../widgets/reports_body.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ReportsCubit>()..load(),
    child: const ReportsBody(),
  );
}
