import 'package:flutter/material.dart';
import 'view_tabbar_models.dart';

abstract class TabBarTransform {
  TabBarTransform? transform;
  TransformBuilder? builder;

  TabBarTransform({
    this.transform,
    this.builder,
  });

  void calculate(int index, ScrollProgress info);

  Widget build(BuildContext context, int index, ScrollProgress info);
}

typedef TransformBuilder = Widget Function(
  BuildContext context,
  dynamic value,
);

class ScaleTransform extends TabBarTransform {
  ScaleTransform({
    super.transform,
    super.builder,
    this.maxScale = 1.2,
  });

  double maxScale = 1.2;
  double scale = 0;

  @override
  Widget build(BuildContext context, int index, ScrollProgress info) {
    calculate(index, info);

    return Transform.scale(
      scale: 1 + ((maxScale - 1) * scale),
      child: builder == null
          ? transform!.build(context, index, info)
          : builder!(context, scale),
    );
  }

  @override
  void calculate(int index, ScrollProgress info) {
    if (info.dir == -1 && info.targetIndex == index) {
      scale = 1 - info.progress;
      return;
    }

    if (info.dir == -1 && info.currentIndex == index) {
      scale = info.progress;
      return;
    }

    if (info.dir == 1 && info.targetIndex == index) {
      scale = info.progress;
      return;
    }

    if (info.dir == 1 && info.currentIndex == index) {
      scale = 1.0 - info.progress;
      return;
    }

    scale = 0;
  }
}

class ColorsTransform extends TabBarTransform {
  Color normalColor;
  Color highlightColor;
  Color? transformColor;

  ColorsTransform({
    super.transform,
    super.builder,
    required this.normalColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context, int index, ScrollProgress info) {
    calculate(index, info);

    return builder != null
        ? builder!(context, transformColor)
        : transform!.build(context, index, info);
  }

  @override
  void calculate(int index, ScrollProgress info) {
    if (info.dir == 0) {
      transformColor = index == info.targetIndex ? highlightColor : normalColor;
      return;
    }

    int alphaValueOffset = highlightColor.alpha - normalColor.alpha;
    int greenValueOffset = highlightColor.green - normalColor.green;
    int blueValueOffset = highlightColor.blue - normalColor.blue;
    int redValueOffset = highlightColor.red - normalColor.red;

    double changeAlpha = alphaValueOffset * info.progress;
    double changeBlue = blueValueOffset * info.progress;
    double changeGreen = greenValueOffset * info.progress;
    double changeRed = redValueOffset * info.progress;

    if (info.dir == -1) {
      changeAlpha = alphaValueOffset * (1 - info.progress);
      changeBlue = blueValueOffset * (1 - info.progress);
      changeGreen = greenValueOffset * (1 - info.progress);
      changeRed = redValueOffset * (1 - info.progress);
    }

    if (info.targetIndex == index) {
      transformColor = normalColor
          .withAlpha(normalColor.alpha + changeAlpha.toInt())
          .withBlue(normalColor.blue + changeBlue.toInt())
          .withGreen(normalColor.green + changeGreen.toInt())
          .withRed(normalColor.red + changeRed.toInt());

      return;
    }

    if (info.currentIndex == index) {
      transformColor = highlightColor
          .withAlpha(highlightColor.alpha - changeAlpha.toInt())
          .withBlue(highlightColor.blue - changeBlue.toInt())
          .withGreen(highlightColor.green - changeGreen.toInt())
          .withRed(highlightColor.red - changeRed.toInt());

      return;
    }

    transformColor = normalColor;
    return;
  }
}
