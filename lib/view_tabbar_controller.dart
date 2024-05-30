import 'package:flutter/material.dart';
import 'view_tabbar_models.dart';

typedef ProgressCallback = void Function(
  ScrollProgress info,
);

class ViewTabBarController {
  int _lastIndex = 0;
  int _targetIndex = 1;
  int _currentIndex = 0;
  final double _progress = 0;

  final List<ProgressCallback?> _listeners = [];

  Axis _direction = Axis.horizontal;
  bool _isTargetGoing = false;

  bool get isTargetChanging {
    if (_isTargetGoing) {
      return true;
    }

    if (!_isTargetGoing) {
      final fixed = _progress.toStringAsFixed(3);
      return double.parse(fixed) > 0.001 && _progress < 1;
    }

    return false;
  }

  bool get isTargetGoing => _isTargetGoing;
  int get currentIndex => _currentIndex;
  int get lastIndex => _lastIndex;
  int get targetIndex => _targetIndex;
  Axis get direction => _direction;

  void setDirection(Axis dir) {
    _direction = dir;
  }

  void setLastIndex(int index) {
    _lastIndex = index;
  }

  void setTargetIndex(int index) {
    _targetIndex = index;
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
  }

  void addProgressListener(ProgressCallback? callback) {
    _listeners.add(callback);
  }

  void callProgressListener(ScrollProgress info) {
    for (final listener in _listeners) {
      listener?.call(info);
    }
  }

  void removeProgressListener(int index) {
    if (index >= 0 && index < _listeners.length) {
      _listeners.removeAt(index);
    }
  }

  void endToTargetGoing() {
    _isTargetGoing = false;
  }

  void startToTargetGoing() {
    _isTargetGoing = true;
  }

  void setScrollTabItemToCenter(
    int index,
    List<Size>? sizeList,
    Size tabBarViewCenterSize,
    ScrollController? scrollController,
    Duration? duration,
  ) {
    if (index == _lastIndex) {
      return;
    }

    _targetIndex = index;

    final totalTabBarSize = getTotalTabBarSize(sizeList);
    final targetEndOffset = getTargetEndOffset(sizeList, index);

    final size = sizeList![index];
    final sizeWidth = size.width;
    final sizeHeight = size.height;
    final totalWidth = totalTabBarSize.width;
    final totalHeight = totalTabBarSize.height;
    final tabBarViewCenterWidth = tabBarViewCenterSize.width;
    final tabBarViewCenterHeight = tabBarViewCenterSize.height;

    double animateToOffset = 0;

    if (direction == Axis.horizontal) {
      animateToOffset =
          (targetEndOffset.dx - sizeWidth / 2) - tabBarViewCenterWidth;
    }

    if (direction == Axis.vertical) {
      animateToOffset =
          (targetEndOffset.dy - sizeHeight / 2) - tabBarViewCenterHeight;
    }

    // 处理 start 边界
    if (animateToOffset <= 0) {
      animateToOffset = 0;
    }

    // 处理 end 边界
    if (animateToOffset > 0 && direction == Axis.horizontal) {
      if (totalWidth - tabBarViewCenterWidth * 2 < animateToOffset) {
        totalWidth > tabBarViewCenterWidth * 2
            ? animateToOffset = totalWidth - tabBarViewCenterWidth * 2
            : animateToOffset = 0;
      }
    }

    // 处理 end 边界
    if (animateToOffset > 0 && direction == Axis.vertical) {
      if (totalHeight - tabBarViewCenterHeight * 2 < animateToOffset) {
        totalHeight > tabBarViewCenterHeight * 2
            ? animateToOffset = totalHeight - tabBarViewCenterHeight * 2
            : animateToOffset = 0;
      }
    }

    duration == null
        ? scrollController?.jumpTo(animateToOffset)
        : scrollController?.animateTo(
            animateToOffset,
            duration: duration,
            curve: Curves.easeIn,
          );

    _lastIndex = index;
    _targetIndex = index;
    _currentIndex = index;
  }

  void setScrollTabItemByPageView(
    List<Size>? sizeList,
    Size tabBarViewCenterSize,
    PageController pageController,
    ScrollController? scrollController,
  ) {
    if (scrollController == null) {
      return;
    }

    if (pageController.page != null) {
      setScrollTabItemToCenter(
        pageController.page!.round(),
        sizeList,
        tabBarViewCenterSize,
        scrollController,
        null,
      );
    }
  }

  ScrollTabItem computeScrollTabItem(double page, List<Size> sizeList) {
    final prevIndex = page.toInt();
    final targetIndex = _targetIndex;
    final currentIndex = _currentIndex;
    final currentItemSize = sizeList[prevIndex];
    final sizeLength = sizeList.length;

    final totalTabBarSize = getTotalTabBarSize(sizeList);
    final totalTabBarLength = sizeList.length;

    final nextItemSize = prevIndex < sizeLength - 1
        ? sizeList[prevIndex + 1]
        : const Size(-1, -1);

    return ScrollTabItem.obtain(
      _targetIndex > _currentIndex ? 1 : -1,
      page % 1.0,
      targetIndex,
      currentIndex,
      getTargetEndOffset(sizeList, prevIndex),
      totalTabBarLength,
      totalTabBarSize,
      currentItemSize,
      nextItemSize,
    );
  }

  Offset getTargetStartOffset(List<Size>? sizeList, int index) {
    double width = 0;
    double height = 0;

    if (sizeList != null) {
      for (int i = 0; i < index; i++) {
        width += sizeList[i].width;
        height += sizeList[i].height;
      }
    }

    return Offset(width, height);
  }

  Offset getTargetEndOffset(List<Size>? sizeList, int index) {
    double width = 0;
    double height = 0;

    if (sizeList != null) {
      for (int i = 0; i <= index; i++) {
        width += sizeList[i].width;
        height += sizeList[i].height;
      }
    }

    return Offset(width, height);
  }

  Size getTotalTabBarSize(List<Size>? sizeList) {
    double width = 0;
    double height = 0;

    sizeList?.forEach((item) {
      width += item.width;
      height += item.height;
    });

    return Size(width, height);
  }

  bool isInTarbarVisible(
    index,
    Size tabBarViewSize,
    List<Size>? sizeList,
    ScrollController scrollController,
  ) {
    final pixels = scrollController.position.pixels;
    final startStartOffset = getTargetStartOffset(sizeList, index);
    final startEndOffset = getTargetEndOffset(sizeList, index);
    final tabBarViewWidth = tabBarViewSize.width;
    final tabBarViewHeight = tabBarViewSize.height;
    final offsetStartX = startStartOffset.dx;
    final offsetStartY = startStartOffset.dy;
    final offsetEndX = startEndOffset.dy;
    final offsetEndY = startEndOffset.dy;

    // offsetEnd == pixels, -> tab end is tabBarView start boundary
    // offsetStart == pixels + tabBarViewWidth, -> tab start is tabBarView end boundary
    return direction == Axis.horizontal
        ? offsetEndX > pixels && offsetStartX < pixels + tabBarViewWidth
        : offsetEndY > pixels && offsetStartY < pixels + tabBarViewHeight;
  }
}
