import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'db_key_manager.dart';
//import 'package:pointycastle/api.dart';
//import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

//Схемы БД
class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ulid => text().unique()();
  TextColumn get name => text().withLength(min: 1, max: 20)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ATOTP extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();
  TextColumn get issuer => text()();
  TextColumn get secret => text().unique()();
  IntColumn get addressOption => integer().withDefault(const Constant(3))();
  TextColumn get algorithm => text().withDefault(const Constant('sha1'))();
  IntColumn get digits => integer().withDefault(const Constant(6))();
  IntColumn get period => integer().withDefault(const Constant(30))();
}

//Логика
@DriftDatabase(tables: [Clients, ATOTP])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await customStatement('PRAGMA journal_mode = WAL;');
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  //Table Clients
  static bool isValidUlid(String ulid) {
    final regex = RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$');
    return regex.hasMatch(ulid.trim().toUpperCase());
  }

  static bool isValidName(String name) {
    if (name.isEmpty || name.length > 100) return false;
    final regex = RegExp(r'^[a-zA-Zа-яА-Я0-9\s_\-.]+$');
    return regex.hasMatch(name);
  }

  Future<int> addClient(String name, String ulid) async {
    if (!isValidUlid(ulid) || !isValidName(name)) return 1;

    try {
      await into(clients).insert(
        ClientsCompanion.insert(
          ulid: ulid.toLowerCase(),
          name: name.trim(),
        ),
        mode: InsertMode.insertOrIgnore,
      );
      return 0;
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) return 2;
      rethrow;
    }
  }

  Future<List<Client>> getAllClients() {
    return (select(clients)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
    ).get();
  }

  Future<bool> removeClient(String ulid) async {
    if (!isValidUlid(ulid)) return false;
    final count = await (delete(clients)..where((t) => t.ulid.equals(ulid.toLowerCase()))).go();
    return count > 0;
  }

  Future<Client?> getClientByUlid(String ulid) {
    return (select(clients)..where((t) => t.ulid.equals(ulid.toLowerCase()))).getSingleOrNull();
  }

  Future<void> clearClients() => delete(clients).go();

  static String? extractUlidFromOtpauth(String input) {
    try {
      final uri = Uri.parse(input.trim());
      if (uri.scheme.toLowerCase() != 'otpauth') return null;
      final type = uri.host.toLowerCase();
      if (!['atotp'].contains(type)) return null;
      String? ulid;
      final path = uri.path.trim();
      if (path.startsWith('/')) {
        final pathContent = path.substring(1);
        if (pathContent.toLowerCase().startsWith('client=')) {
          ulid = pathContent.substring(7).trim().toUpperCase();
        }
      }
      if (ulid != null && isValidUlid(ulid)) {
        return ulid;
      }
      return null;
      } catch (e) {
        return null;
      }
  }

  Future<int> updateClient(String ulid, String newName) async {
    if (!isValidUlid(ulid) || !isValidName(newName)) return 1;
    try {
      final count = await (update(clients)
      ..where((t) => t.ulid.equals(ulid.toLowerCase())))
      .write(ClientsCompanion(
        name: Value(newName.trim()),
      ));
    return count > 0 ? 0 : 2;
    } catch (e) {
      return 2;
    }
  }

  Future<bool> isClientsEmpty() async {
    return await (select(clients)..limit(1)).getSingleOrNull() == null;
  }

  //Table ATOTP
  static bool isValidLabel(String label) {
    final validLabel = label.trim();
    return validLabel.isNotEmpty && validLabel.length <= 50;
  }

  static bool isValidIssuer(String issuer) {
    final validIssuer = issuer.trim();
    return validIssuer.length <= 50;
  }

  static String normalizeSecret(String secret) {
    return secret.trim().replaceAll(' ', '').toUpperCase();
  }

  static bool isValidSecret(String secret) {
    final validSecret = normalizeSecret(secret);
    final regex = RegExp(r'^[A-Z2-7]+$');
    return validSecret.isNotEmpty && validSecret.length >= 16 && regex.hasMatch(validSecret);
  }

  static bool isValidAlgorithm(String algorithm) {
    final validAlgorithm = algorithm.trim().toLowerCase();
    return validAlgorithm == 'sha1' || validAlgorithm == 'sha256' || validAlgorithm == 'sha512';
  }

  static bool isValidDigits(int digits) {
    return digits >= 6 && digits <= 12;
  }

  static bool isValidPeriod(int period) {
    return period == 15 || period == 30 || period == 60;
  }

  static bool isValidAddressOption(int addressOption) {
    return addressOption >= 1 && addressOption <=3;
  }

  Future<int> addService(
    String label, 
    String issuer, 
    String secret, 
    String algorithm, 
    int digits,
    int period,
    int addressOption,
  ) async {
    if (
      !isValidLabel(label) ||
      !isValidIssuer(issuer) ||
      !isValidSecret(secret) ||
      !isValidAlgorithm(algorithm) ||
      !isValidDigits(digits) ||
      !isValidPeriod(period) ||
      !isValidAddressOption(addressOption)
    ) {
      return 1;
    }

    try {
      await into(atotp).insert(
        ATOTPCompanion.insert(
          label: label.trim(),
          issuer: issuer.trim(),
          secret: normalizeSecret(secret),
          algorithm: Value(algorithm.trim().toLowerCase()),
          digits: Value(digits),
          period: Value(period),
          addressOption: Value(addressOption),
        ),
        mode: InsertMode.insertOrFail,
      );
      return 0;
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) return 2;
      rethrow;
    }
  }

  Future<int> updateService(
    int id,
    String newLabel,
    String newIssuer,
    String newAlgorithm,
    int newDigits,
    int newPeriod,
    int newAddressOption
  ) async {
    if (!isValidLabel(newLabel)) return 1;
    if (!isValidIssuer(newIssuer)) return 1;
    if (!isValidAlgorithm(newAlgorithm)) return 1;
    if (!isValidDigits(newDigits)) return 1;
    if (!isValidPeriod(newPeriod)) return 1;
    if (!isValidAddressOption(newAddressOption)) return 1;

    try {
      final count = await (update(atotp)
        ..where((t) => t.id.equals(id)))
      .write(
        ATOTPCompanion(
          label: Value(newLabel.trim()),
          issuer: Value(newIssuer.trim()),
          algorithm: Value(newAlgorithm.trim().toLowerCase()),
          digits: Value(newDigits),
          period: Value(newPeriod),
          addressOption: Value(newAddressOption),
        ),
      );

      return count > 0 ? 0 : 2;
    } catch (e) {
      return 2;
    }
  }

  Future<List<ATOTPData>> getAllServices() {
    return (select(atotp)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
    ).get();
  }

  Future<bool> removeService(String secret) async {
    if (!isValidSecret(secret)) return false;
    final count = await (delete(atotp)..where((t) => t.secret.equals(secret.toUpperCase()))).go();
    return count > 0;
  }

  static ParsedATOTPService? extractServiceFromOtpauth(String input) {
    try {
      final uri = Uri.parse(input.trim());
      
      if (uri.scheme.toLowerCase() != 'otpauth') return null;
      if (uri.host.toLowerCase() != 'atotp') return null;
      
      final path = uri.path.trim();
      if (path.isEmpty || path == '/') return null;
      
      final rawLabel = path.startsWith('/') ? path.substring(1) : path;
      final label = Uri.decodeComponent(rawLabel).trim();
      
      final secretRaw = uri.queryParameters['secret'];
      if (secretRaw == null || secretRaw.isEmpty) return null;
      final secret = normalizeSecret(secretRaw);
      
      final issuer = uri.queryParameters['issuer']?.trim() ?? '';
      final algorithm = (uri.queryParameters['algorithm']?.trim() ?? 'sha1').toLowerCase();
      final digits = int.tryParse(uri.queryParameters['digits']?.trim() ?? '6') ?? 6;
      final period = int.tryParse(uri.queryParameters['period']?.trim() ?? '30') ?? 30;
      final addressOption = int.tryParse(uri.queryParameters['addressOption']?.trim() ?? '3') ?? 3;
      
      if (!isValidLabel(label)) return null;
      if (!isValidIssuer(issuer)) return null;
      if (!isValidSecret(secret)) return null;
      if (!isValidAlgorithm(algorithm)) return null;
      if (!isValidDigits(digits)) return null;
      if (!isValidPeriod(period)) return null;
      if (!isValidAddressOption(addressOption)) return null;
      
      return ParsedATOTPService(
        label: label,
        issuer: issuer,
        secret: secret,
        algorithm: algorithm,
        digits: digits,
        period: period,
        addressOption: addressOption,
      );
      
    } catch (e) {
      return null;
    }
  }

  static ParsedAddressData? extractAddressFromOtpauth(String input) {
    try {
      final uri = Uri.parse(input.trim());
      
      if (uri.scheme.toLowerCase() != 'otpauth') return null;
      if (uri.host.toLowerCase() != 'atotp') return null;
      
      final ipBase32 = uri.queryParameters['ip-address'];
      final urlBase32 = uri.queryParameters['url'];
      final clientUlidRaw = uri.queryParameters['client'];
      
      if (clientUlidRaw == null || !isValidUlid(clientUlidRaw)) return null;
      
      final base32Regex = RegExp(r'^[A-Z2-7]+$', caseSensitive: false);
      if (ipBase32 != null && !base32Regex.hasMatch(ipBase32)) return null;
      if (urlBase32 != null && !base32Regex.hasMatch(urlBase32)) return null;
      
      return ParsedAddressData(
        ipBase32: ipBase32?.toUpperCase(),
        urlBase32: urlBase32?.toUpperCase(),
        clientUlid: clientUlidRaw.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'database.sqlite'));

    final dbKey = await DbKeyManager.getOrCreateKey();
    
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        assert(
          DbKeyManager.debugCheckCipherEnabled(rawDb),
          'SQLite3MultipleCiphers не подключён! Проверте наличие openSSL',
        );
        rawDb.execute("PRAGMA key = '${DbKeyManager.escapeKey(dbKey)}';");
      },
    );
  });
}

class ParsedATOTPService {
  final String label;
  final String issuer;
  final String secret;
  final String algorithm;
  final int digits;
  final int period;
  final int addressOption;

  ParsedATOTPService({
    required this.label,
    required this.issuer,
    required this.secret,
    required this.algorithm,
    required this.digits,
    required this.period,
    required this.addressOption,
  });
}

class ParsedAddressData {
  final String? ipBase32;
  final String? urlBase32;
  final String clientUlid;
  
  ParsedAddressData({
    this.ipBase32,
    this.urlBase32,
    required this.clientUlid,
  });
}