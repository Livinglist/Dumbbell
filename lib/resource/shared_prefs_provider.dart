import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';

import 'package:workout_planner/models/routine.dart';

import 'firebase_provider.dart';

const String AppVersionKey = "appVersion";
const String DailyRankKey = "dailyRank";
const String DatabaseStatusKey = "databaseStatus";
const String WeeklyAmountKey = "weeklyAmount";
const String credentialKey = "credentialKey";
const String emailKey = "emailKey";
const String passwordKey = "passwordKey";
const String gmailKey = "gmailKey";
const String gmailPasswordKey = "gmailPasswordKey";
const String signInMethodKey = "signInMethodKey";

enum SignInMethod {
  apple,
  google,
  none
}

class SharedPrefsProvider {
  Future<SharedPreferences> get sharedPreferences async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    return _sharedPreferences;
  }

  SharedPreferences _sharedPreferences;

  void prepareData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    SharedPreferences prefs = await sharedPreferences;

    ///if true, this is the first time the app is run after installation
    if (prefs.getString(FirstRunDateKey) == null) {
      var dateStr = dateTimeToStringConverter(DateTime.now());

      prefs.setString(FirstRunDateKey, dateStr);

      prefs.setBool(DatabaseStatusKey, false);

      prefs.setInt(WeeklyAmountKey, 3);
    }

    ///if true, this is the first time the app is run after installation/update
    if (prefs.getString(AppVersionKey) == null || prefs.getString(AppVersionKey) != packageInfo.version) {
      prefs.setString(AppVersionKey, packageInfo.version);
      firebaseProvider.isFirstRun = true;
    } else {
      firebaseProvider.isFirstRun = false;
    }
    firebaseProvider.firstRunDate = prefs.getString(FirstRunDateKey);
    //firebaseProvider.dailyRankInfo = prefs.getString(DailyRankKey);
    //firebaseProvider.dailyRank = await getDailyRank();
    //firebaseProvider.weeklyAmount = prefs.getInt(WeeklyAmountKey);
  }

//  void setFirstRunDate() async{
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setInt(FirstRunDateKey, amt);
//    firebaseProvider.weeklyAmount = amt;
//  }

  ///return 0 if haven't workout today
  Future<int> getDailyRank() async {
    SharedPreferences prefs = await sharedPreferences;
    String dailyRankInfo = prefs.getString(DailyRankKey);
    if (dailyRankInfo == null || DateTime.now().day - DateTime.parse(dailyRankInfo.split('/').first).toLocal().day == 1) {
      return 0;
    }
    return int.parse(dailyRankInfo.split('/')[1]);
  }

  void setWeeklyAmount(int amt) async {
    SharedPreferences prefs = await sharedPreferences;
    prefs.setInt(WeeklyAmountKey, amt);
    firebaseProvider.weeklyAmount = amt;
  }

  void setDailyRankInfo(String dailyRankInfo) async {
    SharedPreferences prefs = await sharedPreferences;
    prefs.setString(DailyRankKey, dailyRankInfo);
  }

  void setDatabaseStatus(bool dbStatus) async {
    SharedPreferences prefs = await sharedPreferences;
    prefs.setBool(DatabaseStatusKey, dbStatus);
  }

  Future<bool> getDatabaseStatus() async {
    SharedPreferences prefs = await sharedPreferences;
    return prefs.getBool(DatabaseStatusKey);
  }

  Future<void> saveEmailAndPassword(String email, String password) async {
    print("Saving email and password");
    final sharedPrefs = await sharedPreferences;
    sharedPrefs.setString(emailKey, email);
    sharedPrefs.setString(passwordKey, password);
    return;
  }

  Future<void> saveGmailAndPassword(String email, String password) async {
    print("Saving email and password");
    final sharedPrefs = await sharedPreferences;
    sharedPrefs.setString(gmailKey, email);
    sharedPrefs.setString(gmailPasswordKey, password);
    return;
  }

  void setSignInMethod(SignInMethod signInMethod) async {
    final sharedPrefs = await sharedPreferences;
    int value;
    switch(signInMethod){
      case SignInMethod.apple: value = 0;break;
      case SignInMethod.google: value = 1; break;
      default: throw Exception("Unmatched SignInMethod value");
    }
    sharedPrefs.setInt(signInMethodKey, value);
  }

  ///Get the sign in method last time.
  Future<SignInMethod> getSignInMethod() async {
    final sharedPrefs = await sharedPreferences;
    int value = sharedPrefs.getInt(signInMethodKey);
    return value == null?SignInMethod.none:SignInMethod.values[value];
  }

  Future<String> getString(String key)async{
    final sharedPrefs = await sharedPreferences;
    return sharedPrefs.getString(key);
  }

  void setString(String key, String value) async{
    final sharedPrefs = await sharedPreferences;
    sharedPrefs.setString(key, value);
  }

  void signOut() async {
    sharedPreferences.then((sharedPrefs) => sharedPrefs.remove(credentialKey));
  }
}

final sharedPrefsProvider = SharedPrefsProvider();
