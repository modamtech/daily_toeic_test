import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// Bottom Navigation Bar
// 동적으로 화면을 변화하므로 StatefulWdiget 사용
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0; // 처음에 나올 화면 지정

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.purple,
        appBar: AppBar(title: Text("AppBar title")),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.amber,
        ),
        bottomNavigationBar: BottomNavigationBar(
          // 클릭 이벤트
          onTap: _onItemTapped,
          currentIndex: _selectedIndex, // 현재 선택된 index
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              label: 'Alarm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.nightlight_round),
              label: 'Sleep',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Setting',
            ),
          ],
          selectedItemColor: Colors.amber,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    // state 갱신
    setState(() {
      _selectedIndex = index; // index는 item 순서로 0, 1, 2로 구성
    });
  }
}
