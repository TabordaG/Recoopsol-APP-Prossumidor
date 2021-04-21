import 'package:prossumidor/pages/constantes.dart';
import 'package:prossumidor/pages/entregues.dart';
import 'package:prossumidor/pages/nao_entregues.dart';
import 'package:prossumidor/pages/pedidos.dart';
import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:flutter/material.dart';
import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:palette_generator/palette_generator.dart';

class Pedidos_products extends StatefulWidget {
  final id_pedido;
  final id_sessao;
  final String pageAnterior;

  Pedidos_products(
    this.pageAnterior, {
    this.id_pedido,
    this.id_sessao,
  });

  @override
  _Pedidos_productsState createState() => _Pedidos_productsState();
}

class _Pedidos_productsState extends State<Pedidos_products> {
  List Product_on_the_pedido = [];
  double _top = -60;

  @override
  void initState() {
    listPedido().then((resultado) {
      setState(() {});
    });
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        _top = 20;
      });
    });
    super.initState();
  }

  Future<bool> onWillPop() async {
    Navigator.pop(context, true);
    // setState(() {
    //   _top = -60;
    // });
    // Basicos.pagina = 1;
    // Basicos.product_list = [];
    // Basicos.meus_pedidos = [];
    // Future.delayed(Duration(milliseconds: 250), () {
    //   Navigator.of(context).push(MaterialPageRoute(
    //       builder: (context) => widget.pageAnterior == 'entregues'
    //           ? Pedidos_Entregues(id_sessao: widget.id_sessao)
    //           : widget.pageAnterior == 'naoentregues'
    //               ? Pedidos_nao_Entregues(id_sessao: widget.id_sessao)
    //               : MeusPedidos(id_sessao: widget.id_sessao)));
    // });
    return true;
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10.0, top: 85, bottom: 10),
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
                          'Detalhes Pedido',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                          child: ListView.builder(
                              // retorna o laco com lista de produtos do pedido
                              itemCount: Product_on_the_pedido.length,
                              itemBuilder: (context, index) {
                                return Single_pedido_product(
                                  pedido_prod_name: Product_on_the_pedido[index]
                                      ["descricao_simplificada"],
                                  pedido_prod_id: Product_on_the_pedido[index]
                                      ["id"],
                                  pedido_prod_qtd: Product_on_the_pedido[index]
                                      ["quantidade"],
                                  pedido_prod_price:
                                      Product_on_the_pedido[index]
                                          ["valor_unitario"],
                                  pedido_prod_picture:
                                      Product_on_the_pedido[index]["imagem"],
                                  pedido_prod_status:
                                      Product_on_the_pedido[index]["status"],
                                );
                              }),
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
                      Navigator.pop(context, true);
                      // setState(() {
                      //   _top = -60;
                      // });
                      // Basicos.pagina = 1;
                      // Basicos.product_list = [];
                      //   Basicos.meus_pedidos = [];
                      // Future.delayed(Duration(milliseconds: 250), () {
                      //   Navigator.of(context).push(MaterialPageRoute(
                      //       builder: (context) => widget.pageAnterior ==
                      //               'entregues'
                      //           ? Pedidos_Entregues(id_sessao: widget.id_sessao)
                      //           : widget.pageAnterior == 'naoentregues'
                      //               ? Pedidos_nao_Entregues(
                      //                   id_sessao: widget.id_sessao)
                      //               : MeusPedidos(
                      //                   id_sessao: widget.id_sessao)));
                      // });
                    }),
                radius: 22,
              ),
            ),
          ],
        ),

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 5),
          child: Card(
            elevation: 14,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total sem Frete',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  Text(
                    'R\$${double.parse(total()).toStringAsFixed(2).replaceAll('.', ',')}',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // bottomNavigationBar: new Container(
        //   color: Colors.grey.withOpacity(0.3),
        //   child: Row(
        //     children: <Widget>[
        //       Expanded(
        //         child: ListTile(
        //           title: new Text(
        //             "R\$ ${total().toString().replaceAll('.', ',')}",
        //             style: TextStyle(
        //               fontSize: 15.0,
        //               fontWeight: FontWeight.bold,
        //               color: Colors.blue,
        //             ),
        //           ),
        //           leading: Padding(
        //             padding: const EdgeInsets.fromLTRB(0.0, 3.0, 0.0, 0.0),
        //             child: new Text(
        //               "Total:",
        //               style: TextStyle(
        //                 fontSize: 14.0,
        //                 // fontWeight: FontWeight.bold,
        //                 //color: Colors.red,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //       Expanded(
        //         child: new MaterialButton(onPressed: () async {}),
        //       )
        //     ],
        //   ),
        // ),
      ),
    );
  }

  // Lista itens da cesta
  Future<List> listPedido() async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consult15.${widget.id_pedido}");
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    //print(res.body);
    var res = Basicos.decodifica(res1.body);
    if (res1.body.length > 2) {
      if (res1.statusCode == 200) {
        // converte a lista de consulta em uma lista dinamica
        List list = json.decode(res).cast<Map<String, dynamic>>();
        Product_on_the_pedido = list;

        // print(list);
        return (list);
      }
    }
  }

