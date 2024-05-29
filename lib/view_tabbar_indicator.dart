import 'dart:math';
import 'package:flutter/material.dart';
import 'view_tabbar_controller.dart';
import 'view_tabbar_models.dart';

abstract class CustomIndicator {
  late ViewTabBarController controller;
  double? top;
  double? left;
  double? right;
  double? bottom;
  double? width;
  double? height;
  BorderRadius? radius;
  Color? color;

  CustomIndicator({
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.color,
    this.radius,
  });

  void updateScrollIndicator(
    double? page,
    List<Size>? sizeList,
    ValueNotifier<ScrollProgress> scroller,
    ValueNotifier<IndicatorPosition> notifier,
  );

  void indicatorScrollToIndex(
    int index,
    List<Size>? sizeList,
    ValueNotifier<ScrollProgress> scroller,
    ValueNotifier<IndicatorPosition> notifier,
  );
}

class StandardIndicator extends CustomIndicator {
  StandardIndicator({
    super.top,
    super.left,
    super.right,
    super.bottom,
    super.width,
    super.height,
    super.radius,
    super.color,
  });

  @override
  void updateScrollIndicator(
    double? page,
    List<Size>? sizeList,
    ValueNotifier<ScrollProgress> scroller,
    ValueNotifier<IndicatorPosition> notifier,
  ) {
    ScrollTabItem info = controller.computeScrollTabItem(page!, sizeList!);
    Size size = info.nextItemSize;
    bool isLast = info.isLast;

    if (size.width == -1 && size.height == -1 && !isLast) {
      return;
    }

    double totalTabbarWidth = info.totalTabBarSize.width;
    double tabBarViewHeight = info.totalTabBarSize.height;

    // currentOffsetX/Y -> end of itemSize
    double currentOffsetX = info.currentEndOffset.dx;
    double currentOffsetY = info.currentEndOffset.dy;
    double currentHeight = info.currentItemSize.height;
    double currentWidth = info.currentItemSize.width;
    double currentIndicatorHeight = currentHeight;
    double currentIndicatorWidth = currentWidth;

    double nextHeight = info.nextItemSize.height;
    double nextWidth = info.nextItemSize.width;
    double nextIndicatorHeight = nextHeight;
    double nextIndicatorWidth = nextWidth;

    double indicatorHeight = currentHeight;
    double indicatorWidth = currentWidth;

    if (width != null) {
      // when width < 0, set relative value
      nextIndicatorWidth = min(
        min(
          nextWidth + width!,
          nextWidth,
        ),
        width! <= 0 ? double.infinity : width!,
      );

      currentIndicatorWidth = min(
        min(
          currentWidth + width!,
          currentWidth,
        ),
        width! <= 0 ? double.infinity : width!,
      );
    }

    if (height != null) {
      // when height < 0, set relative value
      nextIndicatorHeight = min(
        min(
          nextHeight + height!,
          nextHeight,
        ),
        height! <= 0 ? double.infinity : height!,
      );

      currentIndicatorHeight = min(
        min(
          currentHeight + height!,
          currentHeight,
        ),
        height! <= 0 ? double.infinity : height!,
      );
    }

    if (nextIndicatorWidth < 0) nextIndicatorWidth = 0;
    if (nextIndicatorHeight < 0) nextIndicatorHeight = 0;
    if (currentIndicatorWidth < 0) currentIndicatorWidth = 0;
    if (currentIndicatorHeight < 0) currentIndicatorHeight = 0;

    indicatorWidth = currentIndicatorWidth;
    indicatorHeight = currentIndicatorHeight;

    if (controller.direction == Axis.horizontal) {
      if (info.progress <= 0.5) {
        final ratio = info.progress;
        final total1 = currentWidth + nextWidth;
        final total2 = currentIndicatorWidth + nextIndicatorWidth;

        indicatorWidth = 2 * currentIndicatorWidth * (0.5 - ratio) +
            ratio * (total1 + total2);
      }

      if (info.progress > 0.5) {
        final ratio = info.progress;
        final total1 = currentWidth + nextWidth;
        final total2 = currentIndicatorWidth + nextIndicatorWidth;

        indicatorWidth = 2 * nextIndicatorWidth * (ratio - 0.5) +
            (1 - ratio) * (total1 + total2);
      }

      final hNextWidth = nextWidth * 0.5;
      final hCurrentWidth = currentWidth * 0.5;
      final hCurrentIndicatorWidth = currentIndicatorWidth * 0.5;
      final hNextIndicatorWidth = nextIndicatorWidth * 0.5;

      if (info.progress <= 0.5) {
        left = currentOffsetX - hCurrentWidth - hCurrentIndicatorWidth;
        right = totalTabbarWidth - left! - indicatorWidth;
      }

      if (info.progress > 0.5) {
        right = totalTabbarWidth -
            currentOffsetX -
            hNextWidth -
            hNextIndicatorWidth;
        left = totalTabbarWidth - right! - indicatorWidth;
      }
    }

    if (controller.direction == Axis.vertical) {
      if (info.progress <= 0.5) {
        final ratio = info.progress;
        final total1 = currentHeight + nextHeight;
        final total2 = currentIndicatorHeight + nextIndicatorHeight;

        indicatorHeight = 2 * currentIndicatorHeight * (0.5 - ratio) +
            ratio * (total1 + total2);
      }

      if (info.progress > 0.5) {
        final ratio = info.progress;
        final total1 = currentHeight + nextHeight;
        final total2 = currentIndicatorHeight + nextIndicatorHeight;

        indicatorHeight = 2 * nextIndicatorHeight * (ratio - 0.5) +
            (1 - ratio) * (total1 + total2);
      }

      final hNextHeight = nextHeight * 0.5;
      final hCurrentHeight = currentHeight * 0.5;
      final hCurrentIndicatorHeight = currentIndicatorHeight * 0.5;
      final hNextIndicatorHeight = nextIndicatorHeight * 0.5;

      if (info.progress <= 0.5) {
        top = currentOffsetY - hCurrentHeight - hCurrentIndicatorHeight;
        bottom = tabBarViewHeight - top! - indicatorHeight;
      }

      if (info.progress > 0.5) {
        bottom = tabBarViewHeight -
            currentOffsetY -
            hNextHeight -
            hNextIndicatorHeight;
        top = tabBarViewHeight - bottom! - indicatorHeight;
      }
    }

    notifier.value = IndicatorPosition(
      top,
      left,
      right,
      bottom,
      indicatorWidth,
      indicatorHeight,
    );

    controller.callProgressListener(
      ScrollProgress(
        currentIndex: scroller.value.currentIndex,
        targetIndex: scroller.value.targetIndex,
        progress: scroller.value.progress,
        dir: scroller.value.dir,
      ),
    );
  }

