import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:flutter/material.dart';
import 'package:prossumidor/pages/home.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:toast/toast.dart';

import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:prossumidor/pages/login.dart';

import 'constantes.dart';

class ProductsDetails extends StatefulWidget {
  final id_sessao;
  final product_detail_id;
  final product_detail_name;
  final product_detail_new_price;
  final product_detail_detalhe;
  final product_detail_marca;
  final product_detail_condicoes;
  final product_detail_picture;
  final product_detail_id_empresa;
  final product_detail_razao_social;
  final product_detail_estoque_atual;
  final product_detail_unidade_medida;

  ProductsDetails({
    this.id_sessao,
    // ignore: non_constant_identifier_names
    this.product_detail_id,
    this.product_detail_name,
    this.product_detail_new_price,
    this.product_detail_detalhe,
    this.product_detail_marca,
    this.product_detail_condicoes,
    this.product_detail_picture,
    this.product_detail_id_empresa,
    this.product_detail_razao_social,
    this.product_detail_estoque_atual,
    this.product_detail_unidade_medida,
  });

  @override
  _ProductsDetailsState createState() => _ProductsDetailsState();
}

class _ProductsDetailsState extends State<ProductsDetails> {
  TabController _tabController;
  int index_tab = 0;
  int quantidade = 1;
  String qtd = "";
  String marca = "";
  double _top = -60, _bottom = -80;

  // app novo

