//import 'package:ajudasobretermos/main.dart';
import 'package:prossumidor/pages/constantes.dart';
import 'package:prossumidor/pages/home.dart';
import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:prossumidor/pages/dados_basicos.dart';

class Sobre extends StatefulWidget {
  final id_sessao;

  Sobre({
    this.id_sessao,
  });

  @override
  _SobreState createState() => _SobreState();
}

class _SobreState extends State<Sobre> {
  @override
  String versao = '';
  double _top = -100;

  void initState() {
    verifica_logado().then((resultado) {
      setState(() {});
    }); //verifica se houve login e esta armazenado na variavel de preferencias
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        _top = 0;
      });
    });
    super.initState();
  }

  Future<bool> onWillPop() async {
    setState(() {
      _top = -100;
    });
    Future.delayed(Duration(milliseconds: 250), () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HomePage1(
                id_sessao: widget.id_sessao,
              )));
    });
    return true;
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          body: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10.0, top: 65, bottom: 15),
              child: Center(
                child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[200],
                          blurRadius:
                              20.0, // has the effect of softening the shadow
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, top: 20, right: 20, bottom: 5),
                            child: Text(
                              'Sobre',
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Aplicativo Recoopsol",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 20,
                                    color: Color(0xFF012f7a),
                                  ),
                                ),
                                SizedBox(height: 30),
                                Text(
                                  "2015-2020 Recoopsol - versão: $versao",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                    color: Color(0xFF012f7a),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 250),
              top: _top,
              child: CircularSoftButton(
                icon: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 28,
                    ),
                    // onPressed: widget.closedBuilder,
                    onPressed: () {
                      setState(() {
                        _top = -100;
                      });
                      Future.delayed(Duration(milliseconds: 250), () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HomePage1(
                                  id_sessao: widget.id_sessao,
                                )));
                      });
                    }),
                radius: 22,
              ),
            ),
          ],
        ),
      )),
    );
  }

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
  }
}
