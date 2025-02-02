import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pokemon_app/model/pokemon_model.dart';
import 'package:pokemon_app/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:pokemon_app/utils/file_system_utils.dart';
import 'package:pokemon_app/utils/permission_utils.dart';
import 'package:pokemon_app/widgets/pokemon_images_slider.dart';

class PokemonDetails extends StatelessWidget {
  const PokemonDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final pokemon = arguments['pokemon'];
    final captures = arguments['captures'];

    return Scaffold(
        appBar: AppBar(
          title: const Text('Pokemon Details'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _PokemonHeader(pokemon: pokemon, captures: captures),
              Text(
                capitalize(pokemon.name),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Weight: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${pokemon.weight} Pounds",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Stats: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              buildStatRow(pokemon.stats),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Types",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PokemonDetailsBody(pokemon: pokemon),
            ],
          ),
        ));
  }
}

class _PokemonHeader extends StatelessWidget {
  final Pokemon pokemon;
  final List<String> captures;

  const _PokemonHeader({
    required this.pokemon,
    required this.captures,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.green,
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Stack(
          children: [
            Center(
                child: captures.isEmpty
                    ? Image(
                        image: NetworkImage(pokemon.sprites.frontDefault),
                        fit: BoxFit.fill,
                        height: 160,
                        width: 180,
                      )
                    : PokemonImagesSlider(imagesPath: captures!)),
            Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt_rounded),
                  color: Colors.white,
                  iconSize: 50,
                  onPressed: () async {
                    bool canUseCamera = await checkAndAskCameraPermission();
                    if (!canUseCamera) return;
                    final picker = ImagePicker();
                    final XFile? pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile == null) return;

                    Directory capturesDirectory =
                        await FileSystemUtils.createLocalDirectory(
                            'pokemon_${pokemon.id}');

                    String fileName = basename(pickedFile.path);

                    String destinationFile =
                        '${capturesDirectory.path}$fileName';

                    File sourceFile = File(pickedFile.path);
                    File destination = File(destinationFile);

                    await destination
                        .writeAsBytes(await sourceFile.readAsBytes());

                    debugPrint("Saved Image Path: $destinationFile");
                    debugPrint(
                        "Saved Image Size: ${await File(destinationFile).length()} bytes");
                  },
                ))
          ],
        ));
  }
}

class PokemonDetailsBody extends StatelessWidget {
  const PokemonDetailsBody({
    super.key,
    required this.pokemon,
  });

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.50,
      width: MediaQuery.of(context).size.width,
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 2,
          ),
          itemCount: pokemon.types.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image(
                    image: AssetImage(getAssetImage(
                      'pokemon',
                      pokemon.types[index].type.name,
                    )),
                    fit: BoxFit.fill,
                    height: 80,
                    width: 80,
                  ),
                  Text(
                    capitalize(pokemon.types[index].type.name),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

Widget buildStatRow(List<StatElement> stats) {
  return Column(
    children: stats.map((stat) {
      return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image(
                  width: 25,
                  height: 25,
                  image: AssetImage(getAssetImage('stats',
                      stat.stat.name.replaceFirst(RegExp(r'(\-)'), '_'))),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  capitalize(stat.stat.name),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              stat.baseStat.toString(),
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
