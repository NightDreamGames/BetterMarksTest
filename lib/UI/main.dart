import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Calculations/manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Translation/i18n.dart';

import '../Misc/serialization.dart';
import '../Calculations/manager.dart';
import 'popup_sub_menu.dart';
import 'subject_route.dart';

void main() {
  // Compatibility.periodPreferences();

  /*switch (Preferences.getPreference("dark_theme", "auto")) {
            case "on":
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
                break;
            case "off":
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
                break;
            default:
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM);
                } else {
                    AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
                }
                break;
        }*/

  Manager.init();

  // Serialization.Deserialize();

  /*if (Preferences.getPreference("isFirstRun", "true") == "true") {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubjectRoute()),
    );
  }*/

  //Compatibility.init();

  Manager.calculate();

  runApp(MaterialApp(
    localizationsDelegates: const [
      I18nDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: I18nDelegate.supportedLocals,
    home: const Scaffold(
      body: HomePage(),
    ),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  void rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      rebuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          actions: <Widget>[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More options',
              onSelected: (value) {
                print(value);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubjectRoute()),
                );
              },
              itemBuilder: (BuildContext context) {
                List<String> a = [];

                switch (Manager.maxTerm) {
                  case 2:
                    a = [
                      I18n.of(context).semester_1,
                      I18n.of(context).semester_2,
                      I18n.of(context).year,
                    ];
                    break;
                  case 3:
                    a = [
                      I18n.of(context).trimester_1,
                      I18n.of(context).trimester_2,
                      I18n.of(context).trimester_3,
                      I18n.of(context).year,
                    ];
                    break;
                }

                List<PopupMenuEntry<String>> entries = [];
                if (Manager.maxTerm != 1) {
                  entries.add(
                    PopupSubMenuItem<String>(
                      title: I18n.of(context).select_term,
                      items: a,
                      onSelected: (value) async {
                        if (value == I18n.of(context).semester_1 || value == I18n.of(context).trimester_1) {
                          Manager.currentTerm = 0;
                        } else if (value == I18n.of(context).semester_2 || value == I18n.of(context).trimester_2) {
                          Manager.currentTerm = 1;
                        } else if (value == I18n.of(context).trimester_3) {
                          Manager.currentTerm = 2;
                        } else if (value == I18n.of(context).year) {
                          Manager.currentTerm = -1;
                        }

                        rebuild();
                      },
                    ),
                  );
                }
                entries.add(PopupSubMenuItem<String>(
                  title: I18n.of(context).sort_by,
                  items: [
                    I18n.of(context).az,
                    I18n.of(context).grade,
                  ],
                  onSelected: (value) async {
                    final prefs = await SharedPreferences.getInstance();

                    if (value == I18n.of(context).az) {
                      prefs.setInt("sort_mode1", 0);
                    } else if (value == I18n.of(context).grade) {
                      prefs.setInt("sort_mode1", 1);
                    }

                    Manager.sortAll();
                    rebuild();
                  },
                ));
                entries.add(PopupMenuItem<String>(
                  child: Text(I18n.of(context).settings),
                  onTap: () {},
                ));

                return entries;
              },
            ),
          ],
          expandedHeight: 150,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: FutureBuilder(
              builder: (context, snapshot) {
                return Text(
                  snapshot.data.toString(),
                  style: const TextStyle(fontSize: 24),
                );
              },
              future: getTitle(context),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                height: 54,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            I18n.of(context).average,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            Manager.getCurrentTerm().getResult(),
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 0, color: Colors.black, thickness: 1),
              ),
            ],
          ),
        ),
        const ListWidget(),
      ],
    );
  }
}

class ListWidget extends StatelessWidget {
  const ListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ListRow(index);
        },
        addAutomaticKeepAlives: true,
        childCount: Manager.getCurrentTerm().subjects.length,
      ),
    );
  }
}

class ListRow extends StatelessWidget {
  final int index;
  const ListRow(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: SubjectRoute(),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            color: Colors.white,
            height: 54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        Manager.getCurrentTerm().subjects[index].name,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        Manager.getCurrentTerm().subjects[index].getResult(),
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(right: 24)),
                      const Icon(
                        Icons.navigate_next,
                        size: 24.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/*void onResume() {
  super.onResume();

  adaptView();
  updateView();
}

void adaptView() {
  setTitle();

  binding = MainSubjectActivityBinding.inflate(getLayoutInflater());
  setContentView(binding.getRoot());

  binding.fab.setVisibility(View.GONE);
  binding.bonus.setVisibility(View.GONE);

  Toolbar toolbar = binding.toolbar;
  setSupportActionBar(toolbar);
}

void updateView() {
  Manager.sortAll();

  Term p = Manager.getCurrentTerm();

  RecyclerView recyclerView = binding.recyclerView;
  recyclerView.setLayoutManager(new LinearLayoutManager(this));

  CustomRecyclerViewAdapter adapter =
      new CustomRecyclerViewAdapter(this, p.getSubjects(), p.getGrades(), 0);

  adapter.setClickListener(this);
  recyclerView.setAdapter(adapter);

  binding.textView3
      .setText((p.result == -1) ? "-" : Calculator.format(p.result));
}*/

Future<String> getTitle(var context) async {
  final prefs = await SharedPreferences.getInstance();
  switch (Manager.currentTerm) {
    case 0:
      switch (Manager.maxTerm) {
        case 3:
          return I18n.of(context).trimester_1;
        case 2:
          return I18n.of(context).semester_1;
        case 1:
          return I18n.of(context).year;
      }
      break;
    case 1:
      switch (Manager.maxTerm) {
        case 3:
          return I18n.of(context).trimester_2;
        case 2:
          return I18n.of(context).semester_2;
      }
      break;
    case 2:
      return I18n.of(context).trimester_3;
    case -1:
      return I18n.of(context).year;
  }

  return I18n.of(context).app_name;
}
