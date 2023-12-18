import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resize/resize.dart';
import 'package:vertical_nav_bar/vertical_nav_bar.dart';

import '../../widget/aboutdialog.dart';

class SettingsPage extends StatefulWidget {
  final String description;
  const SettingsPage({
    super.key,
    required this.description,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int currentRoute = 0;
  @override
  Widget build(BuildContext context) {
    List myRoutes = [
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "PAGE 1",
              style: TextStyle(
                color: Colors.black,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 25.sp,horizontal: 25.sp),
              child: Text(
                widget.description,
                style: TextStyle(fontSize: 8.sp, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 22,
            ),
          ],
        ),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "PAGE 3",
              style: TextStyle(
                color: Colors.black,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "PAGE 4",
              style: TextStyle(
                color: Colors.black,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ];
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[myRoutes[currentRoute]],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                VerticalNavBar(
                  selectedIndex: currentRoute,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width * 0.2,
                  onItemSelected: (value) {
                    setState(() {
                      _navigateRoutes(value);
                    });
                  },
                  items: const [
                    VerticalNavBarItem(
                      title: "S E T T I N G S",
                    ),
                    VerticalNavBarItem(
                      title: "A B O U T",
                    ),
                    VerticalNavBarItem(
                      title: "H O M E",
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateRoutes(int selectedIndex) {
    if (selectedIndex == 2) {
      Get.back();
    } else {
      setState(() {
        currentRoute = selectedIndex;
      });
    }
  }
}
