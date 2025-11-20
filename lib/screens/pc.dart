import 'package:flutter/material.dart';

import '../core/reyveld.dart';

class PCScreen extends StatelessWidget {
  const PCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Reyveld.statusChange,
        initialData: EventType.disconnected,
        builder: (context, snapshot) {
          switch (snapshot.data!) {
            case EventType.disconnected || EventType.connectedUnsecured:
              return Center(
                  child: Column(children: [
                Text(
                  "Not Connected to Reyveld.",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  "Make sure Reyveld is running.",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ]));
            case EventType.connectedSecured:
              return const Placeholder();
          }
        });
  }
}
