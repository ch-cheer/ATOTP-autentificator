//import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';

//генерация ATOTP кодов
String generateATOTP({
  required String generalsecretBase32,
  required String addressBase32,
  required Hash algorithm,
  int interval = 30,
  int digits = 6,
}) {
  final generalsecret = base32.decode(generalsecretBase32.replaceAll(' ', '').toUpperCase());
  final address = base32.decode(addressBase32.replaceAll(' ', ''));

  final addresssecretHmac = Hmac(algorithm, generalsecret);
  final addresssecret = addresssecretHmac.convert(address).bytes;

  //T = (T-T0) / X
  int counter = DateTime.now().millisecondsSinceEpoch ~/ (interval * 1000);
  Uint8List counterBytes = Uint8List(8);
  ByteData.view(counterBytes.buffer).setUint64(0, counter, Endian.big);

  //ATOTP = HMAC-SHA-[1,256,512](KA,T)
  final otpsecretHmac = Hmac(algorithm, addresssecret);
  final otpsecretHash = otpsecretHmac.convert(counterBytes).bytes;

  int offset = otpsecretHash[otpsecretHash.length - 1] & 0x0f;
  int binary = ((otpsecretHash[offset] & 0x7f) << 24) |
               ((otpsecretHash[offset + 1] & 0xff) << 16) |
               ((otpsecretHash[offset + 2] & 0xff) << 8) |
               (otpsecretHash[offset + 3] & 0xff);

  int otpsecret = binary % pow(10, digits).toInt();
  return otpsecret.toString().padLeft(digits, '0');
}

int remainingSeconds({int interval = 30}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return interval - (now % interval);
}

