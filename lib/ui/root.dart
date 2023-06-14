import 'package:expandable_bottom_bar/expandable_bottom_bar.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'scaffolding.dart';
import 'theme.dart';

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('bg'),
        Locale('cs'),
        Locale('de'),
        Locale('es'),
        Locale('fi'),
        Locale('fr'),
        Locale('hi'),
        Locale('hu'),
        Locale('id'),
        Locale('it'),
        Locale('ja'),
        Locale('nl'),
        Locale('pl'),
        Locale('pt', 'BR'),
        Locale('ro'),
        Locale('ru'),
        Locale('sv'),
        Locale('tr'),
        Locale('zh'),
        Locale('en')
      ],
      title: 'Blokada',
      themeMode: ThemeMode.system,
      theme: FlexThemeData.light(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xffFF9400),
            brightness: Brightness.light,
          ),
          primary: const Color(0xffFF9400),
          error: const Color(0xffFF3B30),
          background: Colors.white,
          // textTheme: const TextTheme(
          //   //bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
          //   headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          //   headline2: TextStyle(fontSize: 18.0, fontStyle: FontStyle.normal),
          //   headline3: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          //   headline4: TextStyle(
          //       fontSize: 14.0,
          //       fontWeight: FontWeight.normal,
          //       color: Color(0xffFF9400)),
          // ),
          extensions: <ThemeExtension<dynamic>>{
            const BlokadaTheme(
              bgColor: Color(0xFFF2F1F6),
              bgColorHome1: Color(0xFFC7C7CC),
              bgColorHome2: Color(0xFFC7C7CC),
              bgColorHome3: Color(0xffBDBDBD),
              panelBackground: const Color(0xffF5F7FA),
              cloud: Color(0xFF007AFF),
              plus: Color(0xffFF9400),
              // shadow: const Color(0xffF5F7FA),
              shadow: Color(0xffe8e8e8),
              bgMiniCard: Colors.white,
              textPrimary: Colors.black,
              textSecondary: Colors.black54,
              divider: Colors.black26,
            )
          }),
      darkTheme: FlexThemeData.dark(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xffFF9400),
            brightness: Brightness.dark,
          ),
          primary: const Color(0xffFF9400),
          error: const Color(0xffFF3B30),
          background: Colors.black,
          darkIsTrueBlack: true,
          extensions: <ThemeExtension<dynamic>>{
            const BlokadaTheme(
              bgColor: Color(0xFF000000),
              bgColorHome1: Color(0xFF1A1919),
              bgColorHome2: Color(0xff262626),
              bgColorHome3: Color(0xFF171616),
              panelBackground: const Color(0xff1c1c1e),
              cloud: Color(0xFF007AFF),
              plus: Color(0xffFF9400),
              shadow: Color(0xFF1E1E1E),
              bgMiniCard: Color(0xFF1F1F1F),
              textPrimary: Colors.white,
              textSecondary: Color(0xFF99989F),
              divider: Colors.white24,
            )
          }),
      home: Builder(builder: (context) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaleFactor.clamp(0.8, 1.1);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
          child: I18n(
              child: DefaultBottomBarController(
                  child: const Scaffolding(title: 'Blokada'))),
        );
      }),
    );
  }
}