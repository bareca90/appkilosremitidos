/* import 'package:appkilosremitidos/core/providers/kilos_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'edit_kilos_screen.dart';
import 'widgets/kilos_card.dart';

class KilosListScreen extends StatelessWidget {
  const KilosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kilosProvider = Provider.of<KilosProvider>(context);

    return Column(
      children: [
        if (kilosProvider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(kilosProvider.errorMessage!),
              backgroundColor: Colors.amber[100],
              side: BorderSide.none,
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: kilosProvider.kilosList.length,
            itemBuilder: (context, index) {
              final kilos = kilosProvider.kilosList[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditKilosScreen(kilos: kilos),
                  ),
                ),
                child: KilosCard(kilos: kilos),
              );
            },
          ),
        ),
      ],
    );
  }
}
 */
