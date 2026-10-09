import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class LoginFailureWidget extends StatelessWidget {
  const LoginFailureWidget({super.key, required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xfffde6e3),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          error,
          style: Styles.textStyle14.copyWith(color: Color(0xffd32325)),
        ),
      ),
    );
  }
}
