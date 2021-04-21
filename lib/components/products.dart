import 'package:prossumidor/chat/chats.dart';
import 'package:prossumidor/pages/constantes.dart';
import 'package:flutter/material.dart';
import 'package:prossumidor/pages/product_details.dart';
import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:toast/toast.dart';

import 'package:prossumidor/pages/home.dart';

class Products extends StatefulWidget {
  final id_sessao;
  final busca;
  final Function press;
  final Function unpress;
  final GlobalKey<ScaffoldState> scaffoldKey;

  Products(
      {this.id_sessao,
      this.busca,
      this.press,
      this.unpress,
      this.scaffoldKey}); // id_cliente da sessao
  void initState() {}

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> with TickerProviderStateMixin {
  List productsIDlist = [];
  String message = "";
  bool _isnew = true;

  ScrollController controller_ = ScrollController(
    initialScrollOffset: 0, //Basicos.pagina,
  );
  // final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey(); // snackbar

  void _showSnackBar(String message) {
    widget.scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.black,
      duration: Duration(seconds: 1),
    ));
  }

  _scrollListener() {
    // recebe o scroll se no inicio ou fim
    if (controller_.offset >= (controller_.position.maxScrollExtent - 50) &&
        !controller_.position.outOfRange) {
      if (Basicos.offset <= Basicos.product_list.length) {
        setState(() {
          //atualiza pagina com offset
          Basicos.pagina = controller_.offset;
          // aumenta o offset da consulta no banco
          Basicos.offset = Basicos.offset +
              10; //preenche o grid com a quantidade lida do banco menos dois uma fileira
          message = "final";
        });
        buscaProdutos(categoria, widget.busca);
        // Future.delayed(const Duration(seconds: 2)) //snackbar
        //   .then((_) => _showSnackBar('Carregando Produtos ...'));
        //snackbar
        // circular('inicio');
        // //print(_controller.offset);
        // //print(Basicos.pagina);
        // // _controller.jumpTo(50.0);
        // Navigator.of(context).push(new MaterialPageRoute(
        //   // aqui temos passagem de valores id cliente(sessao) de login para home
        //   builder: (context) => new HomePage1(id_sessao: widget.id_sessao),
        // ));
        // circular('fim');
      } else {
        setState(() {
          Basicos.offset = Basicos.product_list.length;
        });
      }
    }
    if (controller_.offset <= controller_.position.minScrollExtent &&
        !controller_.position.outOfRange) {
      // verifica se ja esta no topo
      setState(() {
        //print (_controller.offset);
//        Basicos.offset = Basicos.offset - product_list.length - 2;
//        if (Basicos.offset < 0) Basicos.offset = 0;
//        message = "topo";
//        Navigator.of(context).push(new MaterialPageRoute(
//          // aqui temos passagem de valores id cliente(sessao) de login para home
//          builder: (context) => new HomePage1(id_sessao: widget.id_sessao),
//        ));
      });
    }
  }

