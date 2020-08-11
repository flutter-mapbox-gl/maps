part of mapbox_gl_platform_interface;

class MapboxConstants {
  /**
   * The name of the desired preferences file for Android's SharedPreferences.
   */
  static final String MAPBOX_SHARED_PREFERENCES = "MapboxSharedPreferences";

  /**
   * Key used to switch storage to external in AndroidManifest.xml
   */
  static final String KEY_META_DATA_SET_STORAGE_EXTERNAL = "com.mapbox.SetStorageExternal";

  /**
   * Default value for KEY_META_DATA_SET_STORAGE_EXTERNAL (default is internal storage)
   */
  static final bool DEFAULT_SET_STORAGE_EXTERNAL = false;

  /**
   * Key used to switch Tile Download Measuring on/off in AndroidManifest.xml
   */
  static final String KEY_META_DATA_MEASURE_TILE_DOWNLOAD_ON = "com.mapbox.MeasureTileDownloadOn";

  /**
   * Default value for KEY_META_DATA_MEASURE_TILE_DOWNLOAD_ON (default is off)
   */
  static final bool DEFAULT_MEASURE_TILE_DOWNLOAD_ON = false;

  static final String KEY_PREFERENCE_SKU_TOKEN = "com.mapbox.mapboxsdk.accounts.skutoken";

  static final String KEY_META_DATA_MANAGE_SKU_TOKEN = "com.mapbox.ManageSkuToken";

  static final bool DEFAULT_MANAGE_SKU_TOKEN = true;

  /**
   * Default value for font fallback for local ideograph fonts
   */
  static final String DEFAULT_FONT = "sans-serif";

  /**
   * Unmeasured state
   */
  static final double UNMEASURED = -1;

  /**
   * Default animation time
   */
  static final int ANIMATION_DURATION = 300;

  /**
   * Default short animation time
   */
  static final int ANIMATION_DURATION_SHORT = 150;

  /**
   * Animation time of a fling gesture
   */
  static final int ANIMATION_DURATION_FLING_BASE = ANIMATION_DURATION_SHORT;

  /**
   * Velocity threshold for a fling gesture
   */
  static final int VELOCITY_THRESHOLD_IGNORE_FLING = 1000;

  /**
   * Vertical angle threshold for a horizontal disabled fling gesture
   */
  static final int ANGLE_THRESHOLD_IGNORE_VERTICAL_FLING = 75;

  /**
   * Maximum absolute zoom change for multi-pointer scale velocity animation
   */
  static final double MAX_ABSOLUTE_SCALE_VELOCITY_CHANGE = 2.5;

  /**
   * Maximum possible zoom change during the quick zoom gesture executed across the whole screen
   */
  static final double QUICK_ZOOM_MAX_ZOOM_CHANGE = 4.0;

  /**
   * Scale velocity animation duration multiplier.
   */
  static final double SCALE_VELOCITY_ANIMATION_DURATION_MULTIPLIER = 150;

  /**
   * Last scale span delta to XY velocity ratio required to execute scale velocity animation.
   */
  static final double SCALE_VELOCITY_RATIO_THRESHOLD = 4 * 1e-3;

  /**
   * Last rotation delta to XY velocity ratio required to execute rotation velocity animation.
   */
  static final double ROTATE_VELOCITY_RATIO_THRESHOLD = 2.2 * 1e-4;

  /**
   * Time within which user needs to lift fingers for velocity animation to start.
   */
  static final int SCHEDULED_ANIMATION_TIMEOUT = 150;

  /**
   * Maximum angular velocity for rotation animation
   */
  static final double MAXIMUM_ANGULAR_VELOCITY = 30;

  /**
   * Factor to calculate tilt change based on pixel change during shove gesture.
   */
  static final double SHOVE_PIXEL_CHANGE_FACTOR = 0.1;

  /**
   * The currently supported minimum zoom level.
   */
  static final double MINIMUM_ZOOM = 0.0;

  /**
   * The currently supported maximum zoom level.
   */
  static final double MAXIMUM_ZOOM = 25.5;

  /**
   * The currently supported minimum pitch level.
   */
  static final double MINIMUM_PITCH = 0.0;

  /**
   * The currently supported maximum pitch level.
   */
  static final double MAXIMUM_PITCH = 60.0;

  /**
   * The currently supported maximum tilt value.
   */
  static final double MAXIMUM_TILT = 60;

  /**
   * The currently supported minimum tilt value.
   */
  static final double MINIMUM_TILT = 0;

