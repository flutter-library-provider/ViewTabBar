import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'view_tabbar_controller.dart';
import 'view_tabbar_indicator.dart';
import 'view_tabbar_transform.dart';
import 'view_tabbar_models.dart';

export 'view_tabbar_controller.dart';
export 'view_tabbar_transform.dart';
export 'view_tabbar_indicator.dart';

typedef IndexedTabBarItemBuilder = Widget Function(
  BuildContext context,
  int index,
);

class _ViewTabBarContext extends InheritedWidget {
  _ViewTabBarContext({required super.child});

  final ValueNotifier<ScrollProgress> progressNotifier = ValueNotifier(
    const ScrollProgress(),
  );

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static _ViewTabBarContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ViewTabBarContext>(
      aspect: _ViewTabBarContext,
    );
  }
}

class ViewTabBar extends StatelessWidget {
  const ViewTabBar({
    super.key,
    required this.builder,
    required this.itemCount,
    required this.pageController,
    this.tabBarController,
    this.direction = Axis.horizontal,
    this.onTapItem,
    this.indicator,
    this.width,
    this.height,
    this.pinned = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.controllerToScroll = true,
    this.controllerToJump = true,
  });

  final int itemCount;
  final Duration animationDuration;
  final IndexedTabBarItemBuilder builder;
  final ViewTabBarController? tabBarController;
  final PageController pageController;
  final CustomIndicator? indicator;
  final ValueChanged<int>? onTapItem;
  final double? width;
  final double? height;
  final bool pinned;
  final bool controllerToJump;
  final bool controllerToScroll;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return _ViewTabBarContext(
      child: _ViewTabBar(
        builder: builder,
        itemCount: itemCount,
        animationDuration: animationDuration,
        tabBarController: tabBarController,
        pageController: pageController,
        indicator: indicator,
        onTapItem: onTapItem,
        width: width,
        height: height,
        pinned: pinned,
        controllerToJump: controllerToJump,
        controllerToScroll: controllerToScroll,
        direction: direction,
      ),
    );
  }
}

class _ViewTabBar extends StatefulWidget {
  const _ViewTabBar({
    required this.builder,
    required this.itemCount,
    required this.pageController,
    required this.animationDuration,
    this.tabBarController,
    this.direction = Axis.horizontal,
    this.onTapItem,
    this.indicator,
    this.width,
    this.height,
    this.pinned = false,
    this.controllerToJump = true,
    this.controllerToScroll = true,
  });

  final int itemCount;
  final Duration animationDuration;
  final IndexedTabBarItemBuilder builder;
  final ViewTabBarController? tabBarController;
  final PageController pageController;
  final CustomIndicator? indicator;
  final ValueChanged<int>? onTapItem;
  final double? width;
  final double? height;
  final bool pinned;
  final bool controllerToJump;
  final bool controllerToScroll;
  final Axis direction;

  @override
  _ViewTabBarState createState() => _ViewTabBarState();
}

