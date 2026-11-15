import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/content/content_pack.dart';

import 'package:piligrim_design/piligrim_design.dart';

import '../../core/widgets/async_body.dart';

class PrayerDetailScreen extends ConsumerWidget {
  const PrayerDetailScreen({super.key, required this.prayerId});

  final String prayerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(journeyOverviewProvider);
    final prayer = PrayerDefinition(id: prayerId);
    return Scaffold(
      appBar: AppBar(
        title: Text(overview.value?.strings.text(prayer.titleKey) ?? ''),
      ),
      body: AsyncBody<JourneyOverview>(
        value: overview,
        builder: (context, data) {
          final lines = data.strings.lines(prayer.linesKey);
          return ListView.separated(
            padding: const EdgeInsets.all(PgSpacing.md),
            itemCount: lines.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: PgSpacing.md),
            itemBuilder: (context, index) => Text(
              lines[index],
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        },
      ),
    );
  }
}
