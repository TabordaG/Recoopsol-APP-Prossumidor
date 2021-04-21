import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:flutter/material.dart';
import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:prossumidor/pages/home.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:toast/toast.dart';

import 'login.dart';

class RecuperaSenha extends StatefulWidget {
  @override
  _RecuperaSenhaState createState() => _RecuperaSenhaState();
}

class _RecuperaSenhaState extends State<RecuperaSenha> {
  final _formKey = GlobalKey<FormState>();

  //UserServices _userServices = UserServices();
  TextEditingController _emailTextController = TextEditingController();
  String gender;
  String groupValue = "Masculino";
  bool hidePass = true;
  bool loading = false;
  double top = -60;
  // funcao que envia email
  _sendEmail() async {
    final String _email = 'mailto:' +
        _emailTextController.text +
        '?subject=' +
        //_subjectController.text +
        '&body=';
    //_bodyController.text;
    try {
      await launch(_email);
    } catch (e) {
      throw 'Could not Call Phone';
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        top = 25;
      });
    });
  }

  Future<bool> onWillPop() async {
    // setState(() {
    //   top = -60;
    // });
    // Future.delayed(Duration(milliseconds: 200), () {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => Login()
    //     )
    //   );
    // });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10.0, top: 8, bottom: 5),
                child: Center(
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[350],
                          blurRadius:
                              20.0, // has the effect of softening the shadow
                        )
                      ],
                    ),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 20, right: 20, top: 30),
                              child: Text(
                                'Recuperar Senha',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 40, bottom: 30),
                              child: Text(
                                'Informe seu e-mail para que possamos enviar a recuperação da senha.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              height: 60,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10.0, top: 0, bottom: 0),
                                child: Material(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.grey.withOpacity(0.2),
                                  elevation: 0.0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 14.0, bottom: 15),
                                    child: ListTile(
                                      title: TextFormField(
                                        controller: _emailTextController,
                                        decoration: InputDecoration(
                                            hintText: "Email",
                                            icon: Icon(Icons.alternate_email),
                                            border: InputBorder.none),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            Pattern pattern =
                                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                            RegExp regex = new RegExp(pattern);
                                            if (!regex.hasMatch(value))
                                              return 'Entre com um email válido';
                                            else
                                              return null;
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20.0, top: 15, bottom: 15),
                              child: Material(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.blueAccent,
                                  elevation: 0.0,
                                  child: MaterialButton(
                                    onPressed: () async {
                                      validateForm();
                                      if (await emailCadastrado() == 'existe') {
                                        envia_email(_emailTextController.text,
                                            'texto_email');
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Login()));
                                      } else
                                        Toast.show(
                                            "Email Não localizado", context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.CENTER,
                                            backgroundRadius: 0.0);
                                    },
                                    minWidth: MediaQuery.of(context).size.width,
                                    child: Text(
                                      "Recuperar Senha",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                  )),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Tenho uma conta",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 14),
                                    ))),
                          ],
                        )),
                  ),
                )),
            Visibility(
              visible: loading ?? true,
              child: Center(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.white.withOpacity(0.9),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 400),
              top: top,
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
                        top = -60;
                      });
                      Future.delayed(Duration(milliseconds: 200), () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      });

                      //new minhaConta(id_sessao: widget.id_sessao)));
                    }),
                radius: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  valueChanged(e) {
    setState(() {
      if (e == "Masculino") {
        groupValue = e;
        gender = e;
      } else if (e == "Feminino") {
        groupValue = e;
        gender = e;
      }
    });
  }

  Future validateForm() async {
    FormState formState = _formKey.currentState;

    if (formState.validate()) {
      String user = "teste"; //await firebaseAuth.currentUser();
      if (user == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage1()));
      }
    }
  }

  // verifica se email já cadastrado
  Future<String> emailCadastrado() async {
    FormState formState = _formKey.currentState;
    if (formState.validate()) {
      // verifica se email ja cadastrado
      String link = Basicos.codifica(
          "${Basicos.ip}/crud/?crud=consulta3.${_emailTextController.text.toLowerCase()}");
      var res1 = await http
          .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
      var res = Basicos.decodifica(res1.body);
      //print(res);
      if (res1.body.length > 2) {
        if (res1.statusCode == 200) {
          List list = json.decode(res).cast<Map<String, dynamic>>();
          if (list.isEmpty)
            return 'livre';
          else
            return 'existe';
        }
      } else
        return 'falha';
      // verifica se email ja cadastrado
    }
  }

  // envia email
  Future<String> envia_email(String email, String mensagem) async {
    FormState formState = _formKey.currentState;
    if (formState.validate()) {
      String link = Basicos.codifica(
          "${Basicos.ip}/crud/?crud=consult24.${email},${mensagem}");
      // print("${Basicos.ip}/crud/?crud=consult24.${email},${mensagem}");
      var res1 = await http
          .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
      var res = Basicos.decodifica(res1.body);
      // print('teste');
      if (res1.body.length > 2) {
        if (res1.statusCode == 200) {
          return 'existe';
        }
      } else
        return 'falha';
    }
  }
}
