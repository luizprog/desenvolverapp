import 'dart:convert';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'RegistrationScreen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'RegistroAtividadeIndividualScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AlunoAtividade.dart';
import 'LoginScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseUser;
import 'package:csv/csv.dart';
import 'TrocarSenha.dart';

class DataTableScreen extends StatefulWidget {
  @override
  static String ID = 'DataTable_screen';
  //variaveis globais com os dados do usuario logado
  static String       currentUser            = "";
  static FirebaseUser loggedInUser           = null;
  //variaveis globais com os dados do usuario selecionado
  static String usuarioSelecionado     = "";
  static String nomeUsuarioSelecionado = "";
  static String vUserID                = "";
  static int    pontuacaoAtual         = 0;
  static int    numeroAtividades       = 0;
  _DataTableScreenState createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  final _auth = FirebaseAuth.instance;
  String userID_atual = "";
  String        senha       = "";
  String        usuario     = "";
  String        novaSenha     = "";
  Widget        widgetBody;
  String        messageText = "";
  String        loggedInUserLocal;
  bool          showSpinner = false;
  QuerySnapshot selectUser;
  final double  myIconSize = 20.0;
  static final  double myTextSize = 20.0;
  static String emailUsuarioLinha = "";
  final TextStyle myTextStyle =
  new TextStyle(color: Colors.black, fontSize: myTextSize);

  /*List variaveis*/
  List<DocumentSnapshot> products = []; // stores fetched products

  bool isLoading = false; // track if products fetching

  bool hasMore = true; // flag for more products available or not

  int documentLimit = 10; // documents to be fetched per request

  DocumentSnapshot lastDocument; // flag for last document from where next 10 records to be fetched

  ScrollController _scrollController = ScrollController(); // li

  Firestore firestore = Firestore.instance;


