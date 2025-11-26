import 'package:flutter/material.dart';
import 'package:converter/converter.dart';
import 'package:mudkip_frontend/core/constants.dart';
import 'package:mudkip_frontend/core/settings.dart';
import 'package:mudkip_frontend/mudkipc.dart';

// ignore: must_be_immutable
class ScaleIndicator extends StatefulWidget {
  ScaleIndicator(
      {super.key,
      required this.pokemonHeight,
      required this.pokemonWeight,
      required this.imageUrl});

  double pokemonHeight = 2;
  double pokemonWeight = 2;
  String imageUrl = "";

  @override
  State<ScaleIndicator> createState() => _ScaleIndicatorState();
}

class _ScaleIndicatorState extends State<ScaleIndicator> {
  static const double averageMaleHeight = 171.45;
  static const double averageFemaleHeight = 162.56;
  // static const double minHeight = 54;
  // static const double maxHeight = 272;
  static const double defaultChartHeight = 500;
  Future<double> get humanHeight async {
    if (await Settings.heightChartGender == HeightChartGender.male) {
      return averageMaleHeight;
    }
    return averageFemaleHeight;
  }

  Future<String> getHeightChartGenderImage() async {
    if (await Settings.heightChartGender == HeightChartGender.male) {
      return 'assets/images/artwork/male.png';
    } else {
      return 'assets/images/artwork/female.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
            future: calulatePokemonAndHumanHeight(),
            builder: (context, asyncSnapshot) {
              if (!asyncSnapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final pokemonHeight = asyncSnapshot.data!.$1;
              final humanHeight = asyncSnapshot.data!.$2;
              final tallest =
                  humanHeight > pokemonHeight ? humanHeight : pokemonHeight;
              final pokemonScale = pokemonHeight / tallest;
              final humanScale = humanHeight / tallest;
              MudkiPC.talker.info(asyncSnapshot.data);
              MudkiPC.talker.info(
                  "Pokemon Scale: $pokemonScale Human Scale: $humanScale");
              return LayoutBuilder(builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder(
                        future: getHeightChartGenderImage(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          return Image.asset(
                            snapshot.data!,
                            height: constraints
                                    .constrainHeight(defaultChartHeight) *
                                humanScale,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.medium,
                          );
                        }),
                    Image.asset(
                      widget.imageUrl,
                      height: constraints.constrainHeight(defaultChartHeight) *
                          pokemonScale,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                    )
                  ],
                );
              });
            }),
        const SizedBox(
            width: 500,
            child: Divider(
              height: 20,
              thickness: 2,
            )),
        FutureBuilder(
            future: formatLabels(),
            builder: (context, asyncSnapshot) {
              if (!asyncSnapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monitor_weight_outlined, size: 40.0),
                  const SizedBox(width: 10),
                  Text(asyncSnapshot.data!.$1,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(width: 20),
                  const Icon(Icons.height_rounded, size: 40.0),
                  Text(asyncSnapshot.data!.$2,
                      style: Theme.of(context).textTheme.headlineMedium),
                ],
              );
            })
      ],
    );
  }

  Future<(double, double)> calulatePokemonAndHumanHeight() async {
    return (await calulatePokemonHeight(), await calulateHumanHeight());
  }

  Future<double> calulateHumanHeight() async {
    return await humanHeight;
  }

  Future<double> calulatePokemonHeight() async {
    return Length(widget.pokemonHeight, "dm").valueIn("cm").toDouble();
  }

  Future<(String, String)> formatLabels() async {
    return (
      await formatWeightLabel(Mass(widget.pokemonWeight, "kg")),
      await formatHeightLabel(Length(widget.pokemonHeight, "dm"))
    );
  }

  Future<String> formatWeightLabel(Mass weight) async {
    if (await Settings.heightChartFormat == HeightChartFormat.imperial) {
      return "${weight.valueIn("lb").truncate()} lb";
    } else if (await Settings.heightChartFormat == HeightChartFormat.metric) {
      return "${weight.valueIn("kg").truncate()} kg";
    }
    return "";
  }

  Future<String> formatHeightLabel(Length height) async {
    if (await Settings.heightChartFormat == HeightChartFormat.imperial) {
      return "${height.valueIn("ft").truncate()}' ${Length(height.valueIn("ft") - height.valueIn("ft").truncate(), "ft").valueIn("in").truncate()}\" ft";
    } else if (await Settings.heightChartFormat == HeightChartFormat.metric) {
      if (height.valueIn("m") < 1) {
        return "${height.valueIn("cm").truncate()} cm";
      }
      return "${height.valueIn("m").toStringAsFixed(2)} m";
    }
    return "";
  }
}
