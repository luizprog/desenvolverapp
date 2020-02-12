import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'RegistrationScreen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MenuInicialUsuarioScreen extends StatefulWidget {
  @override
 /* static String ID = 'MenuInicialUsuario_screen';
  static String usuarioSelecionado = '';
  static String nomeUsuarioSelecionado = '';
  static String vUserID = '';
  static int pontuacaoAtual = 0;
  static int numeroAtividades = 0;*/
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
  static String usuarioSelecionado = '';
  static final double myTextSize = 20.0;
  final double myIconSize = 20.0;
  final TextStyle myTextStyle =
      new TextStyle(color: Colors.black, fontSize: myTextSize);

  @override
  void initState() {
    super.initState();
    //getCurrentUser();
  }
  Widget build(BuildContext context) {
    return Scaffold();}
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
