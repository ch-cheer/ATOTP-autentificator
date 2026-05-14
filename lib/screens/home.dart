import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base32/base32.dart';
import 'package:go_router/go_router.dart';
import '../provider.dart';
import '../data/database.dart';
import '../core/platform_capabilities.dart';
import '../core/qr_scan.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Генератор ATOTP кодов'),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(servicesProvider),
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: servicesAsync.when(
        data: (ATOTPData) {
          if (ATOTPData.isEmpty) {
            return const _EmptyServicesState();
          }
          return _ServicesListView(atotpData: ATOTPData);
        }, 
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_outlined),
              const SizedBox(height: 16),
              Text('Ошибка $error', textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.refresh(servicesProvider),
                child: const Text('Повторить'),
                ),
            ],
          ),
        ), 
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context, 
          builder: (_) => _ShowAddServiceDialog(
            onManual: () => _showServiceDialog(context,ref),
            onPasteLink: () => _showServicePasteLinkDialog(context,ref),
            onScanQr: () => _scanServiceQrCode(context,ref),
          ),
        ),
        tooltip: 'Добавить сервис',
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}

class _EmptyServicesState extends ConsumerWidget {
  const _EmptyServicesState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isClientsEmptyAsync = ref.watch(isClientsEmptyProvider);

    return isClientsEmptyAsync.when(
      data: (isClientsEmpty) => _EmptyServicesContent(
        isClientsEmpty: isClientsEmpty,
      ),
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (_, _) => const _EmptyServicesContent(
        isClientsEmpty: false,
      ),
    );
  }
}

class _EmptyServicesContent extends StatelessWidget {
  const _EmptyServicesContent({
    required this.isClientsEmpty,
  });

  final bool isClientsEmpty;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isClientsEmpty) ...[
            const Icon(Icons.devices_outlined, size: 72, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Для добавления сервиса лучше зарегистрировать клиента',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Для регистрации клиента перейдите на соседнюю вкладку',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/clients'),
              icon: const Icon(Icons.arrow_forward_ios_outlined),
              label: const Text('Перейти к клиентам'),
            ),
          ] else ...[
            const Icon(Icons.add_moderator_outlined, size: 72, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Сервисы пока не добавлены',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Нажмите кнопку + внизу, чтобы добавить сервис',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _ServicesListView extends StatelessWidget {
  final List<ATOTPData> atotpData;
  const _ServicesListView({required this.atotpData});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: atotpData.length,
      itemBuilder: (context, index) {
        final service = atotpData[index];
        return _ServiceCard(service: service);
      },
    );
  }
}

class _ServiceCard extends ConsumerStatefulWidget {
  final ATOTPData service;

  const _ServiceCard({required this.service});

