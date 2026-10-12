import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/domain/usecases/get_top_rank_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/cubit/top_rank_details_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_avatar.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_metrics.dart';

Future<void> showTopRankDetails(
  BuildContext context,
  TopRankEntry entry, {
  required TopRankRole role,
  required TopRankPeriod period,
  TopRankEntry? leader,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.white0,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .9,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => TopRankDetailsCubit(getIt<GetTopRankUsecase>(), entry)
        ..load(
          range: period.apiValue,
          category: role.apiValue,
          entity: entry.id,
        ),
      child: _TopRankDetailsContent(role: role, leader: leader),
    ),
  );
}

class _TopRankDetailsContent extends StatelessWidget {
  const _TopRankDetailsContent({required this.role, required this.leader});

  final TopRankRole role;
  final TopRankEntry? leader;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopRankDetailsCubit, TopRankDetailsState>(
      builder: (context, state) {
        final entry = state.entry;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  // ======= Header ======= //
                  Row(
                    children: [
                      TopRankAvatar(entry: entry, role: role, size: 68),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.name,
                          style: Styles.textStyle22.copyWith(
                            color: AppColors.black1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          label: 'الترتيب الحالي',
                          value: entry.rank == null ? '—' : '#${entry.rank}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryTile(
                          label: 'التقييم',
                          value: '${formatRankNumber(entry.score)} / 100',
                        ),
                      ),
                    ],
                  ),

                  if (entry.provisional)
                    _InfoBanner(
                      text: 'هذا تقييم مبدئي بسبب نقص بعض بيانات الأداء.',
                    ),

                  if (state.loading)
                    LinearProgressIndicator(color: AppColors.primary),

                  if (state.error != null)
                    _InfoBanner(
                      text: 'تعذر تحديث التفاصيل. يتم عرض بيانات الترتيب المحمّلة.',
                    ),

                  // ======= Breakdown ======= //
                  Text(
                    'تفصيل النقاط',
                    style: Styles.textStyle20.copyWith(color: AppColors.black1),
                  ),

                  for (final metric in entry.metrics)
                    _MetricProgress(metric: metric),

                  Divider(color: AppColors.grey3),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'الإجمالي',
                          style: Styles.textStyle18.copyWith(
                            color: AppColors.black1,
                          ),
                        ),
                      ),
                      Text(
                        '${formatRankNumber(entry.score)} / 100',
                        textDirection: TextDirection.ltr,
                        style: Styles.textStyle18.copyWith(
                          color: AppColors.black1,
                        ),
                      ),
                    ],
                  ),

                  // ======= Strengths ======= //
                  if (entry.advice.strengths.isNotEmpty) ...[
                    Text(
                      'عمل إيه علشان وصل كده؟',
                      style: Styles.textStyle18.copyWith(
                        color: AppColors.black1,
                      ),
                    ),
                    for (final strength in entry.advice.strengths)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppColors.green0,
                            size: 21,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              strength,
                              style: Styles.textStyle16.copyWith(
                                color: AppColors.black1,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],

                  // ======= Improvement Advice ======= //
                  if (entry.advice.actions.isNotEmpty) ...[
                    Text(
                      'إعمل إيه علشان تحسن ترتيبك؟',
                      style: Styles.textStyle18.copyWith(
                        color: AppColors.black1,
                      ),
                    ),
                    for (final action in entry.advice.actions)
                      _AdviceCard(action: action),
                  ],

                  // ======= Compare With Leader ======= //
                  if (leader != null &&
                      leader!.id != entry.id &&
                      leader!.score != null &&
                      entry.score != null &&
                      entry.gap != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.blue4,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 10,
                        children: [
                          Text(
                            'المقارنة مع الأول',
                            style: Styles.textStyle18.copyWith(
                              color: AppColors.black1,
                            ),
                          ),
                          _CompareRow(
                            label: 'درجتك',
                            value: formatRankNumber(entry.score),
                          ),
                          _CompareRow(
                            label: 'درجة الأول',
                            value: formatRankNumber(leader!.score),
                          ),
                          _CompareRow(
                            label: 'الفرق',
                            value: formatRankNumber(entry.gap),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey5,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        spacing: 8,
        children: [
          Text(
            label,
            style: Styles.textStyle12.copyWith(color: AppColors.grey4),
          ),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: Styles.textStyle20.copyWith(color: AppColors.black1),
          ),
        ],
      ),
    );
  }
}

class _MetricProgress extends StatelessWidget {
  const _MetricProgress({required this.metric});

  final TopRankMetric metric;

  @override
  Widget build(BuildContext context) {
    final available = metric.hasCalculatedPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                metric.label,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              available
                  ? '${formatRankNumber(metric.points)} / ${formatRankNumber(metric.weight)}'
                  : 'غير متاح',
              textDirection: TextDirection.ltr,
              style: Styles.textStyle14.copyWith(
                color: available ? AppColors.black1 : AppColors.grey4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: LinearProgressIndicator(
            value: available ? metric.progress : 0,
            minHeight: 10,
            backgroundColor: AppColors.grey5,
            valueColor: AlwaysStoppedAnimation(
              available ? AppColors.primary : AppColors.grey3,
            ),
          ),
        ),

        if (metric.value != null || metric.target != null)
          Text(
            'الحالي: ${formatRankMetric(metric)}'
            '   |   الهدف: '
            '${metric.target == null ? 'غير متاح' : formatRankNumber(metric.target)}',
            style: Styles.textStyle12.copyWith(color: AppColors.grey4),
          ),
      ],
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.action});

  final TopRankAdviceAction action;

  @override
  Widget build(BuildContext context) {
    final isDataIssue = action.priority == 'data';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 9,
        children: [
          Row(
            children: [
              Icon(
                isDataIssue
                    ? Icons.info_outline_rounded
                    : Icons.trending_up_rounded,
                color: isDataIssue ? AppColors.orange0 : AppColors.green0,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isDataIssue ? 'بيانات غير كافية' : 'فرصة للتحسين',
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (action.impact != null)
                Text(
                  '+${formatRankNumber(action.impact)} نقطة',
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.green0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          Text(
            action.message,
            style: Styles.textStyle14.copyWith(color: AppColors.black1),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.orange1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Styles.textStyle12.copyWith(color: AppColors.orange0),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: Styles.textStyle16.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}
