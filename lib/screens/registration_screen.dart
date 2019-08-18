import 'package:flutter/material.dart'
    show
        BorderRadius,
        BorderSide,
        BuildContext,
        Colors,
        Column,
        Container,
        CrossAxisAlignment,
        DropdownMenuItem,
        EdgeInsets,
        Hero,
        Image,
        InputDecoration,
        MainAxisAlignment,
        Material,
        MaterialButton,
        Navigator,
        OutlineInputBorder,
        Padding,
        Radius,
        Scaffold,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        TextAlign,
        TextField,
        TextStyle,
        Widget;
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'MenuInicial.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  static String ID = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  List<String> _comboTipo = new List<String>();
  bool showSpinner = false;
  String usuario;
  String nomeusuario;
  String senha;
  String tipo;

  String novoCadastroEmail;
  String novoCadastroUsuario;
  String novoCadastroSenha;

  List _cities = ['administrador', 'comum'];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentCity;

  @override
  void initState() {
    _comboTipo.addAll(['administrador', 'comum']);
    //  tipo = _comboTipo.elementAt(0);
    print(tipo);
    print(_comboTipo.toString());

    _dropDownMenuItems = getDropDownMenuItems();
    tipo = _dropDownMenuItems[0].value;
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in _cities) {
      items.add(new DropdownMenuItem(value: city, child: new Text(city)));
    }
    return items;
  }

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _currentCity = selectedCity;
      print(selectedCity);
    });
  }

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
                  height: 200.0,
                  child: Image.asset('images/auti.png'),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                style: TextStyle(color: Colors.black.withOpacity(1.0)),
                textAlign: TextAlign.center,
                onChanged: (value) {
                  novoCadastroUsuario = value;
                },
                decoration: InputDecoration(
                  hintText: 'Nome de usuario',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.blueAccent, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.blueAccent, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                style: TextStyle(color: Colors.black.withOpacity(1.0)),
                textAlign: TextAlign.center,
                onChanged: (value) {
                  novoCadastroEmail = value;
                },
                decoration: InputDecoration(
                  hintText: 'Entre com o email',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.blueAccent, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.blueAccent, width: 2.0),
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
                  novoCadastroSenha = value;
                },
                decoration: InputDecoration(
                  hintText: 'Entre com a senha',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.blueAccent, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.blueAccent, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),

              /**/

              SizedBox(
                height: 24.0,
              ),

              /**/

              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: novoCadastroEmail,
                                password: novoCadastroSenha);

                        _firestore.collection('usuarios').add({
                          'nivelDeAcesso':
                              _currentCity == null ? "comum" : _currentCity,
                          'usuario': novoCadastroEmail,
                          'nomeusuario': novoCadastroUsuario,
                        });

                        if (newUser != null) {
                          Navigator.pushNamed(context, MenuInicialScreen.ID);
                        }
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
                      'Register',
                      style: TextStyle(color: Colors.white),
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
