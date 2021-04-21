import 'package:prossumidor/chat/chats.dart';
import 'package:prossumidor/pages/product_details.dart';
import 'package:prossumidor/pages/sobre.dart';
//import 'package:prossumidor/widgets/auto_refresh.dart';
import 'package:prossumidor/widgets/menu_item.dart';
import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:flutter/material.dart';
import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:prossumidor/pages/login.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:animations/animations.dart';
// meus imports
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prossumidor/components/products.dart';
import 'package:prossumidor/pages/pedidos.dart';
import 'package:prossumidor/pages/minhaConta.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
// app novo
import 'constantes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'newcart.dart';

List<bool> indexBottom = [false, false, false];
double height = 315;
int _isSelected = 0;
bool _initialexpanded = false, zerarController = false;

class HomePage1 extends StatefulWidget {
  var id_sessao;
  final busca;
  // final double offsetPage;

  HomePage1({
    this.id_sessao,
    this.busca,
  }); // id_cliente da sessao
  @override
  void initState() {}

  _HomePage1State createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1> with TickerProviderStateMixin {
  //appnovo
  StreamController produtosStream;
  ScrollController controller_ = ScrollController(
    initialScrollOffset: 0, //Basicos.pagina,
  );
  AnimationController _controller;
  double _topPadding = -120, _rightPadding = 20, valueScroll = 1, _bottom = -10;

  bool _isExpanded = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey(); // snackbar
  final keyIsFirstLoaded = 'is_first_loaded';

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

  // monta combo categoria
  String _categoryItemSelected = 'TODOS';
  List client_list = [
    {'email': 'null'},
    {'nome_razao_social': 'null'}
  ];

  List<String> _category_list = [
    'TODOS',
  ]; // dados estaticos de categorias
  List productsIDlist = [];
  List<Color> listColor = [];
  List<double> listScales = [];
  bool _isnew = true;

  String _itemSelecionado = 'Aleatório';
  String id_local_retirada = "";
  String qtd = ""; //quantidade de itens na cesta
  String marquee = ''; // marquee
  bool _mostrabadge = false;
  double qtd_chat = 0; //quantidade de msg no chat
  bool _chatbadge = false, _isVisible = true;
  List<String> _categoria_produtos = []; // dados produtos
  List<String> listaBanner = [];

  List<String> iconsList = [
    'icons/food(1).svg',
    'icons/arte.svg',
    'icons/fruits.svg',
    'icons/milk.svg',
    'icons/peas.svg',
    'icons/food(2).svg',
    'icons/bread.svg',
    'icons/food.svg',
    'icons/salt.svg',
    'icons/vegetable(1).svg'
  ];

  _scrollListener() {
    // recebe o scroll se no inicio ou fim
    if (controller_.offset >= (controller_.position.maxScrollExtent - 200) &&
        !controller_.position.outOfRange) {
      if (Basicos.offset <= Basicos.product_list.length) {
        setState(() {
          //atualiza pagina com offset
          Basicos.pagina = controller_.offset;
          // aumenta o offset da consulta no banco
          Basicos.offset = Basicos.offset +
              10; //preenche o grid com a quantidade lida do banco menos dois uma fileira
        });
        switch (_itemSelecionado) {
          case 'Aleatório':
            buscaProdutos(Basicos.categoria_usada, widget.busca);
            break;
          case 'A - Z':
            buscaProdutosCrescente(Basicos.categoria_usada, widget.busca);
            break;
          case 'Z - A':
            buscaProdutosDecrescente(Basicos.categoria_usada, widget.busca);
            break;
          default:
        }
      } else {
        setState(() {
          Basicos.offset = Basicos.product_list.length;
        });
      }
    }
  }

  @override
  initState() {
    super.initState();
    //appnovo
    // print('--->${Basicos.categoria_usada}');
    if (!indexBottom[0]) {
      setState(() {
        indexBottom[0] = true;
        indexBottom[1] = false;
        indexBottom[2] = false;
      });
    }
    KeyboardVisibility.onChange.listen((bool visible) {
      setState(() {
        _isVisible = !visible;
        _isVisible ? _bottom = -3 : _bottom = -80;
      });
    });
    produtosStream = StreamController();
    controller_.addListener(() {
      if (controller_.offset > 27 && height == 315) {
        setState(() {
          height = 1;
          _topPadding = 0;
          _bottom = -80;
          _isVisible = false;
        });
      } else if (controller_.offset == 0 && height == 1) {
        setState(() {
          height = 315;
          _bottom = -3;
          _topPadding = -120;
          _isVisible = true;
        });
      }
    });
    controller_.addListener(_scrollListener);

    buscaProdutos(Basicos.categoria_usada, widget.busca);

    // if (_initialexpanded) {
    //   // circular('inicio');
    //   Future.delayed(Duration(seconds: 1), () {
    //     setState(() {
    //       _bottom = -80;
    //       height = 1;
    //       _topPadding = 0;
    //       _initialexpanded = false;
    //     });
    //   });
    //   // circular('fim');
    // } else {
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        height = 315;
        _bottom = -3;
      });
    });
    // }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    buscaCategorias().then((resultado) {
      setState(() {
        search.text = '';
      });
    });
    buscaMarquee().then((resultado) {
      setState(() {});
    });

    // new Future.delayed(const Duration(seconds: 1)) //snackbar
    //     .then((_) => _showSnackBar('Carregando ...')); //snackbar
  }

  void dispose() {
    super.dispose();
    search.clear();
    controller_.removeListener(_scrollListener);
    controller_.dispose();
    produtosStream.close();
  }

  Future<bool> onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //Color(0xFF012f7a),
        statusBarIconBrightness: Brightness.dark));
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: new Stack(
            children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 15),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = true;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
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
                          // child: SvgPicture.asset("icons/bag.svg"),
                          child: Icon(
                            Icons.menu,
                            color: Color(0xFF012f7a),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            // border: Border.all(color: kBorderColor),
                            color: Colors.grey[200],
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                child: Container(
                                  height: 20,
                                  child: SvgPicture.asset(
                                    "icons/search.svg",
                                    color: Color(0xFF012f7a),
                                  ),
                                ),
                                onTap: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  if (search.text != null &&
                                      search.text.length >= 3) {
                                    setState(() {
                                      _initialexpanded = true;
                                      _buscar_produto();
                                    });
                                  } else {
                                    setState(() {
                                      _bottom = -3;
                                    });
                                    Toast.show(
                                      "A busca deve possuir mais do que 3 caractéres",
                                      context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.CENTER,
                                    );
                                  }
                                },
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: search,
                                  keyboardType: TextInputType.text,
                                  onTap: () {
                                    setState(() {
                                      _bottom = -80;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.only(bottom: 13.0),
                                    border: InputBorder.none,
                                    hintText: "Procurar",
                                    hintStyle: TextStyle(
                                      color: Color(0xFFA0A5BD),
                                    ),
                                  ),
                                  onSubmitted: (value) {
                                    if (search.text != null &&
                                        search.text.length >= 3) {
                                      setState(() {
                                        _initialexpanded = true;
                                        _buscar_produto();
                                      });
                                    } else {
                                      setState(() {
                                        _bottom = -3;
                                      });
                                      Toast.show(
                                        "A busca deve possuir 3 caractéres ou mais",
                                        context,
                                        duration: Toast.LENGTH_LONG,
                                        gravity: Toast.CENTER,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // showAlertDialog1(context, marquee);
                          if (widget.id_sessao == 0) {
                            Basicos.offset = 0; // zera o ofset do banco
                            Basicos.product_list =
                                []; // zera o lista de produtos da pagina principal
                            Basicos.pagina = 1;
                            //Basicos.buscar_produto_home = ''; // limpa pesquisa
                            Navigator.of(context).push(new MaterialPageRoute(
                              // aqui temos passagem de valores id cliente(sessao) de login para home
                              builder: (context) => new Login(),
                            ));
                          } else {
                            // print(widget.id_sessao);
                            Basicos.pagina = 1;
                            Basicos.offset = 0;
                            Basicos.product_list = [];
                            Navigator.of(context).push(new MaterialPageRoute(
                              // aqui temos passagem de valores id cliente(sessao) de login para home
                              builder: (context) => new CartScreen(
                                id_sessao: widget.id_sessao,
                                marquee: marquee,
                              ),
                            ));
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          // padding: EdgeInsets.symmetric(
                          //     horizontal: 10, vertical: 10),
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
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
                          // child: SvgPicture.asset("icons/bag.svg"),
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Center(
                                  child: Icon(
                                    Icons.shopping_cart,
                                    color: Color(0xFF012f7a),
                                  ),
                                ),
                              ),
                              if (qtd != '0' && widget.id_sessao != 0)
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 14,
                                    width: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF012f7a),
                                    ),
                                    child: Text(
                                      '$qtd',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(3, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 110,
                          enlargeCenterPage: false,
                          viewportFraction: 1,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 10),
                          // onPageChanged: (index, reason) {
                          //   commands.setIndex(index);
                          // },
                        ),
                        items:
                            listaBanner //['images/banner2 recoopsol.png', 'images/banner2.jpg']
                                .map((item) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                height: 110,
                                width: double.infinity,
                                child: Image.network(
                                  '${Basicos.ip}/media/$item',
                                  fit: BoxFit.fill,
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 15,
                  ),
                  width: double.infinity,
                  height: 75, //20,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _category_list.length, //categorias.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // print('tap1');
                            //print(_category_list[index].toString());
                            setState(() {
                              // seta o item da categoria escolhido

                              if (_category_list[index].toString() == 'TODOS') {
                                Basicos.categoria_usada = '*';
                                Basicos.categoria_usada_desc =
                                    ': : Categorias'; //Basicos.categoria_usada_desc = '';
                              } else {
                                Basicos.categoria_usada = _category_list[index]
                                    .toString()
                                    .substring(
                                        0,
                                        _category_list[index].indexOf('-',
                                            0)); // retira o codigo ate o hifem das categorias
                                Basicos.categoria_usada_desc =
                                    _category_list[index].toString().substring(
                                        _category_list[index].indexOf('-', 0) +
                                            1,
                                        _category_list[index].length);

                                this._categoryItemSelected =
                                    _category_list[index].toString();
                              }
                              _isSelected = index;
                              _initialexpanded = true;

                              Basicos.offset = 0;

                              /// resolvido bug

                              switch (_itemSelecionado) {
                                case 'Aleatório':
                                  Basicos.offset = 0;
                                  productsIDlist = [];
                                  Basicos.product_list = [];
                                  produtosStream.sink.add(Basicos.product_list);
                                  buscaProdutos(
                                      Basicos.categoria_usada, widget.busca);
                                  break;
                                case 'A - Z':
                                  Basicos.offset = 0;
                                  productsIDlist = [];
                                  Basicos.product_list = [];
                                  produtosStream.sink.add(Basicos.product_list);
                                  buscaProdutosCrescente(
                                      Basicos.categoria_usada, widget.busca);
                                  break;
                                case 'Z - A':
                                  Basicos.offset = 0;
                                  productsIDlist = [];
                                  Basicos.product_list = [];
                                  produtosStream.sink.add(Basicos.product_list);
                                  buscaProdutosDecrescente(
                                      Basicos.categoria_usada, widget.busca);
                                  break;
                                default:
                              }
                            });
                          },
                          child: Container(
                            width: 74,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _isSelected == index
                                        ? Colors.blue[200]
                                        : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 7,
                                        offset: Offset(
                                            3, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(8.0),
                                  child: index == 0
                                      ? Icon(
                                          Icons.dashboard,
                                          color: Color(0xFF012f7a),
                                        )
                                      : SvgPicture.asset(
                                          iconsList[index],
                                          color: Color(0xFF012f7a),
                                        ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '${_category_list[index].toString().substring(_category_list[index].indexOf('-', 0) + 1, _category_list[index].length)}       ',
                                  textAlign: TextAlign.center,
                                  // softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: _isSelected == index
                                        ? Color(0xFF012f7a)
                                        : Color(0xFF012f7a).withOpacity(.4),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ),
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ordenar por',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF012f7a),
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            items: ['Aleatório', 'A - Z', 'Z - A']
                                .map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(
                                  dropDownStringItem,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                    color: Color(0xFF012f7a).withOpacity(.9),
                                  ),
                                ),
                              );
                            }).toList(),
                            icon: _itemSelecionado == 'Aleatório'
                                ? Container(
                                    height: 25,
                                    width: 25,
                                    child: Image.asset(
                                      'images/iconfilter.png',
                                      fit: BoxFit.cover,
                                      color: Color(0xFF012f7a),
                                    ),
                                  )
                                : Icon(Icons.sort_by_alpha,
                                    color: Color(0xFF012f7a)),
                            onChanged: (String novoItemSelecionado) {
                              setState(() {
                                this._itemSelecionado = novoItemSelecionado;
                              });
                              if (widget.id_sessao == 0) {
                                Basicos.offset = 0;
                                Basicos.product_list = [];
                                Basicos.pagina = 1;
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  builder: (context) => new Login(),
                                ));
                              } else {
                                switch (novoItemSelecionado) {
                                  case 'Aleatório':
                                    Basicos.offset = 0;
                                    productsIDlist = [];
                                    Basicos.product_list = [];
                                    produtosStream.sink
                                        .add(Basicos.product_list);
                                    buscaProdutos(
                                        Basicos.categoria_usada, widget.busca);
                                    break;
                                  case 'A - Z':
                                    Basicos.offset = 0;
                                    productsIDlist = [];
                                    Basicos.product_list = [];
                                    produtosStream.sink
                                        .add(Basicos.product_list);
                                    buscaProdutosCrescente(
                                        Basicos.categoria_usada, widget.busca);
                                    break;
                                  case 'Z - A':
                                    Basicos.offset = 0;
                                    productsIDlist = [];
                                    Basicos.product_list = [];
                                    produtosStream.sink
                                        .add(Basicos.product_list);
                                    buscaProdutosDecrescente(
                                        Basicos.categoria_usada, widget.busca);
                                    break;
                                  default:
                                }
                              }
                            },
                            value: _itemSelecionado),
                      ),
                    ],
                  ),
                ),
              ]),
              Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    height: height,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          height = 1;
                          _topPadding = 0;
                          _bottom = -80;
                        });
                      },
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Scrollbar(
                            controller: controller_,
                            child: StreamBuilder(
                                stream: produtosStream.stream,
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    default:
                                      List listaProdutos = snapshot.data;
                                      return StaggeredGridView.countBuilder(
                                        controller: controller_,
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        // itemCount: products.length,

                                        //  controller: controller,
                                        itemCount: listaProdutos.length,
                                        //    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                                        //       crossAxisCount: 2),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          //print(Basicos.offset);
                                          //print(Basicos.product_list.length);
                                          return OpenContainer(
                                            closedBuilder: (context, action) {
                                              return Single_prod(
                                                id_sessao:
                                                    widget.id_sessao.toString(),
                                                // passa a sessao
                                                prod_id: listaProdutos[index]
                                                        ['id']
                                                    .toString(),
                                                prod_name: listaProdutos[index]
                                                    ['descricao_simplificada'],
                                                prod_picture:
                                                    listaProdutos[index]
                                                        ['imagem'],
                                                prod_price: listaProdutos[index]
                                                    ['preco_venda'],
                                                prod_detalhe:
                                                    listaProdutos[index]
                                                        ['observacoes'],
                                                prod_condicoes:
                                                    listaProdutos[index]
                                                        ['marketing'],
                                                prod_marca: listaProdutos[index]
                                                        ['marca_produto_id']
                                                    .toString(),
                                                marca: listaProdutos[index]
                                                    ['descricao'],
                                                empresa_id: listaProdutos[index]
                                                        ['empresa_id']
                                                    .toString(),
                                                razao_social:
                                                    listaProdutos[index]
                                                            ['razao_social']
                                                        .toString(),
                                                estoque_atual: listaProdutos[
                                                        index]['estoque_atual']
                                                    .toString()
                                                    .substring(
                                                        0,
                                                        listaProdutos[index][
                                                                'estoque_atual']
                                                            .toString()
                                                            .indexOf('.')),
                                                unidade_medida:
                                                    listaProdutos[index]
                                                            ['unidade_medida']
                                                        .toString(),
                                              );
                                            },
                                            openBuilder: (BuildContext context,
                                                VoidCallback _) {
                                              // return detalheProduto();
                                              return ProductsDetails(
                                                id_sessao: widget.id_sessao,
                                                product_detail_id:
                                                    listaProdutos[index]['id']
                                                        .toString(),
                                                product_detail_name:
                                                    listaProdutos[index][
                                                        'descricao_simplificada'],
                                                product_detail_new_price:
                                                    listaProdutos[index]
                                                        ['preco_venda'],
                                                product_detail_detalhe:
                                                    listaProdutos[index]
                                                        ['observacoes'],
                                                product_detail_marca:
                                                    listaProdutos[index]
                                                            ['marca_produto_id']
                                                        .toString(),
                                                product_detail_condicoes:
                                                    listaProdutos[index]
                                                        ['marketing'],
                                                product_detail_picture:
                                                    listaProdutos[index]
                                                        ['imagem'],
                                                product_detail_id_empresa:
                                                    listaProdutos[index]
                                                            ['empresa_id']
                                                        .toString(),
                                                product_detail_razao_social:
                                                    listaProdutos[index]
                                                            ['razao_social']
                                                        .toString(),
                                                product_detail_estoque_atual:
                                                    listaProdutos[index]
                                                            ['estoque_atual']
                                                        .toString()
                                                        .substring(
                                                            0,
                                                            listaProdutos[index]
                                                                    [
                                                                    'estoque_atual']
                                                                .toString()
                                                                .indexOf('.')),
                                                product_detail_unidade_medida:
                                                    listaProdutos[index]
                                                            ['unidade_medida']
                                                        .toString(),
                                              );
                                            },
                                          );
                                        },
                                        staggeredTileBuilder: (index) =>
                                            StaggeredTile.fit(1),
                                      );
                                  }
                                }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 450),
                bottom: _bottom,
                left: -4,
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
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(Icons.home,
                                color: indexBottom[0]
                                    ? Color(0xFF012f7a)
                                    : Colors.black26,
                                size: 30),
                            onPressed: () {
                              if (!indexBottom[0]) {
                                setState(() {
                                  indexBottom[0] = true;
                                  indexBottom[1] = false;
                                  indexBottom[2] = false;
                                });
                              }
                              // Basicos.offset = 0; // zera o ofset do banco
                              // Basicos.product_list =
                              //     []; // zera o lista de produtos da pagina principal
                              // Basicos.pagina = 1;
                              // //Basicos.buscar_produto_home = ''; // limpa pesquisa
                              // Navigator.of(context).push(new MaterialPageRoute(
                              //   // aqui temos passagem de valores id cliente(sessao) de login para home
                              //   builder: (context) => new HomePage1(id_sessao: '0'),
                              // ));
                              if (widget.id_sessao == '0') {
                                Basicos.offset = 0; // zera o ofset do banco
                                Basicos.product_list =
                                    []; // zera o lista de produtos da pagina principal
                                Basicos.pagina = 1;
                                //Basicos.buscar_produto_home = ''; // limpa pesquisa
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  // aqui temos passagem de valores id cliente(sessao) de login para home
                                  builder: (context) =>
                                      new HomePage1(id_sessao: '0'),
                                ));
                              } else {
                                // index_tab = 0;
                                Basicos.offset = 0; // zera o ofset do banco
                                Basicos.product_list =
                                    []; // zera o lista de produtos da pagina principal
                                Basicos.pagina = 1;
                                //print('xxx->');
                                //print(Basicos.categoria_usada);
                                //print(Basicos.categoria_usada_desc);
                                //Basicos.buscar_produto_home = ''; // limpa pesquisa
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  // aqui temos passagem de valores id cliente(sessao) de login para home
                                  builder: (context) => new HomePage1(
                                      id_sessao: widget.id_sessao),
                                ));
                              }
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
                              if (!indexBottom[1]) {
                                setState(() {
                                  indexBottom[0] = false;
                                  indexBottom[1] = true;
                                  indexBottom[2] = false;
                                });
                              }
                              if (widget.id_sessao == 0) {
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
                                // index_tab = 0;
                                Basicos.offset = 0; // zera o ofset do banco
                                Basicos.product_list =
                                    []; // zera o lista de produtos da pagina principal
                                Basicos.pagina = 1;
                                //Basicos.buscar_produto_home = ''; // limpa pesquisa
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  // aqui temos passagem de valores id cliente(sessao) de login para home
                                  builder: (context) => new ChatsPage(
                                      id_sessao: widget.id_sessao),
                                ));
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.assessment,
                                color: indexBottom[2]
                                    ? Color(0xFF012f7a)
                                    : Colors.black26,
                                size: 30),
                            onPressed: () {
                              if (!indexBottom[2]) {
                                setState(() {
                                  indexBottom[0] = false;
                                  indexBottom[1] = false;
                                  indexBottom[2] = true;
                                });
                              }
                              if (widget.id_sessao == 0) {
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
                                Basicos.pagina = 1;
                                Basicos.offset = 0;
                                Basicos.product_list = [];
                                Basicos.meus_pedidos = [];
                                // index_tab = 1;
                                //Basicos.buscar_produto_home = ''; // limpa pesquisa
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => new MeusPedidos(
                                            id_sessao: widget.id_sessao)));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              AnimatedPositioned(
                duration: Duration(milliseconds: 600),
                curve: Curves.easeOut,
                top: _topPadding,
                left: MediaQuery.of(context).size.width / 2 - 47,
                child: GestureDetector(
                    child: CircularSoftButton(
                      icon: Icon(
                        Icons.keyboard_arrow_up,
                        size: 44,
                        color: Color(0xFF012f7a),
                      ),
                    ),
                    onTap: () async {
                      setState(() {
                        setState(() {
                          controller_.animateTo(1,
                              duration: Duration(milliseconds: 600),
                              curve: Curves.elasticInOut);
                          zerarController = false;
                        });
                      });
                      Future.delayed(Duration(milliseconds: 350), () {
                        setState(() {
                          height = 315;
                          _bottom = -3;
                          _topPadding = -120;
                        });
                      });
                      // }
                    }),
              ),
