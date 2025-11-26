import 'package:flutter/material.dart';
import 'package:mudkip_frontend/core/reyveld.dart';
import 'package:mudkip_frontend/mudkipc.dart';
import 'package:mudkip_frontend/widgets/scale_indicator.dart';

class SpeciesView extends StatelessWidget {
  final int id;
  const SpeciesView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Species"),
      ),
      body: FutureBuilder(
          future: Reyveld.run("""
local db = SQLDatabase.open("${MudkiPC.databasePath}")
local id = $id

local pokemonBaseInfo = db.select([[SELECT * FROM pokemon_species
INNER JOIN pokemon ON pokemon.species_id = pokemon_species.id
WHERE pokemon_species.id = ?;]],
    { id }).first()

pokemonBaseInfo.names = db.select(
    [[SELECT pokemon_species_names.name, pokemon_species_names.local_language_id FROM pokemon_species_names
WHERE pokemon_species_names.pokemon_species_id = ?;]],
    { id })

pokemonBaseInfo.flavorText = db.select(
    [[SELECT pokemon_species_flavor_text.version_id, pokemon_species_flavor_text.language_id, pokemon_species_flavor_text.flavor_text FROM pokemon_species_flavor_text
WHERE pokemon_species_flavor_text.species_id = ?;]],
    { id })

local baseStats = db.select(
    [[SELECT pokemon_stats.stat_id, pokemon_stats.base_stat FROM pokemon_stats WHERE pokemon_stats.pokemon_id = ?  ]],
    { id }
)

pokemonBaseInfo.baseStats = {
    hp = baseStats.firstWhere(function(s) return s.stat_id == 1 end),
    attack = baseStats.firstWhere(function(s) return s.stat_id == 2 end),
    defense = baseStats.firstWhere(function(s) return s.stat_id == 3 end),
    specialAttack = baseStats.firstWhere(function(s) return s.stat_id == 4 end),
    specialDefense = baseStats.firstWhere(function(s) return s.stat_id == 5 end),
    speed = baseStats.firstWhere(function(s) return s.stat_id == 6 end)
}

return pokemonBaseInfo
""").then((e) async => await e.future),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final species = snapshot.data as Map;
            return SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card.outlined(
                        // The pokemon's sprite.
                        // TODO: Add shiny variant sprites to files and add functionlity to switch between them.
                        // TODO: Add regional forms support.
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: 200,
                              width: 200,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image(
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.none,
                                    image: AssetImage(
                                        "assets/images/sprites/$id.png")),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Card.outlined(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                  (species["names"] as List).firstWhere(
                                      (element) =>
                                          element["local_language_id"] ==
                                          9)["name"],
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("ID: $id",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                  ])
                            ],
                          ),
                        ),
                      ),
                      Card.outlined(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                  ((species["flavorText"] as List).firstWhere(
                                          (element) =>
                                              element["language_id"] ==
                                              9)["flavor_text"] as String)
                                      .split("\n")
                                      .map((e) => e.trim())
                                      .join(" "),
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                        ),
                      ),
                      FittedBox(
                        child: Card.outlined(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: ScaleIndicator(
                                  pokemonHeight:
                                      (species["height"] as int).toDouble(),
                                  pokemonWeight:
                                      (species["weight"] as int).toDouble(),
                                  imageUrl: "assets/images/sprites/$id.png"),
                            ),
                          ),
                        ),
                      ),
                    ]));
          }),
    );
  }
}
