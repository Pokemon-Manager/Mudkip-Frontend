import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  AppShellState createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final showRail = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      appBar: AppBar(title: const Text('MudkiPC'), actions: [
        if (showRail)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 400,
              child: Placeholder(),
            ),
          )
        else
          const Placeholder(),
        const SizedBox(width: 20),
      ]),
      drawer: Drawer(
          width: 300,
          child: ListView(
            children: [
              ListTile(
                title: const Text("Settings"),
                leading: const Icon(Icons.settings),
                onTap: () {
                  context.push("/settings");
                },
              ),
              ListTile(
                title: const Text("About"),
                leading: const Icon(Icons.info),
                onTap: () {
                  context.push("/about");
                },
              ),
              ListTile(
                  title: const Text("Debug"),
                  leading: const Icon(Icons.bug_report_rounded),
                  onTap: () {
                    context.push("/debug");
                  }),
            ],
          )),
      bottomNavigationBar: showRail
          ? const SizedBox()
          : BottomNavBar(
              index: _selectedIndex,
              onDestinationSelected: (int index) {
                _selectedIndex = index;
                context.go(Destinations.getPath(index));
              },
            ),
      body: Row(
        children: [
          if (showRail)
            SideNavRail(
              index: _selectedIndex,
              onDestinationSelected: (int index) {
                _selectedIndex = index;
                context.go(Destinations.getPath(index));
              },
            ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class BottomNavBar extends StatelessWidget {
  BottomNavBar(
      {super.key, required this.onDestinationSelected, required this.index});
  int index;

  Function onDestinationSelected;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      elevation: 80.0,
      onTap: (int index) {
        onDestinationSelected(index);
      },
      items: Destinations.getDestinationsForBar(),
    );
  }
}

// ignore: must_be_immutable
class SideNavRail extends StatelessWidget {
  SideNavRail(
      {super.key, required this.onDestinationSelected, required this.index});
  int index;

  Function onDestinationSelected;
  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: index,
      onDestinationSelected: (int index) {
        onDestinationSelected(index);
      },
      labelType: NavigationRailLabelType.all,
      destinations: Destinations.getDestinationsForRail(),
    );
  }
}

class Destination {
  String label;
  IconData icon;
  String path;

  Destination({required this.label, required this.icon, required this.path});
}

class PCDestination extends Destination {
  PCDestination() : super(label: 'PC', icon: Icons.home, path: '/pc');
}

class PokeDexDestination extends Destination {
  PokeDexDestination()
      : super(
            label: 'PokéDex',
            icon: Icons.phone_android_rounded,
            path: '/pokedex');
}

class Destinations {
  static List<Destination> destinations = [
    PCDestination(),
    PokeDexDestination(),
  ];

  static List<NavigationRailDestination> getDestinationsForRail() {
    List<NavigationRailDestination> destinationsWigets = [];
    for (Destination destination in destinations) {
      destinationsWigets.add(NavigationRailDestination(
          icon: Icon(destination.icon), label: Text(destination.label)));
    }
    return destinationsWigets;
  }

  static List<BottomNavigationBarItem> getDestinationsForBar() {
    List<BottomNavigationBarItem> destinationsWigets = [];
    for (Destination destination in destinations) {
      destinationsWigets.add(BottomNavigationBarItem(
          icon: Icon(destination.icon, size: 25.0), label: destination.label));
    }
    return destinationsWigets;
  }

  static String getPath(int index) => destinations[index].path;
}