//             //drawer app novo
              AnimatedPositioned(
                top: 0,
                bottom: 0,
                left: _isExpanded ? 0 : -MediaQuery.of(context).size.width - 55,
                duration: Duration(milliseconds: 400), //800
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 400), //800
                  curve: Curves.easeInQuint,
                  opacity: _isExpanded ? 1 : 0,
                  child: GestureDetector(
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onHorizontalDragStart: (details) {
                            if (!_isExpanded) {
                              setState(() {
                                _rightPadding =
                                    MediaQuery.of(context).size.width - 56;
                              });
                              Future.delayed(Duration(milliseconds: 200), () {
                                _controller.forward();
                              });
                              Future.delayed(Duration(milliseconds: 800), () {
                                setState(() {
                                  _isExpanded = true;
                                  _rightPadding = 20;
                                });
                              });
                            } else {
                              setState(() {
                                _isExpanded = false;
                                _rightPadding =
                                    MediaQuery.of(context).size.width - 56;
                              });
                              Future.delayed(Duration(milliseconds: 800), () {
                                setState(() {
                                  _rightPadding = 20;
                                });
                              });
                              Future.delayed(Duration(milliseconds: 1000), () {
                                _controller.reverse();
                              });
                            }
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width - 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(1),
                                  spreadRadius: 4,
                                  blurRadius: 7,
                                  offset: Offset(
                                      3, 3), // changes position of shadow
                                ),
                              ],
                              color: Color(0xFF012f7a),
                            ),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 40,
                                ),
                                ListTile(
                                  onTap: () {
                                    setState(() {
                                      _topPadding = 20;
                                    });
                                    if (widget.id_sessao == 0) {
                                      Basicos.offset =
                                          0; // zera o ofset do banco
                                      Basicos.product_list =
                                          []; // zera o lista de produtos da pagina principal
                                      Basicos.pagina = 1;
                                      //Basicos.buscar_produto_home = ''; // limpa pesquisa
                                      Future.delayed(
                                          Duration(milliseconds: 250), () {
                                        Navigator.of(context)
                                            .push(new MaterialPageRoute(
                                          // aqui temos passagem de valores id cliente(sessao) de login para home
                                          builder: (context) => new Login(),
                                        ));
                                      });
                                    } else {
                                      Future.delayed(
                                          Duration(milliseconds: 250), () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    new minhaConta(
                                                        id_sessao:
                                                            widget.id_sessao)));
                                      });
                                    }
                                  },
                                  title: Text(
                                    '${client_list[0]['nome_razao_social'].toString()}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: RichText(
                                    text: TextSpan(
                                      children: <InlineSpan>[
                                        TextSpan(
                                          text: '${client_list[0]['email'].toString()}\n' +
                                              'Local Retirada: ${client_list[0]['nome']} ',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    child: Icon(
                                      Icons.perm_identity,
                                      color: Colors.white,
                                    ),
                                    radius: 40,
                                  ),
                                ),
                                //                             GestureDetector(
                                //                               onTap: () {
                                // //                                Toast.show(
                                // //                                  "No momento só está disponível esta opção.",
                                // //                                  context,
                                // //                                  duration: Toast.LENGTH_LONG,
                                // //                                  gravity: Toast.CENTER,
                                // //                                );
                                //                               },
                                //                               child: Row(
                                //                                 mainAxisAlignment: MainAxisAlignment.end,
                                //                                 crossAxisAlignment: CrossAxisAlignment.center,
                                //                                 children: <Widget>[
                                //                                   RichText(
                                //                                       text: TextSpan(children: [
                                //                                     TextSpan(
                                //                                       text:
                                //                                           'Local Retirada: ${client_list[0]['nome']} ',
                                //                                       style: Theme.of(context)
                                //                                           .textTheme
                                //                                           .button
                                //                                           .copyWith(
                                //                                               color: Colors.white70,
                                //                                               fontSize: 14),
                                //                                     ),
                                //                                   ])),
                                //                                   Padding(
                                //                                     padding: const EdgeInsets.only(right: 32),
                                //                                     child:
                                //                                         Icon(Icons.arrow_drop_down, size: 34),
                                //                                   ),
                                //                                 ],
                                //                               ),
                                //                             ),
                                // SizedBox(
                                //   height: 10,
                                // ),
                                Divider(
                                  height: 50,
                                  thickness: 0.5,
                                  color: Colors.white.withOpacity(.3),
                                  indent: 32,
                                  endIndent: 32,
                                ),
                                Expanded(
                                  child: ListView(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    scrollDirection: Axis.vertical,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _topPadding = 20;
                                          });
                                          if (widget.id_sessao == 0) {
                                            Basicos.offset =
                                                0; // zera o ofset do banco
                                            Basicos.product_list =
                                                []; // zera o lista de produtos da pagina principal
                                            Basicos.pagina = 1;
                                            //Basicos.buscar_produto_home = ''; // limpa pesquisa
                                            Future.delayed(
                                                Duration(milliseconds: 250),
                                                () {
                                              Navigator.of(context)
                                                  .push(new MaterialPageRoute(
                                                // aqui temos passagem de valores id cliente(sessao) de login para home
                                                builder: (context) =>
                                                    new Login(),
                                              ));
                                            });
                                          } else {
                                            Future.delayed(
                                                Duration(milliseconds: 250),
                                                () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          new minhaConta(
                                                              id_sessao: widget
                                                                  .id_sessao)));
                                            });
                                          }
                                        },
                                        child: MenuItem(
                                          title: 'Minha Conta',
                                          icon: Icons.person,
                                          //                                      Icon(
                                          //                                        Icons.person,
                                          //                                        color: Colors.blueAccent,
                                          //                                      ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _topPadding = 20;
                                          });
                                          if (widget.id_sessao == 0) {
                                            Basicos.offset =
                                                0; // zera o ofset do banco
                                            Basicos.product_list =
                                                []; // zera o lista de produtos da pagina principal
                                            Basicos.pagina = 1;
                                            //Basicos.buscar_produto_home = ''; // limpa pesquisa
                                            Future.delayed(
                                                Duration(milliseconds: 250),
                                                () {
                                              Navigator.of(context)
                                                  .push(new MaterialPageRoute(
                                                // aqui temos passagem de valores id cliente(sessao) de login para home
                                                builder: (context) =>
                                                    new Login(),
                                              ));
                                            });
                                          } else {
                                            Basicos.offset = 0;
                                            Basicos.product_list = [];
                                            Basicos.meus_pedidos = [];
                                            // index_tab = 1;
                                            //Basicos.buscar_produto_home = ''; // limpa pesquisa
                                            Future.delayed(
                                                Duration(milliseconds: 250),
                                                () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MeusPedidos(
                                                          id_sessao:
                                                              widget.id_sessao),
                                                ),
                                              );
                                            });
                                          }
                                        }, //vai para tela de pedidos

                                        child: MenuItem(
                                          icon: Icons.list,
                                          title: "Meus Pedidos",
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _topPadding = 20;
                                          });
                                          if (widget.id_sessao == 0) {
                                            Basicos.offset =
                                                0; // zera o ofset do banco
                                            Basicos.product_list =
                                                []; // zera o lista de produtos da pagina principal
                                            Basicos.pagina = 1;
                                            //Basicos.buscar_produto_home = ''; // limpa pesquisa
                                            Future.delayed(
                                                Duration(milliseconds: 250),
                                                () {
                                              Navigator.of(context)
                                                  .push(new MaterialPageRoute(
                                                // aqui temos passagem de valores id cliente(sessao) de login para home
                                                builder: (context) =>
                                                    new Login(),
                                              ));
                                            });
                                          } else {
                                            Basicos.offset = 0;
                                            Basicos.product_list = [];
                                            Basicos.meus_pedidos = [];
                                            // index_tab = 1;
                                            //Basicos.buscar_produto_home = ''; // limpa pesquisa
                                            Future.delayed(
                                                Duration(milliseconds: 250),
                                                () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          new ChatsPage(
                                                              id_sessao: widget
                                                                  .id_sessao)));
                                            });
                                          }
                                        }, //vai para tela de pedidos
                                        child: MenuItem(
                                          icon: Icons.chat,
                                          title: "Chat",
                                        ),
                                      ),
                                      Divider(
                                        height: 50,
                                        thickness: 0.5,
                                        color: Colors.white.withOpacity(.3),
                                        indent: 15,
                                        endIndent: 15,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _topPadding = 20;
                                          });
                                          Future.delayed(
                                              Duration(milliseconds: 250), () {
                                            Navigator.of(context)
                                                .push(new MaterialPageRoute(
                                              // aqui temos passagem de valores id cliente(sessao) de login para home
                                              builder: (context) => new Sobre(
                                                  id_sessao: widget.id_sessao),
                                            ));
                                          });
                                        },
                                        child: MenuItem(
                                          icon: Icons.label,
                                          title: "Sobre",
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          //Link da pagina de Ajuda
                                          const url =
                                              "http://recoopsol.ic.ufmt.br/index.php/ajuda-app/";
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            throw 'erro $url';
                                          }
                                        },
                                        child: MenuItem(
                                          title: ('Ajuda'),
                                          icon: (Icons.help),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await removeValues(); //remove  cooke
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Login()));
                                        },
                                        child: MenuItem(
                                          icon: Icons.exit_to_app,
                                          title: "Sair",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!_isExpanded) {
                              setState(() {
                                _rightPadding =
                                    MediaQuery.of(context).size.width - 56;
                              });
                              Future.delayed(Duration(milliseconds: 200), () {
                                _controller.forward();
                              });
                              Future.delayed(Duration(milliseconds: 800), () {
                                setState(() {
                                  _isExpanded = true;
                                  _rightPadding = 20;
                                });
                              });
                            } else {
                              setState(() {
                                _isExpanded = false;
                                _rightPadding =
                                    MediaQuery.of(context).size.width - 56;
                              });
                              Future.delayed(Duration(milliseconds: 800), () {
                                setState(() {
                                  _rightPadding = 20;
                                });
                              });
                              Future.delayed(Duration(milliseconds: 1000), () {
                                _controller.reverse();
                              });
                            }
                          },
                          onHorizontalDragStart: (details) {
                            if (!_isExpanded) {
                              setState(() {
                                _rightPadding =
                                    MediaQuery.of(context).size.width - 56;
                              });
                              Future.delayed(Duration(milliseconds: 200), () {
                                _controller.forward();
                              });
                              Future.delayed(Duration(milliseconds: 800), () {
                                setState(() {
                                  _isExpanded = true;
                                  _rightPadding = 20;
                                });
                              });
                            } else {
                              setState(() {
                                _isExpanded = false;
                                _rightPadding =
                                    MediaQuery.of(context).size.width - 56;
                              });
                              Future.delayed(Duration(milliseconds: 800), () {
                                setState(() {
                                  _rightPadding = 20;
                                });
                              });
                              Future.delayed(Duration(milliseconds: 1000), () {
                                _controller.reverse();
                              });
                            }
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: 56,
                            color: Colors.white12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 600), //800
                curve: Curves.easeOut,
                right: _rightPadding,
                top: _topPadding == -90 ? 50 : -20,
                child: GestureDetector(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: EdgeInsets.only(left: 30, bottom: 30),
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                        child: SvgPicture.asset(
                          "icons/bag.svg",
                          height: 14,
                          color: _isExpanded ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  onTap: () async {
                    if (!_isExpanded) {
                      setState(() {
                        _rightPadding = MediaQuery.of(context).size.width - 56;
                      });
                      Future.delayed(Duration(milliseconds: 200), () {
                        _controller.forward();
                      });
                      Future.delayed(Duration(milliseconds: 800), () {
                        setState(() {
                          _isExpanded = true;
                          _rightPadding = 20;
                        });
                      });
                    } else {
                      setState(() {
                        _isExpanded = false;
                        _rightPadding = MediaQuery.of(context).size.width - 56;
                      });
                      Future.delayed(Duration(milliseconds: 800), () {
                        setState(() {
                          _rightPadding = 20;
                        });
                      });
                      Future.delayed(Duration(milliseconds: 1000), () {
                        _controller.reverse();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget detalheProduto() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhe Produto'),
        centerTitle: true,
      ),
    );
  }

  showDialogMesage(
      BuildContext context, String dias, String imagemDialog) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String isRightDay = prefs.getString('Day Mesage');
    AlertDialog alerta = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network('${Basicos.ip}/media/$imagemDialog', fit: BoxFit.cover),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                marquee,
                softWrap: true,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF012f7a),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
              prefs.setString('Day Mesage', DateTime.now().toString());
            },
            color: Color(0xFF012f7a),
            child: Text(
              'Entendi',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    if (dias == null) dias = '0';
    if (isRightDay == null ||
        (dias != '0' &&
            DateTime.now().isAfter(DateTime.parse(isRightDay)
                .add(Duration(days: int.parse(dias) - 1))))) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          print(isRightDay);
          print(DateTime.now());
          return alerta;
        },
      );
    }
  }

  // lista os produtos para preencher o grid
  Future<List> buscaProdutos(String categoria, String busca) async {
    //print(widget.id_sessao.toString() + '-');
    // print(categoria);
    //print(widget.id_sessao);
    // PaletteGenerator paletteGenerator;
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
      print("${Basicos.ip}/crud/?"
          "crud=consulta5.${categoria},${id_local_retirada},10,${Basicos.offset},${Basicos.buscar_produto_home}%");
      var res1 = await http
          .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
      //print(id_local_retirada);
      var res = Basicos.decodifica(res1.body);
      //print(res);
      if (res1.body.length > 2) {
        if (res1.statusCode == 200) {
          // converte a lista de consulta em uma lista dinamica
          List list = json.decode(res).cast<Map<String, dynamic>>();

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
              Basicos.product_list.add(list[i]);
              productsIDlist.add(list[i]['id']);
            }
          }
          produtosStream.sink.add(Basicos.product_list);
          busca_qtd_produtos(Basicos.product_list.length,
              Basicos.categoria_usada, Basicos.buscar_produto_home);
          Basicos.buscar_produto_home = '';
          return list;
        }
      }
    }
  }

  // lista os produtos para preencher o grid
  Future<List> buscaProdutosCrescente(String categoria, String busca) async {
    if (widget.id_sessao == 0) {
      id_local_retirada = '0';
    } else {
      await busca_id_local_retirada(); //local de retirada
    }
    if (id_local_retirada == '') {
      Toast.show("Erro ao selecionar a Empresa", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
          backgroundRadius: 0.0);
    } else {
      String link = '';

      if (widget.id_sessao == 0) {
        link = Basicos.codifica("${Basicos.ip}/crud/?"
            "crud=consultc-5.${categoria},${id_local_retirada},10,${Basicos.offset},${Basicos.buscar_produto_home}%"); //lista produto pela categoria, empresa e limit e offset
      } else {
        link = Basicos.codifica("${Basicos.ip}/crud/?"
            "crud=consultc5.${categoria},${id_local_retirada},10,${Basicos.offset},${Basicos.buscar_produto_home}%"); //lista produto pela categoria, empresa e limit e offset
      }
      var res1 = await http
          .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
      print("${Basicos.ip}/crud/?"
          "crud=consultc5.${categoria},${id_local_retirada},10,${Basicos.offset},${Basicos.buscar_produto_home}%");
      var res = Basicos.decodifica(res1.body);
      print(res1.statusCode);
      if (res1.body.length > 2) {
        if (res1.statusCode == 200) {
          // converte a lista de consulta em uma lista dinamica
          List list = json.decode(res).cast<Map<String, dynamic>>();
          print(list.length);
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
              Basicos.product_list.add(list[i]);
              productsIDlist.add(list[i]['id']);
            }
          }
          produtosStream.sink.add(Basicos.product_list);
          busca_qtd_produtos(Basicos.product_list.length,
              Basicos.categoria_usada, Basicos.buscar_produto_home);
          Basicos.buscar_produto_home = '';
          return list;
        }
      }
    }
  }

  // lista os produtos para preencher o grid
  Future<List> buscaProdutosDecrescente(String categoria, String busca) async {
    if (widget.id_sessao == 0) {
      id_local_retirada = '0';
    } else {
      await busca_id_local_retirada(); //local de retirada
    }
    if (id_local_retirada == '') {
      Toast.show("Erro ao selecionar a Empresa", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
          backgroundRadius: 0.0);
    } else {
      String link = '';

      if (widget.id_sessao == 0) {
        link = Basicos.codifica("${Basicos.ip}/crud/?"
            "crud=consultd-5.${categoria},${id_local_retirada},10,${Basicos.offset},${Basicos.buscar_produto_home}%"); //lista produto pela categoria, empresa e limit e offset
      } else {
        link = Basicos.codifica("${Basicos.ip}/crud/?"
            "crud=consultd5.${categoria},${id_local_retirada},10,${Basicos.offset},${Basicos.buscar_produto_home}%"); //lista produto pela categoria, empresa e limit e offset
      }
      var res1 = await http
          .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
      print("${Basicos.ip}/crud/?"
          "crud=consultd5.${categoria},${id_local_retirada},10,${Basicos.offset},${Basicos.buscar_produto_home}%");
      var res = Basicos.decodifica(res1.body);
      print(res1.statusCode);
      if (res1.body.length > 2) {
        if (res1.statusCode == 200) {
          // converte a lista de consulta em uma lista dinamica
          List list = json.decode(res).cast<Map<String, dynamic>>();
          print(list.length);
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
              Basicos.product_list.add(list[i]);
              productsIDlist.add(list[i]['id']);
            }
          }
          produtosStream.sink.add(Basicos.product_list);
          busca_qtd_produtos(Basicos.product_list.length,
              Basicos.categoria_usada, Basicos.buscar_produto_home);
          Basicos.buscar_produto_home = '';
          return list;
        }
      }
    }
  }

  // busca qt de produtos cadastrados
  // ignore: non_constant_identifier_names
  busca_qtd_produtos(int qtd_produtos, String categoria, String busca) {
    if (qtd_produtos == 0) {
      if (busca == null) {
        Toast.show("Nenhum Produto Cadastrado", context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            backgroundRadius: 0.0);
      } else {
        Toast.show(
            "Nenhum produto " + busca + ' encontrado nesta categoria', context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            backgroundRadius: 0.0);
      }
    }
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

// lista as categorias para preencher o combo
  Future<List> buscaCategorias() async {
    //print(widget.id_sessao);
    String link = Basicos.codifica("${Basicos.ip}/crud/?crud=consulta4.");
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    var res = Basicos.decodifica(res1.body);
    //print(res1.body);
    //print(res);
    if (res1.body.length > 2) {
      if (res1.statusCode == 200) {
        var list = json.decode(res) as List;
        list = list.map<Categoria>((json) => Categoria.fromJSON(json)).toList();
        //print(list);
        for (var i = 0, len = list.length; i < len; i++) {
          _category_list
              .add(list[i].id.toString() + '-' + list[i].descricao.toString());
        }

        if (widget.id_sessao == 0) {
          //print('111');
          client_list[0]['nome_razao_social'] = 'Convidado';
          client_list[0]['email'] = 'Convidado';
          client_list[0]['nome'] = 'Convidado';
        } else {
          await busca_cliente();
          await busca_qtd_carrinho();
          await busca_msg_chat();
        }
        return list;
      }
    }
  }

// busca nome e email do cliente
  Future<List> busca_cliente() async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consult16.${widget.id_sessao}");
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    var res = Basicos.decodifica(res1.body);
    //print(res);
    if (res1.body.length > 2) {
      if (res1.statusCode == 200) {
        var list = json.decode(res).cast<Map<String, dynamic>>();
        setState(() {
          client_list = list;
        });
        //print(client_list);
        return list;
      }
    }
  }

  // busca msg chat
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
          qtd_chat = 0;
        } else {
          qtd_chat = 1;
        }
        return qtd_chat;
      }
    }
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
        //   print(qtd);
        if (qtd.toString() == '0') {
          _mostrabadge = false;
        } else {
          _mostrabadge = true;
        }
        return qtd;
      }
    }
  }

