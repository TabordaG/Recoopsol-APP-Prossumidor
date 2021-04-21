import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:flutter/material.dart';
import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:prossumidor/pages/minhaConta.dart';
import 'package:prossumidor/components/pedidos_products.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'constantes.dart';

class Pagamentos extends StatefulWidget {
  final id_sessao;

  Pagamentos({
    this.id_sessao,
  });

  @override
  _Pagamentos createState() => _Pagamentos();
}

class _Pagamentos extends State<Pagamentos> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey(); // snackbar
  double _top = -100;
  // barra de aviso
  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.black,
      duration: Duration(seconds: 2),
    ));
  }

  ScrollController _controller; // controle o listview

  _scrollListener() {
    // recebe o scroll se no inicio ou fim
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        if (Basicos.offset < Basicos.meus_pedidos.length) {
          //atualiza pagina com offset
          Basicos.pagina = _controller.offset;
          // aumenta o offset da consulta no banco
          Basicos.offset = Basicos.offset +
              10; //preenche o grid com a quantidade lida do banco menos dois uma fileira
          // print(_controller.offset);
          //print(Basicos.pagina);
          // _controller.jumpTo(50.0);
          Navigator.of(context).push(new MaterialPageRoute(
            // aqui temos passagem de valores id cliente(sessao) de login para home
            builder: (context) => new Pagamentos(id_sessao: widget.id_sessao),
          ));
        } else
          Basicos.offset = Basicos.meus_pedidos.length;
      });
    }
  }

  @override
  void initState() {
    _controller = ScrollController(
      initialScrollOffset: Basicos.pagina,
    );
    _controller.addListener(_scrollListener);
    listPagamentos().then((resultado) {
      setState(() {});
    });
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        _top = 0;
      });
    });
    new Future.delayed(const Duration(seconds: 1)) //snackbar
        .then((_) => _showSnackBar('Carregando ...')); //snackbar
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  Future<bool> onWillPop() async {
    setState(() {
      _top = -100;
    });
    Basicos.pagina = 1;
    Basicos.product_list = [];
    Future.delayed(Duration(milliseconds: 250), () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => minhaConta(
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
        key: _scaffoldKey, // snackbar
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10.0, top: 65, bottom: 10),
                child: Center(
                  child: Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, top: 20, right: 20, bottom: 5),
                          child: Text(
                            'Pagamentos',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: Basicos.meus_pedidos
                                  .length, //items_entregues.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  child: ListTile(
                                    subtitle: new Column(
                                      children: <Widget>[
                                        // dentro da coluna
                                        Row(
                                          children: <Widget>[
                                            new Text(
                                              "Fornecedor: ",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.0,
                                                  color: Colors.black
                                                      .withOpacity(0.4)),
                                            ),
                                            Expanded(
                                              child: new Text(
                                                Basicos.meus_pedidos[index]
                                                        ["empresa"]
                                                    .toString(),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10.0, 8.0, 8.0, 9.0),
                                              child: new Text(
                                                "Frete:",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            Text(
                                              "R\$" +
                                                  Basicos.meus_pedidos[index]
                                                          ['observacoes_conta']
                                                      .toString()
                                                      .replaceAll('.', ','),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        new Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0,
                                                  right: 3,
                                                  bottom: 0,
                                                  top: 6),
                                              child: new Text(
                                                "Pagamento: ",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0,
                                                    color: Colors.black
                                                        .withOpacity(0.4)),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0,
                                                  right: 5,
                                                  bottom: 0,
                                                  top: 6),
                                              //tanho das letra no lista de produtos
                                              child: new Text(
                                                "#" +
                                                    Basicos.meus_pedidos[index]
                                                            ["id"]
                                                        .toString(),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                    color: Colors.black),
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5,
                                                  right: 3,
                                                  bottom: 0,
                                                  top: 6),
                                              child: new Text(
                                                "Data:",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0,
                                                    color: Colors.black
                                                        .withOpacity(0.4)),
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 2,
                                                  right: 5,
                                                  bottom: 0,
                                                  top: 6),
                                              //tanho das letra no lista de produtos

                                              child: new Text(
                                                inverte_data(Basicos
                                                    .meus_pedidos[index]
                                                        ["data_registro"]
                                                    .substring(0, 10)),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            //===========sessao cor do produto
                                          ],
                                        ),
                                        //============================ sessao preco produto
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0,
                                                  right: 2,
                                                  bottom: 6,
                                                  top: 3),
                                              child: new Text(
                                                "Total+\nFrete:",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0,
                                                    color: Colors.black
                                                        .withOpacity(0.4)),
                                              ),
                                            ),
                                            // new Container(
                                            // alignment: Alignment.topLeft,
                                            //posiciona o texto
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0,
                                                  right: 0,
                                                  bottom: 6,
                                                  top: 3),
                                              child: new Text(
                                                // Basicos.meus_pedidos[index]["valor_conta"].toString().replaceAll('.', ','),
                                                // //"R\$" +
                                                // style: TextStyle(
                                                //   fontSize: 15.0,
                                                //   fontWeight: FontWeight.bold,
                                                //   color: Color(0xFF012f7a),
                                                "R\$ ${(double.parse(Basicos.meus_pedidos[index]["valor_conta"]) + double.parse(Basicos.meus_pedidos[index]["observacoes_conta"])).toStringAsFixed(2).replaceAll('.', ',')}",
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF012f7a),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20,
                                                  right: 2,
                                                  bottom: 6,
                                                  top: 2),
                                              child: new Text(
                                                "Pagamento:",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                    fontSize: 15.0),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8,
                                                    right: 2,
                                                    bottom: 6,
                                                    top: 3),
                                                child: new Text(
                                                  Basicos.meus_pedidos[index]
                                                      ["status_conta"],
                                                  style: TextStyle(
                                                    color: Color(0xFF012f7a),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textScaleFactor: 1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
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
                        Basicos.pagina = 1;
                        Basicos.product_list = [];
                        Future.delayed(Duration(milliseconds: 250), () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => minhaConta(
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
      ),
    );
  }

  // Lista itens
  Future<List> listPagamentos() async {
    String link = Basicos.codifica("${Basicos.ip}"
        "/crud/?crud=consul-27.${widget.id_sessao},10,${Basicos.offset}");
    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    //print(res.body);
    //var res =Basicos.decodifica(res1.body);
    if (res.body.length == 2)
      new Future.delayed(const Duration(seconds: 1)) //snackbar
          .then((_) => _showSnackBar('Sem Pagamentos...'));
    else
      new Future.delayed(const Duration(seconds: 1)) //snackbar
          .then((_) => _showSnackBar('Carregando...')); //snackbar

    if (res.body.length > 2) {
      if (res.statusCode == 200) {
        // converte a lista de consulta em uma lista dinamica
        List list = json.decode(res.body).cast<Map<String, dynamic>>();
        //Meus_pedidos = list;

        // for (var i = 0; i < list.length; i++) Basicos.meus_pedidos.add(list[i]);
        for (var i = 0; i < list.length; i++) {
          if (list[i]['observacoes_conta'].toString() == ' ')
            list[i]['observacoes_conta'] = '0';
          Basicos.meus_pedidos.add(list[i]);
        }
        //print(list);
        return list;
      }
    }
  }
}

//converte data em ingles para padrao brasileiro
String inverte_data(substring) {
  String temp = '';
  //print(substring);
  temp = substring[8] + substring[9];
  temp = temp + '-' + substring[5] + substring[6];
  temp = temp + '-' + substring.toString().substring(0, 4);
  return temp;
}
