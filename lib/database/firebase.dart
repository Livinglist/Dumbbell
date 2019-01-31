////import 'dart:math';
//
////import 'package:firebase_core/firebase_core.dart';
////import 'package:firebase_database/firebase_database.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//
////void UploadKeyAndValue() async{
////  FirebaseDatabase database = FirebaseDatabase(databaseURL: 'https://workout-planner-76f1f.firebaseio.com/');
////  DatabaseReference ref = database.reference();
////
////  KeyAndValue keyAndValue = new KeyAndValue();
////  keyAndValue.key = 'my key';
////  keyAndValue.value ='my value';
////
////  ref.set(keyAndValue.toMap());
////  print("data ref path: "+ref.path);
////}
//
////https://firestore.googleapis.com/v1beta1/projects/workout-planner-76f1f/databases/SharedRoutines
//void UploadToFirestore() async {
////  FirebaseApp firebaseApp = await FirebaseApp.configure(
////      name: 'test',
////      options: FirebaseOptions(
////          googleAppID: 'com.jiaqifeng.workoutplanner',
////          projectID: 'workout-planner-76f1f',
////          apiKey: 'AIzaSyBR4PkpQK1-VPWeP1kE3LT9roMQklixnOo'));
//  //Firestore firestore = new Firestore(app: firebaseApp);
//
//  //firestore.collection('SharedRoutines').add({'Id':'test id', 'RoutineJsonStr':'test routine json str'});
//  Firestore.instance
//      .collection('SharedRoutines')
//      .document()
//      .setData({'Id': 'test id', 'RoutineJsonStr': 'test routine json str'});
//}
//
//class KeyAndValue {
//  String key;
//  String value;
//
//  Map<String, dynamic> toMap() => {'RoutineKey': key, 'RoutineJsonStr': value};
//}
