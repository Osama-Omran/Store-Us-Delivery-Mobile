import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';

import '../cubit/contact_cubit.dart';
import '../widgets/contact_body.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key, this.tripId});

  // Pass a genuine trip ID only when opened for a specific trip.
  final int? tripId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ContactCubit>()..load(),
    child: ContactBody(tripId: tripId),
  );
}
