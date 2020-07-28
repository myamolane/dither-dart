/// Support for doing something awesome.
///
/// More dartdocs go here.
library dither_dart;

import 'package:image/image.dart';

import 'src/dither_dart_base.dart';

// https://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering
Image floydSteinberg(Image src, { int threshold = 127 }) {
  var height = src.height;
  var width = src.width;
  var factor = 1;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      var oldPixel = src.getPixel(x, y);
      var oldR = getRed(oldPixel);
      var oldG = getGreen(oldPixel);
      var oldB = getBlue(oldPixel);

      var newR = (factor * oldR / 255).round() * (255 / factor).round();
      var newG = (factor * oldG / 255).round() * (255 / factor).round();
      var newB = (factor * oldB / 255).round() * (255 / factor).round();
      src.setPixelSafe(x, y, getColor(newR, newG, newB));

      var errR = oldR - newR;
      var errG = oldG - newG;
      var errB = oldB - newB;
      var rightPixel = src.getPixelSafe(x + 1, y);
      var leftBottomPixel = src.getPixelSafe(x - 1, y + 1);
      var bottomPixel = src.getPixelSafe(x, y + 1);
      var rightBottomPixel = src.getPixelSafe(x + 1, y + 1);
      src.setPixelSafe(x + 1, y,
          quantise(rightPixel, err: 7, errB: errB, errG: errG, errR: errR));
      src.setPixelSafe(
          x - 1,
          y + 1,
          quantise(leftBottomPixel,
              err: 3, errB: errB, errG: errG, errR: errR));
      src.setPixelSafe(x, y + 1,
          quantise(bottomPixel, err: 5, errB: errB, errG: errG, errR: errR));
      src.setPixelSafe(
          x + 1,
          y + 1,
          quantise(rightBottomPixel,
              err: 1, errB: errB, errG: errG, errR: errR));
    }
  }
  return src;
}

// minimized average error dithering by Jarvis, Judice, and Ninke https://en.wikipedia.org/wiki/Error_diffusion#minimized_average_error
Image dither(Image src, { int threshold = 127 }) {
  var height = src.height;
  var width = src.width;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      var oldPixel = src.getPixel(x, y);
      var r = getRed(oldPixel);
      var newPixel = r > threshold ? 255 : 0;
      src.setPixelSafe(x, y, getColor(newPixel, newPixel, newPixel));
      var error = r - newPixel;

      src.setPixelSafe(x + 1, y,
          ditherColor(src.getPixelSafe(x + 1, y), (error * 7) / 48));
      src.setPixelSafe(x + 2, y,
          ditherColor(src.getPixelSafe(x + 2, y), (error * 5) / 48));

      src.setPixelSafe(x - 2, y + 1,
          ditherColor(src.getPixelSafe(x - 2, y + 1), (error * 3) / 48));
      src.setPixelSafe(x - 1, y + 1,
          ditherColor(src.getPixelSafe(x - 1, y + 1), (error * 5) / 48));
      src.setPixelSafe(x, y + 1,
          ditherColor(src.getPixelSafe(x, y + 1), (error * 7) / 48));
      src.setPixelSafe(x + 1, y + 1,
          ditherColor(src.getPixelSafe(x + 1, y + 1), (error * 5) / 48));
      src.setPixelSafe(x + 2, y + 1,
          ditherColor(src.getPixelSafe(x + 2, y + 1), (error * 3) / 48));

      src.setPixelSafe(x - 2, y + 2,
          ditherColor(src.getPixelSafe(x - 2, y + 2), (error * 1) / 48));
      src.setPixelSafe(x - 1, y + 2,
          ditherColor(src.getPixelSafe(x - 1, y + 2), (error * 2) / 48));
      src.setPixelSafe(x, y + 2,
          ditherColor(src.getPixelSafe(x, y + 2), (error * 4) / 48));
      src.setPixelSafe(x + 1, y + 2,
          ditherColor(src.getPixelSafe(x + 1, y + 2), (error * 2) / 48));
      src.setPixelSafe(x + 2, y + 2,
          ditherColor(src.getPixelSafe(x + 2, y + 2), (error * 1) / 48));
    }
  }
  return src;
}