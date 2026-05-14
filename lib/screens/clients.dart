import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../core/platform_capabilities.dart';
import '../provider.dart';
import '../data/database.dart';
import '../core/qr_scan.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Клиенты'),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(clientsProvider), 
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_outlined, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Ошибка: $error', textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.refresh(clientsProvider),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
        data: (clients) {
          if (clients.isEmpty) {
            return const _EmptyClientsState();
          }
          return _ClientsListView(clients: clients);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => _ShowAddClientDialog(
            onManual: () => _showManualClientInputDialog(context,ref),
            onPasteLink: () => _showClientPasteLinkDialog(context, ref), 
            onScanQr: () => _showClientQrCode(context,ref),
          ),
        ),
        tooltip: 'Добавить клиента',
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}

class _EmptyClientsState extends StatelessWidget {
  const _EmptyClientsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.devices_outlined, size: 72, color: Colors.grey),
          SizedBox(height: 24),
          Text(
            'Нет клиентов',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Нажмите + для добавления клиента',
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}

class _ClientsListView extends StatelessWidget {
  final List<Client> clients;
  const _ClientsListView({required this.clients});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return _ClientCard(client: client);
      },
    );
  }
}

class _ClientCard extends ConsumerWidget {
  final Client client;
  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            client.name.substring(0, 1).toUpperCase(),
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          client.ulid,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showEditClientDialog(context, ref, client),
        onLongPress: () => _showClientActions(context, ref, client),
      ),
    );
  }
}

class _ShowAddClientDialog extends StatelessWidget {
  final VoidCallback onManual;
  final VoidCallback onPasteLink;
  final VoidCallback onScanQr;

  const _ShowAddClientDialog({
    required this.onManual,
    required this.onPasteLink,
    required this.onScanQr,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Добавить клиента"),
      contentPadding: const EdgeInsets.all(12),
      content: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text("Ввести данные вручную"),
              onTap: () {
                Navigator.pop(context);
                onManual();
              },
            ),
            ListTile(
              leading: const Icon(Icons.paste_outlined),
              title: const Text("Вставить ссылку из буфера"),
              onTap: () {
                Navigator.pop(context);
                onPasteLink();
              },
            ),
            if (PlatformCapabilities.supportsQrScanning)
              ListTile(
                leading: const Icon(Icons.qr_code_outlined),
                title: const Text("Сканировать QR"),
                onTap: () {
                  Navigator.pop(context);
                  onScanQr();
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          label: const Text("Отмена"),
          icon: Icon(Icons.close),
        ),
      ],
    );
  }
}

void _showManualClientInputDialog(BuildContext context, WidgetRef ref) {
  final nameCtrl = TextEditingController();
  final ulidCtrl = TextEditingController();
  String? error;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Добавить клиента'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Имя устройства',
                      hintText: 'Например: Мой телефон',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                    onChanged: (_) => setState(() => error = null),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ulidCtrl,
                    decoration: InputDecoration(
                      labelText: 'ULID',
                      hintText: 'XXXXXXXXXXXXXXXXXXXXXXXXXX',
                      border: const OutlineInputBorder(),
                      errorText: error != null && ulidCtrl.text.isNotEmpty ? error : null,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9A-HJKMNP-TV-Z]', caseSensitive: false),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != value.toUpperCase()) {
                        ulidCtrl.value = ulidCtrl.value.copyWith(
                          text: value.toUpperCase(),
                          selection: TextSelection.collapsed(offset: value.length),
                        );
                      }
                      setState(() => error = null);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () async => _saveClient(
                  context, ref, nameCtrl.text.trim(), ulidCtrl.text.trim(),
                  (msg) => setState(() => error = msg),
                  () => Navigator.pop(context),
                ),
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showClientPasteLinkDialog(BuildContext context, WidgetRef ref) {
  final nameCtrl = TextEditingController();
  final linkCtrl = TextEditingController();
  String? error;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Вставить ссылку'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Имя устройства',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: linkCtrl,
                    decoration: InputDecoration(
                      labelText: 'otpauth:// ссылка',
                      border: const OutlineInputBorder(),
                      errorText: error,
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.paste_outlined),
                    label: const Text('Вставить из буфера'),
                    onPressed: () async {
                      final clipboard = await Clipboard.getData('text/plain');
                      final text = clipboard?.text;
                      setState(() => error = null);
                      if (text != null && text.contains('otpauth://')) {
                        linkCtrl.text = text;
                        final extracted = AppDatabase.extractUlidFromOtpauth(text);
                        if (extracted != null && nameCtrl.text.isEmpty) {
                          nameCtrl.text = 'Клиент ${extracted.substring(0, 4)}';
                        }
                      } else {
                        setState(() => error = 'Неверный формат ссылки');
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () async {
                  final link = linkCtrl.text.trim();
                  final name = nameCtrl.text.trim();
                  if (!link.contains('otpauth://')) {
                    setState(() => error = 'Ссылка должна начинаться с otpauth://');
                    return;
                  }
                  final ulid = AppDatabase.extractUlidFromOtpauth(link);
                  if (ulid == null) {
                    setState(() => error = 'Не удалось извлечь ULID из ссылки');
                    return;
                  }
                  await _saveClient(
                    context, ref,
                    name.isEmpty ? 'Клиент ${ulid.substring(0, 4)}' : name,
                    ulid,
                    (msg) => setState(() => error = msg),
                    () => Navigator.pop(context),
                  );
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showClientQrCode(BuildContext context, WidgetRef ref) async {
  final scannedText = await scanQRCode(context);
  if (scannedText == null || !context.mounted) return;

  final extractedUlid = AppDatabase.extractUlidFromOtpauth(scannedText);
  if (extractedUlid == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось распознать ULID в QR-коде'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
    return;
  }

  // Показываем результат с кнопками Сохранить / Отмена
  if (!context.mounted) return;
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('QR-код распознан'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ULID:'),
            const SizedBox(height: 4),
            SelectableText(
              extractedUlid,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Нажмите "Сохранить", чтобы добавить клиента с этим ULID',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final defaultName = 'Клиент ${extractedUlid.substring(0, 4)}';
              await _showManualClientInputDialogWithPrefilled(
                context, ref, defaultName, extractedUlid,
              );
            },
            child: const Text('Сохранить'),
          ),
        ],
      );
    },
  );
}

