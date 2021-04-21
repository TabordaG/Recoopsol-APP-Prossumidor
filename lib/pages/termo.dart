
//import 'package:ajudasobretermos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import 'minhaConta.dart';


class Termo extends StatefulWidget {
  final id_sessao;

  Termo({
    this.id_sessao,
  });
  @override
  _TermoState createState() => _TermoState();
}

class _TermoState extends State<Termo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      new minhaConta(id_sessao: widget.id_sessao)));
            },
          ),
          elevation: 0.1,
          backgroundColor: Colors.blueAccent,
          title: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      new minhaConta(id_sessao: widget.id_sessao)));
            },
            child: Text(
              'Termos e Condições',
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Recoopsol "
              ,style: TextStyle(fontSize: 25,),),

            Row(

                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>
                [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child:  Container(

                      height: 150.0,
                      width: 150.0,
                      child: Image.asset("/images/app_icon.jpg"
                      ),

                    ),
                  )
                ]
            ),
            Text("2015-2020 Recoopsol",style: TextStyle(color: Colors.teal,fontStyle: FontStyle.italic),),
            Container(
                padding: EdgeInsets.only(top: 150),
                child: RaisedButton(

                  child:  Text("Termos ",style: TextStyle(fontSize: 20,),),
                  onPressed:
                      () async {

                    //Link da pagina de termos
                    const url = "https://www.google.com/search?q=termos+de+uso&oq=termos&aqs=chrome.0.69i59l2j69i57j0l2j69i60j69i61j69i60.1009j0j7&sourceid=chrome&ie=UTF-8";
                    if (await canLaunch(url)) {
                      await launch(url);

                    } else {
                      throw 'erro $url';
                    }


                  },
                )
            ),
          ],
        )
    );
  }
}
