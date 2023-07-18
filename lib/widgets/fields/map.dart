import 'dart:async';
import 'dart:math';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../middleware/device.dart';
import '../../middleware/utils.dart';
import 'text.dart';

class MapFieldValue {
  double radius;
  double zoom;
  Color color;
  LatLng location;

  MapFieldValue({double latitude, double longitude, this.radius, this.zoom, this.color}) {
    location = LatLng(latitude, longitude);
  }

  void setLocation(double latitude, double longitude) {
    location = LatLng(latitude, longitude);
  }

  Map toJson() {
    return {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'radius': radius,
      'zoom': zoom,
      'color': Utils.convert.fromColorToHex(color),
    };
  }
}

class MapFieldController {
  Function(String lookup) _query;
  Function() _refresh;
  bool _initialized;

  MapFieldController();

  void _init({Function(String lookup) query, Function() refresh}) {
    _query = query;
    _refresh = refresh;
    _initialized = true;
  }

  void query(String lookup) {
    _query?.call(lookup);
  }

  void refresh() {
    _refresh?.call();
  }
}

class MapField extends FieldWidget<MapFieldValue> {
  final double height;
  final String marketImageAsset;
  final Future<MapFieldValue> Function(String text) onLookup;
  final String apiKey;
  final String initialQuery;
  final String queryLanguage;
  final MapFieldController controller;

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
    ValueChanged<MapFieldValue> onApplied,
    ValueChanged<MapFieldValue> onChanged,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    FormFieldValidator<MapFieldValue> validator,
    MapFieldValue Function(dynamic value) parser,
    FieldFocusType focusType,
    Future<MapFieldValue> Function() fetcher,
    this.onLookup,
    this.height,
    this.marketImageAsset,
    this.apiKey,
    this.initialQuery,
    this.queryLanguage,
    this.controller,
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
          onApplied: onApplied,
          onChanged: onChanged,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          validator: validator,
          parser: parser,
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
        );

  @override
  _MapFieldState createState() => _MapFieldState();
}

class _MapFieldState extends Field<MapFieldValue, MapField> {
  GoogleMapController _controller;
  BitmapDescriptor _poiner;
  Set<Marker> _markers;
  Set<Circle> _circles;
  GoogleGeocodingApi _api;
  MarkerId _mainMarkerId;
  CircleId _mainCircleId;
  MapFieldValue _default;
  bool _fetchWhenControllerAvailable;
  int _tick;

  @override
  void init() {
    _tick = widget.scope.tick;
    _api = GoogleGeocodingApi(widget.apiKey, isLogged: false);
    _markers = <Marker>{};
    _circles = <Circle>{};
    _mainMarkerId = MarkerId('main');
    _mainCircleId = CircleId('main');

    if (widget.controller?._initialized != true) {
      widget.controller._init(query: (lookup) {
        if (lookup?.isNotEmpty == true) {
          setState(() {
            _api.search(lookup, language: 'es').then((searchResults) {
              if (searchResults.results.isNotEmpty) {
                rasterize(() {
                  busy = false;
                  _updateLocation(LatLng(searchResults.results.first.geometry.location.lat, searchResults.results.first.geometry.location.lng));
                });
              }
            });
          });
        }
      }, refresh: () {
        fetch();
      });
    }
  }

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
            _updateLocation(LatLng(searchResults.results.first.geometry.location.lat, searchResults.results.first.geometry.location.lng));
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
        child: (_fetchWhenControllerAvailable == null) || !(value?.location != null || _default?.location != null)
            ? Container(
                child: Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.scope.application.settings.colors.primary,
                    ),
                  ),
                ),
              )
            : GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  zoom: value?.zoom ?? 1,
                  target: value?.location ?? _default?.location,
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
                onCameraMove: (position) {},
                onCameraIdle: () async {
                  var mzoom = await _controller.getZoomLevel();
                  if (value != null && value?.zoom != mzoom) {
                    value.zoom = mzoom;
                    _renderMarker();
                  }
                },
                onTap: (location) {
                  _updateLocation(location);
                },
                onMapCreated: (GoogleMapController controller) async {
                  if (mounted != true) {
                    return;
                  }
                  final bitmap = await BitmapDescriptor.fromAssetImage(createLocalImageConfiguration(context, size: Size.square(48)), widget.marketImageAsset);
                  rasterize(() {
                    _poiner = bitmap;
                    _controller = controller;
                    if (_fetchWhenControllerAvailable == true) {
                      _fetchWhenControllerAvailable = false;
                      fetch();
                    }
                  });
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

  void _updateLocation(LatLng location) {
    if (location == null) {
      clear();
    } else {
      submit(MapFieldValue(
        latitude: location.latitude,
        longitude: location.longitude,
        zoom: value?.zoom,
        radius: value?.radius,
        color: value?.color,
      ));
    }
  }

  Future _renderMarker() async {
    LatLng location = value?.location ?? _default?.location;

    if (location == null) {
      if (_default == null) {
        final defaultLocation = await _api.search(widget.initialQuery ?? 'Oceano Atlántico', language: widget.queryLanguage ?? 'es');
        _default = MapFieldValue(
          latitude: defaultLocation.results.first.geometry.location.lat,
          longitude: defaultLocation.results.first.geometry.location.lng,
          zoom: 13,
          radius: 300,
          color: widget.scope.application.settings.colors.primary.withOpacity(0.3),
        );
        location = _default.location;
      }
    }

    if (_controller == null || _poiner == null) {
      return;
    }

    if (location?.latitude == null) {
      _circles = {};
      _markers = {};
    } else {
      _markers = {
        Marker(
          markerId: _mainMarkerId,
          position: location,
          draggable: true,
          icon: _poiner,
          onDragEnd: (location) {
            _updateLocation(location);
          },
        )
      };

      if (value?.radius != null && value.radius > 0) {
        _circles = {
          Circle(
            circleId: _mainCircleId,
            center: location,
            radius: value.radius,
            strokeWidth: 0,
            fillColor: value?.color ?? widget.scope.application.settings.colors.navigation.withOpacity(0.3),
          )
        };
      } else {
        _circles = {
          Circle(
            circleId: _mainCircleId,
            center: location,
            radius: 0,
            strokeWidth: 0,
            fillColor: Colors.transparent,
          )
        };
      }
    }

    _controller.moveCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: location, zoom: value?.zoom ?? _default?.zoom ?? 1)),
    );

    rasterize();
  }

  @override
  Future<MapFieldValue> fetch([apply = true]) async {
    var cvalue = await super.fetch(false);
    var calculateZoom = cvalue?.radius == null || cvalue.radius != value?.radius;
    if (_tick != widget.scope.tick) {
      calculateZoom = false;
      _tick = widget.scope.tick;
    }

    await super.fetch();

    if (calculateZoom == true && value?.radius != null && value.radius > 0) {
      value.zoom = ((15 - log(value.radius / 500) / log(2)));
    }

    if (_controller == null || _poiner == null) {
      _fetchWhenControllerAvailable = true;
    } else {
      _fetchWhenControllerAvailable = false;
      _renderMarker();
    }

    return value;
  }

  @override
  void present() {
    _renderMarker();
  }
}
