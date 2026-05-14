// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ulidMeta = const VerificationMeta('ulid');
  @override
  late final GeneratedColumn<String> ulid = GeneratedColumn<String>(
    'ulid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ulid, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Client> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ulid')) {
      context.handle(
        _ulidMeta,
        ulid.isAcceptableOrUnknown(data['ulid']!, _ulidMeta),
      );
    } else if (isInserting) {
      context.missing(_ulidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ulid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ulid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final int id;
  final String ulid;
  final String name;
  final DateTime createdAt;
  const Client({
    required this.id,
    required this.ulid,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ulid'] = Variable<String>(ulid);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      ulid: Value(ulid),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Client.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<int>(json['id']),
      ulid: serializer.fromJson<String>(json['ulid']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ulid': serializer.toJson<String>(ulid),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Client copyWith({int? id, String? ulid, String? name, DateTime? createdAt}) =>
      Client(
        id: id ?? this.id,
        ulid: ulid ?? this.ulid,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      ulid: data.ulid.present ? data.ulid.value : this.ulid,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('ulid: $ulid, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ulid, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.ulid == this.ulid &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<int> id;
  final Value<String> ulid;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.ulid = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClientsCompanion.insert({
    this.id = const Value.absent(),
    required String ulid,
    required String name,
    this.createdAt = const Value.absent(),
  }) : ulid = Value(ulid),
       name = Value(name);
  static Insertable<Client> custom({
    Expression<int>? id,
    Expression<String>? ulid,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ulid != null) 'ulid': ulid,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClientsCompanion copyWith({
    Value<int>? id,
    Value<String>? ulid,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      ulid: ulid ?? this.ulid,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ulid.present) {
      map['ulid'] = Variable<String>(ulid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('ulid: $ulid, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ATOTPTable extends ATOTP with TableInfo<$ATOTPTable, ATOTPData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ATOTPTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issuerMeta = const VerificationMeta('issuer');
  @override
  late final GeneratedColumn<String> issuer = GeneratedColumn<String>(
    'issuer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secretMeta = const VerificationMeta('secret');
  @override
  late final GeneratedColumn<String> secret = GeneratedColumn<String>(
    'secret',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _addressOptionMeta = const VerificationMeta(
    'addressOption',
  );
  @override
  late final GeneratedColumn<int> addressOption = GeneratedColumn<int>(
    'address_option',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _algorithmMeta = const VerificationMeta(
    'algorithm',
  );
  @override
  late final GeneratedColumn<String> algorithm = GeneratedColumn<String>(
    'algorithm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sha1'),
  );
  static const VerificationMeta _digitsMeta = const VerificationMeta('digits');
  @override
  late final GeneratedColumn<int> digits = GeneratedColumn<int>(
    'digits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(6),
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<int> period = GeneratedColumn<int>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    issuer,
    secret,
    addressOption,
    algorithm,
    digits,
    period,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'atotp';
  @override
  VerificationContext validateIntegrity(
    Insertable<ATOTPData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('issuer')) {
      context.handle(
        _issuerMeta,
        issuer.isAcceptableOrUnknown(data['issuer']!, _issuerMeta),
      );
    } else if (isInserting) {
      context.missing(_issuerMeta);
    }
    if (data.containsKey('secret')) {
      context.handle(
        _secretMeta,
        secret.isAcceptableOrUnknown(data['secret']!, _secretMeta),
      );
    } else if (isInserting) {
      context.missing(_secretMeta);
    }
    if (data.containsKey('address_option')) {
      context.handle(
        _addressOptionMeta,
        addressOption.isAcceptableOrUnknown(
          data['address_option']!,
          _addressOptionMeta,
        ),
      );
    }
    if (data.containsKey('algorithm')) {
      context.handle(
        _algorithmMeta,
        algorithm.isAcceptableOrUnknown(data['algorithm']!, _algorithmMeta),
      );
    }
    if (data.containsKey('digits')) {
      context.handle(
        _digitsMeta,
        digits.isAcceptableOrUnknown(data['digits']!, _digitsMeta),
      );
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ATOTPData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ATOTPData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      issuer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issuer'],
      )!,
      secret: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secret'],
      )!,
      addressOption: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}address_option'],
      )!,
      algorithm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm'],
      )!,
      digits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}digits'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period'],
      )!,
    );
  }

  @override
  $ATOTPTable createAlias(String alias) {
    return $ATOTPTable(attachedDatabase, alias);
  }
}

class ATOTPData extends DataClass implements Insertable<ATOTPData> {
  final int id;
  final String label;
  final String issuer;
  final String secret;
  final int addressOption;
  final String algorithm;
  final int digits;
  final int period;
  const ATOTPData({
    required this.id,
    required this.label,
    required this.issuer,
    required this.secret,
    required this.addressOption,
    required this.algorithm,
    required this.digits,
    required this.period,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['issuer'] = Variable<String>(issuer);
    map['secret'] = Variable<String>(secret);
    map['address_option'] = Variable<int>(addressOption);
    map['algorithm'] = Variable<String>(algorithm);
    map['digits'] = Variable<int>(digits);
    map['period'] = Variable<int>(period);
    return map;
  }

  ATOTPCompanion toCompanion(bool nullToAbsent) {
    return ATOTPCompanion(
      id: Value(id),
      label: Value(label),
      issuer: Value(issuer),
      secret: Value(secret),
      addressOption: Value(addressOption),
      algorithm: Value(algorithm),
      digits: Value(digits),
      period: Value(period),
    );
  }

  factory ATOTPData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ATOTPData(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      issuer: serializer.fromJson<String>(json['issuer']),
      secret: serializer.fromJson<String>(json['secret']),
      addressOption: serializer.fromJson<int>(json['addressOption']),
      algorithm: serializer.fromJson<String>(json['algorithm']),
      digits: serializer.fromJson<int>(json['digits']),
      period: serializer.fromJson<int>(json['period']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'issuer': serializer.toJson<String>(issuer),
      'secret': serializer.toJson<String>(secret),
      'addressOption': serializer.toJson<int>(addressOption),
      'algorithm': serializer.toJson<String>(algorithm),
      'digits': serializer.toJson<int>(digits),
      'period': serializer.toJson<int>(period),
    };
  }

  ATOTPData copyWith({
    int? id,
    String? label,
    String? issuer,
    String? secret,
    int? addressOption,
    String? algorithm,
    int? digits,
    int? period,
  }) => ATOTPData(
    id: id ?? this.id,
    label: label ?? this.label,
    issuer: issuer ?? this.issuer,
    secret: secret ?? this.secret,
    addressOption: addressOption ?? this.addressOption,
    algorithm: algorithm ?? this.algorithm,
    digits: digits ?? this.digits,
    period: period ?? this.period,
  );
  ATOTPData copyWithCompanion(ATOTPCompanion data) {
    return ATOTPData(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      issuer: data.issuer.present ? data.issuer.value : this.issuer,
      secret: data.secret.present ? data.secret.value : this.secret,
      addressOption: data.addressOption.present
          ? data.addressOption.value
          : this.addressOption,
      algorithm: data.algorithm.present ? data.algorithm.value : this.algorithm,
      digits: data.digits.present ? data.digits.value : this.digits,
      period: data.period.present ? data.period.value : this.period,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ATOTPData(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('issuer: $issuer, ')
          ..write('secret: $secret, ')
          ..write('addressOption: $addressOption, ')
          ..write('algorithm: $algorithm, ')
          ..write('digits: $digits, ')
          ..write('period: $period')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    issuer,
    secret,
    addressOption,
    algorithm,
    digits,
    period,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ATOTPData &&
          other.id == this.id &&
          other.label == this.label &&
          other.issuer == this.issuer &&
          other.secret == this.secret &&
          other.addressOption == this.addressOption &&
          other.algorithm == this.algorithm &&
          other.digits == this.digits &&
          other.period == this.period);
}

class ATOTPCompanion extends UpdateCompanion<ATOTPData> {
  final Value<int> id;
  final Value<String> label;
  final Value<String> issuer;
  final Value<String> secret;
  final Value<int> addressOption;
  final Value<String> algorithm;
  final Value<int> digits;
  final Value<int> period;
  const ATOTPCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.issuer = const Value.absent(),
    this.secret = const Value.absent(),
    this.addressOption = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.digits = const Value.absent(),
    this.period = const Value.absent(),
  });
  ATOTPCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required String issuer,
    required String secret,
    this.addressOption = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.digits = const Value.absent(),
    this.period = const Value.absent(),
  }) : label = Value(label),
       issuer = Value(issuer),
       secret = Value(secret);
  static Insertable<ATOTPData> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? issuer,
    Expression<String>? secret,
    Expression<int>? addressOption,
    Expression<String>? algorithm,
    Expression<int>? digits,
    Expression<int>? period,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (issuer != null) 'issuer': issuer,
      if (secret != null) 'secret': secret,
      if (addressOption != null) 'address_option': addressOption,
      if (algorithm != null) 'algorithm': algorithm,
      if (digits != null) 'digits': digits,
      if (period != null) 'period': period,
    });
  }

  ATOTPCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String>? issuer,
    Value<String>? secret,
    Value<int>? addressOption,
    Value<String>? algorithm,
    Value<int>? digits,
    Value<int>? period,
  }) {
    return ATOTPCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      secret: secret ?? this.secret,
      addressOption: addressOption ?? this.addressOption,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      period: period ?? this.period,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (issuer.present) {
      map['issuer'] = Variable<String>(issuer.value);
    }
    if (secret.present) {
      map['secret'] = Variable<String>(secret.value);
    }
    if (addressOption.present) {
      map['address_option'] = Variable<int>(addressOption.value);
    }
    if (algorithm.present) {
      map['algorithm'] = Variable<String>(algorithm.value);
    }
    if (digits.present) {
      map['digits'] = Variable<int>(digits.value);
    }
    if (period.present) {
      map['period'] = Variable<int>(period.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ATOTPCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('issuer: $issuer, ')
          ..write('secret: $secret, ')
          ..write('addressOption: $addressOption, ')
          ..write('algorithm: $algorithm, ')
          ..write('digits: $digits, ')
          ..write('period: $period')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $ATOTPTable atotp = $ATOTPTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [clients, atotp];
}

typedef $$ClientsTableCreateCompanionBuilder =
    ClientsCompanion Function({
      Value<int> id,
      required String ulid,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$ClientsTableUpdateCompanionBuilder =
    ClientsCompanion Function({
      Value<int> id,
      Value<String> ulid,
      Value<String> name,
      Value<DateTime> createdAt,
    });

class $$ClientsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ulid => $composableBuilder(
    column: $table.ulid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClientsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ulid => $composableBuilder(
    column: $table.ulid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ulid =>
      $composableBuilder(column: $table.ulid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ClientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientsTable,
          Client,
          $$ClientsTableFilterComposer,
          $$ClientsTableOrderingComposer,
          $$ClientsTableAnnotationComposer,
          $$ClientsTableCreateCompanionBuilder,
          $$ClientsTableUpdateCompanionBuilder,
          (Client, BaseReferences<_$AppDatabase, $ClientsTable, Client>),
          Client,
          PrefetchHooks Function()
        > {
  $$ClientsTableTableManager(_$AppDatabase db, $ClientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ulid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClientsCompanion(
                id: id,
                ulid: ulid,
                name: name,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ulid,
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClientsCompanion.insert(
                id: id,
                ulid: ulid,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientsTable,
      Client,
      $$ClientsTableFilterComposer,
      $$ClientsTableOrderingComposer,
      $$ClientsTableAnnotationComposer,
      $$ClientsTableCreateCompanionBuilder,
      $$ClientsTableUpdateCompanionBuilder,
      (Client, BaseReferences<_$AppDatabase, $ClientsTable, Client>),
      Client,
      PrefetchHooks Function()
    >;
typedef $$ATOTPTableCreateCompanionBuilder =
    ATOTPCompanion Function({
      Value<int> id,
      required String label,
      required String issuer,
      required String secret,
      Value<int> addressOption,
      Value<String> algorithm,
      Value<int> digits,
      Value<int> period,
    });
typedef $$ATOTPTableUpdateCompanionBuilder =
    ATOTPCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String> issuer,
      Value<String> secret,
      Value<int> addressOption,
      Value<String> algorithm,
      Value<int> digits,
      Value<int> period,
    });

class $$ATOTPTableFilterComposer extends Composer<_$AppDatabase, $ATOTPTable> {
  $$ATOTPTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secret => $composableBuilder(
    column: $table.secret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addressOption => $composableBuilder(
    column: $table.addressOption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get digits => $composableBuilder(
    column: $table.digits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ATOTPTableOrderingComposer
    extends Composer<_$AppDatabase, $ATOTPTable> {
  $$ATOTPTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secret => $composableBuilder(
    column: $table.secret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addressOption => $composableBuilder(
    column: $table.addressOption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get digits => $composableBuilder(
    column: $table.digits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ATOTPTableAnnotationComposer
    extends Composer<_$AppDatabase, $ATOTPTable> {
  $$ATOTPTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get issuer =>
      $composableBuilder(column: $table.issuer, builder: (column) => column);

  GeneratedColumn<String> get secret =>
      $composableBuilder(column: $table.secret, builder: (column) => column);

  GeneratedColumn<int> get addressOption => $composableBuilder(
    column: $table.addressOption,
    builder: (column) => column,
  );

  GeneratedColumn<String> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => column);

  GeneratedColumn<int> get digits =>
      $composableBuilder(column: $table.digits, builder: (column) => column);

  GeneratedColumn<int> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);
}

class $$ATOTPTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ATOTPTable,
          ATOTPData,
          $$ATOTPTableFilterComposer,
          $$ATOTPTableOrderingComposer,
          $$ATOTPTableAnnotationComposer,
          $$ATOTPTableCreateCompanionBuilder,
          $$ATOTPTableUpdateCompanionBuilder,
          (ATOTPData, BaseReferences<_$AppDatabase, $ATOTPTable, ATOTPData>),
          ATOTPData,
          PrefetchHooks Function()
        > {
  $$ATOTPTableTableManager(_$AppDatabase db, $ATOTPTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ATOTPTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ATOTPTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ATOTPTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> issuer = const Value.absent(),
                Value<String> secret = const Value.absent(),
                Value<int> addressOption = const Value.absent(),
                Value<String> algorithm = const Value.absent(),
                Value<int> digits = const Value.absent(),
                Value<int> period = const Value.absent(),
              }) => ATOTPCompanion(
                id: id,
                label: label,
                issuer: issuer,
                secret: secret,
                addressOption: addressOption,
                algorithm: algorithm,
                digits: digits,
                period: period,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required String issuer,
                required String secret,
                Value<int> addressOption = const Value.absent(),
                Value<String> algorithm = const Value.absent(),
                Value<int> digits = const Value.absent(),
                Value<int> period = const Value.absent(),
              }) => ATOTPCompanion.insert(
                id: id,
                label: label,
                issuer: issuer,
                secret: secret,
                addressOption: addressOption,
                algorithm: algorithm,
                digits: digits,
                period: period,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ATOTPTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ATOTPTable,
      ATOTPData,
      $$ATOTPTableFilterComposer,
      $$ATOTPTableOrderingComposer,
      $$ATOTPTableAnnotationComposer,
      $$ATOTPTableCreateCompanionBuilder,
      $$ATOTPTableUpdateCompanionBuilder,
      (ATOTPData, BaseReferences<_$AppDatabase, $ATOTPTable, ATOTPData>),
      ATOTPData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$ATOTPTableTableManager get atotp =>
      $$ATOTPTableTableManager(_db, _db.atotp);
}
