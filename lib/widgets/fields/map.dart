import 'dart:async';
import 'dart:math';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../middleware/device.dart';
import 'text.dart';

class MapFieldValue {
  double latitude;
  double longitude;
  double radius;
  double zoom;

  MapFieldValue({this.latitude, this.longitude, this.radius, this.zoom});

  Map toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'zoom': zoom,
    };
  }
}

class MapField extends FieldWidget<MapFieldValue> {
  final double height;
  final String marketImageAsset;
  final Future<MapFieldValue> Function(String text) onLookup;
  final String apiKey;
  final double radius;
  final double zoom;
  final String initialQuery;
  final String queryLanguage;

  MapField({
    @required Scope scope,
    Key key,
    @required String name,
    String group,
    String label,
    IconData icon,
    EdgeInsets margin,
    EdgeInsets padding,
    bool readonly,
    bool visible,
    ValueChanged<MapFieldValue> onSubmitted,
    ValueChanged<MapFieldValue> onValidSubmit,
    ValueChanged<MapFieldValue> onChanged,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    FormFieldValidator<String> validator,
    MapFieldValue Function(dynamic value) parser,
    bool focusNext,
    MapFieldValue Function() fetcher,
    this.onLookup,
    this.height,
    this.marketImageAsset,
    this.apiKey,
    this.radius,
    this.zoom,
    this.initialQuery,
    this.queryLanguage,
    Function(MapFieldValue value) applier,
    FieldWidgetTheme theme,
  })  : assert(name != null),
        super(
          scope: scope,
          key: key,
          name: name,
          group: group,
          label: label,
          icon: icon,
          margin: margin,
          padding: padding,
          readonly: readonly,
          visible: visible,
          onSubmitted: onSubmitted,
          onValidSubmit: onValidSubmit,
          onChanged: onChanged,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          validator: validator,
          parser: parser,
          focusNext: focusNext,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
        );

  @override
  _MapFieldState createState() => _MapFieldState();
}

class _MapFieldState extends Field<MapFieldValue, MapField> {
  GoogleMapController _controller;
  LatLng _location;
  BitmapDescriptor _poiner;
  Set<Marker> _markers;
  Set<Circle> _circles;
  GoogleGeocodingApi _api;
  MarkerId _mainMarkerId;
  CircleId _mainCircleId;
  double _radius;
  double _zoom;

  @override
  void init() {
    _radius = widget.radius;
    _api = GoogleGeocodingApi(widget.apiKey, isLogged: false);
    _markers = <Marker>{};
    _circles = <Circle>{};
    _mainMarkerId = MarkerId('main');
    _mainCircleId = CircleId('main');

    _sync();
  }

  @override
  dynamic data() => value;

  @override
  Future<MapFieldValue> lookup() async {
    final String text = await widget.scope.dialogs
        .prompt(
          'Búsqueda\nPersonalizada',
          hint: '',
          label: 'Dirección',
          type: TextInputFieldType.text,
          acceptLabel: 'Buscar',
          width: Device.isWeb == true ? 500 : null,
          icon: Icons.search,
        )
        .show();

    if (text?.isNotEmpty == true) {
      if (widget.onLookup != null) {
        return await widget.onLookup(text);
      } else {
        busy = true;
        final searchResults = await _api.search(text, language: 'es');
        if (searchResults.results.isNotEmpty) {
          rasterize(() {
            busy = false;
            _location = LatLng(searchResults.results.first.geometry.location.lat, searchResults.results.first.geometry.location.lng);
            _updateMarker();
          });
        }
      }
    }

    return value;
  }

  @override
  String label() => widget.label;

