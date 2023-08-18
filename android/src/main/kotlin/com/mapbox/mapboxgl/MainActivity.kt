package com.mapbox.mapboxgl;


import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.Application
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.annotation.DrawableRes
import androidx.appcompat.content.res.AppCompatResources
import com.mapbox.maps.MapView
import com.mapbox.maps.OfflineManager
import com.mapbox.maps.Style
import com.mapbox.maps.MapInitOptions
import com.mapbox.maps.StylePackLoadOptions
import com.mapbox.maps.TilesetDescriptorOptions
import com.mapbox.maps.TilesetDescriptorOptionsForTilesets
import com.mapbox.common.TileDataDomain
import com.mapbox.common.TileRegionLoadOptions
import com.mapbox.common.TileStore
import com.mapbox.common.TileStoreOptions
import com.mapbox.common.TilesetDescriptor
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import com.mapbox.android.gestures.MoveGestureDetector
import com.mapbox.bindgen.Value
import com.mapbox.common.NetworkRestriction
import com.mapbox.common.TileDataDomain
import com.mapbox.common.TileRegionLoadOptions
import com.mapbox.common.TileStore
import com.mapbox.common.TileStoreOptions
import com.mapbox.common.TilesetDescriptor
import com.mapbox.geojson.Point
import com.mapbox.geojson.Polygon
import com.mapbox.maps.CameraOptions
import com.mapbox.maps.GlyphsRasterizationMode
import com.mapbox.maps.MapInitOptions
import com.mapbox.maps.MapView
import com.mapbox.maps.OfflineManager

import com.mapbox.maps.Style
import com.mapbox.maps.StylePackLoadOptions
import com.mapbox.maps.TilesetDescriptorOptions
import com.mapbox.maps.TilesetDescriptorOptionsForTilesets
import com.mapbox.maps.extension.style.expressions.dsl.generated.all
import com.mapbox.maps.extension.style.layers.generated.LineLayer
import com.mapbox.maps.extension.style.layers.generated.fillLayer
import com.mapbox.maps.extension.style.sources.generated.vectorSource
import com.mapbox.maps.extension.style.style
import com.mapbox.maps.plugin.annotation.annotations
import com.mapbox.maps.plugin.annotation.generated.PointAnnotationOptions
import com.mapbox.maps.plugin.annotation.generated.createPointAnnotationManager
import com.mapbox.maps.plugin.gestures.OnMoveListener
import com.mapbox.maps.plugin.gestures.gestures
import com.mapbox.maps.plugin.locationcomponent.OnIndicatorBearingChangedListener
import com.mapbox.maps.plugin.locationcomponent.OnIndicatorPositionChangedListener
import com.mapbox.maps.plugin.locationcomponent.location
import android.os.Handler
import android.os.Looper







class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        val channelName = "caching_plugin"
        val messenger: BinaryMessenger = flutterEngine.dartExecutor.binaryMessenger
//        private val mapBoxDownload = MapBoxDownload(application)
//        private val downloadTextChangeHandler: Handler =
//            Handler(Looper.getMainLooper())

        val channel = MethodChannel(messenger, channelName)
        channel.setMethodCallHandler { call, result ->
            if (call.method == "download_tileset") {
//                val networkOrFeederId = "mapbox.mapbox-traffic-v1"
//                mapBoxDownload.cacheMapLayer(networkOrFeederId) { progress ->
//                    downloadTextChangeHandler.postDelayed(
//                        Log.i("caching successfull"), 0
//                    )
//                }

                result.success("kkkkkkkkkkkkkkkkk library called")
            }
            else {
                result.notImplemented()
            }


        }
    }
}

//class MapBoxDownload(private val mContext: Application){
//    private val offlineManager:OfflineManager= OfflineManager(MapInitOptions.getDefaultResourceOptions(mContext))
//    private var tilesetDescriptorLines: TilesetDescriptor = offlineManager.createTilesetDescriptor(
//        TilesetDescriptorOptionsForTilesets.Builder()
//            .tilesets(getTileSetIds())
//            .minZoom(0)
//            .maxZoom(16)
//            .build()
//    )
//    private var tilesetDescriptorForStyle: TilesetDescriptor = offlineManager.createTilesetDescriptor(
//        TilesetDescriptorOptions.Builder()
//            .styleURI(Style.OUTDOORS)
//            .minZoom(0)
//            .maxZoom(16)
//            .build()
//    )
//    private val tileStore = TileStore.create().also {
//        it.setOption(
//            TileStoreOptions.MAPBOX_ACCESS_TOKEN,
//            TileDataDomain.MAPS,
//            Value(mContext.getString(R.string.mapbox_access_token))
//        )
//    }
//    private fun getTileSetIds() : List<String> {
//        val list = arrayListOf<String>()
//        list.add("mapbox://mapbox.mapbox-traffic-v1")
//        list.add("mapbox://mapbox.mapbox-terrain-v2")
//
//        return list
//    }
//    //    val StyleCheck : Unit = offlineManager.getAllStylePacks { expected ->
////        if (expected.isValue) {
////            expected.value?.let { stylePackList ->
////                Log.d("Existing style packs: $stylePackList")
////            }
////        }
////        expected.error?.let { stylePackError ->
////            Log.e("StylePackError: $stylePackError")
////        }
////    }
//    suspend fun cacheMapLayer(networkOrFeederId: String, taskCallBack :(Double?) -> Unit) {
//        taskCallBack(90)
////        val tileRegionLoadOptions = TileRegionLoadOptions.Builder()
////            .geometry(Point.fromLngLat(12.9716,77.5946))
////            .descriptors(listOf(tilesetDescriptorLines, tilesetDescriptorForStyle))
////            .acceptExpired(true)
////            .networkRestriction(NetworkRestriction.NONE)
////            .build()
////        val tileStyleLoadOptions = StylePackLoadOptions.Builder()
////            .glyphsRasterizationMode(GlyphsRasterizationMode.IDEOGRAPHS_RASTERIZED_LOCALLY)
////            .build()
////        val tileRegionId = networkOrFeederId
////        tileStore.loadTileRegion(
////            tileRegionId,
////            tileRegionLoadOptions,
////            { progress ->
////                taskCallBack((progress.completedResourceCount*100/progress.requiredResourceCount).toDouble())
////            }
////        ) { expected ->
////            if (expected.isValue) {
////                if(expected.value?.completedResourceCount == expected.value?.requiredResourceCount) {
////                    val stylePackCancelable = offlineManager.loadStylePack(
////                        Style.SATELLITE_STREETS,
////                        // Build Style pack load options
////                        tileStyleLoadOptions,
////                        { progress ->
////
////                        },
////                        { expected ->
////                            if (expected.isValue) {
////                                expected.value?.let { stylePack ->
////                                    if(stylePack.completedResourceCount == stylePack.requiredResourceCount) {
////                                        println("Map Downloaded SuccessFully")
////                                    }
////                                }
////                            }
////                            expected.error?.let {
////
////                                taskCallBack(null)
////                            }
////                        }
////                    )
////                }
////
////            }
////            expected.error?.let {
////                // Handle errors that occurred during the tile region download.
////
////                taskCallBack(null)
////            }
////        }
//    }
//
//
//}
//}