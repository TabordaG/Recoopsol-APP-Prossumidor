import 'package:flutter/material.dart';
import 'package:prossumidor/pages/splash.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:splashscreen/splashscreen.dart';

// meus pacotes

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

void main() {
  debugPaintSizeEnabled = false; // mostra posi;'ao dos widgts no layout
  runApp(MaterialApp(
      builder: (context, child) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return ScrollConfiguration(behavior: MyBehavior(), child: child);
      },
      debugShowCheckedModeBanner: false,
      //home: HomePage1() // função principal monta a pagina inicial
      // home: Login(),
      // home:HomePage1(id_sessao: '76',)
      // home: ChatScreen(id_sessao: 76, ID_Cliente: '76', ID_Produtor: '72'),
      // home: HomePage1(id_sessao: 0),

      home: new SplashScreen(
        seconds: 3,
        navigateAfterSeconds: new Splash(),
        // navigateAfterSeconds: HomePage1(id_sessao: 0,),
        // navigateAfterSeconds: Login(),
        title: new Text(
          'Bem Vindo(a) ao\nRecoopsol',
          style: TextStyle(
            fontSize: 24,
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        image: new Image.asset('images/logo2-2-1.png'),
        backgroundColor: Color(0xFF012f7a),
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        loaderColor: Colors.transparent,
      )));
}
