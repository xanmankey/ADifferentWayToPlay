import 'package:adifferentwaytoplay/app/pages/exception_view.dart';
import 'package:adifferentwaytoplay/app/provider/dwtp_provider.dart';
import 'package:adifferentwaytoplay/app/widgets/utility/text.dart';
import 'package:adifferentwaytoplay/data/utils/utils.dart';
import 'package:adifferentwaytoplay/domain/entities/gamemode.dart';
import 'package:adifferentwaytoplay/domain/entities/player.dart';
import 'package:adifferentwaytoplay/domain/entities/program.dart';
import 'package:adifferentwaytoplay/domain/entities/setting.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

/// Each player will have an individual "ready-up" button to start gameplay
/// Or perhaps I just make automatic checks to see if players are ready or not...
/// Once all players have "readyed-up", provider emits a ready message, and the
/// ready button displays
/// ```
///
/// ```
class PlayerReadyButton extends StatefulWidget {
  Player player;
  bool ready;
  Gamemode gamemode;
  PlayerReadyButton({
    super.key,
    required this.player,
    required this.ready,
    required this.gamemode,
  });

  @override
  State<PlayerReadyButton> createState() => _PlayerReadyButtonState();
}

class _PlayerReadyButtonState extends State<PlayerReadyButton> {
  late List<Setting> individualSettings;

  @override
  void initState() {
    individualSettings = storage.isarDB.settings
        .where()
        .individualEqualTo(true)
        .filter()
        .program((program) => program
            .abbreviationEqualTo(widget.player.program.value!.abbreviation))
        .findAllSync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: const Text("Ready up"),
      value: widget.ready,
      onChanged: (value) {
        // Check if the player is allowed to ready up
        // Simply get all individual settings and check if they are defined or not
        // Check if the setting is filled out
        if ((individualSettings).every((element) => element.ready == true)) {
          setState(() {
            widget.player.ready = true;
          });
          checkReady();
        }
        // Otherwise return null
        return;
      },
    );
  }
}

/// Checks if all the players are ready; if yes, sends a changeNotifier
/// to trigger the ready_button
bool checkReady() {
  if (dwtpProvider.players.every((element) => element.ready)) {
    return true;
  }
  return false;
}