import 'package:adifferentwaytoplay/data/constants.dart';
import 'package:adifferentwaytoplay/data/utils/initial_vars.dart';
import 'package:adifferentwaytoplay/domain/constants.dart';
import 'package:adifferentwaytoplay/domain/entities/setting.dart';
import 'package:adifferentwaytoplay/domain/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'dart:io';
import 'package:adifferentwaytoplay/domain/entities/gamepad.dart';
import 'package:adifferentwaytoplay/domain/entities/player.dart';
import 'package:adifferentwaytoplay/domain/entities/character.dart';
import 'package:adifferentwaytoplay/domain/entities/program.dart';
import 'package:adifferentwaytoplay/domain/entities/gamemode.dart';
import 'package:adifferentwaytoplay/domain/entities/team.dart';
import 'package:logging/logging.dart';

// A simple class for getting the current instance of Isar
// Or creating a new instance
class Storage {
  Logger logger = Logger("Data logger");
  late Future<Isar> isarDB;

  Storage() {
    isarDB = openDB();
  }

  /// A function for resetting the database
  /// Mainly used for testing
  Future<void> reset() async {
    if (Isar.instanceNames.isEmpty) {
      Isar isarDB = await Isar.open(
        [
          CharacterSchema,
          GamemodeSchema,
          GamepadSchema,
          PlayerSchema,
          ProgramSchema,
          TeamSchema,
          SettingSchema,
        ],
        name: "test",
        inspector: true,
      );
      await isarDB.clear();
    }
  }

