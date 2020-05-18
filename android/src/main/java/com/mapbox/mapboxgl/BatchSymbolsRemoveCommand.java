package com.mapbox.mapboxgl;

import com.mapbox.mapboxsdk.plugins.annotation.Symbol;
import com.mapbox.mapboxsdk.plugins.annotation.SymbolManager;
import com.mapbox.mapboxsdk.plugins.annotation.SymbolOptions;

import java.util.ArrayList;
import java.util.List;

class BatchSymbolsRemoveCommand {

    private final List<Symbol> symbolList;

    BatchSymbolsRemoveCommand() {
        symbolList = new ArrayList<Symbol>();
    }

    /**
     * Add symbol to delete
     * @param symbol
     */
    void add(Symbol symbol) {
        symbolList.add(symbol);
    }

    /**
     * Return ids of deleted symbols
     * @param symbolManager
     * @return List<String> symbols ids
     */
    void delete(SymbolManager symbolManager) {
        symbolManager.delete(symbolList);
        symbolList.clear();
    }
}
