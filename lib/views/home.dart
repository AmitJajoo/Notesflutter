import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:message/helperfunction/sharedpref.dart';
import 'package:message/services/auth.dart';
import 'package:message/services/database.dart';
import 'package:message/views/chatscreen.dart';
import 'package:message/views/signin.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  late String myName, myProfilePic, myUserName, myEmail;
  late Stream userStream, chatRoomStream;
  TextEditingController searchUsernameEditingController =
      TextEditingController();

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    userStream = await DatabaseMethods()
        .getUserByUserName(searchUsernameEditingController.text);
    setState(() {});
  }

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfile())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget searchUserListTile(
      {required String profileUrl, name, username, email}) {
    return GestureDetector(
      onTap: () {
        print("Satu is best $myUserName and $username");
        var chatRoomId = getChatRoomIdByUsername(myUserName, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };
        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(username: username, name: name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profileUrl,
              width: 30,
              height: 30,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(name), Text(email)],
            ),
          )
        ],
      ),
    );
  }

  Widget searchUserList() {
    return StreamBuilder(
        stream: userStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds =
                        (snapshot.data! as QuerySnapshot).docs[index];
                    return searchUserListTile(
                        profileUrl: ds['imgUrl'],
                        name: ds['name'],
                        email: ds['email'],
                        username: ds['username']);
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds =
                        (snapshot.data! as QuerySnapshot).docs[index];
                    return chatRoomListTile(
                        myUsername: myUserName,
                        lastMessage: ds["lastMessage"],
                        chatRoomId: ds.id);
                  })
              : CircularProgressIndicator();
        });
  }

  getChatRoom() async {
    chatRoomStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRoom();
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Messenger Clone"),
          actions: [
            InkWell(
              onTap: () {
                AuthMethods().signOut().then((value) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignIN()));
                });
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.exit_to_app)),
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          isSearching = false;
                          searchUsernameEditingController.text = "";
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.arrow_back),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: searchUsernameEditingController,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: "username"),
                        )),
                        GestureDetector(
                            onTap: () {
                              if (searchUsernameEditingController.text != "") {
                                onSearchBtnClick();
                              }
                            },
                            child: Icon(Icons.search))
                      ],
                    ),
                  ),
                ),
              ]),
              isSearching ? searchUserList() : chatRoomList(),
            ],
          ),
        ));
  }
}

// ignore: camel_case_types
class chatRoomListTile extends StatefulWidget {
  final String lastMessage, myUsername, chatRoomId;
  chatRoomListTile(
      {Key? key,
      required this.myUsername,
      required this.lastMessage,
      required this.chatRoomId})
      : super(key: key);

  @override
  _chatRoomListTileState createState() => _chatRoomListTileState();
}

// ignore: camel_case_types
class _chatRoomListTileState extends State<chatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";
  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    print("Something ${querySnapshot.docs[0].id}");
    name = querySnapshot.docs[0]["name"];
    profilePicUrl = querySnapshot.docs[0]["imgUrl"];
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(username: username, name: name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              profilePicUrl,
              height: 40,
              width: 40,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: 3,
              ),
              Text(widget.lastMessage)
            ],
          )
        ],
      ),
    );
  }
}