Future<void> _saveClient(
  BuildContext context,
  WidgetRef ref,
  String name,
  String ulid,
  Function(String) onError,
  VoidCallback onSuccess,
) async {
  if (name.isEmpty || ulid.isEmpty) {
    onError('Заполните имя и ULID');
    return;
  }
  if (!AppDatabase.isValidName(name)) {
    onError('Имя содержит недопустимые символы');
    return;
  }
  if (!AppDatabase.isValidUlid(ulid)) {
    onError('Неверный формат ULID (26 символов, 0-9A-HJKMNP-TV-Z)');
    return;
  }

  final db = ref.read(dbProvider);
  final result = await db.addClient(name, ulid);

  if (context.mounted) {
    if (result == 0) {
      ref.invalidate(clientsProvider);
      onSuccess();
    } else if (result == 1) {
      onError('Ошибка валидации данных');
    } else if (result == 2) {
      onError('Такой ULID уже существует');
    }
  }
}

Future<void> _showManualClientInputDialogWithPrefilled(
  BuildContext context,
  WidgetRef ref,
  String prefilledName,
  String prefilledUlid,
) async {
  final nameCtrl = TextEditingController(text: prefilledName);
  final ulidCtrl = TextEditingController(text: prefilledUlid);
  String? error;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Подтвердите данные'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Имя устройства',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                    onChanged: (_) => setState(() => error = null),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ulidCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ULID',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    enabled: false,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () async => _saveClient(
                  context, ref, nameCtrl.text.trim(), ulidCtrl.text.trim(),
                  (msg) => setState(() => error = msg),
                  () => Navigator.pop(context),
                ),
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showClientActions(BuildContext context, WidgetRef ref, Client client) {

  showModalBottomSheet(
    context: context,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Редактировать'),
          onTap: () {
            Navigator.pop(context);
            _showEditClientDialog(context, ref, client);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text('Удалить', style: TextStyle(color: Colors.red)),
          onTap: () async {
            Navigator.pop(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Удалить клиента?'),
                content: Text('Вы уверены, что хотите удалить "${client.name}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Отмена'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Удалить'),
                  ),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              final db = ref.read(dbProvider);
              await db.removeClient(client.ulid);
              if (context.mounted) {
                ref.invalidate(clientsProvider);
              }
            }
          },
        ),
      ],
    ),
  );
}

void _showEditClientDialog(BuildContext context, WidgetRef ref, Client client) {
  final nameCtrl = TextEditingController(text: client.name);
  String? error;
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Редактировать клиента'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Имя устройства',
                      border: const OutlineInputBorder(),
                      errorText: error != null && nameCtrl.text.isNotEmpty ? error : null,
                    ),
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                    ],
                    onChanged: (_) => setState(() => error = null),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: TextEditingController(text: client.ulid),
                    decoration: const InputDecoration(
                      labelText: 'ULID (не изменяется)',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    enabled: false,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: 'monospace',
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    'ULID является уникальным идентификатором и не может быть изменён',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () async {
                  final newName = nameCtrl.text.trim();
                  
                  if (newName.isEmpty) {
                    setState(() => error = 'Введите имя устройства');
                    return;
                  }
                  if (!AppDatabase.isValidName(newName)) {
                    setState(() => error = 'Имя содержит недопустимые символы');
                    return;
                  }
                  
                  final db = ref.read(dbProvider);
                  final result = await db.updateClient(client.ulid, newName);
                  
                  if (context.mounted) {
                    if (result == 0) {
                      Navigator.pop(context);
                      ref.invalidate(clientsProvider);
                    } else if (result == 1) {
                      setState(() => error = 'Ошибка валидации данных');
                    } else if (result == 2) {
                      setState(() => error = 'Клиент не найден (возможно, уже удалён)');
                    }
                  }
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      );
    },
  );
}