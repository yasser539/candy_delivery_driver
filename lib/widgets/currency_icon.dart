import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurrencyIcon extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;

  const CurrencyIcon({super.key, this.width, this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icon/rsak.svg',
      width: width ?? 16,
      height: height ?? 16,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
