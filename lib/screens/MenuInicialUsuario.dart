import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'registration_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MenuInicialUsuarioScreen extends StatefulWidget {
  @override
  static String ID = 'MenuInicialUsuario_screen';

  _MenuInicialUsuarioScreenState createState() =>
      _MenuInicialUsuarioScreenState();
}

class _MenuInicialUsuarioScreenState extends State<MenuInicialUsuarioScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String senha;
  String usuario;
  FirebaseUser loggedInUser;
  String messageText;
  static String usuarioSelecionado;
  static final double myTextSize = 20.0;
  final double myIconSize = 20.0;
  final TextStyle myTextStyle =
      new TextStyle(color: Colors.black, fontSize: myTextSize);

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        usuarioSelecionado = user.email;
      }
    } catch (e) {
      print(e);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: Text('App - Aluno'),
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: StreamBuilder(
            stream: Firestore.instance
                .collection('procedimento')
                .where('usuario', isEqualTo: this.loggedInUser.email)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return new Text('Loading...');
              return new Column(
                mainAxisSize: MainAxisSize.max,
                verticalDirection: VerticalDirection.down,
                children: snapshot.data.documents.map((document) {
                  print(document['conclusao'].toString());
                  if (document['conclusao'] == "sucesso") {
                    return new Column(
                      children: <Widget>[
                        new MyCard(
                          title: new Text(
                            document['procedimento'],
                            style: myTextStyle,
                          ),
                          icon: new Icon(
                            Icons.done,
                            size: myIconSize,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ); //Column
                  } else {
                    return new Column(
                      children: <Widget>[
                        new MyCard(
                          title: new Text(
                            document['procedimento'],
                            style: myTextStyle,
                          ),
                          icon: new Icon(
                            Icons.done,
                            size: myIconSize,
                            color: Colors.deepOrangeAccent,
                          ),
                        ),
                      ],
                    ); //Column
                  }
                }).toList(),
              ); //ListView
            },
          ),
        ),
      ),
    );
  }

  getModal() {
    print("Chamou a funcao");
  }
}

class MyCard extends StatelessWidget {
  final Widget icon;
  final Widget title;

  // Constructor. {} here denote that they are optional values i.e you can use as: new MyCard()
  MyCard({this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(5.0),
      child: new Card(
        color: Colors.white70,
        child: new Container(
          padding: const EdgeInsets.all(10.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.ltr,
            children: <Widget>[this.title, this.icon],
          ),
        ),
      ),
    );
  }
}
