import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:anxeb_flutter/widgets/buttons/image.dart';
import 'package:flutter/material.dart';

class UserBlock extends StatelessWidget {
  final ImageProvider background;
  final Color color;
  final bool safeArea;
  final bool includeImageProfile;
  final EdgeInsets padding;
  final String imageUrl;
  final String authToken;
  final String userName;
  final String userTitle;
  final GestureTapCallback onTab;

  UserBlock({
    this.background,
    this.color,
    this.safeArea,
    this.includeImageProfile = true,
    this.padding,
    this.imageUrl,
    this.authToken,
    this.userName,
    this.userTitle,
    this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      decoration: background != null
          ? BoxDecoration(
              color: Colors.transparent,
              boxShadow: [BoxShadow(offset: Offset(0, 8), blurRadius: 8, spreadRadius: -5, color: Color(0x44000000))],
              image: DecorationImage(
                fit: BoxFit.cover,
                image: background,
              ),
            )
          : null,
      child: SafeArea(
        top: safeArea ?? false,
        bottom: false,
        child: Container(
          padding: padding ?? Utils.convert.fromInsetToFraction(EdgeInsets.only(left: 0.03, top: 0.03, bottom: 0.03), size),
          child: Row(
            children: <Widget>[
              Visibility(
                visible: includeImageProfile,
                child: Container(
                  child: ImageButton(
                    height: 90,
                    width: 90,
                    imageUrl: imageUrl,
                    innerPadding: EdgeInsets.all(5),
                    headers: authToken != null ? {'Authorization': 'Bearer ${this.authToken}'} : null,
                    outerBorderColor: color ?? Colors.white,
                    failedIcon: Icons.account_circle,
                    failedIconColor: color != null ? color.withAlpha(50) : null,
                    outerThickness: 3,
                    onTap: onTab,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(left: 8.0, right: 10.0, bottom: 6.0, top: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: color ?? Colors.white,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                userName,
                                overflow: TextOverflow.clip,
                                style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.w400, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 8.0, right: 10.0, bottom: 15.0, top: 7),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                userTitle.toUpperCase(),
                                overflow: TextOverflow.clip,
                                style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