  Future<Isar> openDB() async {
    // Alternatively opens an Isar DB in test mode for testing purposes
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      if (Isar.instanceNames.isEmpty) {
        // Create collection
        Isar isarDB = await Isar.open(
          [
            CharacterSchema,
            GamemodeSchema,
            GamepadSchema,
            PlayerSchema,
            ProgramSchema,
            TeamSchema,
            SettingSchema,
          ],
          name: "test",
          inspector: true,
        );
        // NOTE: this is really stupid code
        // Close the db; a fresh db is used for each required test
        // await isarDB.close(deleteFromDisk: true);
        // isarDB = await Isar.open(
        //   [
        //     CharacterSchema,
        //     GamemodeSchema,
        //     GamepadSchema,
        //     PlayerSchema,
        //     ProgramSchema,
        //     TeamSchema,
        //     SettingSchema,
        //   ],
        //   name: "test",
        //   inspector: true,
        // );
        // When writing the characters after clearing the database
        // The IsarLink move error occurs

        isarDB.writeTxnSync(() {
          /// Default mock data is used for gamepads and players
          for (Character character in characters) {
            isarDB.characters.putSync(character);
          }
        });
        isarDB.writeTxnSync(() {
          // Write Gamepads
          for (Gamepad gamepad in testGamepads) {
            isarDB.gamepads.putSync(gamepad);
          }
        });
        // for (List<Setting> settingList in programSettings) {
        //   for (Setting setting in settingList) {
        //     isarDB.settings.putSync(setting);
        //   }
        // }
        isarDB.writeTxnSync(() {
          // Write app settings
          for (Setting setting in appSettings) {
            isarDB.settings.putSync(setting);
          }
        });
        isarDB.writeTxnSync(() {
          // MIOP program (no settings)
          isarDB.programs.putSync(ProgramData.MIOP);
          ProgramData.TC.settings.addAll(TCsettings);
          isarDB.programs.putSync(ProgramData.TC);
          // ProgramData.TC.settings.saveSync();
          ProgramData.TC.settings.addAll(RCsettings);
          isarDB.programs.putSync(ProgramData.RC);
          ProgramData.TC.settings.addAll(FCsettings);
          isarDB.programs.putSync(ProgramData.FC);
        });
        // Write Gamemode
        // for (Gamemode gamemode in gamemodes) {
        //   await ProgramData.TC.settings.save();
        //   isarDB.gamemodes.put(gamemode);
        // }
        isarDB.writeTxnSync(() {
          GamemodeData.freeForAll.settings.addAll([
            Setting()
              ..title = GamemodeOptionsValues.score.toString()
              ..mapValues = 50
              ..settingsWidget = SettingsWidgets.numField,
            Setting()
              ..title = GamemodeOptionsValues.weightedPrograms.toString()
              ..mapValues = true
              ..settingsWidget = SettingsWidgets.boolDropdown,
          ]);
          isarDB.gamemodes.putSync(GamemodeData.freeForAll);
          GamemodeData.tagBattle.settings.addAll([
            Setting()
              ..title = GamemodeOptionsValues.score.toString()
              ..mapValues = 40
              ..settingsWidget = SettingsWidgets.numField,
            Setting()
              ..title = GamemodeOptionsValues.weightedPrograms.toString()
              ..mapValues = true
              ..settingsWidget = SettingsWidgets.boolDropdown,
          ]);
          isarDB.gamemodes.putSync(GamemodeData.tagBattle);
        });
        isarDB.writeTxnSync(() {
          int i = 0;
          for (Player player in testPlayers) {
            player.character.value = characters[i];
            switch (i) {
              case 0:
                player.gamepad.value = testGamepads[i];
                break;
              case 1:
                player.gamepad.value = testGamepads[i];
                break;
              case 2:
                player.gamepad.value = testGamepads[i];
                break;
              case 3:
                player.gamepad.value = testGamepads[i];
                break;
              case 4:
                player.gamepad.value = testGamepads[0];
                break;
              case 5:
                player.gamepad.value = testGamepads[1];
                break;
            }
            player.program.value = programs[0];
            if (i <= 3) {
              player.gamemode.value = GamemodeData.tagBattle;
              if (i < 2) {
                player.team.value = teams[0];
              } else {
                player.team.value = teams[1];
              }
            } else {
              player.gamemode.value = GamemodeData.freeForAll;
            }
            isarDB.players.putSync(player);
            i++;
          }
        });
        return isarDB;
      }
      return Future.value(Isar.getInstance("test"));
    } else {
      // Create collection
      if (Isar.instanceNames.isEmpty) {
        Isar isarDB = await Isar.open(
          [
            CharacterSchema,
            GamemodeSchema,
            GamepadSchema,
            PlayerSchema,
            ProgramSchema,
            TeamSchema,
            SettingSchema,
          ],
          name: "real",
          // TODO: disable inspection once app is completed
          inspector: true,
        );
        // Test query to check if the database is empty
        // NOTE: If you ever need to clear the db for any reason, uncomment the following line
        // await isarDB.clear();
        if (isarDB.characters.where().anyAge().findAllSync().isEmpty) {
          // Write initial data if the database is empty
          await isarDB.writeTxn(() async {
            for (Character character in characters) {
              await isarDB.characters.put(character);
            }
          });

          await isarDB.writeTxn(() async {
            // Write Settings and Programs in tandem
            // TC settings and program
            for (Setting setting in TCsettings) {
              isarDB.settings.put(setting);
              ProgramData.TC.settings.add(setting);
            }
            isarDB.programs.put(ProgramData.TC);
            // RC settings and program
            for (Setting setting in RCsettings) {
              isarDB.settings.put(setting);
              ProgramData.RC.settings.add(setting);
            }
            isarDB.programs.put(ProgramData.RC);
            // FC settings and program
            for (Setting setting in FCsettings) {
              isarDB.settings.put(setting);
              ProgramData.FC.settings.add(setting);
            }
            await isarDB.programs.put(ProgramData.FC);
            // MIOP program (no settings)
            await isarDB.programs.put(ProgramData.MIOP);
            // Write Teams
            for (Team team in teams) {
              await isarDB.teams.put(team);
            }
            // Write app settings
            for (Setting setting in appSettings) {
              isarDB.settings.put(setting);
            }
            // Write Gamemode
            for (Gamemode gamemode in gamemodes) {
              await isarDB.gamemodes.put(gamemode);
            }
          });
          return isarDB;
        }
      }
      return Future.value(Isar.getInstance("real"));
    }
  }

  // Migrating ALL CRUD functions to one utility class
  /// Retrieve character by name, age, or color
  ///
  /// Each gallery has a 'by name' search bar w/ dropdown character selection
  Future<List<Character>> getCharacter(Map<String, dynamic> index) async {
    try {
      Isar db = await isarDB;
      switch (index.entries.first.key) {
        case "name":
          return await db.characters
              .filter()
              .nameStartsWith(index.entries.first.value)
              .findAll();
        case "age":
          return await db.characters
              .filter()
              .ageEqualTo(index.entries.first.value)
              .findAll();
        case "color":
          return await db.characters
              .filter()
              .colorEqualTo(index.entries.first.value)
              .findAll();
        default:
          return [];
      }
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Returns a sorted list based on specified character indexes
  /// This is primarily a SORTING function
  ///
  /// In the GUI these are movable (orderable) checkboxes
  /// Maps have the index name and whether to sort increasing or decreasing
  /// (as well as intrinsically have an order property due to the list)
  Future<List<Character>> getCharacterList(
      List<Map<String, Sort>> indexes) async {
    try {
      Isar db = await isarDB;
      // Default case; sort by id
      if (indexes.isEmpty) {
        List<Character> characters = await db.characters.where().findAll();
        return characters;
      }
      // Building a dynamic query to execute based on the user sorting preferences
      List<SortProperty> sortProperties = [];
      for (Map<String, Sort> index in indexes) {
        switch (index.entries.first.key) {
          case "name":
            sortProperties.add(SortProperty(
                property: 'name', sort: index.entries.first.value));
            break;
          case "age":
            sortProperties.add(
                SortProperty(property: 'age', sort: index.entries.first.value));
            break;
          case "color":
            sortProperties.add(SortProperty(
                property: 'color', sort: index.entries.first.value));
            break;
          case "matchesPlayed":
            sortProperties.add(SortProperty(
                property: 'matchesPlayed', sort: index.entries.first.value));
            break;
          case "matchesWon":
            sortProperties.add(SortProperty(
                property: 'matchesWon', sort: index.entries.first.value));
            break;
        }
      }
      List<Character> characters = await db.characters
          .buildQuery<Character>(sortBy: sortProperties)
          .findAll();
      return characters;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Update all given characters
  Future<List<Character?>?> updateCharacters(List<Character> characters) async {
    try {
      Isar db = await isarDB;
      List<int> ids = await db.characters.putAll(characters);
      return await db.characters.getAll(ids);
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Deletes all characters with the selected ids
  Future<int?> deleteCharacters(List<int> characterIds) async {
    try {
      Isar db = await isarDB;
      int numCharactersDeleted = await db.characters.deleteAll(characterIds);
      return numCharactersDeleted;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Retrieve gamemode by name index (maintains same structure
  /// to make it easy to add new indexes)
  Future<List<Gamemode>> getGamemode(Map<String, dynamic> index) async {
    try {
      Isar db = await isarDB;
      switch (index.entries.first.key) {
        case "name":
          return await db.gamemodes
              .filter()
              .nameStartsWith(index.entries.first.value)
              .findAll();
        default:
          return [];
      }
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Returns a sorted list based on specified gamemode indexes
  Future<List<Gamemode>> getGamemodeList(
      List<Map<String, Sort>> indexes) async {
    try {
      Isar db = await isarDB;
      // Default case; sort by id
      if (indexes.isEmpty) {
        List<Gamemode> gamemodes = await db.gamemodes.where().findAll();
        return gamemodes;
      }
      // Building a dynamic query to execute based on the user sorting preferences
      List<SortProperty> sortProperties = [];
      for (Map<String, Sort> index in indexes) {
        switch (index.entries.first.key) {
          case "name":
            sortProperties.add(SortProperty(
                property: 'name', sort: index.entries.first.value));
            break;
          case "times played":
            sortProperties.add(SortProperty(
                property: 'timesPlayed', sort: index.entries.first.value));
            break;
        }
      }
      List<Gamemode> gamemodes = await db.gamemodes
          .buildQuery<Gamemode>(sortBy: sortProperties)
          .findAll();
      return gamemodes;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Update all given gamemodes
  Future<List<Gamemode?>?> updateGamemodes(List<Gamemode> gamemodes) async {
    try {
      Isar db = await isarDB;
      List<int> ids = await db.gamemodes.putAll(gamemodes);
      return await db.gamemodes.getAll(ids);
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Deletes all gamemodes with the selected ids
  Future<int?> deleteGamemodes(List<int> gamemodeIds) async {
    try {
      Isar db = await isarDB;
      int numGamemodesDeleted = await db.gamemodes.deleteAll(gamemodeIds);
      return numGamemodesDeleted;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Retrieve gamepads by connected or color index
  Future<List<Gamepad>> getGamepad(Map<String, dynamic> index) async {
    try {
      Isar db = await isarDB;
      switch (index.entries.first.key) {
        case "connected":
          return await db.gamepads
              .filter()
              .connectedEqualTo(index.entries.first.value)
              .findAll();
        case "color":
          return await db.gamepads
              .filter()
              .colorEqualTo(index.entries.first.value)
              .findAll();
      }
      return [];
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Returns a sorted list based on specified gamepad indexes
  Future<List<Gamepad>> getGamepadList(List<Map<String, Sort>> indexes) async {
    try {
      Isar db = await isarDB;
      // Default case; sort by id
      if (indexes.isEmpty) {
        List<Gamepad> gamepads = await db.gamepads.where().findAll();
        return gamepads;
      }
      // Building a dynamic query to execute based on the user sorting preferences
      List<SortProperty> sortProperties = [];
      for (Map<String, Sort> index in indexes) {
        switch (index.entries.first.key) {
          case "connected":
            sortProperties.add(SortProperty(
                property: 'connected', sort: index.entries.first.value));
            break;
          case "color":
            sortProperties.add(SortProperty(
                property: 'color', sort: index.entries.first.value));
            break;
        }
      }
      List<Gamepad> gamepads = await db.gamepads
          .buildQuery<Gamepad>(sortBy: sortProperties)
          .findAll();
      return gamepads;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Update all given gamepads
  Future<List<Gamepad?>?> updateGamepads(List<Gamepad> gamepads) async {
    try {
      Isar db = await isarDB;
      List<int> ids = await db.gamepads.putAll(gamepads);
      return await db.gamepads.getAll(ids);
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Deletes all gamepads with the selected ids
  Future<int?> deleteGamepads(List<int> gamepadIds) async {
    try {
      Isar db = await isarDB;
      int numGamepadsDeleted = await db.gamepads.deleteAll(gamepadIds);
      return numGamepadsDeleted;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Retrieve player by gamepad index, character name, program abbreviation,
  /// team name, color, or score
  Future<List<Player>> getPlayer(Map<String, dynamic> index) async {
    try {
      Isar db = await isarDB;
      switch (index.entries.first.key) {
        case "character name":
          return await db.players.filter().character(((character) {
            return character.nameEqualTo(index.entries.first.value);
          })).findAll();
        case "index":
          return await db.players.filter().gamepad(((gamepad) {
            return gamepad.indexEqualTo(index.entries.first.value);
          })).findAll();
        case "abbreviation":
          return await db.players.filter().program(((program) {
            return program.abbreviationEqualTo(index.entries.first.value);
          })).findAll();
        case "teamName":
          return await db.players.filter().team(((team) {
            return team.nameEqualTo(index.entries.first.value);
          })).findAll();
        case "color":
          return await db.players
              .filter()
              .colorEqualTo(index.entries.first.value)
              .findAll();
        case "score":
          return await db.players
              .filter()
              .scoreEqualTo(index.entries.first.value)
              .findAll();
        default:
          return [];
      }
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Returns a sorted list based on specified player indexes
  Future<List<Player>> getPlayerList(List<Map<String, Sort>> indexes) async {
    try {
      Isar db = await isarDB;
      // Default case; sort by id
      if (indexes.isEmpty) {
        List<Player> players = await db.players.where().findAll();
        return players;
      }
      // Building a dynamic query to execute based on the user sorting preferences
      // TODO: the issue w/ a dynamic query here is the SortProperty is a link...
      // 'name' itself is ambiguous; how would I do character.name or team.name
      // TODO: I used psuedocode for this, this implementation likely won't work
      List<SortProperty> sortProperties = [];
      for (Map<String, Sort> index in indexes) {
        switch (index.entries.first.key) {
          case "characterName":
            sortProperties.add(SortProperty(
                property: 'character.name', sort: index.entries.first.value));
            break;
          case "index":
            sortProperties.add(SortProperty(
                property: 'gamepad.index', sort: index.entries.first.value));
            break;
          case "abbreviation":
            sortProperties.add(SortProperty(
                property: 'program.abbreviation',
                sort: index.entries.first.value));
            break;
          case "teamName":
            sortProperties.add(SortProperty(
                property: 'team.name', sort: index.entries.first.value));
            break;
          case "color":
            sortProperties.add(SortProperty(
                property: 'color', sort: index.entries.first.value));
            break;
          case "score":
            sortProperties.add(SortProperty(
                property: 'score', sort: index.entries.first.value));
            break;
        }
      }
      List<Player> players =
          await db.players.buildQuery<Player>(sortBy: sortProperties).findAll();
      return players;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Update all given players
  Future<List<Player?>?> updatePlayers(List<Player> players) async {
    try {
      Isar db = await isarDB;
      List<int> ids = await db.players.putAll(players);
      return await db.players.getAll(ids);
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Deletes all players with the selected ids
  Future<int?> deletePlayers(List<int> playerIds) async {
    try {
      Isar db = await isarDB;
      int numPlayersDeleted = await db.players.deleteAll(playerIds);
      return numPlayersDeleted;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Retrieve program by abbreviation index
  Future<List<Program>> getProgram(Map<String, dynamic> index) async {
    try {
      Isar db = await isarDB;
      switch (index.entries.first.key) {
        case "abbreviation":
          return await db.programs
              .filter()
              .nameStartsWith(index.entries.first.value)
              .findAll();
        default:
          return [];
      }
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Returns a sorted list based on specified program indexes
  Future<List<Program>> getProgramList(List<Map<String, Sort>> indexes) async {
    try {
      Isar db = await isarDB;
      // Default case; sort by id
      if (indexes.isEmpty) {
        List<Program> programs = await db.programs.where().findAll();
        return programs;
      }
      // Building a dynamic query to execute based on the user sorting preferences
      List<SortProperty> sortProperties = [];
      for (Map<String, Sort> index in indexes) {
        switch (index.entries.first.key) {
          case "abbreviation":
            sortProperties.add(SortProperty(
                property: 'abbreviation', sort: index.entries.first.value));
            break;
          case "name":
            sortProperties.add(SortProperty(
                property: 'name', sort: index.entries.first.value));
            break;
        }
      }
      List<Program> programs = await db.programs
          .buildQuery<Program>(sortBy: sortProperties)
          .findAll();
      return programs;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Update all given programs
  Future<List<Program?>?> updatePrograms(List<Program> programs) async {
    try {
      Isar db = await isarDB;
      List<int> ids = await db.programs.putAll(programs);
      return await db.programs.getAll(ids);
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Deletes all programs with the selected ids
  Future<int?> deletePrograms(List<int> programIds) async {
    try {
      Isar db = await isarDB;
      int numDeletedPrograms = await db.programs.deleteAll(programIds);
      return numDeletedPrograms;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Retrieve settings by title and program or gamemode
  Future<List<Setting?>> getSetting(Map<String, dynamic> index) async {
    try {
      Isar db = await isarDB;
      if (index.entries.length != 2) {
        return [];
      }
      List<FilterCondition> filterConditions = [];
      for (MapEntry<String, dynamic> entry in index.entries) {
        switch (entry.key) {
          case "program":
            // TODO: as always, not sure how to access properties of THE linked value
            filterConditions.add(
              FilterCondition(
                type: FilterConditionType.contains,
                property: 'program.value.abbreviation',
                value1: entry.value,
                include1: true,
                include2: false,
                caseSensitive: false,
              ),
            );
            break;
          case "gamemode":
            filterConditions.add(
              FilterCondition(
                type: FilterConditionType.contains,
                property: 'gamemode.value.title',
                value1: entry.value,
                include1: true,
                include2: false,
                caseSensitive: false,
              ),
            );
            break;
          case "title":
            filterConditions.add(
              FilterCondition(
                type: FilterConditionType.contains,
                property: 'title',
                value1: entry.value,
                include1: true,
                include2: false,
                caseSensitive: false,
              ),
            );
            break;
          default:
            return [];
        }
      }
      return await db.settings
          .buildQuery<Setting>(
            filter: FilterGroup(
                filters: filterConditions, type: FilterGroupType.and),
          )
          .findAll();
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Returns a sorted list based on specified setting indexes
  Future<List<Setting>> getSettingList(List<Map<String, Sort>> indexes) async {
    try {
      Isar db = await isarDB;
      // Default case; sort by id
      if (indexes.isEmpty) {
        List<Setting> settings = await db.settings.where().findAll();
        return settings;
      }
      // Building a dynamic query to execute based on the user sorting preferences
      List<SortProperty> sortProperties = [];
      for (Map<String, Sort> index in indexes) {
        switch (index.entries.first.key) {
          case "program":
            sortProperties.add(SortProperty(
                property: 'program.value.abbreviation',
                sort: index.entries.first.value));
            break;
          case "title":
            sortProperties.add(SortProperty(
                property: 'title.name', sort: index.entries.first.value));
            break;
          case "gamemode":
            sortProperties.add(SortProperty(
                property: 'gamemode.value.title',
                sort: index.entries.first.value));
            break;
          case "enabled":
            sortProperties.add(SortProperty(
                property: 'enabled', sort: index.entries.first.value));
            break;
        }
      }
      List<Setting> settings = await db.settings
          .buildQuery<Setting>(sortBy: sortProperties)
          .findAll();
      return settings;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Update all given programs
  Future<List<Setting?>?> updateSettings(List<Setting> settings) async {
    try {
      Isar db = await isarDB;
      List<int> ids = await db.settings.putAll(settings);
      return await db.settings.getAll(ids);
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Deletes all programs with the selected ids
  Future<int?> deleteSettings(List<int> settingIds) async {
    try {
      Isar db = await isarDB;
      int numDeletedSettings = await db.settings.deleteAll(settingIds);
      return numDeletedSettings;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Retrieve team by name, color, or score
  /// The score index is primarily for determining a winner
  Future<List<Team>> getTeam(Map<String, dynamic> index) async {
    try {
      Isar db = await isarDB;
      switch (index.entries.first.key) {
        case "name":
          return await db.teams
              .filter()
              .nameStartsWith(index.entries.first.value)
              .findAll();
        case "color":
          return await db.teams
              .filter()
              .colorEqualTo(index.entries.first.value)
              .findAll();
        default:
          return [];
      }
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Returns a sorted list based on specified team indexes
  Future<List<Team>> getTeamList(List<Map<String, Sort>> indexes) async {
    try {
      Isar db = await isarDB;
      // Default case; sort by id
      if (indexes.isEmpty) {
        List<Team> teams = await db.teams.where().findAll();
        return teams;
      }
      // Building a dynamic query to execute based on the user sorting preferences
      List<SortProperty> sortProperties = [];
      for (Map<String, Sort> index in indexes) {
        switch (index.entries.first.key) {
          case "name":
            sortProperties.add(SortProperty(
                property: 'name', sort: index.entries.first.value));
            break;
          case "color":
            sortProperties.add(SortProperty(
                property: 'color', sort: index.entries.first.value));
            break;
          case "score":
            sortProperties.add(SortProperty(
                property: 'score', sort: index.entries.first.value));
            break;
          case "matchesPlayed":
            sortProperties.add(SortProperty(
                property: 'matchesPlayed', sort: index.entries.first.value));
            break;
          case "matchesWon":
            sortProperties.add(SortProperty(
                property: 'matchesWon', sort: index.entries.first.value));
            break;
        }
      }
      List<Team> teams =
          await db.teams.buildQuery<Team>(sortBy: sortProperties).findAll();
      return teams;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return [];
    }
  }

  /// Update all given characters
  Future<List<Team?>?> updateTeams(List<Team> teams) async {
    try {
      Isar db = await isarDB;
      List<int> ids = await db.teams.putAll(teams);
      return await db.teams.getAll(ids);
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }

  /// Deletes all teams with the selected ids
  Future<int?> deleteTeams(List<int> teamIds) async {
    try {
      Isar db = await isarDB;
      int numTeamsDeleted = await db.teams.deleteAll(teamIds);
      return numTeamsDeleted;
    } catch (e, stacktrace) {
      logger.warning("Whoops, that's an error! \n $e \n $stacktrace");
      return null;
    }
  }
}

Storage storage = Storage();

/*
class ProgramRunner extends Flython {
  List<Player>? players;
  ProgramRunner({this.players});

  // Runs the DWTP script with the player parameters
  // TODO: change ```true``` to false once done debugging
  Flython flython = Flython()
    ..initialize('python.exe', 'assets/scripts/DWTP.py', true);

  Future<dynamic> runPrograms() async {
    if (players == null) {
      throw Exception("players cannot be null when running the program");
    }
    List<Map<String, dynamic>> command = [];
    for (Player player in players!) {
      command.add(player.toMap());
    }
    dynamic output = await runCommand(command);
  }

  Future<bool> checkToken(id) async {
    // Verify if the token is a valid text channel id
    List<Map<String, dynamic>> command = [];
    command.add({'program': 'utils.py', 'function': 'checkToken', 'id': id});
    bool output = await runCommand(command);
    return output;
  }
}
*/