class _ViewTabBarState extends State<_ViewTabBar>
    with TickerProviderStateMixin {
  AnimationController? _progressController;
  ScrollController? _scrollController;

  late ViewTabBarController _tabBarController = ViewTabBarController();

  late ValueNotifier<IndicatorPosition> positionNotifier = ValueNotifier(
    const IndicatorPosition(
      null,
      null,
      null,
      null,
      null,
      null,
    ),
  );

  late final tabBarContext = _ViewTabBarContext.of(context)!;
  late final progressNotifier = tabBarContext.progressNotifier;

  late final sizeList = List.generate(
    widget.itemCount,
    (index) => const Size(0, 0),
  );

  double? indicatorTop;
  double? indicatorLeft;
  double? indicatorRight;
  double? indicatorBottom;
  double? indicatorWidth;
  double? indicatorHeight;
  double get getCurrentPage => widget.pageController.page ?? 0;
  int get initialPage => widget.pageController.initialPage;

  late Size _viewportSize = const Size(-1, -1);
  late int _currentIndex = initialPage;
  late int _targetIndex = initialPage;
  late int _lastIndex = initialPage;
  late bool _locked = false;

  @override
  void didUpdateWidget(covariant _ViewTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    _tabBarController.setDirection(widget.direction);
    widget.indicator?.controller = _tabBarController;
  }

  @override
  void initState() {
    super.initState();

    if (!widget.pinned) {
      _scrollController = ScrollController();
    }

    if (widget.tabBarController != null) {
      _tabBarController = widget.tabBarController!;
    }

    widget.indicator?.controller = _tabBarController;
    _tabBarController.setDirection(widget.direction);
    _tabBarController.setCurrentIndex(_currentIndex);
    _tabBarController.setTargetIndex(_targetIndex);
    _tabBarController.setLastIndex(_lastIndex);

    widget.pageController.addListener(() {
      if (_locked) {
        return;
      }

      // fix bug: call onTap when page scrolling
      // if (_lastIndex == getCurrentPage) {
      //   return;
      // }

      // fix bug: call onTap when page scrolling
      // if (_currentIndex == getCurrentPage) {
      //   return;
      // }

      if (_tabBarController.isTargetGoing) {
        return;
      }

      final dir = widget.pageController.page! > _lastIndex ? 1 : -1;
      final page = widget.pageController.page! % 1.0;
      final offset = dir == 1 ? 1 - page : page;
      final fixed = offset.toStringAsFixed(3);
      final value = double.parse(fixed);
      double progress = 0;

      progress = dir == 1 ? (value > 0.001 ? page : 1.0) : progress;
      progress = dir == -1 ? (value > 0.001 ? page : 0.0) : progress;
      progress = dir == 1 ? (progress != 0.0 ? progress : 1.0) : progress;
      progress = dir == -1 ? (progress != 1.0 ? progress : 0.0) : progress;

      _targetIndex = dir == 1 ? getCurrentPage.ceil() : getCurrentPage.floor();
      _currentIndex = dir == 1 ? getCurrentPage.floor() : getCurrentPage.ceil();

      progressNotifier.value = ScrollProgress(
        dir: dir,
        progress: progress,
        targetIndex: _targetIndex,
        currentIndex: _currentIndex,
      );

      // remove: _currentIndex != _targetIndex (Using by pageController.jumpToPage)
      if (widget.controllerToScroll) {
        _tabBarController.setLastIndex(_lastIndex);
        _tabBarController.setTargetIndex(_targetIndex);
        _tabBarController.setCurrentIndex(_currentIndex);

        _tabBarController.setScrollTabItemByPageView(
          sizeList,
          _viewportSize / 2,
          widget.pageController,
          _scrollController,
        );

        widget.indicator?.updateScrollIndicator(
          getCurrentPage,
          sizeList,
          progressNotifier,
          positionNotifier,
        );
      }

      if (dir == -1 && progress == 0) {
        _locked = true;
        _lastIndex = _targetIndex;
        _currentIndex = _targetIndex;
        _tabBarController.setLastIndex(_targetIndex);
        _tabBarController.setTargetIndex(_targetIndex);
        _tabBarController.setCurrentIndex(_targetIndex);

        Future.delayed(const Duration(milliseconds: 5), () {
          _locked = false;
        });
      }

      if (dir == 1 && progress == 1) {
        _locked = true;
        _lastIndex = _targetIndex;
        _currentIndex = _targetIndex;
        _tabBarController.setLastIndex(_targetIndex);
        _tabBarController.setTargetIndex(_targetIndex);
        _tabBarController.setCurrentIndex(_targetIndex);

        Future.delayed(const Duration(milliseconds: 5), () {
          _locked = false;
        });
      }
    });

    positionNotifier.addListener(() {
      setState(() {
        final indicator = widget.indicator;
        final positionValue = positionNotifier.value;

        if (widget.direction == Axis.horizontal) {
          if (indicator?.top != null) {
            indicatorTop = positionValue.top! + (indicator?.top ?? 0);
          }

          if (indicator?.bottom != null) {
            indicatorBottom = positionValue.bottom! + (indicator?.bottom ?? 0);
          }

          indicatorLeft = positionValue.left;
          indicatorRight = positionValue.right;
          indicatorWidth = positionValue.width;
          indicatorHeight = positionValue.height;
        }

        if (widget.direction == Axis.vertical) {
          if (indicator?.left != null) {
            indicatorLeft = positionValue.left! + (indicator?.left ?? 0);
          }

          if (indicator?.right != null) {
            indicatorRight = positionValue.right! + (indicator?.right ?? 0);
          }

          indicatorTop = positionValue.top;
          indicatorBottom = positionValue.bottom;
          indicatorWidth = positionValue.width;
          indicatorHeight = positionValue.height;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _progressController?.stop(canceled: true);
  }

  @override
  Widget build(BuildContext context) {
    late Widget child;

    if (widget.pinned && widget.direction == Axis.horizontal) {
      if (widget.width != null) {
        _viewportSize = Size(
          widget.width!,
          _viewportSize.height,
        );
      }
      child = _buildTabBarItemList();
    }

    if (widget.pinned && widget.direction == Axis.vertical) {
      if (widget.height != null) {
        _viewportSize = Size(
          _viewportSize.width,
          widget.height!,
        );
      }
      child = _buildTabBarItemList();
    }

    if (!widget.pinned) {
      child = Scrollable(
        controller: _scrollController,
        viewportBuilder: (context, offset) {
          return Viewport(
            axisDirection: widget.direction == Axis.horizontal
                ? AxisDirection.right
                : AxisDirection.down,
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate([
                  _buildTabBarItemList(),
                ]),
              )
            ],
            offset: offset,
          );
        },
        axisDirection: widget.direction == Axis.horizontal
            ? AxisDirection.right
            : AxisDirection.down,
        physics: widget.pinned
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
      );
    }

    return _MeasureTabItemSizeBox(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: child,
      ),
      onSizeCallback: (size) {
        if (_viewportSize != size) {
          _viewportSize = Size.copy(size);
        }
      },
    );
  }

  Widget _buildTabBarItemList() {
    final List<Widget> children = [];

    final physics = widget.pinned
        ? const NeverScrollableScrollPhysics()
        : const BouncingScrollPhysics();

    double? viewPortWidth = widget.pinned
        ? (_viewportSize.width == -1 ? null : _viewportSize.width)
        : null;

    double? viewPortHeight = widget.pinned
        ? (_viewportSize.height == -1 ? null : _viewportSize.height)
        : null;

    children.add(
      LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          viewPortWidth = viewPortWidth ?? width;
          viewPortHeight = viewPortHeight ?? height;

          return _ViewTabBarItemList(
            physics: physics,
            sizeList: sizeList,
            builder: widget.builder,
            direction: widget.direction,
            itemCount: widget.itemCount,
            viewPortWidth: viewPortWidth,
            viewPortHeight: viewPortHeight,
            onMeasureCompleted: () {
              WidgetsBinding.instance.addPostFrameCallback((d) {
                setState(() {
                  progressNotifier.value = ScrollProgress(
                    currentIndex: _currentIndex,
                    targetIndex: _targetIndex,
                    progress: 0,
                    dir: 0,
                  );

                  widget.indicator?.updateScrollIndicator(
                    getCurrentPage,
                    sizeList,
                    progressNotifier,
                    positionNotifier,
                  );

                  _tabBarController.setScrollTabItemToCenter(
                    initialPage,
                    sizeList,
                    _viewportSize / 2,
                    _scrollController,
                    null,
                  );
                });
              });
            },
            onTapItem: (index) {
              if (_currentIndex != index) {
                widget.onTapItem?.call(index);
                _animateToIndex(index);
              }
            },
          );
        },
      ),
    );

    if (widget.indicator != null) {
      children.add(_buildIndicator());
    }

    return Stack(children: children);
  }

  Widget _buildIndicator() {
    for (int i = 0; i < sizeList.length; i++) {
      if (sizeList[i].width == 0) {
        return const SizedBox();
      }
    }

    return Positioned(
      key: widget.key,
      top: indicatorTop,
      left: indicatorLeft,
      right: indicatorRight,
      bottom: indicatorBottom,
      child: Container(
        decoration: BoxDecoration(
          color: widget.indicator?.color,
          borderRadius: widget.indicator?.radius,
        ),
        width: indicatorWidth,
        height: indicatorHeight,
      ),
    );
  }

  void _animateToIndex(int index) {
    if (_targetIndex == index) {
      return;
    }

    if (_targetIndex != index) {
      _targetIndex = index;
      _tabBarController.startToTargetGoing();
    }

    if (widget.controllerToJump) {
      if (widget.animationDuration > Duration.zero) {
        widget.pageController.animateToPage(
          index,
          duration: widget.animationDuration,
          curve: Curves.easeIn,
        );
      }

      if (widget.animationDuration <= Duration.zero) {
        widget.pageController.jumpToPage(index);
      }
    }

    if (widget.animationDuration > Duration.zero) {
      _progressController = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      );

      Tween tween = Tween<double>(begin: 0.0, end: 1.0);
      Animation animation = tween.animate(_progressController!);

      animation.addListener(() {
        if (!mounted) {
          return;
        }

        final dir = _targetIndex > _currentIndex ? 1 : -1;
        final progress = dir == 1 ? animation.value : 1 - animation.value;

        progressNotifier.value = ScrollProgress(
          currentIndex: _currentIndex,
          targetIndex: _targetIndex,
          progress: progress,
          dir: dir,
        );

        widget.indicator?.indicatorScrollToIndex(
          index,
          sizeList,
          progressNotifier,
          positionNotifier,
        );
      });

      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _lastIndex = index;
          _targetIndex = index;
          _currentIndex = index;
          _tabBarController.setLastIndex(index);
          _tabBarController.setTargetIndex(index);
          _tabBarController.setCurrentIndex(index);
          _tabBarController.endToTargetGoing();
        }
      });

      _progressController?.forward();
    }

    if (widget.animationDuration <= Duration.zero) {
      final dir = _targetIndex > _currentIndex ? 1 : -1;
      final progress = dir == 1 ? 1.0 : 0.0;

      progressNotifier.value = ScrollProgress(
        currentIndex: _currentIndex,
        targetIndex: _targetIndex,
        progress: progress,
        dir: dir,
      );

      widget.indicator?.indicatorScrollToIndex(
        index,
        sizeList,
        progressNotifier,
        positionNotifier,
      );

      _lastIndex = index;
      _targetIndex = index;
      _currentIndex = index;
      _tabBarController.setLastIndex(index);
      _tabBarController.setTargetIndex(index);
      _tabBarController.setCurrentIndex(index);
      _tabBarController.endToTargetGoing();
    }

    _tabBarController.setScrollTabItemToCenter(
      index,
      sizeList,
      _viewportSize / 2,
      _scrollController,
      widget.animationDuration,
    );
  }
}

