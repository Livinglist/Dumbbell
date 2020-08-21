import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in.dart';

import 'package:workout_planner/models/routine.dart';
import 'package:workout_planner/resource/shared_prefs_provider.dart';

const String FirstRunDateKey = "firstRunDate";

///format: {"2019-01-01":50} (use UTC time)

class FirebaseProvider {
  AppleIdCredential appleIdCredential;
  User firebaseUser;
  GoogleSignInAccount googleSignInAccount;
  String firstRunDate;
  bool isFirstRun;
  String dailyRankInfo;
  int dailyRank;
  int weeklyAmount;
  final FirebaseAuth firebaseAuth;

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  FirebaseProvider() : firebaseAuth = FirebaseAuth.instance;

  static String generateId() {
    var id = Uuid().v4();
    return id;
  }

  Future uploadRoutines(List<Routine> routines, {failCallback: VoidCallback}) async {
    return Connectivity().checkConnectivity().then((connectivity) async {
      if (connectivity == ConnectivityResult.none) {
        throw ("No connections to internet.");
      } else {
        if(firebaseUser == null) return;
        var db = FirebaseFirestore.instance;
        var snapshot = await db.collection("users").doc(firebaseUser.uid).get();

        if (snapshot.exists) {
          return snapshot.reference.update({"routines": routines.map((routine) => jsonEncode(routine.toMap())).toList()});
        } else {
          return db.collection("users").doc(firebaseUser.uid).set({
            "registerDate": firstRunDate,
            "email": firebaseUser.email,
            "routines": routines.map((routine) => jsonEncode(routine.toMap())).toList()
          });
        }
      }
    });
  }

