import 'package:flutter/cupertino.dart';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';

class SelectorBlock extends StatelessWidget {
  final Anxeb.Scope scope;
  final String name;
  final String reference;
  final bool selected;
  final String tail;
  final String logoUrl;
  final double width;
  final double height;
  final GestureTapCallback onTap;
  final bool flat;
  final Icon failedIcon;
  final EdgeInsets margin;
  final EdgeInsets padding;

  SelectorBlock({this.scope, this.name, this.reference, this.selected, this.tail, this.logoUrl, this.width, this.height, this.onTap, this.flat, this.failedIcon, this.margin, this.padding, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final captionWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(bottom: 3),
                margin: const EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.0,
                      color: scope.application.settings.colors.separator,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name ?? '',
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: selected == true ? scope.application.settings.colors.success : scope.application.settings.colors.primary,
                          height: 0.9,
                          fontSize: 19,
                          fontWeight: selected == true ? FontWeight.w500 : FontWeight.w300,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: selected == true,
                      child: Container(
                        child: Icon(
                          Icons.check_circle,
                          color: scope.application.settings.colors.success,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                reference?.toUpperCase() ?? '',
                style: TextStyle(
                  color: scope.application.settings.colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Text(
              tail ?? '',
              style: TextStyle(
                color: scope.application.settings.colors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ],
    );

    var onlyImage = name == null && reference == null;

    return Container(
      margin: margin,
      child: Anxeb.ImageButton(
        height: height ?? (width == null ? 50 : null),
        width: width ?? (height == null ? 80 : null),
        loadingColor: scope.application.settings.colors.primary.withOpacity(0.5),
        loadingPadding: const EdgeInsets.all(15),
        imageUrl: logoUrl != null ? (logoUrl.contains('http') ? logoUrl : scope.application.api.getUri('$logoUrl?webp=80&t=${scope.tick?.toString()}')) : null,
        failedIconColor: scope.application.settings.colors.primary.withOpacity(0.2),
        headers: {'Authorization': 'Bearer ${scope.application.api.token}'},
        outerRadius: 10,
        innerRadius: 5,
        innerPadding: flat == true ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        imagePadding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        outerFill: flat == true ? null : Colors.white,
        shadow: flat == true ? null : [BoxShadow(offset: Offset(0, 2), blurRadius: 2, spreadRadius: 0, color: Color(0x1f555555))],
        fit: BoxFit.contain,
        shape: BoxShape.rectangle,
        onTap: onTap,
        horizontal: onlyImage == true ? false : true,
        expanded: true,
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        failedBody: onlyImage == true
            ? null
            : Row(
                children: <Widget>[
                  Container(
                    width: width ?? 65,
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: failedIcon ?? const Icon(Anxeb.FlutterIcons.building_faw5s, size: 40),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            width: 1.0,
                            color: scope.application.settings.colors.separator,
                          ),
                        ),
                      ),
                      child: captionWidget,
                    ),
                  ),
                ],
              ),
        body: onlyImage == true
            ? Container()
            : Container(
                padding: padding ?? const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      width: 1.0,
                      color: scope.application.settings.colors.separator,
                    ),
                  ),
                ),
                child: captionWidget,
              ),
      ),
    );
  }
}
