import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialectService extends ChangeNotifier {
  var chkedName = "";
  var chkedSiteName = "";
  var chkedEngCntnt = "";
  var chkedChiCntnt = "";
  var chkedJanCntnt = "";

  var arrConsonant = [
    "ㄱ",
    "ㄴ",
    "ㄷ",
    "ㄹ",
    "ㅁ",
    "ㅂ",
    "ㅅ",
    "ㅇ",
    "ㅈ",
    "ㅊ",
    "ㅋ",
    "ㅍ",
    "ㅌ",
    "ㅎ"
  ];

  final dialectCollection =
      FirebaseFirestore.instance.collection('jejudialectdictn');

  final dialectDetailCollection =
      FirebaseFirestore.instance.collection('dialectdetail');

  Future<QuerySnapshot> read(String consonant) async {
    if (consonant == "") consonant = " ";
    var eachInput = "";
    bool blnConsonant = false;

    for (eachInput in arrConsonant) {
      if (eachInput == consonant) blnConsonant = true;
    }

    if (blnConsonant == true) {
      return await dialectCollection
          .where('consonant', isEqualTo: consonant)
          .get();
    } else {
      if (consonant.length == 1) {
        return await dialectCollection
            .where('syl1', isEqualTo: consonant)
            .get();
      } else if (consonant.length == 2) {
        return await dialectCollection
            .where('syl2', isEqualTo: consonant)
            .get();
      } else if (consonant.length == 3) {
        return await dialectCollection
            .where('syl3', isEqualTo: consonant)
            .get();
      } else if (consonant.length == 4) {
        return await dialectCollection
            .where('syl4', isEqualTo: consonant)
            .get();
      } else if (consonant.length == 5) {
        return await dialectCollection
            .where('syl5', isEqualTo: consonant)
            .get();
      } else if (consonant.length == 6) {
        return await dialectCollection
            .where('syl6', isEqualTo: consonant)
            .get();
      } else if (consonant.length == 7) {
        return await dialectCollection
            .where('syl7', isEqualTo: consonant)
            .get();
      } else if (consonant.length == 8) {
        return await dialectCollection
            .where('syl8', isEqualTo: consonant)
            .get();
      } else {
        return await dialectCollection
            .where('site_name', isEqualTo: consonant)
            .get();
      }
    }
  }

  Future<QuerySnapshot> readDetail(String dtlName) async {
    return await dialectCollection.where('name', isEqualTo: dtlName).get();
  }

  //  String consonant, String vowel
  void create(
      String seq,
      String index,
      int order,
      String name,
      String siteName,
      String consonant,
      String vowel,
      String content,
      String engContent,
      String janContent,
      String chiContent,
      String sound,
      String soundUrl) async {
    String syl1 = "";
    String syl2 = "";
    String syl3 = "";
    String syl4 = "";
    String syl5 = "";
    String syl6 = "";
    String syl7 = "";
    String syl8 = "";

    if (siteName.length == 1) {
      syl1 = siteName.substring(0, 1);
    } else if (siteName.length == 2) {
      syl1 = siteName.substring(0, 1);
      syl2 = siteName.substring(0, 2);
    } else if (siteName.length == 3) {
      syl1 = siteName.substring(0, 1);
      syl2 = siteName.substring(0, 2);
      syl3 = siteName.substring(0, 3);
    } else if (siteName.length == 4) {
      syl1 = siteName.substring(0, 1);
      syl2 = siteName.substring(0, 2);
      syl3 = siteName.substring(0, 3);
      syl4 = siteName.substring(0, 4);
    } else if (siteName.length == 5) {
      syl1 = siteName.substring(0, 1);
      syl2 = siteName.substring(0, 2);
      syl3 = siteName.substring(0, 3);
      syl4 = siteName.substring(0, 4);
      syl5 = siteName.substring(0, 5);
    } else if (siteName.length == 6) {
      syl1 = siteName.substring(0, 1);
      syl2 = siteName.substring(0, 2);
      syl3 = siteName.substring(0, 3);
      syl4 = siteName.substring(0, 4);
      syl5 = siteName.substring(0, 5);
      syl6 = siteName.substring(0, 6);
    } else if (siteName.length == 7) {
      syl1 = siteName.substring(0, 1);
      syl2 = siteName.substring(0, 2);
      syl3 = siteName.substring(0, 3);
      syl4 = siteName.substring(0, 4);
      syl5 = siteName.substring(0, 5);
      syl6 = siteName.substring(0, 6);
      syl7 = siteName.substring(0, 7);
    } else if (siteName.length == 8) {
      syl1 = siteName.substring(0, 1);
      syl2 = siteName.substring(0, 2);
      syl3 = siteName.substring(0, 3);
      syl4 = siteName.substring(0, 4);
      syl5 = siteName.substring(0, 5);
      syl6 = siteName.substring(0, 6);
      syl7 = siteName.substring(0, 7);
      syl8 = siteName.substring(0, 8);
    }

    // jeju dialect 만들기
    await dialectCollection.add({
      'seq': seq,
      'index': index,
      'order': order,
      'name': name,
      'view_name': name,
      'site_name': siteName,
      'consonant': consonant,
      'vowel': vowel,
      'content': content,
      'eng_content': engContent,
      'jan_content': janContent,
      'chi_content': chiContent,
      'sound': sound,
      'sound_url': soundUrl,
      'syl1': syl1,
      'syl2': syl2,
      'syl3': syl3,
      'syl4': syl4,
      'syl5': syl5,
      'syl6': syl6,
      'syl7': syl7,
      'syl8': syl8,
      'favorite': false,
    });
    notifyListeners();
  }

  void update(String docId, String chkedItem, String chkedContent) async {
    // item 업데이트
    if (chkedItem == 'view_name') {
      await dialectCollection
          .doc(docId)
          .update({'index': chkedContent.substring(0, 1)});
      await dialectCollection.doc(docId).update({'view_name': chkedContent});
    } else if (chkedItem == 'site_name') {
      await dialectCollection.doc(docId).update({'site_name': chkedContent});
    } else if (chkedItem == 'content') {
      await dialectCollection.doc(docId).update({'content': chkedContent});
    } else if (chkedItem == 'eng_content') {
      await dialectCollection.doc(docId).update({'eng_content': chkedContent});
    } else if (chkedItem == 'chi_content') {
      await dialectCollection.doc(docId).update({'chi_content': chkedContent});
    } else if (chkedItem == 'jan_content') {
      await dialectCollection.doc(docId).update({'jan_content': chkedContent});
    }
    notifyListeners();
  }

  void updateFavorite(String docId, bool pFavorite) async {
    // item 업데이트
    await dialectCollection.doc(docId).update({'favorite': pFavorite});
    notifyListeners();
  }

  /* 
  void delete(String docId) async {
    // bucket 삭제
    await dialectCollection.doc(docId).delete();
    notifyListeners();
  }
  */

  void search() {
    notifyListeners();
  }
}
