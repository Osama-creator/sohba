import 'package:flutter/material.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/view/screens/home/tabs/chalenges_tab.dart';
import 'package:sohba/view/screens/home/tabs/friends_tab.dart';
import 'package:sohba/view/screens/home/tabs/profile_tap.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: const <Widget>[
          // ProfileTab(),
          ChalengesTab(),
          FriendsTab(),
        ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: StylishBottomBar(
        currentIndex: _selectedIndex,
        hasNotch: true,
        option: DotBarOptions(),
        onTap: _onItemTapped,
        items: [
          // BottomBarItem(
          //   icon: const Icon(
          //     Icons.account_circle_outlined,
          //   ),
          //   title: const Text("الحساب"),
          //   unSelectedColor: Colors.grey.shade400,
          //   selectedColor: AppColors.primary,
          // ),
          BottomBarItem(
            icon: const Icon(
              Icons.battery_5_bar,
            ),
            title: const Text("التحديات"),
            unSelectedColor: Colors.grey.shade400,
            selectedColor: AppColors.primary,
          ),
          BottomBarItem(
            icon: const Icon(
              Icons.people_alt_outlined,
            ),
            title: const Text("الأصدقاء"),
            unSelectedColor: Colors.grey.shade400,
            selectedColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
