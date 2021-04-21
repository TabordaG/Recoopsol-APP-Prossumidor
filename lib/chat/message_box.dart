import 'package:prossumidor/pages/dados_basicos.dart';
import 'package:prossumidor/widgets/soft_buttom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

import 'chats.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

List<Message> messages = List<Message>();

class ChatScreen extends StatefulWidget {
  final id_sessao;
  String ID_Cliente, ID_Produtor, Nome_Empresa, Nome_Cliente;

  ChatScreen(
      {this.ID_Cliente,
      this.ID_Produtor,
      this.Nome_Empresa,
      this.Nome_Cliente,
      this.id_sessao});

  @override
  _ChatScreenState createState() =>
      _ChatScreenState(id_cliente: ID_Cliente, id_produtor: ID_Produtor);
}

class _ChatScreenState extends State<ChatScreen> {
  var message_text = List<Message>();
  final TextEditingController _controller = TextEditingController();
  double _top = -100;
  StreamController chatStream;

  _ChatScreenState({String id_cliente, String id_produtor});

  void _reset() {
    _controller.clear();
  }

//  Timer _timer;
//  int _res = 0, _start = 0;

//  void startTimer() {
//    const oneSec = const Duration(seconds: 3);
//    _timer = new Timer.periodic(
//      oneSec,
//      (Timer timer) => {
//        countDB().then((resultado) {
//          _res = resultado;
//        }),
//        if (_start < _res)
//          {
//            iniciaDB().then((resultado) {
//              setState(() {});
//            }),
//            _start = _res,
//          }
//      },
//    );
//  }

