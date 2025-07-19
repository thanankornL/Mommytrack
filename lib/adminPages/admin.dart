import 'package:carebellmom/adminPages/Chatbot_index_Admin.dart';
import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'AdminHomePage.dart';
import '../notification.dart';
import '../PersonalPage.dart';
import 'package:carebellmom/chatbot/Chatbot_index.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int currentPageIndex = 1; // Default index

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    var navigationBar2 = NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      indicatorColor: const Color.fromARGB(255, 135, 191, 255),

      // มุมมน
      selectedIndex: currentPageIndex,
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.notifications_active),
          icon: Badge(child: Icon(Icons.notifications_outlined)),
          label: 'Notifications',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.message),
          icon: Icon(Icons.message_outlined),
          label: 'Chatbot',
        ),
        NavigationDestination(
          selectedIcon: Badge(
            label: Text('2'),
            child: Icon(Icons.messenger_sharp),
          ),
          icon: Icon(Icons.person_outlined),
          label: 'User',
        ),
      ],
    );
    var navigationBar = navigationBar2;
    return Scaffold(
      bottomNavigationBar: navigationBar,
      body: Center(
        child:
            currentPageIndex == 0
                ? NotificationPage() // Show Text when index is 0
                : currentPageIndex == 1
                ? AdminHomePage()
                : currentPageIndex == 2
                ? Chatbot_index_Admin()
                : currentPageIndex == 3
                ? PersonalPage() // Show Index3Page when index is 3
                : Text("Other Content"), // Default content for other indices
      ),
    );
  }
}