//  List product_list = [];

  String categoria =
      Basicos.categoria_usada; // passar * implica em selecionar todos produtos
  String id_local_retirada = ""; // id local de retirada da tabela clientes

  @override
  void initState() {
    super.initState();
    // app novo
    // controller_ = ScrollController();

    controller_.addListener(() {
      if (controller_.offset > 27 && height == 260) {
        setState(() {
          widget.press();
        });
      } else if (controller_.offset == 0 && height == 1) {
        setState(() {
          //_height = 270;
          widget.unpress(); //_topPadding = -90;
        });
      }
    });
    controller_.addListener(_scrollListener);

    buscaProdutos(categoria, widget.busca).then((resultado) {
      // print('Offset 2: ${Basicos.offset}');
      setState(() {});
    });
    // Future.delayed(const Duration(seconds: 1)) //snackbar
    //   .then((_) => _showSnackBar('Carregando ...')); //snackbar
  }

  @override
  void dispose() {
    controller_.removeListener(_scrollListener);
    controller_.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (zerarController) {
      setState(() {
        controller_.animateTo(1,
            duration: Duration(milliseconds: 400), curve: Curves.ease);
        zerarController = false;
      });
    }
    // grid que monta os produtos
    return Column(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: widget.press,
            child: Container(
              //color: Color(0xf8faf8),
              child: Scrollbar(
                controller: controller_,
                child: StaggeredGridView.countBuilder(
                  controller: controller_,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  // itemCount: products.length,

                  //  controller: controller,
                  itemCount: Basicos.product_list.length,
                  //    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  //       crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    //print(Basicos.offset);
                    //print(Basicos.product_list.length);

                    return //AlertDialog(title: Text("Index : $index"));
                        Single_prod(
                      id_sessao: widget.id_sessao.toString(),
                      // passa a sessao
                      prod_id: Basicos.product_list[index]['id'].toString(),
                      prod_name: Basicos.product_list[index]
                          ['descricao_simplificada'],
                      prod_picture: Basicos.product_list[index]['imagem'],
                      prod_price: Basicos.product_list[index]['preco_venda'],
                      prod_detalhe: Basicos.product_list[index]['observacoes'],
                      prod_condicoes: Basicos.product_list[index]['marketing'],
                      prod_marca: Basicos.product_list[index]
                              ['marca_produto_id']
                          .toString(),
                      marca: Basicos.product_list[index]['descricao'],
                      empresa_id:
                          Basicos.product_list[index]['empresa_id'].toString(),
                      razao_social: Basicos.product_list[index]['razao_social']
                          .toString(),
                      estoque_atual: Basicos.product_list[index]
                              ['estoque_atual']
                          .toString()
                          .substring(
                              0,
                              Basicos.product_list[index]['estoque_atual']
                                  .toString()
                                  .indexOf('.')),
                      unidade_medida: Basicos.product_list[index]
                              ['unidade_medida']
                          .toString(),
                    );
                  },
                  staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // lista os produtos para preencher o grid
  Future<List> buscaProdutos(String categoria, String busca) async {
    //print(widget.id_sessao.toString() + '-');
    // print(categoria);
    //print(widget.id_sessao);
    if (widget.id_sessao == 0) {
      // verifica se a entrada é anonima sem login
      id_local_retirada = '0'; // > 0 todos os  locais de retirada
    } else {
      await busca_id_local_retirada(); //local de retirada
    }
    //print(id_local_retirada);
    if (id_local_retirada == '') {
      // mensagem de erro
      Toast.show("Erro ao selecionar a Empresa", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
          backgroundRadius: 0.0);
    } else {
      // print(id_empresa);
      //print(Basicos.buscar_produto_home);
      String link = '';
      if (widget.id_sessao == 0) {
        link = Basicos.codifica("${Basicos.ip}/crud/?"
            "crud=consult-5.${categoria},${id_local_retirada},10,${Basicos.offset},${Basicos.buscar_produto_home}%"); //lista produto pela categoria, empresa e limit e offset
      } else {
        link = Basicos.codifica("${Basicos.ip}/crud/?"
            "crud=consulta5.${categoria},${id_local_retirada},10,${Basicos.offset},${Basicos.buscar_produto_home}%"); //lista produto pela categoria, empresa e limit e offset
      }
      var res1 = await http
          .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
      //print(id_local_retirada);
      var res = Basicos.decodifica(res1.body);
      //print(res);
      if (res1.body.length > 2) {
        if (res1.statusCode == 200) {
          // converte a lista de consulta em uma lista dinamica
          List list = json.decode(res).cast<Map<String, dynamic>>();
          //print('Lista: $list');
          // if (list.isEmpty && _isnew) {
          //   _showSnackBar('Todos Produtos Carregados');
          //   _isnew = false;
          // }
          for (var i = 0; i < list.length; i++) {
            if (!productsIDlist.contains(list[i]['id'])) {
              if (_isnew) {
                Future.delayed(const Duration(milliseconds: 500)) //snackbar
                    .then((_) => _showSnackBar('Carregando Produtos ...'));
                _isnew = false;
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    _isnew = true;
                  });
                });
              }
              setState(() {
                Basicos.product_list.add(list[i]);
                productsIDlist.add(list[i]['id']);
              });
            }
          }
          Basicos.buscar_produto_home = '';
          //print(Basicos.product_list.length);
          Future.delayed(Duration(milliseconds: 500), () {
            busca_qtd_produtos(Basicos.product_list.length);
          });
          return list;
        }
      }
    }
  }

  // busca qt de produtos cadastrados
  busca_qtd_produtos(int qtd_produtos) {
    if (qtd_produtos == 0)
      Toast.show("Nenhum Produto Cadastrado", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
          backgroundRadius: 0.0);
  }

  // busca id local de retirada na tabela cliente
  Future<String> busca_id_local_retirada() async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consult21.${widget.id_sessao}");
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    var res = Basicos.decodifica(res1.body);
    //print(res);
    if (res1.body.length >= 1) {
      if (res1.statusCode == 200) {
        var list = json.decode(res).cast<Map<String, dynamic>>();
        //print(list);
        id_local_retirada = list[0]['local_retirada_id'].toString();
        if (id_local_retirada.toString() == '') {
          return "falha";
        } else {
          return id_local_retirada;
        }
      }
    }
  }

  circular(String tipo) {
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
}