  @override
  ConsumerState<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends ConsumerState<_ServiceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final label = service.label.trim();
    final firstLetter =
        label.isNotEmpty ? label.substring(0, 1).toUpperCase() : '?';
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                firstLetter,
                style: TextStyle(color: colorScheme.onPrimaryContainer),
              ),
            ),
            title: Text(
              label.isNotEmpty ? label : 'Без названия',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              service.issuer.isNotEmpty
                  ? service.issuer
                  : 'Издатель не указан',
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            onLongPress: () => _showServicesAction(context, ref, service),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _AddressInputSection(
              service: service,
              onManualInput: () => _showManualAddressInputDialog(context, ref, service),
              onPasteLink: () => _showAddressPasteLinkDialog(context, ref, service),
              onScanQr: () => _scanAddressQrCode(context, ref, service),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressInputSection extends StatelessWidget {
  final ATOTPData service;
  final VoidCallback onManualInput;
  final VoidCallback onPasteLink;
  final VoidCallback onScanQr;

  const _AddressInputSection({
    required this.service,
    required this.onManualInput,
    required this.onPasteLink,
    required this.onScanQr,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 8),
          Text(
            'Ввод адреса',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Text(
              'Пока адрес не задан. Выберите способ ввода ниже.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _AddressActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Ввести вручную',
                  onTap: onManualInput,
                ),
              ),
              Expanded(
                child: _AddressActionButton(
                  icon: Icons.link_outlined,
                  label: 'Вставить ссылку',
                  onTap: onPasteLink,
                ),
              ),
              if (PlatformCapabilities.supportsQrScanning)
                Expanded(
                  child: _AddressActionButton(
                    icon: Icons.qr_code_outlined,
                    label: 'Сканировать QR',
                    onTap: onScanQr,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddressActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

//Delete
Future<void> _showStubDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    ),
  );
}

class _ShowAddServiceDialog extends StatelessWidget {
  final VoidCallback onManual;
  final VoidCallback onPasteLink;
  final VoidCallback onScanQr;

  const _ShowAddServiceDialog({
    required this.onManual,
    required this.onPasteLink,
    required this.onScanQr,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Добавить сервис"),
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

Future<void> _showServicePasteLinkDialog(BuildContext context, WidgetRef ref) async {
  final clipboardData = await Clipboard.getData('text/plain');
  final input = clipboardData?.text?.trim();

  if (input == null || input.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Буфер обмена пуст')),
      );
    }
    return;
  }

  final parsed = AppDatabase.extractServiceFromOtpauth(input);
  
  if (parsed == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось распознать ссылку ATOTP')),
      );
    }
    return;
  }

  if (context.mounted) {
    _showServiceDialog(
      context,
      ref,
      prefilledData: parsed,
    );
  }
}

Future<void> _scanServiceQrCode(BuildContext context, WidgetRef ref) async {
  final scannedText = await scanQRCode(context);
  if (scannedText == null || !context.mounted) return;

  final parsed = AppDatabase.extractServiceFromOtpauth(scannedText);
  if (parsed == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось распознать ссылку ATOTP в QR-коде'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
    return;
  }

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
            Text('Название: ${parsed.label}', style: const TextStyle(fontWeight: FontWeight.w500)),
            if (parsed.issuer.isNotEmpty) Text('Издатель: ${parsed.issuer}'),
            
            const SizedBox(height: 12),

            const Text('Параметры:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('Алгоритм: ${parsed.algorithm}'),
            Text('Символов: ${parsed.digits}'),
            Text('Период: ${parsed.period} с'),
            Text('Адрес: ${_addressOptionLabel(parsed.addressOption)}'),

            const SizedBox(height: 16),
            const Text(
              'Нажмите "Добавить", чтобы создать сервис с этими параметрами.\nВы сможете изменить значения перед сохранением.',
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
            onPressed: () {
              Navigator.pop(context);
              _showServiceDialog(context, ref, prefilledData: parsed);
            },
            child: const Text('Добавить'),
          ),
        ],
      );
    },
  );
}

String _addressOptionLabel(int option) {
  switch (option) {
    case 1: return 'Только IP';
    case 2: return 'Только URL';
    case 3: return 'IP и URL';
    default: return 'Неизвестно';
  }
}

Future<void> _showManualAddressInputDialog(
  BuildContext context,
  WidgetRef ref,
  ATOTPData service,
) async {
  await _showStubDialog(
    context,
    title: 'Ввести вручную',
    message: 'Ручной ввод адреса для "${service.label}" пока не реализован.',
  );
}

Future<void> _showAddressPasteLinkDialog(
  BuildContext context,
  WidgetRef ref,
  ATOTPData service,
) async {
  await _showStubDialog(
    context,
    title: 'Вставить ссылку',
    message: 'Вставка ссылки для "${service.label}" пока не реализована.',
  );
}

Future<void> _scanAddressQrCode(
  BuildContext context,
  WidgetRef ref,
  ATOTPData service,
) async {
  if (!PlatformCapabilities.supportsQrScanning) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Сканирование QR недоступно на этой платформе'),
      ),
    );
    return;
  }

  await _showStubDialog(
    context,
    title: 'Сканировать QR',
    message: 'Сканирование QR для "${service.label}" пока в разработке.',
  );
}

void _showServicesAction(BuildContext context, WidgetRef ref, ATOTPData service) {

  showModalBottomSheet(
    context: context,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text("Редактировать"),
          onTap: () {
            Navigator.pop(context);
            _showServiceDialog(context, ref, existingService: service);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text("Удалить", style: TextStyle(color: Colors.red)),
          onTap: () async {
            Navigator.pop(context);
            final confirmed = await showDialog<bool>(
              context: context, 
              builder: (context) => AlertDialog(
                title: const Text("Удалить сервис"),
                content: Text('Вы уверены что хотите удалить "${service.label}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Отмена"),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Удалить"),
                  ),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              final db = ref.read(dbProvider);
              await db.removeService(service.secret);
              if (context.mounted) {
                ref.invalidate(servicesProvider);
              }
            }
          },
        ),
      ],
    ),
  );
}