  Future<int> getDailyData({failCallback: VoidCallback}) async {
    final String tempDateStr = dateTimeToStringConverter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return -1;
    } else {
      var db = FirebaseFirestore.instance;
      var snapshot = await db.collection("dailyData").doc(tempDateStr).get();

      if (snapshot.exists) {
        return snapshot.data()["totalCount"];
      } else {
        await db.collection("dailyData").doc(tempDateStr).set({"totalCount": 0});
        return 0;
      }
    }
  }

  Future<DocumentSnapshot> handleRestore() async {
    var db = FirebaseFirestore.instance;
    var snapshot = await db.collection("users").doc(appleIdCredential.user).get();

    if (snapshot.exists) {
      firstRunDate = snapshot.data()["registerDate"];
      //var routines = (json.decode(snapshot.data["routines"]) as List).map((map) => Routine.fromMap(map)).toList();
    }

    return snapshot;
  }

  //Check whether or not user has routines in the cloud.
  Future<bool> checkUserExists() => FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get().then((snapshot) => snapshot.exists);

  Future<List<Routine>> restoreRoutines() async {
    print("Restoring");
    var db = FirebaseFirestore.instance;
    var snapshot = await db.collection("users").doc(firebaseUser.uid).get();

    List<Routine> routines = snapshot
        .data()["routines"]
        .map((json) {
          Map map = jsonDecode(json);
          var r = Routine.fromMap(map);
          return r;
        })
        .toList()
        .cast<Routine>();

    return routines;
  }

  //Future<bool> isSignedIn() => googleSignIn.isSignedIn();

  Future<User> signInSilently() async {
    var signInMethod = await sharedPrefsProvider.getSignInMethod();

    String email, password;

    switch (signInMethod) {
      case SignInMethod.apple:
        email = await sharedPrefsProvider.getString(emailKey);
        password = await sharedPrefsProvider.getString(passwordKey);
        break;
      case SignInMethod.google:
        email = await sharedPrefsProvider.getString(gmailKey);
        password = await sharedPrefsProvider.getString(gmailPasswordKey);
        break;
      case SignInMethod.none:
        return null;
      default:
        throw Exception("Unmatched SignInMethod value");
    }

    print("Signing in silently");
    if (email != null && password != null) {
      return firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((authResult) {
        firebaseUser = authResult.user;
        return firebaseUser;
      });
    }
    return null;
  }

  Future<User> signInApple() async {
    if (await AppleSignIn.isAvailable()) {
      final result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      if (result.status == AuthorizationStatus.authorized) {
        this.appleIdCredential = result.credential;

        var userId = appleIdCredential.user;

        var email = appleIdCredential.email;
        var password = appleIdCredential.email;

        if (appleIdCredential.email == null || (result.credential.fullName.familyName == null && result.credential.fullName.givenName == null)) {
          email = await sharedPrefsProvider.getString(emailKey);
          password = await sharedPrefsProvider.getString(passwordKey);

          if (email == null) {
            var snapshot = await FirebaseFirestore.instance.collection('appleIdToEmail').doc(userId).get();
            email = snapshot.data()['email'];
            password = snapshot.data()['password'];
          }

          return firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((authResult) {
            this.firebaseUser = authResult.user;
            sharedPrefsProvider.setSignInMethod(SignInMethod.apple);
            return authResult.user;
          }, onError: (PlatformException error) {
            ///TODO: The problem is that if names are null, email is going to be null as well.
            if (error.code == 'user-not-found') {
              return registerNewUser(appleIdCredential.email, appleIdCredential.email).then((value) {
                sharedPrefsProvider.saveEmailAndPassword(email, password);

                firebaseUser = value;

                return value;
              });
            }
            return null;
          });
        } else {
          return firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((authResult) {
            this.firebaseUser = authResult.user;
            sharedPrefsProvider.setSignInMethod(SignInMethod.apple);
            return authResult.user;
          }, onError: (Object error) {
            ///TODO: The problem is that if names are null, email is going to be null as well.
            if (error is PlatformException) {
              if (error.code == 'user-not-found') {
                return registerNewUser(appleIdCredential.email, appleIdCredential.email).then((firebaseUser) async {
                  print("registernewuser retuens ${firebaseUser.email}");

                  sharedPrefsProvider.setSignInMethod(SignInMethod.apple);
                  sharedPrefsProvider.saveEmailAndPassword(email, password);

                  var displayName = (appleIdCredential.fullName.givenName ?? '') + ' ' + (appleIdCredential.fullName.familyName ?? '')
                    ..trim();

                  this.firebaseUser.updateProfile(displayName: displayName).whenComplete(() => this.firebaseUser.reload());

                  return firebaseUser;
                }).whenComplete(() {
                  FirebaseFirestore.instance.collection('appleIdToEmail').doc(userId).set({
                    'email': email,
                    'password': password,
                    'name': (appleIdCredential.fullName.givenName ?? '') + ' ' + (appleIdCredential.fullName.familyName ?? '')
                      ..trim()
                  });
                });
              }
            }
            return null;
          });
        }
      } else {
        return Future.value(null);
      }
    } else {
      print('Apple SignIn is not available for your device');
      return Future.value(null);
    }
  }

  Future<User> registerNewUser(String email, String password) async {
    var authResult = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    //verify email address
    authResult.user.sendEmailVerification();

    return authResult.user;
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    googleSignIn.signOut();
    this.firebaseUser = null;
    this.appleIdCredential = null;
    sharedPrefsProvider.signOut();
  }

  Future<GoogleSignInAccount> signInGoogleSilently() => googleSignIn.signInSilently().then((value) {
        this.googleSignInAccount = value;
        return value;
      });

  Future<User> signInGoogle() async {
    var googleUser = await googleSignIn.signIn().then((value) {
      this.googleSignInAccount = value;
      return value;
    }, onError: (_) {
      return null;
    });

    if (googleUser == null) return null;

    var email = googleUser.email;
    var password = email;

    return firebaseAuth.signInWithEmailAndPassword(email: email, password: email).then((authResult) {
      this.firebaseUser = authResult.user;
      sharedPrefsProvider.setSignInMethod(SignInMethod.google);
      return authResult.user;
    }, onError: (Object error) {
      if (error is PlatformException) {
        if (error.code == "user-not-found") {
          return registerNewUser(email, password).then((firebaseUser) async {
            sharedPrefsProvider.setSignInMethod(SignInMethod.google);
            sharedPrefsProvider.saveGmailAndPassword(email, password);

            var displayName = googleUser.displayName;

            this.firebaseUser.updateProfile(displayName: displayName).whenComplete(() => this.firebaseUser.reload());

            return firebaseUser;
          });
        }
      }
      return null;
    });
  }

  Future<GoogleSignInAccount> signOutGoogle() => googleSignIn.signOut().whenComplete(() => this.googleSignInAccount = null);
}

final firebaseProvider = FirebaseProvider();
