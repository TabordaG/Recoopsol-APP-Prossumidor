import 'dart:math';

import 'package:prossumidor/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dados_basicos.dart';
import 'home.dart';
import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

class Registrar extends StatefulWidget {
  @override
  _RegistrarState createState() => _RegistrarState();
}

class _RegistrarState extends State<Registrar> {
  final _formKey = GlobalKey<FormState>();
  List<String> lista_empresas = [];

  //UserServices _userServices = UserServices();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _cpfTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _telefoneTextController = TextEditingController();
  TextEditingController _codeTextController = TextEditingController();
  TextEditingController _confirm_passwordTextController =
      TextEditingController();
  TextEditingController _enderecoTextController = TextEditingController();
  TextEditingController _bairroTextController = TextEditingController();
  TextEditingController _cidadeTextController = TextEditingController();
  TextEditingController _cepTextController = TextEditingController();
  TextEditingController _estadoTextController = TextEditingController();
  TextEditingController _numeroTextController = TextEditingController();
  TextEditingController _complementoTextController = TextEditingController();

  String gender;
  String groupValue = "Masculino";
  bool hidePass = true;
  bool loading = false;
  String _selectedId;
  double top = -60;
  List usuario = [];
  bool termo = false; // check boc termo de uso

  @override
  void initState() {
    local_retirada().then((resultado) {
      setState(() {});
    });
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        top = 25;
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      ListView(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(left: 20, top: 60, right: 20, bottom: 20),
            child: Text(
              "Dados Cadastrais", //"Simple way to find \nTasty food",
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10.0, top: 0, bottom: 5),
              child: Center(
                child: Container(
                  //heiight: 710

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 0),
                            color: Colors.white,
                            height: 100,
                            child: GestureDetector(
                                child: new CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.blueAccent,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ))),
                          ),

//                                    TITULO *************************************************
                          Padding(
                            padding: EdgeInsets.only(left: 15.0, top: 18.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Dados Pessoais",
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(fontSize: 18),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Divider(
                            height: 5.0,
                            indent: 20,
                            endIndent: 20,
                          ),

                          Padding(padding: EdgeInsets.only(bottom: 10)),

                          Container(
                            height: 50,
                            alignment: Alignment(0, 0),
                            padding: const EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.transparent,
                                elevation: 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      controller: _nameTextController,
                                      decoration: InputDecoration(
                                        suffix: Text('Nome',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14.0,
                                            )),
                                        hintText: "Nome",
                                        icon: Icon(Icons.person_outline),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1,
                                              color:
                                                  Colors.grey.withOpacity(0.2)),
                                        ),
                                        counterText:
                                            "", // remove os numero do contador do maxleng
                                      ),
                                      maxLength: 50,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "O Nome não pode ficar em branco";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            padding: const EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 15.0, 20.0, 0.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.transparent,
                                elevation: 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      controller: _cpfTextController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        suffix: Text('CPF',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14.0,
                                            )),
                                        hintText: "CPF",
                                        icon: Icon(Icons.content_paste),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.2))),
                                        counterText:
                                            "", // remove os numero do contador do maxleng
                                      ),
                                      maxLength: 11,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Insira um CPF válido';
                                        } else {
                                          if (value.length < 11) {
                                            return "CPF Tem Que Ter Pelo Menos 11 Dígitos";
                                          } else {
                                            Pattern pattern =
                                                '([0-9]{2}[\.]?[0-9]{3}[\.]?[0-9]{3}[\/]?[0-9]{4}[-]?[0-9]{2})|([0-9]{3}[\.]?[0-9]{3}[\.]?[0-9]{3}[-]?[0-9]{2})';
                                            RegExp regex = new RegExp(pattern);
                                            if (!regex.hasMatch(value)) {
                                              return 'Insira um CPF válido';
                                            } else
                                              return null;
                                          }
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(0),
                            height: 50,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.transparent,
                                elevation: 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      controller: _telefoneTextController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        suffix: Text('Telefone',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14.0,
                                            )),
                                        hintText: "Telefone",
                                        icon: Icon(Icons.settings_cell),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.2))),
                                        counterText:
                                            "", // remove os numero do contador do maxleng
                                      ),
                                      maxLength: 11,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Insira um telefone';
                                        } else {
                                          if (value.length < 10) {
                                            return "Telefone com 10 ou 11 numeros (ex.65XXXXXNNNN)";
                                          } else {
                                            Pattern pattern = '([0-9]{10})';
                                            RegExp regex = new RegExp(pattern);
                                            if (!regex.hasMatch(value)) {
                                              return 'Insira um numero de telefone válido';
                                            } else if (value.length > 11) {
                                              return "Numero muito grande";
                                            } else
                                              return null;
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.all(0),
                            height: 50,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: new Material(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.transparent,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: ListTile(
                                        title: Text("Mas:",
                                            style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: 15)),
                                        trailing: Radio(
                                            value: "Masculino",
                                            groupValue: groupValue,
                                            onChanged: (e) => valueChanged(e)),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListTile(
                                        title: Text("Fem:",
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: 15)),
                                        trailing: Radio(
                                            value: "Feminino",
                                            groupValue: groupValue,
                                            onChanged: (e) => valueChanged(e)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

//                          TITULO ************************************************************

                          Padding(
                            padding: EdgeInsets.only(left: 15.0, top: 20.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Endereço",
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(fontSize: 18),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Divider(
                            height: 5.0,
                            indent: 20,
                            endIndent: 20,
                          ),
                          Container(
                            height: 60,
                            alignment: Alignment(0, 0),
                            padding: const EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                      controller: _enderecoTextController,
                                      decoration: InputDecoration(
                                          suffix: Text('Endereço',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 14.0,
                                              )),
                                          hintText: "Endereço",
                                          counterText: "",
                                          // remove os numero do contador do maxleng
                                          icon: Icon(
                                            Icons.location_city,
                                          )
                                          // border: InputBorder.none,
                                          ),
                                      maxLength: 49,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "O endereço não pode ficar em branco";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Container(
                            height: 60,
                            alignment: Alignment(0, 0),
                            padding: const EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                      controller: _numeroTextController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          suffix: Text('Número',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 14.0,
                                              )),
                                          hintText: "Número",
                                          counterText: "",
                                          // remove os numero do contador do maxleng
                                          icon: Icon(
                                            Icons.confirmation_number,
                                          )
                                          // border: InputBorder.none,
                                          ),
                                      maxLength: 9,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "O Número não pode ficar em branco";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Container(
                            height: 60,
                            alignment: Alignment(0, 0),
                            padding: const EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                      controller: _complementoTextController,
                                      decoration: InputDecoration(
                                          suffix: Text('Complemento',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 14.0,
                                              )),
                                          hintText: "Complemento",
                                          counterText: "",
                                          // remove os numero do contador do maxleng
                                          icon: Icon(
                                            Icons.save_alt,
                                          )
                                          // border: InputBorder.none,
                                          ),
                                      maxLength: 29,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "O Complemento não pode ficar em branco";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Container(
                            height: 60,
                            alignment: Alignment(0, 0),
                            padding: const EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                      controller: _bairroTextController,
                                      decoration: InputDecoration(
                                          suffix: Text('Bairro',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 14.0,
                                              )),
                                          hintText: "Bairro",
                                          counterText: "",
                                          // remove os numero do contador do maxleng
                                          icon: Icon(
                                            Icons.save_alt,
                                          )
                                          // border: InputBorder.none,
                                          ),
                                      maxLength: 49,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "O Bairro não pode ficar em branco";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            alignment: Alignment(0, 0),
                            padding: const EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                      controller: _cidadeTextController,
                                      decoration: InputDecoration(
                                          suffix: Text('Cidade',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 14.0,
                                              )),
                                          hintText: "Cidade",
                                          counterText: "",
                                          // remove os numero do contador do maxleng
                                          icon: Icon(
                                            Icons.location_on,
                                          )
                                          // border: InputBorder.none,
                                          ),
                                      maxLength: 49,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "A cidade não pode ficar em branco";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            alignment: Alignment(0, 0),
                            padding: const EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      keyboardType:
                                          TextInputType.numberWithOptions(),
                                      //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                      controller: _cepTextController,
                                      decoration: InputDecoration(
                                          suffix: Text('CEP',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 14.0,
                                              )),
                                          hintText: "CEP",
                                          counterText: "",
                                          // remove os numero do contador do maxleng
                                          icon: Icon(
                                            Icons.local_post_office,
                                          )
                                          // border: InputBorder.none,
                                          ),
                                      maxLength: 8,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "O cep não pode ficar em branco";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            alignment: Alignment(0, 0),
                            padding: const EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                      controller: _estadoTextController,
                                      decoration: InputDecoration(
                                          suffix: Text('Estado',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 14.0,
                                              )),
                                          hintText: "Estado",
                                          counterText: "",
                                          // remove os numero do contador do maxleng
                                          icon: Icon(
                                            Icons.account_balance,
                                          )
                                          // border: InputBorder.none,
                                          ),
                                      maxLength: 2,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "O Estado não pode ficar em branco";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

//                          TITULO ************************************************************
                          Padding(
                            padding: EdgeInsets.only(left: 15.0, top: 20.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Dados de Conta",
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(fontSize: 18),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Divider(
                            height: 5.0,
                            indent: 20,
                            endIndent: 20,
                          ),

                          Container(
                            padding: const EdgeInsets.all(0),
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.transparent,
                                elevation: 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      controller: _emailTextController,
                                      decoration: InputDecoration(
                                          suffix: Text('Email',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 14.0,
                                              )),
                                          hintText: "Email",
                                          icon: Icon(Icons.alternate_email),
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.2)))),
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
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(0),
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 15.0, 20.0, 0.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.transparent,
                                elevation: 0.0,
                                child: ListTile(
                                  leading: Icon(Icons.local_shipping),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 0.0, 10.0, 0.0),
                                    child: new DropdownButton<String>(
                                      isExpanded: true,
                                      hint: const Text(
                                        "Local de Retirada",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black54,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      value: _selectedId,
                                      onChanged: (String value) {
                                        setState(() {
                                          _selectedId = value;
                                        });
                                      },
                                      items: lista_empresas.map((String value) {
                                        return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(
                                              value.substring(
                                                  value.indexOf('-', 0) + 1,
                                                  value.length),
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black54,
                                                fontSize: 15.0,
                                              ),
                                            ));
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      25.0, 15.0, 0.0, 0.0),
                                  child: Text('Senha:',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontSize: 16.0,
                                      )),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(0),
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.transparent,
                                elevation: 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      controller: _passwordTextController,
                                      obscureText: hidePass,
                                      decoration: InputDecoration(
                                        suffix: Text('Senha',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14.0,
                                            )),
                                        hintText: "Senha",
                                        icon: Icon(Icons.lock_outline),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.2))),
                                      ),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "A Senha não pode ficar em branco";
                                        } else if (value.length < 6) {
                                          return "A Senha tem que ter pelo menos 6 caracteres";
                                        }
                                        return null;
                                      },
                                    ),
                                    trailing: IconButton(
                                        icon: Icon(Icons.remove_red_eye),
                                        onPressed: () {
                                          setState(() {
                                            hidePass = false;
                                          });
                                        }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(0),
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.transparent,
                                elevation: 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: ListTile(
                                    title: TextFormField(
                                      controller:
                                          _confirm_passwordTextController,
                                      obscureText: hidePass,
                                      decoration: InputDecoration(
                                          suffix: Text('Confirma Senha',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 14.0,
                                              )),
                                          hintText: "Confirma Senha",
                                          icon: Icon(Icons.phonelink_lock),
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.2)))),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "A Senha não pode ficar em branco";
                                        } else if (value.length < 6) {
                                          return "A Senha tem que ter pelo menos 6 caracteres";
                                        }
                                        return null;
                                      },
                                    ),
                                    trailing: IconButton(
                                        icon: Icon(Icons.remove_red_eye),
                                        onPressed: () {
                                          setState(() {
                                            hidePass = false;
                                          });
                                        }),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.all(0),
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: new Material(
                                borderRadius: BorderRadius.circular(20.0),
                                //color: Colors.grey.withOpacity(0.2),
                                color: Colors.white,
                                child: Row(
                                  children: <Widget>[
                                    // Expanded(
                                    MaterialButton(
                                        onPressed: () async {
                                          //http://recoopsol.ic.ufmt.br/index.php/termo-de-uso/
                                          //Link da pagina de Termo
                                          const url =
                                              "http://recoopsol.ic.ufmt.br/index.php/termo-de-uso";
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            throw 'erro $url';
                                          }
                                        },

                                        //  child: ListTile(
                                        child: Container(
                                          //color: Colors.blueAccent,
                                          width: 190,
                                          child: Text("Lí o Termo de Uso",
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: Colors.blueAccent,
                                                  fontSize: 18)),
                                        )
                                        // ),
                                        ),
                                    //),
                                    Expanded(
                                      // child: ListTile(
//                                        title: Text("Fem:",
//                                            textAlign: TextAlign.end,
//                                            style: TextStyle(
//                                                color: Colors.blueAccent,
//                                                fontSize: 15)),
                                      child: Checkbox(
                                        value: termo,
                                        onChanged: _onTermoChanged,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding:
                                EdgeInsets.only(right: 40, left: 40, top: 20),
                            child: FlatButton(
                              color: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              onPressed: () async {
                                // circular('inicio');
                                String result = await validateForm();
                                // print(result);
                                // circular('fim');
                                if (result == "sucesso") {
                                  circular(
                                      'inicio'); // mostra circular indicator
                                  String valida =
                                      await getData(_emailTextController.text);
                                  circular('fim'); // apaga circular indicator
                                  // print(valida);

                                  if (valida == null)
                                    Toast.show(
                                        "Cadastro inválido, ou erro de conexão",
                                        context,
                                        duration: Toast.LENGTH_LONG,
                                        gravity: Toast.CENTER,
                                        backgroundRadius: 0.0);
                                  else {
                                    // await addStringToSF(_emailTextController
                                    //     .text); // armazena email para lembrar do login
                                    // Navigator.of(context)
                                    //     .push(new MaterialPageRoute(
                                    //   // aqui temos passagem de valores id cliente(sessao) de login para home
                                    //   builder: (context) => new HomePage1(
                                    //       id_sessao:
                                    //           usuario[0]['id'].toString()),
                                    // ));
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Login()));
                                  }
                                } else {
                                  // Toast.show(
                                  //   "Erro ao cadastrar, verifique todos os campos",
                                  //   context,
                                  //   duration: Toast.LENGTH_LONG,
                                  //   gravity: Toast.CENTER,
                                  //   backgroundRadius: 0.0
                                  // );
                                }
                              },
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text('Registrar',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(color: Colors.white)),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 0.0,
                                  top: 20.0,
                                  right: 0.0,
                                  bottom: 0.0),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Tenho uma conta",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.blueAccent, fontSize: 14),
                                  ))),

                          Padding(padding: EdgeInsets.only(top: 30))
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
        ],
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Login())); //ALTERAR A PAGINA ********************
                });

                //new minhaConta(id_sessao: widget.id_sessao)));
              }),
          radius: 22,
        ),
      ),
