import 'package:QuoteApp/presentation/screens/catalog/catalog.dart';
import 'package:QuoteApp/presentation/screens/home/main_dashboard.dart';
import 'package:QuoteApp/presentation/screens/settings/settings_screen.dart';
import 'package:QuoteApp/presentation/screens/user/account_info_screen.dart';
import 'package:QuoteApp/presentation/widgets/fab.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class RootScreen extends StatefulWidget {
  static const routeName = '/root_screen';

  const RootScreen({Key? key}) : super(key: key);

  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int bottomNavIndex = 0;

  List<Widget> screens = [
    MainDashboard(),
    Catalog(),
    AccountInfoScreen(),
    SettingsScreen(),
  ];

  List<IconData> iconList = [
    Icons.home,
    Icons.photo_album,
    Icons.account_circle,
    Icons.settings,
  ];

  List<String> titleList = [
    'Home',
    'Catalog',
    'Profile',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: bottomNavIndex,
        children: screens,
      ),
      floatingActionButton: const Fab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        // leftCornerRadius: 30,
        // rightCornerRadius: 30,
        inactiveColor: Color.fromRGBO(0, 0, 0, 0.5),
        gapLocation: GapLocation.center,
        activeIndex: bottomNavIndex,
        activeColor: Colors.black,
        icons: iconList,
        onTap: (index) {
          setState(
            () {
              bottomNavIndex = index;
            },
          );
        },
      ),
    );
  }
}