class Single_prod extends StatefulWidget {
  String id_sessao;
  String prod_id;
  String prod_name;
  String prod_picture;
  String prod_detalhe;
  String prod_marca;
  String prod_condicoes;
  String prod_price;
  String empresa_id;
  String razao_social;
  String estoque_atual;
  String marca;
  String unidade_medida;
  Color corImagem;
  double escalaImagem;

  Single_prod({
    this.id_sessao,
    this.prod_id,
    this.prod_name,
    this.prod_picture,
    this.prod_detalhe,
    this.prod_marca,
    this.prod_condicoes,
    this.prod_price,
    this.empresa_id,
    this.razao_social,
    this.estoque_atual,
    this.marca,
    this.unidade_medida,
    this.corImagem,
    this.escalaImagem,
  });

  factory Single_prod.fromJSON(Map<String, dynamic> jsonMap) {
    return Single_prod(
      id_sessao: '0',
      prod_id: jsonMap['id'].toString(),
      prod_name: jsonMap['descricao_simplificada'],
      prod_picture: jsonMap['imagem'],
      prod_price: jsonMap['preco_venda'],
      prod_detalhe: jsonMap['observacoes'],
      prod_condicoes: jsonMap['marketing'],
      prod_marca: jsonMap['marca_produto_id'].toString(),
      marca: jsonMap['descricao'],
      empresa_id: jsonMap['empresa_id'].toString(),
      razao_social: jsonMap['razao_social'].toString(),
      estoque_atual: jsonMap['estoque_atual']
          .toString()
          .substring(0, jsonMap['estoque_atual'].toString().indexOf('.')),
      unidade_medida: jsonMap['unidade_medida'].toString(),
      corImagem: kPrimaryColor.withOpacity(.05),
      escalaImagem: 1.0,
    );
  }

  @override
  _Single_prodState createState() => _Single_prodState();
}

class _Single_prodState extends State<Single_prod> {
  set nome(String val1) => widget.prod_name = val1;

  Color _color = Colors.blue[50];
  PaletteGenerator paletteGenerator;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //Color(0xFF012f7a),
        statusBarIconBrightness: Brightness.dark));
    return AnimatedContainer(
      duration: Duration(milliseconds: 800),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _color,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 1,
            offset: Offset(3, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 155,
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  // Rounded background
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      height: 130, //181,
                      width: 130, //181,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0256df)
                            .withOpacity(.4), //kPrimaryColor.withOpacity(.3),
                      ),
                    ),
                  ),
                  // Food Image
                  Positioned(
                    top: 0,
                    left: 0, //-30,
                    child: Container(
                      height: 130, //184,
                      width: 130, //168,//276,
                      child: ClipOval(
                        child: Container(
                          //tag: image,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset:
                                    Offset(3, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Image.network(
                            get_picture(),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Price
                  Positioned(
                    right: 10,
                    top: 122,
                    child: new Text(
                      "R\$${widget.prod_price.replaceAll('.', ',')}",
                      style: GoogleFonts.poppins(
                        //Theme.of(context).textTheme.headline.copyWith(
                        color:
                            Color(0xFF0256df).withOpacity(1), //kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        shadows: [
                          Shadow(
                            color: Colors.grey.withOpacity(0.3),
                            // spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(3, 3), // changes position of shadow
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.prod_name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                // color: Color(0xFF012f7a),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "${widget.razao_social}/${widget.marca}",
              style: GoogleFonts.poppins(
                // fontWeight: FontWeight.bold,
                // fontSize: 14,
                color: Colors.black.withOpacity(.4),
              ),
            ),
            SizedBox(height: 5),
            Text(
              widget.prod_detalhe,
              maxLines: 3,
              style: GoogleFonts.poppins(
                // fontWeight: FontWeight.bold,
                // fontSize: 14,
                color: Colors.black.withOpacity(.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get_picture() {
    if (widget.prod_picture == '') {
      return '${Basicos.ip}/media/estoque/produtos/img/product-01.jpg';
    } else {
      //print("${basicos().ip}/media/${prod_picture}");
      return "${Basicos.ip}/media/${widget.prod_picture}";
    }
  }

  Future getColor() async {
    paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(Basicos.ip + '/media/' + widget.prod_picture));
    if (paletteGenerator.lightVibrantColor?.color != null)
      setState(() {
        _color = paletteGenerator.lightVibrantColor?.color;
      });
  }
}
