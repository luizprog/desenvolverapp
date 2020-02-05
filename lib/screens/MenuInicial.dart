import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'RegistrationScreen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'RegistroAtividadeIndividualScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AlunoAtividade.dart';
import 'LoginScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseUser;
import 'TrocarSenha.dart';

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
          /*actions: <Widget>[

            /*TextField(
              style: TextStyle(color: Colors.black.withOpacity(1.0)),
              textAlign: TextAlign.center,
              onChanged: (value) {
                novaSenha = value;
              },
              decoration: InputDecoration(
                hintText: 'Entre com a nova senha',
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
            ),*/

            new FlatButton(
              child: new Text("Confirmar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            new FlatButton(
              child: new Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],*/
        );
      },
    );
  }

  /**/

  Widget build(BuildContext context) {
    if (LoginScreen.PERMISSAO_USUARIO.toString()=="administrador") // || MenuInicialScreen.lo == 'luiz@ssuark.com.br' )
    {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          centerTitle: true,
          title: Text('Desenvolver  - ' + LoginScreen.nomeUsuarioLogado),
          leading: new Container(
              child: IconButton(

                  onPressed: (){
                    print('Trocar senha pressionado');
                    print(userID_atual);
                    _showDialogAlterarSenha();
                  },
                  icon: Icon(Icons.vpn_key),

              )

          ),
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

                return new ListView(

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
                            document['nomeusuario'] + ' - ' +   _getPorcentagem(document['numeroAtividades'],document['pontuacaoAtual']) + '%',
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
                          "Todas as atividades",
                          style: myTextStyle,
                        ),
                        icon: new Icon(
                          Icons.label,
                          size: myIconSize,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    _getUsuarioLogadoFromFirestore().then((results){
                        selectUser = results;

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
                      _createEmail('aba.desenvolver@gmail.com','Duvida App','Estou Com Dúvida.\n'
                          + 'Usuario '
                          + loggedInUserLocal
                          + ' com duvidas no aplicativo.');
                      //AlertDialog(title: Text("Duvida"));
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