  @override
  void initState() {
    super.initState();
    getProducts();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getProducts();
      }
    });
    getCurrentUser();
  }

  getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        DataTableScreen.loggedInUser = user;
        loggedInUserLocal = user.email;
        userID_atual = user.uid;
      }
    } catch (e) {
      //final sair = await _auth.signOut();
      print("Erro ao efetuar o login do usuario, verifique!");
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
      print("Erro ao tentar acessar tela de registro!");
    }
  }

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

  void goToAlunoAtividadesMain(
      String emailUsuarioSelecionado,
      String nomeUsuarioSelecionado,
      String documentID,
      int pontuacaoAtual,
      int numeroAtividades) {
    DataTableScreen.usuarioSelecionado = emailUsuarioSelecionado;
    DataTableScreen.nomeUsuarioSelecionado = nomeUsuarioSelecionado;
    DataTableScreen.vUserID = documentID;
    DataTableScreen.pontuacaoAtual = pontuacaoAtual;
    DataTableScreen.numeroAtividades = numeroAtividades;
    Navigator.pushNamed(context, AlunoAtividadeScreen.ID);
  }

  _getUsuarioLogadoFromFirestore() async {
    return await Firestore.instance.collection('usuarios').where('usuario', isEqualTo: loggedInUserLocal).getDocuments();
  }


  /**/

  void _createEmail(String email,String assunto, String corpo) async{
    String emailaddress = 'mailto:$email?subject=$assunto&body=$corpo';

    if(await canLaunch(emailaddress)) {
      await launch(emailaddress);
    }  else {
      throw 'Could not Email';
    }
  }

  void _makeCall() async{
    const phonenumber = "tel:9999999";

    if(await canLaunch(phonenumber)) {
      await launch(phonenumber);
    } else {
      throw 'Could not call';
    }
  }

  void _sendSMS() async{
    const phonenumber = "sms:9999999";

    if(await canLaunch(phonenumber)) {
      await launch(phonenumber);
    } else {
      throw 'Could not SMS';
    }
  }

  void _changePassword(String password) async{
    //Create an instance of the current user.
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    //Pass in the password to updatePassword.
    user.updatePassword(password).then((_){
      print("Succesfull changed password");
    }).catchError((error){
      print("Password can't be changed" + error.toString());
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  void _showDialogTeste() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Text("Alteração de senha", style: TextStyle(color: Colors.black),),
          content: new Text("Sua senha foi alterada com sucesso!", style: TextStyle(color: Colors.black),),
          actions: <Widget>[
            // define os botões na base do dialogo
            new FlatButton(
              child: new Text("ok"),
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.ID);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialogAlterarSenha() {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return SimpleDialog(
          title: new Text("Alterar senha do App", style: TextStyle(color: Colors.black),),

          children: <Widget>[

            new TextField(
              style: TextStyle(color: Colors.grey),
              enabled: true,
              expands: false,
              onChanged: (value){
                novaSenha = value;
              },
            ),
            new Row( children: <Widget>[
              new FlatButton(child: new Text("        "),onPressed: () {},),
              new FlatButton(child: new Text("Confirmar"),onPressed: () {
                _changePassword(novaSenha);
                _showDialogTeste();
                //Navigator.pushNamed(context, LoginScreen.ID);
              },),
              new FlatButton(child: new Text("Fechar"),onPressed: () {Navigator.of(context).pop();},
              ),
            ],
            ),
          ],

        );
      },
    );
  }


  getProducts() async {
    if (!hasMore) {
      print('No More Products');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await firestore
          .collection('procedimento').orderBy('usuario')
          .getDocuments();
    } else {
      querySnapshot = await firestore
          .collection('procedimento').orderBy('usuario')
          .startAfterDocument(lastDocument)
          .getDocuments();
      print(1);
    }
    if (querySnapshot.documents.length < documentLimit) {
      hasMore = false;
    }
    lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    products.addAll(querySnapshot.documents);
    setState(() {
      isLoading = false;
    });
    print('entrou no getProducts');

  }



  Widget build(BuildContext context) {
    if (LoginScreen.PERMISSAO_USUARIO.toString()=="administrador") // || DataTableScreen.lo == 'luiz@ssuark.com.br' )
        {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          centerTitle: true,
          title: Text('Desenvolver  - ' + LoginScreen.nomeUsuarioLogado),
          leading: new Container(
              child: IconButton(
                onPressed: (){
                  _showDialogAlterarSenha();
                },
                icon: Icon(Icons.vpn_key),
              )
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(

            child: Column(
                children: [
                    Expanded(
                      child: products.length == 0
                          ? Center(
                        child: Text('No Data...'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                        return ListTile(
                        dense: true,
                        isThreeLine: true,
                        leading: Icon(Icons.remove_red_eye),
                        trailing: Text(products[index].data['conclusao'].toString(),style: TextStyle(color: Colors.black),textAlign: TextAlign.right,),
                        contentPadding: EdgeInsets.all(1),
                        title: Text(products[index].data['procedimento']+ ' - ' + products[index].data['usuario'],//products[index].data['usuario'],
                          style: TextStyle(color: Colors.black),),
                        subtitle:
                            Container(child:
                              Row( children:[
                                Text(products[index].data['comajuda'].toString()
                                ,style: TextStyle(color: Colors.redAccent, fontSize: 20.0),),
                                Text(' / ',style: TextStyle(color: Colors.black , fontSize: 20.0)),
                                Text(   products[index].data['parcialajuda'].toString(),style: TextStyle(color: Colors.blueAccent, fontSize: 20.0),),
                                Text(' / ',style: TextStyle(color: Colors.black, fontSize: 20.0)),
                                Text(  products[index].data['semajuda'].toString(),style: TextStyle(color: Colors.green, fontSize: 20.0),),


                              ],

                            ),
                          ),
                      );
                    },
                ),
              ),


              isLoading
                  ? Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(5),
                color: Colors.yellowAccent,

                child: Text(
                  'Loading',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              )
                  : Container()
            ]
            ),
        ),
      );
    }
  }
}