// busca mensagem marqquee
  Future<String> buscaMarquee() async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consul-30.1"); // primeira msg
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    var res = Basicos.decodifica(res1.body); // print(res.body);
    // print(res);
    if (res1.body.length >= 1) {
      if (res1.statusCode == 200) {
        var list = json.decode(res).cast<Map<String, dynamic>>();
        print('lista consulta 30.1: ${list.toString()}');
        marquee = list[0]["msg_notifica"].toString();
        //  print(marquee);
      }
    }

    listaBanner = [];

    for (int i = 4; i < 14; i++) {
      String link2 = Basicos.codifica(
          "${Basicos.ip}/crud/?crud=consul-30.$i"); // primeira msg
      var res2 = await http
          .get(Uri.encodeFull(link2), headers: {"Accept": "application/json"});
      var res3 = Basicos.decodifica(res2.body);
      // print(res2.statusCode);
      if (res2.body.length >= 1) {
        if (res2.statusCode == 200) {
          try {
            var list = json.decode(res3).cast<Map<String, dynamic>>();
            if (list[0]["msg_notifica"] != null) {
              String image = list[0]["msg_notifica"].toString();
              print(image);
              setState(() {
                listaBanner.add(image);
              });
            }
          } catch (e) {
            print('error');
          }
        }
      }
    }
    print('Tamanho: ${listaBanner.length}');
    String dias;

    String link3 = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consul-30.14"); // primeira msg
    var res4 = await http
        .get(Uri.encodeFull(link3), headers: {"Accept": "application/json"});
    var res5 = Basicos.decodifica(res4.body);
    // print(res2.statusCode);
    if (res4.body.length >= 1) {
      if (res4.statusCode == 200) {
        try {
          var list = json.decode(res5).cast<Map<String, dynamic>>();
          print(list.toString());
          if (list[0]["descricao_msg"] != null) {
            dias = list[0]["descricao_msg"].toString();
            print(dias);
          }
        } catch (e) {
          print('error dias');
        }
      }
    }

    String link4 = Basicos.codifica("${Basicos.ip}/crud/?crud=consul-30.15");
    String imagemDialog;
    var res6 = await http
        .get(Uri.encodeFull(link4), headers: {"Accept": "application/json"});
    var res7 = Basicos.decodifica(res6.body);
    if (res6.body.length >= 1) {
      if (res6.statusCode == 200) {
        try {
          var list = json.decode(res7).cast<Map<String, dynamic>>();
          if (list[0]["msg_notifica"] != null) {
            imagemDialog = list[0]["msg_notifica"].toString();
          }
        } catch (e) {
          print('error');
        }
      }
    }
    print(dias);
    Future.delayed(Duration(milliseconds: 800),
        () => showDialogMesage(context, dias, imagemDialog));
    return ' ';
  }

  void circular(String tipo) {
    if (tipo == 'inicio') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          child: new Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
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
          ),
        ),
      );
    } else
      Navigator.pop(context);
  }

  void _buscar_produto() {
    //print('buscar');
    Basicos.buscar_produto_home = search.text;
    Basicos.offset = 0;
    Basicos.product_list = [];
    Basicos.pagina = 1;
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (context) => new HomePage1(id_sessao: widget.id_sessao),
    ));
  }
}

