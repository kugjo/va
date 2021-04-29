import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vocabulary_advancer/app/i18n/strings.g.dart';
import 'package:vocabulary_advancer/app/services/navigation.dart';
import 'package:vocabulary_advancer/app/themes/va_theme.dart';
import 'package:vocabulary_advancer/shared/svc.dart';

class VAApp extends StatefulWidget {
  @override
  _VAAppState createState() => _VAAppState();
}

class _VAAppState extends State<VAApp> {
  final VAThemeId _themeId = VAThemeId.darkCold;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => VATheme(
        _themeId,
        child: TranslationProvider(
          child: MaterialApp(
              theme: _themeId.getMaterialThemeData(),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              supportedLocales: LocaleSettings.supportedLocales,
              navigatorKey: svc.keys.navigationRoot,
              onGenerateRoute: generateRoute),
        ),
      );
}
