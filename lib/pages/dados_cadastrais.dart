import 'package:prossumidor/pages/constantes.dart';
import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:prossumidor/pages/minhaConta.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class Dados_Cadastrais extends StatefulWidget {
  final id_sessao;

  Dados_Cadastrais({
    this.id_sessao,
  });

  @override
  _Dados_CadastraisState createState() => _Dados_CadastraisState();
}

class _Dados_CadastraisState extends State<Dados_Cadastrais> {
  final _formKey = GlobalKey<FormState>();
  List<String> lista_local_retirada = [];
  List client_list = [
    {'nome_razao_social': 'nome'}
  ];

  //UserServices _userServices = UserServices();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _cpfTextController = TextEditingController();

  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _telefoneTextController = TextEditingController();
  TextEditingController _enderecoTextController = TextEditingController();
  TextEditingController _numeroTextController = TextEditingController();
  TextEditingController _complementoTextController = TextEditingController();
  TextEditingController _bairroTextController = TextEditingController();
  TextEditingController _cidadeTextController = TextEditingController();
  TextEditingController _cepTextController = TextEditingController();
  TextEditingController _estadoTextController = TextEditingController();
  TextEditingController _data_nascimentoTextController =
      MaskedTextController(mask: '00/00/0000');
  TextEditingController _estado_civilTextController = TextEditingController();

  //mascaras data
  var controller_data = new MaskedTextController(mask: '00/00/0000');

  String gender;
  String groupValue = "MASCULINO";
  bool hidePass = true;
  bool isLoading = false;
  String _selectedId;
  double _top = -100;

