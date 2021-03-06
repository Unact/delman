import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';

import 'package:delman/app/view_models/accept_payment_view_model.dart';

class AcceptPaymentPage extends StatefulWidget {
  AcceptPaymentPage({Key? key}) : super(key: key);

  @override
  _AcceptPaymentPageState createState() => _AcceptPaymentPageState();
}

class _AcceptPaymentPageState extends State<AcceptPaymentPage> {
  final GlobalKey<SignatureState> _sign = GlobalKey<SignatureState>();
  AcceptPaymentViewModel? _acceptPaymentViewModel;

  @override
  void initState() {
    super.initState();

    _acceptPaymentViewModel = context.read<AcceptPaymentViewModel>();
    _acceptPaymentViewModel!.addListener(this.vmListener);
  }

  @override
  void dispose() {
    _acceptPaymentViewModel!.removeListener(this.vmListener);
    super.dispose();
  }

  Future<void> vmListener() async {
    switch (_acceptPaymentViewModel!.state) {
      case AcceptPaymentState.Finished:
      case AcceptPaymentState.Failure:
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pop(context, _acceptPaymentViewModel!.message);
        });
        break;
      default:
    }
  }
  Future<Uint8List> getSignatureData() async {
    SignatureState? sign = _sign.currentState;
    ByteData? data = (await (await sign!.getData()).toByteData(format: ImageByteFormat.png));

    return data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AcceptPaymentViewModel>(
      builder: (context, vm, _) {
        return Material(
          type: MaterialType.transparency,
          color: Colors.black54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildProgressPart(context)..addAll(_buildInfoPart(context))
          )
        );
      },
    );
  }

  List<Widget> _buildProgressPart(BuildContext context) {
    AcceptPaymentViewModel vm = Provider.of<AcceptPaymentViewModel>(context);

    return [
      CircularProgressIndicator(
        backgroundColor: Colors.white70,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      ),
      Container(height: 40),
      Text(vm.message, style: TextStyle(fontSize: 18, color: Colors.white70), textAlign: TextAlign.center),
      Container(height: 40),
      Container(
        height: 32,
        child: vm.isCancelable ? ElevatedButton(
          child: Text('Отмена', style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            primary: Colors.white
          ),
          onPressed: vm.cancelPayment
        ) : Container()
      ),
      Container(height: 40)
    ];
  }

  List<Widget> _buildInfoPart(BuildContext context) {
    AcceptPaymentViewModel vm = Provider.of<AcceptPaymentViewModel>(context);

    if (!vm.requiredSignature)
      return [Container(height: 272)];

    return [
      Container(
        height: 200,
        width: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
          border: Border.all(color: Colors.grey),
          color: Colors.white
        ),
        child: Signature(key: _sign, strokeWidth: 5)
      ),
      Container(height: 40),
      Container(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                primary: Colors.white
              ),
              child: Text('Очистить', style: TextStyle(color: Colors.black)),
              onPressed: () => _sign.currentState!.clear()
            ),
            Container(width: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                primary: Colors.white
              ),
              child: Text('Подтвердить', style: TextStyle(color: Colors.black)),
              onPressed: () async => vm.adjustPayment(await getSignatureData())
            )
          ]
        )
      )
    ];
  }
}
