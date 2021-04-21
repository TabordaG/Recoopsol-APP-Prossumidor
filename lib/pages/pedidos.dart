import 'package:animations/animations.dart';
import 'package:prossumidor/chat/chats.dart';
import 'package:prossumidor/pages/constantes.dart';
import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:flutter/material.dart';
import 'package:prossumidor/components/pedidos_products.dart';
import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:prossumidor/pages/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:toast/toast.dart';

double _top = -100;

class MeusPedidos extends StatefulWidget {
  final id_sessao;

  @override
  _MeusPedidosState createState() => _MeusPedidosState();

  MeusPedidos({
    this.id_sessao,
  });
}

class _MeusPedidosState extends State<MeusPedidos> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey(); // snackbar
  StreamController pedidosStream;
  double qtd_chat = 0; //quantidade de msg no chat
  // barra de aviso
  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.black,
      duration: Duration(milliseconds: 800),
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

          listPedidos();
        } else
          Basicos.offset = Basicos.meus_pedidos.length;
      });
    }
  }

  @override
  void initState() {
    if (!indexBottom[2]) {
      setState(() {
        indexBottom[0] = false;
        indexBottom[1] = false;
        indexBottom[2] = true;
      });
    }
    pedidosStream = StreamController();
    busca_msg_chat();
    _controller = ScrollController(
      initialScrollOffset: Basicos.pagina,
    );
    _controller.addListener(_scrollListener);
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        _top = 0;
      });
    });
    listPedidos().then((resultado) {
      setState(() {});
    });

    new Future.delayed(const Duration(seconds: 1)) //snackbar
        .then((_) => _showSnackBar('Carregando ...')); //snackbar

    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    pedidosStream.close();
    super.dispose();
  }

  Future<bool> onWillPop() async {
    setState(() {
      _top = -100;
    });
    Basicos.offset = 0;
    Basicos.pagina = 1;
    Basicos.product_list = [];
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
        key: _scaffoldKey, // snackbar
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10.0, top: 65, bottom: 60),
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
                            'Meus Pedidos',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                            child: StreamBuilder(
                                stream: pedidosStream.stream,
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    default:
                                      List meusPedidos = snapshot.data;
                                      return Scrollbar(
                                        child: ListView.builder(
                                            controller: _controller,
                                            itemCount:
                                                Basicos.meus_pedidos.length,
                                            itemBuilder: (context, index) {
                                              return Pedidos(
                                                sessao: widget.id_sessao,
                                                pedido_numero:
                                                    meusPedidos[index]["id"]
                                                        .toString(),
                                                pedido_status:
                                                    meusPedidos[index]
                                                        ["status_pedido"],
                                                pedido_qtd: meusPedidos[index]
                                                    ["quantidade"],
                                                pedido_data: meusPedidos[index]
                                                    ["data_registro"],
                                                data_entrega: meusPedidos[index]
                                                    ['data_entrega'],
                                                pedido_total: meusPedidos[index]
                                                    ["valor_total"],
                                                //cart_prod_picture: Product_on_the_cart[index]["foto"],
                                                empresa: meusPedidos[index]
                                                    ['empresa'],
                                                id_empresa: meusPedidos[index]
                                                    ['id_empresa'],
                                                observacoes_entrega:
                                                    meusPedidos[index]
                                                        ['observacoes_entrega'],
                                              );
                                            }),
                                      );
                                  }
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                child: Hero(
                  tag: 'bottombar',
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: Color(
                        0xFFe3e7ed), //Color(0xFFeceff3),//Color(0xFFd3d9e3),//Color(0xFFf8faf8).withOpacity(1),
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.home,
                              color: indexBottom[0]
                                  ? Color(0xFF012f7a)
                                  : Colors.black26,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                _top = -100;
                              });
                              if (!indexBottom[0]) {
                                setState(() {
                                  indexBottom[0] = true;
                                  indexBottom[1] = false;
                                  indexBottom[2] = false;
                                });
                              }
                              Basicos.offset = 0; // zera o ofset do banco
                              Basicos.product_list =
                                  []; // zera o lista de produtos da pagina principal
                              Basicos.pagina = 1;
                              //Basicos.buscar_produto_home = ''; // limpa pesquisa
                              Future.delayed(Duration(milliseconds: 250), () {
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  // aqui temos passagem de valores id cliente(sessao) de login para home

                                  builder: (context) => new HomePage1(
                                      id_sessao: widget.id_sessao),
                                ));
                              });
                            },
                          ),
                          IconButton(
                            icon: Stack(
                              children: [
                                Center(
                                    child: Icon(
                                  Icons.chat,
                                  color: indexBottom[1]
                                      ? Color(0xFF012f7a)
                                      : Colors.black26,
                                  size: 30,
                                )),
                                qtd_chat > 0
                                    ? Positioned(
                                        bottom: 2,
                                        right: 0,
                                        child: Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            onPressed: () {
                              setState(() {
                                _top = -100;
                              });
                              if (!indexBottom[1]) {
                                setState(() {
                                  indexBottom[0] = false;
                                  indexBottom[1] = true;
                                  indexBottom[2] = false;
                                });
                              }
                              Basicos.offset = 0; // zera o ofset do banco
                              Basicos.product_list =
                                  []; // zera o lista de produtos da pagina principal
                              Basicos.pagina = 1;
                              //Basicos.buscar_produto_home = ''; // limpa pesquisa
                              Future.delayed(Duration(milliseconds: 250), () {
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  // aqui temos passagem de valores id cliente(sessao) de login para home
                                  builder: (context) => new ChatsPage(
                                      id_sessao: widget.id_sessao),
                                ));
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.assessment,
                              color: indexBottom[2]
                                  ? Color(0xFF012f7a)
                                  : Colors.black26,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                _top = -100;
                              });
                              if (!indexBottom[2]) {
                                setState(() {
                                  indexBottom[0] = false;
                                  indexBottom[1] = false;
                                  indexBottom[2] = true;
                                });
                              }
                              Basicos.pagina = 1;
                              Basicos.offset = 0;
                              Basicos.product_list = [];
                              Basicos.meus_pedidos = [];
                              //Basicos.buscar_produto_home = ''; // limpa pesquisa
                              Future.delayed(Duration(milliseconds: 250), () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => new MeusPedidos(
                                            id_sessao: widget.id_sessao)));
                              });
                            },
                          ),
                        ],
                      ),
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
                      onPressed: () {
                        setState(() {
                          _top = -100;
                        });
                        Basicos.offset = 0;
                        Basicos.pagina = 1;
                        Basicos.product_list = [];
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
        ),
      ),
    );
  }

  // Lista itens do cesta
  Future<List> listPedidos() async {
    String link = Basicos.codifica("${Basicos.ip}"
        "/crud/?crud=consult14.${widget.id_sessao},10,${Basicos.offset}");
    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    //print(res.body);
    //var res =Basicos.decodifica(res1.body);
    if (res.body.length > 2) {
      if (res.statusCode == 200) {
        // converte a lista de consulta em uma lista dinamica
        List list = json.decode(res.body).cast<Map<String, dynamic>>();
        //Meus_pedidos = list;

        for (var i = 0; i < list.length; i++) {
          if (list[i]['observacoes_entrega'].toString() == ' ')
            list[i]['observacoes_entrega'] = '0';
          Basicos.meus_pedidos.add(list[i]);
        }
        print(Basicos.meus_pedidos.length);
        pedidosStream.sink.add(Basicos.meus_pedidos);
        //print(list);
        return list;
      }
    }
  }

  Future<double> busca_msg_chat() async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consult81.${widget.id_sessao}");
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    var res = Basicos.decodifica(res1.body); // print(res.body);
    // print(res);
    if (res1.body.length >= 1) {
      if (res1.statusCode == 200) {
        var list = json.decode(res).cast<Map<String, dynamic>>();
        String chat = list[0]["count"].toString();
        //   print(qtd);
        if (chat.toString() == '0') {
          setState(() {
            qtd_chat = 0;
          });
        } else {
          setState(() {
            qtd_chat = 1;
          });
        }
        return qtd_chat;
      }
    }
  }
}

