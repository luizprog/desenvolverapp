import 'package:flutter/material.dart';

class DialogAtividade extends StatefulWidget {
  @override
  DialogAtividadeState createState() => new DialogAtividadeState();
}

class DialogAtividadeState extends State<DialogAtividade> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('New entry'),
        actions: [
          new FlatButton(
              onPressed: () {
                //TODO: Handle save
              },
              child: new Text('SAVE',
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white))),
        ],
      ),
      body: new Text("Foo"),
    );
  }
}