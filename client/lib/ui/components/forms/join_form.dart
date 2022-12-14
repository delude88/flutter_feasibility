import 'package:flutter/material.dart';
import 'package:flutter_feasibility/io/socket_connection.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';

typedef LoginCallback = void Function(String email, String password);

class JoinForm extends StatefulWidget {
  final SocketConnection repository;

  const JoinForm({super.key, required this.repository});

  @override
  State<StatefulWidget> createState() => _JoinFormState();
}

class _JoinFormState extends State<JoinForm> {
  final _codeController = TextEditingController();
  bool _onEditing = true;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 600),
        child: VerificationCode(
          length: 4,
          onCompleted: (String value) {
            widget.repository.joinRoom(value);
          },
          onEditing: (bool value) {
            setState(() {
              _onEditing = value;
            });
            if (!_onEditing) FocusScope.of(context).unfocus();
          },
        ),
      ),
    ]);
  }
}