class Pedidos extends StatefulWidget {
  final sessao;
  final pedido_numero;

  //final cart_prod_picture;
  final pedido_total;
  final pedido_data;
  final data_entrega;
  final pedido_status;
  final pedido_qtd;
  final empresa;
  final id_empresa;
  final observacoes_entrega;

  Pedidos({
    this.sessao,
    this.pedido_numero,
    this.pedido_status,
    // this.cart_prod_picture,
    this.pedido_total,
    this.pedido_qtd,
    this.pedido_data,
    this.data_entrega,
    this.empresa,
    this.id_empresa,
    this.observacoes_entrega,
  });

  @override
  _PedidosState createState() => _PedidosState();
}

class _PedidosState extends State<Pedidos> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedBuilder: (context, action) {
        return Card(
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      "Num Pedido: ",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      widget.pedido_numero,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  children: [
                    Text(
                      "Fornecedor: ",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      widget.empresa,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            //=============== subttitulo da sessao
            subtitle: Column(
              children: <Widget>[
                // dentro da coluna
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                          child: Text(
                            "Data:",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Text(
                          inverte_data(
                              widget.pedido_data.toString().substring(0, 10)),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    //===========sessao cor do produto
                    Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 9.0),
                          child: new Text(
                            "Qtd:",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Text(
                          "${widget.pedido_qtd.toString().substring(0, widget.pedido_qtd.toString().indexOf('.', 0))}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 9.0),
                          child: new Text(
                            "Frete:",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Text(
                          "R\$ ${widget.observacoes_entrega.toString().replaceAll('.', ',')}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //============================ sessao preco produto
                Row(
                  children: [
                    Text(
                      "Entrega: ",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      inverte_data(
                          widget.data_entrega.toString().substring(0, 10)),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Wrap(
                      children: [
                        Text(
                          " Total+Frete: ",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "R\$ ${(double.parse(widget.pedido_total) + double.parse(widget.observacoes_entrega)).toStringAsFixed(2).replaceAll('.', ',')}    ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(children: [
                  Wrap(
                    direction: Axis.horizontal,
                    children: [
                      Text(
                        "Situação: ",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        "${widget.pedido_status}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF012f7a),
                        ),
                        textScaleFactor: 0.9,
                      ),
                    ],
                  ),
                ]),

                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          // user must tap button for close dialog!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Enviar Uma Menssagem ao Vendedor: ' +
                                    '${widget.empresa}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              content: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  color: Color(
                                      0xFFeceff3), //Color(0xFFf8faf8).withOpacity(1),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: TextField(
                                            maxLength: 224,
                                            controller: _controller,
                                            decoration: InputDecoration(
                                              hintText: 'Enviar Mensagem',
                                              counterText: "",
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.send,
                                          color: Color(0xFF012f7a),
                                        ),
                                        onPressed: () {
                                          if (_controller.text.isNotEmpty) {
                                            setState(() {
                                              _top = -100;
                                            });
                                            _sendMessage(
                                                _controller.text,
                                                widget.id_empresa,
                                                widget.sessao);

                                            Basicos.offset = 0;
                                            Basicos.product_list = [];
                                            Basicos.meus_pedidos = [];
                                            Future.delayed(
                                                Duration(milliseconds: 200),
                                                () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatsPage(
                                                          id_sessao:
                                                              widget.sessao),
                                                ),
                                              );
                                            });
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(
                                    'Cancelar',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF012f7a),
                                    ),
                                  ),
                                  onPressed: () {
                                    _controller.text = '';
                                    Navigator.of(context).pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: new Text(
                        "Falar com Vendedor",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      color: Color(0xFF012f7a),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: MaterialButton(
                        onPressed: () {
                          widget.pedido_status == 'EM ANDAMENTO'
                              ? showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Cancelar Pedido',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      content: Text(
                                        'Deseja mesmo cancelar seu pedido ?',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text(
                                            'Voltar',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF012f7a),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop(context);
                                          },
                                        ),
                                        FlatButton(
                                          child: Text(
                                            'Confirmar',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF012f7a),
                                            ),
                                          ),
                                          onPressed: () {
                                            grava_status(widget.pedido_numero,
                                                'CANCELADO');
                                            Toast.show(
                                                "Atualizando Situação \n do Pedido: " +
                                                    widget.pedido_numero,
                                                context,
                                                duration: Toast.LENGTH_LONG,
                                                gravity: Toast.CENTER,
                                                backgroundRadius: 0.0);
                                            Basicos.offset = 0;
                                            Basicos.product_list = [];
                                            Basicos.meus_pedidos = [];
                                            Future.delayed(
                                                Duration(milliseconds: 200),
                                                () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MeusPedidos(
                                                          id_sessao:
                                                              widget.sessao),
                                                ),
                                              );
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        content: Text(
                                          'A situação do seu pedido não permite mais o cancelamento.',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text(
                                              'Cancelar',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Color(0xFF012f7a),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(context);
                                            },
                                          ),
                                        ]);
                                  },
                                );
                        },
                        child: Text(
                          "Cancelar",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        color: widget.pedido_status == 'EM ANDAMENTO'
                            ? Colors.red[900]
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
      openBuilder: (BuildContext context, VoidCallback _) {
        return Pedidos_products(
          'pedidos',
          id_pedido: widget.pedido_numero,
          id_sessao: widget.sessao,
        );
      },
    );
  }

  String inverte_data(substring) {
    String temp = '';
    //print(substring);
    temp = substring[8] + substring[9];
    temp = temp + '-' + substring[5] + substring[6];
    temp = temp + '-' + substring.toString().substring(0, 4);
    return temp;
  }

  Future<List> _sendMessage(String text, _id_produtor, _id_cliente) async {
    // insere no banco de dados
    //Inserir mensagem ###############################################
    String link2 = Basicos.codifica("${Basicos.ip}/crud/?crud=consult74."
        "${Basicos.strip(text)}," //    msg text NOT NULL,
        "Cliente-Produtor,"
        "Enviado,"
        //    data_envio timestamp with time zone NOT NULL,
        //    data_leitura timestamp with time zone NOT NULL,
        "${_id_cliente}," //    cliente_id integer NOT NULL,
        "${_id_produtor}," //    produtor_id integer NOT NULL,
        );

    // print("${Basicos.ip}/crud/?crud=consult74."
    //     "${Basicos.strip(text)}," //    msg text NOT NULL,
    //     "Cliente-Produtor,"
    //     "Enviado,"
    //     //    data_envio timestamp with time zone NOT NULL,
    //     //    data_leitura timestamp with time zone NOT NULL,
    //     "${_id_cliente}," //    cliente_id integer NOT NULL,
    //     "${_id_produtor},");

    var res2 = await http
        .get(Uri.encodeFull(link2), headers: {"Accept": "application/json"});
    var res3 = Basicos.decodifica(res2.body);
  }

  Future<String> grava_status(final numero_pedido, final situacao) async {
    String link = Basicos.codifica("${Basicos.ip}"
        "/crud/?crud=consult30.${numero_pedido},${situacao}");
    //print(situacao);
    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    print(res.statusCode);
    //var res =Basicos.decodifica(res1.body);
    if (res.body.length > 2) {
      if (res.statusCode == 200) {
        // converte a lista de consulta em uma lista dinamica
        //  List list = json.decode(res.body).cast<Map<String, dynamic>>();
        //Meus_pedidos = list;

        // for (var i = 0; i < list.length; i++) Basicos.meus_pedidos.add(list[i]);

        return 'sucesso';
      }
    }
  }
}