  /**
   * The currently supported maximum direction
   */
  static final double MAXIMUM_DIRECTION = 360;

  /**
   * The currently supported minimum direction
   */
  static final double MINIMUM_DIRECTION = 0;

  /**
   * Zoom value multiplier for scale gestures.
   */
  static final double ZOOM_RATE = 0.65;

  /**
   * Fragment Argument Key for MapboxMapOptions
   */
  static final String FRAG_ARG_MAPBOXMAPOPTIONS = "MapboxMapOptions";

  /**
   * Layer Id of annotations layer
   */
  static final String LAYER_ID_ANNOTATIONS = "com.mapbox.annotations.points";

  // Save instance state keys
  static final String STATE_HAS_SAVED_STATE = "mapbox_savedState";
  static final String STATE_CAMERA_POSITION = "mapbox_cameraPosition";
  static final String STATE_ZOOM_ENABLED = "mapbox_zoomEnabled";
  static final String STATE_SCROLL_ENABLED = "mapbox_scrollEnabled";
  static final String STATE_HORIZONAL_SCROLL_ENABLED = "mapbox_horizontalScrollEnabled";
  static final String STATE_ROTATE_ENABLED = "mapbox_rotateEnabled";
  static final String STATE_TILT_ENABLED = "mapbox_tiltEnabled";
  static final String STATE_DOUBLE_TAP_ENABLED = "mapbox_doubleTapEnabled";
  static final String STATE_QUICK_ZOOM_ENABLED = "mapbox_quickZoom";
  static final String STATE_ZOOM_RATE = "mapbox_zoomRate";
  static final String STATE_DEBUG_ACTIVE = "mapbox_debugActive";
  static final String STATE_COMPASS_ENABLED = "mapbox_compassEnabled";
  static final String STATE_COMPASS_GRAVITY = "mapbox_compassGravity";
  static final String STATE_COMPASS_MARGIN_LEFT = "mapbox_compassMarginLeft";
  static final String STATE_COMPASS_MARGIN_TOP = "mapbox_compassMarginTop";
  static final String STATE_COMPASS_MARGIN_RIGHT = "mapbox_compassMarginRight";
  static final String STATE_COMPASS_MARGIN_BOTTOM = "mapbox_compassMarginBottom";
  static final String STATE_COMPASS_FADE_WHEN_FACING_NORTH = "mapbox_compassFade";
  static final String STATE_COMPASS_IMAGE_BITMAP = "mapbox_compassImage";
  static final String STATE_LOGO_GRAVITY = "mapbox_logoGravity";
  static final String STATE_LOGO_MARGIN_LEFT = "mapbox_logoMarginLeft";
  static final String STATE_LOGO_MARGIN_TOP = "mapbox_logoMarginTop";
  static final String STATE_LOGO_MARGIN_RIGHT = "mapbox_logoMarginRight";
  static final String STATE_LOGO_MARGIN_BOTTOM = "mapbox_logoMarginBottom";
  static final String STATE_LOGO_ENABLED = "mapbox_logoEnabled";
  static final String STATE_ATTRIBUTION_GRAVITY = "mapbox_attrGravity";
  static final String STATE_ATTRIBUTION_MARGIN_LEFT = "mapbox_attrMarginLeft";
  static final String STATE_ATTRIBUTION_MARGIN_TOP = "mapbox_attrMarginTop";
  static final String STATE_ATTRIBUTION_MARGIN_RIGHT = "mapbox_attrMarginRight";
  static final String STATE_ATTRIBUTION_MARGIN_BOTTOM = "mapbox_atrrMarginBottom";
  static final String STATE_ATTRIBUTION_ENABLED = "mapbox_atrrEnabled";
  static final String STATE_DESELECT_MARKER_ON_TAP = "mapbox_deselectMarkerOnTap";
  static final String STATE_USER_FOCAL_POINT = "mapbox_userFocalPoint";
  static final String STATE_SCALE_ANIMATION_ENABLED = "mapbox_scaleAnimationEnabled";
  static final String STATE_ROTATE_ANIMATION_ENABLED = "mapbox_rotateAnimationEnabled";
  static final String STATE_FLING_ANIMATION_ENABLED = "mapbox_flingAnimationEnabled";
  static final String STATE_INCREASE_ROTATE_THRESHOLD = "mapbox_increaseRotateThreshold";
  static final String STATE_DISABLE_ROTATE_WHEN_SCALING = "mapbox_disableRotateWhenScaling";
  static final String STATE_INCREASE_SCALE_THRESHOLD = "mapbox_increaseScaleThreshold";
}