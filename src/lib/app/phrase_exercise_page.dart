import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabulary_advancer/app/common/rotatable.dart';
import 'package:vocabulary_advancer/app/i18n/strings.g.dart';
import 'package:vocabulary_advancer/app/phrase_exercise_vm.dart';
import 'package:vocabulary_advancer/app/themes/card_decoration.dart';
import 'package:vocabulary_advancer/app/themes/va_theme.dart';
import 'package:vocabulary_advancer/core/model.dart';

class PhraseExercisePage extends StatefulWidget {
  final String groupId;

  PhraseExercisePage(this.groupId);

  @override
  _PhraseExercisePageState createState() => _PhraseExercisePageState();
}

class _PhraseExercisePageState extends State<PhraseExercisePage> {
  late PhraseExerciseViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = PhraseExerciseViewModel(widget.groupId)..init();
  }

  @override
  void dispose() {
    _vm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<PhraseExerciseViewModel, PhraseExerciseModel>(
      bloc: _vm,
      builder: (context, model) => Scaffold(
            appBar: model.isLoading
                ? null
                : AppBar(
                    automaticallyImplyLeading: !kIsWeb,
                    title: Text(
                        model.countTargeted > 0
                            ? "${Translations.of(context).titles.Exercising}: ${model.countTargeted}"
                            : Translations.of(context).titles.Exercising,
                        style: VATheme.of(context).textHeadline6)),
            body: model.isLoading
                ? Center(child: CircularProgressIndicator())
                : model.isAny
                    ? OrientationBuilder(
                        builder: (context, orientation) => orientation == Orientation.portrait
                            ? Column(children: [
                                SizedBox(height: 180, child: _buildAnimatedCard(context, model)),
                                Expanded(
                                  child: _buildExamplesCard(context, model),
                                ),
                                SizedBox(
                                  height: 120,
                                  child: _buildStatsCard(context, model),
                                ),
                                SizedBox(
                                    height: 100,
                                    child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: _buildActionButtons(context, true, model)))
                              ])
                            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Expanded(
                                    child: SizedBox(
                                        height: 150, child: _buildAnimatedCard(context, model))),
                                Expanded(child: _buildExamplesCard(context, model)),
                                SizedBox(
                                    width: 100,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: _buildActionButtons(context, false, model)
                                          .reversed
                                          .toList(),
                                    ))
                              ]))
                    : _buildEmptyBody(context),
          ));

  Widget _buildAnimatedCard(BuildContext context, PhraseExerciseModel model) => model.isAnimated
      ? Rotatable(onRotated: () => _vm.rotateCard(), child: _buildCard(context, isAnimated: true))
      : GestureDetector(
          onTap: () => _vm.animateCard(),
          child: _buildCard(context,
              value: model.isOpen ? model.current!.phrase : model.current!.definition,
              pronounce: model.isOpen ? model.current!.pronunciation : '',
              isOpen: model.isOpen));

  Widget _buildCard(BuildContext context,
          {String value = '',
          String pronounce = '',
          bool isAnimated = false,
          bool isOpen = false}) =>
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
        child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: cardDecoration(context),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Visibility(
                  visible: !isAnimated,
                  child: Icon(Icons.mode_comment,
                      color: isOpen
                          ? VATheme.of(context).colorAttention
                          : VATheme.of(context).colorPrimary100)),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Visibility(
                        visible: !isAnimated,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(value,
                                  style: isOpen
                                      ? VATheme.of(context).textSubtitle2
                                      : VATheme.of(context).textBodyText1),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  pronounce,
                                  style: VATheme.of(context).textPronounciation,
                                ),
                              )
                            ],
                          ),
                        ),
                      )))
            ])),
      );

  Widget _buildExamplesCard(BuildContext context, PhraseExerciseModel model) => Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
        child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: cardDecoration(context),
            child: ListView.separated(
                itemCount: model.current!.examples.length,
                separatorBuilder: (context, i) => Divider(
                    indent: 8.0, endIndent: 8.0, color: VATheme.of(context).colorPrimary050),
                itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(model.current!.examples[i],
                          maxLines: 3, style: VATheme.of(context).textBodyText2),
                    ))),
      );

  charts.Color _chartColor(Color c) => charts.Color(a: c.alpha, r: c.red, g: c.green, b: c.blue);

  Widget _buildStatsCard(BuildContext context, PhraseExerciseModel model) => Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 12.0, right: 16.0, bottom: 16),
        child: charts.BarChart(
          [
            charts.Series<int, String>(
                id: 'Progress',
                domainFn: (x, n) => n?.toString() ?? "",
                measureFn: (x, n) => x,
                data: (model.current?.rates.length ?? 0) > 2 ? model.current!.rates.toList() : [],
                labelAccessorFn: (x, n) => x.toString(),
                fillColorFn: (n, i) => _chartColor(VATheme.of(context).colorPrimary500))
          ],
          barRendererDecorator: charts.BarLabelDecorator<String>(
              outsideLabelStyleSpec:
                  charts.TextStyleSpec(color: VATheme.of(context).colorPrimary050.toChartsColor()),
              insideLabelStyleSpec:
                  charts.TextStyleSpec(color: VATheme.of(context).colorPrimary050.toChartsColor())),
          domainAxis: charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
          primaryMeasureAxis: charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
          layoutConfig: charts.LayoutConfig(
              leftMarginSpec: charts.MarginSpec.fixedPixel(0),
              topMarginSpec: charts.MarginSpec.fixedPixel(0),
              rightMarginSpec: charts.MarginSpec.fixedPixel(0),
              bottomMarginSpec: charts.MarginSpec.fixedPixel(0)),
        ),
      );

  List<Widget> _buildActionButtons(
          BuildContext context, bool withDivider, PhraseExerciseModel model) =>
      [
        if (withDivider) SizedBox(width: 8.0),
        IconButton(
            iconSize: 48,
            tooltip: Translations.of(context).labels.ExerciseResult.Low,
            icon: Icon(Icons.arrow_downward, color: VATheme.of(context).colorAttention),
            onPressed: () => _vm.next(RateFeedback.lowTheshold)),
        if (withDivider)
          VerticalDivider(indent: 12, endIndent: 24, color: VATheme.of(context).colorPrimary400),
        IconButton(
            iconSize: 48,
            tooltip: Translations.of(context).labels.ExerciseResult.Negative,
            icon:
                Icon(Icons.trending_down, color: VATheme.of(context).colorForegroundIconUnselected),
            onPressed: () => _vm.next(RateFeedback.negative)),
        if (withDivider)
          VerticalDivider(indent: 12, endIndent: 24, color: VATheme.of(context).colorPrimary400),
        IconButton(
            iconSize: 48,
            tooltip: Translations.of(context).labels.ExerciseResult.Uncertain,
            icon:
                Icon(Icons.trending_flat, color: VATheme.of(context).colorForegroundIconUnselected),
            onPressed: () => _vm.next(RateFeedback.uncertain)),
        if (withDivider)
          VerticalDivider(indent: 12, endIndent: 24, color: VATheme.of(context).colorPrimary400),
        IconButton(
            iconSize: 48,
            tooltip: Translations.of(context).labels.ExerciseResult.Positive,
            icon: Icon(Icons.trending_up, color: VATheme.of(context).colorForegroundIconUnselected),
            onPressed: () => _vm.next(RateFeedback.positive)),
        if (withDivider)
          VerticalDivider(indent: 12, endIndent: 24, color: VATheme.of(context).colorPrimary400),
        IconButton(
            iconSize: 48,
            tooltip: Translations.of(context).labels.ExerciseResult.High,
            icon: Icon(Icons.arrow_upward, color: VATheme.of(context).colorTextAccent),
            onPressed: () => _vm.next(RateFeedback.highThershold)),
        if (withDivider) SizedBox(width: 8.0),
      ];

  Widget _buildEmptyBody(BuildContext context) => Padding(
      padding: const EdgeInsets.all(64.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline,
                size: 32, color: VATheme.of(context).colorForegroundIconSelected),
            const SizedBox(height: 16.0),
            Text(Translations.of(context).text.NoPhrase),
          ]));
}

extension on Color {
  charts.Color toChartsColor() => charts.Color(a: alpha, r: red, g: green, b: blue);
}