//                          ]
//                        ),
    ]));
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

  void _onTermoChanged(bool newValue) => setState(() {
        termo = newValue;
      });

// insere Clientes
  Future<String> validateForm() async {
    FormState formState = _formKey.currentState;
    String teste1, msg1, msg2;
    if (termo == true) {
      if (formState.validate()) {
        String teste = await emailCadastrado();
        if (_passwordTextController.text ==
            _confirm_passwordTextController.text)
          teste1 = 'livre';
        else
          teste1 = 'falha_senha';
        //  print(teste);
        //  print(teste1);
        if (teste == "livre" && teste1 == "livre") {
          if (_selectedId == null) {
            //   print('falha local');
            return "falha_local";
          } else {
            // se chegou ate aqui esta validado e email nao existe =========================
            //gera numero aleatorio com 4 digitos
            var rng = new Random();
            String code = '';
            // var code = new List.generate(10, (_) => rng.nextInt(1000)); // lista de 10 numeros aleatorios entre zero e mil
            for (int i = 0; i < 4; i++) {
              code = code + rng.nextInt(10).toString();
            }
            // envia email com o codigo
            //print(code);
            circular('inicio');
            String retorno = await envia_email(_emailTextController.text, code);
            circular('fim');
            // print(retorno);
            if (retorno == 'sucesso') {
              await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return new AlertDialog(
                      title: new Text(
                        "Insira o código de confirmação de registro, enviado para seu email.",
                        textAlign: TextAlign.center,
                      ),
                      content: Container(
                        padding: const EdgeInsets.all(0),
                        height: 60,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                          child: Material(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.grey.withOpacity(0.2),
                            elevation: 0.0,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: ListTile(
                                title: TextFormField(
                                  controller: _codeTextController,
                                  //obscureText: hidePass,
                                  decoration: InputDecoration(
                                      hintText: "Código",
                                      //  icon: Icon(Icons.lock_outline),
                                      border: InputBorder.none),
                                ),
                                trailing: IconButton(
                                    icon: Icon(Icons.remove_red_eye),
                                    onPressed: () {
                                      setState(() {
                                        hidePass = false;
                                      });
                                    }),
                              ),
                            ),
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        new MaterialButton(
                          onPressed: () async {
                            if (code == _codeTextController.text) {
                              // se email livre
                              String link = Basicos.codifica(
                                  "${Basicos.ip}/crud/?crud=consulta2."
                                  "${removeCaracterEspecial(_nameTextController.text)},"
                                  "${_cpfTextController.text},"
                                  "${_telefoneTextController.text},"
                                  "${groupValue.toUpperCase()}," //masculino ou feminino
                                  "${_emailTextController.text.toLowerCase()},"
                                  "${Basicos.codificapwss(_passwordTextController.text)},"
                                  "${_selectedId.substring(0, _selectedId.indexOf('-'))},"
                                  "${removeCaracterEspecial(_enderecoTextController.text)},"
                                  "${removeCaracterEspecial(_bairroTextController.text)},"
                                  "${removeCaracterEspecial(_cidadeTextController.text)},"
                                  "${_cepTextController.text},"
                                  "${removeCaracterEspecial(_estadoTextController.text)},"
                                  "${_numeroTextController.text},"
                                  "${removeCaracterEspecial(_complementoTextController.text)},");
                              circular('inicio');
                              var res1 = await http.get(Uri.encodeFull(link),
                                  headers: {"Accept": "application/json"});
                              circular('fim');
                              var res = Basicos.decodifica(res1.body);
                              if (res1.body.length > 2) {
                                if (res1.statusCode == 200) {
                                  //var list = json.decode(res) as String;
                                  //List list = json.decode(res).cast<Map<String, dynamic>>();
                                  //return list;
                                  //print('s');
                                  Navigator.of(context)
                                      .pop(context); // aciona fechar do alerta
                                  Toast.show(
                                      "Cadastro Realizado Com Sucesso", context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.CENTER,
                                      backgroundRadius: 0.0);
                                  //  Navigator.pushReplacement(
                                  //      context,
                                  //      MaterialPageRoute(
                                  //          builder: (context) => Login()));

                                  return "sucesso";
                                }
                              }
                            } else {
                              Navigator.of(context)
                                  .pop(context); // aciona fechar do alerta
                              _codeTextController.text = '';
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return new AlertDialog(
                                      title: new Text(
                                        "Email não validado ",
                                        textAlign: TextAlign.center,
                                      ),
                                      content: new Text(
                                        "Código Inválido, ou entre em contato recoopsol@ic.ufmt.br",
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
                            }
                          },
                          child: new Text("Confirmar"),
                        )
                      ],
                    );
                  });
              return 'sucesso';
            }
          }
        } else {
          msg1 = "Usuário já Cadastrado  ";
          msg2 = "Tente a Recuperação de Senha ou Use Outro Nome e Email";
          //print(teste1);
          if (teste1 == 'falha_senha') {
            msg1 = 'Senhas Diferentes';
            msg2 = 'Verifique se as senhas digitadas são iguais';
          }
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return new AlertDialog(
                  title: new Text(
                    msg1,
                    textAlign: TextAlign.center,
                  ),
                  content: new Text(
                    msg2,
                    textAlign: TextAlign.center,
                  ),
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
          return "erro_email";
        }
      } else {
        Toast.show("Campos com erros", context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            backgroundRadius: 0.0);
      }
    } else {
      Toast.show(
          "Leia o Termo de Uso e Marque a Leiura dos Termos de Uso do Aplicativo",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
          backgroundRadius: 20.0);
    }
  }

  addStringToSF(String s) async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    prefs1.setString('email', s);
  }

  Future<String> getData(String newsType) async {
    //  print(await getValuesSF());
    //print(newsType);
    String link =
        //Basicos.codifica("${Basicos.ip}/crud/?crud=consulta1.${newsType}"); //auto login
        Basicos.codifica(
            "${Basicos.ip}/crud/?crud=consult-1.${newsType}"); // validar login
    try {
      var res1 = await http
          .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
      var res = Basicos.decodifica(res1.body);
      //print(res1.body);
      if (res1.body.length > 2) {
        if (res1.statusCode == 200) {
          //gerar criptografia senha terminar depois
          List list = json.decode(res).cast<Map<String, dynamic>>();
          usuario = list;
          // print(list);
          if (usuario.isNotEmpty) {
            Basicos.local_retirada_id =
                usuario[0]['local_retirada_id'].toString();
            //print(Basicos.local_retirada_id);
//            Basicos.empresa_id =
//            usuario[0]['empresa_id'].toString();

            if ((usuario[0]['email'].toString() == _emailTextController.text) &&
                Basicos.decodificapwss((usuario[0]['senha'].toString())) ==
                    _passwordTextController.text) {
              return "confirmado";
            } else {
              return null;
            }
          } else
            return null;
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
      }
    } else
      return 'falha';
  }

  // carrega lista de empresas local de retirada
  Future<List> local_retirada() async {
    // verifica empresas
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consult20.${_emailTextController.text.toLowerCase()}");
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    var res = Basicos.decodifica(res1.body);
    //print(res.body);
    if (res1.body.length > 2) {
      if (res1.statusCode == 200) {
        List list = json.decode(res).cast<Map<String, dynamic>>();
        //print(list[0]['id']);
        for (var i = 0, len = list.length; i < len; i++) {
          lista_empresas
              .add(list[i]['id'].toString() + '-' + list[i]['nome'].toString());
        }
        //print(_selectedId);
        return list;
      }
    }
//    //lista empresas
  }

  // envia email confirmação cadastro
  Future<String> envia_email(String email, String mensagem) async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consult25.${email},${mensagem}");
    //print("${Basicos.ip}/crud/?crud=consult25.${email},${mensagem}");
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    var res = Basicos.decodifica(res1.body);
    //print(res);
    return res;
  }

  // mostra circular indicator
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

  String removeCaracterEspecial(String texto) {
    // remove aspas, virgula e *
    String nova1 = texto.replaceAll(",", " ");
    String nova2 = nova1.replaceAll("\"", " ");
    String nova3 = nova2.replaceAll("*", " ");
    String novaf = nova3.replaceAll("'", " ");
    return novaf;
  }
}
