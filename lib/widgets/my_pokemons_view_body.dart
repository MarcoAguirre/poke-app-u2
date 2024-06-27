import 'package:flutter/material.dart';
import 'package:pokemon_app/view_model/my_pokemons_view_model.dart';
import 'package:pokemon_app/widgets/pokemon_card.dart';
import 'package:provider/provider.dart';

class MyPokemonsViewBody extends StatefulWidget {

  const MyPokemonsViewBody({
    super.key
  });

  @override
  State<MyPokemonsViewBody> createState() => _MyPokemonsViewBodyState();
}

class _MyPokemonsViewBodyState extends State<MyPokemonsViewBody> {
  late MyPokemonsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<MyPokemonsViewModel>(context);
    return viewModel.loadingPokemonsCaptures
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: viewModel.pokemonsCaptures.length,
              itemBuilder: (context, index) {
                return PokemonCard(
                  pokemon: viewModel.pokemonsCaptures[index].pokemon,
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
  }
}
