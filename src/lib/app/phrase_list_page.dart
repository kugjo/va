import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabulary_advancer/app/common/empty.dart';
import 'package:vocabulary_advancer/app/common/stat_target.dart';
import 'package:vocabulary_advancer/app/i18n/strings.g.dart';
import 'package:vocabulary_advancer/app/phrase_list_vm.dart';
import 'package:vocabulary_advancer/app/themes/va_theme.dart';
import 'package:vocabulary_advancer/core/extensions.dart';

class PhraseListPage extends StatefulWidget {
  PhraseListPage({required this.groupName});

  final String groupName;

  @override
  _PhraseListPageState createState() => _PhraseListPageState();
}

class _PhraseListPageState extends State<PhraseListPage> {
  late PhraseListViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = PhraseListViewModel(widget.groupName)..init();
  }

  @override
  void dispose() {
    _vm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PhraseListViewModel, PhraseListModel>(
          bloc: _vm,
          builder: (context, model) => Scaffold(
              appBar: model.isLoading
                  ? null
                  : AppBar(
                      title: Text(model.phraseGroupName,
                          style: VATheme.of(context).textHeadline5),
                      actions: _buildAppBarActions(context, model),
                    ),
              body: model.isLoading
                  ? CircularProgressIndicator()
                  : model.phrases.isNotEmpty
                      ? ListView.separated(
                          itemCount: model.phrases.length,
                          itemBuilder: (context, i) =>
                              _buildPhraseItem(context, model, i),
                          separatorBuilder: (context, i) =>
                              const Divider(indent: 16, endIndent: 16))
                      : Empty()));

  Widget _buildPhraseItem(
          BuildContext context, PhraseListModel model, int index) =>
      ListTileTheme(
        selectedColor: VATheme.of(context).colorAccentVariant,
        child: ListTile(
            selected: model.isSelected(index),
            onTap: () =>
                model.isSelected(index) ? _vm.unselect() : _vm.select(index),
            title: Text(model.phrases[index].phrase,
                style: VATheme.of(context).textBodyText1),
            dense: false,
            leading: model.isSelected(index)
                ? CircleAvatar(
                    backgroundColor: VATheme.of(context).colorAccentVariant,
                    radius: 12,
                    child: Icon(Icons.check,
                        size: 12, color: VATheme.of(context).colorPrimaryDark))
                : CircleAvatar(
                    backgroundColor: VATheme.of(context).colorPrimaryLight,
                    radius: 12,
                    child: Icon(Icons.check,
                        size: 12, color: VATheme.of(context).colorPrimaryDark)),
            trailing: SizedBox(
              width: 48,
              child: Center(
                  child: StatTarget(
                      model.phrases[index].targetUtc.differenceNowUtc())),
            )),
      );

  List<Widget> _buildAppBarActions(
          BuildContext context, PhraseListModel model) =>
      [
        if (model.anySelected)
          IconButton(
              icon: Icon(Icons.edit,
                  color: VATheme.of(context).colorAccentVariant),
              tooltip: Translations.of(context).labels.Edit,
              onPressed: () async {
                await _vm.navigateToEditPhrase();
              }),
        IconButton(
            icon: Icon(Icons.plus_one),
            tooltip: Translations.of(context).labels.Add,
            onPressed: () async {
              await _vm.navigateToAddPhrase();
            })
      ];
}
