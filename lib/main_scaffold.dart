import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reathm/history_page.dart';
import 'package:reathm/home_page.dart';
import 'auth_service.dart';
import 'activity_calendar_page.dart';

class MainScaffold extends StatefulWidget {
  final User user;

  const MainScaffold({Key? key, required this.user}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(user: widget.user),
      HistoryPage(user: widget.user),
      ActivityCalendarPage(user: widget.user),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  AppBar _buildAppBar() {
    String title;
    switch (_selectedIndex) {
      case 1:
        title = 'History';
        break;
      case 2:
        title = 'Activity Calendar';
        break;
      default:
        title = 'Reathm';
    }

    if (_selectedIndex == 0) {
      return AppBar(
        title: const Text('Reathm'),
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            icon: CircleAvatar(
              backgroundImage: widget.user.photoURL != null
                  ? NetworkImage(widget.user.photoURL!)
                  : null,
              child: widget.user.photoURL == null
                  ? Text(widget.user.displayName != null
                      ? widget.user.displayName![0].toUpperCase()
                      : '')
                  : null,
            ),
            onSelected: (value) async {
              if (value == 'signOut') {
                try {
                  await AuthService.googleSignIn.disconnect();
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  print("Error signing out: $e");
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.displayName ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.user.email ?? 'No Email',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'signOut',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return AppBar(
        title: Text(title),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}