showAlertDialog1(BuildContext context, String marquee) {
  // configura o button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // configura o  AlertDialog
  AlertDialog alerta = AlertDialog(
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'images/delivery.jpg',
          fit: BoxFit.cover,
        ),
        Text(
          marquee,
          softWrap: true,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF012f7a),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        RaisedButton(
          onPressed: () => Navigator.pop(context),
          color: Color(0xFF012f7a),
          child: Text(
            'Entendi',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ), //Text("Não perca a promoção."),
    // actions: [
    //   okButton,
    // ],
  );

  // exibe o dialog
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return alerta;
    },
  );
}

Color cor_categoria() {
  if (Basicos.categoria_usada == '*')
    return kPrimaryColor;
  else
    return kTextColor.withOpacity(0.5);
}

//app novo ------------
class CustomMenuClippler extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    final width = size.width;
    final height = size.height;

    Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(-8, 8, 10, 16);
    path.quadraticBezierTo(width - 1, height / 2 - 20, width, height / 2);
    path.quadraticBezierTo(width + 1, height / 2 + 20, 10, height - 16);
    path.quadraticBezierTo(-8, height - 8, 0, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
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
removeValues() async {
  SharedPreferences prefs1 = await SharedPreferences.getInstance();
  prefs1.remove('email');
}

class Categoria {
  int id;
  String descricao;

  Categoria({
    this.id,
    this.descricao,
  });

  factory Categoria.fromJSON(Map<String, dynamic> jsonMap) {
    return Categoria(id: jsonMap['id'], descricao: jsonMap['descricao']);
  }
}
