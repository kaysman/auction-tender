import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Constants {
  static const String _appFontFamily = 'Gilroy';

  static const Color cardBorder = Color(0xffebebeb);
  static const int appBlue = 0xff0057B1;
  static const MaterialColor appPrimarySwatch = MaterialColor(
    appBlue,
    <int, Color>{
      50: Color(0xffe6eef7),
      100: Color(0xffb3cde8),
      200: Color(0xff80abd8),
      300: Color(0xff4d89c8),
      400: Color(0xff3379c1),
      500: Color(appBlue),
      600: Color(0xff004e9f),
      700: Color(0xff00468e),
      800: Color(0xff003d7c),
      900: Color(0xff00346a),
    },
  );

  static ThemeData lightTheme() {
    final typography = Typography.material2014();

    final lightTextTheme = typography.black.apply(
      fontFamily: _appFontFamily,
      displayColor: Color(0xff161616),
      bodyColor: Color(0xff161616),
    );

    return ThemeData(
      brightness: Brightness.light,
      fontFamily: _appFontFamily,
      typography: typography,
      textTheme: lightTextTheme,
      primarySwatch: appPrimarySwatch,
      canvasColor: const Color(0xffeff2f8),
      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: const EdgeInsets.only(left: 12, right: 8),
        labelStyle: TextStyle(fontSize: 14),
        filled: true,
        fillColor: const Color(0xffffffff),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(9.0)),
          borderSide: const BorderSide(color: Colors.grey, width: 0.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(9.0)),
          borderSide: const BorderSide(color: Colors.grey, width: 0.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(9.0)),
          borderSide: const BorderSide(color: Colors.grey, width: 0.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: Color(0xff0057B1).withOpacity(0.8),
          width: 1,
        ),
        primary: Colors.black,
      )),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static const label = "Bäsleşikler we Bäsleşikli söwdalar";

  static String baslesikInfoText =
      "Harytlar, işler we hyzmatlar bilen üpjün edijileri saýlap almak boýunça bäsleşik geçirmek hakynda";

  static String baslesik = "BILDIRIŞ";
  static String auctionTitle =
      "Türkmenistanyň Maliýe we ykdysadyýet ministrligi Türkmenistanyň döwlet eýeçiligindäki desgalary hususylaşdyrmak hakynda kanunçylygyna laýyklykda, döwlet eýeçiligindäki desgalary satmak boýunça bäsleşikli söwdalaryň geçirilýändigini habar berýär.";

  static String baslesikDesc =
      "Ahal welaýatynyň Ak bugdaý etrabynyň Ýaşlyk şäherçesiniň çägindäki kuwwatlylygy bir gije-gündizde 30 000 m3 bolan agyz suwuny arassalaýjy desga üçin gurluşyk harytlaryny we enjamlary satyn almak.";

  static List<String> baslesikResminamalar = [
    "Haýyşnama haty ministrligiň adyna",
    "Ýörite (bäsleşik) ýygymynyň geçirilendigi barada töleg resminamasynyň nusgasy",
    "Ýerli salgyt edaralardan bergi ýoklygy barada kepilnama",
    "Esaslandyryjy resminamalaryň kepillendirilen nusgasy",
    "Ýolbaşçynyň pasport nusgasy",
    "Ygtyýarnamanyň we sertifikatlaryň nusgasy",
    "Soňky maliýe hasabatlylygynyň nusgasy",
    "Mümkin bolan üpjün edijiniň (potratçynyň) täjirçilik teklibi (görnüş 4 nusgada) + 1CD",
    "Harydyň gelip çykyş resminamalary (gümrük beýanamasy ýa-da daşary ýurt kärhanalary bilen baglaşylan we Türkmenistanyň Döwlet haryt-çig mal biržasynda hasaba alnan şertnama, kalkulasiýa we ş.m.)",
    "Türkmenistanda öndürilýän önümleriň, işleriň we hyzmatlaryň bahalary Türkmenistanyň Ykdysadyýet we ösüş ministrliginde ylalaşylmaga degişlidir",
    "Bukjaň içinde goýulýan resminamalaryň ählesiniň elektron nusgasyny goşmaly+1CD"
  ];

  static String baslesikElektron =
      "Bäsleşige gatnaşmak üçin resminamalaryň elektron görnüşi";

  static Map<String, dynamic> docs = {
    "doc1": "Haýyşnama haty (nusga)",
    "doc2": "Täjirçilik teklibi (nusga)",
    "doc3": "Ýörite (bäsleşik) ýygymyny tölemek üçin hasaplaşyk hasaby (nusga)",
  };

  static const double defaultMargin = 12;
  static const double defaultMargin8 = 8;
  static const EdgeInsetsGeometry innerPadding =
      EdgeInsets.symmetric(horizontal: 14, vertical: 10);

  static const String otpMessage =
      "Siziň hasabyňyz aktiwasiýa edilmedik. Siziň telefon nomeriňize ugradylan gizlin kod bilen Aktiwasiýa etmegiňizi haýyş etýäris!";
}

const InputDecoration defaultInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
  border: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(18)),
    borderSide: const BorderSide(color: Colors.grey, width: 0.0),
  ),
  enabledBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(18)),
    borderSide: const BorderSide(color: Colors.grey, width: 0.0),
  ),
  focusedBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(18)),
    borderSide: const BorderSide(color: Colors.grey, width: 0.0),
  ),
);
