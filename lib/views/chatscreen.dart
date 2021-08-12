import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message/helperfunction/sharedpref.dart';
import 'package:message/services/database.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String username, name;

  const ChatScreen({Key? key, required this.username, required this.name})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String chatRoomId, messageId = "";
  late Stream messageStream;
  late String myName, myProfilePic, myUserName, myEmail;
  TextEditingController messageTextEditingController = TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfile())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;
    chatRoomId = getChatRoomIdByUsername(widget.username, myUserName);
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft:
                      sendByMe ? Radius.circular(24) : Radius.circular(0),
                  topRight: Radius.circular(24),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(24))),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 70, top: 60),
                reverse: true,
                itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds =
                      (snapshot.data! as QuerySnapshot).docs[index];
                  return chatMessageTile(
                      ds["message"], myUserName == ds['sendBy']);
                },
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  getAndSetMessage() async {
    messageStream = await DatabaseMethods().getChatRoomMessage(chatRoomId);
    setState(() {});
  }

  doThisOnLanuch() async {
    await getMyInfoFromSharedPreference();
    getAndSetMessage();
  }

  addMessage(bool sendClicked) {
    if (messageTextEditingController.text != "") {
      String message = messageTextEditingController.text;
      var lastMessageTs = DateTime.now();
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
        "imageUrl": myProfilePic
      };
      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }
      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": myUserName
        };

        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);
        if (sendClicked) {
          //remove the text in the message input field
          messageTextEditingController.text = "";
          //make message id blank to get regenerated on next message send
          messageId = "";
        }
      });
    }
  }

  @override
  void initState() {
    doThisOnLanuch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
        ),
        body: Container(
          child: Stack(
            children: [
              chatMessages(),
              Container(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.black.withOpacity(0.8),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: messageTextEditingController,
                        onChanged: (value) {
                          addMessage(false);
                        },
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "type a message",
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white60)),
                      )),
                      GestureDetector(
                        onTap: () {
                          addMessage(true);
                        },
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   properties.add(DiagnosticsProperty<Stream>('messageStream', messageStream));
  // }
}
