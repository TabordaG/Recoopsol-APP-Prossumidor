import 'dart:async';
import 'dart:convert';
import 'package:prossumidor/pages/home.dart';
import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'constantes.dart';
import 'dados_basicos.dart';

List<Pedido> pedidos;
double total = 0;
double frete = 0;
double _retirarfrete = 0;
bool initialSet;

class CartScreen extends StatefulWidget {
  final id_sessao;
  final marquee;

  CartScreen({this.id_sessao, this.marquee});
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  StreamController<List<Pedido>> _streamControllerPedido;
  ScrollController scrollController = ScrollController();
  SlidableController slidableController = SlidableController();
  List<Food> cart = [];
  List Product_on_the_cart = [];
  double _top = -100;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey(); // snackbar
  GlobalKey _toolTipKey = GlobalKey();
  bool _retirar = false;
  @override
  void initState() {
    super.initState();
    initialSet = true;
    pedidos = [];
    total = 0;
    frete = 0;
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        _top = 0;
      });
    });

    _carregarProdutos().then((resultado) {
      setState(() {});
    });
    //_carregarProdutos();
    //print(pedidos.length);
  }

  void dispose() {
    super.dispose();
    _streamControllerPedido.close();
  }

  _carregarProdutos() async {
    _streamControllerPedido = StreamController<List<Pedido>>();
    pedidos = await obterPedidos();
    _streamControllerPedido.sink.add(pedidos);
  }

  Future<bool> onWillPop() async {
    setState(() {
      _top = -100;
    });
    Future.delayed(Duration(milliseconds: 250), () {
      Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => new HomePage1(id_sessao: widget.id_sessao),
      ));
    });
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 65, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: "Meu Carrinho\n",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: "Total ${cart.length} itens",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final dynamic tooltip = _toolTipKey.currentState;
                            tooltip.ensureTooltipVisible();
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Tooltip(
                                key: _toolTipKey,
                                margin: EdgeInsets.symmetric(horizontal: 30),
                                padding: EdgeInsets.all(10),
                                message: widget.marquee,
                                decoration: BoxDecoration(
                                  color: Color(0xFFa5a5a5).withOpacity(.8),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(.6),
                                      spreadRadius: 6,
                                      blurRadius: 7,
                                      offset: Offset(
                                          3, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                textStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                child:
                                    Icon(Icons.info, color: Color(0xFF012f7a)),
                              ),
                              Text(
                                'Informações\nde Entrega',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                  color: Colors.black.withOpacity(.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Expanded(
                    child: StreamBuilder(
                        stream: _streamControllerPedido.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError || !snapshot.hasData)
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          List<Pedido> cestas = snapshot.data;
                          if (cestas.length == 0) {
                            return Center(
                              child: Text(
                                'Carrinho Vazio',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return Center(child: Text('Não conectado'));
                            case ConnectionState.waiting:
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            default:
                              return ListView(
                                controller: scrollController,
                                shrinkWrap: true,
                                children: [
                                  for (Pedido item in cestas)
                                    Column(children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20.0),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            'Produtor: ${item.produtor}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color:
                                                  Colors.black.withOpacity(.8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        thickness: .5,
                                        indent: 20,
                                        endIndent: 80,
                                      ),
                                      Container(
                                        height: 110.0 * item.produtos.length,
                                        child: ListView.builder(
                                            controller: scrollController,
                                            shrinkWrap: true,
                                            itemCount: item.produtos.length,
                                            itemBuilder: (context, index2) {
                                              return Slidable(
                                                key: Key(item
                                                    .produtos[index2].title),
                                                controller: slidableController,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20.0),
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          // Navigator.push(
                                                          //   context,
                                                          //   PageRouteBuilder(
                                                          //     pageBuilder: (BuildContext context, _, __) {
                                                          //       return DetailsScreen(item.produtos[index2]);
                                                          //     },
                                                          //   )
                                                          // );
                                                        },
                                                        child: Container(
                                                          width: 100,
                                                          height: 110,
                                                          child: Stack(
                                                            children: [
                                                              Positioned(
                                                                bottom: 10,
                                                                left: 0,
                                                                child:
                                                                    Container(
                                                                  width: 90,
                                                                  height: 90,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: item
                                                                        .produtos[
                                                                            index2]
                                                                        .color
                                                                        .withOpacity(
                                                                            .4),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8)),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 0,
                                                                right: 0,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              15)),
                                                                  // child: Image.network(get_picture(item.produtos[index2].image), fit: BoxFit.contain, height: 90, width: 90,),
                                                                  child: Image
                                                                      .network(
                                                                    Basicos.ip +
                                                                        '/media/' +
                                                                        item.produtos[index2]
                                                                            .image,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    height: 90,
                                                                    width: 90,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20,
                                                                        bottom:
                                                                            5),
                                                                child: Text(
                                                                  item
                                                                      .produtos[
                                                                          index2]
                                                                      .title,
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              Container(
                                                                height: 30,
                                                                width: 115,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    GestureDetector(
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            EdgeInsets.all(2),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(8)),
                                                                          color:
                                                                              Color(0xFF012f7a).withOpacity(.8),
                                                                          shape:
                                                                              BoxShape.rectangle,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.grey.withOpacity(.2),
                                                                              spreadRadius: 5,
                                                                              blurRadius: 7,
                                                                              offset: Offset(3, 3), // changes position of shadow
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Icon(
                                                                            Icons.remove,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        if (item.produtos[index2].quantidade >
                                                                            1) {
                                                                          int index =
                                                                              Product_on_the_cart.indexWhere(
                                                                            (element) =>
                                                                                element['descricao_simplificada'] == item.produtos[index2].title &&
                                                                                item.produtos[index2].idProdutor == element['id'],
                                                                          );
                                                                          //print(index);
                                                                          String
                                                                              link =
                                                                              Basicos.codifica("${Basicos.ip}/crud/?crud=consult13."
                                                                                  "${Product_on_the_cart[index]["id"]}"); //id_produto_cart
                                                                          //print(link);
                                                                          var res1 = await http.get(
                                                                              Uri.encodeFull(link),
                                                                              headers: {
                                                                                "Accept": "application/json"
                                                                              });
                                                                          var res =
                                                                              Basicos.decodifica(res1.body);
                                                                          if (res1.body.length >
                                                                              2) {
                                                                            if (res1.statusCode ==
                                                                                200) {
                                                                              // var list = json.decode(res.body) as String;
                                                                            }
                                                                          }
                                                                          setState(
                                                                              () {
                                                                            item.produtos[index2].quantidade--;
                                                                            total -=
                                                                                item.produtos[index2].price;
                                                                            // calculaFrete(
                                                                            //     total);
                                                                            // carrinho -= 1;  // Esse carrinho, é a variável que tem no arquivo constants.dart, ele serve para mostrar lá no Home quantos itens tem no carrinho.
                                                                          });
                                                                        }
                                                                      },
                                                                    ),
                                                                    Text(
                                                                      item
                                                                          .produtos[
                                                                              index2]
                                                                          .quantidade
                                                                          .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              15,
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(.8)),
                                                                    ),
                                                                    GestureDetector(
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            EdgeInsets.all(2),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(8)),
                                                                          color:
                                                                              Color(0xFF012f7a).withOpacity(.8),
                                                                          shape:
                                                                              BoxShape.rectangle,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.grey.withOpacity(.2),
                                                                              spreadRadius: 5,
                                                                              blurRadius: 7,
                                                                              offset: Offset(3, 3), // changes position of shadow
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Icon(
                                                                            Icons.add,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        int index =
                                                                            Product_on_the_cart.indexWhere(
                                                                          (element) =>
                                                                              element['descricao_simplificada'] == item.produtos[index2].title &&
                                                                              item.produtos[index2].idProdutor == element['id'],
                                                                        );
                                                                        String
                                                                            link =
                                                                            Basicos.codifica("${Basicos.ip}/crud/?crud=consult12."
                                                                                "${Product_on_the_cart[index]["id"]}"); //id_produto_cart
                                                                        //print(link);
                                                                        var res1 = await http.get(
                                                                            Uri.encodeFull(link),
                                                                            headers: {
                                                                              "Accept": "application/json"
                                                                            });
                                                                        var res =
                                                                            Basicos.decodifica(res1.body);
                                                                        if (res1.body.length >
                                                                            2) {
                                                                          if (res1.statusCode ==
                                                                              200) {
                                                                            // var list = json.decode(res.body) as String;
                                                                          }
                                                                        }
                                                                        setState(
                                                                            () {
                                                                          item.produtos[index2]
                                                                              .quantidade++;
                                                                          total =
                                                                              total + item.produtos[index2].price;
                                                                          // calculaFrete(
                                                                          //     total);
                                                                          // carrinho += 1;  // Esse carrinho, é a variável que tem no arquivo constants.dart, ele serve para mostrar lá no Home quantos itens tem no carrinho.
                                                                        });
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 25),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  '*Valor unit',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            .8),
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                'R\$${item.produtos[index2].price.toStringAsFixed(2)}',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ]),
                                                      ),
                                                      Container(
                                                        height: 110,
                                                        width: 5,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    12.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    12.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actionPane:
                                                    SlidableDrawerActionPane(),
                                                secondaryActions: <Widget>[
                                                  IconSlideAction(
                                                    color: Colors.red,
                                                    icon: Icons.delete,
                                                    onTap: () async {
                                                      // print('Index:');
                                                      int index =
                                                          Product_on_the_cart
                                                              .indexWhere(
                                                        (element) =>
                                                            element['descricao_simplificada'] ==
                                                                item
                                                                    .produtos[
                                                                        index2]
                                                                    .title &&
                                                            item
                                                                    .produtos[
                                                                        index2]
                                                                    .idProdutor ==
                                                                element['id'],
                                                      );
                                                      //print(index);
                                                      //remove os itens da cesta de compras
                                                      String link = Basicos.codifica(
                                                          "${Basicos.ip}/crud/?crud=consult11."
                                                          "${Product_on_the_cart[index]["id"]}"); //id_produto_cart
                                                      //print(link);
                                                      var res1 = await http.get(
                                                          Uri.encodeFull(link),
                                                          headers: {
                                                            "Accept":
                                                                "application/json"
                                                          });
                                                      var res =
                                                          Basicos.decodifica(
                                                              res1.body);
                                                      // print(res);
                                                      // print(res1.statusCode);
                                                      if (res1.body.length >
                                                          2) {
                                                        if (res1.statusCode ==
                                                            200) {
                                                          // var list = json.decode(res.body) as String;
                                                          // var list = json.decode(res.body) as String;
                                                        }
                                                      }
                                                      setState(() {
                                                        // carrinho -= item.produtos[index2].quantidade.toInt();  // Esse carrinho, é a variável que tem no arquivo constants.dart, ele serve para mostrar lá no Home quantos itens tem no carrinho.
                                                        total = total -
                                                            item
                                                                    .produtos[
                                                                        index2]
                                                                    .price *
                                                                item
                                                                    .produtos[
                                                                        index2]
                                                                    .quantidade;
                                                        Product_on_the_cart
                                                            .removeAt(index);
                                                        cart.remove(item
                                                            .produtos[index2]);
                                                        cestas.remove(item
                                                            .produtos[index2]);
                                                        item.produtos.remove(
                                                            item.produtos[
                                                                index2]);
                                                        calculaFrete2(
                                                            widget.id_sessao,
                                                            cart);
                                                      });
                                                      // print(carrinho);
                                                      //print(Product_on_the_cart.length);
                                                      //print(cart.length);
                                                      // print(cestas.length);
                                                      if (item.produtos
                                                              .length ==
                                                          0) {
                                                        setState(() {
                                                          cestas.remove(item);
                                                        });
                                                      }
                                                      // Navigator.push(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //       builder: (context) => CartScreen(
                                                      //           id_sessao: widget.id_sessao)));
                                                    },
                                                  ),
                                                ],
                                              );
                                            }),
                                      ),
                                    ]),
                                ],
                              );
                          }
                        }),
                  ),
                  Divider(
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Local",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 80,
                          child: Text(
                            "Taxa de Entrega: R\$${frete.toStringAsFixed(2)}",
                            textAlign: TextAlign.right,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _retirar
                              ? "Retirar no Local"
                              : "Entrega em Domicílio",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black.withOpacity(.8)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)),
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                value: _retirar,
                                onChanged: (bool value) {
                                  setState(() {
                                    _retirar = value;
                                    if (value) {
                                      _retirarfrete = frete;
                                      frete = 0.0;
                                    } else
                                      frete = _retirarfrete;
                                  });
                                },
                              ),
                              Text(
                                "Retirar \nno Local ",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Total: ',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          // total mais frete
                          'R\$${(total + frete).toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20, left: 20, bottom: 15),
                    child: FlatButton(
                      color: Color(0xFF012f7a),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      onPressed: () async {
                        setState(() async {
                          // carrinho += 1;
                          //cart.add(widget.product); ===========>cart

                          if (Product_on_the_cart.length == 0) {
                            {
                              return showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(22.0))),
                                      contentPadding:
                                          EdgeInsets.only(top: 10.0),
                                      content: Container(
                                        width: 300.0,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  "Cesta Vazia",
                                                  style:
                                                      TextStyle(fontSize: 24.0),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            Divider(
                                              color: Colors.grey,
                                              height: 4.0,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 30.0, right: 30.0),
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "Insira um item ...?",
                                                  border: InputBorder.none,
                                                ),
                                                maxLines: 8,
                                              ),
                                            ),
                                            InkWell(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    top: 10.0, bottom: 10.0),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF012f7a),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  22.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  22.0)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    FlatButton(
                                                      //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                      child: const Text(
                                                        'Cancela',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                //                                    Text(
                                                //                                      "Rate Product",
                                                //                                      style: TextStyle(color: Colors.white),
                                                //                                      textAlign: TextAlign.center,
                                                //                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              // user must tap button for close dialog!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(22.0))),
                                  contentPadding: EdgeInsets.only(top: 10.0),
                                  title: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text('Confirmar Pedido?'),
                                      Divider(
                                        color: Colors.grey,
                                        height: 4.0,
                                      ),
                                    ],
                                  ),
                                  content: Container(
                                    //color: Colors.red,
                                    height: MediaQuery.of(context).size.height,
                                    width:
                                        300, // MediaQuery.of(context).size.width,

                                    child: ListTile(
                                      title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              " Como Pretende Pagar ao Retirar o Pedido ?\n",
                                              textAlign: TextAlign.left,
                                              textScaleFactor: 1.0,
                                            ),
                                            Container(
                                                alignment: Alignment.centerLeft,
                                                // margin: EdgeInsets.symmetric(vertical: 210, horizontal: 20),
                                                //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    300,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF012f7a)
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                      color: kBorderColor),
                                                ),
                                                child: MyDialog()),
                                          ]),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.only(
                                          top: 0.0, bottom: 0.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF012f7a),
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(22.0),
                                            bottomRight: Radius.circular(22.0)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          FlatButton(
                                            child: const Text(
                                              'Cancelar',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(context);
                                            },
                                          ),
                                          FlatButton(
                                            child: const Text(
                                              'Confirmar',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            onPressed: () async {
                                              if (Parametro.tipo_pagamento !=
                                                  "") {
                                                //CircularProgressIndicator;
                                                //                                  Toast.show("Aguarde....", context,
                                                //                                      duration: Toast.LENGTH_SHORT,
                                                //                                      gravity: Toast.CENTER,
                                                //                                      backgroundRadius: 0.0);
                                                circular('inicio');
                                                String resultado =
                                                    await insere_pedido(
                                                        Parametro
                                                            .tipo_pagamento);
                                                circular('fim');
                                                if (resultado == 'sucesso') {
                                                  Toast.show(
                                                      "Pedido Finalizado Com Sucesso",
                                                      context,
                                                      duration:
                                                          Toast.LENGTH_LONG,
                                                      gravity: Toast.CENTER,
                                                      backgroundRadius: 0.0);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              new HomePage1(
                                                                id_sessao: widget
                                                                    .id_sessao,
                                                              )));
                                                } else {
                                                  Toast.show("Erro ao Inserir",
                                                      context,
                                                      duration:
                                                          Toast.LENGTH_LONG,
                                                      gravity: Toast.CENTER,
                                                      backgroundRadius: 0.0);
                                                }
                                              } else {
                                                Toast.show(
                                                    "Escolha uma opção de pagamento",
                                                    context,
                                                    duration:
                                                        Toast.LENGTH_SHORT,
                                                    gravity: Toast.CENTER,
                                                    backgroundRadius: 0.0);
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        });
                      },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Finalizar Compra',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                          Navigator.of(context).push(new MaterialPageRoute(
                            builder: (context) =>
                                new HomePage1(id_sessao: widget.id_sessao),
                          ));
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

  void circular(String tipo) {
    if (tipo == 'inicio') {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
                  child: new Container(
                color: Colors.black,
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text(
                      'carregando',
                      style: new TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    new CircularProgressIndicator(),
                    // new Text("Carrengando ..."),
                  ],
                ),
              )));
    } else
      Navigator.pop(context);
  }

  Future<String> insere_pedido(String tipo_pag) async {
    //variaveis locais
    List lista_pedidos = [];
    List lista_totais = [];
    List lista_itens_pedido = [];
    List lista_qtd = [];
    int num_pedidos = 1;
    int temp_lista_geral = 0;

    //determina quantidades de pedidos
    lista_pedidos.add(Product_on_the_cart[0]['id_empresa'].toString());
    for (int i = 0; i < Product_on_the_cart.length - 1; i++) {
      String temp = Product_on_the_cart[i]['id_empresa'].toString();
      if (temp == Product_on_the_cart[i + 1]['id_empresa'].toString()) {
      } else {
        num_pedidos = num_pedidos + 1;
        lista_pedidos.add(Product_on_the_cart[i + 1]['id_empresa'].toString());
      }
    }

    // inicializa listas totais e de itens pedido
    for (int j = 0; j < num_pedidos; j++) {
      lista_totais.add('0');
      lista_itens_pedido.add('0');
      lista_qtd.add('0');
    }
    ;

    //calcula os totais por pedido
    double temp2 = 0.0;
    double temp3 = 0.0;
    int cont = 0;
    for (int j = 0; j < num_pedidos; j++) {
      for (int i = 0; i < Product_on_the_cart.length; i++) {
        if (Product_on_the_cart[i]['id_empresa'].toString() ==
            lista_pedidos[j].toString()) {
          temp2 = temp2 +
              double.parse(Product_on_the_cart[i]['preco_venda']) *
                  double.parse(Product_on_the_cart[i]['quantidade']);
          temp3 = temp3 + double.parse(Product_on_the_cart[i]['quantidade']);
          cont = cont + 1;
        }
      }
      lista_totais[j] = temp2.toString();
      lista_itens_pedido[j] = cont.toString();
      lista_qtd[j] = temp3.toString();
      temp2 = 0.0;
      temp3 = 0.0;
      cont = 0;
    }
    //print('pedidos: ${lista_pedidos}');
    //print('num = ${num_pedidos}');
    //print('totais:${lista_totais}');
    //print('intems:${lista_itens_pedido}');
    //print('qtd:${lista_qtd}');
    //-----------------------------------
    String obs = '';
    if (frete == 0.0)
      obs = 'Retirar no Local';
    else
      obs = 'Entrega em Domicílio';

    for (int w = 0; w < num_pedidos; w++) {
      //insere pedido tabela de vendas

      String link = Basicos.codifica("${Basicos.ip}/crud/?crud=consulta8."
              "APP_RECOOPSOL," //solicitante,character varying(50) NOT NULL
              //data_venda date NOT NULL,
              "${await retornaObsEmpresa(lista_pedidos[w].toString())}," //data_entrega date NOT NULL,
              //vencimento date NOT NULL,
              "EM ANDAMENTO," //status_pedido character varying(30) NOT NULL
              "${lista_totais[w].toString()}," //valor_total numeric(15,2) NOT NULL
              "0.00," //desconto numeric(15,2) NOT NULL,
              "0.00," //saldo_final numeric(15,2) NOT NULL,
              "$obs," //observacoes text NOT NULL,
              //data_registro timestamp with time zone NOT NULL,
              //data_alteracao timestamp with time zone NOT NULL,
              " ," //cep character varying(10) NOT NULL,
              " ," //endereco character varying(50) NOT NULL,
              " ," //numero character varying(10) NOT NULL,
              " ," //complemento character varying(30) NOT NULL,
              " ," //bairro character varying(50) NOT NULL,
              " ," //cidade character varying(50) NOT NULL,
              " ," //estado character varying(2) NOT NULL,
              "${frete.toStringAsFixed(2)} ," //observacoes_entrega text NOT NULL,
              "${widget.id_sessao}," //cliente_id integer NOT NULL,
              "${lista_pedidos[w].toString()}") //empresa_id integer,
          ; //pagamento_id integer,)
      //print(link);
      var res1 = await http
          .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
      //  print(res.body);
      var res2 = Basicos.decodifica(res1.body);
      if (res1.body.length > 2) {
        if (res1.statusCode == 200) {
          var list = json.decode(res2).cast<Map<String, dynamic>>();
          //print(list[0]['id']); // retorna o id inserido na tabelas de vendas

          // caso inserido com sucesso e id retornado insere os produtos na tabela saida_produtos
          if (list[0]['id'] != Null) {
            for (int i = 0; i < int.parse(lista_itens_pedido[w]); i++) {
              //insere itens_pedido na tabela de saida_produtos
              String link2 =
                  Basicos.codifica("${Basicos.ip}/crud/?crud=consulta9."
                      "${Product_on_the_cart[temp_lista_geral]["quantidade"]}," //quantidade numeric(15,3) NOT NULL,
                      //data_saida date NOT NULL
                      "${Product_on_the_cart[temp_lista_geral]["preco_venda"]}," //valor_unitario numeric(15,3) NOT NULL,
                      "0.0," //percentual_desconto numeric(15,3) NOT NULL,
                      "0.0," //total_desconto numeric(15,2) NOT NULL
                      "${(double.parse(Product_on_the_cart[temp_lista_geral]["preco_venda"].toString()) * double.parse(Product_on_the_cart[temp_lista_geral]["quantidade"].toString())).toString()}," //valor_total numeric(15,2) NOT NULL,
                      "EM SEPARACAO," //status character varying(20) NOT NULL
                      "ABERTO," //balanco character varying(20) NOT NULL,
                      " ," //observacoes_saida text,
                      //data_registro timestamp with time zone NOT NULL,
                      //data_alteracao timestamp with time zone NOT NULL,
                      "${Product_on_the_cart[temp_lista_geral]["preco_venda"]}," //saldo_final numeric(15,2) NOT NULL,
                      "${lista_pedidos[w].toString()}," //empresa_id integer,
                      "${Product_on_the_cart[temp_lista_geral]["produto_id"]}," //produto_id integer NOT NULL,
                      "${list[0]['id']}") //venda_id integer NOT NULL,
                  ;
              //print(link);
              var res3 = await http.get(Uri.encodeFull(link2),
                  headers: {"Accept": "application/json"});
              var res4 = Basicos.decodifica(res3.body);
              if (res3.body.length > 2) {
                if (res3.statusCode == 200) {
                  var list_prod_id =
                      json.decode(res4).cast<Map<String, dynamic>>();

                  //---------------------da baixa no estoque do produto

                  String link_2 =
                      Basicos.codifica("${Basicos.ip}/crud/?crud=consul_18."
                          "${Product_on_the_cart[temp_lista_geral]["quantidade"]}," //id_vendas
                          "${Product_on_the_cart[temp_lista_geral]["produto_id"]}") //id_contas_a_receber
                      ;
                  // print(link5);
                  var res_0 = await http.get(Uri.encodeFull(link_2),
                      headers: {"Accept": "application/json"});
                  // var res_1 = Basicos.decodifica(res_0.body);
                  if (res_0.body.length > 2) {
                    if (res_0.statusCode == 200) {}
                  }
                }
              }
              temp_lista_geral = temp_lista_geral + 1;
            }

            //---------------------da baixa no estoque do produto
            //
            // inserir venda no contas a receber
            String link3 =
                Basicos.codifica("${Basicos.ip}/crud/?crud=consult17."
                    //data_conta date NOT NULL,
                    "${lista_totais[w].toString()}," //valor_conta numeric(15,2) NOT NULL,
                    "A VISTA," //forma_de_pagamento character varying(8) NOT NULL,
                    "${tipo_pag}," //meio_de_pagamento character varying(15) NOT NULL,
                    "0," //quantidade_parcelas integer NOT NULL,
                    //primeiro_vencimento date NOT NULL,
                    "0.0," //valor_entrada numeric(15,2) NOT NULL,
                    "${list[0]['id']}," //documento_vinculado integer,
                    "PENDENTE," //status_conta character varying(20) NOT NULL,
                    "Pagamento referente ao pedido ${list[0]['id']}," //descricao character varying(200) NOT NULL,
                    //data_registro timestamp with time zone NOT NULL,
                    //data_alteracao timestamp with time zone NOT NULL,
                    "${frete.toStringAsFixed(2)} ," //observacoes_conta  recebe o frete
                    "${widget.id_sessao}," //agente_pagador_id integer cliente NOT NULL,
                    "${lista_pedidos[w].toString()}") //empresa_id integer,
                ;
            //print(link);
            var res5 = await http.get(Uri.encodeFull(link3),
                headers: {"Accept": "application/json"});
            var res6 = Basicos.decodifica(res5.body);
            if (res5.body.length > 2) {
              if (res5.statusCode == 200) {
                var list2 = json.decode(res6).cast<Map<String, dynamic>>();
                //print(list2[0]['id']); // retorna o id inserido na tabelas de contas a receber

                // atualiza pagamento_id na tabela de vendas
                String link5 =
                    Basicos.codifica("${Basicos.ip}/crud/?crud=consult18."
                        "${list[0]['id']}," //id_vendas
                        "${list2[0]['id']}") //id_contas_a_receber
                    ;
                // print(link5);
                var res9 = await http.get(Uri.encodeFull(link5),
                    headers: {"Accept": "application/json"});
                var res10 = Basicos.decodifica(res9.body);
                if (res5.body.length > 2) {
                  if (res5.statusCode == 200) {}
                }

                // insere compra no pagamento_recebido como pendente
                String link6 = Basicos.codifica(
                    "${Basicos.ip}/crud/?crud=consult28."
                    //    data_pagamento,
                    //    data_vencimento,
                    "${lista_totais[w].toString()}," //valor_pagamento,
                    "PENDENTE," //status_pagamento,
                    "${tipo_pag}," //meio_pagamento,
                    "Pagamento referente ao pedido ${list[0]['id']}," //observacoes_pagamento,
                    //    data_registro,
                    //    data_alteracao,
                    "${list2[0]['id']}," //conta_id,
                    "${lista_pedidos[w].toString()}"); //empresa_id

                //print(link6);
                var res11 = await http.get(Uri.encodeFull(link6),
                    headers: {"Accept": "application/json"});
                var res12 = Basicos.decodifica(res11.body);
                if (res11.body.length > 2) {
                  if (res11.statusCode == 200) {}
                }
              }
            }
            //return 'sucesso';
          } else {
            return 'falha';
          }
        }
      }
    } //for
    // remove  itens do carrinho
    String link4 = Basicos.codifica("${Basicos.ip}/crud/?crud=consult10."
            "${widget.id_sessao}") //id_cliente
        ;
    //print(link);
    var res7 = await http
        .get(Uri.encodeFull(link4), headers: {"Accept": "application/json"});
    var res8 = Basicos.decodifica(res7.body);
    if (res7.body.length > 2) {
      if (res7.statusCode == 200) {
        // var list = json.decode(res.body) as String;
        return 'sucesso';
      }
    }
  }

  Future<List<Pedido>> obterPedidos() async {
    bool verificado = false;
    PaletteGenerator paletteGenerator;
    pedidos = [];

    await listCart();

    cart.forEach((element) async {
      //print(element.title);
      total = total + element.price * element.quantidade;
      if (element.color == null) {
        paletteGenerator = await PaletteGenerator.fromImageProvider(
            NetworkImage(Basicos.ip + '/media/' + element.image));
        element.color = paletteGenerator.darkVibrantColor?.color == null
            ? Colors.grey[200]
            : paletteGenerator.darkVibrantColor?.color;
      }
      verificado = false;
      for (var pedido in pedidos) {
        if (pedido.produtor == element.produtor) {
          pedido.produtos.add(element);
          verificado = true;
          break;
        }
      }
      if (!verificado) {
        pedidos.add(Pedido(
          produtor: element.produtor,
          produtos: [element],
        ));
      }
    });
    initialSet = false;
    // print('Pedidos: ${pedidos.length}');
    pedidos.forEach((element) {
      //  print(element.produtos.length);
    });
    //print(total);
    calculaFrete2(widget.id_sessao, cart);
    await Future.delayed(Duration(seconds: 2));
    return pedidos;
  }

  Future<List> listCart() async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consulta7.${widget.id_sessao}");

    //print(widget.id_sessao);
    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    //var res =Basicos.decodifica(res1.body);
    //print(res.body.length);

    // if (res.body.length == 2)
    //   new Future.delayed(const Duration(seconds: 1)) //snackbar
    //       .then((_) => _showSnackBar('Cesta Vazia...'));
    // else
    //   new Future.delayed(const Duration(seconds: 1)) //snackbar
    //       .then((_) => _showSnackBar('Carregando...')); //snackbar

    //print( Product_on_the_cart.length.toString());
    if (res.body.length > 2) {
      if (res.statusCode == 200) {
        // converte a lista de consulta em uma lista dinamica
        List list = json.decode(res.body).cast<Map<String, dynamic>>();
        //print(list);
        Product_on_the_cart = list;
        list.forEach((element) {
          setState(() {
            cart.add(Food(
              title: element['descricao_simplificada'],
              image: element['imagem'],
              price: double.parse(element['preco_venda']),
              produtor: element['razao_social'],
              description: element['marketing'],
              id: element['produto_id'],
              idProdutor: element['id'],
              quantidade: double.parse(element['quantidade']),
            ));
          });
        });
        // setState(() {
        //   cart = list;
        // });
        return list;
      }
    }
  }

  String get_picture(cart_prod_picture) {
    if (cart_prod_picture == '') {
      return '${Basicos.ip}/media/estoque/produtos/img/product-01.jpg';
    } else {
      //print("${basicos().ip}/media/${prod_picture}");
      return "${Basicos.ip}/media/${cart_prod_picture}";
    }
  }
  // void _showSnackBar(String message) {
  //   _scaffoldKey.currentState.showSnackBar(SnackBar(
  //     content: Text(
  //       message,
  //       textAlign: TextAlign.center,
  //     ),
  //     backgroundColor: Colors.black,
  //     duration: Duration(seconds: 2),
  //   ));
  // }

  Future<String> retornaObsEmpresa(String empresa) async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consul-69.$empresa"); //id_empresa;
    var res7 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});

    var res8 = Basicos.decodifica(res7.body);
    if (res7.body.length >= 2) {
      if (res7.statusCode == 200) {
        List list = json.decode(res8).cast<Map<String, dynamic>>();
        // print(list[0]['observacoes']);
        if (list[0]['observacoes'] == '') return '01-01-1900';
        return list[0]['observacoes'];
      }
    }
  }

  Future<double> calculaFrete2(sessao, List<Food> cart) async {
//double frete = total
    // print(soma);
    String link = Basicos.codifica("${Basicos.ip}/crud/?crud=consul-29."
        "$sessao"); //id_cliente;
    var res7 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});

    var res8 = Basicos.decodifica(res7.body);
    if (res7.body.length >= 1) {
      if (res7.statusCode == 200) {
        //  print('res-$res8');
        if (cart.length > 0)
          setState(() {
            frete = double.parse(res8);
          });
        else
          setState(() {
            frete = 0.0;
          });
        return frete;
      }
    } else
      return 0.0;
  }
}

