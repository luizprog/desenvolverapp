// ignore: unused_import
import 'package:desenvolverapp/screens/DialogAtividade.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'registration_screen.dart';
import 'MenuInicial.dart';

class AlunoAtividadeScreen extends StatefulWidget {
  @override
  static String ID = 'AlunoAtividade_screen';

  _AlunoAtividadeScreenState createState() => _AlunoAtividadeScreenState();
}

class _AlunoAtividadeScreenState extends State<AlunoAtividadeScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String senha;
  String usuario;
  FirebaseUser loggedInUser;
  String messageText;
  bool TemDados;

  String usuarioSelecionado;
  String nomeUsuarioSelecionado;
  String atividadeSelecionada;
  String agendadiaSelecionada;
  String agendahoraSelecionada;
  String descricaoSelecionada;
  String documentID;
  int pontuacaoAtual = 0;

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
      }
    } catch (e) {
      print(e);
    }
  }

  void _showDialogConcluir(String s, String t) {
    // flutter defined function
    t = "Finalizar a atividade com a seguinte conclusao:";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            t,
            style: TextStyle(color: Colors.black54),
          ),
          content: new Text(
            s,
            style: TextStyle(color: Colors.black54),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Concluir"),
              onPressed: () {
                //pontuacaoAtual = 100;

                Firestore.instance
                    .collection("procedimento")
                    .document(documentID)
                    .updateData({"conclusao": "sucesso", "pontuacao": 100});

                //"pontuacaoAtual": "pontuacaoAtual",

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openAddEntryDialog() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.lightBlueAccent,
              centerTitle: true,
              title: Text('Atividades ' + nomeUsuarioSelecionado),
            ),
            backgroundColor: Colors.white,
            body: ModalProgressHUD(
              inAsyncCall: showSpinner,
              child: Container(
                child: new Container(
                  child: Column(
                    children: <Widget>[
                      new Card(
                        color: Colors.white70,
                        child: new ListTile(
                          title: new Text(
                            "Titulo procedimento:",
                            style: myTextStyle,
                          ),
                          subtitle: Text(
                            atividadeSelecionada,
                            style: TextStyle(color: Colors.black54),
                          ),
                          enabled: true,
                          isThreeLine: true,
                        ),
                      ),
                      new Card(
                        color: Colors.white70,
                        child: new ListTile(
                          title: new Text(
                            "Dia da atividade:",
                            style: myTextStyle,
                          ),
                          subtitle: Text(
                            agendadiaSelecionada,
                            style: TextStyle(color: Colors.black54),
                          ),
                          enabled: true,
                          isThreeLine: true,
                        ),
                      ),
                      new Card(
                        color: Colors.white70,
                        child: new ListTile(
                          title: new Text(
                            "Horario da Atividade:",
                            style: myTextStyle,
                          ),
                          subtitle: Text(
                            agendahoraSelecionada,
                            style: TextStyle(color: Colors.black54),
                          ),
                          enabled: true,
                          isThreeLine: true,
                        ),
                      ),
                      new Card(
                        color: Colors.white70,
                        child: ListTile(
                          title: new Text(
                            "Descrição da atividade:",
                            style: myTextStyle,
                          ),
                          subtitle: Text(
                            descricaoSelecionada,
                            style: TextStyle(color: Colors.black54),
                          ),
                          enabled: true,
                          isThreeLine: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: new Row(
                verticalDirection: VerticalDirection.up,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  /* new FlatButton(
                      onPressed: null, child: Icon(Icons.done_outline)),
                 */
                  IconButton(
                    icon: Icon(
                      Icons.thumb_down,
                      size: 36.0,
                      color: Colors.deepOrangeAccent,
                    ),
                    onPressed: () {
                      _showDialogConcluir(
                          "Concluido totalmente com ajuda!", "");
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.thumbs_up_down,
                      size: 36.0,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      _showDialogConcluir(
                          "Concluido parcialmente com ajuda!", "");
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.thumb_up,
                      size: 36.0,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      _showDialogConcluir("Concluido com sucesso!", "");
                    },
                  ),
                ],
              ),
            ),
          );
        },
        fullscreenDialog: true));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: Text('Atividades'),
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: StreamBuilder(
            stream: Firestore.instance
                .collection('procedimento')
                .where('usuario',
                    isEqualTo: MenuInicialScreen.usuarioSelecionado)
                .where('conclusao', isEqualTo: "pendente")
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return new Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                return new Column(
                  mainAxisSize: MainAxisSize.max,
                  verticalDirection: VerticalDirection.down,
                  children: snapshot.data.documents.map((document) {
                    print(document['conclusao'].toString());
                    if (document['conclusao'] == "sucesso") {
                      return new FlatButton(
                        child: Column(
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
                        ),
                        onPressed: () {
                          /*
                          print(document['procedimento']);
                          print(document['usuario']);
                          */
                          nomeUsuarioSelecionado =
                              MenuInicialScreen.nomeUsuarioSelecionado;
                          usuarioSelecionado = document['usuario'];
                          atividadeSelecionada = document['procedimento'];
                          agendadiaSelecionada = document['agendadia'];
                          agendahoraSelecionada = document['agendahora'];
                          descricaoSelecionada = document['descricao'];
                          pontuacaoAtual = document['pontuacaoAtual'];
                          documentID = document.documentID;
                          _openAddEntryDialog();
                        },
                      ); //Column
                    } else {
                      return new FlatButton(
                        child: Column(
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
                        ),
                        onPressed: () {
                          nomeUsuarioSelecionado =
                              MenuInicialScreen.nomeUsuarioSelecionado;
                          usuarioSelecionado = document['usuario'];
                          atividadeSelecionada = document['procedimento'];
                          agendadiaSelecionada = document['agendadia'];
                          agendahoraSelecionada = document['agendahora'];
                          descricaoSelecionada = document['descricao'];
                          pontuacaoAtual = document['pontuacaoAtual'];
                          documentID = document.documentID;
                          _openAddEntryDialog();
                        },
                      ); //Column
                    }
                  }).toList(),
                ); //ListView
              }
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
