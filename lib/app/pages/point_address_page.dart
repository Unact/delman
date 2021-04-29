import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:delman/app/view_models/point_address_view_model.dart';

class PointAddressPage extends StatefulWidget {
  const PointAddressPage({Key key}) : super(key: key);

  @override
  _PointAddressPageState createState() => _PointAddressPageState();
}

class _PointAddressPageState extends State<PointAddressPage> {
  PointAddressViewModel _pointAddressViewModel;

  @override
  void initState() {
    super.initState();

    _pointAddressViewModel = context.read<PointAddressViewModel>();
    _pointAddressViewModel.addListener(this.vmListener);
  }

  @override
  void dispose() {
    _pointAddressViewModel.removeListener(this.vmListener);
    super.dispose();
  }

  void vmListener() {
    switch (_pointAddressViewModel.state) {
      case PointAddressState.Failure:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_pointAddressViewModel.message)));

        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PointAddressViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(vm.deliveryPoint.addressName)
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
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
