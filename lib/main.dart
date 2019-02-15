import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Google Maps'),
        ),
        body: MapsSample(),
      ),
    );
  }
}

class MapsSample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MapsSampleState();
  }
}

class MapsSampleState extends State<MapsSample> {
  GoogleMapController mapController;

  Map<String, double> currentLocation = Map();
  StreamSubscription<Map<String, double>> locationSubscription;
  Location location = Location();
  String error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;

    initPlatformState();

    locationSubscription =
        location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        currentLocation = result;
      });
    });
  }

  void initPlatformState() async {
    Map<String, double> my_location;

    try {
      my_location = await location.getLocation();
      error = '';
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permiso denegado';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permiso ya fue denegado ir a configuraciones de la App!';
      }

      my_location = null;
    }

    setState(() {
      currentLocation = my_location;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: SizedBox(
              height: 200.0,
              width: 300.0,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                options: GoogleMapOptions(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('Dónde está Aguascalientes?'),
                onPressed: mapController == null
                    ? null
                    : () {
                        mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            const CameraPosition(
                              bearing: 0.0,
                              target: LatLng(21.885206, -102.291557),
                              tilt: 0.0,
                              zoom: 10.0,
                            ),
                          ),
                        );
                        mapController.addMarker(
                          MarkerOptions(
                            //icon: BitmapDescriptor.fromAsset(''), Poner un icon espeficifo
                            //alpha: 0.5,Opacidad del icon
                            //rotation: 45.0, rotacion del icon
                            position: LatLng(21.885206, -102.291557),
                            infoWindowText: InfoWindowText(
                                'Aqui esta Aguascalientes', 'Donde Vivo yo!'),
                          ),
                        );
                      },
              ),
              SizedBox(
                width: 10.0,
              ),
              RaisedButton(
                child: Text('Donde estoy?'),
                onPressed: _whereare,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  child: Text('Zoom In'),
                  onPressed: _zoomin,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: RaisedButton(
                  child: Text('Zoom Out'),
                  onPressed: _zoomout,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _whereare() {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
          LatLng(currentLocation['latitude'], currentLocation['longitude']),
          17.0),
    );
    mapController.addMarker(
      MarkerOptions(
        //icon: BitmapDescriptor.fromAsset(''), Poner un icon espeficifo
        //alpha: 0.5,Opacidad del icon
        //rotation: 45.0, rotacion del icon
        position:
            LatLng(currentLocation['latitude'], currentLocation['longitude']),
        infoWindowText:
            InfoWindowText('Aqui esta Aguascalientes', 'Donde Vivo yo!'),
      ),
    );
  }

  void _zoomin() {
    mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomout() {
    mapController.animateCamera(CameraUpdate.zoomOut());
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
