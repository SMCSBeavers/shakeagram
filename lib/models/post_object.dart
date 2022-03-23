import 'package:cloud_firestore/cloud_firestore.dart';

class PostObject {
  final String location;
  final String imageURL;
  final List<String> likers;
  final String description;
  final List<String> comments;
  final DateTime date;
  final String uid;

  PostObject(this.location, this.imageURL, this.likers, this.description,
      this.comments, this.date, this.uid);

  // Get methods

  String get getLocation {
    return location;
  }

  String get getImageURL {
    return imageURL;
  }

  List<String> get getLikers {
    return likers;
  }

  String get getDescription {
    return description;
  }

  List<String> get getComments {
    return comments;
  }

  String get getUID {
    return uid;
  }

  DateTime get getDate {
    return date;
  }

  factory PostObject.fromDocument(DocumentSnapshot documentSnapshot) {
    List<String> convertDynamicArrToStringArr(arr) {
      List<String> tempList = [];
      for (int i = 0; i < arr.length; i++) {
        tempList.add(arr[i].toString());
      }
      return tempList;
    }

    DateTime convertTSDate(Timestamp timestamp) {
      return timestamp.toDate();
    }

    return PostObject(
        documentSnapshot['location'],
        documentSnapshot['imageURL'],
        convertDynamicArrToStringArr(documentSnapshot['likers']),
        documentSnapshot['description'],
        convertDynamicArrToStringArr(documentSnapshot['comments']),
        convertTSDate(documentSnapshot['date']),
        documentSnapshot['uid']);
  }
}