  @override
  void indicatorScrollToIndex(
    int index,
    List<Size>? sizeList,
    ValueNotifier<ScrollProgress> scroller,
    ValueNotifier<IndicatorPosition> notifier,
  ) {
    final itemSize = sizeList![index];
    final totalTabBarSize = controller.getTotalTabBarSize(sizeList);
    final targetEndOffset = controller.getTargetEndOffset(sizeList, index);
    double totalTabBarHeight = totalTabBarSize.height;
    double totalTabBarWidth = totalTabBarSize.width;
    double sizeHeight = itemSize.height;
    double sizeWidth = itemSize.width;

    double indicatorWidth = sizeWidth;
    double indicatorHeight = sizeHeight;

    if (width != null) {
      indicatorWidth = min(
        min(
          sizeWidth + width!,
          sizeWidth,
        ),
        width! <= 0 ? double.infinity : width!,
      );
    }

    if (height != null) {
      indicatorHeight = min(
        min(
          sizeHeight + height!,
          sizeHeight,
        ),
        height! <= 0 ? double.infinity : height!,
      );
    }

    if (indicatorWidth < 0) {
      indicatorWidth = 0;
    }

    if (indicatorHeight < 0) {
      indicatorHeight = 0;
    }

    if (controller.direction == Axis.horizontal) {
      final dir = scroller.value.dir;
      final progress = scroller.value.progress;
      final targetIndex = scroller.value.targetIndex;
      final currentIndex = scroller.value.currentIndex;

      double old = notifier.value.left ?? 0;
      double dist = targetEndOffset.dx - (sizeWidth + indicatorWidth) / 2;
      double left = old + (dist - old) * (dir == 1 ? progress : 1 - progress);
      double right = totalTabBarWidth - left - indicatorWidth;

      notifier.value = IndicatorPosition(
        top,
        left,
        right,
        bottom,
        indicatorWidth,
        indicatorHeight,
      );

      controller.callProgressListener(
        ScrollProgress(
          currentIndex: currentIndex,
          targetIndex: targetIndex,
          progress: progress,
          dir: dir,
        ),
      );
    }

    if (controller.direction == Axis.vertical) {
      final dir = scroller.value.dir;
      final progress = scroller.value.progress;
      final targetIndex = scroller.value.targetIndex;
      final currentIndex = scroller.value.currentIndex;

      double old = notifier.value.top ?? 0;
      double dist = targetEndOffset.dy - (sizeHeight + indicatorHeight) / 2;
      double top = old + (dist - old) * (dir == 1 ? progress : 1 - progress);
      double bottom = totalTabBarHeight - top - indicatorHeight;

      notifier.value = IndicatorPosition(
        top,
        left,
        right,
        bottom,
        indicatorWidth,
        indicatorHeight,
      );

      controller.callProgressListener(
        ScrollProgress(
          currentIndex: currentIndex,
          targetIndex: targetIndex,
          progress: progress,
          dir: dir,
        ),
      );
    }
  }
}
