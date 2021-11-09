import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: use_key_in_widget_constructors
class ChatBotScreen extends StatefulWidget {
  // const ChatBotScreen({ Key? key }) : super(key: key);

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<String> _data = [];

  static const String BOT_URL = "https://rental-app-chatbot.herokuapp.com/bot";
  TextEditingController queryController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    double Height = MediaQuery. of(context). size. height;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text("ChatBot"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Container(
              height: Height-135,
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _data.length,
                itemBuilder:
                    (BuildContext context, int index, Animation animation) {
                  return buildItem(_data[index], animation, index);
                },
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: ColorFiltered(
                colorFilter: ColorFilter.linearToSrgbGamma(),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.message, color: Colors.black),
                        hintText: "Message",
                        fillColor: Colors.white12,
                      ),
                      controller: queryController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (msg) {
                        this.getResponse();
                      },
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  void getResponse() {
    if (queryController.text.length > 0) {
      this.insertSingleItem(queryController.text);
      var client = getClient();
      try {
        client.post(Uri.parse(BOT_URL), body: {"query": queryController.text})
          ..then((response) {
            print(response.body);
            Map<String, dynamic> data = jsonDecode(response.body);
            insertSingleItem(data['response'] + "<bot>");
          });
      } finally {
        client.close();
        queryController.clear();
      }
    }
  }

  void insertSingleItem(String message) {
    _data.add(message);
    _listKey.currentState.insertItem(_data.length - 1);
  }

  http.Client getClient() {
    return http.Client();
  }
}

Widget buildItem(String item, Animation animation, int index) {
  bool mine = item.endsWith("<bot>");
  return SizeTransition(
    sizeFactor: animation,
    child: Padding(
      padding: EdgeInsets.only(top: 10),
      child: Container(
        alignment: mine ? Alignment.topLeft : Alignment.topRight,
        child: Bubble(
          child: Text(
            item.replaceAll("<bot", ""),
            style: TextStyle(color: mine ? Colors.white : Colors.black),
          ),
          color: mine ? Colors.blue : Colors.grey[200],
          padding: BubbleEdges.all(10),
        ),
      ),
    ),
  );
}
