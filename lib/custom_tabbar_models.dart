import 'dart:ui';

class ScrollTabItem {
  final int dir;
  final double progress;
  final int targetIndex;
  final int currentIndex;
  final Offset currentEndOffset;
  final int totalTabBarLength;
  final Size totalTabBarSize;
  final Size currentItemSize;
  final Size nextItemSize;

  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex == totalTabBarLength - 1;

  const ScrollTabItem.obtain(
    this.dir,
    this.progress,
    this.targetIndex,
    this.currentIndex,
    this.currentEndOffset,
    this.totalTabBarLength,
    this.totalTabBarSize,
    this.currentItemSize,
    this.nextItemSize,
  );
}

class ScrollProgress {
  final int dir;
  final int currentIndex;
  final int targetIndex;
  final double progress;

  const ScrollProgress({
    this.currentIndex = 0,
    this.targetIndex = -1,
    this.progress = 0,
    this.dir = 0,
  });
}

class IndicatorPosition {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  const IndicatorPosition(
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.width,
    this.height,
  );
}
