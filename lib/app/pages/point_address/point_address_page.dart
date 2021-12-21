import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/utils/geo_loc.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';

part 'point_address_state.dart';
part 'point_address_view_model.dart';

class PointAddressPage extends StatelessWidget {
  final DeliveryPoint deliveryPoint;

  PointAddressPage({
    Key? key,
    required this.deliveryPoint
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PointAddressViewModel>(
      create: (context) => PointAddressViewModel(context, deliveryPoint: deliveryPoint),
      child: _PointAddressView(),
    );
  }
}

class _PointAddressView extends StatefulWidget {
  @override
  _PointAddressViewState createState() => _PointAddressViewState();
}

class _PointAddressViewState extends State<_PointAddressView> {
  late YandexMapController _controller;

  final double _kImageFontSize = 30;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Color _deliveryPointColor(DeliveryPoint deliveryPoint) {
    PointAddressViewModel vm = context.read<PointAddressViewModel>();

    return deliveryPoint == vm.deliveryPoint ? Colors.red[700]! : Colors.blue[700]!;
  }

  MapObjectId _deliveryPointMapId(DeliveryPoint deliveryPoint) {
    return MapObjectId('delivery_point_${deliveryPoint.id}');
  }

  String _deliveryPointLabel(DeliveryPoint deliveryPoint) {
    PointAddressViewModel vm = context.read<PointAddressViewModel>();
    DateTime? timeFrom = vm.getPointTimeFrom(deliveryPoint);
    DateTime? timeTo = vm.getPointTimeTo(deliveryPoint);

    return '${deliveryPoint.seq}. ${Format.timeStr(timeFrom)} - ${Format.timeStr(timeTo)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PointAddressViewModel, PointAddressState>(
      builder: (context, state) {
        PointAddressViewModel vm = context.read<PointAddressViewModel>();

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
      },
      listener: (context, state) {
        if (state is PointAddressFailure) {
          showMessage(state.message);
        } else if (state is PointAddressSelectionChange) {
          _rebuildPlacemarks();
        }
      }
    );
  }

  Widget _buildMap() {
    PointAddressViewModel vm = context.read<PointAddressViewModel>();

    return YandexMap(
      onMapCreated: (YandexMapController controller) async {
        _controller = controller;
        await _rebuildPlacemarks();
        await _controller.move(cameraPosition: CameraPosition(
          target: Point(
            latitude: vm.deliveryPoint.latitude,
            longitude: vm.deliveryPoint.longitude
          ),
          zoom: 17.0
        ));
      }
    );
  }

  Widget _buildSelectionRow() {
    Size size = MediaQuery.of(context).size;
    PointAddressViewModel vm = context.read<PointAddressViewModel>();

    return Positioned(
      bottom: size.height/18,
      left: size.width/12,
      right: size.width/12,
      child: Container(
        width: size.width - size.width/12,
        padding: const EdgeInsets.only(left: 8),
        decoration: const BoxDecoration(
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
                vm.deliveryPoint.addressName,
                style: const TextStyle(fontWeight: FontWeight.bold)
              )
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.black, width: 2)),
                shape: BoxShape.rectangle,
              ),
              child: IconButton(
                icon: const Icon(Icons.drive_eta),
                onPressed: vm.routeTo,
                tooltip: 'Проложить маршрут',
              )
            ),
          ],
        )
      ),
    );
  }

  Future<void> _rebuildPlacemarks() async {
    PointAddressViewModel vm = context.read<PointAddressViewModel>();
    final futurePlacemarks = vm.deliveryPoints.map((deliveryPoint) async {
      return Placemark(
        mapId: _deliveryPointMapId(deliveryPoint),
        point: Point(latitude: deliveryPoint.latitude, longitude: deliveryPoint.longitude),
        zIndex: deliveryPoint == vm.deliveryPoint ? 1 : 0,
        style: PlacemarkStyle(
          opacity: 1,
          rawImageData: await _buildPlacemarkAppearance(deliveryPoint)
        ),
        onTap: (self, point) => vm.changeDeliveryPoint(deliveryPoint)
      );
    }).toList();
    final placemarks = await Future.wait(futurePlacemarks);

    await _controller.updateMapObjects([
      ClusterizedPlacemarkCollection(
        mapId: const MapObjectId('delivery_points_cluster'),
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
      const Radius.circular(10)
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
    const radius = 20.0;
    const size = Size(300, 200);

    return _buildImage(size, (canvas) {
      _drawPointCircle(size, canvas, radius, _deliveryPointColor(deliveryPoint));
      _drawTextRect(size, canvas, _deliveryPointLabel(deliveryPoint));
    });
  }

  Future<Uint8List> _buildClusterAppearance(Cluster cluster) async {
    PointAddressViewModel vm = context.read<PointAddressViewModel>();
    const radius = 50.0;
    final showTextRect = cluster.size <= 3;
    final size = showTextRect ? Size(300, 200.0 * cluster.size) : const Size(300, 200);
    final deliveryPointMapIds = cluster.placemarks.map((e) => e.mapId).toList();
    final deliveryPoints = vm.deliveryPoints.fold<List<DeliveryPoint>>([], (acc, e) {
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
