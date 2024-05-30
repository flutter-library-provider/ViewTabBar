// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import './demo_horizontal_pinned.dart';
import './demo_vertical_pinned.dart';
import './demo_horizontal.dart';
import './demo_vertical.dart';
import './demo_carousel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('About ViewTabbar Page'),
        ),
        body: Container(
          padding: const EdgeInsets.only(
            top: 30,
            left: 20,
            right: 20,
            bottom: 50,
          ),
          child: _CarouselWithTarBar(),
        ),
      ),
    );
  }
}

/// PageView (Horizontal) pinned
class _RunHorizontalWithPinned extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'PageView (Horizontal)',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff303133),
                  height: 1,
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 3.0,
                    left: 5.0,
                    right: 5.0,
                    bottom: 3.0,
                  ),
                  margin: const EdgeInsets.only(left: 8.0),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Color(0xffb7eb8f),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: const Color(0xfff6ffed),
                  ),
                  child: const Text(
                    'pinned',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff389e0d),
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(top: 8.0),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Color(0xff909399),
                  style: BorderStyle.solid,
                  width: 0.6,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: HorizontalWithPinned(),
          ),
        ),
      ],
    );
  }
}

/// PageView (Vertical) pinned
class _RunVerticalWithPinned extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'PageView (Vertical)',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff303133),
                  height: 1,
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 3.0,
                    left: 5.0,
                    right: 5.0,
                    bottom: 3.0,
                  ),
                  margin: const EdgeInsets.only(left: 8.0),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Color(0xffb7eb8f),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: const Color(0xfff6ffed),
                  ),
                  child: const Text(
                    'pinned',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff389e0d),
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(top: 8.0),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Color(0xff909399),
                  style: BorderStyle.solid,
                  width: 0.6,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: VerticalWithPinned(),
          ),
        ),
      ],
    );
  }
}

/// PageView (Horizontal) no pinned
class _RunHorizontalNoPinned extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'PageView (Horizontal)',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff303133),
                  height: 1,
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 3.0,
                    left: 5.0,
                    right: 5.0,
                    bottom: 3.0,
                  ),
                  margin: const EdgeInsets.only(left: 8.0),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Color(0xffb7eb8f),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: const Color(0xfff6ffed),
                  ),
                  child: const Text(
                    'no-pinned',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff389e0d),
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(top: 8.0),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Color(0xff909399),
                  style: BorderStyle.solid,
                  width: 0.6,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: HorizontalNoPinned(),
          ),
        ),
      ],
    );
  }
}

/// PageView (Vertical) no pinned
class _RunVerticalNoPinned extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'PageView (Vertical)',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff303133),
                  height: 1,
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 3.0,
                    left: 5.0,
                    right: 5.0,
                    bottom: 3.0,
                  ),
                  margin: const EdgeInsets.only(left: 8.0),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Color(0xffb7eb8f),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: const Color(0xfff6ffed),
                  ),
                  child: const Text(
                    'no-pinned',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff389e0d),
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(top: 8.0),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Color(0xff909399),
                  style: BorderStyle.solid,
                  width: 0.6,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: VerticalNoPinned(),
          ),
        ),
      ],
    );
  }
}

/// Carousel (Horizontal)
class _CarouselWithTarBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Carousel (Horizontal)',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Color(0xff303133),
              height: 1,
            ),
          ),
        ),
        Container(
          height: 188,
          margin: const EdgeInsets.only(top: 8.0),
          child: const CarouselWithTarBar(),
        ),
      ],
    );
  }
}
