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
      'assets/icons/rsak.svg',
      width: width ?? 16,
      height: height ?? 16,
      // set color for older flutter_svg and colorFilter as fallback
      color: color,
      colorBlendMode: BlendMode.srcIn,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
