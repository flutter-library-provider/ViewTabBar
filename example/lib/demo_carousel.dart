import 'dart:async';
import 'package:flutter/material.dart';
import 'package:view_tabbar/view_tabbar.dart';

// StatefulWidget
class CarouselWithTarBar extends StatefulWidget {
  const CarouselWithTarBar({super.key});

  @override
  CarouselWithTarBarState createState() => CarouselWithTarBarState();
}

// StatefulWidget State
class CarouselWithTarBarState extends State<CarouselWithTarBar> {
  final pageController = PageController(initialPage: 1);
  final tabBarController = ViewTabBarController();

  int _currentIndex = 1;
  Timer? _timer;

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

                  // last
                  if (page == 7) {
                    Future.delayed(const Duration(milliseconds: 10), () {
                      pageController.jumpToPage(1);
                      _setTimer();
                    });
                    return true;
                  }

                  // first
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
                  if (index == 0) {
                    index = 6;
                  }

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
    return const Rect.fromLTWH(20, 0, 120, 14);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}

// 渲染 PageView 内容
Widget renderPageViewContent(context, index) {
  final times = [
    '2024.05.26',
    '2024.05.21',
    '2024.05.22',
    '2024.05.23',
    '2024.05.24',
    '2024.05.25',
    '2024.05.26',
    '2024.05.21',
  ];

  final contents = [
    '这是一个长发飘飘待人亲和的互联网销售女经理 (编号 x006)',
    '这是一个阳光帅气戴眼镜的互联网男程序员 (编号 x001)',
    '这是一个精神抖擞戴眼镜的互联网产品男经理 (编号 x002)',
    '这是一个穿着时尚戴眼镜的互联网销售男经理 (编号 x003)',
    '这是一个雷厉风行戴眼镜的互联网销售女主管 (编号 x004)',
    '这是一个扎着两个马尾爱笑的互联网销售女实习员 (编号 x005)',
    '这是一个长发飘飘待人亲和的互联网销售女经理 (编号 x006)',
    '这是一个阳光帅气戴眼镜的互联网男程序员 (编号 x001)',
  ];

  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(
          5.0,
        ),
        child: Image(
          image: AssetImage(
            'lib/assets/$index.png',
          ),
          width: 72.0,
          height: 72.0,
          fit: BoxFit.fill,
        ),
      ),
      Expanded(
        child: Container(
          height: 72.0,
          margin: const EdgeInsets.only(
            left: 12.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48.0,
                child: Text(
                  contents[index],
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 14,
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              SizedBox(
                height: 16.0,
                child: Row(
                  children: [
                    const Image(
                      image: AssetImage(
                        'lib/assets/time.png',
                      ),
                      width: 16.0,
                      height: 16.0,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      times[index],
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 14,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w400,
                        height: 1.33333,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
