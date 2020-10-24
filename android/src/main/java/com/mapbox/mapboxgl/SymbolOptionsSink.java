// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import com.mapbox.mapboxsdk.geometry.LatLng;

/**
 * Receiver of Symbol configuration options.
 */
interface SymbolOptionsSink {

  void setIconSize(float iconSize);

  void setIconImage(String iconImage);

  void setIconRotate(float iconRotate);

  void setIconOffset(float[] iconOffset);

  void setIconAnchor(String iconAnchor);

  void setFontNames(String[] fontNames);

  void setTextField(String textField);

  void setTextSize(float textSize);

  void setTextMaxWidth(float textMaxWidth);

  void setTextLetterSpacing(float textLetterSpacing);

  void setTextJustify(String textJustify);

  void setTextAnchor(String textAnchor);

  void setTextRotate(float textRotate);

  void setTextTransform(String textTransform);

  void setTextOffset(float[] textOffset);

  void setIconOpacity(float iconOpacity);

  void setIconColor(String iconColor);

  void setIconHaloColor(String iconHaloColor);

  void setIconHaloWidth(float iconHaloWidth);

  void setIconHaloBlur(float iconHaloBlur);

  void setTextOpacity(float textOpacity);

  void setTextColor(String textColor);

  void setTextHaloColor(String textHaloColor);

  void setTextHaloWidth(float textHaloWidth);

  void setTextHaloBlur(float textHaloBlur);

  void setGeometry(LatLng geometry);

  void setSymbolSortKey(float symbolSortKey);

  void setDraggable(boolean draggable);

}
