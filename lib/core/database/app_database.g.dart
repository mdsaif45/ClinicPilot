// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClinicsTable extends Clinics with TableInfo<$ClinicsTable, Clinic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClinicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlyRentMeta = const VerificationMeta(
    'monthlyRent',
  );
  @override
  late final GeneratedColumn<double> monthlyRent = GeneratedColumn<double>(
    'monthly_rent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _defaultConsultationFeeMeta =
      const VerificationMeta('defaultConsultationFee');
  @override
  late final GeneratedColumn<double> defaultConsultationFee =
      GeneratedColumn<double>(
        'default_consultation_fee',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _openDaysMeta = const VerificationMeta(
    'openDays',
  );
  @override
  late final GeneratedColumn<String> openDays = GeneratedColumn<String>(
    'open_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1,2,3,4,5,6'),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#0F5132'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [
    id,
    name,
    address,
    phone,
    monthlyRent,
    defaultConsultationFee,
    openDays,
    colorHex,
    isActive,
    isDeleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clinics';
  @override
  VerificationContext validateIntegrity(
    Insertable<Clinic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('monthly_rent')) {
      context.handle(
        _monthlyRentMeta,
        monthlyRent.isAcceptableOrUnknown(
          data['monthly_rent']!,
          _monthlyRentMeta,
        ),
      );
    }
    if (data.containsKey('default_consultation_fee')) {
      context.handle(
        _defaultConsultationFeeMeta,
        defaultConsultationFee.isAcceptableOrUnknown(
          data['default_consultation_fee']!,
          _defaultConsultationFeeMeta,
        ),
      );
    }
    if (data.containsKey('open_days')) {
      context.handle(
        _openDaysMeta,
        openDays.isAcceptableOrUnknown(data['open_days']!, _openDaysMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
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
  Clinic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Clinic(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      monthlyRent:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}monthly_rent'],
          )!,
      defaultConsultationFee:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}default_consultation_fee'],
          )!,
      openDays:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}open_days'],
          )!,
      colorHex:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}color_hex'],
          )!,
      isActive:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_active'],
          )!,
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $ClinicsTable createAlias(String alias) {
    return $ClinicsTable(attachedDatabase, alias);
  }
}

