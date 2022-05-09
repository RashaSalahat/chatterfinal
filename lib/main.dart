import 'package:chatter/app.dart';
import 'package:chatter/screens/screens.dart';
import 'package:chatter/screens/select_user_screen.dart';
import 'package:chatter/screens/splash_screen.dart';
import 'package:chatter/theme.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme.dart';

// we will do authentication :

void main() async {
  final client =
      StreamChatClient(streamKey); // initialized with  our stream key

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase
      .initializeApp(); // you call this before any firebase operations

  runApp(
    MyApp(
      client: client,
      appTheme: AppTheme(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.client,
    required this.appTheme,
  }) : super(key: key);

  final StreamChatClient client;
  final AppTheme appTheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme.light,
      darkTheme: appTheme.dark,
      title: 'Chatter',
      builder: (context, child) {
        // our core widget :
        return StreamChatCore(
          //call method
          client: client,
          child: ChannelsBloc(
            // state for our channel
            child: UsersBloc(
              // state for our users
              child: child!,
            ),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
