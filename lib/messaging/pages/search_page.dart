import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:triangle_chat/messaging/helper/helper_function.dart';
import 'package:triangle_chat/messaging/widgets/widgets.dart';

import '../services/database_service.dart';
import 'chat_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  TextEditingController searchController = TextEditingController();
  String userName = "";
  User? user;
  bool _isJoined = true;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdAndName();
  }

  getAdminName(String adminName) {
    return adminName.substring(adminName.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  getCurrentUserIdAndName() async {
    await HelperFunction.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });

    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Search',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Search groups",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearch();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                )
              : groupList(),
        ],
      ),
    );
  }

  initiateSearch() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .searchByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          _isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                  userName: userName,
                  groupId: searchSnapshot!.docs[index]['groupId'],
                  groupName: searchSnapshot!.docs[index]['groupName'],
                  admin: searchSnapshot!.docs[index]['admin']);
            },
          )
        : Container();
  }

  Widget groupTile(
      {required String userName,
      required String groupId,
      required String groupName,
      required String admin}) {
    //cheack wheathr the user already joined the group or not
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
        ),
      ),
      title: Text(
        groupName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Admin : ${getAdminName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .togglingTojoinAndExit(groupId, userName, groupName)
              .then((value) {
            if (_isJoined) {
              setState(() {
                _isJoined = !_isJoined;
              });
              showSnackBar(
                  context, Colors.green, "Suucessfully Joined the group");
              Future.delayed(Duration(seconds: 2), () {
                nextScreen(
                    context,
                    ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName,
                    ));
              });
            } else {
              setState(() {
                _isJoined = !_isJoined;
              });
              showSnackBar(context, Colors.red, "Successfully exit $groupName");
              Future.delayed(Duration(seconds: 2));
            }
          });
        },
        child: _isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  'Joined',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  'Join',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }

  joinedOrNot(
      String userName, String groupId, String groupName, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) async {
      setState(() {
        _isJoined = value;
        print(value);
      });
    });
  }
}
