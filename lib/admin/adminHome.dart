import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:happy_school/admin/Adminhomescreen.dart';
import 'package:happy_school/admin/Coursesandworkshops.dart';
import 'package:happy_school/admin/Profile.dart';
import 'package:happy_school/admin/schools.dart';
import 'package:happy_school/admin/upload.dart';
import 'package:happy_school/admin/uploadcourse.dart';
import 'package:happy_school/utils/hexcolor.dart';

class Adminhome extends StatefulWidget {
  final int initialSelectedIndex;
  const Adminhome({super.key, required this.initialSelectedIndex});

  @override
  State<Adminhome> createState() => _AdminhomeState();
}

class _AdminhomeState extends State<Adminhome> {
  late PageController _pageController;
  int _selectedIndex = 0;
  late final int initialSelectedIndex;

  @override
  void initState() {
    super.initState();
    updateToken();
    getnotificationpermission();
    setState(() {
      _selectedIndex = widget.initialSelectedIndex;
    });
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    DefaultCacheManager().emptyCache();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  Future<void> getnotificationpermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> updateToken() async {
    var fcmToken = await FirebaseMessaging.instance.getToken();
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final email = user.email;
      var token = await FirebaseFirestore.instance
          .collection('fcmTokens')
          .doc(email)
          .get();

      if (token.exists) {
        await FirebaseFirestore.instance
            .collection('fcmTokens')
            .doc(email)
            .update({'token': fcmToken});
      } else {
        await FirebaseFirestore.instance
            .collection('fcmTokens')
            .doc(email)
            .set({'token': fcmToken});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 254, 248),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.notifications_none,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: AlwaysScrollableScrollPhysics(),
        onPageChanged: (index) {
          handleNavigation(index);
        },
        children: [
          Adminhomescreen(),
          Coursesandworkshops(),
          UploadPage(),
          Schools(),
          Profile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.clipboard),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              size: 30,
            ),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Schools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 145, 0),
        onTap: _onItemTapped,
      ),
      drawer: CustomDrawer(
        handleNavigation: handleNavigation,
      ),
    );
  }

  void handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          _pageController.jumpToPage(0);
          break;
        case 1:
          _pageController.jumpToPage(1);
          break;
        case 2:
          _pageController.jumpToPage(2);
          break;
        case 3:
          _pageController.jumpToPage(3);
          break;
        default:
          break;
      }
    });
  }
}

class CustomDrawer extends StatelessWidget {
  final Function(int) handleNavigation;

  CustomDrawer({required this.handleNavigation});
  // ignore: non_constant_identifier_names
  final User = FirebaseAuth.instance.currentUser;
  Future<String?> getUsername() async {
    String? email;
    try {
      var userDocument = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(User!.email)
          .collection('userinfo')
          .doc('userinfo')
          .get();

      if (userDocument.exists) {
        // If the document exists, retrieve the username
        email = userDocument.get('email');
      }
    } catch (e) {
      print("Error getting username: $e");
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Drawer(
      width: width * 0.80,
      backgroundColor: Colors.white,
      child: FutureBuilder<String?>(
        future: getUsername(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -20,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            child: FaIcon(
                              FontAwesomeIcons.close,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.amber,
                              size: 60,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ' Welcome,',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '  ${snapshot.data}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      snapshot.data!.length <= 26 ? 14 : 11,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.houseChimney,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Home',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    handleNavigation(
                        0); // Navigate to the first page (MainBuilderHome)
                    Navigator.pop(context);
                  },
                ),
                Divider(
                  color: Colors.black,
                  thickness: 0,
                  indent: 0,
                  endIndent: 0,
                ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.clipboard,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Orders',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    handleNavigation(1);
                    Navigator.pop(context);
                  },
                ),
                Divider(
                  color: Colors.black,
                  thickness: 0,
                  indent: 0,
                  endIndent: 0,
                ),
                ListTile(
                  leading: Icon(
                    Icons.currency_rupee,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Revenue',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    handleNavigation(2);
                    Navigator.pop(context);
                  },
                ),
                Divider(
                  color: Colors.black,
                  thickness: 0,
                  indent: 0,
                  endIndent: 0,
                ),
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    handleNavigation(3);
                    Navigator.pop(context);
                  },
                ),
                Divider(
                  color: Colors.black,
                  thickness: 0,
                  indent: 0,
                  endIndent: 0,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
