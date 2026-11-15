import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:piligrim_design/piligrim_design.dart';

import 'still_companion_controller.dart';

/// The companion inside the day ring.
///
/// [journeyProgress] (0 to 1) fills the ring. The companion itself is driven
/// only through [controller]. When the Rive file exists, the body of this
/// widget changes to the Rive runtime and no screen needs to change.
class CompanionView extends StatelessWidget {
  const CompanionView({
    super.key,
    required this.controller,
    required this.journeyProgress,
    this.size = PgSizes.dayRing,
  });

  final StillCompanionController controller;
  final double journeyProgress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Decorative for screen readers, as the motion spec asks.
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: journeyProgress.clamp(0, 1).toDouble(),
              strokeWidth: PgSizes.dayRingStroke,
              strokeCap: StrokeCap.round,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
            Padding(
              padding: const EdgeInsets.all(
                PgSizes.dayRingStroke + PgSpacing.xxs,
              ),
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => SvgPicture.asset(
                  controller.pose.asset,
                  key: ValueKey(controller.pose),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
