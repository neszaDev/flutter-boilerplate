import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/rbac/access.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/validation/validation.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';
import 'package:flutter_boilerplate/features/test_results/test_result_validation.dart';
import 'package:flutter_boilerplate/features/test_results/test_results_data.dart';
import 'package:flutter_boilerplate/features/test_results/widgets/report_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the add form, or the edit form for [existing]. Resolves true when something changed.
Future<bool> showTestResultSheet(BuildContext context, {TestResult? existing}) async {
  final changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => TestResultSheet(existing: existing),
  );
  return changed ?? false;
}

/// Asks, deletes, and tells. Resolves true when the result was deleted.
Future<bool> deleteTestResult(BuildContext context, WidgetRef ref, TestResult result) async {
  final l10n = context.l10n;
  final confirmed = await confirm(
    context,
    title: l10n.testResultsPageConfirmTitle(result.testName),
    text: l10n.testResultsPageConfirmText,
    confirmLabel: l10n.testResultsPageConfirmDelete,
    cancelLabel: l10n.testResultsPageConfirmCancel,
  );
  if (!confirmed || !context.mounted) {
    return false;
  }
  try {
    await ref.read(testResultsRepositoryProvider).delete(result.id);
    invalidateTestResults(ref);
    if (context.mounted) {
      showToast(context, l10n.testResultsPageDeleted(result.testName), tone: ToastTone.success);
    }
    return true;
  } on ApiException catch (error) {
    if (context.mounted) {
      showToast(context, errorMessage(context, error), tone: ToastTone.error);
    }
    return false;
  }
}

/// Name, status, score, tested at and notes; the web's `TestResultForm`, plus editing.
class TestResultSheet extends ConsumerStatefulWidget {
  const TestResultSheet({this.existing, super.key});

  final TestResult? existing;

  @override
  ConsumerState<TestResultSheet> createState() => _TestResultSheetState();
}

class _TestResultSheetState extends ConsumerState<TestResultSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.testName);
  late final _score = TextEditingController(
    text: widget.existing == null ? '' : _plain(widget.existing!.score),
  );
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late TestStatus _status = widget.existing?.status ?? TestStatus.pending;
  late DateTime _testedAt = widget.existing?.testedAt.toLocal() ?? _nowToTheMinute();
  bool _busy = false;
  String? _formError;
  Map<String, String> _fieldErrors = const {};

  bool get _editing => widget.existing != null;

  static DateTime _nowToTheMinute() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }

  static String _plain(double score) =>
      score == score.roundToDouble() ? score.toStringAsFixed(0) : score.toString();

  @override
  void dispose() {
    _name.dispose();
    _score.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickTestedAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _testedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_testedAt),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _testedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _testedAt.hour,
        time?.minute ?? _testedAt.minute,
      );
    });
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    setState(() {
      _formError = null;
      _fieldErrors = const {};
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _busy = true);
    final input = TestResultInput(
      testName: _name.text,
      status: _status,
      score: parseScore(_score.text)!,
      testedAt: _testedAt,
      notes: _notes.text.isEmpty ? null : _notes.text,
    );
    final repository = ref.read(testResultsRepositoryProvider);
    try {
      if (_editing) {
        await repository.update(widget.existing!.id, input);
      } else {
        await repository.create(input);
      }
      invalidateTestResults(ref);
      if (!mounted) {
        return;
      }
      showToast(
        context,
        _editing ? l10n.testResultFormSaved : l10n.testResultFormCreated,
        tone: ToastTone.success,
      );
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _fieldErrors = error.fieldErrors;
        _formError = error.fieldErrors.isNotEmpty
            ? l10n.testResultFormErrorInvalidInput
            : errorMessage(context, error, fallback: l10n.testResultFormErrorGeneric);
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final canDelete = _editing && ref.watch(accessProvider).can(Permission.manageOwnTestResults);

    return Padding(
      // Keep the focused field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editing ? l10n.testResultsPageEditTitle : l10n.testResultsPageCreateTitle,
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: Space.card),
              if (_formError != null) ...[
                FormAlert(_formError!),
                const SizedBox(height: Space.page),
              ],
              LabeledField(
                label: l10n.testResultFormTestNameLabel,
                child: TextFormField(
                  key: const Key('testResult.name'),
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 100,
                  decoration: InputDecoration(errorText: _fieldErrors['testName'], counterText: ''),
                  validator: validator(l10n, testNameRule),
                ),
              ),
              const SizedBox(height: Space.page),
              LabeledField(
                label: l10n.testResultFormStatusLabel,
                child: SegmentedButton<TestStatus>(
                  showSelectedIcon: false,
                  segments: [
                    for (final status in TestStatus.values)
                      ButtonSegment(
                        value: status,
                        icon: Mark(status: status, size: 16),
                        label: Text(statusLabel(l10n, status)),
                      ),
                  ],
                  selected: {_status},
                  onSelectionChanged: (selection) => setState(() => _status = selection.first),
                ),
              ),
              const SizedBox(height: Space.page),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledField(
                      label: l10n.testResultFormScoreLabel,
                      aside: l10n.testResultFormScoreHint,
                      child: TextFormField(
                        key: const Key('testResult.score'),
                        controller: _score,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        style: context.type.table.copyWith(fontSize: 16),
                        decoration: InputDecoration(errorText: _fieldErrors['score']),
                        validator: validator(l10n, scoreRule),
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    flex: 2,
                    child: LabeledField(
                      label: l10n.testResultFormTestedAtLabel,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: Space.md),
                        ),
                        onPressed: _pickTestedAt,
                        child: Text(
                          context.formatDateTime(_testedAt),
                          style: context.type.table,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_fieldErrors['testedAt'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: Space.xs),
                  child: Text(_fieldErrors['testedAt']!, style: TextStyle(color: colors.pen)),
                ),
              const SizedBox(height: Space.page),
              LabeledField(
                label: l10n.testResultFormNotesLabel,
                aside: l10n.testResultFormNotesHint,
                child: TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 1000,
                  textCapitalization: TextCapitalization.sentences,
                  style: context.type.handNote.copyWith(fontSize: 17, color: colors.ink900),
                  decoration: InputDecoration(errorText: _fieldErrors['notes']),
                  validator: validator(l10n, notesRule),
                ),
              ),
              const SizedBox(height: Space.lg),
              BusyButton(
                key: const Key('testResult.submit'),
                label: _editing ? l10n.commonSave : l10n.testResultFormCreateButton,
                busy: _busy,
                onPressed: _submit,
              ),
              if (canDelete) ...[
                const SizedBox(height: Space.sm),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: colors.pen),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.testResultsPageDeleteButton),
                  onPressed: _busy
                      ? null
                      : () async {
                          final deleted = await deleteTestResult(context, ref, widget.existing!);
                          if (deleted && context.mounted) {
                            Navigator.pop(context, true);
                          }
                        },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
