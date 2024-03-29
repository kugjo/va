import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabulary_advancer/app/common/form_validation.dart';
import 'package:vocabulary_advancer/core/model.dart';
import 'package:vocabulary_advancer/shared/svc.dart';

class PhraseGroupEditorModel {
  int? groupId;
  String initialGroupName = '';
  String currentGroupName = '';

  bool get isNewGroup => groupId == null;

  PhraseGroupEditorModel(this.groupId);

  PhraseGroupEditorModel.from(
    PhraseGroupEditorModel model, {
    String? initialGroupName,
    String? currentGroupName,
  }) {
    groupId = model.groupId;
    this.initialGroupName = initialGroupName ?? model.initialGroupName;
    this.currentGroupName = currentGroupName ?? model.currentGroupName;
  }
}

class PhraseGroupEditorPageResult {
  PhraseGroupEditorPageResult.deleted(this.group)
      : isDeleted = true,
        isAdded = false,
        isUpdated = false;
  PhraseGroupEditorPageResult.added(this.group)
      : isDeleted = false,
        isAdded = true,
        isUpdated = false;
  PhraseGroupEditorPageResult.updated(this.group)
      : isDeleted = false,
        isAdded = false,
        isUpdated = true;

  final bool isDeleted;
  final bool isAdded;
  final bool isUpdated;
  final PhraseGroup? group;
}

class PhraseGroupEditorViewModel extends Cubit<PhraseGroupEditorModel> with FormValidation {
  PhraseGroupEditorViewModel(int? groupId) : super(PhraseGroupEditorModel(groupId));

  void init() {
    final item = svc.repPhraseGroup.findSingle(state.groupId);
    emit(PhraseGroupEditorModel.from(state, initialGroupName: item?.name));
  }

  String? validatorForName(String? name, String messageWhenEmpty, String messageWhenAlreadyExists) {
    final empty = validationMessageWhenEmpty(value: name, messageWhenEmpty: () => messageWhenEmpty);

    if (empty != null) return empty;
    if (svc.repPhraseGroup.findSingleBy(name) != null) {
      return messageWhenAlreadyExists;
    }

    return null;
  }

  void updateName(String value) {
    state.currentGroupName = value;
    validateInlineIfNeeded();
  }

  void deleteAndClose() {
    if (state.isNewGroup) return;
    final group = svc.repPhraseGroup.delete(state.groupId!);
    svc.route.popWithResult(PhraseGroupEditorPageResult.deleted(group));
  }

  void tryApplyAndClose() {
    if (validate()) {
      final group = state.isNewGroup
          ? svc.repPhraseGroup.create(state.currentGroupName)
          : svc.repPhraseGroup.rename(state.groupId!, state.currentGroupName);

      svc.route.popWithResult(state.isNewGroup
          ? PhraseGroupEditorPageResult.added(group)
          : PhraseGroupEditorPageResult.updated(group));
    }
  }
}