class _ViewTabBarItemList extends StatefulWidget {
  final int itemCount;
  final Axis direction;
  final List<Size> sizeList;
  final double? viewPortWidth;
  final double? viewPortHeight;
  final IndexedWidgetBuilder builder;
  final VoidCallback onMeasureCompleted;
  final ValueChanged<int> onTapItem;
  final ScrollPhysics physics;

  const _ViewTabBarItemList({
    required this.builder,
    required this.itemCount,
    required this.direction,
    required this.sizeList,
    required this.viewPortWidth,
    required this.viewPortHeight,
    required this.onMeasureCompleted,
    required this.onTapItem,
    required this.physics,
  });

  @override
  _ViewTabBarItemListState createState() => _ViewTabBarItemListState();
}

class _ViewTabBarItemListState extends State<_ViewTabBarItemList> {
  bool isMeasureCompletedCallback = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];

    final isNeverScroll = widget.physics is NeverScrollableScrollPhysics;
    final isHorizontal = widget.direction == Axis.horizontal;
    final isVertical = widget.direction == Axis.vertical;

    if (isNeverScroll && isHorizontal) {
      double? itemWidth = (widget.viewPortWidth ?? 0) / widget.itemCount;

      for (var i = 0; i < widget.itemCount; i++) {
        widgetList.add(
          _createItem(
            i,
            SizedBox(
              width: itemWidth,
              child: widget.builder(context, i),
            ),
          ),
        );
        widget.sizeList[i] = Size(itemWidth, double.infinity);
      }

      if (!isMeasureCompletedCallback) {
        widget.onMeasureCompleted();
        isMeasureCompletedCallback = true;
      }
    }

    if (isNeverScroll && isVertical) {
      double? itemHeight = (widget.viewPortHeight ?? 0) / widget.itemCount;

      for (var i = 0; i < widget.itemCount; i++) {
        widgetList.add(
          _createItem(
            i,
            SizedBox(
              height: itemHeight,
              child: widget.builder(context, i),
            ),
          ),
        );
        widget.sizeList[i] = Size(
          widget.viewPortWidth ?? double.infinity,
          itemHeight,
        );
      }

      if (!isMeasureCompletedCallback) {
        widget.onMeasureCompleted();
        isMeasureCompletedCallback = true;
      }
    }

    if (!isNeverScroll) {
      for (var i = 0; i < widget.itemCount; i++) {
        widgetList.add(
          _createItem(
            i,
            _MeasureTabItemSizeBox(
              child: widget.builder(context, i),
              onSizeCallback: (size) {
                widget.sizeList[i] = size;
                if (isAllItemMeasureComplete() && !isMeasureCompletedCallback) {
                  widget.onMeasureCompleted();
                  isMeasureCompletedCallback = true;
                }
              },
            ),
          ),
        );
      }
    }

    if (widget.direction == Axis.horizontal) {
      return Row(children: widgetList);
    }

    if (widget.direction == Axis.vertical) {
      return Column(children: widgetList);
    }

    return const SizedBox();
  }

  Widget _createItem(int index, Widget child) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onTapItem(index),
      child: child,
    );
  }

  bool isAllItemMeasureComplete() {
    for (Size size in widget.sizeList) {
      if (size.isEmpty) {
        return false;
      }
    }
    return true;
  }
}

