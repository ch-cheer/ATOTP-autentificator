import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

enum QrScanResult {
  success,
  canceled,
  permissionDenied,
  error,
  noQrCode,
}

Future<String?> scanQRCode(BuildContext context) async {
  final status = await Permission.camera.request();

  if(status.isDenied) {
    if(context.mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Доступ к камере"),
          content: const Text("Доступ к камере не получен,\n""вы можете разрешить в настройках"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("ОК"),
            ),
          ],
        )
      );
    }
    return null;
  }

  if(!context.mounted) return null;

  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    builder: (context) => _QrScannerSheet(),
    );

  return result;
}

class _QrScannerSheet extends StatefulWidget {
  const _QrScannerSheet();

  @override
  State<_QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<_QrScannerSheet> {
  late final MobileScannerController _controller;
  bool _scaned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanAreaSize = MediaQuery.of(context).size.width * 0.7;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Наведите камеру на QR-код",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white,)
                )
              ],
            ),
          ),

          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_scaned) return;

                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final rawValue = barcode.rawValue;
                  if (rawValue != null && rawValue.isNotEmpty) {
                    _scaned = true;
                    Navigator.pop(context, rawValue);
                    break;
                  }
                }
              },
              overlayBuilder: (context, constraints) {
                return _QrScannerOverlay(
                  scanAreaSize: scanAreaSize,
                  borderColor: Theme.of(context).colorScheme.primary,
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsetsGeometry.all(20),
            child: Text(
              "QR должен содержать ссылку вида otpauth://",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ), 
          )
        ],
      ),
    );
  }
}

class _QrScannerOverlay extends StatelessWidget {
  final double scanAreaSize;
  final Color borderColor;

  const _QrScannerOverlay({
    required this.scanAreaSize,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _QrOverlayPainter(
        scanAreaSize: scanAreaSize,
        borderColor: borderColor,
      ),
      size: Size.infinite,
    );
  }
}

class _QrOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final Color borderColor;

  _QrOverlayPainter({
    required this.scanAreaSize,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final halfSize = scanAreaSize / 2;

    final backgroundPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, centerY - halfSize), backgroundPaint); // верх
    canvas.drawRect(Rect.fromLTWH(0, centerY + halfSize, size.width, size.height - (centerY + halfSize)), backgroundPaint); // низ
    canvas.drawRect(Rect.fromLTWH(0, centerY - halfSize, centerX - halfSize, scanAreaSize), backgroundPaint); // лево
    canvas.drawRect(Rect.fromLTWH(centerX + halfSize, centerY - halfSize, centerX - halfSize, scanAreaSize), backgroundPaint); // право

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: scanAreaSize,
        height: scanAreaSize,
      ),
      borderPaint,
    );

    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    const cornerOffset = 10.0;

    canvas.drawLine(
      Offset(centerX - halfSize + cornerOffset, centerY - halfSize),
      Offset(centerX - halfSize + cornerOffset + cornerLength, centerY - halfSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - halfSize, centerY - halfSize + cornerOffset),
      Offset(centerX - halfSize, centerY - halfSize + cornerOffset + cornerLength),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(centerX + halfSize - cornerOffset, centerY - halfSize),
      Offset(centerX + halfSize - cornerOffset - cornerLength, centerY - halfSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + halfSize, centerY - halfSize + cornerOffset),
      Offset(centerX + halfSize, centerY - halfSize + cornerOffset + cornerLength),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(centerX - halfSize + cornerOffset, centerY + halfSize),
      Offset(centerX - halfSize + cornerOffset + cornerLength, centerY + halfSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - halfSize, centerY + halfSize - cornerOffset),
      Offset(centerX - halfSize, centerY + halfSize - cornerOffset - cornerLength),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(centerX + halfSize - cornerOffset, centerY + halfSize),
      Offset(centerX + halfSize - cornerOffset - cornerLength, centerY + halfSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + halfSize, centerY + halfSize - cornerOffset),
      Offset(centerX + halfSize, centerY + halfSize - cornerOffset - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrOverlayPainter oldDelegate) {
    return oldDelegate.scanAreaSize != scanAreaSize || oldDelegate.borderColor != borderColor;
  }
}