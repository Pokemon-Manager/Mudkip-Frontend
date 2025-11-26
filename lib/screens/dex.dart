import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mudkip_frontend/core/reyveld.dart';
import 'package:mudkip_frontend/mudkipc.dart';

class DexScreen extends StatelessWidget {
  const DexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Reyveld.run(
                """local db = SQLDatabase.open("${MudkiPC.databasePath}")
local lang = 9
return db.select([[SELECT pokemon_species.id, pokemon_species_names.name FROM pokemon_species
    INNER JOIN pokemon_species_names ON pokemon_species.id = pokemon_species_names.pokemon_species_id
    WHERE pokemon_species_names.local_language_id = ?;]],
    { lang })
        """)
            .then((e) async => await e.future),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          final names = snapshot.data as List;
          return ListView.builder(
              itemExtent: 100,
              itemCount: names.length,
              itemBuilder: (context, index) => Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.push("/view/species", extra: index + 1);
                      },
                      child: Row(
                        children: [
                          SizedBox(
                              width: 96,
                              height: 96,
                              child: Image(
                                  filterQuality: FilterQuality.none,
                                  image: AssetImage(
                                      "assets/images/sprites/${index + 1}.png"))),
                          Expanded(
                            child: Text(names[index]["name"].toString()),
                          ),
                        ],
                      ),
                    ),
                  ));
        });
  }
}
