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

class $CampsTable extends Camps with TableInfo<$CampsTable, Camp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _attendanceMeta = const VerificationMeta(
    'attendance',
  );
  @override
  late final GeneratedColumn<int> attendance = GeneratedColumn<int>(
    'attendance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    name,
    date,
    location,
    cost,
    attendance,
    clinicId,
    notes,
    isDeleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'camps';
  @override
  VerificationContext validateIntegrity(
    Insertable<Camp> instance, {
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
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('attendance')) {
      context.handle(
        _attendanceMeta,
        attendance.isAcceptableOrUnknown(data['attendance']!, _attendanceMeta),
      );
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
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
  Camp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Camp(
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
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      cost:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}cost'],
          )!,
      attendance:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}attendance'],
          )!,
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
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
  $CampsTable createAlias(String alias) {
    return $CampsTable(attachedDatabase, alias);
  }
}

class Camp extends DataClass implements Insertable<Camp> {
  final String id;
  final String name;
  final DateTime date;
  final String? location;
  final double cost;
  final int attendance;
  final String? clinicId;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  const Camp({
    required this.id,
    required this.name,
    required this.date,
    this.location,
    required this.cost,
    required this.attendance,
    this.clinicId,
    this.notes,
    required this.isDeleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['cost'] = Variable<double>(cost);
    map['attendance'] = Variable<int>(attendance);
    if (!nullToAbsent || clinicId != null) {
      map['clinic_id'] = Variable<String>(clinicId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CampsCompanion toCompanion(bool nullToAbsent) {
    return CampsCompanion(
      id: Value(id),
      name: Value(name),
      date: Value(date),
      location:
          location == null && nullToAbsent
              ? const Value.absent()
              : Value(location),
      cost: Value(cost),
      attendance: Value(attendance),
      clinicId:
          clinicId == null && nullToAbsent
              ? const Value.absent()
              : Value(clinicId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
    );
  }

  factory Camp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Camp(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<DateTime>(json['date']),
      location: serializer.fromJson<String?>(json['location']),
      cost: serializer.fromJson<double>(json['cost']),
      attendance: serializer.fromJson<int>(json['attendance']),
      clinicId: serializer.fromJson<String?>(json['clinicId']),
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
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<DateTime>(date),
      'location': serializer.toJson<String?>(location),
      'cost': serializer.toJson<double>(cost),
      'attendance': serializer.toJson<int>(attendance),
      'clinicId': serializer.toJson<String?>(clinicId),
      'notes': serializer.toJson<String?>(notes),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Camp copyWith({
    String? id,
    String? name,
    DateTime? date,
    Value<String?> location = const Value.absent(),
    double? cost,
    int? attendance,
    Value<String?> clinicId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
  }) => Camp(
    id: id ?? this.id,
    name: name ?? this.name,
    date: date ?? this.date,
    location: location.present ? location.value : this.location,
    cost: cost ?? this.cost,
    attendance: attendance ?? this.attendance,
    clinicId: clinicId.present ? clinicId.value : this.clinicId,
    notes: notes.present ? notes.value : this.notes,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
  );
  Camp copyWithCompanion(CampsCompanion data) {
    return Camp(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      date: data.date.present ? data.date.value : this.date,
      location: data.location.present ? data.location.value : this.location,
      cost: data.cost.present ? data.cost.value : this.cost,
      attendance:
          data.attendance.present ? data.attendance.value : this.attendance,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      notes: data.notes.present ? data.notes.value : this.notes,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Camp(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('location: $location, ')
          ..write('cost: $cost, ')
          ..write('attendance: $attendance, ')
          ..write('clinicId: $clinicId, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    date,
    location,
    cost,
    attendance,
    clinicId,
    notes,
    isDeleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Camp &&
          other.id == this.id &&
          other.name == this.name &&
          other.date == this.date &&
          other.location == this.location &&
          other.cost == this.cost &&
          other.attendance == this.attendance &&
          other.clinicId == this.clinicId &&
          other.notes == this.notes &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt);
}

class CampsCompanion extends UpdateCompanion<Camp> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> date;
  final Value<String?> location;
  final Value<double> cost;
  final Value<int> attendance;
  final Value<String?> clinicId;
  final Value<String?> notes;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CampsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.location = const Value.absent(),
    this.cost = const Value.absent(),
    this.attendance = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampsCompanion.insert({
    required String id,
    required String name,
    this.date = const Value.absent(),
    this.location = const Value.absent(),
    this.cost = const Value.absent(),
    this.attendance = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Camp> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? date,
    Expression<String>? location,
    Expression<double>? cost,
    Expression<int>? attendance,
    Expression<String>? clinicId,
    Expression<String>? notes,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (location != null) 'location': location,
      if (cost != null) 'cost': cost,
      if (attendance != null) 'attendance': attendance,
      if (clinicId != null) 'clinic_id': clinicId,
      if (notes != null) 'notes': notes,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? date,
    Value<String?>? location,
    Value<double>? cost,
    Value<int>? attendance,
    Value<String?>? clinicId,
    Value<String?>? notes,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CampsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      cost: cost ?? this.cost,
      attendance: attendance ?? this.attendance,
      clinicId: clinicId ?? this.clinicId,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (attendance.present) {
      map['attendance'] = Variable<int>(attendance.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
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
    return (StringBuffer('CampsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('location: $location, ')
          ..write('cost: $cost, ')
          ..write('attendance: $attendance, ')
          ..write('clinicId: $clinicId, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatientCaseRecordsTable extends PatientCaseRecords
    with TableInfo<$PatientCaseRecordsTable, PatientCaseRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientCaseRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _chiefComplaintsJsonMeta =
      const VerificationMeta('chiefComplaintsJson');
  @override
  late final GeneratedColumn<String> chiefComplaintsJson =
      GeneratedColumn<String>(
        'chief_complaints_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hpiMeta = const VerificationMeta('hpi');
  @override
  late final GeneratedColumn<String> hpi = GeneratedColumn<String>(
    'hpi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pastHistoryJsonMeta = const VerificationMeta(
    'pastHistoryJson',
  );
  @override
  late final GeneratedColumn<String> pastHistoryJson = GeneratedColumn<String>(
    'past_history_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyHistoryJsonMeta = const VerificationMeta(
    'familyHistoryJson',
  );
  @override
  late final GeneratedColumn<String> familyHistoryJson =
      GeneratedColumn<String>(
        'family_history_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _developmentalHistoryJsonMeta =
      const VerificationMeta('developmentalHistoryJson');
  @override
  late final GeneratedColumn<String> developmentalHistoryJson =
      GeneratedColumn<String>(
        'developmental_history_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _physicalGeneralsJsonMeta =
      const VerificationMeta('physicalGeneralsJson');
  @override
  late final GeneratedColumn<String> physicalGeneralsJson =
      GeneratedColumn<String>(
        'physical_generals_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mentalGeneralsJsonMeta =
      const VerificationMeta('mentalGeneralsJson');
  @override
  late final GeneratedColumn<String> mentalGeneralsJson =
      GeneratedColumn<String>(
        'mental_generals_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lifestyleJsonMeta = const VerificationMeta(
    'lifestyleJson',
  );
  @override
  late final GeneratedColumn<String> lifestyleJson = GeneratedColumn<String>(
    'lifestyle_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicalExamJsonMeta = const VerificationMeta(
    'clinicalExamJson',
  );
  @override
  late final GeneratedColumn<String> clinicalExamJson = GeneratedColumn<String>(
    'clinical_exam_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _miasmaticAnalysisJsonMeta =
      const VerificationMeta('miasmaticAnalysisJson');
  @override
  late final GeneratedColumn<String> miasmaticAnalysisJson =
      GeneratedColumn<String>(
        'miasmatic_analysis_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _caseTotalityJsonMeta = const VerificationMeta(
    'caseTotalityJson',
  );
  @override
  late final GeneratedColumn<String> caseTotalityJson = GeneratedColumn<String>(
    'case_totality_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baselinePrescriptionJsonMeta =
      const VerificationMeta('baselinePrescriptionJson');
  @override
  late final GeneratedColumn<String> baselinePrescriptionJson =
      GeneratedColumn<String>(
        'baseline_prescription_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _investigationsJsonMeta =
      const VerificationMeta('investigationsJson');
  @override
  late final GeneratedColumn<String> investigationsJson =
      GeneratedColumn<String>(
        'investigations_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _followUpNotesMeta = const VerificationMeta(
    'followUpNotes',
  );
  @override
  late final GeneratedColumn<String> followUpNotes = GeneratedColumn<String>(
    'follow_up_notes',
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
    patientId,
    recordDate,
    chiefComplaintsJson,
    hpi,
    pastHistoryJson,
    familyHistoryJson,
    developmentalHistoryJson,
    physicalGeneralsJson,
    mentalGeneralsJson,
    lifestyleJson,
    clinicalExamJson,
    miasmaticAnalysisJson,
    caseTotalityJson,
    baselinePrescriptionJson,
    investigationsJson,
    followUpNotes,
    outcome,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patient_case_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatientCaseRecord> instance, {
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
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    }
    if (data.containsKey('chief_complaints_json')) {
      context.handle(
        _chiefComplaintsJsonMeta,
        chiefComplaintsJson.isAcceptableOrUnknown(
          data['chief_complaints_json']!,
          _chiefComplaintsJsonMeta,
        ),
      );
    }
    if (data.containsKey('hpi')) {
      context.handle(
        _hpiMeta,
        hpi.isAcceptableOrUnknown(data['hpi']!, _hpiMeta),
      );
    }
    if (data.containsKey('past_history_json')) {
      context.handle(
        _pastHistoryJsonMeta,
        pastHistoryJson.isAcceptableOrUnknown(
          data['past_history_json']!,
          _pastHistoryJsonMeta,
        ),
      );
    }
    if (data.containsKey('family_history_json')) {
      context.handle(
        _familyHistoryJsonMeta,
        familyHistoryJson.isAcceptableOrUnknown(
          data['family_history_json']!,
          _familyHistoryJsonMeta,
        ),
      );
    }
    if (data.containsKey('developmental_history_json')) {
      context.handle(
        _developmentalHistoryJsonMeta,
        developmentalHistoryJson.isAcceptableOrUnknown(
          data['developmental_history_json']!,
          _developmentalHistoryJsonMeta,
        ),
      );
    }
    if (data.containsKey('physical_generals_json')) {
      context.handle(
        _physicalGeneralsJsonMeta,
        physicalGeneralsJson.isAcceptableOrUnknown(
          data['physical_generals_json']!,
          _physicalGeneralsJsonMeta,
        ),
      );
    }
    if (data.containsKey('mental_generals_json')) {
      context.handle(
        _mentalGeneralsJsonMeta,
        mentalGeneralsJson.isAcceptableOrUnknown(
          data['mental_generals_json']!,
          _mentalGeneralsJsonMeta,
        ),
      );
    }
    if (data.containsKey('lifestyle_json')) {
      context.handle(
        _lifestyleJsonMeta,
        lifestyleJson.isAcceptableOrUnknown(
          data['lifestyle_json']!,
          _lifestyleJsonMeta,
        ),
      );
    }
    if (data.containsKey('clinical_exam_json')) {
      context.handle(
        _clinicalExamJsonMeta,
        clinicalExamJson.isAcceptableOrUnknown(
          data['clinical_exam_json']!,
          _clinicalExamJsonMeta,
        ),
      );
    }
    if (data.containsKey('miasmatic_analysis_json')) {
      context.handle(
        _miasmaticAnalysisJsonMeta,
        miasmaticAnalysisJson.isAcceptableOrUnknown(
          data['miasmatic_analysis_json']!,
          _miasmaticAnalysisJsonMeta,
        ),
      );
    }
    if (data.containsKey('case_totality_json')) {
      context.handle(
        _caseTotalityJsonMeta,
        caseTotalityJson.isAcceptableOrUnknown(
          data['case_totality_json']!,
          _caseTotalityJsonMeta,
        ),
      );
    }
    if (data.containsKey('baseline_prescription_json')) {
      context.handle(
        _baselinePrescriptionJsonMeta,
        baselinePrescriptionJson.isAcceptableOrUnknown(
          data['baseline_prescription_json']!,
          _baselinePrescriptionJsonMeta,
        ),
      );
    }
    if (data.containsKey('investigations_json')) {
      context.handle(
        _investigationsJsonMeta,
        investigationsJson.isAcceptableOrUnknown(
          data['investigations_json']!,
          _investigationsJsonMeta,
        ),
      );
    }
    if (data.containsKey('follow_up_notes')) {
      context.handle(
        _followUpNotesMeta,
        followUpNotes.isAcceptableOrUnknown(
          data['follow_up_notes']!,
          _followUpNotesMeta,
        ),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
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
  PatientCaseRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientCaseRecord(
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
      recordDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}record_date'],
          )!,
      chiefComplaintsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chief_complaints_json'],
      ),
      hpi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hpi'],
      ),
      pastHistoryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}past_history_json'],
      ),
      familyHistoryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_history_json'],
      ),
      developmentalHistoryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}developmental_history_json'],
      ),
      physicalGeneralsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}physical_generals_json'],
      ),
      mentalGeneralsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mental_generals_json'],
      ),
      lifestyleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifestyle_json'],
      ),
      clinicalExamJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinical_exam_json'],
      ),
      miasmaticAnalysisJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}miasmatic_analysis_json'],
      ),
      caseTotalityJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_totality_json'],
      ),
      baselinePrescriptionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baseline_prescription_json'],
      ),
      investigationsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}investigations_json'],
      ),
      followUpNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}follow_up_notes'],
      ),
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
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
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $PatientCaseRecordsTable createAlias(String alias) {
    return $PatientCaseRecordsTable(attachedDatabase, alias);
  }
}

class PatientCaseRecord extends DataClass
    implements Insertable<PatientCaseRecord> {
  final String id;
  final String patientId;
  final DateTime recordDate;
  final String? chiefComplaintsJson;
  final String? hpi;
  final String? pastHistoryJson;
  final String? familyHistoryJson;
  final String? developmentalHistoryJson;
  final String? physicalGeneralsJson;
  final String? mentalGeneralsJson;
  final String? lifestyleJson;
  final String? clinicalExamJson;
  final String? miasmaticAnalysisJson;
  final String? caseTotalityJson;
  final String? baselinePrescriptionJson;
  final String? investigationsJson;
  final String? followUpNotes;
  final String? outcome;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PatientCaseRecord({
    required this.id,
    required this.patientId,
    required this.recordDate,
    this.chiefComplaintsJson,
    this.hpi,
    this.pastHistoryJson,
    this.familyHistoryJson,
    this.developmentalHistoryJson,
    this.physicalGeneralsJson,
    this.mentalGeneralsJson,
    this.lifestyleJson,
    this.clinicalExamJson,
    this.miasmaticAnalysisJson,
    this.caseTotalityJson,
    this.baselinePrescriptionJson,
    this.investigationsJson,
    this.followUpNotes,
    this.outcome,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['record_date'] = Variable<DateTime>(recordDate);
    if (!nullToAbsent || chiefComplaintsJson != null) {
      map['chief_complaints_json'] = Variable<String>(chiefComplaintsJson);
    }
    if (!nullToAbsent || hpi != null) {
      map['hpi'] = Variable<String>(hpi);
    }
    if (!nullToAbsent || pastHistoryJson != null) {
      map['past_history_json'] = Variable<String>(pastHistoryJson);
    }
    if (!nullToAbsent || familyHistoryJson != null) {
      map['family_history_json'] = Variable<String>(familyHistoryJson);
    }
    if (!nullToAbsent || developmentalHistoryJson != null) {
      map['developmental_history_json'] = Variable<String>(
        developmentalHistoryJson,
      );
    }
    if (!nullToAbsent || physicalGeneralsJson != null) {
      map['physical_generals_json'] = Variable<String>(physicalGeneralsJson);
    }
    if (!nullToAbsent || mentalGeneralsJson != null) {
      map['mental_generals_json'] = Variable<String>(mentalGeneralsJson);
    }
    if (!nullToAbsent || lifestyleJson != null) {
      map['lifestyle_json'] = Variable<String>(lifestyleJson);
    }
    if (!nullToAbsent || clinicalExamJson != null) {
      map['clinical_exam_json'] = Variable<String>(clinicalExamJson);
    }
    if (!nullToAbsent || miasmaticAnalysisJson != null) {
      map['miasmatic_analysis_json'] = Variable<String>(miasmaticAnalysisJson);
    }
    if (!nullToAbsent || caseTotalityJson != null) {
      map['case_totality_json'] = Variable<String>(caseTotalityJson);
    }
    if (!nullToAbsent || baselinePrescriptionJson != null) {
      map['baseline_prescription_json'] = Variable<String>(
        baselinePrescriptionJson,
      );
    }
    if (!nullToAbsent || investigationsJson != null) {
      map['investigations_json'] = Variable<String>(investigationsJson);
    }
    if (!nullToAbsent || followUpNotes != null) {
      map['follow_up_notes'] = Variable<String>(followUpNotes);
    }
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PatientCaseRecordsCompanion toCompanion(bool nullToAbsent) {
    return PatientCaseRecordsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      recordDate: Value(recordDate),
      chiefComplaintsJson:
          chiefComplaintsJson == null && nullToAbsent
              ? const Value.absent()
              : Value(chiefComplaintsJson),
      hpi: hpi == null && nullToAbsent ? const Value.absent() : Value(hpi),
      pastHistoryJson:
          pastHistoryJson == null && nullToAbsent
              ? const Value.absent()
              : Value(pastHistoryJson),
      familyHistoryJson:
          familyHistoryJson == null && nullToAbsent
              ? const Value.absent()
              : Value(familyHistoryJson),
      developmentalHistoryJson:
          developmentalHistoryJson == null && nullToAbsent
              ? const Value.absent()
              : Value(developmentalHistoryJson),
      physicalGeneralsJson:
          physicalGeneralsJson == null && nullToAbsent
              ? const Value.absent()
              : Value(physicalGeneralsJson),
      mentalGeneralsJson:
          mentalGeneralsJson == null && nullToAbsent
              ? const Value.absent()
              : Value(mentalGeneralsJson),
      lifestyleJson:
          lifestyleJson == null && nullToAbsent
              ? const Value.absent()
              : Value(lifestyleJson),
      clinicalExamJson:
          clinicalExamJson == null && nullToAbsent
              ? const Value.absent()
              : Value(clinicalExamJson),
      miasmaticAnalysisJson:
          miasmaticAnalysisJson == null && nullToAbsent
              ? const Value.absent()
              : Value(miasmaticAnalysisJson),
      caseTotalityJson:
          caseTotalityJson == null && nullToAbsent
              ? const Value.absent()
              : Value(caseTotalityJson),
      baselinePrescriptionJson:
          baselinePrescriptionJson == null && nullToAbsent
              ? const Value.absent()
              : Value(baselinePrescriptionJson),
      investigationsJson:
          investigationsJson == null && nullToAbsent
              ? const Value.absent()
              : Value(investigationsJson),
      followUpNotes:
          followUpNotes == null && nullToAbsent
              ? const Value.absent()
              : Value(followUpNotes),
      outcome:
          outcome == null && nullToAbsent
              ? const Value.absent()
              : Value(outcome),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PatientCaseRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientCaseRecord(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      chiefComplaintsJson: serializer.fromJson<String?>(
        json['chiefComplaintsJson'],
      ),
      hpi: serializer.fromJson<String?>(json['hpi']),
      pastHistoryJson: serializer.fromJson<String?>(json['pastHistoryJson']),
      familyHistoryJson: serializer.fromJson<String?>(
        json['familyHistoryJson'],
      ),
      developmentalHistoryJson: serializer.fromJson<String?>(
        json['developmentalHistoryJson'],
      ),
      physicalGeneralsJson: serializer.fromJson<String?>(
        json['physicalGeneralsJson'],
      ),
      mentalGeneralsJson: serializer.fromJson<String?>(
        json['mentalGeneralsJson'],
      ),
      lifestyleJson: serializer.fromJson<String?>(json['lifestyleJson']),
      clinicalExamJson: serializer.fromJson<String?>(json['clinicalExamJson']),
      miasmaticAnalysisJson: serializer.fromJson<String?>(
        json['miasmaticAnalysisJson'],
      ),
      caseTotalityJson: serializer.fromJson<String?>(json['caseTotalityJson']),
      baselinePrescriptionJson: serializer.fromJson<String?>(
        json['baselinePrescriptionJson'],
      ),
      investigationsJson: serializer.fromJson<String?>(
        json['investigationsJson'],
      ),
      followUpNotes: serializer.fromJson<String?>(json['followUpNotes']),
      outcome: serializer.fromJson<String?>(json['outcome']),
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
      'patientId': serializer.toJson<String>(patientId),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'chiefComplaintsJson': serializer.toJson<String?>(chiefComplaintsJson),
      'hpi': serializer.toJson<String?>(hpi),
      'pastHistoryJson': serializer.toJson<String?>(pastHistoryJson),
      'familyHistoryJson': serializer.toJson<String?>(familyHistoryJson),
      'developmentalHistoryJson': serializer.toJson<String?>(
        developmentalHistoryJson,
      ),
      'physicalGeneralsJson': serializer.toJson<String?>(physicalGeneralsJson),
      'mentalGeneralsJson': serializer.toJson<String?>(mentalGeneralsJson),
      'lifestyleJson': serializer.toJson<String?>(lifestyleJson),
      'clinicalExamJson': serializer.toJson<String?>(clinicalExamJson),
      'miasmaticAnalysisJson': serializer.toJson<String?>(
        miasmaticAnalysisJson,
      ),
      'caseTotalityJson': serializer.toJson<String?>(caseTotalityJson),
      'baselinePrescriptionJson': serializer.toJson<String?>(
        baselinePrescriptionJson,
      ),
      'investigationsJson': serializer.toJson<String?>(investigationsJson),
      'followUpNotes': serializer.toJson<String?>(followUpNotes),
      'outcome': serializer.toJson<String?>(outcome),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PatientCaseRecord copyWith({
    String? id,
    String? patientId,
    DateTime? recordDate,
    Value<String?> chiefComplaintsJson = const Value.absent(),
    Value<String?> hpi = const Value.absent(),
    Value<String?> pastHistoryJson = const Value.absent(),
    Value<String?> familyHistoryJson = const Value.absent(),
    Value<String?> developmentalHistoryJson = const Value.absent(),
    Value<String?> physicalGeneralsJson = const Value.absent(),
    Value<String?> mentalGeneralsJson = const Value.absent(),
    Value<String?> lifestyleJson = const Value.absent(),
    Value<String?> clinicalExamJson = const Value.absent(),
    Value<String?> miasmaticAnalysisJson = const Value.absent(),
    Value<String?> caseTotalityJson = const Value.absent(),
    Value<String?> baselinePrescriptionJson = const Value.absent(),
    Value<String?> investigationsJson = const Value.absent(),
    Value<String?> followUpNotes = const Value.absent(),
    Value<String?> outcome = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PatientCaseRecord(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    recordDate: recordDate ?? this.recordDate,
    chiefComplaintsJson:
        chiefComplaintsJson.present
            ? chiefComplaintsJson.value
            : this.chiefComplaintsJson,
    hpi: hpi.present ? hpi.value : this.hpi,
    pastHistoryJson:
        pastHistoryJson.present ? pastHistoryJson.value : this.pastHistoryJson,
    familyHistoryJson:
        familyHistoryJson.present
            ? familyHistoryJson.value
            : this.familyHistoryJson,
    developmentalHistoryJson:
        developmentalHistoryJson.present
            ? developmentalHistoryJson.value
            : this.developmentalHistoryJson,
    physicalGeneralsJson:
        physicalGeneralsJson.present
            ? physicalGeneralsJson.value
            : this.physicalGeneralsJson,
    mentalGeneralsJson:
        mentalGeneralsJson.present
            ? mentalGeneralsJson.value
            : this.mentalGeneralsJson,
    lifestyleJson:
        lifestyleJson.present ? lifestyleJson.value : this.lifestyleJson,
    clinicalExamJson:
        clinicalExamJson.present
            ? clinicalExamJson.value
            : this.clinicalExamJson,
    miasmaticAnalysisJson:
        miasmaticAnalysisJson.present
            ? miasmaticAnalysisJson.value
            : this.miasmaticAnalysisJson,
    caseTotalityJson:
        caseTotalityJson.present
            ? caseTotalityJson.value
            : this.caseTotalityJson,
    baselinePrescriptionJson:
        baselinePrescriptionJson.present
            ? baselinePrescriptionJson.value
            : this.baselinePrescriptionJson,
    investigationsJson:
        investigationsJson.present
            ? investigationsJson.value
            : this.investigationsJson,
    followUpNotes:
        followUpNotes.present ? followUpNotes.value : this.followUpNotes,
    outcome: outcome.present ? outcome.value : this.outcome,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PatientCaseRecord copyWithCompanion(PatientCaseRecordsCompanion data) {
    return PatientCaseRecord(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      recordDate:
          data.recordDate.present ? data.recordDate.value : this.recordDate,
      chiefComplaintsJson:
          data.chiefComplaintsJson.present
              ? data.chiefComplaintsJson.value
              : this.chiefComplaintsJson,
      hpi: data.hpi.present ? data.hpi.value : this.hpi,
      pastHistoryJson:
          data.pastHistoryJson.present
              ? data.pastHistoryJson.value
              : this.pastHistoryJson,
      familyHistoryJson:
          data.familyHistoryJson.present
              ? data.familyHistoryJson.value
              : this.familyHistoryJson,
      developmentalHistoryJson:
          data.developmentalHistoryJson.present
              ? data.developmentalHistoryJson.value
              : this.developmentalHistoryJson,
      physicalGeneralsJson:
          data.physicalGeneralsJson.present
              ? data.physicalGeneralsJson.value
              : this.physicalGeneralsJson,
      mentalGeneralsJson:
          data.mentalGeneralsJson.present
              ? data.mentalGeneralsJson.value
              : this.mentalGeneralsJson,
      lifestyleJson:
          data.lifestyleJson.present
              ? data.lifestyleJson.value
              : this.lifestyleJson,
      clinicalExamJson:
          data.clinicalExamJson.present
              ? data.clinicalExamJson.value
              : this.clinicalExamJson,
      miasmaticAnalysisJson:
          data.miasmaticAnalysisJson.present
              ? data.miasmaticAnalysisJson.value
              : this.miasmaticAnalysisJson,
      caseTotalityJson:
          data.caseTotalityJson.present
              ? data.caseTotalityJson.value
              : this.caseTotalityJson,
      baselinePrescriptionJson:
          data.baselinePrescriptionJson.present
              ? data.baselinePrescriptionJson.value
              : this.baselinePrescriptionJson,
      investigationsJson:
          data.investigationsJson.present
              ? data.investigationsJson.value
              : this.investigationsJson,
      followUpNotes:
          data.followUpNotes.present
              ? data.followUpNotes.value
              : this.followUpNotes,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientCaseRecord(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('recordDate: $recordDate, ')
          ..write('chiefComplaintsJson: $chiefComplaintsJson, ')
          ..write('hpi: $hpi, ')
          ..write('pastHistoryJson: $pastHistoryJson, ')
          ..write('familyHistoryJson: $familyHistoryJson, ')
          ..write('developmentalHistoryJson: $developmentalHistoryJson, ')
          ..write('physicalGeneralsJson: $physicalGeneralsJson, ')
          ..write('mentalGeneralsJson: $mentalGeneralsJson, ')
          ..write('lifestyleJson: $lifestyleJson, ')
          ..write('clinicalExamJson: $clinicalExamJson, ')
          ..write('miasmaticAnalysisJson: $miasmaticAnalysisJson, ')
          ..write('caseTotalityJson: $caseTotalityJson, ')
          ..write('baselinePrescriptionJson: $baselinePrescriptionJson, ')
          ..write('investigationsJson: $investigationsJson, ')
          ..write('followUpNotes: $followUpNotes, ')
          ..write('outcome: $outcome, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    patientId,
    recordDate,
    chiefComplaintsJson,
    hpi,
    pastHistoryJson,
    familyHistoryJson,
    developmentalHistoryJson,
    physicalGeneralsJson,
    mentalGeneralsJson,
    lifestyleJson,
    clinicalExamJson,
    miasmaticAnalysisJson,
    caseTotalityJson,
    baselinePrescriptionJson,
    investigationsJson,
    followUpNotes,
    outcome,
    isDeleted,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientCaseRecord &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.recordDate == this.recordDate &&
          other.chiefComplaintsJson == this.chiefComplaintsJson &&
          other.hpi == this.hpi &&
          other.pastHistoryJson == this.pastHistoryJson &&
          other.familyHistoryJson == this.familyHistoryJson &&
          other.developmentalHistoryJson == this.developmentalHistoryJson &&
          other.physicalGeneralsJson == this.physicalGeneralsJson &&
          other.mentalGeneralsJson == this.mentalGeneralsJson &&
          other.lifestyleJson == this.lifestyleJson &&
          other.clinicalExamJson == this.clinicalExamJson &&
          other.miasmaticAnalysisJson == this.miasmaticAnalysisJson &&
          other.caseTotalityJson == this.caseTotalityJson &&
          other.baselinePrescriptionJson == this.baselinePrescriptionJson &&
          other.investigationsJson == this.investigationsJson &&
          other.followUpNotes == this.followUpNotes &&
          other.outcome == this.outcome &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PatientCaseRecordsCompanion extends UpdateCompanion<PatientCaseRecord> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<DateTime> recordDate;
  final Value<String?> chiefComplaintsJson;
  final Value<String?> hpi;
  final Value<String?> pastHistoryJson;
  final Value<String?> familyHistoryJson;
  final Value<String?> developmentalHistoryJson;
  final Value<String?> physicalGeneralsJson;
  final Value<String?> mentalGeneralsJson;
  final Value<String?> lifestyleJson;
  final Value<String?> clinicalExamJson;
  final Value<String?> miasmaticAnalysisJson;
  final Value<String?> caseTotalityJson;
  final Value<String?> baselinePrescriptionJson;
  final Value<String?> investigationsJson;
  final Value<String?> followUpNotes;
  final Value<String?> outcome;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PatientCaseRecordsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.chiefComplaintsJson = const Value.absent(),
    this.hpi = const Value.absent(),
    this.pastHistoryJson = const Value.absent(),
    this.familyHistoryJson = const Value.absent(),
    this.developmentalHistoryJson = const Value.absent(),
    this.physicalGeneralsJson = const Value.absent(),
    this.mentalGeneralsJson = const Value.absent(),
    this.lifestyleJson = const Value.absent(),
    this.clinicalExamJson = const Value.absent(),
    this.miasmaticAnalysisJson = const Value.absent(),
    this.caseTotalityJson = const Value.absent(),
    this.baselinePrescriptionJson = const Value.absent(),
    this.investigationsJson = const Value.absent(),
    this.followUpNotes = const Value.absent(),
    this.outcome = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientCaseRecordsCompanion.insert({
    required String id,
    required String patientId,
    this.recordDate = const Value.absent(),
    this.chiefComplaintsJson = const Value.absent(),
    this.hpi = const Value.absent(),
    this.pastHistoryJson = const Value.absent(),
    this.familyHistoryJson = const Value.absent(),
    this.developmentalHistoryJson = const Value.absent(),
    this.physicalGeneralsJson = const Value.absent(),
    this.mentalGeneralsJson = const Value.absent(),
    this.lifestyleJson = const Value.absent(),
    this.clinicalExamJson = const Value.absent(),
    this.miasmaticAnalysisJson = const Value.absent(),
    this.caseTotalityJson = const Value.absent(),
    this.baselinePrescriptionJson = const Value.absent(),
    this.investigationsJson = const Value.absent(),
    this.followUpNotes = const Value.absent(),
    this.outcome = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId);
  static Insertable<PatientCaseRecord> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<DateTime>? recordDate,
    Expression<String>? chiefComplaintsJson,
    Expression<String>? hpi,
    Expression<String>? pastHistoryJson,
    Expression<String>? familyHistoryJson,
    Expression<String>? developmentalHistoryJson,
    Expression<String>? physicalGeneralsJson,
    Expression<String>? mentalGeneralsJson,
    Expression<String>? lifestyleJson,
    Expression<String>? clinicalExamJson,
    Expression<String>? miasmaticAnalysisJson,
    Expression<String>? caseTotalityJson,
    Expression<String>? baselinePrescriptionJson,
    Expression<String>? investigationsJson,
    Expression<String>? followUpNotes,
    Expression<String>? outcome,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (recordDate != null) 'record_date': recordDate,
      if (chiefComplaintsJson != null)
        'chief_complaints_json': chiefComplaintsJson,
      if (hpi != null) 'hpi': hpi,
      if (pastHistoryJson != null) 'past_history_json': pastHistoryJson,
      if (familyHistoryJson != null) 'family_history_json': familyHistoryJson,
      if (developmentalHistoryJson != null)
        'developmental_history_json': developmentalHistoryJson,
      if (physicalGeneralsJson != null)
        'physical_generals_json': physicalGeneralsJson,
      if (mentalGeneralsJson != null)
        'mental_generals_json': mentalGeneralsJson,
      if (lifestyleJson != null) 'lifestyle_json': lifestyleJson,
      if (clinicalExamJson != null) 'clinical_exam_json': clinicalExamJson,
      if (miasmaticAnalysisJson != null)
        'miasmatic_analysis_json': miasmaticAnalysisJson,
      if (caseTotalityJson != null) 'case_totality_json': caseTotalityJson,
      if (baselinePrescriptionJson != null)
        'baseline_prescription_json': baselinePrescriptionJson,
      if (investigationsJson != null) 'investigations_json': investigationsJson,
      if (followUpNotes != null) 'follow_up_notes': followUpNotes,
      if (outcome != null) 'outcome': outcome,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientCaseRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<DateTime>? recordDate,
    Value<String?>? chiefComplaintsJson,
    Value<String?>? hpi,
    Value<String?>? pastHistoryJson,
    Value<String?>? familyHistoryJson,
    Value<String?>? developmentalHistoryJson,
    Value<String?>? physicalGeneralsJson,
    Value<String?>? mentalGeneralsJson,
    Value<String?>? lifestyleJson,
    Value<String?>? clinicalExamJson,
    Value<String?>? miasmaticAnalysisJson,
    Value<String?>? caseTotalityJson,
    Value<String?>? baselinePrescriptionJson,
    Value<String?>? investigationsJson,
    Value<String?>? followUpNotes,
    Value<String?>? outcome,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PatientCaseRecordsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      recordDate: recordDate ?? this.recordDate,
      chiefComplaintsJson: chiefComplaintsJson ?? this.chiefComplaintsJson,
      hpi: hpi ?? this.hpi,
      pastHistoryJson: pastHistoryJson ?? this.pastHistoryJson,
      familyHistoryJson: familyHistoryJson ?? this.familyHistoryJson,
      developmentalHistoryJson:
          developmentalHistoryJson ?? this.developmentalHistoryJson,
      physicalGeneralsJson: physicalGeneralsJson ?? this.physicalGeneralsJson,
      mentalGeneralsJson: mentalGeneralsJson ?? this.mentalGeneralsJson,
      lifestyleJson: lifestyleJson ?? this.lifestyleJson,
      clinicalExamJson: clinicalExamJson ?? this.clinicalExamJson,
      miasmaticAnalysisJson:
          miasmaticAnalysisJson ?? this.miasmaticAnalysisJson,
      caseTotalityJson: caseTotalityJson ?? this.caseTotalityJson,
      baselinePrescriptionJson:
          baselinePrescriptionJson ?? this.baselinePrescriptionJson,
      investigationsJson: investigationsJson ?? this.investigationsJson,
      followUpNotes: followUpNotes ?? this.followUpNotes,
      outcome: outcome ?? this.outcome,
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
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (chiefComplaintsJson.present) {
      map['chief_complaints_json'] = Variable<String>(
        chiefComplaintsJson.value,
      );
    }
    if (hpi.present) {
      map['hpi'] = Variable<String>(hpi.value);
    }
    if (pastHistoryJson.present) {
      map['past_history_json'] = Variable<String>(pastHistoryJson.value);
    }
    if (familyHistoryJson.present) {
      map['family_history_json'] = Variable<String>(familyHistoryJson.value);
    }
    if (developmentalHistoryJson.present) {
      map['developmental_history_json'] = Variable<String>(
        developmentalHistoryJson.value,
      );
    }
    if (physicalGeneralsJson.present) {
      map['physical_generals_json'] = Variable<String>(
        physicalGeneralsJson.value,
      );
    }
    if (mentalGeneralsJson.present) {
      map['mental_generals_json'] = Variable<String>(mentalGeneralsJson.value);
    }
    if (lifestyleJson.present) {
      map['lifestyle_json'] = Variable<String>(lifestyleJson.value);
    }
    if (clinicalExamJson.present) {
      map['clinical_exam_json'] = Variable<String>(clinicalExamJson.value);
    }
    if (miasmaticAnalysisJson.present) {
      map['miasmatic_analysis_json'] = Variable<String>(
        miasmaticAnalysisJson.value,
      );
    }
    if (caseTotalityJson.present) {
      map['case_totality_json'] = Variable<String>(caseTotalityJson.value);
    }
    if (baselinePrescriptionJson.present) {
      map['baseline_prescription_json'] = Variable<String>(
        baselinePrescriptionJson.value,
      );
    }
    if (investigationsJson.present) {
      map['investigations_json'] = Variable<String>(investigationsJson.value);
    }
    if (followUpNotes.present) {
      map['follow_up_notes'] = Variable<String>(followUpNotes.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
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
    return (StringBuffer('PatientCaseRecordsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('recordDate: $recordDate, ')
          ..write('chiefComplaintsJson: $chiefComplaintsJson, ')
          ..write('hpi: $hpi, ')
          ..write('pastHistoryJson: $pastHistoryJson, ')
          ..write('familyHistoryJson: $familyHistoryJson, ')
          ..write('developmentalHistoryJson: $developmentalHistoryJson, ')
          ..write('physicalGeneralsJson: $physicalGeneralsJson, ')
          ..write('mentalGeneralsJson: $mentalGeneralsJson, ')
          ..write('lifestyleJson: $lifestyleJson, ')
          ..write('clinicalExamJson: $clinicalExamJson, ')
          ..write('miasmaticAnalysisJson: $miasmaticAnalysisJson, ')
          ..write('caseTotalityJson: $caseTotalityJson, ')
          ..write('baselinePrescriptionJson: $baselinePrescriptionJson, ')
          ..write('investigationsJson: $investigationsJson, ')
          ..write('followUpNotes: $followUpNotes, ')
          ..write('outcome: $outcome, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ComplaintsTable extends Complaints
    with TableInfo<$ComplaintsTable, Complaint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComplaintsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _complaintIndexMeta = const VerificationMeta(
    'complaintIndex',
  );
  @override
  late final GeneratedColumn<int> complaintIndex = GeneratedColumn<int>(
    'complaint_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _complaintNameMeta = const VerificationMeta(
    'complaintName',
  );
  @override
  late final GeneratedColumn<String> complaintName = GeneratedColumn<String>(
    'complaint_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onsetMeta = const VerificationMeta('onset');
  @override
  late final GeneratedColumn<String> onset = GeneratedColumn<String>(
    'onset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<String> duration = GeneratedColumn<String>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sensationMeta = const VerificationMeta(
    'sensation',
  );
  @override
  late final GeneratedColumn<String> sensation = GeneratedColumn<String>(
    'sensation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extensionMeta = const VerificationMeta(
    'extension',
  );
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
    'extension',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aggravatingFactorsMeta =
      const VerificationMeta('aggravatingFactors');
  @override
  late final GeneratedColumn<String> aggravatingFactors =
      GeneratedColumn<String>(
        'aggravating_factors',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _amelioratingFactorsMeta =
      const VerificationMeta('amelioratingFactors');
  @override
  late final GeneratedColumn<String> amelioratingFactors =
      GeneratedColumn<String>(
        'ameliorating_factors',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _concomitantsMeta = const VerificationMeta(
    'concomitants',
  );
  @override
  late final GeneratedColumn<String> concomitants = GeneratedColumn<String>(
    'concomitants',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _causationMeta = const VerificationMeta(
    'causation',
  );
  @override
  late final GeneratedColumn<String> causation = GeneratedColumn<String>(
    'causation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodicityMeta = const VerificationMeta(
    'periodicity',
  );
  @override
  late final GeneratedColumn<String> periodicity = GeneratedColumn<String>(
    'periodicity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Active'),
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
    patientId,
    visitId,
    complaintIndex,
    complaintName,
    location,
    side,
    onset,
    duration,
    sensation,
    extension,
    aggravatingFactors,
    amelioratingFactors,
    concomitants,
    causation,
    periodicity,
    severity,
    status,
    notes,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'complaints';
  @override
  VerificationContext validateIntegrity(
    Insertable<Complaint> instance, {
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
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    }
    if (data.containsKey('complaint_index')) {
      context.handle(
        _complaintIndexMeta,
        complaintIndex.isAcceptableOrUnknown(
          data['complaint_index']!,
          _complaintIndexMeta,
        ),
      );
    }
    if (data.containsKey('complaint_name')) {
      context.handle(
        _complaintNameMeta,
        complaintName.isAcceptableOrUnknown(
          data['complaint_name']!,
          _complaintNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_complaintNameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    }
    if (data.containsKey('onset')) {
      context.handle(
        _onsetMeta,
        onset.isAcceptableOrUnknown(data['onset']!, _onsetMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('sensation')) {
      context.handle(
        _sensationMeta,
        sensation.isAcceptableOrUnknown(data['sensation']!, _sensationMeta),
      );
    }
    if (data.containsKey('extension')) {
      context.handle(
        _extensionMeta,
        extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta),
      );
    }
    if (data.containsKey('aggravating_factors')) {
      context.handle(
        _aggravatingFactorsMeta,
        aggravatingFactors.isAcceptableOrUnknown(
          data['aggravating_factors']!,
          _aggravatingFactorsMeta,
        ),
      );
    }
    if (data.containsKey('ameliorating_factors')) {
      context.handle(
        _amelioratingFactorsMeta,
        amelioratingFactors.isAcceptableOrUnknown(
          data['ameliorating_factors']!,
          _amelioratingFactorsMeta,
        ),
      );
    }
    if (data.containsKey('concomitants')) {
      context.handle(
        _concomitantsMeta,
        concomitants.isAcceptableOrUnknown(
          data['concomitants']!,
          _concomitantsMeta,
        ),
      );
    }
    if (data.containsKey('causation')) {
      context.handle(
        _causationMeta,
        causation.isAcceptableOrUnknown(data['causation']!, _causationMeta),
      );
    }
    if (data.containsKey('periodicity')) {
      context.handle(
        _periodicityMeta,
        periodicity.isAcceptableOrUnknown(
          data['periodicity']!,
          _periodicityMeta,
        ),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
  Complaint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Complaint(
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
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      ),
      complaintIndex:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}complaint_index'],
          )!,
      complaintName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}complaint_name'],
          )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      ),
      onset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}onset'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration'],
      ),
      sensation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sensation'],
      ),
      extension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension'],
      ),
      aggravatingFactors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggravating_factors'],
      ),
      amelioratingFactors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ameliorating_factors'],
      ),
      concomitants: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concomitants'],
      ),
      causation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}causation'],
      ),
      periodicity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}periodicity'],
      ),
      severity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}severity'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
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
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $ComplaintsTable createAlias(String alias) {
    return $ComplaintsTable(attachedDatabase, alias);
  }
}

class Complaint extends DataClass implements Insertable<Complaint> {
  final String id;
  final String patientId;
  final String? visitId;
  final int complaintIndex;
  final String complaintName;
  final String? location;
  final String? side;
  final String? onset;
  final String? duration;
  final String? sensation;
  final String? extension;
  final String? aggravatingFactors;
  final String? amelioratingFactors;
  final String? concomitants;
  final String? causation;
  final String? periodicity;
  final int severity;
  final String status;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Complaint({
    required this.id,
    required this.patientId,
    this.visitId,
    required this.complaintIndex,
    required this.complaintName,
    this.location,
    this.side,
    this.onset,
    this.duration,
    this.sensation,
    this.extension,
    this.aggravatingFactors,
    this.amelioratingFactors,
    this.concomitants,
    this.causation,
    this.periodicity,
    required this.severity,
    required this.status,
    this.notes,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || visitId != null) {
      map['visit_id'] = Variable<String>(visitId);
    }
    map['complaint_index'] = Variable<int>(complaintIndex);
    map['complaint_name'] = Variable<String>(complaintName);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || side != null) {
      map['side'] = Variable<String>(side);
    }
    if (!nullToAbsent || onset != null) {
      map['onset'] = Variable<String>(onset);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<String>(duration);
    }
    if (!nullToAbsent || sensation != null) {
      map['sensation'] = Variable<String>(sensation);
    }
    if (!nullToAbsent || extension != null) {
      map['extension'] = Variable<String>(extension);
    }
    if (!nullToAbsent || aggravatingFactors != null) {
      map['aggravating_factors'] = Variable<String>(aggravatingFactors);
    }
    if (!nullToAbsent || amelioratingFactors != null) {
      map['ameliorating_factors'] = Variable<String>(amelioratingFactors);
    }
    if (!nullToAbsent || concomitants != null) {
      map['concomitants'] = Variable<String>(concomitants);
    }
    if (!nullToAbsent || causation != null) {
      map['causation'] = Variable<String>(causation);
    }
    if (!nullToAbsent || periodicity != null) {
      map['periodicity'] = Variable<String>(periodicity);
    }
    map['severity'] = Variable<int>(severity);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ComplaintsCompanion toCompanion(bool nullToAbsent) {
    return ComplaintsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      visitId:
          visitId == null && nullToAbsent
              ? const Value.absent()
              : Value(visitId),
      complaintIndex: Value(complaintIndex),
      complaintName: Value(complaintName),
      location:
          location == null && nullToAbsent
              ? const Value.absent()
              : Value(location),
      side: side == null && nullToAbsent ? const Value.absent() : Value(side),
      onset:
          onset == null && nullToAbsent ? const Value.absent() : Value(onset),
      duration:
          duration == null && nullToAbsent
              ? const Value.absent()
              : Value(duration),
      sensation:
          sensation == null && nullToAbsent
              ? const Value.absent()
              : Value(sensation),
      extension:
          extension == null && nullToAbsent
              ? const Value.absent()
              : Value(extension),
      aggravatingFactors:
          aggravatingFactors == null && nullToAbsent
              ? const Value.absent()
              : Value(aggravatingFactors),
      amelioratingFactors:
          amelioratingFactors == null && nullToAbsent
              ? const Value.absent()
              : Value(amelioratingFactors),
      concomitants:
          concomitants == null && nullToAbsent
              ? const Value.absent()
              : Value(concomitants),
      causation:
          causation == null && nullToAbsent
              ? const Value.absent()
              : Value(causation),
      periodicity:
          periodicity == null && nullToAbsent
              ? const Value.absent()
              : Value(periodicity),
      severity: Value(severity),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Complaint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Complaint(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      visitId: serializer.fromJson<String?>(json['visitId']),
      complaintIndex: serializer.fromJson<int>(json['complaintIndex']),
      complaintName: serializer.fromJson<String>(json['complaintName']),
      location: serializer.fromJson<String?>(json['location']),
      side: serializer.fromJson<String?>(json['side']),
      onset: serializer.fromJson<String?>(json['onset']),
      duration: serializer.fromJson<String?>(json['duration']),
      sensation: serializer.fromJson<String?>(json['sensation']),
      extension: serializer.fromJson<String?>(json['extension']),
      aggravatingFactors: serializer.fromJson<String?>(
        json['aggravatingFactors'],
      ),
      amelioratingFactors: serializer.fromJson<String?>(
        json['amelioratingFactors'],
      ),
      concomitants: serializer.fromJson<String?>(json['concomitants']),
      causation: serializer.fromJson<String?>(json['causation']),
      periodicity: serializer.fromJson<String?>(json['periodicity']),
      severity: serializer.fromJson<int>(json['severity']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
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
      'patientId': serializer.toJson<String>(patientId),
      'visitId': serializer.toJson<String?>(visitId),
      'complaintIndex': serializer.toJson<int>(complaintIndex),
      'complaintName': serializer.toJson<String>(complaintName),
      'location': serializer.toJson<String?>(location),
      'side': serializer.toJson<String?>(side),
      'onset': serializer.toJson<String?>(onset),
      'duration': serializer.toJson<String?>(duration),
      'sensation': serializer.toJson<String?>(sensation),
      'extension': serializer.toJson<String?>(extension),
      'aggravatingFactors': serializer.toJson<String?>(aggravatingFactors),
      'amelioratingFactors': serializer.toJson<String?>(amelioratingFactors),
      'concomitants': serializer.toJson<String?>(concomitants),
      'causation': serializer.toJson<String?>(causation),
      'periodicity': serializer.toJson<String?>(periodicity),
      'severity': serializer.toJson<int>(severity),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Complaint copyWith({
    String? id,
    String? patientId,
    Value<String?> visitId = const Value.absent(),
    int? complaintIndex,
    String? complaintName,
    Value<String?> location = const Value.absent(),
    Value<String?> side = const Value.absent(),
    Value<String?> onset = const Value.absent(),
    Value<String?> duration = const Value.absent(),
    Value<String?> sensation = const Value.absent(),
    Value<String?> extension = const Value.absent(),
    Value<String?> aggravatingFactors = const Value.absent(),
    Value<String?> amelioratingFactors = const Value.absent(),
    Value<String?> concomitants = const Value.absent(),
    Value<String?> causation = const Value.absent(),
    Value<String?> periodicity = const Value.absent(),
    int? severity,
    String? status,
    Value<String?> notes = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Complaint(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    visitId: visitId.present ? visitId.value : this.visitId,
    complaintIndex: complaintIndex ?? this.complaintIndex,
    complaintName: complaintName ?? this.complaintName,
    location: location.present ? location.value : this.location,
    side: side.present ? side.value : this.side,
    onset: onset.present ? onset.value : this.onset,
    duration: duration.present ? duration.value : this.duration,
    sensation: sensation.present ? sensation.value : this.sensation,
    extension: extension.present ? extension.value : this.extension,
    aggravatingFactors:
        aggravatingFactors.present
            ? aggravatingFactors.value
            : this.aggravatingFactors,
    amelioratingFactors:
        amelioratingFactors.present
            ? amelioratingFactors.value
            : this.amelioratingFactors,
    concomitants: concomitants.present ? concomitants.value : this.concomitants,
    causation: causation.present ? causation.value : this.causation,
    periodicity: periodicity.present ? periodicity.value : this.periodicity,
    severity: severity ?? this.severity,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Complaint copyWithCompanion(ComplaintsCompanion data) {
    return Complaint(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      complaintIndex:
          data.complaintIndex.present
              ? data.complaintIndex.value
              : this.complaintIndex,
      complaintName:
          data.complaintName.present
              ? data.complaintName.value
              : this.complaintName,
      location: data.location.present ? data.location.value : this.location,
      side: data.side.present ? data.side.value : this.side,
      onset: data.onset.present ? data.onset.value : this.onset,
      duration: data.duration.present ? data.duration.value : this.duration,
      sensation: data.sensation.present ? data.sensation.value : this.sensation,
      extension: data.extension.present ? data.extension.value : this.extension,
      aggravatingFactors:
          data.aggravatingFactors.present
              ? data.aggravatingFactors.value
              : this.aggravatingFactors,
      amelioratingFactors:
          data.amelioratingFactors.present
              ? data.amelioratingFactors.value
              : this.amelioratingFactors,
      concomitants:
          data.concomitants.present
              ? data.concomitants.value
              : this.concomitants,
      causation: data.causation.present ? data.causation.value : this.causation,
      periodicity:
          data.periodicity.present ? data.periodicity.value : this.periodicity,
      severity: data.severity.present ? data.severity.value : this.severity,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Complaint(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('visitId: $visitId, ')
          ..write('complaintIndex: $complaintIndex, ')
          ..write('complaintName: $complaintName, ')
          ..write('location: $location, ')
          ..write('side: $side, ')
          ..write('onset: $onset, ')
          ..write('duration: $duration, ')
          ..write('sensation: $sensation, ')
          ..write('extension: $extension, ')
          ..write('aggravatingFactors: $aggravatingFactors, ')
          ..write('amelioratingFactors: $amelioratingFactors, ')
          ..write('concomitants: $concomitants, ')
          ..write('causation: $causation, ')
          ..write('periodicity: $periodicity, ')
          ..write('severity: $severity, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    patientId,
    visitId,
    complaintIndex,
    complaintName,
    location,
    side,
    onset,
    duration,
    sensation,
    extension,
    aggravatingFactors,
    amelioratingFactors,
    concomitants,
    causation,
    periodicity,
    severity,
    status,
    notes,
    isDeleted,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Complaint &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.visitId == this.visitId &&
          other.complaintIndex == this.complaintIndex &&
          other.complaintName == this.complaintName &&
          other.location == this.location &&
          other.side == this.side &&
          other.onset == this.onset &&
          other.duration == this.duration &&
          other.sensation == this.sensation &&
          other.extension == this.extension &&
          other.aggravatingFactors == this.aggravatingFactors &&
          other.amelioratingFactors == this.amelioratingFactors &&
          other.concomitants == this.concomitants &&
          other.causation == this.causation &&
          other.periodicity == this.periodicity &&
          other.severity == this.severity &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ComplaintsCompanion extends UpdateCompanion<Complaint> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String?> visitId;
  final Value<int> complaintIndex;
  final Value<String> complaintName;
  final Value<String?> location;
  final Value<String?> side;
  final Value<String?> onset;
  final Value<String?> duration;
  final Value<String?> sensation;
  final Value<String?> extension;
  final Value<String?> aggravatingFactors;
  final Value<String?> amelioratingFactors;
  final Value<String?> concomitants;
  final Value<String?> causation;
  final Value<String?> periodicity;
  final Value<int> severity;
  final Value<String> status;
  final Value<String?> notes;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ComplaintsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.visitId = const Value.absent(),
    this.complaintIndex = const Value.absent(),
    this.complaintName = const Value.absent(),
    this.location = const Value.absent(),
    this.side = const Value.absent(),
    this.onset = const Value.absent(),
    this.duration = const Value.absent(),
    this.sensation = const Value.absent(),
    this.extension = const Value.absent(),
    this.aggravatingFactors = const Value.absent(),
    this.amelioratingFactors = const Value.absent(),
    this.concomitants = const Value.absent(),
    this.causation = const Value.absent(),
    this.periodicity = const Value.absent(),
    this.severity = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ComplaintsCompanion.insert({
    required String id,
    required String patientId,
    this.visitId = const Value.absent(),
    this.complaintIndex = const Value.absent(),
    required String complaintName,
    this.location = const Value.absent(),
    this.side = const Value.absent(),
    this.onset = const Value.absent(),
    this.duration = const Value.absent(),
    this.sensation = const Value.absent(),
    this.extension = const Value.absent(),
    this.aggravatingFactors = const Value.absent(),
    this.amelioratingFactors = const Value.absent(),
    this.concomitants = const Value.absent(),
    this.causation = const Value.absent(),
    this.periodicity = const Value.absent(),
    this.severity = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       complaintName = Value(complaintName);
  static Insertable<Complaint> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? visitId,
    Expression<int>? complaintIndex,
    Expression<String>? complaintName,
    Expression<String>? location,
    Expression<String>? side,
    Expression<String>? onset,
    Expression<String>? duration,
    Expression<String>? sensation,
    Expression<String>? extension,
    Expression<String>? aggravatingFactors,
    Expression<String>? amelioratingFactors,
    Expression<String>? concomitants,
    Expression<String>? causation,
    Expression<String>? periodicity,
    Expression<int>? severity,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (visitId != null) 'visit_id': visitId,
      if (complaintIndex != null) 'complaint_index': complaintIndex,
      if (complaintName != null) 'complaint_name': complaintName,
      if (location != null) 'location': location,
      if (side != null) 'side': side,
      if (onset != null) 'onset': onset,
      if (duration != null) 'duration': duration,
      if (sensation != null) 'sensation': sensation,
      if (extension != null) 'extension': extension,
      if (aggravatingFactors != null) 'aggravating_factors': aggravatingFactors,
      if (amelioratingFactors != null)
        'ameliorating_factors': amelioratingFactors,
      if (concomitants != null) 'concomitants': concomitants,
      if (causation != null) 'causation': causation,
      if (periodicity != null) 'periodicity': periodicity,
      if (severity != null) 'severity': severity,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ComplaintsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String?>? visitId,
    Value<int>? complaintIndex,
    Value<String>? complaintName,
    Value<String?>? location,
    Value<String?>? side,
    Value<String?>? onset,
    Value<String?>? duration,
    Value<String?>? sensation,
    Value<String?>? extension,
    Value<String?>? aggravatingFactors,
    Value<String?>? amelioratingFactors,
    Value<String?>? concomitants,
    Value<String?>? causation,
    Value<String?>? periodicity,
    Value<int>? severity,
    Value<String>? status,
    Value<String?>? notes,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ComplaintsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      visitId: visitId ?? this.visitId,
      complaintIndex: complaintIndex ?? this.complaintIndex,
      complaintName: complaintName ?? this.complaintName,
      location: location ?? this.location,
      side: side ?? this.side,
      onset: onset ?? this.onset,
      duration: duration ?? this.duration,
      sensation: sensation ?? this.sensation,
      extension: extension ?? this.extension,
      aggravatingFactors: aggravatingFactors ?? this.aggravatingFactors,
      amelioratingFactors: amelioratingFactors ?? this.amelioratingFactors,
      concomitants: concomitants ?? this.concomitants,
      causation: causation ?? this.causation,
      periodicity: periodicity ?? this.periodicity,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      notes: notes ?? this.notes,
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
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (complaintIndex.present) {
      map['complaint_index'] = Variable<int>(complaintIndex.value);
    }
    if (complaintName.present) {
      map['complaint_name'] = Variable<String>(complaintName.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (onset.present) {
      map['onset'] = Variable<String>(onset.value);
    }
    if (duration.present) {
      map['duration'] = Variable<String>(duration.value);
    }
    if (sensation.present) {
      map['sensation'] = Variable<String>(sensation.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (aggravatingFactors.present) {
      map['aggravating_factors'] = Variable<String>(aggravatingFactors.value);
    }
    if (amelioratingFactors.present) {
      map['ameliorating_factors'] = Variable<String>(amelioratingFactors.value);
    }
    if (concomitants.present) {
      map['concomitants'] = Variable<String>(concomitants.value);
    }
    if (causation.present) {
      map['causation'] = Variable<String>(causation.value);
    }
    if (periodicity.present) {
      map['periodicity'] = Variable<String>(periodicity.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('ComplaintsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('visitId: $visitId, ')
          ..write('complaintIndex: $complaintIndex, ')
          ..write('complaintName: $complaintName, ')
          ..write('location: $location, ')
          ..write('side: $side, ')
          ..write('onset: $onset, ')
          ..write('duration: $duration, ')
          ..write('sensation: $sensation, ')
          ..write('extension: $extension, ')
          ..write('aggravatingFactors: $aggravatingFactors, ')
          ..write('amelioratingFactors: $amelioratingFactors, ')
          ..write('concomitants: $concomitants, ')
          ..write('causation: $causation, ')
          ..write('periodicity: $periodicity, ')
          ..write('severity: $severity, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrescriptionsTable extends Prescriptions
    with TableInfo<$PrescriptionsTable, Prescription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrescriptionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _prescriptionDateMeta = const VerificationMeta(
    'prescriptionDate',
  );
  @override
  late final GeneratedColumn<DateTime> prescriptionDate =
      GeneratedColumn<DateTime>(
        'prescription_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _remedyIndexMeta = const VerificationMeta(
    'remedyIndex',
  );
  @override
  late final GeneratedColumn<int> remedyIndex = GeneratedColumn<int>(
    'remedy_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _remedyNameMeta = const VerificationMeta(
    'remedyName',
  );
  @override
  late final GeneratedColumn<String> remedyName = GeneratedColumn<String>(
    'remedy_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _potencyMeta = const VerificationMeta(
    'potency',
  );
  @override
  late final GeneratedColumn<String> potency = GeneratedColumn<String>(
    'potency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseCountMeta = const VerificationMeta(
    'doseCount',
  );
  @override
  late final GeneratedColumn<String> doseCount = GeneratedColumn<String>(
    'dose_count',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleMeta = const VerificationMeta(
    'vehicle',
  );
  @override
  late final GeneratedColumn<String> vehicle = GeneratedColumn<String>(
    'vehicle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationDaysMeta = const VerificationMeta(
    'durationDays',
  );
  @override
  late final GeneratedColumn<String> durationDays = GeneratedColumn<String>(
    'duration_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dietaryAdviceMeta = const VerificationMeta(
    'dietaryAdvice',
  );
  @override
  late final GeneratedColumn<String> dietaryAdvice = GeneratedColumn<String>(
    'dietary_advice',
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
    patientId,
    visitId,
    prescriptionDate,
    remedyIndex,
    remedyName,
    potency,
    doseCount,
    frequency,
    vehicle,
    durationDays,
    instructions,
    dietaryAdvice,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prescriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Prescription> instance, {
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
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    }
    if (data.containsKey('prescription_date')) {
      context.handle(
        _prescriptionDateMeta,
        prescriptionDate.isAcceptableOrUnknown(
          data['prescription_date']!,
          _prescriptionDateMeta,
        ),
      );
    }
    if (data.containsKey('remedy_index')) {
      context.handle(
        _remedyIndexMeta,
        remedyIndex.isAcceptableOrUnknown(
          data['remedy_index']!,
          _remedyIndexMeta,
        ),
      );
    }
    if (data.containsKey('remedy_name')) {
      context.handle(
        _remedyNameMeta,
        remedyName.isAcceptableOrUnknown(data['remedy_name']!, _remedyNameMeta),
      );
    } else if (isInserting) {
      context.missing(_remedyNameMeta);
    }
    if (data.containsKey('potency')) {
      context.handle(
        _potencyMeta,
        potency.isAcceptableOrUnknown(data['potency']!, _potencyMeta),
      );
    } else if (isInserting) {
      context.missing(_potencyMeta);
    }
    if (data.containsKey('dose_count')) {
      context.handle(
        _doseCountMeta,
        doseCount.isAcceptableOrUnknown(data['dose_count']!, _doseCountMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('vehicle')) {
      context.handle(
        _vehicleMeta,
        vehicle.isAcceptableOrUnknown(data['vehicle']!, _vehicleMeta),
      );
    }
    if (data.containsKey('duration_days')) {
      context.handle(
        _durationDaysMeta,
        durationDays.isAcceptableOrUnknown(
          data['duration_days']!,
          _durationDaysMeta,
        ),
      );
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    }
    if (data.containsKey('dietary_advice')) {
      context.handle(
        _dietaryAdviceMeta,
        dietaryAdvice.isAcceptableOrUnknown(
          data['dietary_advice']!,
          _dietaryAdviceMeta,
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
  Prescription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prescription(
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
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      ),
      prescriptionDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}prescription_date'],
          )!,
      remedyIndex:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}remedy_index'],
          )!,
      remedyName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remedy_name'],
          )!,
      potency:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}potency'],
          )!,
      doseCount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_count'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      ),
      vehicle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle'],
      ),
      durationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration_days'],
      ),
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      ),
      dietaryAdvice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dietary_advice'],
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
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $PrescriptionsTable createAlias(String alias) {
    return $PrescriptionsTable(attachedDatabase, alias);
  }
}

class Prescription extends DataClass implements Insertable<Prescription> {
  final String id;
  final String patientId;
  final String? visitId;
  final DateTime prescriptionDate;
  final int remedyIndex;
  final String remedyName;
  final String potency;
  final String? doseCount;
  final String? frequency;
  final String? vehicle;
  final String? durationDays;
  final String? instructions;
  final String? dietaryAdvice;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Prescription({
    required this.id,
    required this.patientId,
    this.visitId,
    required this.prescriptionDate,
    required this.remedyIndex,
    required this.remedyName,
    required this.potency,
    this.doseCount,
    this.frequency,
    this.vehicle,
    this.durationDays,
    this.instructions,
    this.dietaryAdvice,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || visitId != null) {
      map['visit_id'] = Variable<String>(visitId);
    }
    map['prescription_date'] = Variable<DateTime>(prescriptionDate);
    map['remedy_index'] = Variable<int>(remedyIndex);
    map['remedy_name'] = Variable<String>(remedyName);
    map['potency'] = Variable<String>(potency);
    if (!nullToAbsent || doseCount != null) {
      map['dose_count'] = Variable<String>(doseCount);
    }
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<String>(frequency);
    }
    if (!nullToAbsent || vehicle != null) {
      map['vehicle'] = Variable<String>(vehicle);
    }
    if (!nullToAbsent || durationDays != null) {
      map['duration_days'] = Variable<String>(durationDays);
    }
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    if (!nullToAbsent || dietaryAdvice != null) {
      map['dietary_advice'] = Variable<String>(dietaryAdvice);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PrescriptionsCompanion toCompanion(bool nullToAbsent) {
    return PrescriptionsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      visitId:
          visitId == null && nullToAbsent
              ? const Value.absent()
              : Value(visitId),
      prescriptionDate: Value(prescriptionDate),
      remedyIndex: Value(remedyIndex),
      remedyName: Value(remedyName),
      potency: Value(potency),
      doseCount:
          doseCount == null && nullToAbsent
              ? const Value.absent()
              : Value(doseCount),
      frequency:
          frequency == null && nullToAbsent
              ? const Value.absent()
              : Value(frequency),
      vehicle:
          vehicle == null && nullToAbsent
              ? const Value.absent()
              : Value(vehicle),
      durationDays:
          durationDays == null && nullToAbsent
              ? const Value.absent()
              : Value(durationDays),
      instructions:
          instructions == null && nullToAbsent
              ? const Value.absent()
              : Value(instructions),
      dietaryAdvice:
          dietaryAdvice == null && nullToAbsent
              ? const Value.absent()
              : Value(dietaryAdvice),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Prescription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prescription(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      visitId: serializer.fromJson<String?>(json['visitId']),
      prescriptionDate: serializer.fromJson<DateTime>(json['prescriptionDate']),
      remedyIndex: serializer.fromJson<int>(json['remedyIndex']),
      remedyName: serializer.fromJson<String>(json['remedyName']),
      potency: serializer.fromJson<String>(json['potency']),
      doseCount: serializer.fromJson<String?>(json['doseCount']),
      frequency: serializer.fromJson<String?>(json['frequency']),
      vehicle: serializer.fromJson<String?>(json['vehicle']),
      durationDays: serializer.fromJson<String?>(json['durationDays']),
      instructions: serializer.fromJson<String?>(json['instructions']),
      dietaryAdvice: serializer.fromJson<String?>(json['dietaryAdvice']),
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
      'patientId': serializer.toJson<String>(patientId),
      'visitId': serializer.toJson<String?>(visitId),
      'prescriptionDate': serializer.toJson<DateTime>(prescriptionDate),
      'remedyIndex': serializer.toJson<int>(remedyIndex),
      'remedyName': serializer.toJson<String>(remedyName),
      'potency': serializer.toJson<String>(potency),
      'doseCount': serializer.toJson<String?>(doseCount),
      'frequency': serializer.toJson<String?>(frequency),
      'vehicle': serializer.toJson<String?>(vehicle),
      'durationDays': serializer.toJson<String?>(durationDays),
      'instructions': serializer.toJson<String?>(instructions),
      'dietaryAdvice': serializer.toJson<String?>(dietaryAdvice),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Prescription copyWith({
    String? id,
    String? patientId,
    Value<String?> visitId = const Value.absent(),
    DateTime? prescriptionDate,
    int? remedyIndex,
    String? remedyName,
    String? potency,
    Value<String?> doseCount = const Value.absent(),
    Value<String?> frequency = const Value.absent(),
    Value<String?> vehicle = const Value.absent(),
    Value<String?> durationDays = const Value.absent(),
    Value<String?> instructions = const Value.absent(),
    Value<String?> dietaryAdvice = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Prescription(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    visitId: visitId.present ? visitId.value : this.visitId,
    prescriptionDate: prescriptionDate ?? this.prescriptionDate,
    remedyIndex: remedyIndex ?? this.remedyIndex,
    remedyName: remedyName ?? this.remedyName,
    potency: potency ?? this.potency,
    doseCount: doseCount.present ? doseCount.value : this.doseCount,
    frequency: frequency.present ? frequency.value : this.frequency,
    vehicle: vehicle.present ? vehicle.value : this.vehicle,
    durationDays: durationDays.present ? durationDays.value : this.durationDays,
    instructions: instructions.present ? instructions.value : this.instructions,
    dietaryAdvice:
        dietaryAdvice.present ? dietaryAdvice.value : this.dietaryAdvice,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Prescription copyWithCompanion(PrescriptionsCompanion data) {
    return Prescription(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      prescriptionDate:
          data.prescriptionDate.present
              ? data.prescriptionDate.value
              : this.prescriptionDate,
      remedyIndex:
          data.remedyIndex.present ? data.remedyIndex.value : this.remedyIndex,
      remedyName:
          data.remedyName.present ? data.remedyName.value : this.remedyName,
      potency: data.potency.present ? data.potency.value : this.potency,
      doseCount: data.doseCount.present ? data.doseCount.value : this.doseCount,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      vehicle: data.vehicle.present ? data.vehicle.value : this.vehicle,
      durationDays:
          data.durationDays.present
              ? data.durationDays.value
              : this.durationDays,
      instructions:
          data.instructions.present
              ? data.instructions.value
              : this.instructions,
      dietaryAdvice:
          data.dietaryAdvice.present
              ? data.dietaryAdvice.value
              : this.dietaryAdvice,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prescription(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('visitId: $visitId, ')
          ..write('prescriptionDate: $prescriptionDate, ')
          ..write('remedyIndex: $remedyIndex, ')
          ..write('remedyName: $remedyName, ')
          ..write('potency: $potency, ')
          ..write('doseCount: $doseCount, ')
          ..write('frequency: $frequency, ')
          ..write('vehicle: $vehicle, ')
          ..write('durationDays: $durationDays, ')
          ..write('instructions: $instructions, ')
          ..write('dietaryAdvice: $dietaryAdvice, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    visitId,
    prescriptionDate,
    remedyIndex,
    remedyName,
    potency,
    doseCount,
    frequency,
    vehicle,
    durationDays,
    instructions,
    dietaryAdvice,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prescription &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.visitId == this.visitId &&
          other.prescriptionDate == this.prescriptionDate &&
          other.remedyIndex == this.remedyIndex &&
          other.remedyName == this.remedyName &&
          other.potency == this.potency &&
          other.doseCount == this.doseCount &&
          other.frequency == this.frequency &&
          other.vehicle == this.vehicle &&
          other.durationDays == this.durationDays &&
          other.instructions == this.instructions &&
          other.dietaryAdvice == this.dietaryAdvice &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PrescriptionsCompanion extends UpdateCompanion<Prescription> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String?> visitId;
  final Value<DateTime> prescriptionDate;
  final Value<int> remedyIndex;
  final Value<String> remedyName;
  final Value<String> potency;
  final Value<String?> doseCount;
  final Value<String?> frequency;
  final Value<String?> vehicle;
  final Value<String?> durationDays;
  final Value<String?> instructions;
  final Value<String?> dietaryAdvice;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PrescriptionsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.visitId = const Value.absent(),
    this.prescriptionDate = const Value.absent(),
    this.remedyIndex = const Value.absent(),
    this.remedyName = const Value.absent(),
    this.potency = const Value.absent(),
    this.doseCount = const Value.absent(),
    this.frequency = const Value.absent(),
    this.vehicle = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.instructions = const Value.absent(),
    this.dietaryAdvice = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrescriptionsCompanion.insert({
    required String id,
    required String patientId,
    this.visitId = const Value.absent(),
    this.prescriptionDate = const Value.absent(),
    this.remedyIndex = const Value.absent(),
    required String remedyName,
    required String potency,
    this.doseCount = const Value.absent(),
    this.frequency = const Value.absent(),
    this.vehicle = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.instructions = const Value.absent(),
    this.dietaryAdvice = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       remedyName = Value(remedyName),
       potency = Value(potency);
  static Insertable<Prescription> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? visitId,
    Expression<DateTime>? prescriptionDate,
    Expression<int>? remedyIndex,
    Expression<String>? remedyName,
    Expression<String>? potency,
    Expression<String>? doseCount,
    Expression<String>? frequency,
    Expression<String>? vehicle,
    Expression<String>? durationDays,
    Expression<String>? instructions,
    Expression<String>? dietaryAdvice,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (visitId != null) 'visit_id': visitId,
      if (prescriptionDate != null) 'prescription_date': prescriptionDate,
      if (remedyIndex != null) 'remedy_index': remedyIndex,
      if (remedyName != null) 'remedy_name': remedyName,
      if (potency != null) 'potency': potency,
      if (doseCount != null) 'dose_count': doseCount,
      if (frequency != null) 'frequency': frequency,
      if (vehicle != null) 'vehicle': vehicle,
      if (durationDays != null) 'duration_days': durationDays,
      if (instructions != null) 'instructions': instructions,
      if (dietaryAdvice != null) 'dietary_advice': dietaryAdvice,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrescriptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String?>? visitId,
    Value<DateTime>? prescriptionDate,
    Value<int>? remedyIndex,
    Value<String>? remedyName,
    Value<String>? potency,
    Value<String?>? doseCount,
    Value<String?>? frequency,
    Value<String?>? vehicle,
    Value<String?>? durationDays,
    Value<String?>? instructions,
    Value<String?>? dietaryAdvice,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PrescriptionsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      visitId: visitId ?? this.visitId,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      remedyIndex: remedyIndex ?? this.remedyIndex,
      remedyName: remedyName ?? this.remedyName,
      potency: potency ?? this.potency,
      doseCount: doseCount ?? this.doseCount,
      frequency: frequency ?? this.frequency,
      vehicle: vehicle ?? this.vehicle,
      durationDays: durationDays ?? this.durationDays,
      instructions: instructions ?? this.instructions,
      dietaryAdvice: dietaryAdvice ?? this.dietaryAdvice,
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
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (prescriptionDate.present) {
      map['prescription_date'] = Variable<DateTime>(prescriptionDate.value);
    }
    if (remedyIndex.present) {
      map['remedy_index'] = Variable<int>(remedyIndex.value);
    }
    if (remedyName.present) {
      map['remedy_name'] = Variable<String>(remedyName.value);
    }
    if (potency.present) {
      map['potency'] = Variable<String>(potency.value);
    }
    if (doseCount.present) {
      map['dose_count'] = Variable<String>(doseCount.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (vehicle.present) {
      map['vehicle'] = Variable<String>(vehicle.value);
    }
    if (durationDays.present) {
      map['duration_days'] = Variable<String>(durationDays.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (dietaryAdvice.present) {
      map['dietary_advice'] = Variable<String>(dietaryAdvice.value);
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
    return (StringBuffer('PrescriptionsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('visitId: $visitId, ')
          ..write('prescriptionDate: $prescriptionDate, ')
          ..write('remedyIndex: $remedyIndex, ')
          ..write('remedyName: $remedyName, ')
          ..write('potency: $potency, ')
          ..write('doseCount: $doseCount, ')
          ..write('frequency: $frequency, ')
          ..write('vehicle: $vehicle, ')
          ..write('durationDays: $durationDays, ')
          ..write('instructions: $instructions, ')
          ..write('dietaryAdvice: $dietaryAdvice, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestigationsTable extends Investigations
    with TableInfo<$InvestigationsTable, Investigation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestigationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _testDateMeta = const VerificationMeta(
    'testDate',
  );
  @override
  late final GeneratedColumn<DateTime> testDate = GeneratedColumn<DateTime>(
    'test_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _testCategoryMeta = const VerificationMeta(
    'testCategory',
  );
  @override
  late final GeneratedColumn<String> testCategory = GeneratedColumn<String>(
    'test_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Blood / Biochemistry'),
  );
  static const VerificationMeta _testNameMeta = const VerificationMeta(
    'testName',
  );
  @override
  late final GeneratedColumn<String> testName = GeneratedColumn<String>(
    'test_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numericValueMeta = const VerificationMeta(
    'numericValue',
  );
  @override
  late final GeneratedColumn<double> numericValue = GeneratedColumn<double>(
    'numeric_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stringValueMeta = const VerificationMeta(
    'stringValue',
  );
  @override
  late final GeneratedColumn<String> stringValue = GeneratedColumn<String>(
    'string_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refRangeMinMeta = const VerificationMeta(
    'refRangeMin',
  );
  @override
  late final GeneratedColumn<double> refRangeMin = GeneratedColumn<double>(
    'ref_range_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refRangeMaxMeta = const VerificationMeta(
    'refRangeMax',
  );
  @override
  late final GeneratedColumn<double> refRangeMax = GeneratedColumn<double>(
    'ref_range_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flagMeta = const VerificationMeta('flag');
  @override
  late final GeneratedColumn<String> flag = GeneratedColumn<String>(
    'flag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Normal'),
  );
  static const VerificationMeta _labNameMeta = const VerificationMeta(
    'labName',
  );
  @override
  late final GeneratedColumn<String> labName = GeneratedColumn<String>(
    'lab_name',
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
    patientId,
    visitId,
    testDate,
    testCategory,
    testName,
    numericValue,
    stringValue,
    unit,
    refRangeMin,
    refRangeMax,
    flag,
    labName,
    notes,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investigations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Investigation> instance, {
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
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    }
    if (data.containsKey('test_date')) {
      context.handle(
        _testDateMeta,
        testDate.isAcceptableOrUnknown(data['test_date']!, _testDateMeta),
      );
    }
    if (data.containsKey('test_category')) {
      context.handle(
        _testCategoryMeta,
        testCategory.isAcceptableOrUnknown(
          data['test_category']!,
          _testCategoryMeta,
        ),
      );
    }
    if (data.containsKey('test_name')) {
      context.handle(
        _testNameMeta,
        testName.isAcceptableOrUnknown(data['test_name']!, _testNameMeta),
      );
    } else if (isInserting) {
      context.missing(_testNameMeta);
    }
    if (data.containsKey('numeric_value')) {
      context.handle(
        _numericValueMeta,
        numericValue.isAcceptableOrUnknown(
          data['numeric_value']!,
          _numericValueMeta,
        ),
      );
    }
    if (data.containsKey('string_value')) {
      context.handle(
        _stringValueMeta,
        stringValue.isAcceptableOrUnknown(
          data['string_value']!,
          _stringValueMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('ref_range_min')) {
      context.handle(
        _refRangeMinMeta,
        refRangeMin.isAcceptableOrUnknown(
          data['ref_range_min']!,
          _refRangeMinMeta,
        ),
      );
    }
    if (data.containsKey('ref_range_max')) {
      context.handle(
        _refRangeMaxMeta,
        refRangeMax.isAcceptableOrUnknown(
          data['ref_range_max']!,
          _refRangeMaxMeta,
        ),
      );
    }
    if (data.containsKey('flag')) {
      context.handle(
        _flagMeta,
        flag.isAcceptableOrUnknown(data['flag']!, _flagMeta),
      );
    }
    if (data.containsKey('lab_name')) {
      context.handle(
        _labNameMeta,
        labName.isAcceptableOrUnknown(data['lab_name']!, _labNameMeta),
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
  Investigation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Investigation(
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
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      ),
      testDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}test_date'],
          )!,
      testCategory:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}test_category'],
          )!,
      testName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}test_name'],
          )!,
      numericValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}numeric_value'],
      ),
      stringValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}string_value'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      refRangeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ref_range_min'],
      ),
      refRangeMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ref_range_max'],
      ),
      flag:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}flag'],
          )!,
      labName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lab_name'],
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
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $InvestigationsTable createAlias(String alias) {
    return $InvestigationsTable(attachedDatabase, alias);
  }
}

class Investigation extends DataClass implements Insertable<Investigation> {
  final String id;
  final String patientId;
  final String? visitId;
  final DateTime testDate;
  final String testCategory;
  final String testName;
  final double? numericValue;
  final String? stringValue;
  final String? unit;
  final double? refRangeMin;
  final double? refRangeMax;
  final String flag;
  final String? labName;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Investigation({
    required this.id,
    required this.patientId,
    this.visitId,
    required this.testDate,
    required this.testCategory,
    required this.testName,
    this.numericValue,
    this.stringValue,
    this.unit,
    this.refRangeMin,
    this.refRangeMax,
    required this.flag,
    this.labName,
    this.notes,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || visitId != null) {
      map['visit_id'] = Variable<String>(visitId);
    }
    map['test_date'] = Variable<DateTime>(testDate);
    map['test_category'] = Variable<String>(testCategory);
    map['test_name'] = Variable<String>(testName);
    if (!nullToAbsent || numericValue != null) {
      map['numeric_value'] = Variable<double>(numericValue);
    }
    if (!nullToAbsent || stringValue != null) {
      map['string_value'] = Variable<String>(stringValue);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || refRangeMin != null) {
      map['ref_range_min'] = Variable<double>(refRangeMin);
    }
    if (!nullToAbsent || refRangeMax != null) {
      map['ref_range_max'] = Variable<double>(refRangeMax);
    }
    map['flag'] = Variable<String>(flag);
    if (!nullToAbsent || labName != null) {
      map['lab_name'] = Variable<String>(labName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InvestigationsCompanion toCompanion(bool nullToAbsent) {
    return InvestigationsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      visitId:
          visitId == null && nullToAbsent
              ? const Value.absent()
              : Value(visitId),
      testDate: Value(testDate),
      testCategory: Value(testCategory),
      testName: Value(testName),
      numericValue:
          numericValue == null && nullToAbsent
              ? const Value.absent()
              : Value(numericValue),
      stringValue:
          stringValue == null && nullToAbsent
              ? const Value.absent()
              : Value(stringValue),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      refRangeMin:
          refRangeMin == null && nullToAbsent
              ? const Value.absent()
              : Value(refRangeMin),
      refRangeMax:
          refRangeMax == null && nullToAbsent
              ? const Value.absent()
              : Value(refRangeMax),
      flag: Value(flag),
      labName:
          labName == null && nullToAbsent
              ? const Value.absent()
              : Value(labName),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Investigation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Investigation(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      visitId: serializer.fromJson<String?>(json['visitId']),
      testDate: serializer.fromJson<DateTime>(json['testDate']),
      testCategory: serializer.fromJson<String>(json['testCategory']),
      testName: serializer.fromJson<String>(json['testName']),
      numericValue: serializer.fromJson<double?>(json['numericValue']),
      stringValue: serializer.fromJson<String?>(json['stringValue']),
      unit: serializer.fromJson<String?>(json['unit']),
      refRangeMin: serializer.fromJson<double?>(json['refRangeMin']),
      refRangeMax: serializer.fromJson<double?>(json['refRangeMax']),
      flag: serializer.fromJson<String>(json['flag']),
      labName: serializer.fromJson<String?>(json['labName']),
      notes: serializer.fromJson<String?>(json['notes']),
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
      'patientId': serializer.toJson<String>(patientId),
      'visitId': serializer.toJson<String?>(visitId),
      'testDate': serializer.toJson<DateTime>(testDate),
      'testCategory': serializer.toJson<String>(testCategory),
      'testName': serializer.toJson<String>(testName),
      'numericValue': serializer.toJson<double?>(numericValue),
      'stringValue': serializer.toJson<String?>(stringValue),
      'unit': serializer.toJson<String?>(unit),
      'refRangeMin': serializer.toJson<double?>(refRangeMin),
      'refRangeMax': serializer.toJson<double?>(refRangeMax),
      'flag': serializer.toJson<String>(flag),
      'labName': serializer.toJson<String?>(labName),
      'notes': serializer.toJson<String?>(notes),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Investigation copyWith({
    String? id,
    String? patientId,
    Value<String?> visitId = const Value.absent(),
    DateTime? testDate,
    String? testCategory,
    String? testName,
    Value<double?> numericValue = const Value.absent(),
    Value<String?> stringValue = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<double?> refRangeMin = const Value.absent(),
    Value<double?> refRangeMax = const Value.absent(),
    String? flag,
    Value<String?> labName = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Investigation(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    visitId: visitId.present ? visitId.value : this.visitId,
    testDate: testDate ?? this.testDate,
    testCategory: testCategory ?? this.testCategory,
    testName: testName ?? this.testName,
    numericValue: numericValue.present ? numericValue.value : this.numericValue,
    stringValue: stringValue.present ? stringValue.value : this.stringValue,
    unit: unit.present ? unit.value : this.unit,
    refRangeMin: refRangeMin.present ? refRangeMin.value : this.refRangeMin,
    refRangeMax: refRangeMax.present ? refRangeMax.value : this.refRangeMax,
    flag: flag ?? this.flag,
    labName: labName.present ? labName.value : this.labName,
    notes: notes.present ? notes.value : this.notes,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Investigation copyWithCompanion(InvestigationsCompanion data) {
    return Investigation(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      testDate: data.testDate.present ? data.testDate.value : this.testDate,
      testCategory:
          data.testCategory.present
              ? data.testCategory.value
              : this.testCategory,
      testName: data.testName.present ? data.testName.value : this.testName,
      numericValue:
          data.numericValue.present
              ? data.numericValue.value
              : this.numericValue,
      stringValue:
          data.stringValue.present ? data.stringValue.value : this.stringValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      refRangeMin:
          data.refRangeMin.present ? data.refRangeMin.value : this.refRangeMin,
      refRangeMax:
          data.refRangeMax.present ? data.refRangeMax.value : this.refRangeMax,
      flag: data.flag.present ? data.flag.value : this.flag,
      labName: data.labName.present ? data.labName.value : this.labName,
      notes: data.notes.present ? data.notes.value : this.notes,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Investigation(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('visitId: $visitId, ')
          ..write('testDate: $testDate, ')
          ..write('testCategory: $testCategory, ')
          ..write('testName: $testName, ')
          ..write('numericValue: $numericValue, ')
          ..write('stringValue: $stringValue, ')
          ..write('unit: $unit, ')
          ..write('refRangeMin: $refRangeMin, ')
          ..write('refRangeMax: $refRangeMax, ')
          ..write('flag: $flag, ')
          ..write('labName: $labName, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    visitId,
    testDate,
    testCategory,
    testName,
    numericValue,
    stringValue,
    unit,
    refRangeMin,
    refRangeMax,
    flag,
    labName,
    notes,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Investigation &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.visitId == this.visitId &&
          other.testDate == this.testDate &&
          other.testCategory == this.testCategory &&
          other.testName == this.testName &&
          other.numericValue == this.numericValue &&
          other.stringValue == this.stringValue &&
          other.unit == this.unit &&
          other.refRangeMin == this.refRangeMin &&
          other.refRangeMax == this.refRangeMax &&
          other.flag == this.flag &&
          other.labName == this.labName &&
          other.notes == this.notes &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InvestigationsCompanion extends UpdateCompanion<Investigation> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String?> visitId;
  final Value<DateTime> testDate;
  final Value<String> testCategory;
  final Value<String> testName;
  final Value<double?> numericValue;
  final Value<String?> stringValue;
  final Value<String?> unit;
  final Value<double?> refRangeMin;
  final Value<double?> refRangeMax;
  final Value<String> flag;
  final Value<String?> labName;
  final Value<String?> notes;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InvestigationsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.visitId = const Value.absent(),
    this.testDate = const Value.absent(),
    this.testCategory = const Value.absent(),
    this.testName = const Value.absent(),
    this.numericValue = const Value.absent(),
    this.stringValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.refRangeMin = const Value.absent(),
    this.refRangeMax = const Value.absent(),
    this.flag = const Value.absent(),
    this.labName = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestigationsCompanion.insert({
    required String id,
    required String patientId,
    this.visitId = const Value.absent(),
    this.testDate = const Value.absent(),
    this.testCategory = const Value.absent(),
    required String testName,
    this.numericValue = const Value.absent(),
    this.stringValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.refRangeMin = const Value.absent(),
    this.refRangeMax = const Value.absent(),
    this.flag = const Value.absent(),
    this.labName = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       testName = Value(testName);
  static Insertable<Investigation> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? visitId,
    Expression<DateTime>? testDate,
    Expression<String>? testCategory,
    Expression<String>? testName,
    Expression<double>? numericValue,
    Expression<String>? stringValue,
    Expression<String>? unit,
    Expression<double>? refRangeMin,
    Expression<double>? refRangeMax,
    Expression<String>? flag,
    Expression<String>? labName,
    Expression<String>? notes,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (visitId != null) 'visit_id': visitId,
      if (testDate != null) 'test_date': testDate,
      if (testCategory != null) 'test_category': testCategory,
      if (testName != null) 'test_name': testName,
      if (numericValue != null) 'numeric_value': numericValue,
      if (stringValue != null) 'string_value': stringValue,
      if (unit != null) 'unit': unit,
      if (refRangeMin != null) 'ref_range_min': refRangeMin,
      if (refRangeMax != null) 'ref_range_max': refRangeMax,
      if (flag != null) 'flag': flag,
      if (labName != null) 'lab_name': labName,
      if (notes != null) 'notes': notes,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestigationsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String?>? visitId,
    Value<DateTime>? testDate,
    Value<String>? testCategory,
    Value<String>? testName,
    Value<double?>? numericValue,
    Value<String?>? stringValue,
    Value<String?>? unit,
    Value<double?>? refRangeMin,
    Value<double?>? refRangeMax,
    Value<String>? flag,
    Value<String?>? labName,
    Value<String?>? notes,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return InvestigationsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      visitId: visitId ?? this.visitId,
      testDate: testDate ?? this.testDate,
      testCategory: testCategory ?? this.testCategory,
      testName: testName ?? this.testName,
      numericValue: numericValue ?? this.numericValue,
      stringValue: stringValue ?? this.stringValue,
      unit: unit ?? this.unit,
      refRangeMin: refRangeMin ?? this.refRangeMin,
      refRangeMax: refRangeMax ?? this.refRangeMax,
      flag: flag ?? this.flag,
      labName: labName ?? this.labName,
      notes: notes ?? this.notes,
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
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (testDate.present) {
      map['test_date'] = Variable<DateTime>(testDate.value);
    }
    if (testCategory.present) {
      map['test_category'] = Variable<String>(testCategory.value);
    }
    if (testName.present) {
      map['test_name'] = Variable<String>(testName.value);
    }
    if (numericValue.present) {
      map['numeric_value'] = Variable<double>(numericValue.value);
    }
    if (stringValue.present) {
      map['string_value'] = Variable<String>(stringValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (refRangeMin.present) {
      map['ref_range_min'] = Variable<double>(refRangeMin.value);
    }
    if (refRangeMax.present) {
      map['ref_range_max'] = Variable<double>(refRangeMax.value);
    }
    if (flag.present) {
      map['flag'] = Variable<String>(flag.value);
    }
    if (labName.present) {
      map['lab_name'] = Variable<String>(labName.value);
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
    return (StringBuffer('InvestigationsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('visitId: $visitId, ')
          ..write('testDate: $testDate, ')
          ..write('testCategory: $testCategory, ')
          ..write('testName: $testName, ')
          ..write('numericValue: $numericValue, ')
          ..write('stringValue: $stringValue, ')
          ..write('unit: $unit, ')
          ..write('refRangeMin: $refRangeMin, ')
          ..write('refRangeMax: $refRangeMax, ')
          ..write('flag: $flag, ')
          ..write('labName: $labName, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $CampsTable camps = $CampsTable(this);
  late final $PatientCaseRecordsTable patientCaseRecords =
      $PatientCaseRecordsTable(this);
  late final $ComplaintsTable complaints = $ComplaintsTable(this);
  late final $PrescriptionsTable prescriptions = $PrescriptionsTable(this);
  late final $InvestigationsTable investigations = $InvestigationsTable(this);
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
    camps,
    patientCaseRecords,
    complaints,
    prescriptions,
    investigations,
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

  static MultiTypedResultKey<$CampsTable, List<Camp>> _campsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.camps,
    aliasName: $_aliasNameGenerator(db.clinics.id, db.camps.clinicId),
  );

  $$CampsTableProcessedTableManager get campsRefs {
    final manager = $$CampsTableTableManager(
      $_db,
      $_db.camps,
    ).filter((f) => f.clinicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_campsRefsTable($_db));
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

  Expression<bool> campsRefs(
    Expression<bool> Function($$CampsTableFilterComposer f) f,
  ) {
    final $$CampsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.camps,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampsTableFilterComposer(
            $db: $db,
            $table: $db.camps,
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

  Expression<T> campsRefs<T extends Object>(
    Expression<T> Function($$CampsTableAnnotationComposer a) f,
  ) {
    final $$CampsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.camps,
      getReferencedColumn: (t) => t.clinicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampsTableAnnotationComposer(
            $db: $db,
            $table: $db.camps,
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
            bool campsRefs,
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
            campsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (visitsRefs) db.visits,
                if (cashMemosRefs) db.cashMemos,
                if (expensesRefs) db.expenses,
                if (reviewRequestsRefs) db.reviewRequests,
                if (footfallsRefs) db.footfalls,
                if (campsRefs) db.camps,
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
                  if (campsRefs)
                    await $_getPrefetchedData<Clinic, $ClinicsTable, Camp>(
                      currentTable: table,
                      referencedTable: $$ClinicsTableReferences._campsRefsTable(
                        db,
                      ),
                      managerFromTypedResult:
                          (p0) =>
                              $$ClinicsTableReferences(db, table, p0).campsRefs,
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
        bool campsRefs,
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

  static MultiTypedResultKey<$PatientCaseRecordsTable, List<PatientCaseRecord>>
  _patientCaseRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.patientCaseRecords,
        aliasName: $_aliasNameGenerator(
          db.patients.id,
          db.patientCaseRecords.patientId,
        ),
      );

  $$PatientCaseRecordsTableProcessedTableManager get patientCaseRecordsRefs {
    final manager = $$PatientCaseRecordsTableTableManager(
      $_db,
      $_db.patientCaseRecords,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _patientCaseRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComplaintsTable, List<Complaint>>
  _complaintsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.complaints,
    aliasName: $_aliasNameGenerator(db.patients.id, db.complaints.patientId),
  );

  $$ComplaintsTableProcessedTableManager get complaintsRefs {
    final manager = $$ComplaintsTableTableManager(
      $_db,
      $_db.complaints,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_complaintsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrescriptionsTable, List<Prescription>>
  _prescriptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prescriptions,
    aliasName: $_aliasNameGenerator(db.patients.id, db.prescriptions.patientId),
  );

  $$PrescriptionsTableProcessedTableManager get prescriptionsRefs {
    final manager = $$PrescriptionsTableTableManager(
      $_db,
      $_db.prescriptions,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_prescriptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestigationsTable, List<Investigation>>
  _investigationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.investigations,
    aliasName: $_aliasNameGenerator(
      db.patients.id,
      db.investigations.patientId,
    ),
  );

  $$InvestigationsTableProcessedTableManager get investigationsRefs {
    final manager = $$InvestigationsTableTableManager(
      $_db,
      $_db.investigations,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_investigationsRefsTable($_db));
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

  Expression<bool> patientCaseRecordsRefs(
    Expression<bool> Function($$PatientCaseRecordsTableFilterComposer f) f,
  ) {
    final $$PatientCaseRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.patientCaseRecords,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientCaseRecordsTableFilterComposer(
            $db: $db,
            $table: $db.patientCaseRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> complaintsRefs(
    Expression<bool> Function($$ComplaintsTableFilterComposer f) f,
  ) {
    final $$ComplaintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableFilterComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prescriptionsRefs(
    Expression<bool> Function($$PrescriptionsTableFilterComposer f) f,
  ) {
    final $$PrescriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionsTableFilterComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investigationsRefs(
    Expression<bool> Function($$InvestigationsTableFilterComposer f) f,
  ) {
    final $$InvestigationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investigations,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestigationsTableFilterComposer(
            $db: $db,
            $table: $db.investigations,
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

  Expression<T> patientCaseRecordsRefs<T extends Object>(
    Expression<T> Function($$PatientCaseRecordsTableAnnotationComposer a) f,
  ) {
    final $$PatientCaseRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.patientCaseRecords,
          getReferencedColumn: (t) => t.patientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PatientCaseRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.patientCaseRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> complaintsRefs<T extends Object>(
    Expression<T> Function($$ComplaintsTableAnnotationComposer a) f,
  ) {
    final $$ComplaintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableAnnotationComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> prescriptionsRefs<T extends Object>(
    Expression<T> Function($$PrescriptionsTableAnnotationComposer a) f,
  ) {
    final $$PrescriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> investigationsRefs<T extends Object>(
    Expression<T> Function($$InvestigationsTableAnnotationComposer a) f,
  ) {
    final $$InvestigationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investigations,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestigationsTableAnnotationComposer(
            $db: $db,
            $table: $db.investigations,
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
            bool patientCaseRecordsRefs,
            bool complaintsRefs,
            bool prescriptionsRefs,
            bool investigationsRefs,
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
            patientCaseRecordsRefs = false,
            complaintsRefs = false,
            prescriptionsRefs = false,
            investigationsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (visitsRefs) db.visits,
                if (cashMemosRefs) db.cashMemos,
                if (reviewRequestsRefs) db.reviewRequests,
                if (footfallsRefs) db.footfalls,
                if (patientCaseRecordsRefs) db.patientCaseRecords,
                if (complaintsRefs) db.complaints,
                if (prescriptionsRefs) db.prescriptions,
                if (investigationsRefs) db.investigations,
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
                  if (patientCaseRecordsRefs)
                    await $_getPrefetchedData<
                      Patient,
                      $PatientsTable,
                      PatientCaseRecord
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._patientCaseRecordsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).patientCaseRecordsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.patientId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (complaintsRefs)
                    await $_getPrefetchedData<
                      Patient,
                      $PatientsTable,
                      Complaint
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._complaintsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).complaintsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.patientId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (prescriptionsRefs)
                    await $_getPrefetchedData<
                      Patient,
                      $PatientsTable,
                      Prescription
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._prescriptionsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).prescriptionsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.patientId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (investigationsRefs)
                    await $_getPrefetchedData<
                      Patient,
                      $PatientsTable,
                      Investigation
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._investigationsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).investigationsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.patientId == item.id,
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
        bool patientCaseRecordsRefs,
        bool complaintsRefs,
        bool prescriptionsRefs,
        bool investigationsRefs,
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

  static MultiTypedResultKey<$ComplaintsTable, List<Complaint>>
  _complaintsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.complaints,
    aliasName: $_aliasNameGenerator(db.visits.id, db.complaints.visitId),
  );

  $$ComplaintsTableProcessedTableManager get complaintsRefs {
    final manager = $$ComplaintsTableTableManager(
      $_db,
      $_db.complaints,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_complaintsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrescriptionsTable, List<Prescription>>
  _prescriptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prescriptions,
    aliasName: $_aliasNameGenerator(db.visits.id, db.prescriptions.visitId),
  );

  $$PrescriptionsTableProcessedTableManager get prescriptionsRefs {
    final manager = $$PrescriptionsTableTableManager(
      $_db,
      $_db.prescriptions,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_prescriptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestigationsTable, List<Investigation>>
  _investigationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.investigations,
    aliasName: $_aliasNameGenerator(db.visits.id, db.investigations.visitId),
  );

  $$InvestigationsTableProcessedTableManager get investigationsRefs {
    final manager = $$InvestigationsTableTableManager(
      $_db,
      $_db.investigations,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_investigationsRefsTable($_db));
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

  Expression<bool> complaintsRefs(
    Expression<bool> Function($$ComplaintsTableFilterComposer f) f,
  ) {
    final $$ComplaintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableFilterComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prescriptionsRefs(
    Expression<bool> Function($$PrescriptionsTableFilterComposer f) f,
  ) {
    final $$PrescriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionsTableFilterComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investigationsRefs(
    Expression<bool> Function($$InvestigationsTableFilterComposer f) f,
  ) {
    final $$InvestigationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investigations,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestigationsTableFilterComposer(
            $db: $db,
            $table: $db.investigations,
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

  Expression<T> complaintsRefs<T extends Object>(
    Expression<T> Function($$ComplaintsTableAnnotationComposer a) f,
  ) {
    final $$ComplaintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableAnnotationComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> prescriptionsRefs<T extends Object>(
    Expression<T> Function($$PrescriptionsTableAnnotationComposer a) f,
  ) {
    final $$PrescriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> investigationsRefs<T extends Object>(
    Expression<T> Function($$InvestigationsTableAnnotationComposer a) f,
  ) {
    final $$InvestigationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investigations,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestigationsTableAnnotationComposer(
            $db: $db,
            $table: $db.investigations,
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
            bool complaintsRefs,
            bool prescriptionsRefs,
            bool investigationsRefs,
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
            complaintsRefs = false,
            prescriptionsRefs = false,
            investigationsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cashMemosRefs) db.cashMemos,
                if (complaintsRefs) db.complaints,
                if (prescriptionsRefs) db.prescriptions,
                if (investigationsRefs) db.investigations,
              ],
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
                  if (complaintsRefs)
                    await $_getPrefetchedData<Visit, $VisitsTable, Complaint>(
                      currentTable: table,
                      referencedTable: $$VisitsTableReferences
                          ._complaintsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).complaintsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.visitId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (prescriptionsRefs)
                    await $_getPrefetchedData<
                      Visit,
                      $VisitsTable,
                      Prescription
                    >(
                      currentTable: table,
                      referencedTable: $$VisitsTableReferences
                          ._prescriptionsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).prescriptionsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.visitId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (investigationsRefs)
                    await $_getPrefetchedData<
                      Visit,
                      $VisitsTable,
                      Investigation
                    >(
                      currentTable: table,
                      referencedTable: $$VisitsTableReferences
                          ._investigationsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).investigationsRefs,
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
        bool complaintsRefs,
        bool prescriptionsRefs,
        bool investigationsRefs,
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
typedef $$CampsTableCreateCompanionBuilder =
    CampsCompanion Function({
      required String id,
      required String name,
      Value<DateTime> date,
      Value<String?> location,
      Value<double> cost,
      Value<int> attendance,
      Value<String?> clinicId,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CampsTableUpdateCompanionBuilder =
    CampsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> date,
      Value<String?> location,
      Value<double> cost,
      Value<int> attendance,
      Value<String?> clinicId,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CampsTableReferences
    extends BaseReferences<_$AppDatabase, $CampsTable, Camp> {
  $$CampsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClinicsTable _clinicIdTable(_$AppDatabase db) => db.clinics
      .createAlias($_aliasNameGenerator(db.camps.clinicId, db.clinics.id));

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

class $$CampsTableFilterComposer extends Composer<_$AppDatabase, $CampsTable> {
  $$CampsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attendance => $composableBuilder(
    column: $table.attendance,
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
}

class $$CampsTableOrderingComposer
    extends Composer<_$AppDatabase, $CampsTable> {
  $$CampsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attendance => $composableBuilder(
    column: $table.attendance,
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
}

class $$CampsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CampsTable> {
  $$CampsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<int> get attendance => $composableBuilder(
    column: $table.attendance,
    builder: (column) => column,
  );

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
}

class $$CampsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CampsTable,
          Camp,
          $$CampsTableFilterComposer,
          $$CampsTableOrderingComposer,
          $$CampsTableAnnotationComposer,
          $$CampsTableCreateCompanionBuilder,
          $$CampsTableUpdateCompanionBuilder,
          (Camp, $$CampsTableReferences),
          Camp,
          PrefetchHooks Function({bool clinicId})
        > {
  $$CampsTableTableManager(_$AppDatabase db, $CampsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CampsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CampsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CampsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<int> attendance = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampsCompanion(
                id: id,
                name: name,
                date: date,
                location: location,
                cost: cost,
                attendance: attendance,
                clinicId: clinicId,
                notes: notes,
                isDeleted: isDeleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<DateTime> date = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<int> attendance = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampsCompanion.insert(
                id: id,
                name: name,
                date: date,
                location: location,
                cost: cost,
                attendance: attendance,
                clinicId: clinicId,
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
                          $$CampsTableReferences(db, table, e),
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
                            referencedTable: $$CampsTableReferences
                                ._clinicIdTable(db),
                            referencedColumn:
                                $$CampsTableReferences._clinicIdTable(db).id,
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

typedef $$CampsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CampsTable,
      Camp,
      $$CampsTableFilterComposer,
      $$CampsTableOrderingComposer,
      $$CampsTableAnnotationComposer,
      $$CampsTableCreateCompanionBuilder,
      $$CampsTableUpdateCompanionBuilder,
      (Camp, $$CampsTableReferences),
      Camp,
      PrefetchHooks Function({bool clinicId})
    >;
typedef $$PatientCaseRecordsTableCreateCompanionBuilder =
    PatientCaseRecordsCompanion Function({
      required String id,
      required String patientId,
      Value<DateTime> recordDate,
      Value<String?> chiefComplaintsJson,
      Value<String?> hpi,
      Value<String?> pastHistoryJson,
      Value<String?> familyHistoryJson,
      Value<String?> developmentalHistoryJson,
      Value<String?> physicalGeneralsJson,
      Value<String?> mentalGeneralsJson,
      Value<String?> lifestyleJson,
      Value<String?> clinicalExamJson,
      Value<String?> miasmaticAnalysisJson,
      Value<String?> caseTotalityJson,
      Value<String?> baselinePrescriptionJson,
      Value<String?> investigationsJson,
      Value<String?> followUpNotes,
      Value<String?> outcome,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PatientCaseRecordsTableUpdateCompanionBuilder =
    PatientCaseRecordsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<DateTime> recordDate,
      Value<String?> chiefComplaintsJson,
      Value<String?> hpi,
      Value<String?> pastHistoryJson,
      Value<String?> familyHistoryJson,
      Value<String?> developmentalHistoryJson,
      Value<String?> physicalGeneralsJson,
      Value<String?> mentalGeneralsJson,
      Value<String?> lifestyleJson,
      Value<String?> clinicalExamJson,
      Value<String?> miasmaticAnalysisJson,
      Value<String?> caseTotalityJson,
      Value<String?> baselinePrescriptionJson,
      Value<String?> investigationsJson,
      Value<String?> followUpNotes,
      Value<String?> outcome,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PatientCaseRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PatientCaseRecordsTable,
          PatientCaseRecord
        > {
  $$PatientCaseRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias(
        $_aliasNameGenerator(db.patientCaseRecords.patientId, db.patients.id),
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
}

class $$PatientCaseRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientCaseRecordsTable> {
  $$PatientCaseRecordsTableFilterComposer({
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

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chiefComplaintsJson => $composableBuilder(
    column: $table.chiefComplaintsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hpi => $composableBuilder(
    column: $table.hpi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pastHistoryJson => $composableBuilder(
    column: $table.pastHistoryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyHistoryJson => $composableBuilder(
    column: $table.familyHistoryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get developmentalHistoryJson => $composableBuilder(
    column: $table.developmentalHistoryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get physicalGeneralsJson => $composableBuilder(
    column: $table.physicalGeneralsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mentalGeneralsJson => $composableBuilder(
    column: $table.mentalGeneralsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifestyleJson => $composableBuilder(
    column: $table.lifestyleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicalExamJson => $composableBuilder(
    column: $table.clinicalExamJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get miasmaticAnalysisJson => $composableBuilder(
    column: $table.miasmaticAnalysisJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caseTotalityJson => $composableBuilder(
    column: $table.caseTotalityJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baselinePrescriptionJson => $composableBuilder(
    column: $table.baselinePrescriptionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get investigationsJson => $composableBuilder(
    column: $table.investigationsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get followUpNotes => $composableBuilder(
    column: $table.followUpNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
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
}

class $$PatientCaseRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientCaseRecordsTable> {
  $$PatientCaseRecordsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chiefComplaintsJson => $composableBuilder(
    column: $table.chiefComplaintsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hpi => $composableBuilder(
    column: $table.hpi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pastHistoryJson => $composableBuilder(
    column: $table.pastHistoryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyHistoryJson => $composableBuilder(
    column: $table.familyHistoryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get developmentalHistoryJson => $composableBuilder(
    column: $table.developmentalHistoryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get physicalGeneralsJson => $composableBuilder(
    column: $table.physicalGeneralsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mentalGeneralsJson => $composableBuilder(
    column: $table.mentalGeneralsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifestyleJson => $composableBuilder(
    column: $table.lifestyleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicalExamJson => $composableBuilder(
    column: $table.clinicalExamJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get miasmaticAnalysisJson => $composableBuilder(
    column: $table.miasmaticAnalysisJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caseTotalityJson => $composableBuilder(
    column: $table.caseTotalityJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baselinePrescriptionJson => $composableBuilder(
    column: $table.baselinePrescriptionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get investigationsJson => $composableBuilder(
    column: $table.investigationsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get followUpNotes => $composableBuilder(
    column: $table.followUpNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
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
}

class $$PatientCaseRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientCaseRecordsTable> {
  $$PatientCaseRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chiefComplaintsJson => $composableBuilder(
    column: $table.chiefComplaintsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hpi =>
      $composableBuilder(column: $table.hpi, builder: (column) => column);

  GeneratedColumn<String> get pastHistoryJson => $composableBuilder(
    column: $table.pastHistoryJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familyHistoryJson => $composableBuilder(
    column: $table.familyHistoryJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get developmentalHistoryJson => $composableBuilder(
    column: $table.developmentalHistoryJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get physicalGeneralsJson => $composableBuilder(
    column: $table.physicalGeneralsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mentalGeneralsJson => $composableBuilder(
    column: $table.mentalGeneralsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifestyleJson => $composableBuilder(
    column: $table.lifestyleJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicalExamJson => $composableBuilder(
    column: $table.clinicalExamJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get miasmaticAnalysisJson => $composableBuilder(
    column: $table.miasmaticAnalysisJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get caseTotalityJson => $composableBuilder(
    column: $table.caseTotalityJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baselinePrescriptionJson => $composableBuilder(
    column: $table.baselinePrescriptionJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get investigationsJson => $composableBuilder(
    column: $table.investigationsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get followUpNotes => $composableBuilder(
    column: $table.followUpNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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
}

class $$PatientCaseRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientCaseRecordsTable,
          PatientCaseRecord,
          $$PatientCaseRecordsTableFilterComposer,
          $$PatientCaseRecordsTableOrderingComposer,
          $$PatientCaseRecordsTableAnnotationComposer,
          $$PatientCaseRecordsTableCreateCompanionBuilder,
          $$PatientCaseRecordsTableUpdateCompanionBuilder,
          (PatientCaseRecord, $$PatientCaseRecordsTableReferences),
          PatientCaseRecord,
          PrefetchHooks Function({bool patientId})
        > {
  $$PatientCaseRecordsTableTableManager(
    _$AppDatabase db,
    $PatientCaseRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PatientCaseRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$PatientCaseRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$PatientCaseRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<String?> chiefComplaintsJson = const Value.absent(),
                Value<String?> hpi = const Value.absent(),
                Value<String?> pastHistoryJson = const Value.absent(),
                Value<String?> familyHistoryJson = const Value.absent(),
                Value<String?> developmentalHistoryJson = const Value.absent(),
                Value<String?> physicalGeneralsJson = const Value.absent(),
                Value<String?> mentalGeneralsJson = const Value.absent(),
                Value<String?> lifestyleJson = const Value.absent(),
                Value<String?> clinicalExamJson = const Value.absent(),
                Value<String?> miasmaticAnalysisJson = const Value.absent(),
                Value<String?> caseTotalityJson = const Value.absent(),
                Value<String?> baselinePrescriptionJson = const Value.absent(),
                Value<String?> investigationsJson = const Value.absent(),
                Value<String?> followUpNotes = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientCaseRecordsCompanion(
                id: id,
                patientId: patientId,
                recordDate: recordDate,
                chiefComplaintsJson: chiefComplaintsJson,
                hpi: hpi,
                pastHistoryJson: pastHistoryJson,
                familyHistoryJson: familyHistoryJson,
                developmentalHistoryJson: developmentalHistoryJson,
                physicalGeneralsJson: physicalGeneralsJson,
                mentalGeneralsJson: mentalGeneralsJson,
                lifestyleJson: lifestyleJson,
                clinicalExamJson: clinicalExamJson,
                miasmaticAnalysisJson: miasmaticAnalysisJson,
                caseTotalityJson: caseTotalityJson,
                baselinePrescriptionJson: baselinePrescriptionJson,
                investigationsJson: investigationsJson,
                followUpNotes: followUpNotes,
                outcome: outcome,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                Value<DateTime> recordDate = const Value.absent(),
                Value<String?> chiefComplaintsJson = const Value.absent(),
                Value<String?> hpi = const Value.absent(),
                Value<String?> pastHistoryJson = const Value.absent(),
                Value<String?> familyHistoryJson = const Value.absent(),
                Value<String?> developmentalHistoryJson = const Value.absent(),
                Value<String?> physicalGeneralsJson = const Value.absent(),
                Value<String?> mentalGeneralsJson = const Value.absent(),
                Value<String?> lifestyleJson = const Value.absent(),
                Value<String?> clinicalExamJson = const Value.absent(),
                Value<String?> miasmaticAnalysisJson = const Value.absent(),
                Value<String?> caseTotalityJson = const Value.absent(),
                Value<String?> baselinePrescriptionJson = const Value.absent(),
                Value<String?> investigationsJson = const Value.absent(),
                Value<String?> followUpNotes = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientCaseRecordsCompanion.insert(
                id: id,
                patientId: patientId,
                recordDate: recordDate,
                chiefComplaintsJson: chiefComplaintsJson,
                hpi: hpi,
                pastHistoryJson: pastHistoryJson,
                familyHistoryJson: familyHistoryJson,
                developmentalHistoryJson: developmentalHistoryJson,
                physicalGeneralsJson: physicalGeneralsJson,
                mentalGeneralsJson: mentalGeneralsJson,
                lifestyleJson: lifestyleJson,
                clinicalExamJson: clinicalExamJson,
                miasmaticAnalysisJson: miasmaticAnalysisJson,
                caseTotalityJson: caseTotalityJson,
                baselinePrescriptionJson: baselinePrescriptionJson,
                investigationsJson: investigationsJson,
                followUpNotes: followUpNotes,
                outcome: outcome,
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
                          $$PatientCaseRecordsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({patientId = false}) {
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
                            referencedTable: $$PatientCaseRecordsTableReferences
                                ._patientIdTable(db),
                            referencedColumn:
                                $$PatientCaseRecordsTableReferences
                                    ._patientIdTable(db)
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

typedef $$PatientCaseRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientCaseRecordsTable,
      PatientCaseRecord,
      $$PatientCaseRecordsTableFilterComposer,
      $$PatientCaseRecordsTableOrderingComposer,
      $$PatientCaseRecordsTableAnnotationComposer,
      $$PatientCaseRecordsTableCreateCompanionBuilder,
      $$PatientCaseRecordsTableUpdateCompanionBuilder,
      (PatientCaseRecord, $$PatientCaseRecordsTableReferences),
      PatientCaseRecord,
      PrefetchHooks Function({bool patientId})
    >;
typedef $$ComplaintsTableCreateCompanionBuilder =
    ComplaintsCompanion Function({
      required String id,
      required String patientId,
      Value<String?> visitId,
      Value<int> complaintIndex,
      required String complaintName,
      Value<String?> location,
      Value<String?> side,
      Value<String?> onset,
      Value<String?> duration,
      Value<String?> sensation,
      Value<String?> extension,
      Value<String?> aggravatingFactors,
      Value<String?> amelioratingFactors,
      Value<String?> concomitants,
      Value<String?> causation,
      Value<String?> periodicity,
      Value<int> severity,
      Value<String> status,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ComplaintsTableUpdateCompanionBuilder =
    ComplaintsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String?> visitId,
      Value<int> complaintIndex,
      Value<String> complaintName,
      Value<String?> location,
      Value<String?> side,
      Value<String?> onset,
      Value<String?> duration,
      Value<String?> sensation,
      Value<String?> extension,
      Value<String?> aggravatingFactors,
      Value<String?> amelioratingFactors,
      Value<String?> concomitants,
      Value<String?> causation,
      Value<String?> periodicity,
      Value<int> severity,
      Value<String> status,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ComplaintsTableReferences
    extends BaseReferences<_$AppDatabase, $ComplaintsTable, Complaint> {
  $$ComplaintsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias(
        $_aliasNameGenerator(db.complaints.patientId, db.patients.id),
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

  static $VisitsTable _visitIdTable(_$AppDatabase db) => db.visits.createAlias(
    $_aliasNameGenerator(db.complaints.visitId, db.visits.id),
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

class $$ComplaintsTableFilterComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableFilterComposer({
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

  ColumnFilters<int> get complaintIndex => $composableBuilder(
    column: $table.complaintIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get complaintName => $composableBuilder(
    column: $table.complaintName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onset => $composableBuilder(
    column: $table.onset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sensation => $composableBuilder(
    column: $table.sensation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggravatingFactors => $composableBuilder(
    column: $table.aggravatingFactors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amelioratingFactors => $composableBuilder(
    column: $table.amelioratingFactors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concomitants => $composableBuilder(
    column: $table.concomitants,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get causation => $composableBuilder(
    column: $table.causation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodicity => $composableBuilder(
    column: $table.periodicity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

class $$ComplaintsTableOrderingComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableOrderingComposer({
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

  ColumnOrderings<int> get complaintIndex => $composableBuilder(
    column: $table.complaintIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get complaintName => $composableBuilder(
    column: $table.complaintName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onset => $composableBuilder(
    column: $table.onset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sensation => $composableBuilder(
    column: $table.sensation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggravatingFactors => $composableBuilder(
    column: $table.aggravatingFactors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amelioratingFactors => $composableBuilder(
    column: $table.amelioratingFactors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concomitants => $composableBuilder(
    column: $table.concomitants,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get causation => $composableBuilder(
    column: $table.causation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodicity => $composableBuilder(
    column: $table.periodicity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

class $$ComplaintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get complaintIndex => $composableBuilder(
    column: $table.complaintIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get complaintName => $composableBuilder(
    column: $table.complaintName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get onset =>
      $composableBuilder(column: $table.onset, builder: (column) => column);

  GeneratedColumn<String> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get sensation =>
      $composableBuilder(column: $table.sensation, builder: (column) => column);

  GeneratedColumn<String> get extension =>
      $composableBuilder(column: $table.extension, builder: (column) => column);

  GeneratedColumn<String> get aggravatingFactors => $composableBuilder(
    column: $table.aggravatingFactors,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amelioratingFactors => $composableBuilder(
    column: $table.amelioratingFactors,
    builder: (column) => column,
  );

  GeneratedColumn<String> get concomitants => $composableBuilder(
    column: $table.concomitants,
    builder: (column) => column,
  );

  GeneratedColumn<String> get causation =>
      $composableBuilder(column: $table.causation, builder: (column) => column);

  GeneratedColumn<String> get periodicity => $composableBuilder(
    column: $table.periodicity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

class $$ComplaintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComplaintsTable,
          Complaint,
          $$ComplaintsTableFilterComposer,
          $$ComplaintsTableOrderingComposer,
          $$ComplaintsTableAnnotationComposer,
          $$ComplaintsTableCreateCompanionBuilder,
          $$ComplaintsTableUpdateCompanionBuilder,
          (Complaint, $$ComplaintsTableReferences),
          Complaint,
          PrefetchHooks Function({bool patientId, bool visitId})
        > {
  $$ComplaintsTableTableManager(_$AppDatabase db, $ComplaintsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ComplaintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ComplaintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ComplaintsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String?> visitId = const Value.absent(),
                Value<int> complaintIndex = const Value.absent(),
                Value<String> complaintName = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> side = const Value.absent(),
                Value<String?> onset = const Value.absent(),
                Value<String?> duration = const Value.absent(),
                Value<String?> sensation = const Value.absent(),
                Value<String?> extension = const Value.absent(),
                Value<String?> aggravatingFactors = const Value.absent(),
                Value<String?> amelioratingFactors = const Value.absent(),
                Value<String?> concomitants = const Value.absent(),
                Value<String?> causation = const Value.absent(),
                Value<String?> periodicity = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComplaintsCompanion(
                id: id,
                patientId: patientId,
                visitId: visitId,
                complaintIndex: complaintIndex,
                complaintName: complaintName,
                location: location,
                side: side,
                onset: onset,
                duration: duration,
                sensation: sensation,
                extension: extension,
                aggravatingFactors: aggravatingFactors,
                amelioratingFactors: amelioratingFactors,
                concomitants: concomitants,
                causation: causation,
                periodicity: periodicity,
                severity: severity,
                status: status,
                notes: notes,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                Value<String?> visitId = const Value.absent(),
                Value<int> complaintIndex = const Value.absent(),
                required String complaintName,
                Value<String?> location = const Value.absent(),
                Value<String?> side = const Value.absent(),
                Value<String?> onset = const Value.absent(),
                Value<String?> duration = const Value.absent(),
                Value<String?> sensation = const Value.absent(),
                Value<String?> extension = const Value.absent(),
                Value<String?> aggravatingFactors = const Value.absent(),
                Value<String?> amelioratingFactors = const Value.absent(),
                Value<String?> concomitants = const Value.absent(),
                Value<String?> causation = const Value.absent(),
                Value<String?> periodicity = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComplaintsCompanion.insert(
                id: id,
                patientId: patientId,
                visitId: visitId,
                complaintIndex: complaintIndex,
                complaintName: complaintName,
                location: location,
                side: side,
                onset: onset,
                duration: duration,
                sensation: sensation,
                extension: extension,
                aggravatingFactors: aggravatingFactors,
                amelioratingFactors: amelioratingFactors,
                concomitants: concomitants,
                causation: causation,
                periodicity: periodicity,
                severity: severity,
                status: status,
                notes: notes,
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
                          $$ComplaintsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({patientId = false, visitId = false}) {
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
                            referencedTable: $$ComplaintsTableReferences
                                ._patientIdTable(db),
                            referencedColumn:
                                $$ComplaintsTableReferences
                                    ._patientIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (visitId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.visitId,
                            referencedTable: $$ComplaintsTableReferences
                                ._visitIdTable(db),
                            referencedColumn:
                                $$ComplaintsTableReferences
                                    ._visitIdTable(db)
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

typedef $$ComplaintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComplaintsTable,
      Complaint,
      $$ComplaintsTableFilterComposer,
      $$ComplaintsTableOrderingComposer,
      $$ComplaintsTableAnnotationComposer,
      $$ComplaintsTableCreateCompanionBuilder,
      $$ComplaintsTableUpdateCompanionBuilder,
      (Complaint, $$ComplaintsTableReferences),
      Complaint,
      PrefetchHooks Function({bool patientId, bool visitId})
    >;
typedef $$PrescriptionsTableCreateCompanionBuilder =
    PrescriptionsCompanion Function({
      required String id,
      required String patientId,
      Value<String?> visitId,
      Value<DateTime> prescriptionDate,
      Value<int> remedyIndex,
      required String remedyName,
      required String potency,
      Value<String?> doseCount,
      Value<String?> frequency,
      Value<String?> vehicle,
      Value<String?> durationDays,
      Value<String?> instructions,
      Value<String?> dietaryAdvice,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PrescriptionsTableUpdateCompanionBuilder =
    PrescriptionsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String?> visitId,
      Value<DateTime> prescriptionDate,
      Value<int> remedyIndex,
      Value<String> remedyName,
      Value<String> potency,
      Value<String?> doseCount,
      Value<String?> frequency,
      Value<String?> vehicle,
      Value<String?> durationDays,
      Value<String?> instructions,
      Value<String?> dietaryAdvice,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PrescriptionsTableReferences
    extends BaseReferences<_$AppDatabase, $PrescriptionsTable, Prescription> {
  $$PrescriptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias(
        $_aliasNameGenerator(db.prescriptions.patientId, db.patients.id),
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

  static $VisitsTable _visitIdTable(_$AppDatabase db) => db.visits.createAlias(
    $_aliasNameGenerator(db.prescriptions.visitId, db.visits.id),
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

class $$PrescriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableFilterComposer({
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

  ColumnFilters<DateTime> get prescriptionDate => $composableBuilder(
    column: $table.prescriptionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remedyIndex => $composableBuilder(
    column: $table.remedyIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remedyName => $composableBuilder(
    column: $table.remedyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get potency => $composableBuilder(
    column: $table.potency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseCount => $composableBuilder(
    column: $table.doseCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicle => $composableBuilder(
    column: $table.vehicle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dietaryAdvice => $composableBuilder(
    column: $table.dietaryAdvice,
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

class $$PrescriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get prescriptionDate => $composableBuilder(
    column: $table.prescriptionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remedyIndex => $composableBuilder(
    column: $table.remedyIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remedyName => $composableBuilder(
    column: $table.remedyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get potency => $composableBuilder(
    column: $table.potency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseCount => $composableBuilder(
    column: $table.doseCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicle => $composableBuilder(
    column: $table.vehicle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dietaryAdvice => $composableBuilder(
    column: $table.dietaryAdvice,
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

class $$PrescriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get prescriptionDate => $composableBuilder(
    column: $table.prescriptionDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remedyIndex => $composableBuilder(
    column: $table.remedyIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remedyName => $composableBuilder(
    column: $table.remedyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get potency =>
      $composableBuilder(column: $table.potency, builder: (column) => column);

  GeneratedColumn<String> get doseCount =>
      $composableBuilder(column: $table.doseCount, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get vehicle =>
      $composableBuilder(column: $table.vehicle, builder: (column) => column);

  GeneratedColumn<String> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dietaryAdvice => $composableBuilder(
    column: $table.dietaryAdvice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

class $$PrescriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrescriptionsTable,
          Prescription,
          $$PrescriptionsTableFilterComposer,
          $$PrescriptionsTableOrderingComposer,
          $$PrescriptionsTableAnnotationComposer,
          $$PrescriptionsTableCreateCompanionBuilder,
          $$PrescriptionsTableUpdateCompanionBuilder,
          (Prescription, $$PrescriptionsTableReferences),
          Prescription,
          PrefetchHooks Function({bool patientId, bool visitId})
        > {
  $$PrescriptionsTableTableManager(_$AppDatabase db, $PrescriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PrescriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$PrescriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PrescriptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String?> visitId = const Value.absent(),
                Value<DateTime> prescriptionDate = const Value.absent(),
                Value<int> remedyIndex = const Value.absent(),
                Value<String> remedyName = const Value.absent(),
                Value<String> potency = const Value.absent(),
                Value<String?> doseCount = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String?> vehicle = const Value.absent(),
                Value<String?> durationDays = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<String?> dietaryAdvice = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrescriptionsCompanion(
                id: id,
                patientId: patientId,
                visitId: visitId,
                prescriptionDate: prescriptionDate,
                remedyIndex: remedyIndex,
                remedyName: remedyName,
                potency: potency,
                doseCount: doseCount,
                frequency: frequency,
                vehicle: vehicle,
                durationDays: durationDays,
                instructions: instructions,
                dietaryAdvice: dietaryAdvice,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                Value<String?> visitId = const Value.absent(),
                Value<DateTime> prescriptionDate = const Value.absent(),
                Value<int> remedyIndex = const Value.absent(),
                required String remedyName,
                required String potency,
                Value<String?> doseCount = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String?> vehicle = const Value.absent(),
                Value<String?> durationDays = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<String?> dietaryAdvice = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrescriptionsCompanion.insert(
                id: id,
                patientId: patientId,
                visitId: visitId,
                prescriptionDate: prescriptionDate,
                remedyIndex: remedyIndex,
                remedyName: remedyName,
                potency: potency,
                doseCount: doseCount,
                frequency: frequency,
                vehicle: vehicle,
                durationDays: durationDays,
                instructions: instructions,
                dietaryAdvice: dietaryAdvice,
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
                          $$PrescriptionsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({patientId = false, visitId = false}) {
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
                            referencedTable: $$PrescriptionsTableReferences
                                ._patientIdTable(db),
                            referencedColumn:
                                $$PrescriptionsTableReferences
                                    ._patientIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (visitId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.visitId,
                            referencedTable: $$PrescriptionsTableReferences
                                ._visitIdTable(db),
                            referencedColumn:
                                $$PrescriptionsTableReferences
                                    ._visitIdTable(db)
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

typedef $$PrescriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrescriptionsTable,
      Prescription,
      $$PrescriptionsTableFilterComposer,
      $$PrescriptionsTableOrderingComposer,
      $$PrescriptionsTableAnnotationComposer,
      $$PrescriptionsTableCreateCompanionBuilder,
      $$PrescriptionsTableUpdateCompanionBuilder,
      (Prescription, $$PrescriptionsTableReferences),
      Prescription,
      PrefetchHooks Function({bool patientId, bool visitId})
    >;
typedef $$InvestigationsTableCreateCompanionBuilder =
    InvestigationsCompanion Function({
      required String id,
      required String patientId,
      Value<String?> visitId,
      Value<DateTime> testDate,
      Value<String> testCategory,
      required String testName,
      Value<double?> numericValue,
      Value<String?> stringValue,
      Value<String?> unit,
      Value<double?> refRangeMin,
      Value<double?> refRangeMax,
      Value<String> flag,
      Value<String?> labName,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$InvestigationsTableUpdateCompanionBuilder =
    InvestigationsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String?> visitId,
      Value<DateTime> testDate,
      Value<String> testCategory,
      Value<String> testName,
      Value<double?> numericValue,
      Value<String?> stringValue,
      Value<String?> unit,
      Value<double?> refRangeMin,
      Value<double?> refRangeMax,
      Value<String> flag,
      Value<String?> labName,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$InvestigationsTableReferences
    extends BaseReferences<_$AppDatabase, $InvestigationsTable, Investigation> {
  $$InvestigationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias(
        $_aliasNameGenerator(db.investigations.patientId, db.patients.id),
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

  static $VisitsTable _visitIdTable(_$AppDatabase db) => db.visits.createAlias(
    $_aliasNameGenerator(db.investigations.visitId, db.visits.id),
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

class $$InvestigationsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestigationsTable> {
  $$InvestigationsTableFilterComposer({
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

  ColumnFilters<DateTime> get testDate => $composableBuilder(
    column: $table.testDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testCategory => $composableBuilder(
    column: $table.testCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testName => $composableBuilder(
    column: $table.testName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get numericValue => $composableBuilder(
    column: $table.numericValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stringValue => $composableBuilder(
    column: $table.stringValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get refRangeMin => $composableBuilder(
    column: $table.refRangeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get refRangeMax => $composableBuilder(
    column: $table.refRangeMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flag => $composableBuilder(
    column: $table.flag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labName => $composableBuilder(
    column: $table.labName,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

class $$InvestigationsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestigationsTable> {
  $$InvestigationsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get testDate => $composableBuilder(
    column: $table.testDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testCategory => $composableBuilder(
    column: $table.testCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testName => $composableBuilder(
    column: $table.testName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get numericValue => $composableBuilder(
    column: $table.numericValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stringValue => $composableBuilder(
    column: $table.stringValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get refRangeMin => $composableBuilder(
    column: $table.refRangeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get refRangeMax => $composableBuilder(
    column: $table.refRangeMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flag => $composableBuilder(
    column: $table.flag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labName => $composableBuilder(
    column: $table.labName,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

class $$InvestigationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestigationsTable> {
  $$InvestigationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get testDate =>
      $composableBuilder(column: $table.testDate, builder: (column) => column);

  GeneratedColumn<String> get testCategory => $composableBuilder(
    column: $table.testCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get testName =>
      $composableBuilder(column: $table.testName, builder: (column) => column);

  GeneratedColumn<double> get numericValue => $composableBuilder(
    column: $table.numericValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stringValue => $composableBuilder(
    column: $table.stringValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get refRangeMin => $composableBuilder(
    column: $table.refRangeMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get refRangeMax => $composableBuilder(
    column: $table.refRangeMax,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flag =>
      $composableBuilder(column: $table.flag, builder: (column) => column);

  GeneratedColumn<String> get labName =>
      $composableBuilder(column: $table.labName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

class $$InvestigationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestigationsTable,
          Investigation,
          $$InvestigationsTableFilterComposer,
          $$InvestigationsTableOrderingComposer,
          $$InvestigationsTableAnnotationComposer,
          $$InvestigationsTableCreateCompanionBuilder,
          $$InvestigationsTableUpdateCompanionBuilder,
          (Investigation, $$InvestigationsTableReferences),
          Investigation,
          PrefetchHooks Function({bool patientId, bool visitId})
        > {
  $$InvestigationsTableTableManager(
    _$AppDatabase db,
    $InvestigationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$InvestigationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$InvestigationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$InvestigationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String?> visitId = const Value.absent(),
                Value<DateTime> testDate = const Value.absent(),
                Value<String> testCategory = const Value.absent(),
                Value<String> testName = const Value.absent(),
                Value<double?> numericValue = const Value.absent(),
                Value<String?> stringValue = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> refRangeMin = const Value.absent(),
                Value<double?> refRangeMax = const Value.absent(),
                Value<String> flag = const Value.absent(),
                Value<String?> labName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestigationsCompanion(
                id: id,
                patientId: patientId,
                visitId: visitId,
                testDate: testDate,
                testCategory: testCategory,
                testName: testName,
                numericValue: numericValue,
                stringValue: stringValue,
                unit: unit,
                refRangeMin: refRangeMin,
                refRangeMax: refRangeMax,
                flag: flag,
                labName: labName,
                notes: notes,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                Value<String?> visitId = const Value.absent(),
                Value<DateTime> testDate = const Value.absent(),
                Value<String> testCategory = const Value.absent(),
                required String testName,
                Value<double?> numericValue = const Value.absent(),
                Value<String?> stringValue = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> refRangeMin = const Value.absent(),
                Value<double?> refRangeMax = const Value.absent(),
                Value<String> flag = const Value.absent(),
                Value<String?> labName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestigationsCompanion.insert(
                id: id,
                patientId: patientId,
                visitId: visitId,
                testDate: testDate,
                testCategory: testCategory,
                testName: testName,
                numericValue: numericValue,
                stringValue: stringValue,
                unit: unit,
                refRangeMin: refRangeMin,
                refRangeMax: refRangeMax,
                flag: flag,
                labName: labName,
                notes: notes,
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
                          $$InvestigationsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({patientId = false, visitId = false}) {
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
                            referencedTable: $$InvestigationsTableReferences
                                ._patientIdTable(db),
                            referencedColumn:
                                $$InvestigationsTableReferences
                                    ._patientIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (visitId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.visitId,
                            referencedTable: $$InvestigationsTableReferences
                                ._visitIdTable(db),
                            referencedColumn:
                                $$InvestigationsTableReferences
                                    ._visitIdTable(db)
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

typedef $$InvestigationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestigationsTable,
      Investigation,
      $$InvestigationsTableFilterComposer,
      $$InvestigationsTableOrderingComposer,
      $$InvestigationsTableAnnotationComposer,
      $$InvestigationsTableCreateCompanionBuilder,
      $$InvestigationsTableUpdateCompanionBuilder,
      (Investigation, $$InvestigationsTableReferences),
      Investigation,
      PrefetchHooks Function({bool patientId, bool visitId})
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
  $$CampsTableTableManager get camps =>
      $$CampsTableTableManager(_db, _db.camps);
  $$PatientCaseRecordsTableTableManager get patientCaseRecords =>
      $$PatientCaseRecordsTableTableManager(_db, _db.patientCaseRecords);
  $$ComplaintsTableTableManager get complaints =>
      $$ComplaintsTableTableManager(_db, _db.complaints);
  $$PrescriptionsTableTableManager get prescriptions =>
      $$PrescriptionsTableTableManager(_db, _db.prescriptions);
  $$InvestigationsTableTableManager get investigations =>
      $$InvestigationsTableTableManager(_db, _db.investigations);
}
