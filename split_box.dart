import 'package:flutter/material.dart';

class SplitBox extends StatelessWidget {
  const SplitBox({
    super.key,
    required this.splitHorizontal,
    required this.id,
    required this.randomColors,
    required this.baseColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.splitIds,
    required this.onSplit,
  });

  final bool splitHorizontal;
  final int id;
  final bool randomColors;
  final Color baseColor;
  final double borderWidth;
  final double borderRadius;
  final Set<int> splitIds;
  final ValueChanged<int> onSplit;

  Color get _color {
    if (randomColors) {
      final hue = (id * 71 + 40) % 360;
      return HSLColor.fromAHSL(1, hue.toDouble(), .65, .48).toColor();
    }
    final hsl = HSLColor.fromColor(baseColor);
    final lightness = 0.28 + ((id * 37) % 48) / 100;
    return hsl.withLightness(lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    if (!splitIds.contains(id)) {
      return GestureDetector(
        onTap: () => onSplit(id),
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: _color,
            border: Border.all(color: Colors.black87, width: borderWidth),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      );
    }

    final child1 = SplitBox(
      splitHorizontal: !splitHorizontal,
      id: id * 2 + 1,
      randomColors: randomColors,
      baseColor: baseColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      splitIds: splitIds,
      onSplit: onSplit,
    );
    final child2 = SplitBox(
      splitHorizontal: !splitHorizontal,
      id: id * 2 + 2,
      randomColors: randomColors,
      baseColor: baseColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      splitIds: splitIds,
      onSplit: onSplit,
    );

    if (splitHorizontal) {
      return Row(
        children: [
          Expanded(child: child1),
          Expanded(child: child2),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(child: child1),
          Expanded(child: child2),
        ],
      );
    }
  }
}
