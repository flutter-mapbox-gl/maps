part of mapbox_gl_platform_interface;

/// This file wrapps AndroidViewController classes in order to delay disposal process.
/// It is an workaround for flutter 3, where resourses get disposed quicker than before, while Mapbox behaves badly
/// and tries to access those resources after they had been disposed, resulting in a native crash.

class WrappedPlatformViewsService {
  static AndroidViewController initAndroidView({
    required int id,
    required String viewType,
    required TextDirection layoutDirection,
    dynamic creationParams,
    MessageCodec<dynamic>? creationParamsCodec,
    VoidCallback? onFocus,
  }) {
    final view = PlatformViewsService.initAndroidView(
      id: id,
      viewType: viewType,
      layoutDirection: layoutDirection,
      creationParams: creationParams,
      creationParamsCodec: creationParamsCodec,
      onFocus: onFocus,
    );
    return TextureAndroidViewControllerWrapper(
        view as TextureAndroidViewController);
  }
}

class TextureAndroidViewControllerWrapper
    implements TextureAndroidViewController {
  TextureAndroidViewControllerWrapper(this._controller);

  final TextureAndroidViewController _controller;

  @override
  PointTransformer get pointTransformer => _controller.pointTransformer;
  set pointTransformer(PointTransformer transformer) =>
      _controller.pointTransformer = transformer;

  @override
  void addOnPlatformViewCreatedListener(PlatformViewCreatedCallback listener) =>
      _controller.addOnPlatformViewCreatedListener(listener);

  @override
  bool get awaitingCreation => _controller.awaitingCreation;

  @override
  Future<void> clearFocus() => _controller.clearFocus();

  @override
  Future<void> create({Size? size}) => _controller.create(size: size);

  @override
  // ignore: invalid_use_of_visible_for_testing_member
  List<PlatformViewCreatedCallback> get createdCallbacks =>
      _controller.createdCallbacks;

  @override
  Future<void> dispatchPointerEvent(PointerEvent event) =>
      _controller.dispatchPointerEvent(event);

  @override
  //! workaround for flutter 3.0
  Future<void> dispose() {
    //? instead of this
    // _controller.dispose();
    //? we do this
    unawaited(Future.delayed(Duration(seconds: 5), _controller.dispose));
    return Future(() {});
  }

  @override
  bool get isCreated => _controller.isCreated;

  @override
  void removeOnPlatformViewCreatedListener(
          PlatformViewCreatedCallback listener) =>
      _controller.removeOnPlatformViewCreatedListener(listener);

  @override
  Future<void> sendMotionEvent(AndroidMotionEvent event) =>
      _controller.sendMotionEvent(event);

  @override
  Future<void> setLayoutDirection(TextDirection layoutDirection) =>
      _controller.setLayoutDirection(layoutDirection);

  @override
  Future<void> setOffset(Offset off) => _controller.setOffset(off);

  @override
  Future<Size> setSize(Size size) => _controller.setSize(size);

  @override
  int? get textureId => _controller.textureId;

  @override
  int get viewId => _controller.viewId;
}

class AndroidViewWithWrappedController extends StatefulWidget {
  const AndroidViewWithWrappedController({
    Key? key,
    required this.viewType,
    this.onPlatformViewCreated,
    this.hitTestBehavior = PlatformViewHitTestBehavior.opaque,
    this.layoutDirection,
    this.gestureRecognizers,
    this.creationParams,
    this.creationParamsCodec,
    this.clipBehavior = Clip.hardEdge,
  })  : assert(viewType != null),
        assert(hitTestBehavior != null),
        assert(creationParams == null || creationParamsCodec != null),
        assert(clipBehavior != null),
        super(key: key);

  final String viewType;
  final PlatformViewCreatedCallback? onPlatformViewCreated;
  final PlatformViewHitTestBehavior hitTestBehavior;
  final TextDirection? layoutDirection;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;
  final dynamic creationParams;
  final MessageCodec<dynamic>? creationParamsCodec;
  final Clip clipBehavior;

  @override
  State<AndroidViewWithWrappedController> createState() =>
      _AndroidViewWithWrappedControllerState();
}

