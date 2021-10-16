import 'dart:convert';
import 'dart:developer';
import 'models/user.dart';
import 'config/unfocus.dart';
import 'config/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maliye_app/ui/common/index.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/providers/tendor_list.dart';
import 'package:maliye_app/providers/auction_list.dart';
import 'package:maliye_app/providers/index_provider.dart';
import 'package:maliye_app/components/restart_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maliye_app/providers/bookmark_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => IndexProvider()),
          ChangeNotifierProvider(create: (_) => BookmarkProvider()),
          ChangeNotifierProvider(create: (_) => AuctionListProvider()),
          ChangeNotifierProvider(create: (_) => TenderListProvider()),
          ChangeNotifierProvider(create: (_) => ApiAuth()),
        ],
        child: AuctionApp(),
      ),
    ),
  );
}

class AuctionApp extends StatefulWidget {
  @override
  _AuctionAppState createState() => _AuctionAppState();
}

class _AuctionAppState extends State<AuctionApp> {
  @override
  void initState() {
    getUser();
    super.initState();
  }

  getUser() async {
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    var user = prefs.getString("user");
    if (user != null) {
      var userMap = jsonDecode(user);
      log("shared user: " + userMap.toString());
      apiAuth.setUser(User.fromJson(userMap));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auction App',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Unfocus(child: child),
      theme: Constants.lightTheme(),
      home: IndexPage(),
      routes: {'/home': (context) => IndexPage()},
    );
  }
}
