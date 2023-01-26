import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  //reference for our collection app
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  //saving the user data
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  //getting userData
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

//gettingUsersGroups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

//creating group
  Future creatingGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userUserDocumentReference = userCollection.doc(uid);
    return await userUserDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  //getting the chat
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

//to get group admin

  Future getGroupAdmin(String groupId) async {
    DocumentReference document = groupCollection.doc(groupId);
    DocumentSnapshot docSnap = await document.get();
    return docSnap['admin'];
  }

//getting group members
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //searching group
  searchByName(String groupName) async {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

//check if user if joined the group or not
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocument = userCollection.doc(uid);
    DocumentSnapshot docSnapshot = await userDocument.get();

    List<dynamic> groups = await docSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  //toggling the group join and exit
  Future togglingTojoinAndExit(
      String groupId, String userName, String groupName) async {
    //doc reff
    DocumentReference userDocumentRefrense = userCollection.doc(uid);
    DocumentReference groupDocumentRefrense = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentRefrense.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    //if user already join then remove them and not then add them
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentRefrense.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentRefrense.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentRefrense.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentRefrense.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  //send message
  sendMessage(String groupId, Map<String, dynamic> chatMessagesData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessagesData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessagesData['message'],
      "recentMessageSender": chatMessagesData['sender'],
      "recentMessageTime": chatMessagesData['time'].toString()
    });
  }
}
