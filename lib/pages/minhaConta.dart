import 'package:prossumidor/pages/constantes.dart';
import 'package:prossumidor/pages/dados_cadastrais.dart';
import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:flutter/material.dart';
import 'package:prossumidor/pages/home.dart';
import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:prossumidor/pages/entregues.dart';
import 'package:prossumidor/pages/nao_entregues.dart';
import 'package:prossumidor/pages/pagamentos.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'termo.dart';

class minhaConta extends StatefulWidget {
  final id_sessao;

  minhaConta({
    this.id_sessao,
  }); // id_cliente da sessao
  @override
  void initState() {}

  _minhaContaState createState() => _minhaContaState();
}

class _minhaContaState extends State<minhaConta> {
  ScrollController scrollController;
  double _top = -100;
  List client_list = [
    {'email': 'email'},
    {'nome_razao_social': 'nome'}
  ];

  void initState() {
    busca_cliente().then((resultado) {
      setState(() {});
    });
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
    Basicos.pagina = 1;
    Basicos.product_list = [];
    Future.delayed(Duration(milliseconds: 250), () {
      Navigator.of(context).push(MaterialPageRoute(
          // aqui temos passagem de valores id cliente(sessao) de login para home
          builder: (context) => HomePage1(
                id_sessao: widget.id_sessao,
              )));
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              ListView(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 65, right: 20),
                  child: Text(
                    "Minha Conta",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20, top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        elevation: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            color: Colors.white,
                          ),
                          height: 160,
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_shipping,
                                  color: Color(0xFF012f7a),
                                  size: 45,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Compras Entregues',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Finalizadas',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _top = -100;
                              });
                              Basicos.offset = 0;
                              Basicos.meus_pedidos = [];
                              Future.delayed(Duration(milliseconds: 250), () {
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  // aqui temos passagem de valores id cliente(sessao) de login para home
                                  builder: (context) => new Pedidos_Entregues(
                                      id_sessao: widget.id_sessao),
                                ));
                              });
                            },
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        elevation: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            color: Colors.white,
                          ),
                          height: 160,
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.remove_shopping_cart,
                                  color: Color(0xFF012f7a),
                                  size: 45,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Compras Não Entregues',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Canceladas ou Não Finalizadas',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _top = -100;
                              });
                              Basicos.offset = 0;
                              Basicos.meus_pedidos = [];
                              Future.delayed(Duration(milliseconds: 250), () {
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  // aqui temos passagem de valores id cliente(sessao) de login para home
                                  builder: (context) =>
                                      new Pedidos_nao_Entregues(
                                          id_sessao: widget.id_sessao),
                                ));
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        elevation: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            color: Colors.white,
                          ),
                          height: 160,
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: ListTile(
                            //  leading: Icon(Icons.wb_sunny),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.money_off,
                                  color: Color(0xFF012f7a),
                                  size: 45,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Pagamentos',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Recebidos',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _top = -100;
                              });
                              Basicos.offset = 0;
                              Basicos.product_list = [];
                              Basicos.meus_pedidos = [];
                              Future.delayed(Duration(milliseconds: 250), () {
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  // aqui temos passagem de valores id cliente(sessao) de login para home
                                  builder: (context) => new Pagamentos(
                                      id_sessao: widget.id_sessao),
                                ));
                              });
                            },
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        elevation: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            color: Colors.white,
                          ),
                          height: 160,
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_box,
                                  color: Color(0xFF012f7a),
                                  size: 45,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Dados Cadastrais',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Atualizar',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _top = -100;
                              });
                              Future.delayed(Duration(milliseconds: 250), () {
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  // aqui temos passagem de valores id cliente(sessao) de login para home
                                  builder: (context) => new Dados_Cadastrais(
                                      id_sessao: widget.id_sessao),
                                ));
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, top: 15, right: 15, bottom: 15),
                  //  left: 20, top: 10, right: 20, bottom: 20),
                  child: Text(
                    "Meus Dados",
                    //"Simple way to find \nTasty food",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                      ),
                      // height: 75,
                      child: ListTile(
                        leading: Icon(
                          Icons.account_box,
                          color: Color(0xFF012f7a),
                          size: 55,
                        ),
                        title: Text(
                          '${client_list[0]['nome_razao_social'].toString()}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        //

                        subtitle: Text(
                          '${client_list[0]['email'].toString()}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
              AnimatedPositioned(
                duration: Duration(milliseconds: 250),
                top: _top,
                // padding: const EdgeInsets.only(top: 20.0),
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
                        Basicos.pagina = 1;
                        Basicos.product_list = [];
                        Future.delayed(Duration(milliseconds: 250), () {
                          Navigator.of(context).push(MaterialPageRoute(
                              // aqui temos passagem de valores id cliente(sessao) de login para home
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
        ),
        // floatingActionButton: Container(
        //   height: 40,
        //   width: 40,
        //   child: FittedBox(
        //     child: FloatingActionButton(
        //       backgroundColor: Colors.white,
        //       shape: RoundedRectangleBorder(
        //         side: BorderSide(color: Color(0xFF012f7a), width: 2),
        //         borderRadius: BorderRadius.circular(60),
        //       ),
        //       elevation: 60,
        //       child: Icon(Icons.help, color: Color(0xFF012f7a), size: 50,),
        //       onPressed: () async {
        //         const url = "http://recoopsol.ic.ufmt.br/index.php/ajuda-app/";
        //         if (await canLaunch(url)) {
        //           await launch(url);
        //         } else {
        //           throw 'CNão encontrado $url';
        //         }
        //       }
        //     ),
        //   ),
        // ),
      ),
    );
  }

  // busca nome e email do cliente
  Future<List> busca_cliente() async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consult16.${widget.id_sessao}");
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    //print(res.body);
    var res = Basicos.decodifica(res1.body);
    if (res1.body.length > 2) {
      if (res1.statusCode == 200) {
        var list = json.decode(res).cast<Map<String, dynamic>>();
        client_list = list;
        //print(client_list);
        return list;
      }
    }
  }
}
