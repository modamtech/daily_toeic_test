// ignore_for_file: file_names
/*
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_toeic_test/sub/dialect_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dialect Dic',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController jobController = TextEditingController();
  String consonant = "ㅇ";

  final player = AudioPlayer();
  double progress = 0.0;
  String curPostTime = "";
  String endPostTime = "";

  @override
  initState() {}

  @override
  Widget build(BuildContext context) {
    return Consumer<DialectService>(
      builder: (context, dialectService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("제주 방언 사전"),
          ),
          body: Center(
            child: Column(
              children: [
                /// 입력창
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      /// 텍스트 입력창
                      Expanded(
                        child: TextField(
                          controller: jobController,
                          decoration: InputDecoration(
                            hintText: "첫자음을 입력해주세요.",
                          ),
                        ),
                      ),

                      /// 추가 버튼
                      ElevatedButton(
                        child: Icon(Icons.search),
                        onPressed: () {
                          consonant = jobController.text;
                          dialectService.search();
                        },
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),

                /// 버킷 리스트
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                      future: dialectService.read(consonant),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            String job = doc.get('name');
                            String soundUrl = doc.get('sound');
                            return ListTile(
                              title: Text(
                                job,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              // 오디오 아이콘 버튼
                              trailing: IconButton(
                                icon: Icon(CupertinoIcons.speaker_1_fill),
                                onPressed: () {
                                  player.play(
                                      "https://www.jeju.go.kr/files/dialect/${soundUrl}");
                                },
                              ),
                              onTap: () {
                                // 상세 페이지로 이동
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(targetTxt: job),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 로그인 페이지
class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.targetTxt});

  final String targetTxt;

  @override
  State<DetailPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<DetailPage> {
  TextEditingController updController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController siteNameController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController engContentController = TextEditingController();
  TextEditingController chiContentController = TextEditingController();
  TextEditingController janContentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<DialectService>(
      builder: (context, dialectService, child) {
        String targetName = widget.targetTxt;
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black),
            title: Text(
              "상세 정보",
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Center(
            child: Column(
              children: [
                /// 입력창
                /*
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      /// 텍스트 입력창
                      Expanded(
                        child: TextField(
                          controller: updController,
                          decoration: InputDecoration(
                            hintText: "수정 대상을 선택하세요.",
                          ),
                        ),
                      ),

                      /// 추가 버튼
                      ElevatedButton(
                        child: Icon(Icons.search),
                        onPressed: () {
                          // 아이템 클릭하여 isDone 업데이트
                          dialectService.update(targetName, updController.text);
                        },
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                */

                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: dialectService.readDetail(targetName),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          String dtlName = doc.get('name');
                          String dtlSiteName = doc.get('site_name');
                          String dtlContent = doc.get('content');
                          String dtlEngContent = doc.get('eng_content');
                          String dtlChiContent = doc.get('chi_ontent');
                          String dtlJanContent = doc.get('jan_ontent');
                          nameController.text = dtlName;
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  dtlName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                // 자료 수정 아이콘 버튼
                                trailing: IconButton(
                                  icon: Icon(CupertinoIcons.refresh_thick),
                                  onPressed: () {
                                    // 자료 수정 버튼 클릭시
                                    //bucketService.delete(doc.id);
                                  },
                                ),
                                onTap: () {
                                  // 상세 페이지로 이동
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                            targetTxt:
                                                'Flutter Demo Home Page')),
                                  );
                                },
                              ),
                              ListTile(
                                title: Text(
                                  dtlSiteName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                // 자료 수정 아이콘 버튼
                                trailing: IconButton(
                                  icon: Icon(CupertinoIcons.refresh_thick),
                                  onPressed: () {
                                    // 자료 수정 버튼 클릭시
                                    //bucketService.delete(doc.id);
                                  },
                                ),
                                onTap: () {
                                  // 상세 페이지로 이동
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                            targetTxt:
                                                'Flutter Demo Home Page')),
                                  );
                                },
                              ),
                              ListTile(
                                title: Text(
                                  dtlContent,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                // 자료 수정 아이콘 버튼
                                trailing: IconButton(
                                  icon: Icon(CupertinoIcons.refresh_thick),
                                  onPressed: () {
                                    // 자료 수정 버튼 클릭시
                                    //bucketService.delete(doc.id);
                                  },
                                ),
                                onTap: () {
                                  // 상세 페이지로 이동
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                            targetTxt:
                                                'Flutter Demo Home Page')),
                                  );
                                },
                              ),
                              ListTile(
                                title: Text(
                                  dtlEngContent,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                // 자료 수정 아이콘 버튼
                                trailing: IconButton(
                                  icon: Icon(CupertinoIcons.refresh_thick),
                                  onPressed: () {
                                    // 자료 수정 버튼 클릭시
                                    //bucketService.delete(doc.id);
                                  },
                                ),
                                onTap: () {
                                  // 상세 페이지로 이동
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                            targetTxt:
                                                'Flutter Demo Home Page')),
                                  );
                                },
                              ),
                              ListTile(
                                title: Text(
                                  dtlChiContent,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                // 자료 수정 아이콘 버튼
                                trailing: IconButton(
                                  icon: Icon(CupertinoIcons.refresh_thick),
                                  onPressed: () {
                                    // 자료 수정 버튼 클릭시
                                    //bucketService.delete(doc.id);
                                  },
                                ),
                                onTap: () {
                                  // 상세 페이지로 이동
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                            targetTxt:
                                                'Flutter Demo Home Page')),
                                  );
                                },
                              ),
                              ListTile(
                                title: Text(
                                  dtlJanContent,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                // 자료 수정 아이콘 버튼
                                trailing: IconButton(
                                  icon: Icon(CupertinoIcons.refresh_thick),
                                  onPressed: () {
                                    // 자료 수정 버튼 클릭시
                                    //bucketService.delete(doc.id);
                                  },
                                ),
                                onTap: () {
                                  // 상세 페이지로 이동
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                            targetTxt:
                                                'Flutter Demo Home Page')),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
 */