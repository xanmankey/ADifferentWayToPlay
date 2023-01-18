// A toolbar supporting various drag and drop flutter widgets
// to aid in program and gamemode creation

import 'package:adifferentwaytoplay/app/widgets/settings/settings_field.dart';
import 'package:adifferentwaytoplay/app/widgets/settings/settings_card.dart';
import 'package:adifferentwaytoplay/app/widgets/settings/settings_dropdown.dart';
import 'package:adifferentwaytoplay/app/widgets/settings/settings_checkbox.dart';
import 'package:adifferentwaytoplay/data/utils/utils.dart';
import 'package:adifferentwaytoplay/domain/entities/settings.dart';
import 'package:adifferentwaytoplay/domain/utils/utils.dart';
import 'package:flutter/material.dart';

// On using the creator bar to drag and drop a settings widget,
// a settings object is CREATED.
// The settings widgets (and thus, the settings objects) are only created if the creator bar is OPENED
// for efficiency's sake.
// The CreatorBar is only available for programs and gamemodes.
class CreatorBar extends StatefulWidget {
  Setting setting;
  CreatorBar({super.key, required this.setting});

  @override
  State<CreatorBar> createState() => _CreatorBarState();
}

class _CreatorBarState extends State<CreatorBar> {
  @override
  Widget build(BuildContext context) {
    bool visible = false;
    IconData arrowIcon = Icons.arrow_drop_up;
    List<Widget> items = [];
    return Visibility(
      visible: visible,
      replacement: GestureDetector(
        child: Icon(arrowIcon),
        onTap: () => setState(() {
          visible = !visible;
          if (visible) {
            Map<SettingsWidgets, Setting> settings =
                createSettings(SettingsWidgets.values);
            items = [
              SettingsCheckbox(setting: settings[SettingsWidgets.checkbox]!),
              SettingsCard(setting: settings[SettingsWidgets.card]!),
              SettingsField(
                  setting: settings[SettingsWidgets.numField]!,
                  settingsWidget: SettingsWidgets.numField),
              SettingsDropdown(
                  setting: settings[SettingsWidgets.textField]!,
                  items: Items.inputs),
              SettingsDropdown(
                  setting: settings[SettingsWidgets.inputTypesDropdown]!,
                  items: Items.inputTypes),
              SettingsDropdown(
                  setting: settings[SettingsWidgets.filtersDropdown]!,
                  items: Items.filters),
              SettingsField(
                  setting: settings[SettingsWidgets.textField]!,
                  settingsWidget: SettingsWidgets.textField),
            ];
          }
        }),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          for (Widget widget in items) {
            return widget;
          }
          throw Exception('No SettingsWidgets were created for the create bar');
        },
        itemCount: items.length,
        separatorBuilder: (context, index) {
          for (int i = 0; i < index; i++) {
            return const Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10));
          }
          throw Exception('Padding failed to be created for the create bar');
        },
      ),
    );
  }
}