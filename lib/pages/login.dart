import 'package:flutter/material.dart';
import 'package:prossumidor/pages/registrar.dart';
import 'package:prossumidor/pages/home.dart';
import 'package:prossumidor/pages/RecuperaSenha.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;

//import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formkey = new GlobalKey<FormState>();
  bool _validate = false;
  TextEditingController _emailTextController = new TextEditingController();
  TextEditingController _passwordTextController = new TextEditingController();
  bool hidePass = true, _isVisible = true;
  bool liga_circular = false;
  List usuario = [];
  TabController _tabController;
  int index_tab = 0;

  @override
  void initState() {
    super.initState;
    KeyboardVisibility.onChange.listen((bool visible) {
      setState(() {
        _isVisible = !visible;
      });
    });
    liga_circular = false;
    verifica_logado(); //verifica se houve login e esta armazenado na variavel de preferencias
  }

  Future<bool> onWillPop() async {
    Basicos.offset = 0;
    Basicos.pagina = 1;
    Basicos.product_list = [];
    Future.delayed(Duration(milliseconds: 250), () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HomePage1(
                id_sessao: 0,
              )));
    });
    return true;
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        // floatingActionButton: Visibility(
        //   visible: _isVisible,
        //   child: FloatingActionButton.extended(
        //     backgroundColor: kPrimaryColor,//Colors.blueAccent,
        //     onPressed: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(
        //           builder: (context) => HomePage1(
        //             id_sessao: 0,
        //           ),
        //         ),
        //       );
        //     },
        //     label: Text(
        //       'Iniciar como visitante',
        //       style: TextStyle(
        //         color: Colors.white,
        //         fontWeight: FontWeight.bold,
        //         fontSize: 14.0
        //       ),
        //     )
        //   ),
        // ),
        backgroundColor: Color(0xFF1a3d91),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 60.0),
                    //alignment: Alignment(2,4),
                    child: Center(
                      heightFactor: 1,
                      child: GestureDetector(
                        onTap: () {
                          Basicos.offset = 0;
                          Basicos.product_list = [];
                          Basicos.pagina = 1;
                          setState(() {
                            height = 260;
                          });
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HomePage1(
                                id_sessao: 0,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          'images/logo2-2-1.png',

                          width: 400.0,
//                height: 240.0,
                        ),
                      ),
                    )),

                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Form(
                    key: _formkey,
                    autovalidate: _validate, //valida  a entrada do email
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white.withOpacity(.8),
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: ListTile(
                          subtitle: TextFormField(
                              //autofocus: true,
                              controller: _emailTextController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email",
                                icon: Icon(Icons.alternate_email),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Insira um endereço de email';
                                } else {
                                  if (value.length < 3) {
                                    return "Email Tem Que Ter Pelo Menos 3 Caracteres";
                                  } else {
                                    Pattern pattern =
                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                    RegExp regex = new RegExp(pattern);
                                    if (!regex.hasMatch(value)) {
                                      return 'Insira um endereço de email válido';
                                    } else
                                      return null;
                                  }
                                }
                              }),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white.withOpacity(.8),
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: ListTile(
                          subtitle: TextFormField(
                            controller: _passwordTextController,
                            obscureText: hidePass,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Senha",
                              icon: Icon(Icons.lock_outline),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return "O campo password não pode ficar vazio";
                              } else if (value.length < 6) {
                                return "A senha tem que ter pelo menos 6 caracteres";
                              }
                              return null;
                            },
                          ),
                          trailing: IconButton(
                              icon: Icon(Icons.remove_red_eye),
                              onPressed: () {
                                setState(() {
                                  hidePass = !hidePass;
                                });
                              }),
                        ),
                      )),
                ),

                Material(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.blueAccent,
                    elevation: 0.0,
                    child: MaterialButton(
                      onPressed: () async {
                        if (_formkey.currentState.validate()) {
                          //print(_formkey.toString());
                          // valida formulario
                          // acesso ao banco de dados
                          circular('inicio'); // mostra circular indicator
                          String valida =
                              await getData(_emailTextController.text);
                          circular('fim'); // apaga circular indicator
                          if (valida == null)
                            Toast.show(
                                "Login Inválido, ou erro de Conexão", context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.CENTER,
                                backgroundRadius: 0.0);
                          else {
                            if (valida == 'inativo') {
                              // Toast.show(
                              //     "Seu usuário ainda não foi validado\n Aguarde que o Recoopsol vai enviar um email com a confirmação", context,
                              //     duration: Toast.LENGTH_LONG,
                              //     gravity: Toast.CENTER,
                              //     backgroundRadius: 0.0);
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return new AlertDialog(
                                      title: new Text(
                                        "Aguarde...",
                                        textAlign: TextAlign.center,
                                      ),
                                      content: new Text(
                                        "Seu usuário ainda não foi validado Aguarde que o Recoopsol vai enviar um email com a confirmação.",
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: <Widget>[
                                        new MaterialButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(
                                                context); // aciona fechar do alerta
                                          },
                                          child: new Text("Fechar"),
                                        )
                                      ],
                                    );
                                  });
                            } else {
                              await addStringToSF(_emailTextController
                                  .text); // armazena email para lembrar do login
                              Navigator.of(context).push(new MaterialPageRoute(
                                // aqui temos passagem de valores id cliente(sessao) de login para home
                                builder: (context) => new HomePage1(
                                    id_sessao: usuario[0]['id'].toString()),
                              ));
                            }
                          }
                        } else {}
                      },
                      minWidth: MediaQuery.of(context).size.width,
                      child: Text(
                        "Entrar",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0),
                      ),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14.0, 30.0, 14.0, 0.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RecuperaSenha())); //recupera senha
                        },
                        child: Text(
                          "< Recuperar Senha >",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
//===============verificar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Registrar()));
                        },
                        child: Text(
                          "< Criar Uma Conta > ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
//======verificar
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getData(String newsType) async {
    //  print(await getValuesSF());
    //print(newsType);
    String link =
        Basicos.codifica("${Basicos.ip}/crud/?crud=consulta1.${newsType}");
    try {
      var res1 = await http
          .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
      var res = Basicos.decodifica(res1.body);
      //print(res);
      if (res1.body.length > 2) {
        if (res1.statusCode == 200) {
          //gerar criptografia senha terminar depois
          List list = json.decode(res).cast<Map<String, dynamic>>();
          usuario = list;
          //print(list);
          if (usuario.isNotEmpty) {
            Basicos.local_retirada_id =
                usuario[0]['local_retirada_id'].toString();
            //print(Basicos.local_retirada_id);
//            Basicos.empresa_id =
//            usuario[0]['empresa_id'].toString();

            if ((usuario[0]['email'].toString() == _emailTextController.text) &&
                Basicos.decodificapwss(usuario[0]['senha'].toString()) ==
                    _passwordTextController.text) {
              return "confirmado";
            } else {
              return null;
            }
          } else {
            String link = Basicos.codifica(
                "${Basicos.ip}/crud/?crud=consult-1.${newsType}");
            var res1 = await http.get(Uri.encodeFull(link),
                headers: {"Accept": "application/json"});
            var res = Basicos.decodifica(res1.body);
            //print(res);
            if (res1.body.length > 2) {
              if (res1.statusCode == 200) {
                //gerar criptografia senha terminar depois
                List list = json.decode(res).cast<Map<String, dynamic>>();
                usuario = list;
                //print(list);
                if (usuario.isNotEmpty)
                  return 'inativo';
                else
                  return null;
              }
            }
          }
        }
        // return list;
      }
    } on Exception catch (E) {
      showDialog(
          context: context,
          builder: (context) {
            return new AlertDialog(
              title: new Text("Erro"),
              content: new Text("Falha na Conexão"),
              actions: <Widget>[
                new MaterialButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(context); // aciona fechar do alerta
                  },
                  child: new Text("Fechar"),
                )
              ],
            );
          });
    }
  }

  addStringToSF(String s) async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    prefs1.setString('email', s);
  }

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

  void verifica_logado() async {
    final email = await getValuesSF();
    if (email != '') {
      // print(email);
      String link =
          Basicos.codifica("${Basicos.ip}/crud/?crud=consulta1.${email}");
      try {
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
            // print(Basicos.empresa_id );
          }
        }

        Navigator.of(context).push(new MaterialPageRoute(
          // aqui temos passagem de valores id cliente(sessao) de login para home
          builder: (context) =>
              new HomePage1(id_sessao: usuario[0]['id'].toString()),
        ));
      } on Exception catch (E) {
        showDialog(
            context: context,
            builder: (context) {
              return new AlertDialog(
                title: new Text("Erro"),
                content: new Text("Falha na Conexão"),
                actions: <Widget>[
                  new MaterialButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(context); // aciona fechar do alerta
                    },
                    child: new Text("Fechar"),
                  )
                ],
              );
            });
      }
    }
  }

// mostra circular indicator
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
}
