import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/view_models/point_address_view_model.dart';

class PointAddressPage extends StatefulWidget {
  const PointAddressPage({Key? key}) : super(key: key);

  @override
  _PointAddressPageState createState() => _PointAddressPageState();
}

class _PointAddressPageState extends State<PointAddressPage> {
  late PointAddressViewModel _pointAddressViewModel;
  late YandexMapController _controller;

  double _kImageFontSize = 50;

  Color _deliveryPointColor(DeliveryPoint deliveryPoint) {
      if (deliveryPoint == _pointAddressViewModel.deliveryPoint) {
        return Colors.red[700]!;
      }

      if (deliveryPoint.isFinished) {
        return Colors.green[700]!;
      }

      if (deliveryPoint.inProgress) {
        return Colors.yellow[700]!;
      }

      return Colors.blue[700]!;
  }

  MapObjectId _deliveryPointMapId(DeliveryPoint deliveryPoint) {
    return MapObjectId('delivery_point_${deliveryPoint.id}');
  }

  String _deliveryPointLabel(DeliveryPoint deliveryPoint) {
    final planArrival = Format.hourStr(deliveryPoint.planArrival);
    final planDeparture = Format.hourStr(deliveryPoint.planDeparture);

    return '${deliveryPoint.seq}. $planArrival - $planDeparture';
  }

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
      case PointAddressState.SelectionChange:
        _rebuildPlacemarks();
        break;
      case PointAddressState.Failure:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_pointAddressViewModel.message!)));

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
            title: Text('Точка ${vm.deliveryPoint.seq}')
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Stack(
                  children: [
                    _buildMap(),
                    _buildSelectionRow()
                  ],
                )
              )
            ]
          )
        );
      }
    );
  }

  Widget _buildMap() {
    return YandexMap(
      onMapCreated: (YandexMapController controller) async {
        _controller = controller;
        await _rebuildPlacemarks();
        await _controller.move(cameraPosition: CameraPosition(
          target: Point(
            latitude: _pointAddressViewModel.deliveryPoint.latitude,
            longitude: _pointAddressViewModel.deliveryPoint.longitude
          ),
          zoom: 17.0
        ));
      }
    );
  }

  Widget _buildSelectionRow() {
    Size size = MediaQuery.of(context).size;

    return Positioned(
      bottom: size.height/18,
      left: size.width/12,
      right: size.width/12,
      child: Container(
        width: size.width - size.width/12,
        padding: EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black, blurRadius: 2, spreadRadius: -1, offset: Offset(0, 1)),
          ],
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                _pointAddressViewModel.deliveryPoint.addressName,
                style: TextStyle(fontWeight: FontWeight.bold)
              )
            ),
            Container(
              margin: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.black, width: 2)),
                shape: BoxShape.rectangle,
              ),
              child: IconButton(
                icon: Icon(Icons.drive_eta),
                onPressed: _pointAddressViewModel.routeTo,
                tooltip: 'Проложить маршрут',
              )
            ),
          ],
        )
      ),
    );
  }

  Future<void> _rebuildPlacemarks() async {
    final futurePlacemarks = _pointAddressViewModel.deliveryPoints.map((deliveryPoint) async {
      return Placemark(
        mapId: _deliveryPointMapId(deliveryPoint),
        point: Point(latitude: deliveryPoint.latitude, longitude: deliveryPoint.longitude),
        zIndex: deliveryPoint == _pointAddressViewModel.deliveryPoint ? 1 : 0,
        style: PlacemarkStyle(
          opacity: 1,
          rawImageData: await _buildPlacemarkAppearance(deliveryPoint)
        ),
        onTap: (self, point) => _pointAddressViewModel.changeDeliveryPoint(deliveryPoint)
      );
    }).toList();
    final placemarks = await Future.wait(futurePlacemarks);

    await _controller.updateMapObjects([
      ClusterizedPlacemarkCollection(
        mapId: MapObjectId('delivery_points_cluster'),
        placemarks: placemarks,
        radius: 20,
        minZoom: (await _controller.getMaxZoom()).toInt(),
        onClusterAdded: (self, cluster) async {
          return cluster.copyWith(
            appearance: cluster.appearance.copyWith(
              style: PlacemarkStyle(
                opacity: 1,
                rawImageData: await _buildClusterAppearance(cluster)
              )
            )
          );
        }
      )
    ]);
  }

  void _drawTextRect(Size size, Canvas canvas, String text) {
    final rrectPaint = Paint()
      ..color = Colors.white;
    final painter = TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black87, fontSize: _kImageFontSize, fontWeight: FontWeight.bold)
      ),
      textDirection: TextDirection.ltr
    );

    painter.layout(minWidth: 0, maxWidth: size.width);

    final textOffset = Offset((size.width - painter.width) / 2, painter.height);
    final rrectOffset = Offset(size.width / 2, painter.height + painter.height/2);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: rrectOffset, width: size.width - 10, height: painter.height),
      Radius.circular(10)
    );
    final rrectShadowPath = Path()
      ..addRRect(rrect);

    canvas.drawShadow(rrectShadowPath, Colors.black, 2, false);
    canvas.drawRRect(rrect, rrectPaint);

    painter.paint(canvas, textOffset);
  }

  void _drawTextCircle(Size size, Canvas canvas, String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.white, fontSize: _kImageFontSize, fontWeight: FontWeight.bold)
      ),
      textDirection: TextDirection.ltr
    );

    painter.layout(minWidth: 0, maxWidth: size.width);

    final textOffset = Offset((size.width - painter.width) / 2, (size.height - painter.height) / 2);

    painter.paint(canvas, textOffset);
  }

  void _drawPointCircle(Size size, Canvas canvas, double radius, Color color) {
    final circlePaint = Paint()
      ..color = color;

    final circleOffset = Offset(size.width / 2, size.height / 2);
    final circleShadowPath = Path()
      ..addOval(Rect.fromCircle(center: circleOffset, radius: radius));

    canvas.drawShadow(circleShadowPath, Colors.black, 2, false);
    canvas.drawCircle(circleOffset, radius, circlePaint);
  }

  void _drawClusterCircle(Size size, Canvas canvas, double radius, List<Color> colors) {
    final colorRatios = colors.groupFoldBy<Color, int>((element) => element, (previous, element) {
      return (previous ?? 0) + 1;
    });

    final circleOffset = Offset(size.width / 2, size.height / 2);
    final circleRect = Rect.fromCircle(center: circleOffset, radius: radius);
    final circleShadowPath = Path()
      ..addOval(circleRect);

    canvas.drawShadow(circleShadowPath, Colors.black, 2, false);

    var prev = 0.0;
    colorRatios.forEach((key, value) {
      final circlePaint = Paint()
        ..color = key;
      double radian = value * 2 * pi / colors.length;

      canvas.drawArc(circleRect, prev, radian, true, circlePaint);

      prev += radian;
    });
  }

  Future<Uint8List> _buildImage(Size size, Function(Canvas canvas) draw) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    draw.call(canvas);

    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }

  Future<Uint8List> _buildPlacemarkAppearance(DeliveryPoint deliveryPoint) async {
    final radius = 20.0;
    final size = Size(300, 300);

    return _buildImage(size, (canvas) {
      _drawPointCircle(size, canvas, radius, _deliveryPointColor(deliveryPoint));
      _drawTextRect(size, canvas, _deliveryPointLabel(deliveryPoint));
    });
  }

  Future<Uint8List> _buildClusterAppearance(Cluster cluster) async {
    final radius = 50.0;
    final showTextRect = cluster.size <= 3;
    final size = showTextRect ? Size(300, 300.0 * cluster.size) : Size(300, 300);
    final deliveryPointMapIds = cluster.placemarks.map((e) => e.mapId).toList();
    final deliveryPoints = _pointAddressViewModel.deliveryPoints.fold<List<DeliveryPoint>>([], (acc, e) {
      if (deliveryPointMapIds.contains(_deliveryPointMapId(e))) {
        acc.add(e);
      }

      return acc;
    });


    return _buildImage(size, (canvas) {
      _drawClusterCircle(size, canvas, radius, deliveryPoints.map((e) => _deliveryPointColor(e)).toList());
      _drawTextCircle(size, canvas, cluster.size.toString());

      if (showTextRect) {
        _drawTextRect(size, canvas, deliveryPoints.map((e) => _deliveryPointLabel(e)).join('\n'));
      }
    });
  }
}
