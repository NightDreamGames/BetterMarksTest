// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:shared_preferences/shared_preferences.dart";
import "package:test/test.dart";

// Project imports:
import "package:graded/calculations/calculation_object.dart";
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/calculations/test.dart";
import "package:graded/calculations/year.dart";
import "package:graded/l10n/generated/l10n.dart";
import "package:graded/misc/enums.dart";
import "package:graded/ui/settings/flutter_settings_screens.dart";

void main() async {
  SharedPreferences.setMockInitialValues({});
  await Settings.init();
  TranslationsClass.load(const Locale("en", "GB"));
  Manager.init();
  Manager.addYear(year: Year());

  test("Calculations", () async {
    final List<CalculationObject> emptyList = [Test(null, 0), Test(null, 0), Test(null, 0)];
    final List<CalculationObject> oneItemList = [Test(80, 100)];
    final List<CalculationObject> multipleItemsList = [Test(47.5, 50), Test(65.9, 70), Test(50, 55)];
    final List<CalculationObject> speakingList = [Test(0, 60, isSpeaking: true), Test(60, 60)];
    final List<CalculationObject> clampingList = [Test(80, 100), Test(150, 100)];
    final List<CalculationObject> scaleUpTestsList = [Test(30, 40), Test(06, 10)];

    expect(Calculator.calculate([]), equals(null));
    expect(Calculator.calculate(emptyList), equals(null));
    expect(Calculator.calculate(speakingList, speakingWeight: 3), equals(45));
    expect(Calculator.calculate(multipleItemsList), equals(57));
    expect(Calculator.calculate(multipleItemsList, bonus: -3), equals(54));
    expect(Calculator.calculate(multipleItemsList, bonus: 3, precise: true), equals(59.1));

    expect(Calculator.calculate(oneItemList), equals(48));
    getCurrentYear().maxGrade = 100;
    expect(Calculator.calculate(oneItemList), equals(80));

    expect(Calculator.calculate(clampingList), equals(100));
    expect(Calculator.calculate(clampingList, clamp: false), equals(115));

    expect(Calculator.calculate(scaleUpTestsList, precise: true), equals(72));
    getCurrentYear().scaleUpTests = true;
    expect(Calculator.calculate(scaleUpTestsList, precise: true), equals(67.5));
  });

  test("Number formatting", () {
    expect(Calculator.format(null), equals("-"));
    expect(Calculator.format(47), equals("47"));
    expect(Calculator.format(3.14159), equals("03.14159"));
    expect(Calculator.format(3.14159, roundToOverride: 100), equals("03.14159"));
    expect(Calculator.format(0.5, roundToOverride: 100), equals("0.50"));
    expect(Calculator.format(47, roundToOverride: 10), equals("47.0"));
    expect(Calculator.format(47.5), equals("47.5"));
    expect(Calculator.format(47.5, roundToOverride: 100), equals("47.50"));
    expect(Calculator.format(1, leadingZero: false), equals("1"));
    expect(Calculator.format(3.14159, leadingZero: false), equals("3.14159"));
    expect(Calculator.format(1), equals("01"));
    expect(Calculator.format(47.5, roundToOverride: 10, roundToMultiplier: 10), equals("47.50"));
  });

  test("Number rounding", () {
    expect(Calculator.round(47), equals(47));
    expect(Calculator.round(47.11), equals(48));
    expect(Calculator.round(47.111, roundToOverride: 10), equals(47.2));
    expect(Calculator.round(47.199, roundToOverride: 100), equals(47.2));
    expect(Calculator.round(47.199, roundingModeOverride: RoundingMode.down, roundToOverride: 10), equals(47.1));
    expect(Calculator.round(47.5, roundingModeOverride: RoundingMode.halfUp), equals(48));
    expect(Calculator.round(47.15, roundingModeOverride: RoundingMode.halfDown, roundToOverride: 10), equals(47.1));
    expect(Calculator.round(-1.23, roundingModeOverride: RoundingMode.up, roundToOverride: 10), equals(-1.2));
    expect(Calculator.round(-1.23, roundingModeOverride: RoundingMode.down, roundToOverride: 1), equals(-2));
    expect(Calculator.round(-1.5, roundingModeOverride: RoundingMode.halfUp, roundToOverride: 1), equals(-2));
    expect(Calculator.round(-1.5, roundingModeOverride: RoundingMode.halfDown, roundToOverride: 1), equals(-1));
  });

  test("Number parsing", () {
    expect(Calculator.tryParse(null), equals(null));
    expect(Calculator.tryParse(""), equals(null));
    expect(Calculator.tryParse("abc"), equals(null));

    expect(Calculator.tryParse("1"), equals(1));
    expect(Calculator.tryParse("1.23"), equals(1.23));
    expect(Calculator.tryParse("1,23"), equals(1.23));
    expect(Calculator.tryParse("-1.23"), equals(-1.23));
    expect(Calculator.tryParse("1 234.56"), equals(1234.56));
    expect(Calculator.tryParse("1,234.56"), equals(null));
    expect(Calculator.tryParse("1.234,56"), equals(null));
    expect(Calculator.tryParse(".89"), equals(0.89));
  });

  test("Object sorting", () {
    // Test sorting by name in ascending order
    List<CalculationObject> data = [
      Test(30, 100, name: "Beta"),
      Test(30, 100, name: "Alpha"),
      Test(30, 100, name: "Delta"),
      Test(30, 100, name: "Gamma"),
    ];

    data = Calculator.sortObjects(data, sortType: 1, sortModeOverride: SortMode.name);

    expect(data[0].name, "Alpha");
    expect(data[1].name, "Beta");
    expect(data[2].name, "Delta");
    expect(data[3].name, "Gamma");

    // Test sorting by result in descending order
    data = [
      Test(50, 100, name: "Beta"),
      Test(40, 100, name: "Alpha"),
      Test(86, 100, name: "Delta"),
      Test(99, 100, name: "Gamma"),
    ];

    data = Calculator.sortObjects(
      data,
      sortType: 1,
      sortModeOverride: SortMode.result,
      sortDirectionOverride: SortDirection.descending,
    );

    expect(data[0].name, "Gamma");
    expect(data[1].name, "Delta");
    expect(data[2].name, "Beta");
    expect(data[3].name, "Alpha");

    // Test sorting by coefficient in descending order
    data = [
      Term(name: "Alpha", weight: 0.5),
      Term(name: "Beta", weight: 0.3),
      Term(name: "Delta", weight: 0.8),
      Term(name: "Gamma", weight: 0.1),
    ];

    data = Calculator.sortObjects(
      data,
      sortType: 1,
      sortModeOverride: SortMode.weight,
      sortDirectionOverride: SortDirection.descending,
    );

    expect(data[0].name, "Delta");
    expect(data[1].name, "Alpha");
    expect(data[2].name, "Beta");
    expect(data[3].name, "Gamma");

    // Test sorting using custom order
    data = [
      Subject("Gamma", 1),
      Subject("Beta", 1),
      Subject("Alpha", 1),
      Subject("Delta", 1),
    ];

    data = Calculator.sortObjects(
      data,
      sortType: 1,
      sortModeOverride: SortMode.custom,
      sortDirectionOverride: SortDirection.ascending,
    );

    expect(data[0].name, "Gamma");
    expect(data[1].name, "Beta");
    expect(data[2].name, "Alpha");
    expect(data[3].name, "Delta");
  });

  group("ensureTermCount", () {
    test("Ensure term count for a non-group subject without an exam", () {
      final year = Year();
      year.termCount = 3;
      year.validatedYear = 5;
      final subject = Subject("Subject1", 3)..terms = [Term(), Term()];

      subject.ensureTermCount(year: year);

      expect(subject.terms.length, equals(3));
      expect(subject.terms.where((term) => term.isExam).isEmpty, isTrue);
    });

    test("Ensure term count for a non-group subject with an exam", () {
      final year = Year();
      year.termCount = 3;
      year.validatedYear = 1;
      final subject = Subject("Subject2", 3)..terms = [Term(), Term()];

      subject.ensureTermCount(year: year);

      expect(subject.terms.length, equals(4));
      expect(subject.terms.where((term) => term.isExam).length, equals(1));
      expect(subject.terms.last.isExam, isTrue);
    });

    test("Ensure term count for a non-group subject with an exam present", () {
      final year = Year();
      year.termCount = 3;
      year.validatedYear = 1;
      final subject = Subject("Subject2", 3)..terms = [Term(), Term(), Term(isExam: true)];

      subject.ensureTermCount(year: year);

      expect(subject.terms.length, equals(4));
      expect(subject.terms.where((term) => term.isExam).length, equals(1));
      expect(subject.terms.last.isExam, isTrue);
    });

    test("Ensure term count for a group subject", () {
      final year = Year();
      year.termCount = 3;
      year.validatedYear = 5;
      final childSubject = Subject("ChildSubject", 3)..terms = [Term(), Term()];
      final groupSubject = Subject("GroupSubject", 3, isGroup: true)..children = [childSubject];

      groupSubject.ensureTermCount(year: year);

      expect(childSubject.terms.length, equals(3));
      expect(childSubject.terms.where((term) => term.isExam).isEmpty, isTrue);
    });

    test("Ensure term count for a non-group subject with excess terms with exam", () {
      final year = Year();
      year.termCount = 3;
      year.validatedYear = 1;
      final subject = Subject("Subject3", 3)..terms = [Term(), Term(), Term(), Term(), Term(isExam: true)];

      subject.ensureTermCount(year: year);

      expect(subject.terms.length, equals(4));
      expect(subject.terms.where((term) => term.isExam).length, equals(1));
    });

    test("Ensure term count for a non-group subject with fewer terms with exam", () {
      final year = Year();
      year.termCount = 3;
      year.validatedYear = 1;
      final subject = Subject("Subject4", 3)..terms = [Term(), Term(isExam: true)];

      subject.ensureTermCount(year: year);

      expect(subject.terms.length, equals(4));
      expect(subject.terms.where((term) => term.isExam).length, equals(1));
      expect(subject.terms.last.isExam, isTrue);
    });
  });
}
