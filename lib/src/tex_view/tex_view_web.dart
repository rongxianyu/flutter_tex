import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutter_tex/src/tex_view/utils/core_utils.dart';
import 'package:web/web.dart';

@JS('TeXViewRenderedCallback')
external set teXViewRenderedCallback(JSFunction callback);

@JS('OnTapCallback')
external set onTapCallback(JSFunction callback);

@JS('initWebTeXView')
external void initWebTeXView(String viewId, String rawData);

class TeXViewState extends State<TeXView> {
  final String _viewId = UniqueKey().toString();
  final HTMLIFrameElement iframeElement = HTMLIFrameElement()
    ..src = "assets/packages/flutter_tex/core/flutter_tex.html"
    ..style.height = '100%'
    ..style.width = '100%'
    ..style.border = '0';

  final StreamController<double> heightStreamController = StreamController();

  String _lastRawData = '';
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    _renderTeXView();
    return StreamBuilder<double>(
        stream: heightStreamController.stream,
        builder: (context, snap) {
          return SizedBox(
            height: snap.data ?? initialHeight,
            child: HtmlElementView(
              key: widget.key ?? ValueKey(_viewId),
              viewType: _viewId,
            ),
          );
        });
  }

  @override
  void initState() {
    iframeElement.id = _viewId;

    platformViewRegistry.registerViewFactory(
        _viewId, (int id) => iframeElement);
    teXViewRenderedCallback = onTeXViewRendered.toJS;
    onTapCallback = onTap.toJS;
    _isReady = true;
    _renderTeXView();

    super.initState();
  }

  void onTap(JSString id) {
    widget.child.onTapCallback(id.toString());
  }

  void onTeXViewRendered(JSNumber message) {
    heightStreamController
        .add(double.parse(message.toString()) + widget.heightOffset);

    // if (viewHeight != _teXViewHeight && mounted) {
    //   setState(() {
    //     _teXViewHeight = viewHeight;
    //   });
    // }
  }

  @override
  void dispose() {
    if (mounted) {
      heightStreamController.close();
    }
    super.dispose();
  }

  void _renderTeXView() {
    if (!_isReady) {
      return;
    }
    var currentRawData = getRawData(widget);
    if (currentRawData != _lastRawData) {
      initWebTeXView(_viewId, currentRawData);
      _lastRawData = currentRawData;
    }
  }
}
