import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';

import '../cubit/top_rank_cubit.dart';
import '../widgets/top_rank_body.dart';

class TopRankScreen extends StatelessWidget {
  const TopRankScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<TopRankCubit>()..load(fetchAllCategories: true),
    child: TopRankBody(onBack: onBack),
  );
}
