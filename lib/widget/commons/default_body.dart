
import 'package:flutter/material.dart';



import 'package:flutter/material.dart';

abstract class DefaultBody extends StatefulWidget {
  late BuildContext buildContext;

  DefaultBody({Key? key}) : super();

  @override
  State<StatefulWidget> createState() => _DefaultBodyState();

  Widget buildBody(BuildContext context);

  void onStart(Duration timeStamp) {
    // nothing to do
  }

  void onDispose() {

  }
}

class _DefaultBodyState extends State<DefaultBody> {
  @override
  Widget build(BuildContext context) {
    widget.buildContext = context;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onStart(timeStamp);
    });

    return widget.buildBody(context);
  }

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }
}

// abstract class DefaultBody extends StatelessWidget {
//   late BuildContext buildContext;
//
//   DefaultBody({ super.key });
//
//   @override
//   Widget build(BuildContext context) {
//     buildContext = context;
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       onStart(timeStamp);
//     });
//
//     return buildBody(context);
//   }
//
//   Widget buildBody(BuildContext context);
//
//   void onStart() {
//     // nothing to do
//   }
// }



// abstract class DefaultBody extends StatelessWidget {
//   late BuildContext buildContext;
//
//   DefaultBody({ super.key });
//
//   @override
//   Widget build(BuildContext context) {
//     buildContext = context;
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       onStart(timeStamp);
//     });
//
//     return buildBody(context);
//   }
//
//   Widget buildBody(BuildContext context);
//
//   void onStart(Duration timeStamp) {
//     // nothing to do
//   }
// }