class Clinic extends DataClass implements Insertable<Clinic> {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final double monthlyRent;
  final double defaultConsultationFee;
  final String openDays;
  final String colorHex;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  const Clinic({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    required this.monthlyRent,
    required this.defaultConsultationFee,
    required this.openDays,
    required this.colorHex,
    required this.isActive,
    required this.isDeleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['monthly_rent'] = Variable<double>(monthlyRent);
    map['default_consultation_fee'] = Variable<double>(defaultConsultationFee);
    map['open_days'] = Variable<String>(openDays);
    map['color_hex'] = Variable<String>(colorHex);
    map['is_active'] = Variable<bool>(isActive);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClinicsCompanion toCompanion(bool nullToAbsent) {
    return ClinicsCompanion(
      id: Value(id),
      name: Value(name),
      address:
          address == null && nullToAbsent
              ? const Value.absent()
              : Value(address),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      monthlyRent: Value(monthlyRent),
      defaultConsultationFee: Value(defaultConsultationFee),
      openDays: Value(openDays),
      colorHex: Value(colorHex),
      isActive: Value(isActive),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
    );
  }

  factory Clinic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Clinic(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      monthlyRent: serializer.fromJson<double>(json['monthlyRent']),
      defaultConsultationFee: serializer.fromJson<double>(
        json['defaultConsultationFee'],
      ),
      openDays: serializer.fromJson<String>(json['openDays']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'monthlyRent': serializer.toJson<double>(monthlyRent),
      'defaultConsultationFee': serializer.toJson<double>(
        defaultConsultationFee,
      ),
      'openDays': serializer.toJson<String>(openDays),
      'colorHex': serializer.toJson<String>(colorHex),
      'isActive': serializer.toJson<bool>(isActive),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Clinic copyWith({
    String? id,
    String? name,
    Value<String?> address = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    double? monthlyRent,
    double? defaultConsultationFee,
    String? openDays,
    String? colorHex,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdAt,
  }) => Clinic(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    phone: phone.present ? phone.value : this.phone,
    monthlyRent: monthlyRent ?? this.monthlyRent,
    defaultConsultationFee:
        defaultConsultationFee ?? this.defaultConsultationFee,
    openDays: openDays ?? this.openDays,
    colorHex: colorHex ?? this.colorHex,
    isActive: isActive ?? this.isActive,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
  );
  Clinic copyWithCompanion(ClinicsCompanion data) {
    return Clinic(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      monthlyRent:
          data.monthlyRent.present ? data.monthlyRent.value : this.monthlyRent,
      defaultConsultationFee:
          data.defaultConsultationFee.present
              ? data.defaultConsultationFee.value
              : this.defaultConsultationFee,
      openDays: data.openDays.present ? data.openDays.value : this.openDays,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Clinic(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('monthlyRent: $monthlyRent, ')
          ..write('defaultConsultationFee: $defaultConsultationFee, ')
          ..write('openDays: $openDays, ')
          ..write('colorHex: $colorHex, ')
          ..write('isActive: $isActive, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    address,
    phone,
    monthlyRent,
    defaultConsultationFee,
    openDays,
    colorHex,
    isActive,
    isDeleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Clinic &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.monthlyRent == this.monthlyRent &&
          other.defaultConsultationFee == this.defaultConsultationFee &&
          other.openDays == this.openDays &&
          other.colorHex == this.colorHex &&
          other.isActive == this.isActive &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt);
}

class ClinicsCompanion extends UpdateCompanion<Clinic> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<double> monthlyRent;
  final Value<double> defaultConsultationFee;
  final Value<String> openDays;
  final Value<String> colorHex;
  final Value<bool> isActive;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ClinicsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.monthlyRent = const Value.absent(),
    this.defaultConsultationFee = const Value.absent(),
    this.openDays = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClinicsCompanion.insert({
    required String id,
    required String name,
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.monthlyRent = const Value.absent(),
    this.defaultConsultationFee = const Value.absent(),
    this.openDays = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Clinic> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<double>? monthlyRent,
    Expression<double>? defaultConsultationFee,
    Expression<String>? openDays,
    Expression<String>? colorHex,
    Expression<bool>? isActive,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (monthlyRent != null) 'monthly_rent': monthlyRent,
      if (defaultConsultationFee != null)
        'default_consultation_fee': defaultConsultationFee,
      if (openDays != null) 'open_days': openDays,
      if (colorHex != null) 'color_hex': colorHex,
      if (isActive != null) 'is_active': isActive,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClinicsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? address,
    Value<String?>? phone,
    Value<double>? monthlyRent,
    Value<double>? defaultConsultationFee,
    Value<String>? openDays,
    Value<String>? colorHex,
    Value<bool>? isActive,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ClinicsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      defaultConsultationFee:
          defaultConsultationFee ?? this.defaultConsultationFee,
      openDays: openDays ?? this.openDays,
      colorHex: colorHex ?? this.colorHex,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (monthlyRent.present) {
      map['monthly_rent'] = Variable<double>(monthlyRent.value);
    }
    if (defaultConsultationFee.present) {
      map['default_consultation_fee'] = Variable<double>(
        defaultConsultationFee.value,
      );
    }
    if (openDays.present) {
      map['open_days'] = Variable<String>(openDays.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClinicsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('monthlyRent: $monthlyRent, ')
          ..write('defaultConsultationFee: $defaultConsultationFee, ')
          ..write('openDays: $openDays, ')
          ..write('colorHex: $colorHex, ')
          ..write('isActive: $isActive, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatientsTable extends Patients with TableInfo<$PatientsTable, Patient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientCodeMeta = const VerificationMeta(
    'patientCode',
  );
  @override
  late final GeneratedColumn<String> patientCode = GeneratedColumn<String>(
    'patient_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _serialNoMeta = const VerificationMeta(
    'serialNo',
  );
  @override
  late final GeneratedColumn<String> serialNo = GeneratedColumn<String>(
    'serial_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whatsappMeta = const VerificationMeta(
    'whatsapp',
  );
  @override
  late final GeneratedColumn<String> whatsapp = GeneratedColumn<String>(
    'whatsapp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<String> area = GeneratedColumn<String>(
    'area',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occupationMeta = const VerificationMeta(
    'occupation',
  );
  @override
  late final GeneratedColumn<String> occupation = GeneratedColumn<String>(
    'occupation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primaryClinicIdMeta = const VerificationMeta(
    'primaryClinicId',
  );
  @override
  late final GeneratedColumn<String> primaryClinicId = GeneratedColumn<String>(
    'primary_clinic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('clinic_old'),
  );
  static const VerificationMeta _primaryDiseaseMeta = const VerificationMeta(
    'primaryDisease',
  );
  @override
  late final GeneratedColumn<String> primaryDisease = GeneratedColumn<String>(
    'primary_disease',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referralSourceMeta = const VerificationMeta(
    'referralSource',
  );
  @override
  late final GeneratedColumn<String> referralSource = GeneratedColumn<String>(
    'referral_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewAskedAtMeta = const VerificationMeta(
    'reviewAskedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewAskedAt =
      GeneratedColumn<DateTime>(
        'review_asked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reviewGivenMeta = const VerificationMeta(
    'reviewGiven',
  );
  @override
  late final GeneratedColumn<bool> reviewGiven = GeneratedColumn<bool>(
    'review_given',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("review_given" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientCode,
    serialNo,
    name,
    phone,
    whatsapp,
    age,
    gender,
    area,
    address,
    occupation,
    primaryClinicId,
    primaryDisease,
    referralSource,
    notes,
    reviewAskedAt,
    reviewGiven,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Patient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_code')) {
      context.handle(
        _patientCodeMeta,
        patientCode.isAcceptableOrUnknown(
          data['patient_code']!,
          _patientCodeMeta,
        ),
      );
    }
    if (data.containsKey('serial_no')) {
      context.handle(
        _serialNoMeta,
        serialNo.isAcceptableOrUnknown(data['serial_no']!, _serialNoMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('whatsapp')) {
      context.handle(
        _whatsappMeta,
        whatsapp.isAcceptableOrUnknown(data['whatsapp']!, _whatsappMeta),
      );
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('area')) {
      context.handle(
        _areaMeta,
        area.isAcceptableOrUnknown(data['area']!, _areaMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('occupation')) {
      context.handle(
        _occupationMeta,
        occupation.isAcceptableOrUnknown(data['occupation']!, _occupationMeta),
      );
    }
    if (data.containsKey('primary_clinic_id')) {
      context.handle(
        _primaryClinicIdMeta,
        primaryClinicId.isAcceptableOrUnknown(
          data['primary_clinic_id']!,
          _primaryClinicIdMeta,
        ),
      );
    }
    if (data.containsKey('primary_disease')) {
      context.handle(
        _primaryDiseaseMeta,
        primaryDisease.isAcceptableOrUnknown(
          data['primary_disease']!,
          _primaryDiseaseMeta,
        ),
      );
    }
    if (data.containsKey('referral_source')) {
      context.handle(
        _referralSourceMeta,
        referralSource.isAcceptableOrUnknown(
          data['referral_source']!,
          _referralSourceMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('review_asked_at')) {
      context.handle(
        _reviewAskedAtMeta,
        reviewAskedAt.isAcceptableOrUnknown(
          data['review_asked_at']!,
          _reviewAskedAtMeta,
        ),
      );
    }
    if (data.containsKey('review_given')) {
      context.handle(
        _reviewGivenMeta,
        reviewGiven.isAcceptableOrUnknown(
          data['review_given']!,
          _reviewGivenMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Patient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patient(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      patientCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_code'],
          )!,
      serialNo:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}serial_no'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      phone:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}phone'],
          )!,
      whatsapp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}whatsapp'],
      ),
      age:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}age'],
          )!,
      gender:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}gender'],
          )!,
      area: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      occupation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occupation'],
      ),
      primaryClinicId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}primary_clinic_id'],
          )!,
      primaryDisease: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_disease'],
      ),
      referralSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referral_source'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      reviewAskedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}review_asked_at'],
      ),
      reviewGiven:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}review_given'],
          )!,
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class Patient extends DataClass implements Insertable<Patient> {
  final String id;
  final String patientCode;
  final String serialNo;
  final String name;
  final String phone;
  final String? whatsapp;
  final int age;
  final String gender;
  final String? area;
  final String? address;
  final String? occupation;
  final String primaryClinicId;
  final String? primaryDisease;
  final String? referralSource;
  final String? notes;

  /// Google review tracking.
  ///
  /// The growth plan ranks Google reviews the single highest-impact local
  /// marketing channel, with a target of 100 in the first year. The app can
  /// only record that the ask happened and what the patient reported back — it
  /// cannot verify a review was actually published.
  final DateTime? reviewAskedAt;
  final bool reviewGiven;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Patient({
    required this.id,
    required this.patientCode,
    required this.serialNo,
    required this.name,
    required this.phone,
    this.whatsapp,
    required this.age,
    required this.gender,
    this.area,
    this.address,
    this.occupation,
    required this.primaryClinicId,
    this.primaryDisease,
    this.referralSource,
    this.notes,
    this.reviewAskedAt,
    required this.reviewGiven,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_code'] = Variable<String>(patientCode);
    map['serial_no'] = Variable<String>(serialNo);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || whatsapp != null) {
      map['whatsapp'] = Variable<String>(whatsapp);
    }
    map['age'] = Variable<int>(age);
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || area != null) {
      map['area'] = Variable<String>(area);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || occupation != null) {
      map['occupation'] = Variable<String>(occupation);
    }
    map['primary_clinic_id'] = Variable<String>(primaryClinicId);
    if (!nullToAbsent || primaryDisease != null) {
      map['primary_disease'] = Variable<String>(primaryDisease);
    }
    if (!nullToAbsent || referralSource != null) {
      map['referral_source'] = Variable<String>(referralSource);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || reviewAskedAt != null) {
      map['review_asked_at'] = Variable<DateTime>(reviewAskedAt);
    }
    map['review_given'] = Variable<bool>(reviewGiven);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      patientCode: Value(patientCode),
      serialNo: Value(serialNo),
      name: Value(name),
      phone: Value(phone),
      whatsapp:
          whatsapp == null && nullToAbsent
              ? const Value.absent()
              : Value(whatsapp),
      age: Value(age),
      gender: Value(gender),
      area: area == null && nullToAbsent ? const Value.absent() : Value(area),
      address:
          address == null && nullToAbsent
              ? const Value.absent()
              : Value(address),
      occupation:
          occupation == null && nullToAbsent
              ? const Value.absent()
              : Value(occupation),
      primaryClinicId: Value(primaryClinicId),
      primaryDisease:
          primaryDisease == null && nullToAbsent
              ? const Value.absent()
              : Value(primaryDisease),
      referralSource:
          referralSource == null && nullToAbsent
              ? const Value.absent()
              : Value(referralSource),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      reviewAskedAt:
          reviewAskedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(reviewAskedAt),
      reviewGiven: Value(reviewGiven),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Patient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patient(
      id: serializer.fromJson<String>(json['id']),
      patientCode: serializer.fromJson<String>(json['patientCode']),
      serialNo: serializer.fromJson<String>(json['serialNo']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      whatsapp: serializer.fromJson<String?>(json['whatsapp']),
      age: serializer.fromJson<int>(json['age']),
      gender: serializer.fromJson<String>(json['gender']),
      area: serializer.fromJson<String?>(json['area']),
      address: serializer.fromJson<String?>(json['address']),
      occupation: serializer.fromJson<String?>(json['occupation']),
      primaryClinicId: serializer.fromJson<String>(json['primaryClinicId']),
      primaryDisease: serializer.fromJson<String?>(json['primaryDisease']),
      referralSource: serializer.fromJson<String?>(json['referralSource']),
      notes: serializer.fromJson<String?>(json['notes']),
      reviewAskedAt: serializer.fromJson<DateTime?>(json['reviewAskedAt']),
      reviewGiven: serializer.fromJson<bool>(json['reviewGiven']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientCode': serializer.toJson<String>(patientCode),
      'serialNo': serializer.toJson<String>(serialNo),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'whatsapp': serializer.toJson<String?>(whatsapp),
      'age': serializer.toJson<int>(age),
      'gender': serializer.toJson<String>(gender),
      'area': serializer.toJson<String?>(area),
      'address': serializer.toJson<String?>(address),
      'occupation': serializer.toJson<String?>(occupation),
      'primaryClinicId': serializer.toJson<String>(primaryClinicId),
      'primaryDisease': serializer.toJson<String?>(primaryDisease),
      'referralSource': serializer.toJson<String?>(referralSource),
      'notes': serializer.toJson<String?>(notes),
      'reviewAskedAt': serializer.toJson<DateTime?>(reviewAskedAt),
      'reviewGiven': serializer.toJson<bool>(reviewGiven),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Patient copyWith({
    String? id,
    String? patientCode,
    String? serialNo,
    String? name,
    String? phone,
    Value<String?> whatsapp = const Value.absent(),
    int? age,
    String? gender,
    Value<String?> area = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> occupation = const Value.absent(),
    String? primaryClinicId,
    Value<String?> primaryDisease = const Value.absent(),
    Value<String?> referralSource = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> reviewAskedAt = const Value.absent(),
    bool? reviewGiven,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Patient(
    id: id ?? this.id,
    patientCode: patientCode ?? this.patientCode,
    serialNo: serialNo ?? this.serialNo,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    whatsapp: whatsapp.present ? whatsapp.value : this.whatsapp,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    area: area.present ? area.value : this.area,
    address: address.present ? address.value : this.address,
    occupation: occupation.present ? occupation.value : this.occupation,
    primaryClinicId: primaryClinicId ?? this.primaryClinicId,
    primaryDisease:
        primaryDisease.present ? primaryDisease.value : this.primaryDisease,
    referralSource:
        referralSource.present ? referralSource.value : this.referralSource,
    notes: notes.present ? notes.value : this.notes,
    reviewAskedAt:
        reviewAskedAt.present ? reviewAskedAt.value : this.reviewAskedAt,
    reviewGiven: reviewGiven ?? this.reviewGiven,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Patient copyWithCompanion(PatientsCompanion data) {
    return Patient(
      id: data.id.present ? data.id.value : this.id,
      patientCode:
          data.patientCode.present ? data.patientCode.value : this.patientCode,
      serialNo: data.serialNo.present ? data.serialNo.value : this.serialNo,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      whatsapp: data.whatsapp.present ? data.whatsapp.value : this.whatsapp,
      age: data.age.present ? data.age.value : this.age,
      gender: data.gender.present ? data.gender.value : this.gender,
      area: data.area.present ? data.area.value : this.area,
      address: data.address.present ? data.address.value : this.address,
      occupation:
          data.occupation.present ? data.occupation.value : this.occupation,
      primaryClinicId:
          data.primaryClinicId.present
              ? data.primaryClinicId.value
              : this.primaryClinicId,
      primaryDisease:
          data.primaryDisease.present
              ? data.primaryDisease.value
              : this.primaryDisease,
      referralSource:
          data.referralSource.present
              ? data.referralSource.value
              : this.referralSource,
      notes: data.notes.present ? data.notes.value : this.notes,
      reviewAskedAt:
          data.reviewAskedAt.present
              ? data.reviewAskedAt.value
              : this.reviewAskedAt,
      reviewGiven:
          data.reviewGiven.present ? data.reviewGiven.value : this.reviewGiven,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patient(')
          ..write('id: $id, ')
          ..write('patientCode: $patientCode, ')
          ..write('serialNo: $serialNo, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('whatsapp: $whatsapp, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('area: $area, ')
          ..write('address: $address, ')
          ..write('occupation: $occupation, ')
          ..write('primaryClinicId: $primaryClinicId, ')
          ..write('primaryDisease: $primaryDisease, ')
          ..write('referralSource: $referralSource, ')
          ..write('notes: $notes, ')
          ..write('reviewAskedAt: $reviewAskedAt, ')
          ..write('reviewGiven: $reviewGiven, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientCode,
    serialNo,
    name,
    phone,
    whatsapp,
    age,
    gender,
    area,
    address,
    occupation,
    primaryClinicId,
    primaryDisease,
    referralSource,
    notes,
    reviewAskedAt,
    reviewGiven,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patient &&
          other.id == this.id &&
          other.patientCode == this.patientCode &&
          other.serialNo == this.serialNo &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.whatsapp == this.whatsapp &&
          other.age == this.age &&
          other.gender == this.gender &&
          other.area == this.area &&
          other.address == this.address &&
          other.occupation == this.occupation &&
          other.primaryClinicId == this.primaryClinicId &&
          other.primaryDisease == this.primaryDisease &&
          other.referralSource == this.referralSource &&
          other.notes == this.notes &&
          other.reviewAskedAt == this.reviewAskedAt &&
          other.reviewGiven == this.reviewGiven &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PatientsCompanion extends UpdateCompanion<Patient> {
  final Value<String> id;
  final Value<String> patientCode;
  final Value<String> serialNo;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> whatsapp;
  final Value<int> age;
  final Value<String> gender;
  final Value<String?> area;
  final Value<String?> address;
  final Value<String?> occupation;
  final Value<String> primaryClinicId;
  final Value<String?> primaryDisease;
  final Value<String?> referralSource;
  final Value<String?> notes;
  final Value<DateTime?> reviewAskedAt;
  final Value<bool> reviewGiven;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.patientCode = const Value.absent(),
    this.serialNo = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.whatsapp = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.area = const Value.absent(),
    this.address = const Value.absent(),
    this.occupation = const Value.absent(),
    this.primaryClinicId = const Value.absent(),
    this.primaryDisease = const Value.absent(),
    this.referralSource = const Value.absent(),
    this.notes = const Value.absent(),
    this.reviewAskedAt = const Value.absent(),
    this.reviewGiven = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    this.patientCode = const Value.absent(),
    this.serialNo = const Value.absent(),
    required String name,
    required String phone,
    this.whatsapp = const Value.absent(),
    required int age,
    required String gender,
    this.area = const Value.absent(),
    this.address = const Value.absent(),
    this.occupation = const Value.absent(),
    this.primaryClinicId = const Value.absent(),
    this.primaryDisease = const Value.absent(),
    this.referralSource = const Value.absent(),
    this.notes = const Value.absent(),
    this.reviewAskedAt = const Value.absent(),
    this.reviewGiven = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       phone = Value(phone),
       age = Value(age),
       gender = Value(gender);
  static Insertable<Patient> custom({
    Expression<String>? id,
    Expression<String>? patientCode,
    Expression<String>? serialNo,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? whatsapp,
    Expression<int>? age,
    Expression<String>? gender,
    Expression<String>? area,
    Expression<String>? address,
    Expression<String>? occupation,
    Expression<String>? primaryClinicId,
    Expression<String>? primaryDisease,
    Expression<String>? referralSource,
    Expression<String>? notes,
    Expression<DateTime>? reviewAskedAt,
    Expression<bool>? reviewGiven,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientCode != null) 'patient_code': patientCode,
      if (serialNo != null) 'serial_no': serialNo,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (area != null) 'area': area,
      if (address != null) 'address': address,
      if (occupation != null) 'occupation': occupation,
      if (primaryClinicId != null) 'primary_clinic_id': primaryClinicId,
      if (primaryDisease != null) 'primary_disease': primaryDisease,
      if (referralSource != null) 'referral_source': referralSource,
      if (notes != null) 'notes': notes,
      if (reviewAskedAt != null) 'review_asked_at': reviewAskedAt,
      if (reviewGiven != null) 'review_given': reviewGiven,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientCode,
    Value<String>? serialNo,
    Value<String>? name,
    Value<String>? phone,
    Value<String?>? whatsapp,
    Value<int>? age,
    Value<String>? gender,
    Value<String?>? area,
    Value<String?>? address,
    Value<String?>? occupation,
    Value<String>? primaryClinicId,
    Value<String?>? primaryDisease,
    Value<String?>? referralSource,
    Value<String?>? notes,
    Value<DateTime?>? reviewAskedAt,
    Value<bool>? reviewGiven,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PatientsCompanion(
      id: id ?? this.id,
      patientCode: patientCode ?? this.patientCode,
      serialNo: serialNo ?? this.serialNo,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      area: area ?? this.area,
      address: address ?? this.address,
      occupation: occupation ?? this.occupation,
      primaryClinicId: primaryClinicId ?? this.primaryClinicId,
      primaryDisease: primaryDisease ?? this.primaryDisease,
      referralSource: referralSource ?? this.referralSource,
      notes: notes ?? this.notes,
      reviewAskedAt: reviewAskedAt ?? this.reviewAskedAt,
      reviewGiven: reviewGiven ?? this.reviewGiven,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientCode.present) {
      map['patient_code'] = Variable<String>(patientCode.value);
    }
    if (serialNo.present) {
      map['serial_no'] = Variable<String>(serialNo.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (whatsapp.present) {
      map['whatsapp'] = Variable<String>(whatsapp.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (occupation.present) {
      map['occupation'] = Variable<String>(occupation.value);
    }
    if (primaryClinicId.present) {
      map['primary_clinic_id'] = Variable<String>(primaryClinicId.value);
    }
    if (primaryDisease.present) {
      map['primary_disease'] = Variable<String>(primaryDisease.value);
    }
    if (referralSource.present) {
      map['referral_source'] = Variable<String>(referralSource.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (reviewAskedAt.present) {
      map['review_asked_at'] = Variable<DateTime>(reviewAskedAt.value);
    }
    if (reviewGiven.present) {
      map['review_given'] = Variable<bool>(reviewGiven.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('patientCode: $patientCode, ')
          ..write('serialNo: $serialNo, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('whatsapp: $whatsapp, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('area: $area, ')
          ..write('address: $address, ')
          ..write('occupation: $occupation, ')
          ..write('primaryClinicId: $primaryClinicId, ')
          ..write('primaryDisease: $primaryDisease, ')
          ..write('referralSource: $referralSource, ')
          ..write('notes: $notes, ')
          ..write('reviewAskedAt: $reviewAskedAt, ')
          ..write('reviewGiven: $reviewGiven, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, Visit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clinics (id)',
    ),
  );
  static const VerificationMeta _visitTypeMeta = const VerificationMeta(
    'visitType',
  );
  @override
  late final GeneratedColumn<String> visitType = GeneratedColumn<String>(
    'visit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consultationTypeMeta = const VerificationMeta(
    'consultationType',
  );
  @override
  late final GeneratedColumn<String> consultationType = GeneratedColumn<String>(
    'consultation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('clinic'),
  );
  static const VerificationMeta _diseaseMeta = const VerificationMeta(
    'disease',
  );
  @override
  late final GeneratedColumn<String> disease = GeneratedColumn<String>(
    'disease',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chiefComplaintMeta = const VerificationMeta(
    'chiefComplaint',
  );
  @override
  late final GeneratedColumn<String> chiefComplaint = GeneratedColumn<String>(
    'chief_complaint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referralSourceMeta = const VerificationMeta(
    'referralSource',
  );
  @override
  late final GeneratedColumn<String> referralSource = GeneratedColumn<String>(
    'referral_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitDateMeta = const VerificationMeta(
    'visitDate',
  );
  @override
  late final GeneratedColumn<DateTime> visitDate = GeneratedColumn<DateTime>(
    'visit_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextFollowUpDateMeta = const VerificationMeta(
    'nextFollowUpDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextFollowUpDate =
      GeneratedColumn<DateTime>(
        'next_follow_up_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    clinicId,
    visitType,
    consultationType,
    disease,
    chiefComplaint,
    referralSource,
    outcome,
    visitDate,
    nextFollowUpDate,
    notes,
    isDeleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Visit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clinicIdMeta);
    }
    if (data.containsKey('visit_type')) {
      context.handle(
        _visitTypeMeta,
        visitType.isAcceptableOrUnknown(data['visit_type']!, _visitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_visitTypeMeta);
    }
    if (data.containsKey('consultation_type')) {
      context.handle(
        _consultationTypeMeta,
        consultationType.isAcceptableOrUnknown(
          data['consultation_type']!,
          _consultationTypeMeta,
        ),
      );
    }
    if (data.containsKey('disease')) {
      context.handle(
        _diseaseMeta,
        disease.isAcceptableOrUnknown(data['disease']!, _diseaseMeta),
      );
    } else if (isInserting) {
      context.missing(_diseaseMeta);
    }
    if (data.containsKey('chief_complaint')) {
      context.handle(
        _chiefComplaintMeta,
        chiefComplaint.isAcceptableOrUnknown(
          data['chief_complaint']!,
          _chiefComplaintMeta,
        ),
      );
    }
    if (data.containsKey('referral_source')) {
      context.handle(
        _referralSourceMeta,
        referralSource.isAcceptableOrUnknown(
          data['referral_source']!,
          _referralSourceMeta,
        ),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('visit_date')) {
      context.handle(
        _visitDateMeta,
        visitDate.isAcceptableOrUnknown(data['visit_date']!, _visitDateMeta),
      );
    } else if (isInserting) {
      context.missing(_visitDateMeta);
    }
    if (data.containsKey('next_follow_up_date')) {
      context.handle(
        _nextFollowUpDateMeta,
        nextFollowUpDate.isAcceptableOrUnknown(
          data['next_follow_up_date']!,
          _nextFollowUpDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
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
  Visit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Visit(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      patientId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_id'],
          )!,
      clinicId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}clinic_id'],
          )!,
      visitType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}visit_type'],
          )!,
      consultationType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}consultation_type'],
          )!,
      disease:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}disease'],
          )!,
      chiefComplaint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chief_complaint'],
      ),
      referralSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referral_source'],
      ),
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
      visitDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}visit_date'],
          )!,
      nextFollowUpDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_follow_up_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }
}

class Visit extends DataClass implements Insertable<Visit> {
  final String id;
  final String patientId;
  final String clinicId;
  final String visitType;
  final String consultationType;
  final String disease;
  final String? chiefComplaint;
  final String? referralSource;
  final String? outcome;
  final DateTime visitDate;
  final DateTime? nextFollowUpDate;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  const Visit({
    required this.id,
    required this.patientId,
    required this.clinicId,
    required this.visitType,
    required this.consultationType,
    required this.disease,
    this.chiefComplaint,
    this.referralSource,
    this.outcome,
    required this.visitDate,
    this.nextFollowUpDate,
    this.notes,
    required this.isDeleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['clinic_id'] = Variable<String>(clinicId);
    map['visit_type'] = Variable<String>(visitType);
    map['consultation_type'] = Variable<String>(consultationType);
    map['disease'] = Variable<String>(disease);
    if (!nullToAbsent || chiefComplaint != null) {
      map['chief_complaint'] = Variable<String>(chiefComplaint);
    }
    if (!nullToAbsent || referralSource != null) {
      map['referral_source'] = Variable<String>(referralSource);
    }
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    map['visit_date'] = Variable<DateTime>(visitDate);
    if (!nullToAbsent || nextFollowUpDate != null) {
      map['next_follow_up_date'] = Variable<DateTime>(nextFollowUpDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      clinicId: Value(clinicId),
      visitType: Value(visitType),
      consultationType: Value(consultationType),
      disease: Value(disease),
      chiefComplaint:
          chiefComplaint == null && nullToAbsent
              ? const Value.absent()
              : Value(chiefComplaint),
      referralSource:
          referralSource == null && nullToAbsent
              ? const Value.absent()
              : Value(referralSource),
      outcome:
          outcome == null && nullToAbsent
              ? const Value.absent()
              : Value(outcome),
      visitDate: Value(visitDate),
      nextFollowUpDate:
          nextFollowUpDate == null && nullToAbsent
              ? const Value.absent()
              : Value(nextFollowUpDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
    );
  }

  factory Visit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Visit(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      clinicId: serializer.fromJson<String>(json['clinicId']),
      visitType: serializer.fromJson<String>(json['visitType']),
      consultationType: serializer.fromJson<String>(json['consultationType']),
      disease: serializer.fromJson<String>(json['disease']),
      chiefComplaint: serializer.fromJson<String?>(json['chiefComplaint']),
      referralSource: serializer.fromJson<String?>(json['referralSource']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      visitDate: serializer.fromJson<DateTime>(json['visitDate']),
      nextFollowUpDate: serializer.fromJson<DateTime?>(
        json['nextFollowUpDate'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'clinicId': serializer.toJson<String>(clinicId),
      'visitType': serializer.toJson<String>(visitType),
      'consultationType': serializer.toJson<String>(consultationType),
      'disease': serializer.toJson<String>(disease),
      'chiefComplaint': serializer.toJson<String?>(chiefComplaint),
      'referralSource': serializer.toJson<String?>(referralSource),
      'outcome': serializer.toJson<String?>(outcome),
      'visitDate': serializer.toJson<DateTime>(visitDate),
      'nextFollowUpDate': serializer.toJson<DateTime?>(nextFollowUpDate),
      'notes': serializer.toJson<String?>(notes),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Visit copyWith({
    String? id,
    String? patientId,
    String? clinicId,
    String? visitType,
    String? consultationType,
    String? disease,
    Value<String?> chiefComplaint = const Value.absent(),
    Value<String?> referralSource = const Value.absent(),
    Value<String?> outcome = const Value.absent(),
    DateTime? visitDate,
    Value<DateTime?> nextFollowUpDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
  }) => Visit(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    clinicId: clinicId ?? this.clinicId,
    visitType: visitType ?? this.visitType,
    consultationType: consultationType ?? this.consultationType,
    disease: disease ?? this.disease,
    chiefComplaint:
        chiefComplaint.present ? chiefComplaint.value : this.chiefComplaint,
    referralSource:
        referralSource.present ? referralSource.value : this.referralSource,
    outcome: outcome.present ? outcome.value : this.outcome,
    visitDate: visitDate ?? this.visitDate,
    nextFollowUpDate:
        nextFollowUpDate.present
            ? nextFollowUpDate.value
            : this.nextFollowUpDate,
    notes: notes.present ? notes.value : this.notes,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
  );
  Visit copyWithCompanion(VisitsCompanion data) {
    return Visit(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      visitType: data.visitType.present ? data.visitType.value : this.visitType,
      consultationType:
          data.consultationType.present
              ? data.consultationType.value
              : this.consultationType,
      disease: data.disease.present ? data.disease.value : this.disease,
      chiefComplaint:
          data.chiefComplaint.present
              ? data.chiefComplaint.value
              : this.chiefComplaint,
      referralSource:
          data.referralSource.present
              ? data.referralSource.value
              : this.referralSource,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      visitDate: data.visitDate.present ? data.visitDate.value : this.visitDate,
      nextFollowUpDate:
          data.nextFollowUpDate.present
              ? data.nextFollowUpDate.value
              : this.nextFollowUpDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Visit(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('clinicId: $clinicId, ')
          ..write('visitType: $visitType, ')
          ..write('consultationType: $consultationType, ')
          ..write('disease: $disease, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('referralSource: $referralSource, ')
          ..write('outcome: $outcome, ')
          ..write('visitDate: $visitDate, ')
          ..write('nextFollowUpDate: $nextFollowUpDate, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    clinicId,
    visitType,
    consultationType,
    disease,
    chiefComplaint,
    referralSource,
    outcome,
    visitDate,
    nextFollowUpDate,
    notes,
    isDeleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Visit &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.clinicId == this.clinicId &&
          other.visitType == this.visitType &&
          other.consultationType == this.consultationType &&
          other.disease == this.disease &&
          other.chiefComplaint == this.chiefComplaint &&
          other.referralSource == this.referralSource &&
          other.outcome == this.outcome &&
          other.visitDate == this.visitDate &&
          other.nextFollowUpDate == this.nextFollowUpDate &&
          other.notes == this.notes &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt);
}

class VisitsCompanion extends UpdateCompanion<Visit> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> clinicId;
  final Value<String> visitType;
  final Value<String> consultationType;
  final Value<String> disease;
  final Value<String?> chiefComplaint;
  final Value<String?> referralSource;
  final Value<String?> outcome;
  final Value<DateTime> visitDate;
  final Value<DateTime?> nextFollowUpDate;
  final Value<String?> notes;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VisitsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.visitType = const Value.absent(),
    this.consultationType = const Value.absent(),
    this.disease = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.referralSource = const Value.absent(),
    this.outcome = const Value.absent(),
    this.visitDate = const Value.absent(),
    this.nextFollowUpDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsCompanion.insert({
    required String id,
    required String patientId,
    required String clinicId,
    required String visitType,
    this.consultationType = const Value.absent(),
    required String disease,
    this.chiefComplaint = const Value.absent(),
    this.referralSource = const Value.absent(),
    this.outcome = const Value.absent(),
    required DateTime visitDate,
    this.nextFollowUpDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       clinicId = Value(clinicId),
       visitType = Value(visitType),
       disease = Value(disease),
       visitDate = Value(visitDate);
  static Insertable<Visit> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? clinicId,
    Expression<String>? visitType,
    Expression<String>? consultationType,
    Expression<String>? disease,
    Expression<String>? chiefComplaint,
    Expression<String>? referralSource,
    Expression<String>? outcome,
    Expression<DateTime>? visitDate,
    Expression<DateTime>? nextFollowUpDate,
    Expression<String>? notes,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (visitType != null) 'visit_type': visitType,
      if (consultationType != null) 'consultation_type': consultationType,
      if (disease != null) 'disease': disease,
      if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
      if (referralSource != null) 'referral_source': referralSource,
      if (outcome != null) 'outcome': outcome,
      if (visitDate != null) 'visit_date': visitDate,
      if (nextFollowUpDate != null) 'next_follow_up_date': nextFollowUpDate,
      if (notes != null) 'notes': notes,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? clinicId,
    Value<String>? visitType,
    Value<String>? consultationType,
    Value<String>? disease,
    Value<String?>? chiefComplaint,
    Value<String?>? referralSource,
    Value<String?>? outcome,
    Value<DateTime>? visitDate,
    Value<DateTime?>? nextFollowUpDate,
    Value<String?>? notes,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VisitsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      clinicId: clinicId ?? this.clinicId,
      visitType: visitType ?? this.visitType,
      consultationType: consultationType ?? this.consultationType,
      disease: disease ?? this.disease,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      referralSource: referralSource ?? this.referralSource,
      outcome: outcome ?? this.outcome,
      visitDate: visitDate ?? this.visitDate,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (visitType.present) {
      map['visit_type'] = Variable<String>(visitType.value);
    }
    if (consultationType.present) {
      map['consultation_type'] = Variable<String>(consultationType.value);
    }
    if (disease.present) {
      map['disease'] = Variable<String>(disease.value);
    }
    if (chiefComplaint.present) {
      map['chief_complaint'] = Variable<String>(chiefComplaint.value);
    }
    if (referralSource.present) {
      map['referral_source'] = Variable<String>(referralSource.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (visitDate.present) {
      map['visit_date'] = Variable<DateTime>(visitDate.value);
    }
    if (nextFollowUpDate.present) {
      map['next_follow_up_date'] = Variable<DateTime>(nextFollowUpDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('clinicId: $clinicId, ')
          ..write('visitType: $visitType, ')
          ..write('consultationType: $consultationType, ')
          ..write('disease: $disease, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('referralSource: $referralSource, ')
          ..write('outcome: $outcome, ')
          ..write('visitDate: $visitDate, ')
          ..write('nextFollowUpDate: $nextFollowUpDate, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashMemosTable extends CashMemos
    with TableInfo<$CashMemosTable, CashMemo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashMemosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoNumberMeta = const VerificationMeta(
    'memoNumber',
  );
  @override
  late final GeneratedColumn<String> memoNumber = GeneratedColumn<String>(
    'memo_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clinics (id)',
    ),
    defaultValue: const Constant('clinic_old'),
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES visits (id)',
    ),
  );
  static const VerificationMeta _consultationFeeMeta = const VerificationMeta(
    'consultationFee',
  );
  @override
  late final GeneratedColumn<double> consultationFee = GeneratedColumn<double>(
    'consultation_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _medicineFeeMeta = const VerificationMeta(
    'medicineFee',
  );
  @override
  late final GeneratedColumn<double> medicineFee = GeneratedColumn<double>(
    'medicine_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _otherFeeMeta = const VerificationMeta(
    'otherFee',
  );
  @override
  late final GeneratedColumn<double> otherFee = GeneratedColumn<double>(
    'other_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
    'discount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
    'paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _memoDateMeta = const VerificationMeta(
    'memoDate',
  );
  @override
  late final GeneratedColumn<DateTime> memoDate = GeneratedColumn<DateTime>(
    'memo_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
  List<GeneratedColumn> get $columns => [
    id,
    memoNumber,
    patientId,
    clinicId,
    visitId,
    consultationFee,
    medicineFee,
    otherFee,
    discount,
    total,
    paidAmount,
    paymentMethod,
    notes,
    isDeleted,
    memoDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_memos';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashMemo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memo_number')) {
      context.handle(
        _memoNumberMeta,
        memoNumber.isAcceptableOrUnknown(data['memo_number']!, _memoNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_memoNumberMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    }
    if (data.containsKey('consultation_fee')) {
      context.handle(
        _consultationFeeMeta,
        consultationFee.isAcceptableOrUnknown(
          data['consultation_fee']!,
          _consultationFeeMeta,
        ),
      );
    }
    if (data.containsKey('medicine_fee')) {
      context.handle(
        _medicineFeeMeta,
        medicineFee.isAcceptableOrUnknown(
          data['medicine_fee']!,
          _medicineFeeMeta,
        ),
      );
    }
    if (data.containsKey('other_fee')) {
      context.handle(
        _otherFeeMeta,
        otherFee.isAcceptableOrUnknown(data['other_fee']!, _otherFeeMeta),
      );
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('memo_date')) {
      context.handle(
        _memoDateMeta,
        memoDate.isAcceptableOrUnknown(data['memo_date']!, _memoDateMeta),
      );
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
  CashMemo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashMemo(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      memoNumber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}memo_number'],
          )!,
      patientId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_id'],
          )!,
      clinicId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}clinic_id'],
          )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      ),
      consultationFee:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}consultation_fee'],
          )!,
      medicineFee:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}medicine_fee'],
          )!,
      otherFee:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}other_fee'],
          )!,
      discount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}discount'],
          )!,
      total:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}total'],
          )!,
      paidAmount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}paid_amount'],
          )!,
      paymentMethod:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payment_method'],
          )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
      memoDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}memo_date'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $CashMemosTable createAlias(String alias) {
    return $CashMemosTable(attachedDatabase, alias);
  }
}

class CashMemo extends DataClass implements Insertable<CashMemo> {
  final String id;
  final String memoNumber;
  final String patientId;
  final String clinicId;
  final String? visitId;
  final double consultationFee;
  final double medicineFee;
  final double otherFee;
  final double discount;
  final double total;
  final double paidAmount;
  final String paymentMethod;
  final String? notes;
  final bool isDeleted;
  final DateTime memoDate;
  final DateTime createdAt;
  const CashMemo({
    required this.id,
    required this.memoNumber,
    required this.patientId,
    required this.clinicId,
    this.visitId,
    required this.consultationFee,
    required this.medicineFee,
    required this.otherFee,
    required this.discount,
    required this.total,
    required this.paidAmount,
    required this.paymentMethod,
    this.notes,
    required this.isDeleted,
    required this.memoDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memo_number'] = Variable<String>(memoNumber);
    map['patient_id'] = Variable<String>(patientId);
    map['clinic_id'] = Variable<String>(clinicId);
    if (!nullToAbsent || visitId != null) {
      map['visit_id'] = Variable<String>(visitId);
    }
    map['consultation_fee'] = Variable<double>(consultationFee);
    map['medicine_fee'] = Variable<double>(medicineFee);
    map['other_fee'] = Variable<double>(otherFee);
    map['discount'] = Variable<double>(discount);
    map['total'] = Variable<double>(total);
    map['paid_amount'] = Variable<double>(paidAmount);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['memo_date'] = Variable<DateTime>(memoDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CashMemosCompanion toCompanion(bool nullToAbsent) {
    return CashMemosCompanion(
      id: Value(id),
      memoNumber: Value(memoNumber),
      patientId: Value(patientId),
      clinicId: Value(clinicId),
      visitId:
          visitId == null && nullToAbsent
              ? const Value.absent()
              : Value(visitId),
      consultationFee: Value(consultationFee),
      medicineFee: Value(medicineFee),
      otherFee: Value(otherFee),
      discount: Value(discount),
      total: Value(total),
      paidAmount: Value(paidAmount),
      paymentMethod: Value(paymentMethod),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isDeleted: Value(isDeleted),
      memoDate: Value(memoDate),
      createdAt: Value(createdAt),
    );
  }

  factory CashMemo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashMemo(
      id: serializer.fromJson<String>(json['id']),
      memoNumber: serializer.fromJson<String>(json['memoNumber']),
      patientId: serializer.fromJson<String>(json['patientId']),
      clinicId: serializer.fromJson<String>(json['clinicId']),
      visitId: serializer.fromJson<String?>(json['visitId']),
      consultationFee: serializer.fromJson<double>(json['consultationFee']),
      medicineFee: serializer.fromJson<double>(json['medicineFee']),
      otherFee: serializer.fromJson<double>(json['otherFee']),
      discount: serializer.fromJson<double>(json['discount']),
      total: serializer.fromJson<double>(json['total']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      notes: serializer.fromJson<String?>(json['notes']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      memoDate: serializer.fromJson<DateTime>(json['memoDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memoNumber': serializer.toJson<String>(memoNumber),
      'patientId': serializer.toJson<String>(patientId),
      'clinicId': serializer.toJson<String>(clinicId),
      'visitId': serializer.toJson<String?>(visitId),
      'consultationFee': serializer.toJson<double>(consultationFee),
      'medicineFee': serializer.toJson<double>(medicineFee),
      'otherFee': serializer.toJson<double>(otherFee),
      'discount': serializer.toJson<double>(discount),
      'total': serializer.toJson<double>(total),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'notes': serializer.toJson<String?>(notes),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'memoDate': serializer.toJson<DateTime>(memoDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CashMemo copyWith({
    String? id,
    String? memoNumber,
    String? patientId,
    String? clinicId,
    Value<String?> visitId = const Value.absent(),
    double? consultationFee,
    double? medicineFee,
    double? otherFee,
    double? discount,
    double? total,
    double? paidAmount,
    String? paymentMethod,
    Value<String?> notes = const Value.absent(),
    bool? isDeleted,
    DateTime? memoDate,
    DateTime? createdAt,
  }) => CashMemo(
    id: id ?? this.id,
    memoNumber: memoNumber ?? this.memoNumber,
    patientId: patientId ?? this.patientId,
    clinicId: clinicId ?? this.clinicId,
    visitId: visitId.present ? visitId.value : this.visitId,
    consultationFee: consultationFee ?? this.consultationFee,
    medicineFee: medicineFee ?? this.medicineFee,
    otherFee: otherFee ?? this.otherFee,
    discount: discount ?? this.discount,
    total: total ?? this.total,
    paidAmount: paidAmount ?? this.paidAmount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    notes: notes.present ? notes.value : this.notes,
    isDeleted: isDeleted ?? this.isDeleted,
    memoDate: memoDate ?? this.memoDate,
    createdAt: createdAt ?? this.createdAt,
  );
  CashMemo copyWithCompanion(CashMemosCompanion data) {
    return CashMemo(
      id: data.id.present ? data.id.value : this.id,
      memoNumber:
          data.memoNumber.present ? data.memoNumber.value : this.memoNumber,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      consultationFee:
          data.consultationFee.present
              ? data.consultationFee.value
              : this.consultationFee,
      medicineFee:
          data.medicineFee.present ? data.medicineFee.value : this.medicineFee,
      otherFee: data.otherFee.present ? data.otherFee.value : this.otherFee,
      discount: data.discount.present ? data.discount.value : this.discount,
      total: data.total.present ? data.total.value : this.total,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      paymentMethod:
          data.paymentMethod.present
              ? data.paymentMethod.value
              : this.paymentMethod,
      notes: data.notes.present ? data.notes.value : this.notes,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      memoDate: data.memoDate.present ? data.memoDate.value : this.memoDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashMemo(')
          ..write('id: $id, ')
          ..write('memoNumber: $memoNumber, ')
          ..write('patientId: $patientId, ')
          ..write('clinicId: $clinicId, ')
          ..write('visitId: $visitId, ')
          ..write('consultationFee: $consultationFee, ')
          ..write('medicineFee: $medicineFee, ')
          ..write('otherFee: $otherFee, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('memoDate: $memoDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    memoNumber,
    patientId,
    clinicId,
    visitId,
    consultationFee,
    medicineFee,
    otherFee,
    discount,
    total,
    paidAmount,
    paymentMethod,
    notes,
    isDeleted,
    memoDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashMemo &&
          other.id == this.id &&
          other.memoNumber == this.memoNumber &&
          other.patientId == this.patientId &&
          other.clinicId == this.clinicId &&
          other.visitId == this.visitId &&
          other.consultationFee == this.consultationFee &&
          other.medicineFee == this.medicineFee &&
          other.otherFee == this.otherFee &&
          other.discount == this.discount &&
          other.total == this.total &&
          other.paidAmount == this.paidAmount &&
          other.paymentMethod == this.paymentMethod &&
          other.notes == this.notes &&
          other.isDeleted == this.isDeleted &&
          other.memoDate == this.memoDate &&
          other.createdAt == this.createdAt);
}

class CashMemosCompanion extends UpdateCompanion<CashMemo> {
  final Value<String> id;
  final Value<String> memoNumber;
  final Value<String> patientId;
  final Value<String> clinicId;
  final Value<String?> visitId;
  final Value<double> consultationFee;
  final Value<double> medicineFee;
  final Value<double> otherFee;
  final Value<double> discount;
  final Value<double> total;
  final Value<double> paidAmount;
  final Value<String> paymentMethod;
  final Value<String?> notes;
  final Value<bool> isDeleted;
  final Value<DateTime> memoDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CashMemosCompanion({
    this.id = const Value.absent(),
    this.memoNumber = const Value.absent(),
    this.patientId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.visitId = const Value.absent(),
    this.consultationFee = const Value.absent(),
    this.medicineFee = const Value.absent(),
    this.otherFee = const Value.absent(),
    this.discount = const Value.absent(),
    this.total = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.memoDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashMemosCompanion.insert({
    required String id,
    required String memoNumber,
    required String patientId,
    this.clinicId = const Value.absent(),
    this.visitId = const Value.absent(),
    this.consultationFee = const Value.absent(),
    this.medicineFee = const Value.absent(),
    this.otherFee = const Value.absent(),
    this.discount = const Value.absent(),
    required double total,
    this.paidAmount = const Value.absent(),
    required String paymentMethod,
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.memoDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memoNumber = Value(memoNumber),
       patientId = Value(patientId),
       total = Value(total),
       paymentMethod = Value(paymentMethod);
  static Insertable<CashMemo> custom({
    Expression<String>? id,
    Expression<String>? memoNumber,
    Expression<String>? patientId,
    Expression<String>? clinicId,
    Expression<String>? visitId,
    Expression<double>? consultationFee,
    Expression<double>? medicineFee,
    Expression<double>? otherFee,
    Expression<double>? discount,
    Expression<double>? total,
    Expression<double>? paidAmount,
    Expression<String>? paymentMethod,
    Expression<String>? notes,
    Expression<bool>? isDeleted,
    Expression<DateTime>? memoDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoNumber != null) 'memo_number': memoNumber,
      if (patientId != null) 'patient_id': patientId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (visitId != null) 'visit_id': visitId,
      if (consultationFee != null) 'consultation_fee': consultationFee,
      if (medicineFee != null) 'medicine_fee': medicineFee,
      if (otherFee != null) 'other_fee': otherFee,
      if (discount != null) 'discount': discount,
      if (total != null) 'total': total,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (memoDate != null) 'memo_date': memoDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashMemosCompanion copyWith({
    Value<String>? id,
    Value<String>? memoNumber,
    Value<String>? patientId,
    Value<String>? clinicId,
    Value<String?>? visitId,
    Value<double>? consultationFee,
    Value<double>? medicineFee,
    Value<double>? otherFee,
    Value<double>? discount,
    Value<double>? total,
    Value<double>? paidAmount,
    Value<String>? paymentMethod,
    Value<String?>? notes,
    Value<bool>? isDeleted,
    Value<DateTime>? memoDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CashMemosCompanion(
      id: id ?? this.id,
      memoNumber: memoNumber ?? this.memoNumber,
      patientId: patientId ?? this.patientId,
      clinicId: clinicId ?? this.clinicId,
      visitId: visitId ?? this.visitId,
      consultationFee: consultationFee ?? this.consultationFee,
      medicineFee: medicineFee ?? this.medicineFee,
      otherFee: otherFee ?? this.otherFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      memoDate: memoDate ?? this.memoDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memoNumber.present) {
      map['memo_number'] = Variable<String>(memoNumber.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (consultationFee.present) {
      map['consultation_fee'] = Variable<double>(consultationFee.value);
    }
    if (medicineFee.present) {
      map['medicine_fee'] = Variable<double>(medicineFee.value);
    }
    if (otherFee.present) {
      map['other_fee'] = Variable<double>(otherFee.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (memoDate.present) {
      map['memo_date'] = Variable<DateTime>(memoDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashMemosCompanion(')
          ..write('id: $id, ')
          ..write('memoNumber: $memoNumber, ')
          ..write('patientId: $patientId, ')
          ..write('clinicId: $clinicId, ')
          ..write('visitId: $visitId, ')
          ..write('consultationFee: $consultationFee, ')
          ..write('medicineFee: $medicineFee, ')
          ..write('otherFee: $otherFee, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('memoDate: $memoDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clinics (id)',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Cash'),
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [
    id,
    clinicId,
    category,
    subcategory,
    amount,
    paymentMethod,
    isRecurring,
    notes,
    date,
    isDeleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clinicIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
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
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      clinicId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}clinic_id'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      ),
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount'],
          )!,
      paymentMethod:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payment_method'],
          )!,
      isRecurring:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_recurring'],
          )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String clinicId;
  final String category;
  final String? subcategory;
  final double amount;
  final String paymentMethod;
  final bool isRecurring;
  final String? notes;
  final DateTime date;
  final bool isDeleted;
  final DateTime createdAt;
  const Expense({
    required this.id,
    required this.clinicId,
    required this.category,
    this.subcategory,
    required this.amount,
    required this.paymentMethod,
    required this.isRecurring,
    this.notes,
    required this.date,
    required this.isDeleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['clinic_id'] = Variable<String>(clinicId);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    map['amount'] = Variable<double>(amount);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['date'] = Variable<DateTime>(date);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      clinicId: Value(clinicId),
      category: Value(category),
      subcategory:
          subcategory == null && nullToAbsent
              ? const Value.absent()
              : Value(subcategory),
      amount: Value(amount),
      paymentMethod: Value(paymentMethod),
      isRecurring: Value(isRecurring),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      date: Value(date),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      clinicId: serializer.fromJson<String>(json['clinicId']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      notes: serializer.fromJson<String?>(json['notes']),
      date: serializer.fromJson<DateTime>(json['date']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clinicId': serializer.toJson<String>(clinicId),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String?>(subcategory),
      'amount': serializer.toJson<double>(amount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'notes': serializer.toJson<String?>(notes),
      'date': serializer.toJson<DateTime>(date),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Expense copyWith({
    String? id,
    String? clinicId,
    String? category,
    Value<String?> subcategory = const Value.absent(),
    double? amount,
    String? paymentMethod,
    bool? isRecurring,
    Value<String?> notes = const Value.absent(),
    DateTime? date,
    bool? isDeleted,
    DateTime? createdAt,
  }) => Expense(
    id: id ?? this.id,
    clinicId: clinicId ?? this.clinicId,
    category: category ?? this.category,
    subcategory: subcategory.present ? subcategory.value : this.subcategory,
    amount: amount ?? this.amount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    isRecurring: isRecurring ?? this.isRecurring,
    notes: notes.present ? notes.value : this.notes,
    date: date ?? this.date,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      category: data.category.present ? data.category.value : this.category,
      subcategory:
          data.subcategory.present ? data.subcategory.value : this.subcategory,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMethod:
          data.paymentMethod.present
              ? data.paymentMethod.value
              : this.paymentMethod,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      notes: data.notes.present ? data.notes.value : this.notes,
      date: data.date.present ? data.date.value : this.date,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('clinicId: $clinicId, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('notes: $notes, ')
          ..write('date: $date, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clinicId,
    category,
    subcategory,
    amount,
    paymentMethod,
    isRecurring,
    notes,
    date,
    isDeleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.clinicId == this.clinicId &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.amount == this.amount &&
          other.paymentMethod == this.paymentMethod &&
          other.isRecurring == this.isRecurring &&
          other.notes == this.notes &&
          other.date == this.date &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> clinicId;
  final Value<String> category;
  final Value<String?> subcategory;
  final Value<double> amount;
  final Value<String> paymentMethod;
  final Value<bool> isRecurring;
  final Value<String?> notes;
  final Value<DateTime> date;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.notes = const Value.absent(),
    this.date = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String clinicId,
    required String category,
    this.subcategory = const Value.absent(),
    required double amount,
    this.paymentMethod = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime date,
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clinicId = Value(clinicId),
       category = Value(category),
       amount = Value(amount),
       date = Value(date);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? clinicId,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<double>? amount,
    Expression<String>? paymentMethod,
    Expression<bool>? isRecurring,
    Expression<String>? notes,
    Expression<DateTime>? date,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clinicId != null) 'clinic_id': clinicId,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (amount != null) 'amount': amount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (notes != null) 'notes': notes,
      if (date != null) 'date': date,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? clinicId,
    Value<String>? category,
    Value<String?>? subcategory,
    Value<double>? amount,
    Value<String>? paymentMethod,
    Value<bool>? isRecurring,
    Value<String?>? notes,
    Value<DateTime>? date,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('clinicId: $clinicId, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('notes: $notes, ')
          ..write('date: $date, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}value'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const Setting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Setting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      Setting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewRequestsTable extends ReviewRequests
    with TableInfo<$ReviewRequestsTable, ReviewRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clinics (id)',
    ),
  );
  static const VerificationMeta _requestedAtMeta = const VerificationMeta(
    'requestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> requestedAt = GeneratedColumn<DateTime>(
    'requested_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('google'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    clinicId,
    requestedAt,
    reviewedAt,
    rating,
    platform,
    notes,
    isDeleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    }
    if (data.containsKey('requested_at')) {
      context.handle(
        _requestedAtMeta,
        requestedAt.isAcceptableOrUnknown(
          data['requested_at']!,
          _requestedAtMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
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
  ReviewRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewRequest(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      patientId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_id'],
          )!,
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      ),
      requestedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}requested_at'],
          )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      platform:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}platform'],
          )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $ReviewRequestsTable createAlias(String alias) {
    return $ReviewRequestsTable(attachedDatabase, alias);
  }
}

class ReviewRequest extends DataClass implements Insertable<ReviewRequest> {
  final String id;
  final String patientId;
  final String? clinicId;
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final int? rating;
  final String platform;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  const ReviewRequest({
    required this.id,
    required this.patientId,
    this.clinicId,
    required this.requestedAt,
    this.reviewedAt,
    this.rating,
    required this.platform,
    this.notes,
    required this.isDeleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || clinicId != null) {
      map['clinic_id'] = Variable<String>(clinicId);
    }
    map['requested_at'] = Variable<DateTime>(requestedAt);
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReviewRequestsCompanion toCompanion(bool nullToAbsent) {
    return ReviewRequestsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      clinicId:
          clinicId == null && nullToAbsent
              ? const Value.absent()
              : Value(clinicId),
      requestedAt: Value(requestedAt),
      reviewedAt:
          reviewedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(reviewedAt),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      platform: Value(platform),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
    );
  }

  factory ReviewRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewRequest(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      clinicId: serializer.fromJson<String?>(json['clinicId']),
      requestedAt: serializer.fromJson<DateTime>(json['requestedAt']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
      rating: serializer.fromJson<int?>(json['rating']),
      platform: serializer.fromJson<String>(json['platform']),
      notes: serializer.fromJson<String?>(json['notes']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'clinicId': serializer.toJson<String?>(clinicId),
      'requestedAt': serializer.toJson<DateTime>(requestedAt),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
      'rating': serializer.toJson<int?>(rating),
      'platform': serializer.toJson<String>(platform),
      'notes': serializer.toJson<String?>(notes),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReviewRequest copyWith({
    String? id,
    String? patientId,
    Value<String?> clinicId = const Value.absent(),
    DateTime? requestedAt,
    Value<DateTime?> reviewedAt = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    String? platform,
    Value<String?> notes = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
  }) => ReviewRequest(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    clinicId: clinicId.present ? clinicId.value : this.clinicId,
    requestedAt: requestedAt ?? this.requestedAt,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
    rating: rating.present ? rating.value : this.rating,
    platform: platform ?? this.platform,
    notes: notes.present ? notes.value : this.notes,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
  );
  ReviewRequest copyWithCompanion(ReviewRequestsCompanion data) {
    return ReviewRequest(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      requestedAt:
          data.requestedAt.present ? data.requestedAt.value : this.requestedAt,
      reviewedAt:
          data.reviewedAt.present ? data.reviewedAt.value : this.reviewedAt,
      rating: data.rating.present ? data.rating.value : this.rating,
      platform: data.platform.present ? data.platform.value : this.platform,
      notes: data.notes.present ? data.notes.value : this.notes,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewRequest(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('clinicId: $clinicId, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rating: $rating, ')
          ..write('platform: $platform, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    clinicId,
    requestedAt,
    reviewedAt,
    rating,
    platform,
    notes,
    isDeleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewRequest &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.clinicId == this.clinicId &&
          other.requestedAt == this.requestedAt &&
          other.reviewedAt == this.reviewedAt &&
          other.rating == this.rating &&
          other.platform == this.platform &&
          other.notes == this.notes &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt);
}

class ReviewRequestsCompanion extends UpdateCompanion<ReviewRequest> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String?> clinicId;
  final Value<DateTime> requestedAt;
  final Value<DateTime?> reviewedAt;
  final Value<int?> rating;
  final Value<String> platform;
  final Value<String?> notes;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReviewRequestsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.requestedAt = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rating = const Value.absent(),
    this.platform = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewRequestsCompanion.insert({
    required String id,
    required String patientId,
    this.clinicId = const Value.absent(),
    this.requestedAt = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rating = const Value.absent(),
    this.platform = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId);
  static Insertable<ReviewRequest> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? clinicId,
    Expression<DateTime>? requestedAt,
    Expression<DateTime>? reviewedAt,
    Expression<int>? rating,
    Expression<String>? platform,
    Expression<String>? notes,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (requestedAt != null) 'requested_at': requestedAt,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (rating != null) 'rating': rating,
      if (platform != null) 'platform': platform,
      if (notes != null) 'notes': notes,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String?>? clinicId,
    Value<DateTime>? requestedAt,
    Value<DateTime?>? reviewedAt,
    Value<int?>? rating,
    Value<String>? platform,
    Value<String?>? notes,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReviewRequestsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      clinicId: clinicId ?? this.clinicId,
      requestedAt: requestedAt ?? this.requestedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rating: rating ?? this.rating,
      platform: platform ?? this.platform,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (requestedAt.present) {
      map['requested_at'] = Variable<DateTime>(requestedAt.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewRequestsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('clinicId: $clinicId, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rating: $rating, ')
          ..write('platform: $platform, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FootfallsTable extends Footfalls
    with TableInfo<$FootfallsTable, Footfall> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FootfallsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clinics (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diseaseMeta = const VerificationMeta(
    'disease',
  );
  @override
  late final GeneratedColumn<String> disease = GeneratedColumn<String>(
    'disease',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _convertedPatientIdMeta =
      const VerificationMeta('convertedPatientId');
  @override
  late final GeneratedColumn<String> convertedPatientId =
      GeneratedColumn<String>(
        'converted_patient_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES patients (id)',
        ),
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [
    id,
    clinicId,
    date,
    name,
    phone,
    disease,
    convertedPatientId,
    notes,
    isDeleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'footfalls';
  @override
  VerificationContext validateIntegrity(
    Insertable<Footfall> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clinicIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('disease')) {
      context.handle(
        _diseaseMeta,
        disease.isAcceptableOrUnknown(data['disease']!, _diseaseMeta),
      );
    }
    if (data.containsKey('converted_patient_id')) {
      context.handle(
        _convertedPatientIdMeta,
        convertedPatientId.isAcceptableOrUnknown(
          data['converted_patient_id']!,
          _convertedPatientIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
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
  Footfall map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Footfall(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      clinicId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}clinic_id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      disease: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}disease'],
      ),
      convertedPatientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}converted_patient_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $FootfallsTable createAlias(String alias) {
    return $FootfallsTable(attachedDatabase, alias);
  }
}

class Footfall extends DataClass implements Insertable<Footfall> {
  final String id;
  final String clinicId;
  final DateTime date;
  final String name;
  final String? phone;
  final String? disease;
  final String? convertedPatientId;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  const Footfall({
    required this.id,
    required this.clinicId,
    required this.date,
    required this.name,
    this.phone,
    this.disease,
    this.convertedPatientId,
    this.notes,
    required this.isDeleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['clinic_id'] = Variable<String>(clinicId);
    map['date'] = Variable<DateTime>(date);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || disease != null) {
      map['disease'] = Variable<String>(disease);
    }
    if (!nullToAbsent || convertedPatientId != null) {
      map['converted_patient_id'] = Variable<String>(convertedPatientId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FootfallsCompanion toCompanion(bool nullToAbsent) {
    return FootfallsCompanion(
      id: Value(id),
      clinicId: Value(clinicId),
      date: Value(date),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      disease:
          disease == null && nullToAbsent
              ? const Value.absent()
              : Value(disease),
      convertedPatientId:
          convertedPatientId == null && nullToAbsent
              ? const Value.absent()
              : Value(convertedPatientId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
    );
  }

  factory Footfall.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Footfall(
      id: serializer.fromJson<String>(json['id']),
      clinicId: serializer.fromJson<String>(json['clinicId']),
      date: serializer.fromJson<DateTime>(json['date']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      disease: serializer.fromJson<String?>(json['disease']),
      convertedPatientId: serializer.fromJson<String?>(
        json['convertedPatientId'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clinicId': serializer.toJson<String>(clinicId),
      'date': serializer.toJson<DateTime>(date),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'disease': serializer.toJson<String?>(disease),
      'convertedPatientId': serializer.toJson<String?>(convertedPatientId),
      'notes': serializer.toJson<String?>(notes),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Footfall copyWith({
    String? id,
    String? clinicId,
    DateTime? date,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> disease = const Value.absent(),
    Value<String?> convertedPatientId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
  }) => Footfall(
    id: id ?? this.id,
    clinicId: clinicId ?? this.clinicId,
    date: date ?? this.date,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    disease: disease.present ? disease.value : this.disease,
    convertedPatientId:
        convertedPatientId.present
            ? convertedPatientId.value
            : this.convertedPatientId,
    notes: notes.present ? notes.value : this.notes,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
  );
  Footfall copyWithCompanion(FootfallsCompanion data) {
    return Footfall(
      id: data.id.present ? data.id.value : this.id,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      date: data.date.present ? data.date.value : this.date,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      disease: data.disease.present ? data.disease.value : this.disease,
      convertedPatientId:
          data.convertedPatientId.present
              ? data.convertedPatientId.value
              : this.convertedPatientId,
      notes: data.notes.present ? data.notes.value : this.notes,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Footfall(')
          ..write('id: $id, ')
          ..write('clinicId: $clinicId, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('disease: $disease, ')
          ..write('convertedPatientId: $convertedPatientId, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clinicId,
    date,
    name,
    phone,
    disease,
    convertedPatientId,
    notes,
    isDeleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Footfall &&
          other.id == this.id &&
          other.clinicId == this.clinicId &&
          other.date == this.date &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.disease == this.disease &&
          other.convertedPatientId == this.convertedPatientId &&
          other.notes == this.notes &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt);
}

class FootfallsCompanion extends UpdateCompanion<Footfall> {
  final Value<String> id;
  final Value<String> clinicId;
  final Value<DateTime> date;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> disease;
  final Value<String?> convertedPatientId;
  final Value<String?> notes;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FootfallsCompanion({
    this.id = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.date = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.disease = const Value.absent(),
    this.convertedPatientId = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FootfallsCompanion.insert({
    required String id,
    required String clinicId,
    this.date = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.disease = const Value.absent(),
    this.convertedPatientId = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clinicId = Value(clinicId),
       name = Value(name);
  static Insertable<Footfall> custom({
    Expression<String>? id,
    Expression<String>? clinicId,
    Expression<DateTime>? date,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? disease,
    Expression<String>? convertedPatientId,
    Expression<String>? notes,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clinicId != null) 'clinic_id': clinicId,
      if (date != null) 'date': date,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (disease != null) 'disease': disease,
      if (convertedPatientId != null)
        'converted_patient_id': convertedPatientId,
      if (notes != null) 'notes': notes,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FootfallsCompanion copyWith({
    Value<String>? id,
    Value<String>? clinicId,
    Value<DateTime>? date,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? disease,
    Value<String?>? convertedPatientId,
    Value<String?>? notes,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FootfallsCompanion(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      date: date ?? this.date,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      disease: disease ?? this.disease,
      convertedPatientId: convertedPatientId ?? this.convertedPatientId,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (disease.present) {
      map['disease'] = Variable<String>(disease.value);
    }
    if (convertedPatientId.present) {
      map['converted_patient_id'] = Variable<String>(convertedPatientId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FootfallsCompanion(')
          ..write('id: $id, ')
          ..write('clinicId: $clinicId, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('disease: $disease, ')
          ..write('convertedPatientId: $convertedPatientId, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClinicsTable clinics = $ClinicsTable(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  late final $CashMemosTable cashMemos = $CashMemosTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ReviewRequestsTable reviewRequests = $ReviewRequestsTable(this);
  late final $FootfallsTable footfalls = $FootfallsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clinics,
    patients,
    visits,
    cashMemos,
    expenses,
    settings,
    reviewRequests,
    footfalls,
  ];
}

typedef $$ClinicsTableCreateCompanionBuilder =
    ClinicsCompanion Function({
      required String id,
      required String name,
      Value<String?> address,
      Value<String?> phone,
      Value<double> monthlyRent,
      Value<double> defaultConsultationFee,
      Value<String> openDays,
      Value<String> colorHex,
      Value<bool> isActive,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ClinicsTableUpdateCompanionBuilder =
    ClinicsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> address,
      Value<String?> phone,
      Value<double> monthlyRent,
      Value<double> defaultConsultationFee,
      Value<String> openDays,
      Value<String> colorHex,
      Value<bool> isActive,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ClinicsTableReferences
    extends BaseReferences<_$AppDatabase, $ClinicsTable, Clinic> {
  $$ClinicsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VisitsTable, List<Visit>> _visitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.visits,
    aliasName: $_aliasNameGenerator(db.clinics.id, db.visits.clinicId),
  );

  $$VisitsTableProcessedTableManager get visitsRefs {
    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.clinicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_visitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashMemosTable, List<CashMemo>>
  _cashMemosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashMemos,
    aliasName: $_aliasNameGenerator(db.clinics.id, db.cashMemos.clinicId),
  );

  $$CashMemosTableProcessedTableManager get cashMemosRefs {
    final manager = $$CashMemosTableTableManager(
      $_db,
      $_db.cashMemos,
    ).filter((f) => f.clinicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cashMemosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: $_aliasNameGenerator(db.clinics.id, db.expenses.clinicId),
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.clinicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReviewRequestsTable, List<ReviewRequest>>
  _reviewRequestsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewRequests,
    aliasName: $_aliasNameGenerator(db.clinics.id, db.reviewRequests.clinicId),
  );

  $$ReviewRequestsTableProcessedTableManager get reviewRequestsRefs {
    final manager = $$ReviewRequestsTableTableManager(
      $_db,
      $_db.reviewRequests,
    ).filter((f) => f.clinicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewRequestsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FootfallsTable, List<Footfall>>
  _footfallsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.footfalls,
    aliasName: $_aliasNameGenerator(db.clinics.id, db.footfalls.clinicId),
  );

  $$FootfallsTableProcessedTableManager get footfallsRefs {
    final manager = $$FootfallsTableTableManager(
      $_db,
      $_db.footfalls,
    ).filter((f) => f.clinicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_footfallsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClinicsTableFilterComposer
    extends Composer<_$AppDatabase, $ClinicsTable> {
  $$ClinicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyRent => $composableBuilder(
    column: $table.monthlyRent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultConsultationFee => $composableBuilder(
    column: $table.defaultConsultationFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openDays => $composableBuilder(
    column: $table.openDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> visitsRefs(
    Expression<bool> Function($$VisitsTableFilterComposer f) f,
  ) {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cashMemosRefs(
    Expression<bool> Function($$CashMemosTableFilterComposer f) f,
  ) {
    final $$CashMemosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMemos,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMemosTableFilterComposer(
            $db: $db,
            $table: $db.cashMemos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reviewRequestsRefs(
    Expression<bool> Function($$ReviewRequestsTableFilterComposer f) f,
  ) {
    final $$ReviewRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRequests,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewRequestsTableFilterComposer(
            $db: $db,
            $table: $db.reviewRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> footfallsRefs(
    Expression<bool> Function($$FootfallsTableFilterComposer f) f,
  ) {
    final $$FootfallsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.footfalls,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FootfallsTableFilterComposer(
            $db: $db,
            $table: $db.footfalls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClinicsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClinicsTable> {
  $$ClinicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyRent => $composableBuilder(
    column: $table.monthlyRent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultConsultationFee => $composableBuilder(
    column: $table.defaultConsultationFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openDays => $composableBuilder(
    column: $table.openDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClinicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClinicsTable> {
  $$ClinicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<double> get monthlyRent => $composableBuilder(
    column: $table.monthlyRent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultConsultationFee => $composableBuilder(
    column: $table.defaultConsultationFee,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openDays =>
      $composableBuilder(column: $table.openDays, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> visitsRefs<T extends Object>(
    Expression<T> Function($$VisitsTableAnnotationComposer a) f,
  ) {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cashMemosRefs<T extends Object>(
    Expression<T> Function($$CashMemosTableAnnotationComposer a) f,
  ) {
    final $$CashMemosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMemos,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMemosTableAnnotationComposer(
            $db: $db,
            $table: $db.cashMemos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reviewRequestsRefs<T extends Object>(
    Expression<T> Function($$ReviewRequestsTableAnnotationComposer a) f,
  ) {
    final $$ReviewRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRequests,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> footfallsRefs<T extends Object>(
    Expression<T> Function($$FootfallsTableAnnotationComposer a) f,
  ) {
    final $$FootfallsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.footfalls,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FootfallsTableAnnotationComposer(
            $db: $db,
            $table: $db.footfalls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClinicsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClinicsTable,
          Clinic,
          $$ClinicsTableFilterComposer,
          $$ClinicsTableOrderingComposer,
          $$ClinicsTableAnnotationComposer,
          $$ClinicsTableCreateCompanionBuilder,
          $$ClinicsTableUpdateCompanionBuilder,
          (Clinic, $$ClinicsTableReferences),
          Clinic,
          PrefetchHooks Function({
            bool visitsRefs,
            bool cashMemosRefs,
            bool expensesRefs,
            bool reviewRequestsRefs,
            bool footfallsRefs,
          })
        > {
  $$ClinicsTableTableManager(_$AppDatabase db, $ClinicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ClinicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ClinicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ClinicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<double> monthlyRent = const Value.absent(),
                Value<double> defaultConsultationFee = const Value.absent(),
                Value<String> openDays = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicsCompanion(
                id: id,
                name: name,
                address: address,
                phone: phone,
                monthlyRent: monthlyRent,
                defaultConsultationFee: defaultConsultationFee,
                openDays: openDays,
                colorHex: colorHex,
                isActive: isActive,
                isDeleted: isDeleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<double> monthlyRent = const Value.absent(),
                Value<double> defaultConsultationFee = const Value.absent(),
                Value<String> openDays = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicsCompanion.insert(
                id: id,
                name: name,
                address: address,
                phone: phone,
                monthlyRent: monthlyRent,
                defaultConsultationFee: defaultConsultationFee,
                openDays: openDays,
                colorHex: colorHex,
                isActive: isActive,
                isDeleted: isDeleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ClinicsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            visitsRefs = false,
            cashMemosRefs = false,
            expensesRefs = false,
            reviewRequestsRefs = false,
            footfallsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (visitsRefs) db.visits,
                if (cashMemosRefs) db.cashMemos,
                if (expensesRefs) db.expenses,
                if (reviewRequestsRefs) db.reviewRequests,
                if (footfallsRefs) db.footfalls,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (visitsRefs)
                    await $_getPrefetchedData<Clinic, $ClinicsTable, Visit>(
                      currentTable: table,
                      referencedTable: $$ClinicsTableReferences
                          ._visitsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ClinicsTableReferences(
                                db,
                                table,
                                p0,
                              ).visitsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.clinicId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (cashMemosRefs)
                    await $_getPrefetchedData<Clinic, $ClinicsTable, CashMemo>(
                      currentTable: table,
                      referencedTable: $$ClinicsTableReferences
                          ._cashMemosRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ClinicsTableReferences(
                                db,
                                table,
                                p0,
                              ).cashMemosRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.clinicId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (expensesRefs)
                    await $_getPrefetchedData<Clinic, $ClinicsTable, Expense>(
                      currentTable: table,
                      referencedTable: $$ClinicsTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ClinicsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.clinicId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (reviewRequestsRefs)
                    await $_getPrefetchedData<
                      Clinic,
                      $ClinicsTable,
                      ReviewRequest
                    >(
                      currentTable: table,
                      referencedTable: $$ClinicsTableReferences
                          ._reviewRequestsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ClinicsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewRequestsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.clinicId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (footfallsRefs)
                    await $_getPrefetchedData<Clinic, $ClinicsTable, Footfall>(
                      currentTable: table,
                      referencedTable: $$ClinicsTableReferences
                          ._footfallsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ClinicsTableReferences(
                                db,
                                table,
                                p0,
                              ).footfallsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.clinicId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ClinicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClinicsTable,
      Clinic,
      $$ClinicsTableFilterComposer,
      $$ClinicsTableOrderingComposer,
      $$ClinicsTableAnnotationComposer,
      $$ClinicsTableCreateCompanionBuilder,
      $$ClinicsTableUpdateCompanionBuilder,
      (Clinic, $$ClinicsTableReferences),
      Clinic,
      PrefetchHooks Function({
        bool visitsRefs,
        bool cashMemosRefs,
        bool expensesRefs,
        bool reviewRequestsRefs,
        bool footfallsRefs,
      })
    >;
typedef $$PatientsTableCreateCompanionBuilder =
    PatientsCompanion Function({
      required String id,
      Value<String> patientCode,
      Value<String> serialNo,
      required String name,
      required String phone,
      Value<String?> whatsapp,
      required int age,
      required String gender,
      Value<String?> area,
      Value<String?> address,
      Value<String?> occupation,
      Value<String> primaryClinicId,
      Value<String?> primaryDisease,
      Value<String?> referralSource,
      Value<String?> notes,
      Value<DateTime?> reviewAskedAt,
      Value<bool> reviewGiven,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PatientsTableUpdateCompanionBuilder =
    PatientsCompanion Function({
      Value<String> id,
      Value<String> patientCode,
      Value<String> serialNo,
      Value<String> name,
      Value<String> phone,
      Value<String?> whatsapp,
      Value<int> age,
      Value<String> gender,
      Value<String?> area,
      Value<String?> address,
      Value<String?> occupation,
      Value<String> primaryClinicId,
      Value<String?> primaryDisease,
      Value<String?> referralSource,
      Value<String?> notes,
      Value<DateTime?> reviewAskedAt,
      Value<bool> reviewGiven,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PatientsTableReferences
    extends BaseReferences<_$AppDatabase, $PatientsTable, Patient> {
  $$PatientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VisitsTable, List<Visit>> _visitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.visits,
    aliasName: $_aliasNameGenerator(db.patients.id, db.visits.patientId),
  );

  $$VisitsTableProcessedTableManager get visitsRefs {
    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_visitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashMemosTable, List<CashMemo>>
  _cashMemosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashMemos,
    aliasName: $_aliasNameGenerator(db.patients.id, db.cashMemos.patientId),
  );

  $$CashMemosTableProcessedTableManager get cashMemosRefs {
    final manager = $$CashMemosTableTableManager(
      $_db,
      $_db.cashMemos,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cashMemosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReviewRequestsTable, List<ReviewRequest>>
  _reviewRequestsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewRequests,
    aliasName: $_aliasNameGenerator(
      db.patients.id,
      db.reviewRequests.patientId,
    ),
  );

  $$ReviewRequestsTableProcessedTableManager get reviewRequestsRefs {
    final manager = $$ReviewRequestsTableTableManager(
      $_db,
      $_db.reviewRequests,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewRequestsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FootfallsTable, List<Footfall>>
  _footfallsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.footfalls,
    aliasName: $_aliasNameGenerator(
      db.patients.id,
      db.footfalls.convertedPatientId,
    ),
  );

  $$FootfallsTableProcessedTableManager get footfallsRefs {
    final manager = $$FootfallsTableTableManager($_db, $_db.footfalls).filter(
      (f) => f.convertedPatientId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_footfallsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientCode => $composableBuilder(
    column: $table.patientCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialNo => $composableBuilder(
    column: $table.serialNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatsapp => $composableBuilder(
    column: $table.whatsapp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occupation => $composableBuilder(
    column: $table.occupation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryClinicId => $composableBuilder(
    column: $table.primaryClinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryDisease => $composableBuilder(
    column: $table.primaryDisease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referralSource => $composableBuilder(
    column: $table.referralSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewAskedAt => $composableBuilder(
    column: $table.reviewAskedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reviewGiven => $composableBuilder(
    column: $table.reviewGiven,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> visitsRefs(
    Expression<bool> Function($$VisitsTableFilterComposer f) f,
  ) {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cashMemosRefs(
    Expression<bool> Function($$CashMemosTableFilterComposer f) f,
  ) {
    final $$CashMemosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMemos,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMemosTableFilterComposer(
            $db: $db,
            $table: $db.cashMemos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reviewRequestsRefs(
    Expression<bool> Function($$ReviewRequestsTableFilterComposer f) f,
  ) {
    final $$ReviewRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRequests,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewRequestsTableFilterComposer(
            $db: $db,
            $table: $db.reviewRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> footfallsRefs(
    Expression<bool> Function($$FootfallsTableFilterComposer f) f,
  ) {
    final $$FootfallsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.footfalls,
      getReferencedColumn: (t) => t.convertedPatientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FootfallsTableFilterComposer(
            $db: $db,
            $table: $db.footfalls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientCode => $composableBuilder(
    column: $table.patientCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialNo => $composableBuilder(
    column: $table.serialNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatsapp => $composableBuilder(
    column: $table.whatsapp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occupation => $composableBuilder(
    column: $table.occupation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryClinicId => $composableBuilder(
    column: $table.primaryClinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryDisease => $composableBuilder(
    column: $table.primaryDisease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referralSource => $composableBuilder(
    column: $table.referralSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewAskedAt => $composableBuilder(
    column: $table.reviewAskedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reviewGiven => $composableBuilder(
    column: $table.reviewGiven,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientCode => $composableBuilder(
    column: $table.patientCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serialNo =>
      $composableBuilder(column: $table.serialNo, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get whatsapp =>
      $composableBuilder(column: $table.whatsapp, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get occupation => $composableBuilder(
    column: $table.occupation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryClinicId => $composableBuilder(
    column: $table.primaryClinicId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryDisease => $composableBuilder(
    column: $table.primaryDisease,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referralSource => $composableBuilder(
    column: $table.referralSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewAskedAt => $composableBuilder(
    column: $table.reviewAskedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reviewGiven => $composableBuilder(
    column: $table.reviewGiven,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> visitsRefs<T extends Object>(
    Expression<T> Function($$VisitsTableAnnotationComposer a) f,
  ) {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cashMemosRefs<T extends Object>(
    Expression<T> Function($$CashMemosTableAnnotationComposer a) f,
  ) {
    final $$CashMemosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMemos,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMemosTableAnnotationComposer(
            $db: $db,
            $table: $db.cashMemos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reviewRequestsRefs<T extends Object>(
    Expression<T> Function($$ReviewRequestsTableAnnotationComposer a) f,
  ) {
    final $$ReviewRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRequests,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> footfallsRefs<T extends Object>(
    Expression<T> Function($$FootfallsTableAnnotationComposer a) f,
  ) {
    final $$FootfallsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.footfalls,
      getReferencedColumn: (t) => t.convertedPatientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FootfallsTableAnnotationComposer(
            $db: $db,
            $table: $db.footfalls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTable,
          Patient,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (Patient, $$PatientsTableReferences),
          Patient,
          PrefetchHooks Function({
            bool visitsRefs,
            bool cashMemosRefs,
            bool reviewRequestsRefs,
            bool footfallsRefs,
          })
        > {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientCode = const Value.absent(),
                Value<String> serialNo = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> whatsapp = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String?> area = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> occupation = const Value.absent(),
                Value<String> primaryClinicId = const Value.absent(),
                Value<String?> primaryDisease = const Value.absent(),
                Value<String?> referralSource = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> reviewAskedAt = const Value.absent(),
                Value<bool> reviewGiven = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion(
                id: id,
                patientCode: patientCode,
                serialNo: serialNo,
                name: name,
                phone: phone,
                whatsapp: whatsapp,
                age: age,
                gender: gender,
                area: area,
                address: address,
                occupation: occupation,
                primaryClinicId: primaryClinicId,
                primaryDisease: primaryDisease,
                referralSource: referralSource,
                notes: notes,
                reviewAskedAt: reviewAskedAt,
                reviewGiven: reviewGiven,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> patientCode = const Value.absent(),
                Value<String> serialNo = const Value.absent(),
                required String name,
                required String phone,
                Value<String?> whatsapp = const Value.absent(),
                required int age,
                required String gender,
                Value<String?> area = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> occupation = const Value.absent(),
                Value<String> primaryClinicId = const Value.absent(),
                Value<String?> primaryDisease = const Value.absent(),
                Value<String?> referralSource = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> reviewAskedAt = const Value.absent(),
                Value<bool> reviewGiven = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                patientCode: patientCode,
                serialNo: serialNo,
                name: name,
                phone: phone,
                whatsapp: whatsapp,
                age: age,
                gender: gender,
                area: area,
                address: address,
                occupation: occupation,
                primaryClinicId: primaryClinicId,
                primaryDisease: primaryDisease,
                referralSource: referralSource,
                notes: notes,
                reviewAskedAt: reviewAskedAt,
                reviewGiven: reviewGiven,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PatientsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            visitsRefs = false,
            cashMemosRefs = false,
            reviewRequestsRefs = false,
            footfallsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (visitsRefs) db.visits,
                if (cashMemosRefs) db.cashMemos,
                if (reviewRequestsRefs) db.reviewRequests,
                if (footfallsRefs) db.footfalls,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (visitsRefs)
                    await $_getPrefetchedData<Patient, $PatientsTable, Visit>(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._visitsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).visitsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.patientId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (cashMemosRefs)
                    await $_getPrefetchedData<
                      Patient,
                      $PatientsTable,
                      CashMemo
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._cashMemosRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).cashMemosRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.patientId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (reviewRequestsRefs)
                    await $_getPrefetchedData<
                      Patient,
                      $PatientsTable,
                      ReviewRequest
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._reviewRequestsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewRequestsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.patientId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (footfallsRefs)
                    await $_getPrefetchedData<
                      Patient,
                      $PatientsTable,
                      Footfall
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._footfallsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).footfallsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.convertedPatientId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTable,
      Patient,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (Patient, $$PatientsTableReferences),
      Patient,
      PrefetchHooks Function({
        bool visitsRefs,
        bool cashMemosRefs,
        bool reviewRequestsRefs,
        bool footfallsRefs,
      })
    >;
typedef $$VisitsTableCreateCompanionBuilder =
    VisitsCompanion Function({
      required String id,
      required String patientId,
      required String clinicId,
      required String visitType,
      Value<String> consultationType,
      required String disease,
      Value<String?> chiefComplaint,
      Value<String?> referralSource,
      Value<String?> outcome,
      required DateTime visitDate,
      Value<DateTime?> nextFollowUpDate,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$VisitsTableUpdateCompanionBuilder =
    VisitsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> clinicId,
      Value<String> visitType,
      Value<String> consultationType,
      Value<String> disease,
      Value<String?> chiefComplaint,
      Value<String?> referralSource,
      Value<String?> outcome,
      Value<DateTime> visitDate,
      Value<DateTime?> nextFollowUpDate,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$VisitsTableReferences
    extends BaseReferences<_$AppDatabase, $VisitsTable, Visit> {
  $$VisitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PatientsTable _patientIdTable(_$AppDatabase db) => db.patients
      .createAlias($_aliasNameGenerator(db.visits.patientId, db.patients.id));

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClinicsTable _clinicIdTable(_$AppDatabase db) => db.clinics
      .createAlias($_aliasNameGenerator(db.visits.clinicId, db.clinics.id));

  $$ClinicsTableProcessedTableManager get clinicId {
    final $_column = $_itemColumn<String>('clinic_id')!;

    final manager = $$ClinicsTableTableManager(
      $_db,
      $_db.clinics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clinicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CashMemosTable, List<CashMemo>>
  _cashMemosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashMemos,
    aliasName: $_aliasNameGenerator(db.visits.id, db.cashMemos.visitId),
  );

  $$CashMemosTableProcessedTableManager get cashMemosRefs {
    final manager = $$CashMemosTableTableManager(
      $_db,
      $_db.cashMemos,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cashMemosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VisitsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitType => $composableBuilder(
    column: $table.visitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consultationType => $composableBuilder(
    column: $table.consultationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get disease => $composableBuilder(
    column: $table.disease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referralSource => $composableBuilder(
    column: $table.referralSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextFollowUpDate => $composableBuilder(
    column: $table.nextFollowUpDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClinicsTableFilterComposer get clinicId {
    final $$ClinicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableFilterComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cashMemosRefs(
    Expression<bool> Function($$CashMemosTableFilterComposer f) f,
  ) {
    final $$CashMemosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMemos,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMemosTableFilterComposer(
            $db: $db,
            $table: $db.cashMemos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitType => $composableBuilder(
    column: $table.visitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consultationType => $composableBuilder(
    column: $table.consultationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get disease => $composableBuilder(
    column: $table.disease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referralSource => $composableBuilder(
    column: $table.referralSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextFollowUpDate => $composableBuilder(
    column: $table.nextFollowUpDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClinicsTableOrderingComposer get clinicId {
    final $$ClinicsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableOrderingComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get visitType =>
      $composableBuilder(column: $table.visitType, builder: (column) => column);

  GeneratedColumn<String> get consultationType => $composableBuilder(
    column: $table.consultationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get disease =>
      $composableBuilder(column: $table.disease, builder: (column) => column);

  GeneratedColumn<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referralSource => $composableBuilder(
    column: $table.referralSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<DateTime> get visitDate =>
      $composableBuilder(column: $table.visitDate, builder: (column) => column);

  GeneratedColumn<DateTime> get nextFollowUpDate => $composableBuilder(
    column: $table.nextFollowUpDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClinicsTableAnnotationComposer get clinicId {
    final $$ClinicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableAnnotationComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cashMemosRefs<T extends Object>(
    Expression<T> Function($$CashMemosTableAnnotationComposer a) f,
  ) {
    final $$CashMemosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMemos,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMemosTableAnnotationComposer(
            $db: $db,
            $table: $db.cashMemos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitsTable,
          Visit,
          $$VisitsTableFilterComposer,
          $$VisitsTableOrderingComposer,
          $$VisitsTableAnnotationComposer,
          $$VisitsTableCreateCompanionBuilder,
          $$VisitsTableUpdateCompanionBuilder,
          (Visit, $$VisitsTableReferences),
          Visit,
          PrefetchHooks Function({
            bool patientId,
            bool clinicId,
            bool cashMemosRefs,
          })
        > {
  $$VisitsTableTableManager(_$AppDatabase db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> clinicId = const Value.absent(),
                Value<String> visitType = const Value.absent(),
                Value<String> consultationType = const Value.absent(),
                Value<String> disease = const Value.absent(),
                Value<String?> chiefComplaint = const Value.absent(),
                Value<String?> referralSource = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<DateTime> visitDate = const Value.absent(),
                Value<DateTime?> nextFollowUpDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion(
                id: id,
                patientId: patientId,
                clinicId: clinicId,
                visitType: visitType,
                consultationType: consultationType,
                disease: disease,
                chiefComplaint: chiefComplaint,
                referralSource: referralSource,
                outcome: outcome,
                visitDate: visitDate,
                nextFollowUpDate: nextFollowUpDate,
                notes: notes,
                isDeleted: isDeleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String clinicId,
                required String visitType,
                Value<String> consultationType = const Value.absent(),
                required String disease,
                Value<String?> chiefComplaint = const Value.absent(),
                Value<String?> referralSource = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                required DateTime visitDate,
                Value<DateTime?> nextFollowUpDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion.insert(
                id: id,
                patientId: patientId,
                clinicId: clinicId,
                visitType: visitType,
                consultationType: consultationType,
                disease: disease,
                chiefComplaint: chiefComplaint,
                referralSource: referralSource,
                outcome: outcome,
                visitDate: visitDate,
                nextFollowUpDate: nextFollowUpDate,
                notes: notes,
                isDeleted: isDeleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$VisitsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            patientId = false,
            clinicId = false,
            cashMemosRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cashMemosRefs) db.cashMemos],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (patientId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.patientId,
                            referencedTable: $$VisitsTableReferences
                                ._patientIdTable(db),
                            referencedColumn:
                                $$VisitsTableReferences._patientIdTable(db).id,
                          )
                          as T;
                }
                if (clinicId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.clinicId,
                            referencedTable: $$VisitsTableReferences
                                ._clinicIdTable(db),
                            referencedColumn:
                                $$VisitsTableReferences._clinicIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cashMemosRefs)
                    await $_getPrefetchedData<Visit, $VisitsTable, CashMemo>(
                      currentTable: table,
                      referencedTable: $$VisitsTableReferences
                          ._cashMemosRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).cashMemosRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.visitId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitsTable,
      Visit,
      $$VisitsTableFilterComposer,
      $$VisitsTableOrderingComposer,
      $$VisitsTableAnnotationComposer,
      $$VisitsTableCreateCompanionBuilder,
      $$VisitsTableUpdateCompanionBuilder,
      (Visit, $$VisitsTableReferences),
      Visit,
      PrefetchHooks Function({
        bool patientId,
        bool clinicId,
        bool cashMemosRefs,
      })
    >;
typedef $$CashMemosTableCreateCompanionBuilder =
    CashMemosCompanion Function({
      required String id,
      required String memoNumber,
      required String patientId,
      Value<String> clinicId,
      Value<String?> visitId,
      Value<double> consultationFee,
      Value<double> medicineFee,
      Value<double> otherFee,
      Value<double> discount,
      required double total,
      Value<double> paidAmount,
      required String paymentMethod,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> memoDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CashMemosTableUpdateCompanionBuilder =
    CashMemosCompanion Function({
      Value<String> id,
      Value<String> memoNumber,
      Value<String> patientId,
      Value<String> clinicId,
      Value<String?> visitId,
      Value<double> consultationFee,
      Value<double> medicineFee,
      Value<double> otherFee,
      Value<double> discount,
      Value<double> total,
      Value<double> paidAmount,
      Value<String> paymentMethod,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> memoDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CashMemosTableReferences
    extends BaseReferences<_$AppDatabase, $CashMemosTable, CashMemo> {
  $$CashMemosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias(
        $_aliasNameGenerator(db.cashMemos.patientId, db.patients.id),
      );

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClinicsTable _clinicIdTable(_$AppDatabase db) => db.clinics
      .createAlias($_aliasNameGenerator(db.cashMemos.clinicId, db.clinics.id));

  $$ClinicsTableProcessedTableManager get clinicId {
    final $_column = $_itemColumn<String>('clinic_id')!;

    final manager = $$ClinicsTableTableManager(
      $_db,
      $_db.clinics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clinicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VisitsTable _visitIdTable(_$AppDatabase db) => db.visits.createAlias(
    $_aliasNameGenerator(db.cashMemos.visitId, db.visits.id),
  );

  $$VisitsTableProcessedTableManager? get visitId {
    final $_column = $_itemColumn<String>('visit_id');
    if ($_column == null) return null;
    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_visitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CashMemosTableFilterComposer
    extends Composer<_$AppDatabase, $CashMemosTable> {
  $$CashMemosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memoNumber => $composableBuilder(
    column: $table.memoNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get consultationFee => $composableBuilder(
    column: $table.consultationFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get medicineFee => $composableBuilder(
    column: $table.medicineFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get otherFee => $composableBuilder(
    column: $table.otherFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get memoDate => $composableBuilder(
    column: $table.memoDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClinicsTableFilterComposer get clinicId {
    final $$ClinicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableFilterComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VisitsTableFilterComposer get visitId {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashMemosTableOrderingComposer
    extends Composer<_$AppDatabase, $CashMemosTable> {
  $$CashMemosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoNumber => $composableBuilder(
    column: $table.memoNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get consultationFee => $composableBuilder(
    column: $table.consultationFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get medicineFee => $composableBuilder(
    column: $table.medicineFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get otherFee => $composableBuilder(
    column: $table.otherFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get memoDate => $composableBuilder(
    column: $table.memoDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClinicsTableOrderingComposer get clinicId {
    final $$ClinicsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableOrderingComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VisitsTableOrderingComposer get visitId {
    final $$VisitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableOrderingComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashMemosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashMemosTable> {
  $$CashMemosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memoNumber => $composableBuilder(
    column: $table.memoNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get consultationFee => $composableBuilder(
    column: $table.consultationFee,
    builder: (column) => column,
  );

  GeneratedColumn<double> get medicineFee => $composableBuilder(
    column: $table.medicineFee,
    builder: (column) => column,
  );

  GeneratedColumn<double> get otherFee =>
      $composableBuilder(column: $table.otherFee, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get memoDate =>
      $composableBuilder(column: $table.memoDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClinicsTableAnnotationComposer get clinicId {
    final $$ClinicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableAnnotationComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VisitsTableAnnotationComposer get visitId {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashMemosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashMemosTable,
          CashMemo,
          $$CashMemosTableFilterComposer,
          $$CashMemosTableOrderingComposer,
          $$CashMemosTableAnnotationComposer,
          $$CashMemosTableCreateCompanionBuilder,
          $$CashMemosTableUpdateCompanionBuilder,
          (CashMemo, $$CashMemosTableReferences),
          CashMemo,
          PrefetchHooks Function({bool patientId, bool clinicId, bool visitId})
        > {
  $$CashMemosTableTableManager(_$AppDatabase db, $CashMemosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CashMemosTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CashMemosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CashMemosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memoNumber = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> clinicId = const Value.absent(),
                Value<String?> visitId = const Value.absent(),
                Value<double> consultationFee = const Value.absent(),
                Value<double> medicineFee = const Value.absent(),
                Value<double> otherFee = const Value.absent(),
                Value<double> discount = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<double> paidAmount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> memoDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashMemosCompanion(
                id: id,
                memoNumber: memoNumber,
                patientId: patientId,
                clinicId: clinicId,
                visitId: visitId,
                consultationFee: consultationFee,
                medicineFee: medicineFee,
                otherFee: otherFee,
                discount: discount,
                total: total,
                paidAmount: paidAmount,
                paymentMethod: paymentMethod,
                notes: notes,
                isDeleted: isDeleted,
                memoDate: memoDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memoNumber,
                required String patientId,
                Value<String> clinicId = const Value.absent(),
                Value<String?> visitId = const Value.absent(),
                Value<double> consultationFee = const Value.absent(),
                Value<double> medicineFee = const Value.absent(),
                Value<double> otherFee = const Value.absent(),
                Value<double> discount = const Value.absent(),
                required double total,
                Value<double> paidAmount = const Value.absent(),
                required String paymentMethod,
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> memoDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashMemosCompanion.insert(
                id: id,
                memoNumber: memoNumber,
                patientId: patientId,
                clinicId: clinicId,
                visitId: visitId,
                consultationFee: consultationFee,
                medicineFee: medicineFee,
                otherFee: otherFee,
                discount: discount,
                total: total,
                paidAmount: paidAmount,
                paymentMethod: paymentMethod,
                notes: notes,
                isDeleted: isDeleted,
                memoDate: memoDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CashMemosTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            patientId = false,
            clinicId = false,
            visitId = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (patientId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.patientId,
                            referencedTable: $$CashMemosTableReferences
                                ._patientIdTable(db),
                            referencedColumn:
                                $$CashMemosTableReferences
                                    ._patientIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (clinicId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.clinicId,
                            referencedTable: $$CashMemosTableReferences
                                ._clinicIdTable(db),
                            referencedColumn:
                                $$CashMemosTableReferences
                                    ._clinicIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (visitId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.visitId,
                            referencedTable: $$CashMemosTableReferences
                                ._visitIdTable(db),
                            referencedColumn:
                                $$CashMemosTableReferences._visitIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CashMemosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashMemosTable,
      CashMemo,
      $$CashMemosTableFilterComposer,
      $$CashMemosTableOrderingComposer,
      $$CashMemosTableAnnotationComposer,
      $$CashMemosTableCreateCompanionBuilder,
      $$CashMemosTableUpdateCompanionBuilder,
      (CashMemo, $$CashMemosTableReferences),
      CashMemo,
      PrefetchHooks Function({bool patientId, bool clinicId, bool visitId})
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String id,
      required String clinicId,
      required String category,
      Value<String?> subcategory,
      required double amount,
      Value<String> paymentMethod,
      Value<bool> isRecurring,
      Value<String?> notes,
      required DateTime date,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> id,
      Value<String> clinicId,
      Value<String> category,
      Value<String?> subcategory,
      Value<double> amount,
      Value<String> paymentMethod,
      Value<bool> isRecurring,
      Value<String?> notes,
      Value<DateTime> date,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClinicsTable _clinicIdTable(_$AppDatabase db) => db.clinics
      .createAlias($_aliasNameGenerator(db.expenses.clinicId, db.clinics.id));

  $$ClinicsTableProcessedTableManager get clinicId {
    final $_column = $_itemColumn<String>('clinic_id')!;

    final manager = $$ClinicsTableTableManager(
      $_db,
      $_db.clinics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clinicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClinicsTableFilterComposer get clinicId {
    final $$ClinicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableFilterComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClinicsTableOrderingComposer get clinicId {
    final $$ClinicsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableOrderingComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClinicsTableAnnotationComposer get clinicId {
    final $$ClinicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableAnnotationComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({bool clinicId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clinicId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                clinicId: clinicId,
                category: category,
                subcategory: subcategory,
                amount: amount,
                paymentMethod: paymentMethod,
                isRecurring: isRecurring,
                notes: notes,
                date: date,
                isDeleted: isDeleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clinicId,
                required String category,
                Value<String?> subcategory = const Value.absent(),
                required double amount,
                Value<String> paymentMethod = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime date,
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                clinicId: clinicId,
                category: category,
                subcategory: subcategory,
                amount: amount,
                paymentMethod: paymentMethod,
                isRecurring: isRecurring,
                notes: notes,
                date: date,
                isDeleted: isDeleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ExpensesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({clinicId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (clinicId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.clinicId,
                            referencedTable: $$ExpensesTableReferences
                                ._clinicIdTable(db),
                            referencedColumn:
                                $$ExpensesTableReferences._clinicIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool clinicId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$ReviewRequestsTableCreateCompanionBuilder =
    ReviewRequestsCompanion Function({
      required String id,
      required String patientId,
      Value<String?> clinicId,
      Value<DateTime> requestedAt,
      Value<DateTime?> reviewedAt,
      Value<int?> rating,
      Value<String> platform,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ReviewRequestsTableUpdateCompanionBuilder =
    ReviewRequestsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String?> clinicId,
      Value<DateTime> requestedAt,
      Value<DateTime?> reviewedAt,
      Value<int?> rating,
      Value<String> platform,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ReviewRequestsTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewRequestsTable, ReviewRequest> {
  $$ReviewRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias(
        $_aliasNameGenerator(db.reviewRequests.patientId, db.patients.id),
      );

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClinicsTable _clinicIdTable(_$AppDatabase db) =>
      db.clinics.createAlias(
        $_aliasNameGenerator(db.reviewRequests.clinicId, db.clinics.id),
      );

  $$ClinicsTableProcessedTableManager? get clinicId {
    final $_column = $_itemColumn<String>('clinic_id');
    if ($_column == null) return null;
    final manager = $$ClinicsTableTableManager(
      $_db,
      $_db.clinics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clinicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewRequestsTable> {
  $$ReviewRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClinicsTableFilterComposer get clinicId {
    final $$ClinicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableFilterComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewRequestsTable> {
  $$ReviewRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClinicsTableOrderingComposer get clinicId {
    final $$ClinicsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableOrderingComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewRequestsTable> {
  $$ReviewRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClinicsTableAnnotationComposer get clinicId {
    final $$ClinicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableAnnotationComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewRequestsTable,
          ReviewRequest,
          $$ReviewRequestsTableFilterComposer,
          $$ReviewRequestsTableOrderingComposer,
          $$ReviewRequestsTableAnnotationComposer,
          $$ReviewRequestsTableCreateCompanionBuilder,
          $$ReviewRequestsTableUpdateCompanionBuilder,
          (ReviewRequest, $$ReviewRequestsTableReferences),
          ReviewRequest,
          PrefetchHooks Function({bool patientId, bool clinicId})
        > {
  $$ReviewRequestsTableTableManager(
    _$AppDatabase db,
    $ReviewRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ReviewRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$ReviewRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ReviewRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<DateTime> requestedAt = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewRequestsCompanion(
                id: id,
                patientId: patientId,
                clinicId: clinicId,
                requestedAt: requestedAt,
                reviewedAt: reviewedAt,
                rating: rating,
                platform: platform,
                notes: notes,
                isDeleted: isDeleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                Value<String?> clinicId = const Value.absent(),
                Value<DateTime> requestedAt = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewRequestsCompanion.insert(
                id: id,
                patientId: patientId,
                clinicId: clinicId,
                requestedAt: requestedAt,
                reviewedAt: reviewedAt,
                rating: rating,
                platform: platform,
                notes: notes,
                isDeleted: isDeleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ReviewRequestsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({patientId = false, clinicId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (patientId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.patientId,
                            referencedTable: $$ReviewRequestsTableReferences
                                ._patientIdTable(db),
                            referencedColumn:
                                $$ReviewRequestsTableReferences
                                    ._patientIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (clinicId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.clinicId,
                            referencedTable: $$ReviewRequestsTableReferences
                                ._clinicIdTable(db),
                            referencedColumn:
                                $$ReviewRequestsTableReferences
                                    ._clinicIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReviewRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewRequestsTable,
      ReviewRequest,
      $$ReviewRequestsTableFilterComposer,
      $$ReviewRequestsTableOrderingComposer,
      $$ReviewRequestsTableAnnotationComposer,
      $$ReviewRequestsTableCreateCompanionBuilder,
      $$ReviewRequestsTableUpdateCompanionBuilder,
      (ReviewRequest, $$ReviewRequestsTableReferences),
      ReviewRequest,
      PrefetchHooks Function({bool patientId, bool clinicId})
    >;
typedef $$FootfallsTableCreateCompanionBuilder =
    FootfallsCompanion Function({
      required String id,
      required String clinicId,
      Value<DateTime> date,
      required String name,
      Value<String?> phone,
      Value<String?> disease,
      Value<String?> convertedPatientId,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$FootfallsTableUpdateCompanionBuilder =
    FootfallsCompanion Function({
      Value<String> id,
      Value<String> clinicId,
      Value<DateTime> date,
      Value<String> name,
      Value<String?> phone,
      Value<String?> disease,
      Value<String?> convertedPatientId,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$FootfallsTableReferences
    extends BaseReferences<_$AppDatabase, $FootfallsTable, Footfall> {
  $$FootfallsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClinicsTable _clinicIdTable(_$AppDatabase db) => db.clinics
      .createAlias($_aliasNameGenerator(db.footfalls.clinicId, db.clinics.id));

  $$ClinicsTableProcessedTableManager get clinicId {
    final $_column = $_itemColumn<String>('clinic_id')!;

    final manager = $$ClinicsTableTableManager(
      $_db,
      $_db.clinics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clinicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PatientsTable _convertedPatientIdTable(_$AppDatabase db) =>
      db.patients.createAlias(
        $_aliasNameGenerator(db.footfalls.convertedPatientId, db.patients.id),
      );

  $$PatientsTableProcessedTableManager? get convertedPatientId {
    final $_column = $_itemColumn<String>('converted_patient_id');
    if ($_column == null) return null;
    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_convertedPatientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FootfallsTableFilterComposer
    extends Composer<_$AppDatabase, $FootfallsTable> {
  $$FootfallsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get disease => $composableBuilder(
    column: $table.disease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClinicsTableFilterComposer get clinicId {
    final $$ClinicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableFilterComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableFilterComposer get convertedPatientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.convertedPatientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FootfallsTableOrderingComposer
    extends Composer<_$AppDatabase, $FootfallsTable> {
  $$FootfallsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get disease => $composableBuilder(
    column: $table.disease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClinicsTableOrderingComposer get clinicId {
    final $$ClinicsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableOrderingComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableOrderingComposer get convertedPatientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.convertedPatientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FootfallsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FootfallsTable> {
  $$FootfallsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get disease =>
      $composableBuilder(column: $table.disease, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClinicsTableAnnotationComposer get clinicId {
    final $$ClinicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clinicId,
      referencedTable: $db.clinics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicsTableAnnotationComposer(
            $db: $db,
            $table: $db.clinics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientsTableAnnotationComposer get convertedPatientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.convertedPatientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FootfallsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FootfallsTable,
          Footfall,
          $$FootfallsTableFilterComposer,
          $$FootfallsTableOrderingComposer,
          $$FootfallsTableAnnotationComposer,
          $$FootfallsTableCreateCompanionBuilder,
          $$FootfallsTableUpdateCompanionBuilder,
          (Footfall, $$FootfallsTableReferences),
          Footfall,
          PrefetchHooks Function({bool clinicId, bool convertedPatientId})
        > {
  $$FootfallsTableTableManager(_$AppDatabase db, $FootfallsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FootfallsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$FootfallsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$FootfallsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clinicId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> disease = const Value.absent(),
                Value<String?> convertedPatientId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FootfallsCompanion(
                id: id,
                clinicId: clinicId,
                date: date,
                name: name,
                phone: phone,
                disease: disease,
                convertedPatientId: convertedPatientId,
                notes: notes,
                isDeleted: isDeleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clinicId,
                Value<DateTime> date = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> disease = const Value.absent(),
                Value<String?> convertedPatientId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FootfallsCompanion.insert(
                id: id,
                clinicId: clinicId,
                date: date,
                name: name,
                phone: phone,
                disease: disease,
                convertedPatientId: convertedPatientId,
                notes: notes,
                isDeleted: isDeleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$FootfallsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            clinicId = false,
            convertedPatientId = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (clinicId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.clinicId,
                            referencedTable: $$FootfallsTableReferences
                                ._clinicIdTable(db),
                            referencedColumn:
                                $$FootfallsTableReferences
                                    ._clinicIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (convertedPatientId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.convertedPatientId,
                            referencedTable: $$FootfallsTableReferences
                                ._convertedPatientIdTable(db),
                            referencedColumn:
                                $$FootfallsTableReferences
                                    ._convertedPatientIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FootfallsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FootfallsTable,
      Footfall,
      $$FootfallsTableFilterComposer,
      $$FootfallsTableOrderingComposer,
      $$FootfallsTableAnnotationComposer,
      $$FootfallsTableCreateCompanionBuilder,
      $$FootfallsTableUpdateCompanionBuilder,
      (Footfall, $$FootfallsTableReferences),
      Footfall,
      PrefetchHooks Function({bool clinicId, bool convertedPatientId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClinicsTableTableManager get clinics =>
      $$ClinicsTableTableManager(_db, _db.clinics);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
  $$CashMemosTableTableManager get cashMemos =>
      $$CashMemosTableTableManager(_db, _db.cashMemos);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ReviewRequestsTableTableManager get reviewRequests =>
      $$ReviewRequestsTableTableManager(_db, _db.reviewRequests);
  $$FootfallsTableTableManager get footfalls =>
      $$FootfallsTableTableManager(_db, _db.footfalls);
}
