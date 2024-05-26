import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_tabbar/custom_tabbar.dart';

void main() {
  testWidgets('CustomTabBar', (WidgetTester tester) async {
    expect(
      CustomTabBar(
        builder: (context, index) => const SizedBox(),
        pageController: PageController(),
        itemCount: 10,
      ),
      isA<Widget>(),
    );
  });
}
