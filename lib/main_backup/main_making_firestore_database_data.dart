/// *********************************************************
/// 작성일 :2023.01.01
/// 프로그램의 목적 :
/// 오픈 API 의 XML 데이터를 읽어 Firebase(dialectDicJeju) 의
/// jejudialecdic 컬렉션에 데이터를 생성한다.
/// *********************************************************
///

import 'dart:convert';

import 'package:daily_toeic_test/sub/dialect_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:xml2json/xml2json.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  await Firebase.initializeApp(); // firebase 앱 시작
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DialectService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dialect Dic',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// ****************************************************
  /// 방언 데이터를 Firestore Database 에 생성하기 위한 코딩
  /// ****************************************************
  getJejuDialect({required int idx}) async {
    print("idx = ${idx}");
    var url =
        'https://www.jeju.go.kr/rest/JejuDialectService/getJejuDialectServiceList?authApiKey=&page=$idx&pageSize=1';
    var response = await http.get(Uri.parse(url));
    var xml = utf8.decode(response.bodyBytes);
    var xml2Json = Xml2Json()..parse(xml);
    var json = xml2Json.toParker();
    var jsonResult0 = jsonDecode(json);
    var jsonResult1 = (jsonResult0["jejunetApi"]["list"]["item"]);
    Map jsonResult = jsonResult1 as Map;
    print("seq = " + jsonResult["seq"]);
    return jsonResult;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DialectService>(
      builder: (context, dialectService, child) {
        int indx = 0;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                /// ****************************************************
                /// 방언 데이터를 Firestore Database 에 생성하기 위한 코딩
                /// ****************************************************
                MaterialButton(
                  onPressed: () {
                    //dialectData.clear();
                    int idx = 6996;
                    for (indx = 7000; indx < 7200; indx++) {
                      getJejuDialect(idx: indx).then((dynamic result) {
                        idx = idx + 1;
                        if (result is Map) {
                          dialectService.create(
                            result['seq'],
                            result['index'],
                            idx,
                            result['name'],
                            result['siteName'],
                            '',
                            '',
                            result['contents'],
                            result['engContents'],
                            result['janContents'],
                            result['chiContents'],
                            result['sound'],
                            result['soundUrl'],
                          );
                          print(idx);
                        }
                      });
                    }
                  },
                  child: Text(
                    '검색하기2',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blueAccent,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
