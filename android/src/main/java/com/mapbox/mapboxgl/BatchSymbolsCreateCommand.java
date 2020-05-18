package com.mapbox.mapboxgl;

import com.mapbox.mapboxsdk.plugins.annotation.Symbol;
import com.mapbox.mapboxsdk.plugins.annotation.SymbolManager;
import com.mapbox.mapboxsdk.plugins.annotation.SymbolOptions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;


class BatchSymbolsCreateCommand {

    private final List<SymbolOptions> symbolOptionsList;

    BatchSymbolsCreateCommand() {
        this.symbolOptionsList = new ArrayList<SymbolOptions>();
    }


    void addSymbolOptions(SymbolOptions options) {
        this.symbolOptionsList.add(options);
    }


    Map<String, SymbolController> create(SymbolManager symbolManager, OnSymbolTappedListener symbolTappedListener ) {
        Map<String, SymbolController> newSymbolControllers = new LinkedHashMap<String, SymbolController>();
        if (!symbolOptionsList.isEmpty()) {
            List<Symbol> newSymbols = symbolManager.create(symbolOptionsList);
            String symbolId;
            for (Symbol symbol : newSymbols) {
                symbolId = String.valueOf(symbol.getId());
                newSymbolControllers.put(symbolId, new SymbolController(symbol, true, symbolTappedListener));
            }
            this.symbolOptionsList.clear();
        }

        return newSymbolControllers;
    }
}