  @override
  void initState() {
    // startTimer();
//    countDB().then((resultado) {
//      setState(() {});
//      _start = resultado;
//    });
    chatStream = StreamController();
    chat = [];
    chatStream.sink.add(chat);
    iniciaDB().then((resultado) {
      // chatStream.sink.add(resultado);
      setState(() {});
    });
    chatStream.sink.add(chat);
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        _top = 0;
      });
    });
    super.initState();
  }

  _rightName(DateTime dateTime) {
    if (dateTime.hour >= 12)
      return 'PM';
    else
      return 'AM';
  }

  @override
  void dispose() {
    //  _timer.cancel();
    super.dispose();
  }

  Future<bool> onWillPop() async {
    setState(() {
      _top = -100;
    });
    Basicos.pagina = 1;
    Basicos.product_list = [];
    Future.delayed(Duration(milliseconds: 250), () {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => ChatsPage(id_sessao: widget.id_sessao)),
      );
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                        ),
                        Text(
                          widget.Nome_Empresa,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                            icon: Icon(Icons.autorenew),
                            onPressed: () {
                              Basicos.offset = 0; // zera o ofset do banco
                              Basicos.product_list =
                                  []; // zera o lista de produtos da pagina principal
                              Basicos.pagina = 1;
                              Toast.show(
                                "Atualizando..",
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.CENTER,
                              );
                              iniciaDB();
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) => ChatScreen(
                              //       id_sessao: widget.id_sessao,
                              //       ID_Cliente: text[index].ID_Cliente,
                              //       ID_Produtor: text[index].ID_Empresa,
                              //       Nome_Empresa: text[index].Nome_Empresa,
                              //       Nome_Cliente: text[index].Nome_Cliente,
                              //     ),
                              //   ),
                              // );
                              // Navigator.of(context).push(new MaterialPageRoute(
                              //   // aqui temos passagem de valores id cliente(sessao) de login para home
                              //   builder: (context) => ChatScreen(
                              //       id_sessao: widget.id_sessao,
                              //       ID_Cliente: widget.ID_Cliente,
                              //       ID_Produtor: widget.ID_Produtor),
                              // ));
                            }),
                      ],
                    ),
                  ),
                  Divider(
                    indent: 20,
                    endIndent: 20,
                  ),
                  Expanded(
                    child: StreamBuilder(
                        stream: chatStream.stream,
                        //getFutureMessages(widget.ID_Cliente, widget.ID_Produtor),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            default:
                              List<Message> messageNoReversed = snapshot.data;
                              message_text =
                                  messageNoReversed.reversed.toList();
                              return ListView.builder(
                                  itemCount: message_text.length,
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    bool _isclient =
                                        message_text[index].Situacao ==
                                            'Cliente-Produtor';
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 2),
                                      width: MediaQuery.of(context).size.width,
                                      alignment: _isclient
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment: _isclient
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: _isclient
                                                ? EdgeInsets.only(
                                                    left: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        4)
                                                : EdgeInsets.only(
                                                    right:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            4),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: _isclient
                                                    ? BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                15.0),
                                                        topRight:
                                                            Radius.circular(
                                                                15.0),
                                                        topLeft:
                                                            Radius.circular(
                                                                15.0),
                                                      )
                                                    : BorderRadius.only(
                                                        bottomRight:
                                                            Radius.circular(
                                                                15.0),
                                                        topRight:
                                                            Radius.circular(
                                                                15.0),
                                                        topLeft:
                                                            Radius.circular(
                                                                15.0),
                                                      ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Text(
                                                  message_text[index].Mensagem,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontFamily: "Poppins",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              color: _isclient
                                                  ? Color(0xFF012f7a)
                                                  : Color(
                                                      0xFF5e5e5e), //Color(0xFFa7b5c8), //Colors.green[100],
                                              elevation: 2,
                                            ),
                                          ),
                                          Padding(
                                            padding: _isclient
                                                ? EdgeInsets.only(right: 4)
                                                : EdgeInsets.only(left: 4),
                                            child: Row(
                                              mainAxisAlignment: _isclient
                                                  ? MainAxisAlignment.end
                                                  : MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  message_text[index]
                                                              .Data_Envio
                                                              .hour <
                                                          10
                                                      ? '0${message_text[index].Data_Envio.hour.toString()}:'
                                                      : '${message_text[index].Data_Envio.hour.toString()}:',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  message_text[index]
                                                              .Data_Envio
                                                              .minute <
                                                          10
                                                      ? '0${message_text[index].Data_Envio.minute.toString()} '
                                                      : '${message_text[index].Data_Envio.minute.toString()} ',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  '${_rightName(message_text[index].Data_Envio)}',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                _isclient
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 3.0),
                                                        child: _buildCheck(
                                                            message_text[
                                                                index]),
                                                        // child: Icon(
                                                        //     Icons.done_all,
                                                        //     color: Colors.teal,
                                                        //     size: 16,
                                                        //   ),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                          }
                        }),
                  ),
                  Divider(
                    indent: 20,
                    endIndent: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, bottom: 10, top: 0),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color:
                          Color(0xFFeceff3), //Color(0xFFf8faf8).withOpacity(1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: TextField(
                                maxLength: 224,
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: 'Enviar Mensagem',
                                  counterText: "",
                                  border: InputBorder.none,
                                ),
                                onChanged: (text) {
                                  // setState(() {
                                  //   _isComposing = text.isNotEmpty;
                                  // });
                                },
                                onSubmitted: (text) {
                                  setState(() async {
                                    await _sendMessage(text);
                                  });
                                  // _reset();
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Color(0xFF012f7a),
                            ),
                            onPressed: () async {
                              if (_controller.text.isNotEmpty)
                                await _sendMessage(_controller.text);
                              // _reset();
                            },
                          )
                        ],
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
                      onPressed: () {
                        setState(() {
                          _top = -100;
                        });
                        Basicos.pagina = 1;
                        Basicos.product_list = [];
                        Future.delayed(Duration(milliseconds: 250), () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChatsPage(id_sessao: widget.id_sessao)),
                          );
                        });
                      }),
                  radius: 22,
                ),
              ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        // Basicos.offset = 0; // zera o ofset do banco
        // Basicos.product_list =
        //     []; // zera o lista de produtos da pagina principal
        // Basicos.pagina = 1;
        // Navigator.of(context).push(new MaterialPageRoute(
        //   // aqui temos passagem de valores id cliente(sessao) de login para home
        //   builder: (context) => ChatScreen(
        //       id_sessao: widget.id_sessao,
        //       ID_Cliente: widget.ID_Cliente,
        //       ID_Produtor: widget.ID_Produtor),
        // ));
        //   },
        //   child: Icon(Icons.autorenew),
        //   backgroundColor: Colors.white,
        //   foregroundColor: Colors.black,
        //   mini: false,
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }

  Future<List> iniciaDB() async {
    // conta mensagens
    String limite = '0';
    if (int.parse(await conta_msg_chat_cliente_to_empresa()) >= 20)
      limite = (int.parse(await conta_msg_chat_cliente_to_empresa()) - 19)
          .toString();

    // limpar conversas
    chat = []; // zera chat
    //print(widget.id_sessao);
    String link = Basicos.codifica("${Basicos.ip}"
        "/crud/?crud=consult75.${widget.id_sessao},"
        "${widget.ID_Produtor},"
        "20,$limite");
    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    //var res =Basicos.decodifica(res1.body);

    // converte a lista de consulta em uma lista dinamica
    List list = json.decode(res.body).cast<Map<String, dynamic>>();

    if (res.body.length > 2) {
      print('entrou aqui..');
      if (res.statusCode == 200) {
        //Meus_recebimentos = list;
        //print('passou por aqui');
        for (var i = 0; i < list.length; i++) {
          // print('add message');
          chat.add(Message(
            ID_mensagem: list[i]['id'].toString(),
            Mensagem: list[i]['mensagem'],
            Situacao: list[i]['situacao'],
            Status: list[i]['status'],
            Data_Envio: DateTime.parse(list[i]['data_envio'].toString()),
            Data_Leitura: DateTime.parse(list[i]['data_leitura'].toString()),
            ID_Cliente: list[i]['id_cliente_id'].toString(),
            Nome_Cliente: list[i]['nome_razao_social'].toString(),
            ID_Empresa: list[i]['id_empresa_id'].toString(),
            Nome_Empresa: list[i]['razao_social'].toString(),
          ));
          chatStream.sink.add(chat);
          // print(messages[i].Data_Envio);
        }
        print(list);
        await atualizaMessage();
      }
    }
    return chat;
  }

  //conta msg de cliente para empresa
  Future<String> conta_msg_chat_cliente_to_empresa() async {
    String link = Basicos.codifica(
        "${Basicos.ip}/crud/?crud=consult84.${widget.id_sessao},${widget.ID_Produtor}");
    var res1 = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    var res = Basicos.decodifica(res1.body); // print(res.body);
    // print(res);
    if (res1.body.length >= 1) {
      if (res1.statusCode == 200) {
        var list = json.decode(res).cast<Map<String, dynamic>>();
        String qtd_chat_cliente = list[0]["count"].toString();
        //  print(qtd_chat_cliente);
        return qtd_chat_cliente;
      }
    }
  }

