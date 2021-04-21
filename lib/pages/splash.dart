import 'package:flutter/material.dart';
import 'package:prossumidor/pages/home.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  // AnimationController rotationController;
  String versao = '';
  List usuario = [];
  void initState() {
    // rotationController = AnimationController(
    //   duration: const Duration(milliseconds: 1000),
    //   vsync: this,
    // )..repeat(period: Duration(milliseconds: 500));
    // rotationController = AnimationController(vsync: this, duration: Duration(seconds: 2), upperBound: pi * 2)..repeat(period: Duration(microseconds: 1000));
    // Future.delayed(Duration(milliseconds: 500), (){
    //   rotationController.forward();
    // });
    verifica_logado().then((resultado) {
      setState(() {});
    }); //verifica se houve login e esta armazenado na variavel de preferencias
    super.initState();

    //   SystemChrome.setEnabledSystemUIOverlays([]);

//    Future.delayed(Duration(seconds: 4)).then((_) {
////      Navigator.pushReplacement(
////          context, MaterialPageRoute(builder: (context) => HomePage1(id_sessao: 0,)));
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF012f7a),
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(34),
          //   child: Image(
          //     height: 100,
          //     width: 100,
          //     fit: BoxFit.contain,
          //     image: AssetImage('images/logoverde.png')
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "$versao",
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none),
            ),
          ),
        ],
      ),
    );
  }

  //addStringToSF(String s) async {
//  SharedPreferences prefs1 = await SharedPreferences.getInstance();
//  prefs1.setString('email', s);
//}
//
  getValuesSF() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs1.getString('email') ?? '';
    //final myString = prefs.getString('my_string_key') ?? '';
    return stringValue;
  }

//
//  removeValues() async {
//    SharedPreferences prefs1 = await SharedPreferences.getInstance();
//    prefs1.remove('email');
//  }
  Future<List> verifica_logado() async {
    //verifica versão
    String link0 = Basicos.codifica("${Basicos.ip}/crud/?crud=consult85.*");
//print("${Basicos.ip}/crud/?crud=consult85.*,");
    var res10 = await http
        .get(Uri.encodeFull(link0), headers: {"Accept": "application/json"});
    //var res0 = Basicos.decodifica(res10.body);
    //print('2');
    if (res10.body.length > 2) {
      if (res10.statusCode == 200) {
        //gera criptografia senha terminar depois
        //print('3');
        List listx = json.decode(res10.body).cast<Map<String, dynamic>>();
        versao = listx[0]['id_versao'].toString();
        //print(versao);
      }
    }

    if (versao == '1.0.2') {
      versao = 'Versão: $versao+5';
      final email = await getValuesSF();
      if (email != '') {
        // print(email);
        String link =
            Basicos.codifica("${Basicos.ip}/crud/?crud=consulta1.$email");

        var res1 = await http
            .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
        var res = Basicos.decodifica(res1.body);
        if (res1.body.length > 2) {
          if (res1.statusCode == 200) {
            //gera criptografia senha terminar depois
            List list = json.decode(res).cast<Map<String, dynamic>>();
            usuario = list;
            Basicos.empresa_id = usuario[0]['empresa_id'].toString();
            Basicos.local_retirada_id =
                usuario[0]['local_retirada_id'].toString();
            //print(Basicos.empresa_id );
          }
        }

        Navigator.of(context).push(new MaterialPageRoute(
          // aqui temos passagem de valores id cliente(sessao) de login para home
          builder: (context) =>
              new HomePage1(id_sessao: usuario[0]['id'].toString()),
        ));
      } else {
        Navigator.of(context).push(new MaterialPageRoute(
          // aqui temos passagem de valores id cliente(sessao) de login para home
          builder: (context) => new HomePage1(id_sessao: 0),
        ));
      }
    } else
      versao =
          'Versão Desatualizada, Acesse o Portal\n http://recoopsol.ic.ufmt.br/ ou Atualize';
  }
}
