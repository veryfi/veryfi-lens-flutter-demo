import 'package:flutter/material.dart';

class SettingsPanel {
  static void showSettingsPanel(BuildContext context, Map<String, bool> preferences) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
              expand: false,
              builder: (_, controller) {
                return Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Settings',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Color(0xFF171C3A)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Material(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                            color: const Color(0xFFE9ECE4),
                            elevation: 2.0,
                            child: Column(
                              children: [
                                const ListTile(
                                  leading: Icon(Icons.settings,
                                      size: 24.0, color: Color(0xFF171C3A)),
                                  title: Text(
                                    'General Settings',
                                    style: TextStyle(color: Color(0xFF171C3A)),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    controller: controller,
                                    itemCount: preferences.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      String key =
                                      preferences.keys.elementAt(index);
                                      return _customSwitchListTile(
                                        key,
                                        preferences[key]!,
                                            (bool value) {
                                          setState(() {
                                            preferences[key] = value;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static Widget _customSwitchListTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF171C3A)),
      ),
      trailing: Transform.scale(
        scale: 0.7,
        child: Switch(
          value: value,
          onChanged: (newValue) {
            onChanged(newValue);
          },
          activeColor: const Color(0xFF171C3A),
        ),
      ),
      onTap: () {
        onChanged(!value);
      },
    );
  }
}

