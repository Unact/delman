import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/view_models/delivery_point_view_model.dart';
import 'package:delman/app/widgets/widgets.dart';

class DeliveryPointPage extends StatefulWidget {
  const DeliveryPointPage({Key key}) : super(key: key);

  @override
  _DeliveryPointPageState createState() => _DeliveryPointPageState();
}

class _DeliveryPointPageState extends State<DeliveryPointPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DeliveryPointViewModel _deliveryPointViewModel;

  @override
  void initState() {
    super.initState();

    _deliveryPointViewModel = context.read<DeliveryPointViewModel>();
    _deliveryPointViewModel.addListener(this.vmListener);
  }

  @override
  void dispose() {
    _deliveryPointViewModel.removeListener(this.vmListener);
    super.dispose();
  }

  void vmListener() {
    switch (_deliveryPointViewModel.state) {
      case DeliveryPointState.Failure:
      case DeliveryPointState.ArrivalSaved:
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(_deliveryPointViewModel.message)));

        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Consumer<DeliveryPointViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Точка ${vm.deliveryPoint.seq}')
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 24, bottom: 24),
                  children: [
                    InfoRow(
                      title: Text(Strings.address),
                      trailing: ExpandingText(vm.deliveryPoint.addressName, style: TextStyle(color: Colors.black)),
                    ),
                    ListTile(
                      leading: Text(Strings.planArrival),
                      trailing: Text(Format.timeStr(vm.deliveryPoint.planArrival)),
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8)
                    ),
                    ListTile(
                      leading: Text(Strings.factArrival),
                      trailing: vm.deliveryPoint.inProgress ?
                        Text(Format.timeStr(vm.deliveryPoint.factArrival)) :
                        vm.state == DeliveryPointState.InProgress ?
                          SizedBox(child: CircularProgressIndicator()) :
                          RaisedButton(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                            color: Colors.blue,
                            child: Text('Отметить', style: TextStyle(color: Colors.white)),
                            onPressed: () => vm.arrive(),
                          ),
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8)
                    ),
                    ListTile(
                      leading: Text(Strings.factDeparture),
                      trailing: Text(Format.timeStr(vm.deliveryPoint.factDeparture)),
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8)
                    )
                  ]
                )
              ),
              Container(
                height: screenHeight/2,
                child: YandexMap(
                  onMapCreated: (YandexMapController controller) async {
                    await controller.addPlacemark(vm.placemark);
                    await controller.move(point: vm.placemark.point, zoom: 17.0);
                  }
                )
              )
            ]
          )
        );
      }
    );
  }
}