// soma os valores da cesta retorna o total
  String total() {
    var soma = 0.0;

    for (int i = 0; i < Product_on_the_pedido.length; i++) {
      soma = soma +
          (double.parse(Product_on_the_pedido[i]["valor_unitario"]) *
              double.parse(Product_on_the_pedido[i]["quantidade"]));
    }
    return soma.toString();
  }
}

class Single_pedido_product extends StatefulWidget {
  final pedido_prod_id;
  final pedido_prod_name;
  final pedido_prod_picture;
  final pedido_prod_price;
  final pedido_prod_size;
  final pedido_prod_qtd;
  final pedido_prod_status;

  Single_pedido_product({
    this.pedido_prod_id,
    this.pedido_prod_name,
    this.pedido_prod_picture,
    this.pedido_prod_price,
    this.pedido_prod_qtd,
    this.pedido_prod_size,
    this.pedido_prod_status,
  });

  @override
  _Single_pedido_productState createState() => _Single_pedido_productState();
}

class _Single_pedido_productState extends State<Single_pedido_product> {
  PaletteGenerator paletteGenerator;
  Color colorImage = Colors.blueAccent.withOpacity(.6);

  @override
  void initState() {
    super.initState();
    _carregarImage();
  }

  _carregarImage() async {
    Color color = await getColor();
    setState(() {
      colorImage = color;
    });
  }

  Future<Color> getColor() async {
    Color color;
    paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(Basicos.ip + '/media/' + widget.pedido_prod_picture));
    color = paletteGenerator.dominantColor?.color == null
        ? Colors.grey
        : paletteGenerator.dominantColor?.color;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 5),
                  width: 100,
                  height: 110,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 10,
                        left: 0,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color:
                                colorImage, //item.produtos[index2].color.withOpacity(.4),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 3,
                        right: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          child: Image.network(
                            Basicos.ip + '/media/' + widget.pedido_prod_picture,
                            fit: BoxFit.contain,
                            height: 90,
                            width: 90,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 5),
                          child: Text(
                            widget.pedido_prod_name,
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(fontSize: 18),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          height: 30,
                          width: 115,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Qtd.: '),
                              Text(
                                  "${widget.pedido_prod_qtd.toString().substring(0, widget.pedido_prod_qtd.toString().indexOf('.', 0))}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            'R\$${widget.pedido_prod_price.toString().replaceAll('.', ',').substring(0, widget.pedido_prod_price.toString().indexOf(',') + 5)} unit.',
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(
                                    fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '*Valor ajustado a qtd',
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(fontSize: 7),
                          ),
                        ),
                        Text(
                          'R\$${(double.parse(widget.pedido_prod_price) * double.parse(widget.pedido_prod_qtd)).toStringAsFixed(2).replaceAll('.', ',')}',
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontSize: 20),
                        ),
                      ]),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Situação: ',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(fontSize: 16),
                  ),
                  Text(
                    '${widget.pedido_prod_status.toString()}',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

//     return Card(
//       child: ListTile(
// // ===================== sessao lista de compras
// // imagem
//         leading: Column(
//           children: <Widget>[
//             Container(
//               width: 50.0,
//               height: 43.0,
//               padding: EdgeInsets.all(0.0), //diminui a figura
//               child: Image.network(Basicos.ip + '/media/' + pedido_prod_picture,
//                   fit: BoxFit.fill),
//             ),
//             Text('# ${pedido_prod_id.toString()}',
//                 textScaleFactor: 0.7,
//                 style: TextStyle(
//                   color: Colors.grey,
//                 )),
//           ],
//         ),
// //texto descritivo

// //=============== subttitulo da sessao
//         title: new Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             // dentro da coluna
//             Expanded(
//               child: new Text(
//                 pedido_prod_name + '   ',
//                 style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.left,
//               ),
//             ),
// //============================ sessao preco produto
//             new Text(
//               "R\$ ${pedido_prod_price.toString().replaceAll('.', ',').substring(0, pedido_prod_price.toString().indexOf(',') + 5)}",
//               style: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//           ],
//         ),
//         subtitle: Column(
//           children: <Widget>[
//             Row(children: <Widget>[
//               Expanded(
//                 child: new Text(
//                   " Qtd:    ",
//                   textAlign: TextAlign.left,
//                   textScaleFactor: 1.0,
//                 ),
//               ),
//               new Text(
//                 "${pedido_prod_qtd.toString().substring(0, pedido_prod_qtd.toString().indexOf('.', 0))}   ",
//                 textAlign: TextAlign.left,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16.0,
//                   color: Colors.black,
//                 ),
//                 key: Key('texto1'),
//                 textScaleFactor: 1,
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
//                 child: Text("subtotal: "),
//               ),
//               new Text(
//                 "R\$ ${(double.parse(pedido_prod_price) * double.parse(pedido_prod_qtd)).toString().replaceAll('.', ',')}",
//                 style: TextStyle(
//                   fontSize: 16.0,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                 ),
//               ),
//             ]),
    // Row(
    //   children: <Widget>[
    //     Text('Situação: '),
    //     Text(
    //       '${pedido_prod_status.toString()}',
    //       style: TextStyle(
    //         fontSize: 16.0,
    //         fontWeight: FontWeight.bold,
    //         color: Colors.blue,
    //       ),
    //     ),
    //   ],
    // )
//           ],
//         ),
//       ),
//     );
  }
}
