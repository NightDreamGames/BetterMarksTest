// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:showcaseview/showcaseview.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/l10n/translations.dart";
import "package:graded/misc/enums.dart";
import "package:graded/ui/routes/subject_edit_route.dart";
import "package:graded/ui/utilities/haptics.dart";
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/popup_menus.dart";

class TextRow extends StatelessWidget {
  const TextRow({
    super.key,
    required this.leadingText,
    required this.trailingText,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.onTap,
    this.onLongPress,
    this.isChild = false,
    this.horizontalTitleGap = 16,
    this.enableEqualLongPress = false,
  });

  final String leadingText;
  final String trailingText;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets padding;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool isChild;
  final double horizontalTitleGap;
  final bool enableEqualLongPress;

  @override
  Widget build(BuildContext context) {
    final Widget listTile = ListTile(
      horizontalTitleGap: horizontalTitleGap,
      onTap: onTap,
      onLongPress: enableEqualLongPress ? onTap : onLongPress,
      contentPadding: padding,
      leading: leading,
      title: Text(
        leadingText,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trailingText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
          ),
          if (trailing != null) ...[
            const Padding(padding: EdgeInsets.only(right: 24)),
            Theme(
              data: Theme.of(context).copyWith(
                iconTheme: Theme.of(context).iconTheme.copyWith(
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              ),
              child: trailing!,
            ),
          ],
        ],
      ),
    );

    return !isChild
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Card(
              child: listTile,
            ),
          )
        : listTile;
  }
}

class GroupRow extends StatefulWidget {
  const GroupRow({
    super.key,
    required this.children,
    required this.leadingText,
    required this.trailingText,
  });

  final String leadingText;
  final String trailingText;
  final List<Widget> children;

  @override
  State<GroupRow> createState() => _GroupRowState();
}

class _GroupRowState extends State<GroupRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        child: ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              widget.leadingText,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.trailingText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
              const Padding(padding: EdgeInsets.only(right: 24)),
              AnimatedRotation(
                turns: _isExpanded ? .5 : 0,
                duration: Durations.short4,
                child: const Icon(
                  Icons.expand_more,
                  size: 24,
                ),
              ),
            ],
          ),
          onExpansionChanged: (value) {
            setState(() {
              _isExpanded = value;
            });
            lightHaptics();
          },
          children: widget.children,
        ),
      ),
    );
  }
}

class ResultRow extends StatefulWidget {
  const ResultRow({
    super.key,
    required this.result,
    required this.preciseResult,
    this.leading,
  });

  final String result;
  final String preciseResult;
  final Widget? leading;

  @override
  State<ResultRow> createState() => _ResultRowState();
}

class _ResultRowState extends State<ResultRow> {
  bool showPreciseResult = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              showPreciseResult = !showPreciseResult;
            }),
            behavior: HitTestBehavior.translucent,
            child: SizedBox(
              height: 54,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.leading != null) Expanded(flex: 3, child: widget.leading!),
                    const Padding(padding: EdgeInsets.only(right: 16)),
                    Text(
                      showPreciseResult ? widget.preciseResult : widget.result,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            thickness: 2,
          ),
        ],
      ),
    );
  }
}

class SubjectTile extends StatefulWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    this.potentialParent,
    required this.reorderIndex,
    this.onActionCompleted,
    this.shouldShowcase = false,
  });

  final Subject subject;
  final Subject? potentialParent;
  final int reorderIndex;
  final Function()? onActionCompleted;
  final bool shouldShowcase;

  @override
  State<SubjectTile> createState() => _SubjectTileState();
}

class _SubjectTileState extends State<SubjectTile> {
  bool showcasing = false;

  Future<void> showTutorial(BuildContext context) async {
    if (!widget.shouldShowcase || showcasing) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500), () {
        if (!widget.shouldShowcase || showcasing || !context.mounted || context.findAncestorWidgetOfExactType<ShowCaseWidget>() == null) return;
        ShowCaseWidget.of(context).startShowCase([showCaseKey1, showCaseKey2]);
        showcasing = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String weightString = Calculator.format(widget.subject.weight, leadingZero: false, roundToOverride: 1);

    showTutorial(context);

    return AnimatedPadding(
      duration: Durations.medium2,
      curve: Easing.standard,
      padding: widget.subject.isChild ? const EdgeInsets.only(left: 16) : EdgeInsets.zero,
      child: TextRow(
        leadingText: widget.subject.name,
        trailingText: weightString == "0" && widget.subject.isGroup ? "" : weightString,
        padding: const EdgeInsets.only(left: 4, right: 24),
        horizontalTitleGap: 8,
        enableEqualLongPress: true,
        leading: ReorderableDragStartListener(
          index: widget.reorderIndex,
          child: widget.shouldShowcase
              ? Showcase(
                  key: showCaseKey1,
                  description: translations.showcase_tap_subject,
                  scaleAnimationCurve: Easing.standardDecelerate,
                  child: Showcase(
                    key: showCaseKey2,
                    description: translations.showcase_drag_subject,
                    scaleAnimationCurve: Easing.standardDecelerate,
                    child: IgnorePointer(
                      child: ReorderableHandle(
                        target: widget.subject,
                        potentialParent: widget.potentialParent,
                        onActionCompleted: widget.onActionCompleted,
                      ),
                    ),
                  ),
                )
              : ReorderableHandle(
                  target: widget.subject,
                  potentialParent: widget.potentialParent,
                  onActionCompleted: widget.onActionCompleted,
                ),
        ),
        onTap: () {
          showMenuActions<MenuAction>(context, MenuAction.values, [translations.edit, translations.delete]).then((result) {
            switch (result) {
              case MenuAction.edit:
                if (!context.mounted) return;
                showSubjectDialog(
                  context,
                  subject: widget.subject,
                  action: CreationType.edit,
                ).then((_) => widget.onActionCompleted?.call());
              case MenuAction.delete:
                heavyHaptics();

                if (widget.subject.isChild) {
                  final Subject parent = widget.potentialParent!;
                  parent.children.remove(widget.subject);
                  parent.isGroup = parent.children.isNotEmpty;
                } else {
                  getCurrentYear().subjects.remove(widget.subject);
                }

                Manager.calculate();
                widget.onActionCompleted?.call();
              default:
                break;
            }
          });
        },
      ),
    );
  }
}

class ReorderableHandle extends StatelessWidget {
  const ReorderableHandle({
    super.key,
    required this.target,
    this.potentialParent,
    this.onActionCompleted,
  });

  final Subject target;
  final Subject? potentialParent;
  final Function()? onActionCompleted;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: translations.set_sub_subject,
      icon: const Icon(Icons.drag_handle),
      onPressed: () {
        final bool isChild = target.isChild;

        if (potentialParent == null && !isChild) return;

        lightHaptics();

        final subjects = getCurrentYear().subjects;

        if (!isChild) {
          final Subject parent = potentialParent!;
          final Subject child = target;

          subjects.remove(child);

          parent.isGroup = true;
          child.isChild = true;
          child.isGroup = false;

          parent.children.addAll([child, ...child.children]);
          child.children.clear();
        } else {
          final Subject parent = potentialParent!;
          final Subject child = target;

          parent.children.remove(child);
          subjects.insert(subjects.indexOf(parent) + 1, child..isChild = false);
          if (parent.children.isEmpty) parent.isGroup = false;
        }

        Manager.calculate();
        onActionCompleted?.call();
      },
    );
  }
}
