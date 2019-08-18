import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MenuInicial.dart';
import 'MenuInicialUsuario.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatefulWidget {
  @override
  static String ID = 'login_screen';

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  bool showSpinner = false;
  String usuario;
  String usuarioEmail;
  String senha;
  String permissao;

  void getUsuarioPermisssao() async {
    final permissao = await _firestore.collection('usuarios').getDocuments();

    for (var usuariosLogado in permissao.documents) {
      if (usuariosLogado.data['usuario'].toString() == usuarioEmail) {
        if (usuariosLogado.data['nivelDeAcesso'] == 'administrador') {
          Navigator.pushNamed(context, MenuInicialScreen.ID);
        } else {
          Navigator.pushNamed(context, MenuInicialUsuarioScreen.ID);
        }
      }
    }
  }

  void getUsuarioEmail() async {
    final loginUserName =
        await _firestore.collection('usuarios').getDocuments();
    for (var usuariosLogado in loginUserName.documents) {
      if (usuariosLogado.data['nomeusuario'].toString() == usuario) {
        usuarioEmail = usuariosLogado.data['usuario'].toString();
      }
    }

    final newUser = await _auth.signInWithEmailAndPassword(
        email: usuarioEmail, password: senha);
  }

  /* getSnapshot Stream message
  * void messageStream() async{
  *   await for (var snapshots in _firestore.collection('usuarios').snapshots()){
  *     for(var message in snapshot.documents){
  *       print(message.data);
  *     }
  *   }
  * }
  * */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: 148.0,
                  width: 60.0,
                  child: Image.asset('images/auti.png'),
                ),
                transitionOnUserGestures: true,
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                style: TextStyle(color: Colors.black.withOpacity(1.0)),
                textAlign: TextAlign.center,
                onChanged: (value) {
                  usuario = value;
                },
                decoration: InputDecoration(
                  hintText: 'Entre com o usuario',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                style: TextStyle(color: Colors.black.withOpacity(1.0)),
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  senha = value;
                },
                decoration: InputDecoration(
                  fillColor: Colors.black,
                  hintText: 'Entre com a senha',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () async {
                      try {
                        getUsuarioEmail();
                      } catch (e) {
                        print("Erro");
                        print(e);
                      }
                      getUsuarioPermisssao();
                      setState(() {
                        showSpinner = true;
                      });

                      try {
                        setState(() {
                          showSpinner = false;
                        });
                      } catch (e) {
                        print("Erro");
                        print(e);
                      }
                    },
                    minWidth: 200.0,
                    height: 42.0,
                    child: Text(
                      'Entrar',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
