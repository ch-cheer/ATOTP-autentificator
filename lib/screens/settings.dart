import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text("Тема"),
              subtitle: Text(
                _getThemeLabel(themeMode),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              trailing: _ThemeToggleSwitch(
                currentMode: themeMode,
                onChanged: (mode) => notifier.setTheme(mode),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("О приложении"),
              subtitle: const Text("Версия \"Диплом\" 0.9.1"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'ATOTP autentificator',
                  applicationVersion: '0.9.1',
                  children: const [
                    Text("Приложение для генерации ATOTP кодов"),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

String _getThemeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.dark:
    return 'Тёмная';
    case ThemeMode.light:
    return 'Светлая';
    case ThemeMode.system:
    return 'Системная';
  }
}

class _ThemeToggleSwitch extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeToggleSwitch({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.dark,
          label: Icon(Icons.nightlight),
          tooltip: 'Тёмная', 
          ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Icon(Icons.wb_sunny),
          tooltip: 'Светлая',
        ),
        ButtonSegment(
          value: ThemeMode.system,
          label: Icon(Icons.settings),
          tooltip: 'Как в системе',
        ),
      ],
      selected: {currentMode},
      onSelectionChanged: (selected) {
        if (selected.isNotEmpty) {
          onChanged(selected.first);
        }
      },
      showSelectedIcon: false,
    );
  }
}