  StreamController<int> streamController = StreamController<int>();
  ScrollController _controller;
  double _percentColor, _percentOpacity;
  Color _color = Colors.white;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _percentColor = .65;
    _percentOpacity = 1;
    streamController.sink.add(quantidade);

    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        _top = 0;
        _bottom = -3;
      });
    });

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _color = kPrimaryColor.withOpacity(.15);
      });
    });

    _controller.addListener(() {
      if (_controller.offset <= 200) {
        setState(() {
          _percentOpacity = 1;
        });
      } else if (_controller.offset <= 400) {
        setState(() {
          _percentOpacity = 1 - (_controller.offset / 400);
        });
      }
    });
    busca_qtd_carrinho().then((resultado) {
      setState(() {});
    });
    buscaMarca().then((resultado) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamController.close();
  }

  Future<bool> onWillPop() async {
    setState(() {
      _top = -60;
      _bottom = -80;
    });
    if (widget.id_sessao == '0') {
      Basicos.pagina = 1;
      Basicos.product_list = [];
      Future.delayed(Duration(milliseconds: 250), () {
        Navigator.of(context).push(MaterialPageRoute(
            // aqui temos passagem de valores id cliente(sessao) de login para home
            builder: (context) => Login()));
      });
    } else {
      Navigator.pop(context, true);
      // Basicos.pagina = 1;
      // Basicos.product_list = [];
      // Future.delayed(Duration(milliseconds: 250), () {
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     // aqui temos passagem de valores id cliente(sessao) de login para home
      //     builder: (context) =>
      //       HomePage1(
      //         id_sessao: widget.id_sessao,
      //       )
      //   )
      // );
      // });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //Color(0xFF012f7a),
        statusBarIconBrightness: Brightness.dark));
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                //app novo--------------------------------------

                CustomScrollView(
                  controller: _controller,
                  slivers: <Widget>[
                    SliverAppBar(
                      elevation: 18,
                      backgroundColor: Colors.white,
                      expandedHeight: 390,
                      pinned: true,
                      floating: false,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        titlePadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
//                          SizedBox(
//                            width: 45 * (1 - _percentOpacity),
//                          ), // to move text and show back button
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: //' # ' +
                                          //'${widget.product_detail_id.toString()}' +
                                          //' -  ' +
                                          '${widget.product_detail_name}\n',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '${widget.product_detail_razao_social}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
//                                  TextSpan(
//                                    text:" R\$20",
//                                    style: Theme.of(context)
//                                        .textTheme
//                                        .headline
//                                        .copyWith(color: kPrimaryColor, fontSize: 19),
//                                  )
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              "R\$${widget.product_detail_new_price.toString().replaceAll('.', ',')}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF012f7a),
                              ),
                            )
                          ],
                        ),
                        collapseMode: CollapseMode.pin,
                        background: Stack(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (_) => Center(
                                            // Aligns the container to center
                                            child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .95,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .7,
                                          color: Colors.transparent,
                                          child: Stack(
                                            children: <Widget>[
                                              Center(
                                                child: Image.network(
                                                  Basicos.ip +
                                                          '/media/' +
                                                          widget
                                                              .product_detail_picture ??
                                                      '${Basicos.ip}/media/estoque/produtos/img/product-01.jpg',
                                                  fit: BoxFit.scaleDown,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 20,
                                                right: 20,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Icon(
                                                    (Icons.fullscreen_exit),
                                                    size: 34,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 10),
                                child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 800),
                                        curve: Curves.easeInOutBack,
                                        margin: EdgeInsets.only(bottom: 30),
                                        padding: EdgeInsets.all(5),
                                        height: 305,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                12,
                                        //305,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            shape: BoxShape.rectangle,
                                            color: Color(
                                                0xFF012f7a) //Color(0xFF012f7a).withOpacity(.3), //_color,
                                            ),
                                        child: Container(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Hero(
                                              tag: Basicos.ip +
                                                  '/media/' +
                                                  widget.product_detail_picture,
                                              child: Image.network(
                                                Basicos.ip +
                                                    '/media/' +
                                                    widget
                                                        .product_detail_picture,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 20,
                              bottom: 90,
                              child: IconButton(
                                icon: Icon(Icons.fullscreen),
                                iconSize: 34,
                                color: Colors.white,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) => Center(
                                              // Aligns the container to center
                                              child: Container(
                                            // A simplified version of dialog.
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .95,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .7,
                                            color: Colors.transparent,
                                            child: Stack(
                                              children: <Widget>[
                                                Center(
                                                  child: Image.network(
                                                    Basicos.ip +
                                                        '/media/' +
                                                        widget
                                                            .product_detail_picture,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 20,
                                                  right: 20,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Icon(
                                                      (Icons.fullscreen_exit),
                                                      size: 34,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                        delegate: SliverChildListDelegate([
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          widget.product_detail_detalhe ?? ' ',
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: Colors.black),
                        ),
                      ),
                      Stack(
                        children: <Widget>[
                          Positioned(
                            bottom: -70,
                            right: -50,
                            child: Opacity(
                              opacity: .2,
                              child: Image.asset(
                                'images/leaf.png',
                                height: 250,
                              ),
                            ),
                          ),
                          DataTable(
                            dataRowHeight: 60,
                            columns: [
                              DataColumn(label: Icon(Icons.info)),
                              DataColumn(label: Icon(Icons.description)),
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(
                                  Text(
                                    'Origem',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                DataCell(Text(
                                  marca ?? ' ',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Condições do Produto',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                )),
                                DataCell(Text(
                                  widget.product_detail_condicoes,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Estoque Atual',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                )),
                                DataCell(Text(
                                  widget.product_detail_estoque_atual,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Unidade',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                )),
                                DataCell(Text(
                                  widget.product_detail_unidade_medida,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                )),
                              ]),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 120),
                    ]))
                  ],
                ),

                AnimatedPositioned(
                  duration: Duration(milliseconds: 250),
                  bottom: _bottom,
                  left: -3,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: Color(
                        0xFFe3e7ed), //Color(0xFFeceff3),//Color(0xFFd3d9e3),//Color(0xFFf8faf8).withOpacity(1),
                    child: Container(
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 60,
                            width: 120,
                            child: Center(
                              child: Container(
                                height: 30,
                                width: 115,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          color:
                                              Color(0xFF012f7a).withOpacity(.4),
                                          shape: BoxShape.rectangle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(.4),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(3,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        if (quantidade > 1) {
                                          quantidade--;
                                          streamController.sink.add(quantidade);
                                        }
                                      },
                                    ),
                                    StreamBuilder<Object>(
                                        stream: streamController.stream,
                                        initialData: 1,
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data.toString(),
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.black,
                                            ),
                                          );
                                        }),
                                    GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          color:
                                              Color(0xFF012f7a).withOpacity(.4),
                                          shape: BoxShape.rectangle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(.4),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(3,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        if (quantidade <
                                            double.parse(widget
                                                .product_detail_estoque_atual)) {
                                          quantidade++;
                                          streamController.sink.add(quantidade);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(color: kPrimaryColor)),
                            color: Color(0xFF012f7a),
                            onPressed: () async {
                              setState(() async {
                                _percentColor = 1;
                                carrinho += 1;
                                //cart.add(widget.product); ===========>cart

                                if (widget.id_sessao.toString() == '0') {
                                  // se nao logado
                                  Basicos.offset = 0; // zera o ofset do banco
                                  Basicos.product_list =
                                      []; // zera o lista de produtos da pagina principal
                                  Basicos.pagina = 1;
                                  //Basicos.buscar_produto_home = ''; // limpa pesquisa
                                  Navigator.of(context)
                                      .push(new MaterialPageRoute(
                                    // aqui temos passagem de valores id cliente(sessao) de login para home
                                    builder: (context) => new Login(),
                                  ));
                                } else {
                                  String result = await insereProduto();
                                  if (result == "sucesso") {
                                    Toast.show(
                                      "Inserido na Cesta de Compras",
                                      context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.CENTER,
                                    );
                                    Basicos.pagina = 1;
                                    Basicos.product_list = [];
                                    Basicos.offset = 0; // zera o ofset do banco
                                    // Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                        new MaterialPageRoute(
                                            // aqui temos passagem de valores id cliente(sessao) de login para home
                                            builder: (context) => new HomePage1(
                                                id_sessao: widget.id_sessao)));
                                  }
                                }
                              });
                              Toast.show(
                                "Adicionado ao carrinho",
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.CENTER,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Incluir na Cesta",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
                            _top = -60;
                            _bottom = -80;
                          });
                          if (widget.id_sessao == '0') {
                            Basicos.pagina = 1;
                            Basicos.product_list = [];
                            Future.delayed(Duration(milliseconds: 250), () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  // aqui temos passagem de valores id cliente(sessao) de login para home
                                  builder: (context) => Login()));
                            });
                          } else {
                            Navigator.pop(context, true);
                            // Basicos.pagina = 1;
                            // Basicos.product_list = [];
                            // Future.delayed(Duration(milliseconds: 250), () {
                            //   Navigator.of(context).push(
                            //     MaterialPageRoute(
                            //       // aqui temos passagem de valores id cliente(sessao) de login para home
                            //       builder: (context) =>
                            //         HomePage1(
                            //           id_sessao: widget.id_sessao,
                            //         )
                            //     )
                            //   );
                            // });
                          }
                        }),
                    radius: 22,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  // busca qt itens na cesta
  Future<String> busca_qtd_carrinho() async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consult19.${widget.id_sessao}");
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    var res = Basicos.decodifica(res1.body); // print(res.body);
    // print(res);
    if (res1.body.length >= 1) {
      if (res1.statusCode == 200) {
        var list = json.decode(res).cast<Map<String, dynamic>>();
        qtd = list[0]["count"].toString();

        return qtd;
      }
    }
  }

  // busca marca
  Future<String> buscaMarca() async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consul-28.${widget.product_detail_marca}");
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    var res = Basicos.decodifica(res1.body); // print(res.body);
    // print(res);
    if (res1.body.length >= 1) {
      if (res1.statusCode == 200) {
        var list = json.decode(res).cast<Map<String, dynamic>>();
        marca = list[0]["descricao"].toString();
        return marca;
      }
    }
  }

// insere Produtos no cesta de compras
  Future<String> insereProduto() async {
    String link = Basicos.codifica("${Basicos.ip}/crud/?crud=consulta6."
        "01/01/2019," // data da venda quando pedido finalizado
        "ATIVO," //status do pedido no cesta
        "${widget.product_detail_new_price}," //valor do item
        "0.0 ," //desconto no item
        "${quantidade}," // quantidade
        "APP," //observacoes do cesta
        "01/01/2019," //data modificação do cesta
        "${widget.id_sessao}," // id cliente
        "${Basicos.empresa_id}," //id empresa
        "${widget.product_detail_id}"); //id produto
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    //print(res1.body);
    var res = Basicos.decodifica(res1.body);
    //print(res);
    if (res1.body.length > 2) {
      if (res1.statusCode == 200) {
        //var list = json.decode(res) as String;
        //print(list);
        return "sucesso";
      }
    }
  }

// botao de diminiur quantida
  void menos() {
    {
      setState(
        () {
          if (quantidade > 1) quantidade--;
        },
      );
    }
    ;
  }

// boatao de somar quantidade
  void adiciona() {
    setState(() {
      quantidade++;
    });
  }
}
