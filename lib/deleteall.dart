import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: DeleteAllScreen(),
  ));
}

class DeleteAllScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          title: Text(
            "HA",
            style: GoogleFonts.ibmPlexSansThai(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DeleteButton(collectionName: 'chats'),
              DeleteButton(collectionName: 'friendrequest'),
              DeleteButton(collectionName: 'groupmessages'),
              DeleteButton(collectionName: 'interest'),
              DeleteButton(collectionName: 'messages'),
              DeleteButton(collectionName: 'placemeet'),
              DeleteButton(collectionName: 'places'),
              DeleteButton(collectionName: 'timeline'),
              DeleteButton(collectionName: 'triprequest'),
              DeleteButton(collectionName: 'trips'),
              DeleteButton(collectionName: 'userlocation'),
              DeleteButton(collectionName: 'users'),
              ElevatedButton(
                onPressed: () => deleteAllData(context),
                child: Text('ลบข้อมูลทั้งหมด'),
              ),
            ],
          ),
        ));
  }

  Future<void> deleteCollection(String collection) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference collectionRef = firestore.collection(collection);
      QuerySnapshot querySnapshot = await collectionRef.get();
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
      print('Deleted all documents in $collection collection.');
    } catch (error) {
      print('Error deleting documents: $error');
    }
  }

  Future<void> deleteAllData(BuildContext context) async {
    try {
      await deleteCollection('chats');
      await deleteCollection('friendrequest');
      await deleteCollection('groupmessages');
      await deleteCollection('interest');
      await deleteCollection('messages');
      await deleteCollection('placemeet');
      await deleteCollection('places');
      await deleteCollection('timeline');
      await deleteCollection('triprequest');
      await deleteCollection('trips');
      await deleteCollection('userlocation');
      await deleteCollection('users');

      final FirebaseStorage storage = FirebaseStorage.instance;
      await storage.ref('profilepic').delete();
      await storage.ref('trip').delete();

      Fluttertoast.showToast(msg: 'Deleted all data');
    } catch (error) {
      print('Error deleting data: $error');
      Fluttertoast.showToast(msg: 'Error deleting data');
    }
  }
}

Future<void> deleteFolder(String folderName) async {
  try {
    final FirebaseStorage storage = FirebaseStorage.instance;
    await storage.ref(folderName).delete();
    print('Deleted folder: $folderName');
  } catch (error) {
    print('Error deleting folder: $error');
  }
}

class DeleteButton extends StatelessWidget {
  final String collectionName;

  const DeleteButton({Key? key, required this.collectionName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => deleteCollection(collectionName),
      child: Text('ลบข้อมูลในคอลเลกชัน $collectionName'),
    );
  }

  Future<void> deleteCollection(String collection) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference collectionRef = firestore.collection(collection);
      QuerySnapshot querySnapshot = await collectionRef.get();
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
      print('Deleted all documents in $collection collection.');
    } catch (error) {
      print('Error deleting documents: $error');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
