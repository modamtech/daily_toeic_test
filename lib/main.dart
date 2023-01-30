import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_toeic_test/sub/auth_service.dart';
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
        ChangeNotifierProvider(create: (context) => AuthService()),
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
    final user = context.read<AuthService>().currentUser();
    print(user);
    return MaterialApp(
      title: 'Dialect Dic',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: user == null ? LoginPage() : MyHomePage(targetConsonant: ""),
    );
  }
}

/// 로그인 페이지
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser();
        return Scaffold(
          appBar: AppBar(title: Text("로그인")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// 현재 유저 로그인 상태
                Center(
                  child: Text(
                    user == null ? "로그인해 주세요 🙂" : "${user.email}님 안녕하세요 👋",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(height: 32),

                /// 이메일
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: "이메일"),
                ),

                /// 비밀번호
                TextField(
                  controller: passwordController,
                  obscureText: false, // 비밀번호 안보이게
                  decoration: InputDecoration(hintText: "비밀번호"),
                ),
                SizedBox(height: 32),

                /// 로그인 버튼
                ElevatedButton(
                  child: Text("로그인", style: TextStyle(fontSize: 21)),
                  onPressed: () {
                    // 로그인
                    authService.signIn(
                      email: emailController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        // 로그인 성공
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("로그인 성공"),
                        ));

                        // MyHomePage로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyHomePage(targetConsonant: "")),
                        );
                      },
                      onError: (err) {
                        // 에러 발생
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(err),
                        ));
                      },
                    );
                  },
                ),

                /// 회원가입 버튼
                ElevatedButton(
                  child: Text("회원가입", style: TextStyle(fontSize: 21)),
                  onPressed: () {
                    // 회원가입
                    authService.signUp(
                      email: emailController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        // 회원가입 성공
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("회원가입 성공"),
                        ));
                      },
                      onError: (err) {
                        // 에러 발생
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(err),
                        ));
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.targetConsonant});

  final String targetConsonant;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController jobController = TextEditingController();

  final player = AudioPlayer();
  double progress = 0.0;
  String curPostTime = "";
  String endPostTime = "";

  @override
  initState() {}

  @override
  Widget build(BuildContext context) {
    String consonant = widget.targetConsonant;
    jobController.text = consonant;

    return Consumer<DialectService>(
      builder: (context, dialectService, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black),
            title: Text(
              "제주 방언 사전",
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  "로그아웃",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  // 로그아웃
                  context.read<AuthService>().signOut();

                  // 로그인 페이지로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
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
                          style: TextStyle(fontSize: 20.0),
                          controller: jobController,
                          decoration: InputDecoration(
                            hintText: "첫자음을 입력해주세요.",
                          ),
                        ),
                      ),

                      /// 홈 페이지 조회 버튼
                      ElevatedButton(
                        child: Icon(Icons.search, size: 24),
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
                            String viewName = doc.get('view_name');
                            String name = doc.get('name');
                            String soundUrl = doc.get('sound');
                            return ListTile(
                              title: Text(
                                viewName,
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
                                    builder: (context) => DetailPage(
                                        targetTxt: name,
                                        targetConsonant: consonant),
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

/// 로그인 이후 페이지
class DetailPage extends StatefulWidget {
  const DetailPage(
      {super.key, required this.targetTxt, required this.targetConsonant});

  final String targetTxt;
  final String targetConsonant;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  //TextEditingController updController = TextEditingController();
  TextEditingController viewNameController = TextEditingController();
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
        String targetConsonant = widget.targetConsonant;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black),
            leading: IconButton(
              icon: Icon(
                CupertinoIcons.back,
                color: Colors.black,
              ),
              //onPressed: () => Navigator.of(context).pop(),
              onPressed: () {
                // 상세 페이지로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MyHomePage(targetConsonant: targetConsonant),
                  ),
                );
              },
            ),
            title: Text(
              "상세 정보",
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
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

                          String dtlViewName = doc.get('view_name');
                          String dtlSiteName = doc.get('site_name');
                          String dtlContent = doc.get('content');
                          String dtlEngContent = doc.get('eng_content');
                          String dtlChiContent = doc.get('chi_content');
                          String dtlJanContent = doc.get('jan_content');

                          viewNameController.text = dtlViewName;
                          siteNameController.text = dtlSiteName;
                          contentController.text = dtlContent;
                          engContentController.text = dtlEngContent;
                          chiContentController.text = dtlChiContent;
                          janContentController.text = dtlJanContent;

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    " > 방 언 :  ",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: TextField(
                                      controller: viewNameController,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "입력해 주세요.",
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.refresh_rounded),
                                          onPressed: () {
                                            dialectService.update(
                                                doc.id,
                                                "view_name",
                                                viewNameController.text);
                                            /*
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MyHomePage(
                                                        targetConsonant:
                                                            targetConsonant),
                                              ),
                                            );
                                            */
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              /*
                              TextField(
                                controller: siteNameController,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                                decoration: InputDecoration(
                                  hintText: "입력해 주세요.",
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.refresh_rounded),
                                    onPressed: () {
                                      dialectService.update(doc.id, "site_name",
                                          siteNameController.text);
                                    },
                                  ),
                                ),
                              ),
                              */
                              Row(
                                children: [
                                  Text(
                                    " > 표 준 :  ",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: TextField(
                                      controller: contentController,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "입력해 주세요.",
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.refresh_rounded),
                                          onPressed: () {
                                            dialectService.update(
                                                doc.id,
                                                "content",
                                                contentController.text);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    " > 영 어 :  ",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: TextField(
                                      controller: engContentController,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "입력해 주세요.",
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.refresh_rounded),
                                          onPressed: () {
                                            dialectService.update(
                                                doc.id,
                                                "eng_content",
                                                engContentController.text);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    " > 중 국 :  ",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: TextField(
                                      controller: chiContentController,
                                      //inputFormatters: <TextInputFormatter>[
                                      //  FilteringTextInputFormatter.allow(
                                      //      RegExp(r'[ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ]')),
                                      //],
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "입력해 주세요.",
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.refresh_rounded),
                                          onPressed: () {
                                            dialectService.update(
                                                doc.id,
                                                "chi_content",
                                                chiContentController.text);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    " > 일 어 :  ",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: TextField(
                                      controller: janContentController,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "입력해 주세요.",
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.refresh_rounded),
                                          onPressed: () {
                                            dialectService.update(
                                                doc.id,
                                                "jan_content",
                                                janContentController.text);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
