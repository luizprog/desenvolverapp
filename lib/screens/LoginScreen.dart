import 'package:desenvolverapp/screens/ErroNaSenha.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'MenuInicial.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatefulWidget {
  @override
  static String ID = 'login_screen';

  //variaveis globais para uso em outras classes

  static String       PERMISSAO_USUARIO;
  static String       usuarioemailLogado     = "";
  static String       nomeUsuarioLogado      = "";
  static String       vUserIDLogado          = "";
  static int          pontuacaoAtualLogado   = 0;
  static int          numeroAtividadesLogado = 0;

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _auth = FirebaseAuth.instance;
  var _firestore = Firestore.instance;

  bool showSpinner    = false;
  String usuario      = "";
  String usuarioEmail = "";
  String senha        = "";
  String permissao    = "";
  var loginUserName   = null;
  var tentoulogin   = 0;

  void getUsuarioEmail() async {
    loginUserName =
        await _firestore.collection('usuarios').getDocuments();
    for (var usuariosLogado in loginUserName.documents) {
      if (usuariosLogado.data['nomeusuario'].toString() == usuario) {
        usuarioEmail = usuariosLogado.data['usuario'].toString();
      }
    }
    try{
      final newUser = await _auth.signInWithEmailAndPassword(
          email: usuarioEmail, password: senha);
      setState(() {

      });

    }catch(e){
      if(e.toString().contains('ERROR_WRONG_PASSWORD'))
      {
        print('No IFFF 9872');
        showDialog(
          context: context,
          builder: (BuildContext context) {
          // return object of type Dialog
            return AlertDialog(
                title: new Text(
                  'Erro ao tentar entrar no App, senha invalida!',
                  style: TextStyle(color: Colors.black54),
                ),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new FlatButton(
                    child: new Text("Fechar"),
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.ID);
                    },
                  ),
                ],
            );
          },
        );
      }
      if(e.toString().contains('ERROR_TOO_MANY_REQUESTS'))
      {
        print('No IFFF 9872');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text(
                'Nosso servidor está lotado, tente novamente em 10 minutos!',
                style: TextStyle(color: Colors.black54),
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Fechar"),
                  onPressed: () {
                    Navigator.pushNamed(context, LoginScreen.ID);
                  },
                ),
              ],
            );
          },
        );
      }

      print('Erro 3: ' + e.toString());
    }


  }

  void getUsuarioPermisssao() async {
    final permissao = await _firestore.collection('usuarios').getDocuments();

    for (var usuariosLogado in permissao.documents) {
      if (usuariosLogado.data['usuario'].toString() == usuarioEmail) {
        LoginScreen.usuarioemailLogado          = usuariosLogado.data['usuario'];
        LoginScreen.nomeUsuarioLogado           = usuariosLogado.data['nomeusuario'];
        LoginScreen.vUserIDLogado               = usuariosLogado.documentID;
        LoginScreen.pontuacaoAtualLogado        = usuariosLogado.data['pontuacaoAtual'];
        LoginScreen.numeroAtividadesLogado      = usuariosLogado.data['numeroAtividades'];
        LoginScreen.PERMISSAO_USUARIO = usuariosLogado.data['nivelDeAcesso'].toString();
        if(tentoulogin!=1)
          Navigator.pushNamed(context, MenuInicialScreen.ID);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,

        child: new ListView(
          children: <Widget>[
        new Column(children:<Widget>[
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
                      try{
                        setState(() {
                          tentoulogin = 1;
                        });

                        try {
                          getUsuarioEmail();
                        } catch (e) {
                          AlertDialog( actions: <Widget>[Text('Erro ao efetuar o login tente novamente!'),],title: Text('Erro no login'),);
                          print('Erro 1 no catch onPressed(): ' + e.toString());
                        }
                        getUsuarioPermisssao();
                        setState(() {

                          showSpinner = true;
                        });
                        try {
                          setState(() {
                          showSpinner = false;
                          tentoulogin = 0;
                        });
                        } catch (e) {
                          _auth.signOut();
                          AlertDialog(title: Text("Falha ao tentar efetuar o login, verifique os dados informados!"),);
                          print(e);
                        }

                      }
                      catch (e) {
                        print('Erro 2 no catch onPressed(): ' + e.toString());
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
          ],
          ),
        ),
    );
  }
}
