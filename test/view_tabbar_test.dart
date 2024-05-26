import 'package:flutter/material.dart';
import 'package:view_tabbar/view_tabbar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ViewTabBar', (WidgetTester tester) async {
    expect(
      ViewTabBar(
        builder: (context, index) => const SizedBox(),
        pageController: PageController(),
        itemCount: 10,
      ),
      isA<Widget>(),
    );
  });
}
