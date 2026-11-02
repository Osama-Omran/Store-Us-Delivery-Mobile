import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/helpers/utils/force_update_services.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class ForceUpdateScreen extends StatefulWidget {
  const ForceUpdateScreen({super.key});

  @override
  State<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen> {
  bool _isOpeningStore = false;
  bool _storeOpenFailed = false;

  Future<void> _openStore() async {
    setState(() {
      _isOpeningStore = true;
      _storeOpenFailed = false;
    });
    final update = await getIt<ForceUpdateServices>().checkForUpdate();
    final opened = await getIt<ForceUpdateServices>().openStore(
      update.storeUrl,
    );
    if (!mounted) return;
    setState(() {
      _isOpeningStore = false;
      _storeOpenFailed = !opened;
    });
  }

  Future<void> _retryStore() async {
    setState(() {
      _isOpeningStore = true;
      _storeOpenFailed = false;
    });
    final update = await getIt<ForceUpdateServices>().checkForUpdate(
      refreshRemoteConfig: true,
    );
    final opened = await getIt<ForceUpdateServices>().openStore(
      update.storeUrl,
    );
    if (!mounted) return;
    setState(() {
      _isOpeningStore = false;
      _storeOpenFailed = !opened;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white0,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 680;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.width * .07,
                  vertical: isCompact ? 12 : 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        AppAssets.forceUpdate,
                        height: (constraints.maxHeight * .47).clamp(190, 420),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.strings.force_update_title,
                        textAlign: TextAlign.center,
                        style: Styles.textStyle24.copyWith(
                          color: AppColors.black0,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.strings.force_update_description,
                        textAlign: TextAlign.center,
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.grey1,
                          height: 1.65,
                        ),
                      ),
                      if (_storeOpenFailed) ...[
                        const SizedBox(height: 14),
                        Text(
                          context.strings.update_store_unavailable,
                          textAlign: TextAlign.center,
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.red1,
                          ),
                        ),
                        TextButton(
                          onPressed: _isOpeningStore ? null : _retryStore,
                          child: Text(context.strings.update_retry),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 68,
                        child: ElevatedButton(
                          onPressed: _isOpeningStore ? null : _openStore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0d6875),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: _isOpeningStore
                              ? const SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.white0,
                                  ),
                                )
                              : Text(
                                  context.strings.update_now,
                                  style: Styles.textStyle20.copyWith(
                                    color: AppColors.white0,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
