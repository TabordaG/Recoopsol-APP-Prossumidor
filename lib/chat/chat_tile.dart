import 'chats.dart';
import 'package:flutter/material.dart';

class MessagesTile extends StatelessWidget {
  final Message message;

  MessagesTile(this.message);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 120.0,
          child: Icon(Icons.person),
          padding: EdgeInsets.all(8.0),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  message.ID_Cliente,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17.0,
                  ),
                ),
                Text(
                  message.Mensagem,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