class ViewTabBarItem extends StatefulWidget {
  const ViewTabBarItem({
    super.key,
    this.child,
    this.transform,
    required this.index,
  });

  final int index;
  final Widget? child;
  final TabBarTransform? transform;

  @override
  ViewTabBarItemState createState() => ViewTabBarItemState();
}

class ViewTabBarItemState extends State<ViewTabBarItem> {
  ValueNotifier<ScrollProgress>? progressNotifier;
  ScrollProgress? info;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (!context.mounted) {
        return;
      }

      // ignore: use_build_context_synchronously
      progressNotifier = _ViewTabBarContext.of(context)?.progressNotifier;

      setState(() {
        info = progressNotifier!.value;
      });

      progressNotifier?.addListener(() {
        setState(() {
          info = progressNotifier!.value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (info == null) {
      return const SizedBox();
    }

    if (widget.transform != null) {
      return widget.transform!.build(context, widget.index, info!);
    }

    return Container(child: widget.child);
  }
}

class _MeasureTabItemSizeBox extends SingleChildRenderObjectWidget {
  const _MeasureTabItemSizeBox({
    required Widget super.child,
    required this.onSizeCallback,
  });

  final ValueChanged<Size> onSizeCallback;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _LayoutMeasureTabItemSizeBox(onSizeCallback: onSizeCallback);
  }
}

class _LayoutMeasureTabItemSizeBox extends RenderConstrainedBox {
  final ValueChanged<Size> onSizeCallback;

  _LayoutMeasureTabItemSizeBox({required this.onSizeCallback})
      : super(additionalConstraints: const BoxConstraints());

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    super.layout(constraints, parentUsesSize: parentUsesSize);
    if (!size.isEmpty) {
      onSizeCallback(Size.copy(size));
    }
  }
}