// Future<double> calculaFrete(soma) async {
// //double frete = total
//   // print(soma);
//   String link = Basicos.codifica("${Basicos.ip}/crud/?crud=consul029."
//       "${soma.toStringAsFixed(2)}"); //id_cliente;
//   var res7 = await http
//       .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});

//   var res8 = Basicos.decodifica(res7.body);
//   if (res7.body.length >= 1) {
//     if (res7.statusCode == 200) {
//       //  print('res-$res8');
//       frete = double.parse(res8); //double.parse(list[0]);
//       return frete;
//     }
//   }
// //return total.toStringAsFixed(2);
//   else
//     return 0.0;
// }

class MyDialog extends StatefulWidget {
  const MyDialog();

  @override
  State createState() => new MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  String _selectedId;

  void initState() {
    Parametro.tipo_pagamento = "";
  }

  Widget build(BuildContext context) {
    String _picked = "";
    return Scrollbar(
      child: ListView(children: <Widget>[
        new Column(
          // title: new Text("New Dialog"),
          // contentPadding: const EdgeInsets.all(10.0),
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(2, 10.0, 10.0, 0.0),
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                //color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.all(Radius.circular(22.0)),
              ),
              child: RadioButtonGroup(
                //picked: _picked,
                labels: <String>[
                  "DINHEIRO",
                  "CARTÃO DÉBITO",
                  "CARTÃO CRÉDITO",
                  'CHEQUE',
                  'OUTROS'
                ],
                labelStyle: TextStyle(fontSize: 15),
                onSelected: (String selected) => setState(() {
                  _picked = selected;
                  Parametro.tipo_pagamento = selected;
                }),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class Parametro {
  static String tipo_pagamento = "DINHEIRO";

  Parametro();
}

class Pedido {
  final String produtor;
  final List<Food> produtos;

  Pedido({this.produtos, this.produtor});
}

class Food {
  final String title;
  final String image;
  final double price;
  final String produtor;
  final String description;
  final int id;
  final int idProdutor;
  double quantidade;
  Color color;

  Food(
      {this.title,
      this.image,
      this.price,
      this.produtor,
      this.description,
      this.color,
      this.quantidade,
      this.id,
      this.idProdutor});
}
