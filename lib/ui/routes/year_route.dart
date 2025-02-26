// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/year.dart";
import "package:graded/l10n/translations.dart";
import "package:graded/main.dart";
import "package:graded/misc/enums.dart";
import "package:graded/ui/utilities/haptics.dart";
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/easy_form_field.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/popup_menus.dart";

class YearRoute extends StatefulWidget {
  const YearRoute({super.key});

  @override
  State<YearRoute> createState() => _YearRouteState();
}

class _YearRouteState extends SpinningFabPage<YearRoute> {
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final Year year in Manager.years) {
      year.calculate();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        tooltip: translations.add_year,
        onPressed: () {
          setState(() {
            fabRotation += 0.5;
          });
          Navigator.pushNamed(context, "/setup");
        },
        child: SpinningIcon(
          icon: Icons.add,
          rotation: fabRotation,
        ),
      ),
      appBar: AppBar(
        title: Text(translations.manage_years),
        titleSpacing: 0,
        toolbarHeight: 64,
      ),
      body: SafeArea(
        top: false,
        maintainBottomViewPadding: true,
        child: Manager.years.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                primary: true,
                itemCount: Manager.years.length,
                itemBuilder: (context, index) {
                  final Year year = Manager.years[index];
                  return Builder(
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            Card(
                              child: ListTile(
                                title: Text(
                                  year.name,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (Manager.currentYear == index)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 32),
                                        child: Icon(Icons.check),
                                      ),
                                    Text(
                                      Calculator.format(year.result),
                                      overflow: TextOverflow.visible,
                                      softWrap: false,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.normal,
                                          ),
                                    ),
                                  ],
                                ),
                                onLongPress: () {
                                  showPopupActions(context, index, year);
                                },
                                onTap: () {
                                  showPopupActions(context, index, year);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              )
            : EmptyWidget(message: translations.no_items),
      ),
    );
  }

  void showPopupActions(BuildContext context, int index, Year year) {
    showMenuActions<YearAction>(context, YearAction.values, [translations.select, translations.edit, translations.delete]).then((result) {
      if (!context.mounted) return;
      switch (result) {
        case YearAction.select:
          heavyHaptics();
          Manager.changeYear(index);
          Navigator.pushAndRemoveUntil(context, createRoute(const RouteSettings(name: "/")), (_) => false);
        case YearAction.edit:
          nameController.text = year.name;

          showDialog(
            context: context,
            useSafeArea: false,
            builder: (context) {
              final GlobalKey<EasyDialogState> dialogKey = GlobalKey<EasyDialogState>();

              return EasyDialog(
                key: dialogKey,
                title: translations.edit_year,
                icon: Icons.edit,
                child: EasyFormField(
                  controller: nameController,
                  label: translations.name,
                  autofocus: true,
                  flexible: false,
                  onSubmitted: () => dialogKey.currentState?.submit(),
                ),
              );
            },
          ).then((value) {
            year.name = nameController.value.text;
            rebuild();
          });
        case YearAction.delete:
          heavyHaptics();

          Manager.years.removeAt(index);

          if (Manager.years.isEmpty) {
            Navigator.pushNamedAndRemoveUntil(context, "/setup", (_) => false);
          } else if (index == Manager.currentYear || Manager.currentYear == Manager.years.length) {
            Manager.changeYear(Manager.years.length - 1);
          }
        default:
          break;
      }
      rebuild();
    });
  }
}