void _showServiceDialog(BuildContext context, WidgetRef ref, 
  {
    ATOTPData? existingService,
    ParsedATOTPService? prefilledData,
  }
) {
  final isEditing = existingService != null && existingService.id > 0;

  final labelCtrl = TextEditingController(
    text: existingService?.label ?? prefilledData?.label ?? '',
  );
  final issuerCtrl = TextEditingController(
    text: existingService?.issuer ?? prefilledData?.issuer ?? '',
  );
  final secretCtrl = TextEditingController(
    text: isEditing 
      ? base32.decode(existingService.secret).toString() 
      : (prefilledData?.secret ?? ''),
  );
  final digitsCtrl = TextEditingController(
    text: (existingService?.digits ?? prefilledData?.digits ?? 6).toString(),
  );
  final periodCtrl = TextEditingController(
    text: (existingService?.period ?? prefilledData?.period ?? 30).toString(),
  );

  final algorithms = ['sha1', 'sha256', 'sha512'];
  String selectedAlgorithm = (existingService?.algorithm ?? prefilledData?.algorithm ?? 'sha1').toLowerCase();

  final addressOptions = {
    1: 'Только IP',
    2: 'Только URL',
    3: 'IP и URL',
  };
  int selectedAddressOption = existingService?.addressOption ?? prefilledData?.addressOption ?? 3;

  String? error;

  showDialog(
    context: context, 
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing? "Редактировать сервис" : "Добавить сервис"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: labelCtrl,
                    label: "Название сервиса",
                    hint: "Например: ATOTP",
                    error: error != null && labelCtrl.text.isNotEmpty ? error : null,
                    onChanged: (_) => setState(() => error = null),
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: issuerCtrl,
                    label: "Издатель (необязательно)",
                    hint: "Например: ООО ATOTP",
                    error: error != null && issuerCtrl.text.isNotEmpty ? error : null,
                    onChanged: (_) => setState(() => error = null),
                    maxLength: 50,
                  ),

                  const SizedBox(height: 16),
                  
                  if (isEditing)
                    _buildDisabledSecretField(context, base32.decode(existingService.secret).toString())
                  else
                    _buildTextField(
                      controller: secretCtrl,
                      label: "Секрет (в base32)",
                      hint: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                      error: error != null && secretCtrl.text.isNotEmpty ? error : null,
                      onChanged: (value) {
                        if (value != value.toUpperCase()) {
                          secretCtrl.value = secretCtrl.value.copyWith(
                            text: value.toUpperCase(),
                            selection: TextSelection.collapsed(offset: value.length),
                          );
                        }
                        setState(() => error = null);
                      },
                      filter: FilteringTextInputFormatter.allow(RegExp(r'^[A-Z2-7]+$', caseSensitive: false)),
                    ),

                  const SizedBox(height: 8),

                  if(!isEditing)
                    Text(
                      "Секрет вводится при добавлении сервиса и не может быть изменён",
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                  const SizedBox(height: 16),

                  _buildDropdown<String>(
                    value: selectedAlgorithm,
                    label: "Алгоритм",
                    items: algorithms.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                    onChanged: (v) => setState(() => selectedAlgorithm = v!),
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: digitsCtrl,
                    label: "Количество символов в коде",
                    hint: "Например для получения кода XXX-XXX, значение 6",
                    error: error != null && digitsCtrl.text.isNotEmpty ? error : null,
                    onChanged: (_) => setState(() => error = null),
                    keyboardType: TextInputType.number,
                    filter: FilteringTextInputFormatter.digitsOnly,
                    maxLength: 12,
                    helper: "Не более 12 символов",
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Не более 12 символов",
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: periodCtrl,
                    label: "Период",
                    hint: "в секундах: 15, 30, 60",
                    error: error != null && periodCtrl.text.isNotEmpty ? error : null,
                    onChanged: (_) => setState(() => error = null),
                    keyboardType: TextInputType.number,
                    filter: FilteringTextInputFormatter.digitsOnly,
                    maxLength: 60,
                    helper: "Укажите период: 15, 30, 60",
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Укажите период: 15, 30, 60",
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildDropdown<int>(
                    value: selectedAddressOption,
                    label: "Тип используемого адреса",
                    items: addressOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    onChanged: (v) => setState(() => selectedAddressOption = v!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Отмена"),
              ),
              FilledButton(
                onPressed: () async {
                  final formError = _validateServiceForm(
                    label: labelCtrl.text.trim(),
                    issuer: issuerCtrl.text.trim(),
                    secret: secretCtrl.text.trim(),
                    digitsText: digitsCtrl.text.trim(),
                    periodText: periodCtrl.text.trim(),
                  );

                  if (formError != null) {
                    setState(() => error = formError);
                    return;
                  }

                  setState(() => error = null);
                  final saveError = await _handleSaveService(
                    ref: ref,
                    label: labelCtrl.text.trim(),
                    issuer: issuerCtrl.text.trim(),
                    secret: secretCtrl.text.trim(),
                    algorithm: selectedAlgorithm,
                    digits: int.parse(digitsCtrl.text.trim()),
                    period: int.parse(periodCtrl.text.trim()),
                    addressOption: selectedAddressOption,
                    serviceId: existingService?.id,
                  );

                  if (context.mounted) {
                    if (saveError == null) {
                      Navigator.pop(context);
                    } else {
                      setState(() => error = saveError);
                    }
                  }
                },

                child: const Text("Сохранить"),
              ),
            ],
          );
        }
      );
    },
  ).whenComplete(() {
    labelCtrl.dispose();
    issuerCtrl.dispose();
    secretCtrl.dispose();
    digitsCtrl.dispose();
    periodCtrl.dispose();
  });
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  String? error,
  String? helper,
  void Function(String)? onChanged,
  TextInputFormatter? filter,
  int? maxLength,
  TextInputType? keyboardType,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: error,
      helperText: helper,
      border: const OutlineInputBorder(),
    ),
    keyboardType: keyboardType ?? TextInputType.text,
    inputFormatters: filter != null ? [filter, LengthLimitingTextInputFormatter(maxLength)] : [LengthLimitingTextInputFormatter(maxLength)],
    onChanged: onChanged,
  );
}

