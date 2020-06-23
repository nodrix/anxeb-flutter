import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:anxeb_flutter/widgets/buttons/image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserBlock extends StatelessWidget {
  final ImageProvider background;
  final String imageUrl;
  final String authToken;
  final String userName;
  final String userTitle;
  final GestureTapCallback onTab;

  UserBlock({
    this.background,
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
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [BoxShadow(offset: Offset(0, 8), blurRadius: 8, spreadRadius: -5, color: Color(0x44000000))],
        image: DecorationImage(
          fit: BoxFit.cover,
          image: background,
        ),
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          padding: Utils.convert.toFraction(EdgeInsets.only(left: 0.03, top: 0.03, bottom: 0.03), size),
          child: Row(
            children: <Widget>[
              ImageButton(
                width: 80,
                url: imageUrl,
                headers: authToken != null ? {'Authorization': 'Bearer ${this.authToken}'} : null,
                color: Colors.white,
                selected: true,
                onTap: onTab,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(left: 8.0, right: 10.0, bottom: 6.0, top: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              userName,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 8.0, right: 10.0, bottom: 15.0, top: 7),
                        child: Text(
                          userTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
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