  @override
  Widget display([String text]) {
    if (widget.radius != _radius) {
      _radius = widget.radius;
      _updateCircle(calculateZoom: true);
    }

    Widget mapContainer = Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.scope.application.settings.dialogs.dialogRadius + 2),
        border: Border.all(
          color: widget.scope.application.settings.fields.focusColor ?? Colors.black12,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.scope.application.settings.dialogs.dialogRadius),
        child: _location == null
            ? Container()
            : GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  zoom: _zoom ?? widget.zoom ?? 1,
                  target: _location,
                ),
                compassEnabled: false,
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                mapToolbarEnabled: true,
                myLocationButtonEnabled: false,
                tiltGesturesEnabled: false,
                trafficEnabled: false,
                buildingsEnabled: false,
                indoorViewEnabled: false,
                circles: _circles,
                markers: _markers,
                rotateGesturesEnabled: false,
                myLocationEnabled: false,
                onCameraMove: (position) {
                  _controller.getZoomLevel().then((value) {
                    _update(zoom: value);
                  });
                },
                onTap: (location) {
                  _location = location;
                  _updateMarker();
                },
                onMapCreated: (GoogleMapController controller) {
                  BitmapDescriptor.fromAssetImage(
                    createLocalImageConfiguration(context, size: Size.square(48)),
                    widget.marketImageAsset,
                  ).then((BitmapDescriptor bitmap) {
                    rasterize(() {
                      _poiner = bitmap;
                      _updateMarker();
                    });
                  });
                  _controller = controller;
                },
              ),
      ),
    );

    return Container(
      child: Container(
        padding: EdgeInsets.only(bottom: 10, top: 6),
        child: widget.height == null ? AspectRatio(aspectRatio: 1, child: mapContainer) : SizedBox(height: widget.height, child: mapContainer),
      ),
    );
  }

  Future _sync() async {
    if (value != null && value.latitude != null && value.longitude != null) {
      _zoom = value.zoom;
      _radius = value.radius;
      _location = LatLng(value.latitude, value.longitude);
      _updateMarker();
    } else {
      busy = true;
      try {
        final value = await _api.search(widget.initialQuery ?? 'Oceano Atlántico', language: widget.queryLanguage ?? 'es');
        _location = LatLng(value.results.first.geometry.location.lat, value.results.first.geometry.location.lng);
        _zoom = 13;
        _updateMarker();
        rasterize(() {
          busy = false;
        });
      } catch (err) {
        //ignore
      } finally {
        rasterize(() {
          busy = false;
        });
      }
    }
  }

  void _updateMarker() {
    if (_poiner == null) {
      return;
    }
    _markers = {};
    rasterize();

    Future.delayed(Duration(milliseconds: 0)).then((value) {
      _markers = {
        Marker(
          markerId: _mainMarkerId,
          position: _location,
          draggable: true,
          icon: _poiner,
          onDragEnd: (location) {
            _location = location;
            _updateMarker();
          },
        )
      };
      rasterize();
    });

    _updateCircle();
  }

  @override
  void fetch() {
    super.fetch();
    _sync();
  }

  void _updateCircle({bool calculateZoom}) async {
    if (_radius != null && _radius > 0) {
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        _circles = {
          Circle(
            circleId: _mainCircleId,
            center: _location,
            radius: _radius,
            strokeWidth: 0,
            fillColor: widget.scope.application.settings.colors.navigation.withOpacity(0.3),
          )
        };
        rasterize();
      });
    }

    if (calculateZoom == true) {
      _zoom = ((15 - log(_radius / 400) / log(2)));
    }

    if (_controller != null) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: _location, zoom: _zoom ?? 1)),
      );
    }
  }

  void _update({double zoom, double radius}) {
    var $update = false;

    if (zoom != null && zoom != _zoom) {
      _zoom = zoom;
      $update = true;
    }

    if (radius != null && radius != _radius) {
      _radius = radius;
      $update = true;
    }

    if (value == null) {
      return;
    }

    if (value.latitude != _location.latitude || value.longitude != _location.longitude) {
      $update = true;
    }

    if ($update) {
      submit(MapFieldValue(
        latitude: _location.latitude,
        longitude: _location.longitude,
        zoom: _zoom,
        radius: _radius,
      ));
    }
  }

  @override
  void clear() {
    super.clear();

    Future.delayed(Duration(milliseconds: 0)).then((value) {
      _zoom = 1;
      _radius = null;
      _sync();
    });
  }
}
