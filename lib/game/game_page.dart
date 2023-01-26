import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triangle_chat/game/doodle_dash.dart';
import 'package:triangle_chat/game/util/util.dart';
import 'package:triangle_chat/game/widgets/widgets.dart';

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Triangle Game',
      themeMode: ThemeMode.dark,
      theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
      darkTheme: ThemeData(
          colorScheme: darkColorScheme,
          textTheme: GoogleFonts.audiowideTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true),
      home: const MyGamePage(title: 'Triangl Game'),
    );
  }
}

final Game game = DoodleDash();

class MyGamePage extends StatefulWidget {
  final String title;

  const MyGamePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyGamePage> createState() => _MyGamePageState();
}

class _MyGamePageState extends State<MyGamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            constraints: const BoxConstraints(
              maxWidth: 800,
              minWidth: 550,
            ),
            child: GameWidget(
              game: game,
              overlayBuilderMap: <String, Widget Function(BuildContext, Game)>{
                'gameOverlay': (context, game) => GameOverlay(game),
                'mainMenuOverlay': (context, game) => MainMenuOverlay(game),
                'gameOverOverlay': (context, game) => GameOverOverlay(game),
              },
            ),
          );
        }),
      ),
    );
  }
}
