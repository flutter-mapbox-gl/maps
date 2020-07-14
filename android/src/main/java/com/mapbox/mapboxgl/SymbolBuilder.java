// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import com.mapbox.geojson.Point;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.plugins.annotation.Symbol;
import com.mapbox.mapboxsdk.plugins.annotation.SymbolManager;
import com.mapbox.mapboxsdk.plugins.annotation.SymbolOptions;

class SymbolBuilder implements SymbolOptionsSink {
  private final SymbolOptions symbolOptions;
  private static boolean customImage;

  SymbolBuilder() {
    this.symbolOptions = new SymbolOptions();
  }

  public SymbolOptions getSymbolOptions(){
    return this.symbolOptions;
  }

  @Override
  public void setIconSize(float iconSize) {
    symbolOptions.withIconSize(iconSize);
  }

  @Override
  public void setIconImage(String iconImage) {
    symbolOptions.withIconImage(iconImage);
  }

  @Override
  public void setIconRotate(float iconRotate) {
    symbolOptions.withIconRotate(iconRotate);
  }

  @Override
  public void setIconOffset(float[] iconOffset) {
    symbolOptions.withIconOffset(new Float[] {iconOffset[0], iconOffset[1]});
  }

  @Override
  public void setIconAnchor(String iconAnchor) {
    symbolOptions.withIconAnchor(iconAnchor);
  }

  @Override
  public void setFontNames(String[] fontNames) { symbolOptions.withTextFont(fontNames); }

  @Override
  public void setTextField(String textField) {
    symbolOptions.withTextField(textField);
  }

  @Override
  public void setTextSize(float textSize) {
    symbolOptions.withTextSize(textSize);
  }

  @Override
  public void setTextMaxWidth(float textMaxWidth) {
    symbolOptions.withTextMaxWidth(textMaxWidth);
  }

  @Override
  public void setTextLetterSpacing(float textLetterSpacing) {
    symbolOptions.withTextLetterSpacing(textLetterSpacing);
  }

  @Override
  public void setTextJustify(String textJustify) {
    symbolOptions.withTextJustify(textJustify);
  }

  @Override
  public void setTextAnchor(String textAnchor) {
    symbolOptions.withTextAnchor(textAnchor);
  }

  @Override
  public void setTextRotate(float textRotate) {
    symbolOptions.withTextRotate(textRotate);
  }

  @Override
  public void setTextTransform(String textTransform) {
    symbolOptions.withTextTransform(textTransform);
  }

  @Override
  public void setTextOffset(float[] textOffset) {
    symbolOptions.withTextOffset(new Float[] {textOffset[0], textOffset[1]});
  }

  @Override
  public void setIconOpacity(float iconOpacity) {
    symbolOptions.withIconOpacity(iconOpacity);
  }

  @Override
  public void setIconColor(String iconColor) {
    symbolOptions.withIconColor(iconColor);
  }

  @Override
  public void setIconHaloColor(String iconHaloColor) {
    symbolOptions.withIconHaloColor(iconHaloColor);
  }

  @Override
  public void setIconHaloWidth(float iconHaloWidth) {
    symbolOptions.withIconHaloWidth(iconHaloWidth);
  }

  @Override
  public void setIconHaloBlur(float iconHaloBlur) {
    symbolOptions.withIconHaloBlur(iconHaloBlur);
  }

  @Override
  public void setTextOpacity(float textOpacity) {
    symbolOptions.withTextOpacity(textOpacity);
  }

  @Override
  public void setTextColor(String textColor) {
    symbolOptions.withTextColor(textColor);
  }

  @Override
  public void setTextHaloColor(String textHaloColor) {
    symbolOptions.withTextHaloColor(textHaloColor);
  }

  @Override
  public void setTextHaloWidth(float textHaloWidth) {
    symbolOptions.withTextHaloWidth(textHaloWidth);
  }

  @Override
  public void setTextHaloBlur(float textHaloBlur) {
    symbolOptions.withTextHaloBlur(textHaloBlur);
  }

  @Override
  public void setGeometry(LatLng geometry) {
    symbolOptions.withGeometry(Point.fromLngLat(geometry.getLongitude(), geometry.getLatitude()));
  }

  @Override
  public void setSymbolSortKey(float symbolSortKey) {
    symbolOptions.withSymbolSortKey(symbolSortKey);
  }

  @Override
  public void setDraggable(boolean draggable) {
    symbolOptions.withDraggable(draggable);
  }

  public boolean getCustomImage() { 
    return this.customImage;
  }
}