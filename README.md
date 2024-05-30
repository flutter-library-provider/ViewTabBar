# ViewTabBar

ViewTabBar 基于 TabBarController 和 PageController，实现了 TabBar 和 PageView 之间在 UI 上的解耦及联动。

- 可实现 TabBar + PageView (horizontal)
- 可实现 TabBar + PageView (vertical)
- 可实现 Carousel (轮播图)

<br/>

## 如何安装

1. 在 `pubspec.yaml` 添加

   ```
     dependencies:
       view_tabbar: ^1.2.7
   ```

2. 在命令行运行如下

   ```
    flutter pub get
   ```

<br/>

## 如何使用

<details open>
  <summary style="font-size: 18px;">
    TabBar + PageView (pinned)
  </summary>
  
  <br/>

```dart
  import 'package:flutter/material.dart';
  import 'package:view_tabbar/view_tabbar.dart';

  class HorizontalWithPinned extends StatelessWidget {
    HorizontalWithPinned({super.key});

    final pageController = PageController();
    final tabBarController = ViewTabBarController();

    @override
    Widget build(BuildContext context) {
      const tags = ['板块1', '板块2', '板块3', '板块4'];
      const duration = Duration(milliseconds: 300);

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ViewTabBar
          ViewTabBar(
            pinned: true,
            itemCount: tags.length,
            direction: Axis.horizontal,
            pageController: pageController,
            tabBarController: tabBarController,
            animationDuration: duration, // 取消动画 -> Duration.zero
            builder: (context, index) {
              return ViewTabBarItem(
                index: index,
                transform: ScaleTransform(
                  maxScale: 1.2,
                  transform: ColorsTransform(
                    normalColor: const Color(0xff606266),
                    highlightColor: const Color(0xff436cff),
                    builder: (context, color) {
                      return Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          left: 10.0,
                          right: 10.0,
                          bottom: 8.0,
                        ),
                        child: Text(
                          tags[index],
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },

            // StandardIndicator
            indicator: StandardIndicator(
              color: const Color(0xff436cff),
              width: 27.0,
              height: 2.0,
              bottom: 0,
            ),
          ),

          // PageView
          Expanded(
            flex: 1,
            child: PageView.builder(
              itemCount: tags.length,
              controller: pageController,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: Text(
                    '这里渲染显示 ${tags[index]} 的内容',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff606266),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }

```

  </div>

</details>

<details>
  <summary style="font-size: 18px;">
    Carousel (轮播图)
  </summary>
  
  <br/>

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:view_tabbar/view_tabbar.dart';

class CarouselWithTarBar extends StatefulWidget {
  const CarouselWithTarBar({super.key});

  @override
  CarouselWithTarBarState createState() => CarouselWithTarBarState();
}

class CarouselWithTarBarState extends State<CarouselWithTarBar> {
  // 共 6 个 Card 轮播元素
  // 因需要实现无限轮播的效果
  // 需在第一个元素前添加最后一个元素
  // 且在最后一个元素前添加第一个元素
  // 如此下来则就有共计 8 个轮播元素


  // 默认显示第2个轮播元素 (即 6 个 Card 中第一个)
  final pageController = PageController(initialPage: 1);
  final tabBarController = ViewTabBarController();

  int _currentIndex = 1;
  Timer? _timer;

