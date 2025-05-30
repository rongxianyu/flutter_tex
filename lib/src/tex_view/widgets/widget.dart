import 'package:flutter_tex/src/tex_view/utils/widget_meta.dart';

abstract class TeXViewWidget {
  const TeXViewWidget();

  TeXViewWidgetMeta meta();

  void onTapCallback(String id) {}

  Map<dynamic, dynamic> toJson();
}
