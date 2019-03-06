// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mapbox_gl;

class Symbol {
  @visibleForTesting
  Symbol(this._id, this._options);

  /// A unique identifier for this symbol.
  ///
  /// The identifier is an arbitrary unique string.
  final String _id;

  String get id => _id;

  SymbolOptions _options;

  /// The symbol configuration options most recently applied programmatically
  /// via the map controller.
  ///
  /// The returned value does not reflect any changes made to the symbol through
  /// touch events. Add listeners to the owning map controller to track those.
  SymbolOptions get options => _options;
}

dynamic _offsetToJson(Offset offset) {
  if (offset == null) {
    return null;
  }
  return <dynamic>[offset.dx, offset.dy];
}

/// Configuration options for [Symbol] instances.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class SymbolOptions {
  /// Creates a set of symbol configuration options.
  ///
  /// By default, every non-specified field is null, meaning no desire to change
  /// symbol defaults or current configuration.
  const SymbolOptions({
    this.iconSize,
    this.iconImage,
    this.iconRotate,
    this.iconOffset,
    this.iconAnchor,
    this.textField,
    this.textSize,
    this.textMaxWidth,
    this.textLetterSpacing,
    this.textJustify,
    this.textAnchor,
    this.textRotate,
    this.textTransform,
    this.textOffset,
    this.iconOpacity,
    this.iconColor,
    this.iconHaloColor,
    this.iconHaloWidth,
    this.iconHaloBlur,
    this.textOpacity,
    this.textColor,
    this.textHaloColor,
    this.textHaloWidth,
    this.textHaloBlur,
    this.geometry,
    this.zIndex,
    this.draggable,
  });

  final double iconSize;
  final String iconImage;
  final double iconRotate;
  final Offset iconOffset;
  final String iconAnchor;
  final String textField;
  final double textSize;
  final double textMaxWidth;
  final double textLetterSpacing;
  final String textJustify;
  final String textAnchor;
  final double textRotate;
  final String textTransform;
  final Offset textOffset;
  final double iconOpacity;
  final String iconColor;
  final String iconHaloColor;
  final double iconHaloWidth;
  final double iconHaloBlur;
  final double textOpacity;
  final String textColor;
  final String textHaloColor;
  final double textHaloWidth;
  final double textHaloBlur;
  final LatLng geometry;
  final int zIndex;
  final bool draggable;

  static const SymbolOptions defaultOptions = SymbolOptions(

  );

  SymbolOptions copyWith(SymbolOptions changes) {
    if (changes == null) {
      return this;
    }
    return SymbolOptions(
      iconSize: changes.iconSize ?? iconSize,
      iconImage: changes.iconImage ?? iconImage,
      iconRotate: changes.iconRotate ?? iconRotate,
      iconOffset: changes.iconOffset ?? iconOffset,
      iconAnchor: changes.iconAnchor ?? iconAnchor,
      textField: changes.textField ?? textField,
      textSize: changes.textSize ?? textSize,
      textMaxWidth: changes.textMaxWidth ?? textMaxWidth,
      textLetterSpacing: changes.textLetterSpacing ?? textLetterSpacing,
      textJustify: changes.textJustify ?? textJustify,
      textAnchor: changes.textAnchor ?? textAnchor,
      textRotate: changes.textRotate ?? textRotate,
      textTransform: changes.textTransform ?? textTransform,
      textOffset: changes.textOffset ?? textOffset,
      iconOpacity: changes.iconOpacity ?? iconOpacity,
      iconColor: changes.iconColor ?? iconColor,
      iconHaloColor: changes.iconHaloColor ?? iconHaloColor,
      iconHaloWidth: changes.iconHaloWidth ?? iconHaloWidth,
      iconHaloBlur: changes.iconHaloBlur ?? iconHaloBlur,
      textOpacity: changes.textOpacity ?? textOpacity,
      textColor: changes.textColor ?? textColor,
      textHaloColor: changes.textHaloColor ?? textHaloColor,
      textHaloWidth: changes.textHaloWidth ?? textHaloWidth,
      textHaloBlur: changes.textHaloBlur ?? textHaloBlur,
      geometry: changes.geometry ?? geometry,
      zIndex: changes.zIndex ?? zIndex,
      draggable: changes.draggable ?? draggable,
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('iconSize', iconSize);
    addIfPresent('iconImage', iconImage);
    addIfPresent('iconRotate', iconRotate);
    addIfPresent('iconOffset', _offsetToJson(iconOffset));
    addIfPresent('iconAnchor', iconAnchor);
    addIfPresent('textField', textField);
    addIfPresent('textSize', textSize);
    addIfPresent('textMaxWidth', textMaxWidth);
    addIfPresent('textLetterSpacing', textLetterSpacing);
    addIfPresent('textJustify', textJustify);
    addIfPresent('textAnchor', textAnchor);
    addIfPresent('textRotate', textRotate);
    addIfPresent('textTransform', textTransform);
    addIfPresent('textOffset', _offsetToJson(textOffset));
    addIfPresent('iconOpacity', iconOpacity);
    addIfPresent('iconColor', iconColor);
    addIfPresent('iconHaloColor', iconHaloColor);
    addIfPresent('iconHaloWidth', iconHaloWidth);
    addIfPresent('iconHaloBlur', iconHaloBlur);
    addIfPresent('textOpacity', textOpacity);
    addIfPresent('textColor', textColor);
    addIfPresent('textHaloColor', textHaloColor);
    addIfPresent('textHaloWidth', textHaloWidth);
    addIfPresent('textHaloBlur', textHaloBlur);
    addIfPresent('geometry', geometry?._toJson());
    addIfPresent('zIndex', zIndex);
    addIfPresent('draggable', draggable);
    return json;
  }

}