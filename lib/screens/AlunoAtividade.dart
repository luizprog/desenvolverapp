// ignore: unused_import
import 'dart:async';
import 'dart:ui' as prefix0;

import 'package:desenvolverapp/screens/DialogAtividade.dart';
import 'package:desenvolverapp/screens/LoginScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'RegistrationScreen.dart';
import 'MenuInicial.dart';
import 'MenuInicialUsuario.dart';
import 'dart:math';
import 'MenuInicial.dart';
import 'MenuInicial.dart';
import 'package:desenvolverapp/FuncoesUteis/Matematica.dart';
import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';

class AlunoAtividadeScreen extends StatefulWidget {
  @override
  static String ID = 'AlunoAtividade_screen';
  _AlunoAtividadeScreenState createState() => _AlunoAtividadeScreenState();
 }

class _AlunoAtividadeScreenState extends State<AlunoAtividadeScreen> {
  final _auth = FirebaseAuth.instance;
  static int acerto;
  bool   showSpinner = false;
  bool   TemDados;
  String senha;
  String usuario;
  String messageText;
  String usuarioSelecionado;
  String nomeUsuarioSelecionado;
  String atividadeSelecionada;
  String agendadiaSelecionada;
  String descricaoSelecionada;
  String objetivoSelecionado;
  String documentID;
  String agendahoraSelecionada;
  int    pontuacaoAtual = 0;
  int    qtde;
  FirebaseUser loggedInUser;
  var diasEntrega;
  var entreguesNoDiaDeHoje;
  static final double myTextSize = 15.0;
  final  double    myIconSize  = 12.0;
  final  TextStyle myTextStyle =
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