class _AndroidViewWithWrappedControllerState
    extends State<AndroidViewWithWrappedController> {
  int? _id;
  late AndroidViewController _controller;
  TextDirection? _layoutDirection;
  bool _initialized = false;
  FocusNode? _focusNode;

  static final Set<Factory<OneSequenceGestureRecognizer>> _emptyRecognizersSet =
      <Factory<OneSequenceGestureRecognizer>>{};

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: _onFocusChange,
      child: _CopyPastedAndroidPlatformView(
        controller: _controller,
        hitTestBehavior: widget.hitTestBehavior,
        gestureRecognizers: widget.gestureRecognizers ?? _emptyRecognizersSet,
        clipBehavior: widget.clipBehavior,
      ),
    );
  }

  void _initializeOnce() {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _createNewAndroidView();
    _focusNode = FocusNode(debugLabel: 'AndroidView(id: $_id)');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final TextDirection newLayoutDirection = _findLayoutDirection();
    final bool didChangeLayoutDirection =
        _layoutDirection != newLayoutDirection;
    _layoutDirection = newLayoutDirection;

    _initializeOnce();
    if (didChangeLayoutDirection) {
      // The native view will update asynchronously, in the meantime we don't want
      // to block the framework. (so this is intentionally not awaiting).
      _controller.setLayoutDirection(_layoutDirection!);
    }
  }

  @override
  void didUpdateWidget(AndroidViewWithWrappedController oldWidget) {
    super.didUpdateWidget(oldWidget);

    final TextDirection newLayoutDirection = _findLayoutDirection();
    final bool didChangeLayoutDirection =
        _layoutDirection != newLayoutDirection;
    _layoutDirection = newLayoutDirection;

    if (widget.viewType != oldWidget.viewType) {
      _controller.dispose();
      _createNewAndroidView();
      return;
    }

    if (didChangeLayoutDirection) {
      _controller.setLayoutDirection(_layoutDirection!);
    }
  }

  TextDirection _findLayoutDirection() {
    assert(
        widget.layoutDirection != null || debugCheckHasDirectionality(context));
    return widget.layoutDirection ?? Directionality.of(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _createNewAndroidView() {
    _id = platformViewsRegistry.getNextPlatformViewId();
    _controller = WrappedPlatformViewsService.initAndroidView(
      id: _id!,
      viewType: widget.viewType,
      layoutDirection: _layoutDirection!,
      creationParams: widget.creationParams,
      creationParamsCodec: widget.creationParamsCodec,
      onFocus: () {
        _focusNode!.requestFocus();
      },
    );
    if (widget.onPlatformViewCreated != null) {
      _controller
          .addOnPlatformViewCreatedListener(widget.onPlatformViewCreated!);
    }
  }

  void _onFocusChange(bool isFocused) {
    if (!_controller.isCreated) {
      return;
    }
    if (!isFocused) {
      _controller.clearFocus().catchError((dynamic e) {
        if (e is MissingPluginException) {
          // We land the framework part of Android platform views keyboard
          // support before the engine part. There will be a commit range where
          // clearFocus isn't implemented in the engine. When that happens we
          // just swallow the error here. Once the engine part is rolled to the
          // framework I'll remove this.
          // TODO(amirh): remove this once the engine's clearFocus is rolled.
          return;
        }
      });
      return;
    }
    SystemChannels.textInput.invokeMethod<void>(
      'TextInput.setPlatformViewClient',
      <String, dynamic>{'platformViewId': _id},
    ).catchError((dynamic e) {
      if (e is MissingPluginException) {
        // We land the framework part of Android platform views keyboard
        // support before the engine part. There will be a commit range where
        // setPlatformViewClient isn't implemented in the engine. When that
        // happens we just swallow the error here. Once the engine part is
        // rolled to the framework I'll remove this.
        // TODO(amirh): remove this once the engine's clearFocus is rolled.
        return;
      }
    });
  }
}

class _CopyPastedAndroidPlatformView extends LeafRenderObjectWidget {
  const _CopyPastedAndroidPlatformView({
    required this.controller,
    required this.hitTestBehavior,
    required this.gestureRecognizers,
    this.clipBehavior = Clip.hardEdge,
  })  : assert(controller != null),
        assert(hitTestBehavior != null),
        assert(gestureRecognizers != null),
        assert(clipBehavior != null);

  final AndroidViewController controller;
  final PlatformViewHitTestBehavior hitTestBehavior;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final Clip clipBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderAndroidView(
        viewController: controller,
        hitTestBehavior: hitTestBehavior,
        gestureRecognizers: gestureRecognizers,
        clipBehavior: clipBehavior,
      );

  @override
  void updateRenderObject(
      BuildContext context, RenderAndroidView renderObject) {
    renderObject.controller = controller;
    renderObject.hitTestBehavior = hitTestBehavior;
    renderObject.updateGestureRecognizers(gestureRecognizers);
    renderObject.clipBehavior = clipBehavior;
  }
}
