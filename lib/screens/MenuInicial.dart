import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'registration_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'RegistroAtividadeIndividualScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'AlunoAtividade.dart';
import 'login_screen.dart';
import 'package:desenvolverapp/FuncoesUteis/Matematica.dart';
import 'dart:math';

class MenuInicialScreen extends StatefulWidget {
  @override
  static String ID = 'MenuInicial_screen';

  //variaveis globais com os dados do usuario logado
  static String       currentUser            = "";
  static FirebaseUser loggedInUser           = null;


  //variaveis globais com os dados do usuario selecionado
  static String usuarioSelecionado     = "";
  static String nomeUsuarioSelecionado = "";
  static String vUserID                = "";
  static int    pontuacaoAtual         = 0;
  static int    numeroAtividades       = 0;

  _MenuInicialScreenState createState() => _MenuInicialScreenState();
}

class _MenuInicialScreenState extends State<MenuInicialScreen> {
  final _auth = FirebaseAuth.instance;
  String senha       = "";
  String usuario     = "";
  Widget widgetBody;
  String messageText = "";
  String loggedInUserLocal;
  bool   showSpinner = false;
  QuerySnapshot selectUser;
  final double myIconSize = 20.0;
  static final double myTextSize = 20.0;
  final TextStyle myTextStyle =
      new TextStyle(color: Colors.black, fontSize: myTextSize);

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

   getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        MenuInicialScreen.loggedInUser = user;
        loggedInUserLocal = user.email;
        print(user.email);
        print('qwertyu');
      }
    } catch (e) {
      //final sair = await _auth.signOut();
      print(e);
    }
  }

  void gotoRegistration() {
    setState(() {
      showSpinner = true;
    });

    try {
      Navigator.pushNamed(context, RegistrationScreen.ID);
      setState(() {
        showSpinner = false;
      });
    } catch (e) {
      print("Erro");
      print(e);
    }
  }

  String _getPorcentagem(int numAtividades, int pontosAtual) {
    var x = (numAtividades * 100) - pontosAtual;
    var y = (x / pontosAtual) * 100;

    if (y < 0) {
      y = y * (-1);
    }

    var porcentagemFinal = 100 - y.round();

    return porcentagemFinal.toString();
  }

  void goToAlunoAtividadesMain(
      String emailUsuarioSelecionado, String nomeUsuarioSelecionado, String documentID,int pontuacaoAtual, int numeroAtividades) {
    MenuInicialScreen.usuarioSelecionado = emailUsuarioSelecionado;
    MenuInicialScreen.nomeUsuarioSelecionado = nomeUsuarioSelecionado;
    MenuInicialScreen.vUserID = documentID;
    MenuInicialScreen.pontuacaoAtual = pontuacaoAtual;
    MenuInicialScreen.numeroAtividades = numeroAtividades;
    Navigator.pushNamed(context, AlunoAtividadeScreen.ID);
  }


  _getUsuarioLogadoFromFirestore() async {
    return await Firestore.instance.collection('usuarios').where('usuario', isEqualTo: loggedInUserLocal).getDocuments();
  }