  @override
  void initState() {
    local_retirada().then((resultado) {
      setState(() {});
    });
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        _top = 0;
      });
    });
    super.initState();
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

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10.0, top: 65, bottom: 5),
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
                            'Dados Cadastrais',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: <Widget>[
                              Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        child: GestureDetector(
                                            child: new CircleAvatar(
                                                radius: 35,
                                                backgroundColor:
                                                    Color(0xFF012f7a),
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                ))),
                                      ),
                                      Container(
                                        height: 60,
                                        alignment: Alignment(0, 0),
                                        padding: const EdgeInsets.all(0),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20.0, 10.0, 20.0, 0.0),
                                          child: Material(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                title: TextFormField(
                                                  //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                                  controller:
                                                      _nameTextController,
                                                  decoration: InputDecoration(
                                                    suffix: Text(
                                                      'Nome',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    hintText: "Nome",
                                                    icon: Icon(
                                                      Icons.person_outline,
                                                    ),
                                                    counterText:
                                                        "", // remove os numero do contador do maxleng
                                                    // border: InputBorder.none,
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
                                        height: 60,
                                        padding: const EdgeInsets.all(0),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20.0, 10.0, 20.0, 0.0),
                                          child: Material(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                title: TextFormField(
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(),
                                                  controller:
                                                      _cpfTextController,
                                                  decoration: InputDecoration(
                                                    suffix: Text(
                                                      'CPF',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    hintText: "CPF",
                                                    icon: Icon(
                                                        Icons.content_paste),
                                                    counterText:
                                                        "", // remove os numero do contador do maxleng
                                                  ),
                                                  maxLength: 20,
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Insira um CPF';
                                                    } else {
                                                      if (value.length < 11) {
                                                        return "Email Tem Que Ter Pelo Menos 11 Dígitos";
                                                      } else {
                                                        Pattern pattern =
                                                            '([0-9]{2}[\.]?[0-9]{3}[\.]?[0-9]{3}[\/]?[0-9]{4}[-]?[0-9]{2})|([0-9]{3}[\.]?[0-9]{3}[\.]?[0-9]{3}[-]?[0-9]{2})';
                                                        RegExp regex =
                                                            new RegExp(pattern);
                                                        if (!regex
                                                            .hasMatch(value)) {
                                                          return 'Insira um CPF válido';
                                                        } else
                                                          return null;
                                                      }
                                                    }

                                                    //if (value.isEmpty) {
                                                    // return "O CPF não pode ficar em branco";
                                                    //}
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
                                        height: 60,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20.0, 10.0, 20.0, 0.0),
                                          child: Material(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                title: TextFormField(
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(),
                                                  controller:
                                                      _telefoneTextController,
                                                  decoration: InputDecoration(
                                                    suffix: Text(
                                                      'Telefone',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    hintText: "Telefone",
                                                    icon: Icon(
                                                        Icons.settings_cell),
                                                    counterText:
                                                        "", // remove os numero do contador do maxleng
                                                  ),
                                                  maxLength: 11,
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Insira um telefone';
                                                    } else {
                                                      if (value.length < 10) {
                                                        return "Tem Que Ter 10 ou 11 numeros (ex.65XXXXXNNNN)";
                                                      } else {
                                                        Pattern pattern =
                                                            '([0-9]{10})';
                                                        RegExp regex =
                                                            new RegExp(pattern);
                                                        if (!regex
                                                            .hasMatch(value)) {
                                                          return 'Insira um numero de telefone válido';
                                                        } else if (value
                                                                .length >
                                                            11) {
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
                                        //alignment: Alignment.bottomCenter,
                                        //color: Colors.grey.withOpacity(0.1),
                                        padding: const EdgeInsets.all(1),
                                        height: 60,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              45.0, 10.0, 20.0, 0.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "Sexo:",
                                                textAlign: TextAlign.right,
                                                style: GoogleFonts.poppins(
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Expanded(
                                                child: ListTile(
                                                  title: Text(
                                                    "Mas:",
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  trailing: Radio(
                                                      value: "MASCULINO",
                                                      groupValue: groupValue,
                                                      onChanged: (e) =>
                                                          valueChanged(e)),
                                                ),
                                              ),
                                              Expanded(
                                                child: ListTile(
                                                  title: Text(
                                                    "Fem:",
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  trailing: Radio(
                                                      value: "FEMININO",
                                                      groupValue: groupValue,
                                                      onChanged: (e) =>
                                                          valueChanged(e)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
//                  Container(
//                    padding: const EdgeInsets.all(0),
//                    height: 60,
//                    child: Padding(
//                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
//                      child: Material(
//                        child: Padding(
//                          padding: const EdgeInsets.only(left: 0.0),
//                          child: ListTile(
//                            title: TextFormField(
//                              controller: _emailTextController,
//                              decoration: InputDecoration(
//                                suffix: Text('Email', style: TextStyle(fontStyle: FontStyle.italic,
//                                  fontSize: 14.0,)),
//                                hintText: "Email",
//                                icon: Icon(Icons.alternate_email),
//                              ),
//                              validator: (value) {
//                                if (value.isEmpty) {
//                                  return 'Insira um endereço de email';
//                                } else {
//                                  if (value.length < 3) {
//                                    return "Email Tem Que Ter Pelo Menos 3 Caracteres";
//                                  } else {
//                                    Pattern pattern =
//                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
//                                    RegExp regex = new RegExp(pattern);
//                                    if (!regex.hasMatch(value)) {
//                                      return 'Insira um endereço de email válido';
//                                    } else
//                                      return null;
//                                  }
//                                }
//                              },
//                            ),
//                          ),
//                        ),
//                      ),
//                    ),
//                  ),

                                      Container(
                                        height: 60,
                                        alignment: Alignment(0, 0),
                                        padding: const EdgeInsets.all(0),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20.0, 10.0, 20.0, 0.0),
                                          child: Material(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                title: TextFormField(
                                                  //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                                  controller:
                                                      _enderecoTextController,
                                                  decoration: InputDecoration(
                                                    suffix: Text(
                                                      'Endereço',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    hintText: "Endereço",
                                                    icon: Icon(
                                                      Icons.add_location,
                                                    ),
                                                    counterText:
                                                        "", // remove os numero do contador do maxleng
                                                    // border: InputBorder.none,
                                                  ),
                                                  maxLength: 50,
//                              validator: (value) {
//                                if (value.isEmpty) {
//                                  return "O Nome não pode ficar em branco";
//                                }
//                                return null;
//                              },
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
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                title: TextFormField(
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(),
                                                  //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                                  controller:
                                                      _numeroTextController,
                                                  decoration: InputDecoration(
                                                    suffix: Text(
                                                      'Numero',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    hintText: "Numero",
                                                    icon: Icon(
                                                      Icons.confirmation_number,
                                                    ),
                                                    counterText:
                                                        "", // remove os numero do contador do maxleng
                                                    // border: InputBorder.none,
                                                  ),
                                                  maxLength: 10,
//                              validator: (value) {
//                                if (value.isEmpty) {
//                                  return "O Nome não pode ficar em branco";
//                                }
//                                return null;
//                              },
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
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                title: TextFormField(
                                                  //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                                  controller:
                                                      _complementoTextController,
                                                  decoration: InputDecoration(
                                                    suffix: Text(
                                                      'Complemento',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    hintText: "Complemento",
                                                    icon: Icon(
                                                      Icons
                                                          .format_list_numbered,
                                                    ),
                                                    counterText:
                                                        "", // remove os numero do contador do maxleng
                                                    // border: InputBorder.none,
                                                  ),
                                                  maxLength: 30,
//                              validator: (value) {
//                                if (value.isEmpty) {
//                                  return "O Nome não pode ficar em branco";
//                                }
//                                return null;
//                              },
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
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                title: TextFormField(
                                                  //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                                  controller:
                                                      _bairroTextController,
                                                  decoration: InputDecoration(
                                                    suffix: Text(
                                                      'Bairro',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    hintText: "Bairro",
                                                    icon: Icon(
                                                      Icons.local_activity,
                                                    ),
                                                    counterText:
                                                        "", // remove os numero do contador do maxleng
                                                    // border: InputBorder.none,
                                                  ),
                                                  maxLength: 50,
//                              validator: (value) {
//                                if (value.isEmpty) {
//                                  return "O Nome não pode ficar em branco";
//                                }
//                                return null;
//                              },
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
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                title: TextFormField(
                                                  //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                                  controller:
                                                      _cidadeTextController,
                                                  decoration: InputDecoration(
                                                    suffix: Text(
                                                      'Cidade',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    hintText: "Cidade",
                                                    icon: Icon(
                                                      Icons.location_city,
                                                    ),
                                                    counterText:
                                                        "", // remove os numero do contador do maxleng
                                                    // border: InputBorder.none,
                                                  ),
                                                  maxLength: 50,
//                              validator: (value) {
//                                if (value.isEmpty) {
//                                  return "O Nome não pode ficar em branco";
//                                }
//                                return null;
//                              },
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
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                title: TextFormField(
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(),
                                                  //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                                  controller:
                                                      _cepTextController,
                                                  decoration: InputDecoration(
                                                    suffix: Text(
                                                      'CEP',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    hintText: "CEP",
                                                    icon: Icon(
                                                      Icons.center_focus_weak,
                                                    ),
                                                    counterText:
                                                        "", // remove os numero do contador do maxleng
                                                    // border: InputBorder.none,
                                                  ),
                                                  maxLength: 10,
//                              validator: (value) {
//                                if (value.isEmpty) {
//                                  return "O Nome não pode ficar em branco";
//                                }
//                                return null;
//                              },
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
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                title: TextFormField(
                                                  //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                                  controller:
                                                      _estadoTextController,
                                                  decoration: InputDecoration(
                                                    suffix: Text(
                                                      'Estado',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    hintText: "Estado",
                                                    icon: Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                    ),
                                                    counterText:
                                                        "", // remove os numero do contador do maxleng
                                                    // border: InputBorder.none,
                                                  ),
                                                  maxLength: 2,
//                              validator: (value) {
//                                if (value.isEmpty) {
//                                  return "O Nome não pode ficar em branco";
//                                }
//                                return null;
//                              },
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
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                leading: Icon(
                                                  Icons.date_range,
                                                ),
                                                trailing: Text(
                                                  'Data de \n Nascimento:',
                                                  textAlign: TextAlign.center,
                                                  textScaleFactor: 1.1,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                title: RaisedButton(
                                                    color: Color(0xFF012f7a)
                                                        .withOpacity(0.4),
                                                    child: Text(
                                                      _data_nascimentoTextController
                                                          .text,
                                                      textAlign:
                                                          TextAlign.center,
                                                      textScaleFactor: 1.1,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      final DateTime picked =
                                                          await showDatePicker(
                                                              context: context,
                                                              initialDate:
                                                                  DateTime
                                                                      .now(),
                                                              //DateTime.parse(_data_nascimentoTextController.text),
                                                              firstDate:
                                                                  DateTime(
                                                                      1900, 7),
                                                              lastDate:
                                                                  DateTime(
                                                                      2101));
                                                      if (picked != null &&
                                                          picked !=
                                                              DateTime.parse(
                                                                  formata_data_aaaammdd(
                                                                      _data_nascimentoTextController
                                                                          .text)))
                                                        setState(() {
                                                          _data_nascimentoTextController
                                                                  .text =
                                                              formata_data_ddmmaaaa(
                                                                  picked
                                                                      .toString());
                                                        });
                                                      // print(_data_nascimentoTextController.text);
                                                    }),
//                            title: TextFormField(
//                              //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
//                              controller: _data_nascimentoTextController,
//                              decoration: InputDecoration(
//                                  suffix: Text('Data de Nascimento',
//                                      style: TextStyle(
//                                        fontStyle: FontStyle.italic,
//                                        fontSize: 14.0,
//                                      )),
//                                  hintText: "Data Nascimento",
//                                  icon: Icon(
//                                    Icons.person_outline,
//                                  )
//                                  // border: InputBorder.none,
//                                  ),
//                              validator: (value) {
//                                if (value.isEmpty) {
//                                  return 'Insira uma data válida';
//                                } else {
//                                  Pattern pattern =
//                                      '((((0[13578]|1[02])\/(0[1-9]|1[0-9]|2[0-9]|3[01]))|((0[469]|11)\/(0[1-9]|1[0-9]|2[0-9]|3[0]))|((02)(\/(0[1-9]|1[0-9]|2[0-8]))))\/(19([6-9][0-9])|20([0-9][0-9])))|((02)\/(29)\/(19(6[048]|7[26]|8[048]|9[26])|20(0[048]|1[26]|2[048])))';
//                                  RegExp regex = new RegExp(pattern);
//                                  if (!regex.hasMatch(value)) {
//                                    return 'Insira uma data válida';
//                                  } else
//                                    return null;
//                                }
//                              },
//                            ),
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
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: ListTile(
                                                title: TextFormField(
                                                  //initialValue : "" ,//client_list[0]['nome_razao_social'] ?? " ",
                                                  controller:
                                                      _estado_civilTextController,
                                                  decoration: InputDecoration(
                                                    suffix: Text(
                                                      'Estado Civil',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    hintText: "Estado Civil",
                                                    icon: Icon(
                                                      Icons.person_add,
                                                    ),
                                                    counterText:
                                                        "", // remove os numero do contador do maxleng
                                                    // border: InputBorder.none,
                                                  ),
                                                  maxLength: 15,
//                              validator: (value) {
//                                if (value.isEmpty) {
//                                  return "O Nome não pode ficar em branco";
//                                }
//                                return null;
//                              },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      Container(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  40.0, 20.0, 0.0, 0.0),
                                              alignment: Alignment.bottomLeft,
                                              child: Text(
                                                'Local de Retirada:',
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.poppins(
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      25.0, 0.0, 20.0, 0.0),
                                              child: ListTile(
                                                leading:
                                                    Icon(Icons.local_shipping),
                                                subtitle: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0.0, 0.0, 10.0, 0.0),
                                                  child: new DropdownButton<
                                                      String>(
                                                    isExpanded: true,
                                                    hint: Text(
                                                      " Local de Retirada",
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: Colors
                                                                  .black54),
                                                    ),
                                                    value: _selectedId,
                                                    onChanged: (String value) {
                                                      setState(() {
                                                        _selectedId = value;
                                                      });
                                                    },
                                                    items: lista_local_retirada
                                                        .map((String value) {
                                                      return new DropdownMenuItem<
                                                              String>(
                                                          value: value,
                                                          child: new Text(
                                                            value.substring(
                                                                value.indexOf(
                                                                        '-',
                                                                        0) +
                                                                    1,
                                                                value.length),
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Colors
                                                                    .black54),
                                                          ));
                                                    }).toList(),
                                                  ),

                                                  //  new RaisedButton(
                                                  //    child: const Text("Save"),
                                                  //    onPressed: () {
                                                  //      Navigator.pop(context, null);
                                                  //    },
                                                  //  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: 40,
                                            left: 40,
                                            bottom: 10,
                                            top: 10),
                                        child: FlatButton(
                                          color: Color(0xFF012f7a),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                          ),
                                          onPressed: () async {
                                            String result =
                                                await validateForm();
                                            if (result == "sucesso") {
                                              // print(result);
                                              Toast.show(
                                                  "Cadastro Atualizado com Sucesso",
                                                  context,
                                                  duration: Toast.LENGTH_LONG,
                                                  gravity: Toast.CENTER,
                                                  backgroundRadius: 0.0);
                                              Basicos.offset =
                                                  0; // zera o ofset do banco
                                              Basicos.product_list =
                                                  []; // zera o lista de produtos da pagina principal

                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          minhaConta(
                                                              id_sessao: widget
                                                                  .id_sessao)));
                                            } else {
                                              if (result == "falha_local") {
                                                Toast.show(
                                                    "Escolha um local para Retirada dos produtos",
                                                    context,
                                                    duration: Toast.LENGTH_LONG,
                                                    gravity: Toast.CENTER,
                                                    backgroundRadius: 0.0);
                                              } else {
                                                if (result == "erro_email") {
                                                } else
                                                  Toast.show(
                                                      "Erro ao cadastrar",
                                                      context,
                                                      duration:
                                                          Toast.LENGTH_LONG,
                                                      gravity: Toast.CENTER,
                                                      backgroundRadius: 0.0);
                                              }
                                            }
                                          },
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Atualizar',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Padding(
                                      //   padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 0.0),
                                      //   child: Material(
                                      //       borderRadius: BorderRadius.circular(20.0),
                                      //       color: Color(0xFF012f7a),
                                      //       elevation: 0.0,
                                      //       child: MaterialButton(
                                      //         onPressed: () async {
                                      //           String result = await validateForm();
                                      //           if (result == "sucesso") {
                                      //            // print(result);
                                      //             Toast.show(
                                      //                 "Cadastro Atualizado com Sucesso", context,
                                      //                 duration: Toast.LENGTH_LONG,
                                      //                 gravity: Toast.CENTER,
                                      //                 backgroundRadius: 0.0);
                                      //             Basicos.offset = 0; // zera o ofset do banco
                                      //             Basicos.product_list =
                                      //                 []; // zera o lista de produtos da pagina principal

                                      //             Navigator.pushReplacement(
                                      //                 context,
                                      //                 MaterialPageRoute(
                                      //                     builder: (context) => minhaConta(
                                      //                         id_sessao: widget.id_sessao)));
                                      //           } else {
                                      //             if (result == "falha_local") {
                                      //               Toast.show(
                                      //                   "Escolha um local para Retirada dos produtos",
                                      //                   context,
                                      //                   duration: Toast.LENGTH_LONG,
                                      //                   gravity: Toast.CENTER,
                                      //                   backgroundRadius: 0.0);
                                      //             } else {
                                      //               if (result == "erro_email") {
                                      //               } else
                                      //                 Toast.show("Erro ao cadastrar", context,
                                      //                     duration: Toast.LENGTH_LONG,
                                      //                     gravity: Toast.CENTER,
                                      //                     backgroundRadius: 0.0);
                                      //             }
                                      //           }
                                      //         },
                                      //         minWidth: MediaQuery.of(context).size.width,
                                      //         child: Text(
                                      //           "Atualizar",
                                      //           textAlign: TextAlign.center,
                                      //           style: TextStyle(
                                      //               color: Colors.black87,
                                      //               //fontWeight: FontWeight.bold,
                                      //               fontSize: 20.0),
                                      //         ),
                                      //       )),
                                      // ),

                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            40.0, 10.0, 40.0, 0.0),
                                      )
                                    ],
                                  )),
                              //),
                              //)),
//          Visibility(
//            visible: isLoading ?? true,
//            child: Center(
//              child: Container(
//                alignment: Alignment.center,
//                color: Colors.white.withOpacity(0.9),
//                child: CircularProgressIndicator(
//                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
//                ),
//              ),
//            ),
//          )
                            ],
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

  valueChanged(e) {
    setState(() {
      if (e == "MASCULINO") {
        groupValue = e;
        gender = e;
      } else if (e == "FEMININO") {
        groupValue = e;
        gender = e;
      }
    });
  }

// insere Clientes
  Future<String> validateForm() async {
    FormState formState = _formKey.currentState;
    if (formState.validate()) {
      if (_selectedId == null) {
        return "falha_local";
      } else {
        String link = Basicos.codifica("${Basicos.ip}/crud/?crud=consult23."
            "${widget.id_sessao.toString()},"
            "${removeCaracterEspecial(_nameTextController.text)},"
            "${_cpfTextController.text},"
            "${_telefoneTextController.text},"
            "${groupValue.toUpperCase()}," //masculino ou feminino
            "${removeCaracterEspecial(_enderecoTextController.text)},"
            "${_numeroTextController.text},"
            "${removeCaracterEspecial(_complementoTextController.text)},"
            "${removeCaracterEspecial(_bairroTextController.text)},"
            "${removeCaracterEspecial(_cidadeTextController.text)},"
            "${_cepTextController.text},"
            "${removeCaracterEspecial(_estadoTextController.text)},"
            "${formata_data_aaaammdd(_data_nascimentoTextController.text)},"
            "${removeCaracterEspecial(_estado_civilTextController.text)},"
            "${_selectedId.substring(0, _selectedId.indexOf('-'))}");

        // print(link);
        var res1 = await http
            .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
        // print(res.body);
        var res = Basicos.decodifica(res1.body);
        if (res1.body.length > 2) {
          if (res1.statusCode == 200) {
            //var list = json.decode(res.body) as String;
            //return list;
            //print(list);
            // atualiza local_retirada_id quando voltar da a tela principal
            Basicos.local_retirada_id =
                _selectedId.substring(0, _selectedId.indexOf('-'));
            return "sucesso";
            //-${_selectedId.substring(
            //0, _selectedId.indexOf('-'))}";
          }
        }
      }
    }
  }

  // carrega lista de local_retirada_id local de retirada monta combobox
  Future<List> local_retirada() async {
    // verifica local_retirada_id
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
          lista_local_retirada
              .add(list[i]['id'].toString() + '-' + list[i]['nome'].toString());
          // print(list[i]['id'].toString() + '-' + list[i]['nome'].toString());
        }
        //print(_selectedId);

        await cliente();
        return list;
      }
    }
    //lista local_retirada
  }

  // carrega dados do cliente
  Future<List> cliente() async {
    // verifica local_retirada_id
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consult22.${widget.id_sessao}");
    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    //var res =Basicos.decodifica(res1.body);
    // print(res.body);
    if (res.body.length > 2) {
      if (res.statusCode == 200) {
        List list = json.decode(res.body).cast<Map<String, dynamic>>();
        // print(list);
        client_list = list;
        //print(_selectedId);
        //print(client_list[0]['nome_razao_social']);

        _nameTextController.text = client_list[0]['nome_razao_social'];
        _cpfTextController.text = client_list[0]['cpf_cnpj'];
//    rg_inscricao_estadual character varying(15) NOT NULL,
//    telefone character varying(30) NOT NULL,
        _telefoneTextController.text = client_list[0]['celular'];
//    contato character varying(30) NOT NULL,
        _emailTextController.text = client_list[0]['email'];
//    status character varying(20) NOT NULL,
        _enderecoTextController.text = client_list[0]['endereco'];
        _numeroTextController.text = client_list[0]['numero'];
        _complementoTextController.text = client_list[0]['complemento'];
        _bairroTextController.text = client_list[0]['bairro'];
        _cidadeTextController.text = client_list[0]['cidade'];
        _cepTextController.text = client_list[0]['cep'];
        _estadoTextController.text = client_list[0]['estado'];
//    observacoes text NOT NULL,
        groupValue = client_list[0]['sexo'];

//    data_registro timestamp with time zone NOT NULL,
//    data_alteracao timestamp with time zone NOT NULL,
//    pessoa character varying(10) NOT NULL,
//    numero character varying(10) NOT NULL,
//    complemento character varying(30) NOT NULL,
        _data_nascimentoTextController.text =
            formata_data_ddmmaaaa(client_list[0]['data_nascimento_fundacao']);

        _estado_civilTextController.text = client_list[0]['estado_civil'];
//    model_template character varying(20) NOT NULL,
//    sobre_nome character varying(50) NOT NULL,
//    nome_fantasia character varying(100) NOT NULL,
//    inscricao_municipal character varying(15) NOT NULL,
        // print(lista_local_retirada.length);
        for (var i = 0, len = lista_local_retirada.length; i < len; i++) {
          if (lista_local_retirada[i]
                  .substring(0, lista_local_retirada[i].indexOf('-')) ==
              client_list[0]['local_retirada_id'].toString()) {
            _selectedId = lista_local_retirada[i];
          }
          // print(lista_local_retirada[i]
          //   .substring(0, lista_local_retirada[i].indexOf('-')));
          //print(client_list[0]['local_retirada_id'].toString());
        }

        return list;
      }
    }
  }
}

String removeCaracterEspecial(String texto) {
  // remove aspas, virgula e *
  String nova1 = texto.replaceAll(",", " ");
  String nova2 = nova1.replaceAll("\"", " ");
  String nova3 = nova2.replaceAll("*", " ");
  String novaf = nova3.replaceAll("'", " ");
  return novaf;
}

String formata_data_aaaammdd(String text) {
  // formata data inverte data padrao dd/mm/aaaa para  aaaa-mm-dd
  if (text == null) {
  } else {
    String dia, mes, ano;
    for (int i = 0, len = text.length; i < len; i++) {
      dia = text.substring(0, 2);
      mes = text.substring(3, 5);
      ano = text.substring(6, 10);
    }
    return ano + '-' + mes + '-' + dia;
  }
}

String formata_data_ddmmaaaa(String text) {
  // formata data inverte data padrao aaaa-mm-dd para dd/mm/aaaa
  if (text == null) {
  } else {
    String dia, mes, ano;
    //print(text);
    for (int i = 0, len = text.length; i < len; i++) {
      ano = text.substring(0, 4);
      mes = text.substring(5, 7);
      dia = text.substring(8, 10);
    }
    return dia + '/' + mes + '/' + ano;
  }
}
