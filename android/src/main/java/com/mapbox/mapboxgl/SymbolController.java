// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import android.graphics.Color;
import android.graphics.PointF;
import com.mapbox.geojson.Point;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.plugins.annotation.Symbol;
import com.mapbox.mapboxsdk.plugins.annotation.SymbolManager;

/**
 * Controller of a single Symbol on the map.
 */
class SymbolController implements SymbolOptionsSink {
  private final Symbol symbol;
  private final OnSymbolTappedListener onTappedListener;
  private boolean consumeTapEvents;

  SymbolController(Symbol symbol, boolean consumeTapEvents, OnSymbolTappedListener onTappedListener) {
    this.symbol = symbol;
    this.consumeTapEvents = consumeTapEvents;
    this.onTappedListener = onTappedListener;
  }

  boolean onTap() {
    if (onTappedListener != null) {
      onTappedListener.onSymbolTapped(symbol);
    }
    return consumeTapEvents;
  }

  public Symbol getSymbol(){
    return this.symbol;
  }

  void remove(SymbolManager symbolManager) {
    symbolManager.delete(symbol);
  }

  @Override
  public void setIconSize(float iconSize) {
    symbol.setIconSize(iconSize);
  }

  @Override
  public void setIconImage(String iconImage) {
    symbol.setIconImage(iconImage);
  }

  @Override
  public void setIconRotate(float iconRotate) {
    symbol.setIconRotate(iconRotate);
  }

  @Override
  public void setIconOffset(float[] iconOffset) {
    symbol.setIconOffset(new PointF(iconOffset[0], iconOffset[1]));
  }

  @Override
  public void setIconAnchor(String iconAnchor) {
    symbol.setIconAnchor(iconAnchor);
  }

  @Override
  public void setFontNames(String[] fontNames) { symbol.setTextFont(fontNames); }

  @Override
  public void setTextField(String textField) {
    symbol.setTextField(textField);
  }

  @Override
  public void setTextSize(float textSize) {
    symbol.setTextSize(textSize);
  }

  @Override
  public void setTextMaxWidth(float textMaxWidth) {
    symbol.setTextMaxWidth(textMaxWidth);
  }

  @Override
  public void setTextLetterSpacing(float textLetterSpacing) {
    symbol.setTextLetterSpacing(textLetterSpacing);
  }

  @Override
  public void setTextJustify(String textJustify) {
    symbol.setTextJustify(textJustify);
  }

  @Override
  public void setTextAnchor(String textAnchor) {
    symbol.setTextAnchor(textAnchor);
  }

  @Override
  public void setTextRotate(float textRotate) {
    symbol.setTextRotate(textRotate);
  }

  @Override
  public void setTextTransform(String textTransform) {
    symbol.setTextTransform(textTransform);
  }

  @Override
  public void setTextOffset(float[] textOffset) {
    symbol.setTextOffset(new PointF(textOffset[0], textOffset[1]));
  }

  @Override
  public void setIconOpacity(float iconOpacity) {
    symbol.setIconOpacity(iconOpacity);
  }

  @Override
  public void setIconColor(String iconColor) {
    symbol.setIconColor(Color.parseColor(iconColor));
  }

  @Override
  public void setIconHaloColor(String iconHaloColor) {
    symbol.setIconHaloColor(Color.parseColor(iconHaloColor));
  }

  @Override
  public void setIconHaloWidth(float iconHaloWidth) {
    symbol.setIconHaloWidth(iconHaloWidth);
  }

  @Override
  public void setIconHaloBlur(float iconHaloBlur) {
    symbol.setIconHaloBlur(iconHaloBlur);
  }

  @Override
  public void setTextOpacity(float textOpacity) {
    symbol.setTextOpacity(textOpacity);
  }

  @Override
  public void setTextColor(String textColor) {
    symbol.setTextColor(Color.parseColor(textColor));
  }

  @Override
  public void setTextHaloColor(String textHaloColor) {
    symbol.setTextHaloColor(Color.parseColor(textHaloColor));
  }

  @Override
  public void setTextHaloWidth(float textHaloWidth) {
    symbol.setTextHaloWidth(textHaloWidth);
  }

  @Override
  public void setTextHaloBlur(float textHaloBlur) {
    symbol.setTextHaloBlur(textHaloBlur);
  }

  @Override
  public void setSymbolSortKey(float symbolSortKey) {
    symbol.setSymbolSortKey(symbolSortKey);
  }

  @Override
  public void setGeometry(LatLng geometry) {
    symbol.setGeometry(Point.fromLngLat(geometry.getLongitude(), geometry.getLatitude()));
  }

  public LatLng getGeometry() {
    Point point =  symbol.getGeometry();
    return new LatLng(point.latitude(), point.longitude());
  }

  @Override
  public void setDraggable(boolean draggable) {
    symbol.setDraggable(draggable);
  }

  public void update(SymbolManager symbolManager) {
    symbolManager.update(symbol);
  }
}