//  Adiciona a nova mensagem no banco
  Future<List> _sendMessage(String text) async {
    int id = messages.length + 1;
    Message msg = Message(
        ID_mensagem: text,
        ID_Cliente: widget.ID_Cliente,
        ID_Empresa: widget.ID_Produtor,
        Nome_Cliente: widget.Nome_Cliente,
        Nome_Empresa: widget.Nome_Empresa,
        Situacao: 'Cliente-Produtor',
        Status: 'Enviado',
        Mensagem: text,
        Data_Envio: DateTime.now(),
        Data_Leitura: DateTime.now());
    // insere no banco de dados
    //Inserir mensagem ###############################################
    String link2 = Basicos.codifica("${Basicos.ip}/crud/?crud=consult74."
        "${Basicos.strip(text)}," //    msg text NOT NULL,
        "Cliente-Produtor,"
        "Enviado,"
        //    data_envio timestamp with time zone NOT NULL,
        //    data_leitura timestamp with time zone NOT NULL,
        //"${widget.ID_Cliente.substring(widget.ID_Cliente.lastIndexOf('(', widget.ID_Cliente.length) + 1, widget.ID_Cliente.length - 1)}," //    cliente_id integer NOT NULL,
        "${widget.ID_Cliente},"
        //"${widget.ID_Produtor.substring(widget.ID_Produtor.lastIndexOf('(', widget.ID_Produtor.length) + 1, widget.ID_Produtor.length - 1)}," //    produtor_id integer NOT NULL,
        "${widget.ID_Produtor},");
    // print('object2');
    // print(link2);
    var res2 = await http
        .get(Uri.encodeFull(link2), headers: {"Accept": "application/json"});
    //  print('Enviar Mensagem... Status: ');
    //  print(res2.statusCode.toString());
    if (res2.statusCode == 200) {
      chat.add(msg);
      chatStream.sink.add(chat);
    }

    _reset();
    var res3 = Basicos.decodifica(res2.body);
  }

  //  atualiza msg para lida
  Future<List> atualizaMessage() async {
    String link2 = Basicos.codifica("${Basicos.ip}/crud/?crud=consult83."
        "${widget.ID_Produtor}," //"${widget.ID_Produtor.substring(widget.ID_Produtor.lastIndexOf('(', widget.ID_Produtor.length) + 1, widget.ID_Produtor.length - 1)}," //    produtor_id integer NOT NULL,
        "Lido,"
        //    data_envio timestamp with time zone NOT NULL,
        "${DateTime.now()}," //data_leitura timestamp with time zone NOT NULL,
        "${widget.id_sessao}," //    cliente_id integer NOT NULL,
        "Produtor-Cliente,");
    var res2 = await http
        .get(Uri.encodeFull(link2), headers: {"Accept": "application/json"});
    var res3 = Basicos.decodifica(res2.body);
  }
}

Widget _buildCheck(Message mensagem) {
  Color color;
  IconData icon;
  if (mensagem.Status == 'Lido') {
    icon = Icons.done_all;
    color = Colors.green;
  } else if (mensagem.Status == 'Enviado') {
    icon = Icons.done;
    color = Colors.grey;
  } else if (mensagem.Status == 'Recebido') {
    icon = Icons.done_all;
    color = Colors.grey;
  } else if (mensagem.Status == 'Apagado') {
    icon = Icons.do_not_disturb;
    color = Colors.grey;
  }
  return Icon(icon, color: color, size: 16);
}