  void _showDialogConcluir(String s, String t, int x, int pontuacaoAtual, String ProcedimentoID, String UserID,int numeroAtividades)
  {
    // flutter defined function
    String tipoConclusao;
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
              child: new Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Concluir"),
              onPressed: () {
                var acertos, acertosAgora;
                acertosAgora=0;

                //pontuacaoAtual = 100;
                if(x > 90) {
                  tipoConclusao = 'sem ajuda';
                  acertosAgora = 1;
                }
                if (x > 0 && x < 100 )
                {
                  tipoConclusao = 'parcial';
                }
                if(x < 1)
                {
                  tipoConclusao = 'total';
                }
                DateTime now = DateTime.now();
                var Quantidade;
                
                setState(() {
                    getUsuarioAcertos(documentID, MenuInicialScreen.loggedInUser.email,Quantidade,now, acertosAgora);                    
                });
                


                  //adicionando atividade diaria
                  Firestore.instance.collection('procedimentosEntregues').add({
                    'id': ProcedimentoID + TimeOfDay.now().toString(),
                    'procedimento': atividadeSelecionada,
                    'usuario':UserID,
                    'dataEntrega':now,
                    'conclusao':tipoConclusao,
                    'pontuacao':x,
                  });
                  Firestore.instance
                      .collection('usuarios')
                      .document(UserID)
                      .updateData({'pontuacaoAtual': x + MenuInicialScreen.pontuacaoAtual,'numeroAtividades': numeroAtividades+1});
                  Navigator.pushNamed(context, MenuInicialScreen.ID);
              },
            ),
          ],
        );
      },
    );
  }
  void _callDialogConcluir(String s1, String s2, int x){

    _showDialogConcluir(s1, s2, x,MenuInicialScreen.pontuacaoAtual  ,documentID ,MenuInicialScreen.vUserID,MenuInicialScreen.numeroAtividades);
  }

  /**/

  void getUsuarioAcertos(String idProcedimento, String idUsuario,int Quantidade,DateTime now, int acertosAgora) async {
    final acertoDocumento = 
    await Firestore.instance.collection("procedimento").where('usuario',isEqualTo: idUsuario).getDocuments();

    for (var acertoDocumentoFor in acertoDocumento.documents) {
      if(acertoDocumentoFor.documentID.toString() == idProcedimento.toString())
      {
        
          print('Acertos na funcao getUsuarioAcertos');
          
          print(idUsuario);
          acerto = acertoDocumentoFor.data['acertos'];
          print(acerto);
          if(acerto!=null){
            if(acertosAgora>0){
              acerto = int.parse(acerto.toString())+acertosAgora;
            }
            Firestore.instance
            .collection("procedimento")
            .document(idProcedimento)
            .updateData({"entregasHoje": Quantidade, 'dataEntrega': now, 'acertos': acerto});
          }else{
            print("Nao foi possivel atualizar, acertos estao nulo!");
          }
         
      }
    }
  }

  /**/

  String _getPorcentagem(int numAtividades, int pontosAtual) {
    if(pontosAtual == 0 && numAtividades == 0){
      return '0';
    }
    var x = (numAtividades * 100) - pontosAtual;
    var y = (x / pontosAtual) * 100;
    if (y < 0) {
      y = y * (-1);
    }
    var porcentagemFinal = 100 - y.round();
    return porcentagemFinal.toString();
  }

  String _getAtividadesRestantes(int atividadesPorDia, int atividadesEntregues){
    var qtdeFaltante = atividadesPorDia - atividadesEntregues;
    String all;
    diasEntrega          =  atividadesPorDia;
    entreguesNoDiaDeHoje = atividadesEntregues;
    all = qtdeFaltante.toString();
    return all;
  }

  void _openAddEntryDialog() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.lightBlueAccent,
              centerTitle: true,
              title: Text('Atividades ' + ' - ' + MenuInicialScreen.pontuacaoAtual.toString()),
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
                            "Repetir nos dias:",
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
                      new Card(
                        color: Colors.white70,
                        child: ListTile(
                          title: new Text(
                            "Objetivo atividade:",
                            style: myTextStyle,
                          ),
                          subtitle: Text(
                            objetivoSelecionado,
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
              color: Colors.lightBlueAccent,
              child: new Container(child: Row(
                verticalDirection: VerticalDirection.up,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    textColor: Colors.white,
                    color: Colors.deepOrange,
                    child: Text("Total", style: TextStyle(color: Colors.white,),),
                    onPressed: () {    _callDialogConcluir(
                        "total", "", 0);},
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                  ),
                  RaisedButton(
                    textColor: Colors.white,
                    color: Colors.yellowAccent,
                child: Text("Parcial", style: TextStyle(color: Colors.blueAccent),),
                    onPressed: () {
                      _callDialogConcluir(
                          "parcial", "", 50);
                    },
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                  ),
                  RaisedButton(
                    textColor: Colors.white,
                    color: Colors.green,
                    child: Text("Sem Ajuda", style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      _callDialogConcluir("sem ajuda", "", 100);
                    },
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                  ),
                ],
              ),
              ),
            ),
          );
        },
        fullscreenDialog: true));
  }

  Widget build(BuildContext context) {
    //final _kTabPages = <Widget>[
      //Center(child: Icon(Icons.done, size: 24.0, color: Colors.teal)),
      //Center(child: Icon(Icons.done, size: 24.0, color: Colors.green)),
   // ];
    final _kTabs = <Tab>[
      Tab(icon: Icon(Icons.new_releases, color: Colors.yellowAccent, size: 24.0,),    text: 'Atividades'),
      Tab(icon: Icon(Icons.lens, color: Colors.greenAccent, size: 24.0,),    text: 'Sem Ajuda' ),
      Tab(icon: Icon(Icons.lens, color: Colors.blueAccent, size: 24.0,),    text: 'Parcial' ),
      Tab(icon: Icon(Icons.lens, color: Colors.orangeAccent , size: 24.0,),    text: 'Total'   ),

    ];
    return DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: Text( MenuInicialScreen.pontuacaoAtual.toString() + ' pontos. '  +
            _getPorcentagem(MenuInicialScreen.numeroAtividades
            , MenuInicialScreen.pontuacaoAtual) + '%'

        ),
        bottom: TabBar( tabs: _kTabs,),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        children: <Widget>[
          ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: StreamBuilder(
            stream: Firestore.instance
                .collection('procedimento')
                .where('usuario',
                    isEqualTo: MenuInicialScreen.usuarioSelecionado)
                .where('conclusao', isEqualTo: "pendente").snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return new Center(

                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                return new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  verticalDirection: VerticalDirection.down,
                  children: snapshot.data.documents.map((document) {
                    
                    if (document['conclusao'] == "sem ajuda") {
                      return new FlatButton(
                        child:  Column(
                          children: <Widget>[
                            new MyCard(
                              subtitle: Text(""),
                              title: new Text(
                                document['procedimento'],
                                style: myTextStyle,
                              ),
                              //icon: new Icon(Icons.label_important,size: myIconSize,color: Colors.amberAccent,),
                            ),
                          ],
                        ),
                        onPressed: () {
                          nomeUsuarioSelecionado = MenuInicialScreen.nomeUsuarioSelecionado;
                          usuarioSelecionado     = document['usuario'].toString();
                          atividadeSelecionada   = document['procedimento'].toString();
                          agendadiaSelecionada   = document['agendadia'].toString();
                          agendahoraSelecionada  = document['agendahora'].toString();
                          descricaoSelecionada   = document['descricao'].toString();
                          pontuacaoAtual         = document['pontuacaoAtual'];
                          objetivoSelecionado    = document['objetivo'].toString();
                          documentID             = document.documentID;
                          _openAddEntryDialog();
                        },
                      ); //Column
                    } else {
                      print(document.documentID);
                      print(document['acertos']);
                      print(document['acertos'] != int.parse(document['acertosNecessarios']));
                      if(document['acertos'] != int.parse(document['acertosNecessarios'])){
                      return new FlatButton(
                        child: Column(
                          children: <Widget>[
                            new MyCard(
                              title: new Text(
                                document['procedimento'],
                                style: myTextStyle,
                              ),
                              subtitle: Text(document['acertos'].toString()+'/'+document['acertosNecessarios'].toString()
                                , style: myTextStyle, ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            nomeUsuarioSelecionado =
                                MenuInicialScreen.nomeUsuarioSelecionado;
                            usuarioSelecionado = document['usuario'].toString();
                            atividadeSelecionada = document['procedimento'].toString();
                            agendadiaSelecionada = document['agendadia'].toString();
                            agendahoraSelecionada = document['agendahora'].toString();
                            descricaoSelecionada = document['descricao'].toString();
                            pontuacaoAtual =  document['pontuacaoAtual'];
                            objetivoSelecionado = document['objetivo'].toString();
                            documentID = document.documentID;
                            setState(() {
                              _openAddEntryDialog();
                            });
                          });
                        },
                      ); //Column
                    }else{
                      return new Text(''
                      );
                    }
                    
                    }
                  }).toList(),
                ); //ListView
              }
            },
          ),
        ),
      ),
          ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('procedimentosEntregues')
                    .where('usuario',
                    isEqualTo: MenuInicialScreen.vUserID)
                    .where('conclusao', isEqualTo: 'sem ajuda').snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return new Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return new ListView(
                       children: snapshot.data.documents.map((document) {
                         if (document['conclusao'] == "sem ajuda") {
                           return new FlatButton(
                             child: Column(
                               children: <Widget>[
                                 new MyCard(
                                   subtitle: Text(""),
                                   title: new Text(
                                       document['procedimento'].toString() + ' • ' + formatDate(DateTime.fromMillisecondsSinceEpoch(document['dataEntrega'].seconds * 1000), [dd,'/',mm,'/',yyyy,' ',HH,':',nn ]) ,
                                     style: myTextStyle,
                                   ),
                                 ),
                               ],
                             ),
                             onPressed: () {
                               print(document['dataEntrega'].toString());
                               print("Sem ajuda clicado!");
                             },
                           ); //Column
                         } else {
                           return new FlatButton(
                             child: Column(
                               children: <Widget>[
                                 new MyCard(
                                   subtitle: Text(""),
                                   title: new Text(
                                     document['procedimento'].toString() + ' • ' + formatDate(DateTime.fromMillisecondsSinceEpoch(document['dataEntrega'].seconds * 1000), [dd,'/',mm,'/',yyyy,' ',HH,':',nn ]) ,
                                     style: myTextStyle,
                                   ),
                                 ),
                               ],
                             ),
                             onPressed: () {
                               print("Sem ajuda clicado");
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
          ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('procedimentosEntregues')
                    .where('usuario',
                    isEqualTo: MenuInicialScreen.vUserID)
                    .where('conclusao', isEqualTo: 'parcial').snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return new Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return new ListView(

                      children: snapshot.data.documents.map((document) {
                        if (document['conclusao'] == "sem ajuda") {
                          return new FlatButton(
                            child: Column(
                              children: <Widget>[
                                new MyCard(
                                  subtitle: Text(""),
                                  title: new Text(
                                    document['procedimento'].toString() + ' • ' + formatDate(DateTime.fromMillisecondsSinceEpoch(document['dataEntrega'].seconds * 1000), [dd,'/',mm,'/',yyyy,' ',HH,':',nn ]) ,
                                    style: myTextStyle,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              print("qwert Clicado done");
                            },
                          ); //Column
                        } else {
                          return new FlatButton(
                            child: Column(
                              children: <Widget>[
                                new MyCard(
                                  subtitle: Text(""),
                                  title: new Text(
                                    document['procedimento'].toString() + ' • ' + formatDate(DateTime.fromMillisecondsSinceEpoch(document['dataEntrega'].seconds * 1000), [dd,'/',mm,'/',yyyy,' ',HH,':',nn ]) ,
                                    style: myTextStyle,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              print("Parcial Clicado");
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
          ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('procedimentosEntregues')
                    .where('usuario',
                    isEqualTo: MenuInicialScreen.vUserID)
                    .where('conclusao', isEqualTo: 'total').snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return new Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return new ListView(
                      children: snapshot.data.documents.map((document) {
                        if (document['conclusao'] == "sem ajuda") {
                          return new FlatButton(
                            child: Column(
                              children: <Widget>[
                                new MyCard(
                                  subtitle: Text(""),
                                  title: new Text(
                                    document['procedimento'].toString() + ' • ' + formatDate(DateTime.fromMillisecondsSinceEpoch(document['dataEntrega'].seconds * 1000), [dd,'/',mm,'/',yyyy,' ',HH,':',nn ]) ,
                                    style: myTextStyle,
                                  ),
                                  //icon: new Icon(Icons.done,size: myIconSize,color: Colors.deepOrange,),
                                ),
                              ],
                            ),
                            onPressed: () {
                              print('qwert  orange');
                            },
                          ); //Column
                        } else {
                          return new FlatButton(
                            child: Column(
                              children: <Widget>[
                                new MyCard(
                                  subtitle: Text(""),
                                  title: new Text(
                                    document['procedimento'].toString(),
                                    style: myTextStyle,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              getModal();
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
        ],
      ),
    ),
    );
  }

  Widget getModal() {
    return new AlertDialog(actions: <Widget>[Text("Voltar")],content: new Container(child: Text("qwer"),),);
  }
}

class MyCard extends StatelessWidget {
//  final Widget icon;
  final Widget title;
  final Widget subtitle;

  MyCard({this.title, /*this.icon,*/ this.subtitle});

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(4.0),
      child: new Card(
        color: Colors.white70,
        child: new Container(
          width: 850,
          padding: const EdgeInsets.all(10.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[this.title, this.subtitle],
          ),
        ),
      ),
    );
  }
}
