import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class ImagesConverter {
  static Image imageFromBase64String(String base64String,
      {int iTypeImage = 1}) {
    Image imgs = null;
    String defaultImage;

    defaultImage = 'assets/images/ptm.jpg';

    try {
      if (base64String != null) {
        base64String = base64String.trim();
        if (base64String.length > 0) {
          base64String =
              base64String.replaceAll('\n', '').replaceAll('\r', '').trim();
          imgs = Image.memory(
            base64Decode(base64String),
            fit: BoxFit.cover,
          );
        } else {
          imgs = Image.asset(
            defaultImage,
            width: 75,
            height: 75,
          );
        }
      } else {
        imgs = Image.asset(
          defaultImage,
          width: 75,
          height: 75,
        );
      }
    } catch (_) {
      imgs = Image.asset(
        defaultImage,
        width: 75,
        height: 75,
      );
    }

    return imgs;
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}
