import 'package:maliye_app/config/icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MyCachedNetworkImage extends StatelessWidget {
  final String imageurl;
  const MyCachedNetworkImage({Key key, this.imageurl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageurl,
      placeholder: (_, __) => SvgIcons.placeholder,
      errorWidget: (_, error, __) => SvgIcons.placeholder,
      fit: BoxFit.cover,
    );
  }
}
