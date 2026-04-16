import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_page.dart';
import 'screens/home_screen.dart';
import 'screens/analyze_screen.dart';
import 'screens/map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '벌레 분석 앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MainPage(), // 처음 접속 시 메인 페이지(버튼 2개)
      routes: {
        // '/home'로 갈 때 arguments로 초기 탭 인덱스(0=분석,1=지도)를 넘깁니다.
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final initialIndex = (args is int) ? args : 0;
          return HomeScreen(initialIndex: initialIndex);
        },
        '/analyze': (context) => AnalyzeScreen(onResultSaved: () {}),
        '/map': (context) => MapScreen(),
      },
    );
  }
}
