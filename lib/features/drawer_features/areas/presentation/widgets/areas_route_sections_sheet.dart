import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/trip_map/services/route_navigation_launcher.dart';

class AreasRouteSectionsSheet extends StatelessWidget {
  const AreasRouteSectionsSheet({super.key, required this.sections});

  final List<TripRouteSection> sections;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.strings.areas_route_sections,
              style: Styles.textStyle19.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              context.strings.areas_route_sections_description,
              style: Styles.textStyle13.copyWith(color: AppColors.grey4),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sections.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(
                    Icons.route_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    context.strings.areas_route_section(
                      index + 1,
                      sections.length,
                    ),
                  ),
                  subtitle: Text(
                    context.strings.areas_route_section_stops(
                      sections[index].firstStop,
                      sections[index].lastStop,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(sections[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