/*  Future<Null> logoutWithGoogle() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }*/

  Widget build(BuildContext context) {

    if (LoginScreen.PERMISSAO_USUARIO.toString()=="administrador") // || MenuInicialScreen.lo == 'luiz@ssuark.com.br' )
        {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          centerTitle: true,
          title: Text('Desenvolver - ' + LoginScreen.nomeUsuarioLogado),
          leading: new Container(),
        ),
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection('usuarios')
                  .where("nivelDeAcesso", isEqualTo: 'comum')
                  .snapshots(),
              builder:
                  (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text('Loading...');

                return new Column(
                  mainAxisSize: MainAxisSize.max,
                  verticalDirection: VerticalDirection.down,
                  children: snapshot.data.documents.map((document) {
                    return new Container(
                      padding: const EdgeInsets.all(5.0),
                      width: 680,
                      child: Card(
                        child: MaterialButton(
                          onPressed: () {
                            goToAlunoAtividadesMain(
                                document['usuario'], document['nomeusuario'],
                                document.documentID, document['pontuacaoAtual'],
                                document['numeroAtividades']);
                          },
                          child: Text(
                            document['nomeusuario'] + ' - ' +  _getPorcentagem(document['numeroAtividades'],document['pontuacaoAtual']) + '%',
                            style: myTextStyle,
                          ),
                        ),
                        color: Colors.white70,
                      ),
                    );
                  }).toList(),
                ); //ListView
              },
            ),
          ),
        ),
        floatingActionButton: SpeedDial(
          // onPressed: () {
          // Add your onPressed code here!
          // },
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          children: [
            SpeedDialChild(
                child: Icon(Icons.accessibility),
                backgroundColor: Colors.blue,
                label: 'Novo aluno',
                //labelStyle: TextTheme(fontSize: 18.0),
                labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                onTap: () => gotoRegistration()),
            SpeedDialChild(
              child: Icon(Icons.person_add),
              backgroundColor: Colors.green,
              label: 'Nova atividade',
              //labelStyle: TextTheme(fontSize: 18.0),
              labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
              onTap: () =>
                  Navigator.pushNamed(
                      context, RegistroAtividadeIndividualScreen.ID),
            ),
            SpeedDialChild(
              child: Icon(Icons.group_add),
              backgroundColor: Colors.lightGreen,
              labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
              label: 'Relatório de desempenho',
              labelBackgroundColor: Colors.grey,
              //labelStyle: TextTheme(fontSize: 18.0),
              onTap: () => print('THIRD CHILD'),
            ),
          ],
        ),
      );
    }
    else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          centerTitle: true,
          title: Text('Desenvolver - ' + LoginScreen.nomeUsuarioLogado),
        ),
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child:
            Column(children: <Widget>[
              new Container(

                width: 680,
                child: FlatButton(
                  child: Column(
                    children: <Widget>[
                      new MyCard(
                        title: new Text(
                          "Próxima atividade",
                          style: myTextStyle,
                        ),
                        icon: new Icon(
                          Icons.schedule,
                          size: myIconSize,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  onPressed: (){
                    AlertDialog(title: Text("Próxima atividade"));
                  }
                ),
              ),


              new Container(
                width: 680,
                child: FlatButton(
                  child: Column(
                    children: <Widget>[
                      new MyCard(
                        title: new Text(
                          "Todas as atividades",
                          style: myTextStyle,
                        ),
                        icon: new Icon(
                          Icons.arrow_forward,
                          size: myIconSize,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    _getUsuarioLogadoFromFirestore().then((results){
                        selectUser = results;
                        print(selectUser.documents.first.data['numeroAtividades']);
                        print('estado');
                        //print(selectUser.documents.first['usuario']);
                        goToAlunoAtividadesMain(
                            LoginScreen.usuarioemailLogado, LoginScreen.nomeUsuarioLogado,
                            LoginScreen.vUserIDLogado, selectUser.documents.first.data['pontuacaoAtual'],
                            selectUser.documents.first.data['numeroAtividades']);
                    });
                  },
                ),
              ),
              new Container(

                width: 680,
                child: FlatButton(
                  child: Column(
                    children: <Widget>[
                      new MyCard(
                        title: new Text(
                          "Enviar dúvida",
                          style: myTextStyle,
                        ),
                        icon: new Icon(
                          Icons.question_answer,
                          size: myIconSize,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                    ],
                  ),
                    onPressed: (){
                      AlertDialog(title: Text("Duvida"));
                    }
                ),
              ),
            ],

            ),
          ),
        ),

      );
    }
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
      padding: const EdgeInsets.all(2.0),
      child: new Card(
        color: Colors.white70,
        child: new Container(
          padding: const EdgeInsets.all(20.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            textBaseline: TextBaseline.alphabetic,
            textDirection: TextDirection.ltr,
            children: <Widget>[this.title, this.icon],
          ),
        ),
      ),
    );
  }
}
