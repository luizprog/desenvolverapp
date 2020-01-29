import 'package:desenvolverapp/screens/AlunoAtividade.dart';
import 'package:desenvolverapp/screens/ErroNaSenha.dart';
import 'package:flutter/material.dart';
import 'package:desenvolverapp/screens/WelcomeScreen.dart';
import 'package:desenvolverapp/screens/LoginScreen.dart';
import 'package:desenvolverapp/screens/RegistrationScreen.dart';
import 'package:desenvolverapp/screens/MenuInicial.dart';
import 'package:desenvolverapp/screens/MenuInicialUsuario.dart';
import 'package:desenvolverapp/screens/RegistroAtividadeIndividualScreen.dart';

void main() => runApp(DesenvolverApp());

class DesenvolverApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.light().copyWith(textTheme: TextTheme(body1: TextStyle(color: Colors.white30),),),
        initialRoute: WelcomeScreen.ID,
      routes: {
        WelcomeScreen.ID: (context)                     => WelcomeScreen(),
        LoginScreen.ID: (context)                       => LoginScreen(),
        ErroNaSenhaScreen.ID: (context)                       => ErroNaSenhaScreen(),
        RegistrationScreen.ID: (context)                => RegistrationScreen(),
        MenuInicialScreen.ID: (context)                 => MenuInicialScreen(),
        //MenuInicialUsuarioScreen.ID: (context)          => MenuInicialUsuarioScreen(),
        RegistroAtividadeIndividualScreen.ID: (context) => RegistroAtividadeIndividualScreen(),
        AlunoAtividadeScreen.ID: (context)              => AlunoAtividadeScreen(),
      },
    );
  }
}