Widget _buildDisabledSecretField(BuildContext context, String secret) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: TextEditingController(text: secret),
        enabled: false,
        decoration: const InputDecoration(
          labelText: "Секрет (не изменяется)",
          border: OutlineInputBorder(),
          filled: true,
        ),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontFamily: "monospace",
        ),
      ),
      const SizedBox(height: 8),
      Text(
        "Секрет вводится при добавлении сервиса и не может быть изменён",
        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}

Widget _buildDropdown<T>({
  required T value,
  required String label,
  required List<DropdownMenuItem<T>> items,
  required void Function(T?) onChanged,
}) {
  return DropdownButtonFormField<T>(
    initialValue: value,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    items: items,
    onChanged: onChanged,
  );
}

Future<String?> _handleSaveService({
  required WidgetRef ref,
  required String label,
  required String issuer,
  required String secret,
  required String algorithm,
  required int digits,
  required int period,
  required int addressOption,
  int? serviceId,
}) async {
  final db = ref.read(dbProvider);
  int result;

  if (serviceId == null) {
    result = await db.addService(label, issuer, secret, algorithm, digits, period, addressOption);
  } else {
    result = await db.updateService(serviceId, label, issuer, algorithm, digits, period, addressOption);
  }

  switch (result) {
    case 0:
      ref.invalidate(servicesProvider);
      return null; // Успех
    case 1:
      return "Ошибка валидации данных";
    case 2:
      return "Сервис не найден (возможно, уже удалён)";
    default:
      return "Произошла неизвестная ошибка";
  }
}

String? _validateServiceForm({
  required String label,
  required String issuer,
  required String secret,
  required String digitsText,
  required String periodText,
}) {
  if (label.isEmpty) return "Введите название";
  if (!AppDatabase.isValidLabel(label)) return "Название больше 50 символов";
  if (secret.isEmpty) return "Введите секрет (Base32)";
  
  final digits = int.tryParse(digitsText);
  if (digits == null || digits <= 0) return "Введите корректное количество цифр";
  
  final period = int.tryParse(periodText);
  if (period == null || period <= 0) return "Введите корректный период";
  if (!AppDatabase.isValidPeriod(period)) return "Укажите корректный период: 15, 30, 60";
  
  return null;
}