  // 定时轮播 - 每隔 3s
  void _setTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      int page = _currentIndex + 1;

      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _setTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 10.0,
        bottom: 12.0,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.00, -1.00),
          end: Alignment(0, 1),
          stops: [0, 0.2, 1],
          colors: [
            Color(0xFFEEF3FF),
            Color(0xFFEEF3FF),
            Colors.white,
          ],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.50, color: Colors.white),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Column(
        children: [
          // 标题
          Container(
            height: 24.0,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 10.0),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Text(
              "职业类型",
              style: TextStyle(
                color: Color(0xFF101828),
                fontSize: 18.0,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),

          // PageView
          Container(
            height: 72.0,
            margin: const EdgeInsets.only(
              top: 16.0,
              bottom: 20.0,
            ),
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 10.0,
            ),
            child: NotificationListener(
              onNotification: (notification) {
                if (notification is! ScrollNotification ||
                    notification.depth != 0) {
                  return false;
                }

                if (notification is ScrollUpdateNotification) {
                  // 关闭定时器
                  _timer?.cancel();
                }

                if (notification is ScrollStartNotification) {
                  if (notification.dragDetails != null) {
                    // 关闭定时器
                    _timer?.cancel();
                  }
                }

                if (notification is ScrollEndNotification) {
                  final page = pageController.page?.round();

                  // last, 处理 end 边界
                  if (page == 7) {
                    Future.delayed(const Duration(milliseconds: 10), () {
                      pageController.jumpToPage(1);
                      _setTimer();
                    });
                    return true;
                  }

                  // first, 处理 start 边界
                  if (page == 0) {
                    Future.delayed(const Duration(milliseconds: 10), () {
                      pageController.jumpToPage(3);
                      _setTimer();
                    });
                    return true;
                  }

                  // 延时启动定时器
                  Future.delayed(
                    const Duration(milliseconds: 20),
                    () {
                      setState(() {
                        _currentIndex = page ?? 1;
                        _setTimer();
                      });
                    },
                  );
                }

                return true;
              },
              child: PageView.builder(
                itemCount: 8,
                controller: pageController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  // first, 处理 start 边界
                  if (index == 0) {
                    index = 6;
                  }

                  // last, 处理 end 边界
                  if (index == 7) {
                    index = 1;
                  }

                  return renderPageViewContent(
                    context,
                    index,
                  );
                },
              ),
            ),
          ),

          // TarBar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 0,
                child: ClipRect(
                  clipper: ViewTabBarClipper(),
                  child: ViewTabBar(
                    pinned: true,
                    height: 14.0,
                    width: 160.0,
                    direction: Axis.horizontal,
                    pageController: pageController,
                    tabBarController: tabBarController,
                    animationDuration: const Duration(milliseconds: 300),
                    indicator: StandardIndicator(
                      width: 15.0,
                      height: 4.0,
                      color: const Color(0xff436cff),
                      radius: const BorderRadius.all(Radius.circular(3.0)),
                      bottom: 5,
                    ),
                    itemCount: 8,
                    builder: (context, index) {
                      return ViewTabBarItem(
                        index: index,
                        child: Container(
                          width: 14.0,
                          height: 4.0,
                          margin: const EdgeInsets.only(
                            left: 2.0,
                            right: 2.0,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(2),
                            ),
                            color: Color(0x66436cff),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 截取 TabBar 容器大小
class ViewTabBarClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // 共 8 个 tab item (每个 tab -> 宽度: 20, 高度: 14)
    // 截取保留 第 2 - 7 tab 元素 -> Rect.fromLTWH(20, 0, 120, 14)
    return const Rect.fromLTWH(20, 0, 120, 14);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}

// 渲染 PageView 内容
Widget renderPageViewContent(context, index) {
  // PageView 内容 ....
}
```

  </div>

</details>

<br/>

## API 说明

### ViewTabBar

| API                | 说明                                                      | 必选 | 默认值                      |
| :----------------- | :-------------------------------------------------------- | :--- | :-------------------------- |
| pinned             | tabbar 固定                                               | 否   | false                       |
| builder            | widget 构建                                               | 是   |                             |
| itemCount          | tabbar 数量                                               | 是   |                             |
| direction          | tabbar 方向                                               | 否   | Axis.horizontal             |
| indicator          | tabbar 指示器                                             | 否   |                             |
| pageController     | PageView controller                                       | 是   | PageController              |
| tabBarController   | ViewTabBar controller                                     | 否   | ViewTabBarController        |
| animationDuration  | 动画时长，Duration.zero -> 禁用动画                       | 否   | Duration(milliseconds: 300) |
| controllerToScroll | PageView 滚动时，联动 TabBar/Indicator                    | 否   | true                        |
| controllerToJump   | TabBar 滑动时，联动 PageView 滚动                         | 否   | true                        |
| onTapItem          | TabBar Item onTap 事件                                    | 否   |                             |
| height             | tabbar 高度，当 direction 为 Axis.horizontal 时，请指定值 | 否   |                             |
| width              | tabbar 宽度，当 direction 为 Axis.vertical 时，请指定值   | 否   |                             |

### ViewTabBarItem

| API       | 说明                                                          | 必选 | 默认值 |
| :-------- | :------------------------------------------------------------ | :--- | :----- |
| index     | tabar item index                                              | 是   |        |
| child     | tabar item child                                              | 否   |        |
| transform | tabar item transform, 目前有 ColorsTransform / ScaleTransform | 否   |        |

### StandardIndicator

| API    | 说明                    | 必选 | 默认值 |
| :----- | :---------------------- | :--- | :----- |
| top    | indicator 顶部          | 否   |        |
| left   | indicator 左侧          | 否   |        |
| right  | indicator 右侧          | 否   |        |
| bottom | indicator 底部          | 否   |        |
| width  | indicator 宽度          | 否   |        |
| height | indicator 高度          | 否   |        |
| radius | indicator border radius | 否   |        |
| color  | indicator color         | 否   |        |

### ColorsTransform

| API            | 说明                                 | 必选 | 默认值 |
| :------------- | :----------------------------------- | :--- | :----- |
| builder        | widget 构建                          | 否   |        |
| transform      | transformer，嵌套使用 ScaleTransform | 否   |        |
| normalColor    | tabbar 正常颜色                      | 否   |        |
| highlightColor | tabbar 高亮颜色                      | 否   |        |

### ScaleTransform

| API       | 说明                                  | 必选 | 默认值 |
| :-------- | :------------------------------------ | :--- | :----- |
| builder   | widget 构建                           | 否   |        |
| transform | transformer，嵌套使用 ColorsTransform | 否   |        |
| maxScale  | tabbar 最大可缩放值                   | 否   | 1.2    |

<br/>

## Gif 演示

### TabBar + PageView **------ (horizontal)** <span style="margin-right: 10px">[看源码](https://github.com/flutter-library-provider/ViewTabBar/blob/main/example/lib/demo_horizontal_pinned.dart)</span>

  <p>
    <img 
      style="width: calc(50% - 30px); min-width: 240px; max-width: 320px; padding: 1px; margin: 0 15px 15px;" 
      src="https://linpengteng.github.io/resource/flutter-tabbar/gif/page_view (horizontal-pinned)_1.gif" 
      alt="page_view-horizontal-pinned-1"
      width="320px"
    >
    <img
      style="width: calc(50% - 30px); min-width: 240px; max-width: 320px; padding: 1px; margin: 0 15px 15px;" 
      src="https://linpengteng.github.io/resource/flutter-tabbar/gif/page_view (horizontal-no-pinned)_1.gif" 
      alt="page_view-horizontal-no-pinned-1"
      width="320px"
    >
  </p>

  <br/>

### TabBar + PageView **------ (vertical)** <span style="margin-right: 10px">[看源码](https://github.com/flutter-library-provider/ViewTabBar/blob/main/example/lib/demo_vertical_pinned.dart)</span>

  <p>
    <img 
      style="width: calc(50% - 30px); min-width: 240px; max-width: 320px; padding: 1px; margin: 0 15px 15px;"  
      src="https://linpengteng.github.io/resource/flutter-tabbar/gif/page_view (vertical-pinned)_1.gif" 
      alt="page_view-vertical-pinned-1"
      width="320px"
    >
    <img 
      style="width: calc(50% - 30px); min-width: 240px; max-width: 320px; padding: 1px; margin: 0 15px 15px;" 
      src="https://linpengteng.github.io/resource/flutter-tabbar/gif/page_view (vertical-no-pinned)_1.gif" 
      alt="page_view-vertical-no-pinned-1"
      width="320px"
    >
  </p>

  <br/>

### Carousel **------ (轮播图)** <span style="margin-right: 10px">[看源码](https://github.com/flutter-library-provider/ViewTabBar/blob/main/example/lib/demo_carousel.dart)</span>

  <p>
    <img 
      style="width: 100%;" 
      src="https://linpengteng.github.io/resource/flutter-tabbar/gif/carousel_1.gif" 
      alt="carousel_1"
      width="320px"
    >
  </p>

  <br/>
