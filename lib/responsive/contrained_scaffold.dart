import 'package:flutter/material.dart';

class ContrainedScaffold extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final bool? resizeToAvoidBottomInset;
  
  const ContrainedScaffold({
    super.key,
     this.appBar,
     this.body,
     this.drawer,
     this.resizeToAvoidBottomInset
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 465),
          child: body,
        ),
      ),
    );
  }
}
