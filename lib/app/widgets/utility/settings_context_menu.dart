// A context menu for right-clicking SettingsWidgets
import 'package:adifferentwaytoplay/app/widgets/utility/text.dart';
import 'package:adifferentwaytoplay/domain/constants.dart';
import 'package:adifferentwaytoplay/domain/entities/setting.dart';
import 'package:native_context_menu/native_context_menu.dart' as NCM;
import 'package:flutter/material.dart';
import 'package:adifferentwaytoplay/data/utils/utils.dart';

class SettingsContextMenu extends StatefulWidget {
  Setting setting;
  Widget settingsWidget;
  void Function({
    String? title,
    String? description,
    bool enabled,
    String? sortType,
  }) updateSettingValue;
  void Function(Setting setting) deleteSetting;

  SettingsContextMenu({
    super.key,
    required this.setting,
    required this.settingsWidget,
    required this.updateSettingValue,
    required this.deleteSetting,
  });

  @override
  State<SettingsContextMenu> createState() => _SettingsContextMenuState();
}

class _SettingsContextMenuState extends State<SettingsContextMenu> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    titleController.text = widget.setting.title;
    descriptionController.text = widget.setting.description ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NCM.ContextMenuRegion(
      menuItems: [
        NCM.MenuItem(
            title: "Title",
            onSelected: () async {
              await showDialog(
                context: context,
                builder: ((context) => AlertDialog(
                      title: TextField(controller: titleController),
                    )),
              );
              setState(() {
                widget.setting.title = titleController.text;
              });
              widget.updateSettingValue(title: titleController.text);
            }),
        NCM.MenuItem(
            title: "Description",
            onSelected: () async {
              await showDialog(
                context: context,
                builder: ((context) => AlertDialog(
                      title: TextField(controller: descriptionController),
                    )),
              );
              setState(() {
                widget.setting.title = descriptionController.text;
              });
              widget.updateSettingValue(
                  description: descriptionController.text);
            }),
        NCM.MenuItem(
          title: "Disable/Enable",
          items: [
            NCM.MenuItem(
              title: "Enable",
              onSelected: () {
                setState(() {
                  widget.setting.enabled = true;
                });
                widget.updateSettingValue(enabled: true);
              },
            ),
            NCM.MenuItem(
              title: "Disable",
              onSelected: () {
                setState(() {
                  widget.setting.enabled = false;
                });
                widget.updateSettingValue(enabled: false);
              },
            ),
          ],
        ),
        NCM.MenuItem(
          title: "Sort Property",
          items: [
            NCM.MenuItem(
              title: InputTypes.button.toString(),
              onSelected: () {
                setState(() {
                  widget.setting.sortProperty = SortProperties.button;
                });
              },
            ),
            NCM.MenuItem(
              title: InputTypes.trigger.toString(),
              onSelected: () {
                setState(() {
                  widget.setting.sortProperty = SortProperties.trigger;
                });
              },
            ),
            NCM.MenuItem(
              title: InputTypes.stick.toString(),
              onSelected: () {
                setState(() {
                  widget.setting.sortProperty = SortProperties.stick;
                });
              },
            ),
            NCM.MenuItem(
              title: 'none',
              onSelected: () {
                setState(() {
                  widget.setting.sortProperty = null;
                });
              },
            ),
          ],
        ),
        NCM.MenuItem(
          title: "Delete",
          onSelected: () async {
            await showDialog(
              context: context,
              builder: ((context) => AlertDialog(
                    title: const TextWidget(
                        text: "Are you sure you want to delete this setting?"),
                    content: IconButton(
                      onPressed: () {
                        widget.deleteSetting(widget.setting);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  )),
            );
          },
        ),
      ],
      child: widget.settingsWidget,
    );
  }
}
