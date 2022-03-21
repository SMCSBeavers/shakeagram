import 'package:cloud_firestore/cloud_firestore.dart';

class UserObject {
  // String uid in firebase
  final String uid;
  final String name;
  // String of storage url
  final String avatar;
  final String bio;
  // list of followers string uids
  final List<String> followers;
  // list of following string uids
  final List<String> following;
  // list of ints post ids
  final List<int> posts;

  UserObject(this.uid, this.name, this.avatar, this.bio, this.followers,
      this.following, this.posts);

  // Get methods
  String get getUID {
    return uid;
  }

  String get getName {
    return name;
  }

  String get getAvatar {
    return avatar;
  }

  String get getBio {
    return bio;
  }

  List<String> get getFollowers {
    return followers;
  }

  List<String> get getFollowing {
    return following;
  }

  List<int> get getUserPosts {
    return posts;
  }

  factory UserObject.fromDocument(DocumentSnapshot documentSnapshot) {
    List<String> convertDynamicArrToStringArr(arr) {
      List<String> tempList = [];
      for (int i = 0; i < arr.length; i++) {
        tempList.add(arr[i].toString());
      }
      return tempList;
    }

    List<int> convertDynamicArrToIntArr(arr) {
      List<int> tempList = [];
      for (int i = 0; i < arr.length; i++) {
        tempList.add(arr[i].toInt());
      }
      return tempList;
    }

    return UserObject(
        documentSnapshot['uid'],
        documentSnapshot['name'],
        documentSnapshot['avatar'],
        documentSnapshot['bio'],
        convertDynamicArrToStringArr(documentSnapshot['followers']),
        convertDynamicArrToStringArr(documentSnapshot['following']),
        convertDynamicArrToIntArr(documentSnapshot['posts']));
  }
}
