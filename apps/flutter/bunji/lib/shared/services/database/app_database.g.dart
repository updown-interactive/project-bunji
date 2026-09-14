// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dobMeta = const VerificationMeta('dob');
  @override
  late final GeneratedColumn<DateTime> dob = GeneratedColumn<DateTime>(
    'dob',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
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
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    dob,
    email,
    phone,
    gender,
    avatarUrl,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
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
    if (data.containsKey('dob')) {
      context.handle(
        _dobMeta,
        dob.isAcceptableOrUnknown(data['dob']!, _dobMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
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
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dob: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dob'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  /// Unique identifier (e.g. Supabase Auth UID or local UUID).
  final String id;

  /// User's full name.
  final String name;

  /// Date of birth.
  final DateTime? dob;

  /// Email address.
  final String? email;

  /// Phone number.
  final String? phone;

  /// Gender (e.g. Male, Female, Non-binary, Other, Prefer not to say).
  final String? gender;

  /// Avatar URL or local image path if any.
  final String? avatarUrl;

  /// Timestamp of creation.
  final DateTime createdAt;

  /// Timestamp of last update.
  final DateTime? updatedAt;
  const UserProfile({
    required this.id,
    required this.name,
    this.dob,
    this.email,
    this.phone,
    this.gender,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || dob != null) {
      map['dob'] = Variable<DateTime>(dob);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      dob: dob == null && nullToAbsent ? const Value.absent() : Value(dob),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dob: serializer.fromJson<DateTime?>(json['dob']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      gender: serializer.fromJson<String?>(json['gender']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'dob': serializer.toJson<DateTime?>(dob),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'gender': serializer.toJson<String?>(gender),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    Value<DateTime?> dob = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    dob: dob.present ? dob.value : this.dob,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    gender: gender.present ? gender.value : this.gender,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dob: data.dob.present ? data.dob.value : this.dob,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      gender: data.gender.present ? data.gender.value : this.gender,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dob: $dob, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('gender: $gender, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    dob,
    email,
    phone,
    gender,
    avatarUrl,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.dob == this.dob &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.gender == this.gender &&
          other.avatarUrl == this.avatarUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime?> dob;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> gender;
  final Value<String?> avatarUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dob = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.gender = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String name,
    this.dob = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.gender = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? dob,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? gender,
    Expression<String>? avatarUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dob != null) 'dob': dob,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime?>? dob,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? gender,
    Value<String?>? avatarUrl,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dob.present) {
      map['dob'] = Variable<DateTime>(dob.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
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
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dob: $dob, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('gender: $gender, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserAiModelsTable extends UserAiModels
    with TableInfo<$UserAiModelsTable, UserAiModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAiModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1.0.0'),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<BigInt> fileSizeBytes = GeneratedColumn<BigInt>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isVerifiedMeta = const VerificationMeta(
    'isVerified',
  );
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
    'is_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    tier,
    version,
    filePath,
    fileSizeBytes,
    sha256,
    isVerified,
    isActive,
    installedAt,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_ai_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserAiModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('is_verified')) {
      context.handle(
        _isVerifiedMeta,
        isVerified.isAcceptableOrUnknown(data['is_verified']!, _isVerifiedMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserAiModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAiModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      isVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_verified'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
    );
  }

  @override
  $UserAiModelsTable createAlias(String alias) {
    return $UserAiModelsTable(attachedDatabase, alias);
  }
}

class UserAiModel extends DataClass implements Insertable<UserAiModel> {
  /// Unique identifier of the model (e.g., 'qwen3_0_6b', 'mobilellm_r1_5_950m', 'qwen3_1_7b').
  final String id;

  /// Human-readable model display name (e.g. 'Qwen3 0.6B').
  final String displayName;

  /// Semantic model tier: 'fast', 'reasoning', 'quality'.
  final String tier;

  /// Model revision or version string.
  final String version;

  /// Local file path on device storage where the model artifact is saved.
  final String filePath;

  /// Size of the model artifact on disk in bytes.
  final BigInt fileSizeBytes;

  /// SHA-256 integrity checksum.
  final String sha256;

  /// Whether the model passed SHA-256 verification and local health check.
  final bool isVerified;

  /// Whether this model is currently the active model used for inference.
  final bool isActive;

  /// Timestamp when model download & verification completed.
  final DateTime installedAt;

  /// Timestamp when the user last switched to or used this model.
  final DateTime? lastUsedAt;
  const UserAiModel({
    required this.id,
    required this.displayName,
    required this.tier,
    required this.version,
    required this.filePath,
    required this.fileSizeBytes,
    required this.sha256,
    required this.isVerified,
    required this.isActive,
    required this.installedAt,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['tier'] = Variable<String>(tier);
    map['version'] = Variable<String>(version);
    map['file_path'] = Variable<String>(filePath);
    map['file_size_bytes'] = Variable<BigInt>(fileSizeBytes);
    map['sha256'] = Variable<String>(sha256);
    map['is_verified'] = Variable<bool>(isVerified);
    map['is_active'] = Variable<bool>(isActive);
    map['installed_at'] = Variable<DateTime>(installedAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  UserAiModelsCompanion toCompanion(bool nullToAbsent) {
    return UserAiModelsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      tier: Value(tier),
      version: Value(version),
      filePath: Value(filePath),
      fileSizeBytes: Value(fileSizeBytes),
      sha256: Value(sha256),
      isVerified: Value(isVerified),
      isActive: Value(isActive),
      installedAt: Value(installedAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory UserAiModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAiModel(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      tier: serializer.fromJson<String>(json['tier']),
      version: serializer.fromJson<String>(json['version']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileSizeBytes: serializer.fromJson<BigInt>(json['fileSizeBytes']),
      sha256: serializer.fromJson<String>(json['sha256']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'tier': serializer.toJson<String>(tier),
      'version': serializer.toJson<String>(version),
      'filePath': serializer.toJson<String>(filePath),
      'fileSizeBytes': serializer.toJson<BigInt>(fileSizeBytes),
      'sha256': serializer.toJson<String>(sha256),
      'isVerified': serializer.toJson<bool>(isVerified),
      'isActive': serializer.toJson<bool>(isActive),
      'installedAt': serializer.toJson<DateTime>(installedAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  UserAiModel copyWith({
    String? id,
    String? displayName,
    String? tier,
    String? version,
    String? filePath,
    BigInt? fileSizeBytes,
    String? sha256,
    bool? isVerified,
    bool? isActive,
    DateTime? installedAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => UserAiModel(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    tier: tier ?? this.tier,
    version: version ?? this.version,
    filePath: filePath ?? this.filePath,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    sha256: sha256 ?? this.sha256,
    isVerified: isVerified ?? this.isVerified,
    isActive: isActive ?? this.isActive,
    installedAt: installedAt ?? this.installedAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  UserAiModel copyWithCompanion(UserAiModelsCompanion data) {
    return UserAiModel(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      tier: data.tier.present ? data.tier.value : this.tier,
      version: data.version.present ? data.version.value : this.version,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      isVerified: data.isVerified.present
          ? data.isVerified.value
          : this.isVerified,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAiModel(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('tier: $tier, ')
          ..write('version: $version, ')
          ..write('filePath: $filePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('isVerified: $isVerified, ')
          ..write('isActive: $isActive, ')
          ..write('installedAt: $installedAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    tier,
    version,
    filePath,
    fileSizeBytes,
    sha256,
    isVerified,
    isActive,
    installedAt,
    lastUsedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAiModel &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.tier == this.tier &&
          other.version == this.version &&
          other.filePath == this.filePath &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.sha256 == this.sha256 &&
          other.isVerified == this.isVerified &&
          other.isActive == this.isActive &&
          other.installedAt == this.installedAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class UserAiModelsCompanion extends UpdateCompanion<UserAiModel> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> tier;
  final Value<String> version;
  final Value<String> filePath;
  final Value<BigInt> fileSizeBytes;
  final Value<String> sha256;
  final Value<bool> isVerified;
  final Value<bool> isActive;
  final Value<DateTime> installedAt;
  final Value<DateTime?> lastUsedAt;
  final Value<int> rowid;
  const UserAiModelsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.tier = const Value.absent(),
    this.version = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.isActive = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserAiModelsCompanion.insert({
    required String id,
    required String displayName,
    required String tier,
    this.version = const Value.absent(),
    required String filePath,
    required BigInt fileSizeBytes,
    required String sha256,
    this.isVerified = const Value.absent(),
    this.isActive = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       tier = Value(tier),
       filePath = Value(filePath),
       fileSizeBytes = Value(fileSizeBytes),
       sha256 = Value(sha256);
  static Insertable<UserAiModel> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? tier,
    Expression<String>? version,
    Expression<String>? filePath,
    Expression<BigInt>? fileSizeBytes,
    Expression<String>? sha256,
    Expression<bool>? isVerified,
    Expression<bool>? isActive,
    Expression<DateTime>? installedAt,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (tier != null) 'tier': tier,
      if (version != null) 'version': version,
      if (filePath != null) 'file_path': filePath,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (sha256 != null) 'sha256': sha256,
      if (isVerified != null) 'is_verified': isVerified,
      if (isActive != null) 'is_active': isActive,
      if (installedAt != null) 'installed_at': installedAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserAiModelsCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? tier,
    Value<String>? version,
    Value<String>? filePath,
    Value<BigInt>? fileSizeBytes,
    Value<String>? sha256,
    Value<bool>? isVerified,
    Value<bool>? isActive,
    Value<DateTime>? installedAt,
    Value<DateTime?>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return UserAiModelsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      tier: tier ?? this.tier,
      version: version ?? this.version,
      filePath: filePath ?? this.filePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      sha256: sha256 ?? this.sha256,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      installedAt: installedAt ?? this.installedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<BigInt>(fileSizeBytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAiModelsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('tier: $tier, ')
          ..write('version: $version, ')
          ..write('filePath: $filePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('isVerified: $isVerified, ')
          ..write('isActive: $isActive, ')
          ..write('installedAt: $installedAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _messageDensityMeta = const VerificationMeta(
    'messageDensity',
  );
  @override
  late final GeneratedColumn<String> messageDensity = GeneratedColumn<String>(
    'message_density',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('comfortable'),
  );
  static const VerificationMeta _activeModelIdMeta = const VerificationMeta(
    'activeModelId',
  );
  @override
  late final GeneratedColumn<String> activeModelId = GeneratedColumn<String>(
    'active_model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('qwen3_0_6b'),
  );
  static const VerificationMeta _responseStyleMeta = const VerificationMeta(
    'responseStyle',
  );
  @override
  late final GeneratedColumn<String> responseStyle = GeneratedColumn<String>(
    'response_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Balanced'),
  );
  static const VerificationMeta _reasoningModeMeta = const VerificationMeta(
    'reasoningMode',
  );
  @override
  late final GeneratedColumn<bool> reasoningMode = GeneratedColumn<bool>(
    'reasoning_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reasoning_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _streamingTokensMeta = const VerificationMeta(
    'streamingTokens',
  );
  @override
  late final GeneratedColumn<bool> streamingTokens = GeneratedColumn<bool>(
    'streaming_tokens',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("streaming_tokens" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _localAiOnlyMeta = const VerificationMeta(
    'localAiOnly',
  );
  @override
  late final GeneratedColumn<bool> localAiOnly = GeneratedColumn<bool>(
    'local_ai_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("local_ai_only" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _allowInternetForDownloadsMeta =
      const VerificationMeta('allowInternetForDownloads');
  @override
  late final GeneratedColumn<bool> allowInternetForDownloads =
      GeneratedColumn<bool>(
        'allow_internet_for_downloads',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_internet_for_downloads" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _sendDiagnosticsMeta = const VerificationMeta(
    'sendDiagnostics',
  );
  @override
  late final GeneratedColumn<bool> sendDiagnostics = GeneratedColumn<bool>(
    'send_diagnostics',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("send_diagnostics" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _saveChatHistoryMeta = const VerificationMeta(
    'saveChatHistory',
  );
  @override
  late final GeneratedColumn<bool> saveChatHistory = GeneratedColumn<bool>(
    'save_chat_history',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("save_chat_history" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _autoDeleteChatsMeta = const VerificationMeta(
    'autoDeleteChats',
  );
  @override
  late final GeneratedColumn<String> autoDeleteChats = GeneratedColumn<String>(
    'auto_delete_chats',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Never'),
  );
  static const VerificationMeta _bunjiMemoryMeta = const VerificationMeta(
    'bunjiMemory',
  );
  @override
  late final GeneratedColumn<bool> bunjiMemory = GeneratedColumn<bool>(
    'bunji_memory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bunji_memory" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _enterToSendMeta = const VerificationMeta(
    'enterToSend',
  );
  @override
  late final GeneratedColumn<bool> enterToSend = GeneratedColumn<bool>(
    'enter_to_send',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enter_to_send" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showAiIndicatorMeta = const VerificationMeta(
    'showAiIndicator',
  );
  @override
  late final GeneratedColumn<bool> showAiIndicator = GeneratedColumn<bool>(
    'show_ai_indicator',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_ai_indicator" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _autoScrollMeta = const VerificationMeta(
    'autoScroll',
  );
  @override
  late final GeneratedColumn<bool> autoScroll = GeneratedColumn<bool>(
    'auto_scroll',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_scroll" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _codeSyntaxHighlightingMeta =
      const VerificationMeta('codeSyntaxHighlighting');
  @override
  late final GeneratedColumn<bool> codeSyntaxHighlighting =
      GeneratedColumn<bool>(
        'code_syntax_highlighting',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("code_syntax_highlighting" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _markdownRenderingMeta = const VerificationMeta(
    'markdownRendering',
  );
  @override
  late final GeneratedColumn<bool> markdownRendering = GeneratedColumn<bool>(
    'markdown_rendering',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("markdown_rendering" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _autoNameConversationsMeta =
      const VerificationMeta('autoNameConversations');
  @override
  late final GeneratedColumn<bool> autoNameConversations =
      GeneratedColumn<bool>(
        'auto_name_conversations',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_name_conversations" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _reduceMotionMeta = const VerificationMeta(
    'reduceMotion',
  );
  @override
  late final GeneratedColumn<bool> reduceMotion = GeneratedColumn<bool>(
    'reduce_motion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reduce_motion" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enableNotificationsMeta =
      const VerificationMeta('enableNotifications');
  @override
  late final GeneratedColumn<bool> enableNotifications = GeneratedColumn<bool>(
    'enable_notifications',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_notifications" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyTaskCompletionMeta =
      const VerificationMeta('notifyTaskCompletion');
  @override
  late final GeneratedColumn<bool> notifyTaskCompletion = GeneratedColumn<bool>(
    'notify_task_completion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_task_completion" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyDownloadsMeta = const VerificationMeta(
    'notifyDownloads',
  );
  @override
  late final GeneratedColumn<bool> notifyDownloads = GeneratedColumn<bool>(
    'notify_downloads',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_downloads" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyRemindersMeta = const VerificationMeta(
    'notifyReminders',
  );
  @override
  late final GeneratedColumn<bool> notifyReminders = GeneratedColumn<bool>(
    'notify_reminders',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_reminders" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _launchBehaviorMeta = const VerificationMeta(
    'launchBehavior',
  );
  @override
  late final GeneratedColumn<String> launchBehavior = GeneratedColumn<String>(
    'launch_behavior',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Open Home'),
  );
  static const VerificationMeta _hapticFeedbackMeta = const VerificationMeta(
    'hapticFeedback',
  );
  @override
  late final GeneratedColumn<bool> hapticFeedback = GeneratedColumn<bool>(
    'haptic_feedback',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("haptic_feedback" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _soundEffectsMeta = const VerificationMeta(
    'soundEffects',
  );
  @override
  late final GeneratedColumn<bool> soundEffects = GeneratedColumn<bool>(
    'sound_effects',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_effects" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _confirmBeforeDeletingMeta =
      const VerificationMeta('confirmBeforeDeleting');
  @override
  late final GeneratedColumn<bool> confirmBeforeDeleting =
      GeneratedColumn<bool>(
        'confirm_before_deleting',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("confirm_before_deleting" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _appLanguageMeta = const VerificationMeta(
    'appLanguage',
  );
  @override
  late final GeneratedColumn<String> appLanguage = GeneratedColumn<String>(
    'app_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _aiLanguageMeta = const VerificationMeta(
    'aiLanguage',
  );
  @override
  late final GeneratedColumn<String> aiLanguage = GeneratedColumn<String>(
    'ai_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  static const VerificationMeta _developerModeMeta = const VerificationMeta(
    'developerMode',
  );
  @override
  late final GeneratedColumn<bool> developerMode = GeneratedColumn<bool>(
    'developer_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("developer_mode" IN (0, 1))',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    messageDensity,
    activeModelId,
    responseStyle,
    reasoningMode,
    streamingTokens,
    localAiOnly,
    allowInternetForDownloads,
    sendDiagnostics,
    saveChatHistory,
    autoDeleteChats,
    bunjiMemory,
    enterToSend,
    showAiIndicator,
    autoScroll,
    codeSyntaxHighlighting,
    markdownRendering,
    autoNameConversations,
    reduceMotion,
    enableNotifications,
    notifyTaskCompletion,
    notifyDownloads,
    notifyReminders,
    launchBehavior,
    hapticFeedback,
    soundEffects,
    confirmBeforeDeleting,
    appLanguage,
    aiLanguage,
    developerMode,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('message_density')) {
      context.handle(
        _messageDensityMeta,
        messageDensity.isAcceptableOrUnknown(
          data['message_density']!,
          _messageDensityMeta,
        ),
      );
    }
    if (data.containsKey('active_model_id')) {
      context.handle(
        _activeModelIdMeta,
        activeModelId.isAcceptableOrUnknown(
          data['active_model_id']!,
          _activeModelIdMeta,
        ),
      );
    }
    if (data.containsKey('response_style')) {
      context.handle(
        _responseStyleMeta,
        responseStyle.isAcceptableOrUnknown(
          data['response_style']!,
          _responseStyleMeta,
        ),
      );
    }
    if (data.containsKey('reasoning_mode')) {
      context.handle(
        _reasoningModeMeta,
        reasoningMode.isAcceptableOrUnknown(
          data['reasoning_mode']!,
          _reasoningModeMeta,
        ),
      );
    }
    if (data.containsKey('streaming_tokens')) {
      context.handle(
        _streamingTokensMeta,
        streamingTokens.isAcceptableOrUnknown(
          data['streaming_tokens']!,
          _streamingTokensMeta,
        ),
      );
    }
    if (data.containsKey('local_ai_only')) {
      context.handle(
        _localAiOnlyMeta,
        localAiOnly.isAcceptableOrUnknown(
          data['local_ai_only']!,
          _localAiOnlyMeta,
        ),
      );
    }
    if (data.containsKey('allow_internet_for_downloads')) {
      context.handle(
        _allowInternetForDownloadsMeta,
        allowInternetForDownloads.isAcceptableOrUnknown(
          data['allow_internet_for_downloads']!,
          _allowInternetForDownloadsMeta,
        ),
      );
    }
    if (data.containsKey('send_diagnostics')) {
      context.handle(
        _sendDiagnosticsMeta,
        sendDiagnostics.isAcceptableOrUnknown(
          data['send_diagnostics']!,
          _sendDiagnosticsMeta,
        ),
      );
    }
    if (data.containsKey('save_chat_history')) {
      context.handle(
        _saveChatHistoryMeta,
        saveChatHistory.isAcceptableOrUnknown(
          data['save_chat_history']!,
          _saveChatHistoryMeta,
        ),
      );
    }
    if (data.containsKey('auto_delete_chats')) {
      context.handle(
        _autoDeleteChatsMeta,
        autoDeleteChats.isAcceptableOrUnknown(
          data['auto_delete_chats']!,
          _autoDeleteChatsMeta,
        ),
      );
    }
    if (data.containsKey('bunji_memory')) {
      context.handle(
        _bunjiMemoryMeta,
        bunjiMemory.isAcceptableOrUnknown(
          data['bunji_memory']!,
          _bunjiMemoryMeta,
        ),
      );
    }
    if (data.containsKey('enter_to_send')) {
      context.handle(
        _enterToSendMeta,
        enterToSend.isAcceptableOrUnknown(
          data['enter_to_send']!,
          _enterToSendMeta,
        ),
      );
    }
    if (data.containsKey('show_ai_indicator')) {
      context.handle(
        _showAiIndicatorMeta,
        showAiIndicator.isAcceptableOrUnknown(
          data['show_ai_indicator']!,
          _showAiIndicatorMeta,
        ),
      );
    }
    if (data.containsKey('auto_scroll')) {
      context.handle(
        _autoScrollMeta,
        autoScroll.isAcceptableOrUnknown(data['auto_scroll']!, _autoScrollMeta),
      );
    }
    if (data.containsKey('code_syntax_highlighting')) {
      context.handle(
        _codeSyntaxHighlightingMeta,
        codeSyntaxHighlighting.isAcceptableOrUnknown(
          data['code_syntax_highlighting']!,
          _codeSyntaxHighlightingMeta,
        ),
      );
    }
    if (data.containsKey('markdown_rendering')) {
      context.handle(
        _markdownRenderingMeta,
        markdownRendering.isAcceptableOrUnknown(
          data['markdown_rendering']!,
          _markdownRenderingMeta,
        ),
      );
    }
    if (data.containsKey('auto_name_conversations')) {
      context.handle(
        _autoNameConversationsMeta,
        autoNameConversations.isAcceptableOrUnknown(
          data['auto_name_conversations']!,
          _autoNameConversationsMeta,
        ),
      );
    }
    if (data.containsKey('reduce_motion')) {
      context.handle(
        _reduceMotionMeta,
        reduceMotion.isAcceptableOrUnknown(
          data['reduce_motion']!,
          _reduceMotionMeta,
        ),
      );
    }
    if (data.containsKey('enable_notifications')) {
      context.handle(
        _enableNotificationsMeta,
        enableNotifications.isAcceptableOrUnknown(
          data['enable_notifications']!,
          _enableNotificationsMeta,
        ),
      );
    }
    if (data.containsKey('notify_task_completion')) {
      context.handle(
        _notifyTaskCompletionMeta,
        notifyTaskCompletion.isAcceptableOrUnknown(
          data['notify_task_completion']!,
          _notifyTaskCompletionMeta,
        ),
      );
    }
    if (data.containsKey('notify_downloads')) {
      context.handle(
        _notifyDownloadsMeta,
        notifyDownloads.isAcceptableOrUnknown(
          data['notify_downloads']!,
          _notifyDownloadsMeta,
        ),
      );
    }
    if (data.containsKey('notify_reminders')) {
      context.handle(
        _notifyRemindersMeta,
        notifyReminders.isAcceptableOrUnknown(
          data['notify_reminders']!,
          _notifyRemindersMeta,
        ),
      );
    }
    if (data.containsKey('launch_behavior')) {
      context.handle(
        _launchBehaviorMeta,
        launchBehavior.isAcceptableOrUnknown(
          data['launch_behavior']!,
          _launchBehaviorMeta,
        ),
      );
    }
    if (data.containsKey('haptic_feedback')) {
      context.handle(
        _hapticFeedbackMeta,
        hapticFeedback.isAcceptableOrUnknown(
          data['haptic_feedback']!,
          _hapticFeedbackMeta,
        ),
      );
    }
    if (data.containsKey('sound_effects')) {
      context.handle(
        _soundEffectsMeta,
        soundEffects.isAcceptableOrUnknown(
          data['sound_effects']!,
          _soundEffectsMeta,
        ),
      );
    }
    if (data.containsKey('confirm_before_deleting')) {
      context.handle(
        _confirmBeforeDeletingMeta,
        confirmBeforeDeleting.isAcceptableOrUnknown(
          data['confirm_before_deleting']!,
          _confirmBeforeDeletingMeta,
        ),
      );
    }
    if (data.containsKey('app_language')) {
      context.handle(
        _appLanguageMeta,
        appLanguage.isAcceptableOrUnknown(
          data['app_language']!,
          _appLanguageMeta,
        ),
      );
    }
    if (data.containsKey('ai_language')) {
      context.handle(
        _aiLanguageMeta,
        aiLanguage.isAcceptableOrUnknown(data['ai_language']!, _aiLanguageMeta),
      );
    }
    if (data.containsKey('developer_mode')) {
      context.handle(
        _developerModeMeta,
        developerMode.isAcceptableOrUnknown(
          data['developer_mode']!,
          _developerModeMeta,
        ),
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
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      messageDensity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_density'],
      )!,
      activeModelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_model_id'],
      )!,
      responseStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_style'],
      )!,
      reasoningMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reasoning_mode'],
      )!,
      streamingTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}streaming_tokens'],
      )!,
      localAiOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}local_ai_only'],
      )!,
      allowInternetForDownloads: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_internet_for_downloads'],
      )!,
      sendDiagnostics: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}send_diagnostics'],
      )!,
      saveChatHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}save_chat_history'],
      )!,
      autoDeleteChats: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_delete_chats'],
      )!,
      bunjiMemory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bunji_memory'],
      )!,
      enterToSend: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enter_to_send'],
      )!,
      showAiIndicator: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_ai_indicator'],
      )!,
      autoScroll: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_scroll'],
      )!,
      codeSyntaxHighlighting: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}code_syntax_highlighting'],
      )!,
      markdownRendering: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}markdown_rendering'],
      )!,
      autoNameConversations: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_name_conversations'],
      )!,
      reduceMotion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reduce_motion'],
      )!,
      enableNotifications: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_notifications'],
      )!,
      notifyTaskCompletion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_task_completion'],
      )!,
      notifyDownloads: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_downloads'],
      )!,
      notifyReminders: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_reminders'],
      )!,
      launchBehavior: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}launch_behavior'],
      )!,
      hapticFeedback: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}haptic_feedback'],
      )!,
      soundEffects: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_effects'],
      )!,
      confirmBeforeDeleting: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confirm_before_deleting'],
      )!,
      appLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_language'],
      )!,
      aiLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_language'],
      )!,
      developerMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}developer_mode'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  /// Unique identifier for the settings profile (e.g. 'default').
  final String id;

  /// Theme mode: 'system', 'light', or 'dark'.
  final String themeMode;

  /// Message density: 'compact', 'comfortable', or 'spacious'.
  final String messageDensity;

  /// Active AI model identifier (e.g. 'qwen3_0_6b', 'mobilellm_r1_5_950m', 'qwen3_1_7b').
  final String activeModelId;

  /// AI response style: 'Balanced', 'Concise', or 'Detailed'.
  final String responseStyle;

  /// Reasoning mode toggle (step-by-step thinking for analytical queries).
  final bool reasoningMode;

  /// Streaming responses toggle (render tokens dynamically).
  final bool streamingTokens;

  /// Local AI only toggle (strictly enforce 100% on-device inference).
  final bool localAiOnly;

  /// Allow internet connectivity for model downloads.
  final bool allowInternetForDownloads;

  /// Send anonymous diagnostic data.
  final bool sendDiagnostics;

  /// Save chat history locally.
  final bool saveChatHistory;

  /// Auto-delete chats policy ('Never', 'After 30 days', 'After 90 days').
  final String autoDeleteChats;

  /// Bunji memory toggle (remembers facts across sessions).
  final bool bunjiMemory;

  /// Enter key sends message.
  final bool enterToSend;

  /// Show AI generation visual pulse indicator.
  final bool showAiIndicator;

  /// Auto-scroll conversation viewport to latest message.
  final bool autoScroll;

  /// Code syntax highlighting in chat markdown.
  final bool codeSyntaxHighlighting;

  /// Markdown rich text rendering.
  final bool markdownRendering;

  /// Automatically generate conversation title from first user prompt.
  final bool autoNameConversations;

  /// Reduce motion and animations.
  final bool reduceMotion;

  /// Enable master notifications.
  final bool enableNotifications;

  /// Notify on AI task completion.
  final bool notifyTaskCompletion;

  /// Notify on model download completion and updates.
  final bool notifyDownloads;

  /// Scheduled reminders and proactive alerts.
  final bool notifyReminders;

  /// App launch behavior ('Open Home', 'Last Chat', 'New Chat').
  final String launchBehavior;

  /// Haptic tactile feedback.
  final bool hapticFeedback;

  /// Subtle audio sound effects.
  final bool soundEffects;

  /// Confirmation dialog before deleting conversations or items.
  final bool confirmBeforeDeleting;

  /// App interface language.
  final String appLanguage;

  /// AI response language.
  final String aiLanguage;

  /// Developer mode (displays latency, tokens/sec, and debug info).
  final bool developerMode;

  /// Timestamp of creation.
  final DateTime createdAt;

  /// Timestamp of last update.
  final DateTime? updatedAt;
  const UserSetting({
    required this.id,
    required this.themeMode,
    required this.messageDensity,
    required this.activeModelId,
    required this.responseStyle,
    required this.reasoningMode,
    required this.streamingTokens,
    required this.localAiOnly,
    required this.allowInternetForDownloads,
    required this.sendDiagnostics,
    required this.saveChatHistory,
    required this.autoDeleteChats,
    required this.bunjiMemory,
    required this.enterToSend,
    required this.showAiIndicator,
    required this.autoScroll,
    required this.codeSyntaxHighlighting,
    required this.markdownRendering,
    required this.autoNameConversations,
    required this.reduceMotion,
    required this.enableNotifications,
    required this.notifyTaskCompletion,
    required this.notifyDownloads,
    required this.notifyReminders,
    required this.launchBehavior,
    required this.hapticFeedback,
    required this.soundEffects,
    required this.confirmBeforeDeleting,
    required this.appLanguage,
    required this.aiLanguage,
    required this.developerMode,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['message_density'] = Variable<String>(messageDensity);
    map['active_model_id'] = Variable<String>(activeModelId);
    map['response_style'] = Variable<String>(responseStyle);
    map['reasoning_mode'] = Variable<bool>(reasoningMode);
    map['streaming_tokens'] = Variable<bool>(streamingTokens);
    map['local_ai_only'] = Variable<bool>(localAiOnly);
    map['allow_internet_for_downloads'] = Variable<bool>(
      allowInternetForDownloads,
    );
    map['send_diagnostics'] = Variable<bool>(sendDiagnostics);
    map['save_chat_history'] = Variable<bool>(saveChatHistory);
    map['auto_delete_chats'] = Variable<String>(autoDeleteChats);
    map['bunji_memory'] = Variable<bool>(bunjiMemory);
    map['enter_to_send'] = Variable<bool>(enterToSend);
    map['show_ai_indicator'] = Variable<bool>(showAiIndicator);
    map['auto_scroll'] = Variable<bool>(autoScroll);
    map['code_syntax_highlighting'] = Variable<bool>(codeSyntaxHighlighting);
    map['markdown_rendering'] = Variable<bool>(markdownRendering);
    map['auto_name_conversations'] = Variable<bool>(autoNameConversations);
    map['reduce_motion'] = Variable<bool>(reduceMotion);
    map['enable_notifications'] = Variable<bool>(enableNotifications);
    map['notify_task_completion'] = Variable<bool>(notifyTaskCompletion);
    map['notify_downloads'] = Variable<bool>(notifyDownloads);
    map['notify_reminders'] = Variable<bool>(notifyReminders);
    map['launch_behavior'] = Variable<String>(launchBehavior);
    map['haptic_feedback'] = Variable<bool>(hapticFeedback);
    map['sound_effects'] = Variable<bool>(soundEffects);
    map['confirm_before_deleting'] = Variable<bool>(confirmBeforeDeleting);
    map['app_language'] = Variable<String>(appLanguage);
    map['ai_language'] = Variable<String>(aiLanguage);
    map['developer_mode'] = Variable<bool>(developerMode);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      messageDensity: Value(messageDensity),
      activeModelId: Value(activeModelId),
      responseStyle: Value(responseStyle),
      reasoningMode: Value(reasoningMode),
      streamingTokens: Value(streamingTokens),
      localAiOnly: Value(localAiOnly),
      allowInternetForDownloads: Value(allowInternetForDownloads),
      sendDiagnostics: Value(sendDiagnostics),
      saveChatHistory: Value(saveChatHistory),
      autoDeleteChats: Value(autoDeleteChats),
      bunjiMemory: Value(bunjiMemory),
      enterToSend: Value(enterToSend),
      showAiIndicator: Value(showAiIndicator),
      autoScroll: Value(autoScroll),
      codeSyntaxHighlighting: Value(codeSyntaxHighlighting),
      markdownRendering: Value(markdownRendering),
      autoNameConversations: Value(autoNameConversations),
      reduceMotion: Value(reduceMotion),
      enableNotifications: Value(enableNotifications),
      notifyTaskCompletion: Value(notifyTaskCompletion),
      notifyDownloads: Value(notifyDownloads),
      notifyReminders: Value(notifyReminders),
      launchBehavior: Value(launchBehavior),
      hapticFeedback: Value(hapticFeedback),
      soundEffects: Value(soundEffects),
      confirmBeforeDeleting: Value(confirmBeforeDeleting),
      appLanguage: Value(appLanguage),
      aiLanguage: Value(aiLanguage),
      developerMode: Value(developerMode),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory UserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      id: serializer.fromJson<String>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      messageDensity: serializer.fromJson<String>(json['messageDensity']),
      activeModelId: serializer.fromJson<String>(json['activeModelId']),
      responseStyle: serializer.fromJson<String>(json['responseStyle']),
      reasoningMode: serializer.fromJson<bool>(json['reasoningMode']),
      streamingTokens: serializer.fromJson<bool>(json['streamingTokens']),
      localAiOnly: serializer.fromJson<bool>(json['localAiOnly']),
      allowInternetForDownloads: serializer.fromJson<bool>(
        json['allowInternetForDownloads'],
      ),
      sendDiagnostics: serializer.fromJson<bool>(json['sendDiagnostics']),
      saveChatHistory: serializer.fromJson<bool>(json['saveChatHistory']),
      autoDeleteChats: serializer.fromJson<String>(json['autoDeleteChats']),
      bunjiMemory: serializer.fromJson<bool>(json['bunjiMemory']),
      enterToSend: serializer.fromJson<bool>(json['enterToSend']),
      showAiIndicator: serializer.fromJson<bool>(json['showAiIndicator']),
      autoScroll: serializer.fromJson<bool>(json['autoScroll']),
      codeSyntaxHighlighting: serializer.fromJson<bool>(
        json['codeSyntaxHighlighting'],
      ),
      markdownRendering: serializer.fromJson<bool>(json['markdownRendering']),
      autoNameConversations: serializer.fromJson<bool>(
        json['autoNameConversations'],
      ),
      reduceMotion: serializer.fromJson<bool>(json['reduceMotion']),
      enableNotifications: serializer.fromJson<bool>(
        json['enableNotifications'],
      ),
      notifyTaskCompletion: serializer.fromJson<bool>(
        json['notifyTaskCompletion'],
      ),
      notifyDownloads: serializer.fromJson<bool>(json['notifyDownloads']),
      notifyReminders: serializer.fromJson<bool>(json['notifyReminders']),
      launchBehavior: serializer.fromJson<String>(json['launchBehavior']),
      hapticFeedback: serializer.fromJson<bool>(json['hapticFeedback']),
      soundEffects: serializer.fromJson<bool>(json['soundEffects']),
      confirmBeforeDeleting: serializer.fromJson<bool>(
        json['confirmBeforeDeleting'],
      ),
      appLanguage: serializer.fromJson<String>(json['appLanguage']),
      aiLanguage: serializer.fromJson<String>(json['aiLanguage']),
      developerMode: serializer.fromJson<bool>(json['developerMode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'messageDensity': serializer.toJson<String>(messageDensity),
      'activeModelId': serializer.toJson<String>(activeModelId),
      'responseStyle': serializer.toJson<String>(responseStyle),
      'reasoningMode': serializer.toJson<bool>(reasoningMode),
      'streamingTokens': serializer.toJson<bool>(streamingTokens),
      'localAiOnly': serializer.toJson<bool>(localAiOnly),
      'allowInternetForDownloads': serializer.toJson<bool>(
        allowInternetForDownloads,
      ),
      'sendDiagnostics': serializer.toJson<bool>(sendDiagnostics),
      'saveChatHistory': serializer.toJson<bool>(saveChatHistory),
      'autoDeleteChats': serializer.toJson<String>(autoDeleteChats),
      'bunjiMemory': serializer.toJson<bool>(bunjiMemory),
      'enterToSend': serializer.toJson<bool>(enterToSend),
      'showAiIndicator': serializer.toJson<bool>(showAiIndicator),
      'autoScroll': serializer.toJson<bool>(autoScroll),
      'codeSyntaxHighlighting': serializer.toJson<bool>(codeSyntaxHighlighting),
      'markdownRendering': serializer.toJson<bool>(markdownRendering),
      'autoNameConversations': serializer.toJson<bool>(autoNameConversations),
      'reduceMotion': serializer.toJson<bool>(reduceMotion),
      'enableNotifications': serializer.toJson<bool>(enableNotifications),
      'notifyTaskCompletion': serializer.toJson<bool>(notifyTaskCompletion),
      'notifyDownloads': serializer.toJson<bool>(notifyDownloads),
      'notifyReminders': serializer.toJson<bool>(notifyReminders),
      'launchBehavior': serializer.toJson<String>(launchBehavior),
      'hapticFeedback': serializer.toJson<bool>(hapticFeedback),
      'soundEffects': serializer.toJson<bool>(soundEffects),
      'confirmBeforeDeleting': serializer.toJson<bool>(confirmBeforeDeleting),
      'appLanguage': serializer.toJson<String>(appLanguage),
      'aiLanguage': serializer.toJson<String>(aiLanguage),
      'developerMode': serializer.toJson<bool>(developerMode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  UserSetting copyWith({
    String? id,
    String? themeMode,
    String? messageDensity,
    String? activeModelId,
    String? responseStyle,
    bool? reasoningMode,
    bool? streamingTokens,
    bool? localAiOnly,
    bool? allowInternetForDownloads,
    bool? sendDiagnostics,
    bool? saveChatHistory,
    String? autoDeleteChats,
    bool? bunjiMemory,
    bool? enterToSend,
    bool? showAiIndicator,
    bool? autoScroll,
    bool? codeSyntaxHighlighting,
    bool? markdownRendering,
    bool? autoNameConversations,
    bool? reduceMotion,
    bool? enableNotifications,
    bool? notifyTaskCompletion,
    bool? notifyDownloads,
    bool? notifyReminders,
    String? launchBehavior,
    bool? hapticFeedback,
    bool? soundEffects,
    bool? confirmBeforeDeleting,
    String? appLanguage,
    String? aiLanguage,
    bool? developerMode,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => UserSetting(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    messageDensity: messageDensity ?? this.messageDensity,
    activeModelId: activeModelId ?? this.activeModelId,
    responseStyle: responseStyle ?? this.responseStyle,
    reasoningMode: reasoningMode ?? this.reasoningMode,
    streamingTokens: streamingTokens ?? this.streamingTokens,
    localAiOnly: localAiOnly ?? this.localAiOnly,
    allowInternetForDownloads:
        allowInternetForDownloads ?? this.allowInternetForDownloads,
    sendDiagnostics: sendDiagnostics ?? this.sendDiagnostics,
    saveChatHistory: saveChatHistory ?? this.saveChatHistory,
    autoDeleteChats: autoDeleteChats ?? this.autoDeleteChats,
    bunjiMemory: bunjiMemory ?? this.bunjiMemory,
    enterToSend: enterToSend ?? this.enterToSend,
    showAiIndicator: showAiIndicator ?? this.showAiIndicator,
    autoScroll: autoScroll ?? this.autoScroll,
    codeSyntaxHighlighting:
        codeSyntaxHighlighting ?? this.codeSyntaxHighlighting,
    markdownRendering: markdownRendering ?? this.markdownRendering,
    autoNameConversations: autoNameConversations ?? this.autoNameConversations,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    enableNotifications: enableNotifications ?? this.enableNotifications,
    notifyTaskCompletion: notifyTaskCompletion ?? this.notifyTaskCompletion,
    notifyDownloads: notifyDownloads ?? this.notifyDownloads,
    notifyReminders: notifyReminders ?? this.notifyReminders,
    launchBehavior: launchBehavior ?? this.launchBehavior,
    hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    soundEffects: soundEffects ?? this.soundEffects,
    confirmBeforeDeleting: confirmBeforeDeleting ?? this.confirmBeforeDeleting,
    appLanguage: appLanguage ?? this.appLanguage,
    aiLanguage: aiLanguage ?? this.aiLanguage,
    developerMode: developerMode ?? this.developerMode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      messageDensity: data.messageDensity.present
          ? data.messageDensity.value
          : this.messageDensity,
      activeModelId: data.activeModelId.present
          ? data.activeModelId.value
          : this.activeModelId,
      responseStyle: data.responseStyle.present
          ? data.responseStyle.value
          : this.responseStyle,
      reasoningMode: data.reasoningMode.present
          ? data.reasoningMode.value
          : this.reasoningMode,
      streamingTokens: data.streamingTokens.present
          ? data.streamingTokens.value
          : this.streamingTokens,
      localAiOnly: data.localAiOnly.present
          ? data.localAiOnly.value
          : this.localAiOnly,
      allowInternetForDownloads: data.allowInternetForDownloads.present
          ? data.allowInternetForDownloads.value
          : this.allowInternetForDownloads,
      sendDiagnostics: data.sendDiagnostics.present
          ? data.sendDiagnostics.value
          : this.sendDiagnostics,
      saveChatHistory: data.saveChatHistory.present
          ? data.saveChatHistory.value
          : this.saveChatHistory,
      autoDeleteChats: data.autoDeleteChats.present
          ? data.autoDeleteChats.value
          : this.autoDeleteChats,
      bunjiMemory: data.bunjiMemory.present
          ? data.bunjiMemory.value
          : this.bunjiMemory,
      enterToSend: data.enterToSend.present
          ? data.enterToSend.value
          : this.enterToSend,
      showAiIndicator: data.showAiIndicator.present
          ? data.showAiIndicator.value
          : this.showAiIndicator,
      autoScroll: data.autoScroll.present
          ? data.autoScroll.value
          : this.autoScroll,
      codeSyntaxHighlighting: data.codeSyntaxHighlighting.present
          ? data.codeSyntaxHighlighting.value
          : this.codeSyntaxHighlighting,
      markdownRendering: data.markdownRendering.present
          ? data.markdownRendering.value
          : this.markdownRendering,
      autoNameConversations: data.autoNameConversations.present
          ? data.autoNameConversations.value
          : this.autoNameConversations,
      reduceMotion: data.reduceMotion.present
          ? data.reduceMotion.value
          : this.reduceMotion,
      enableNotifications: data.enableNotifications.present
          ? data.enableNotifications.value
          : this.enableNotifications,
      notifyTaskCompletion: data.notifyTaskCompletion.present
          ? data.notifyTaskCompletion.value
          : this.notifyTaskCompletion,
      notifyDownloads: data.notifyDownloads.present
          ? data.notifyDownloads.value
          : this.notifyDownloads,
      notifyReminders: data.notifyReminders.present
          ? data.notifyReminders.value
          : this.notifyReminders,
      launchBehavior: data.launchBehavior.present
          ? data.launchBehavior.value
          : this.launchBehavior,
      hapticFeedback: data.hapticFeedback.present
          ? data.hapticFeedback.value
          : this.hapticFeedback,
      soundEffects: data.soundEffects.present
          ? data.soundEffects.value
          : this.soundEffects,
      confirmBeforeDeleting: data.confirmBeforeDeleting.present
          ? data.confirmBeforeDeleting.value
          : this.confirmBeforeDeleting,
      appLanguage: data.appLanguage.present
          ? data.appLanguage.value
          : this.appLanguage,
      aiLanguage: data.aiLanguage.present
          ? data.aiLanguage.value
          : this.aiLanguage,
      developerMode: data.developerMode.present
          ? data.developerMode.value
          : this.developerMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('messageDensity: $messageDensity, ')
          ..write('activeModelId: $activeModelId, ')
          ..write('responseStyle: $responseStyle, ')
          ..write('reasoningMode: $reasoningMode, ')
          ..write('streamingTokens: $streamingTokens, ')
          ..write('localAiOnly: $localAiOnly, ')
          ..write('allowInternetForDownloads: $allowInternetForDownloads, ')
          ..write('sendDiagnostics: $sendDiagnostics, ')
          ..write('saveChatHistory: $saveChatHistory, ')
          ..write('autoDeleteChats: $autoDeleteChats, ')
          ..write('bunjiMemory: $bunjiMemory, ')
          ..write('enterToSend: $enterToSend, ')
          ..write('showAiIndicator: $showAiIndicator, ')
          ..write('autoScroll: $autoScroll, ')
          ..write('codeSyntaxHighlighting: $codeSyntaxHighlighting, ')
          ..write('markdownRendering: $markdownRendering, ')
          ..write('autoNameConversations: $autoNameConversations, ')
          ..write('reduceMotion: $reduceMotion, ')
          ..write('enableNotifications: $enableNotifications, ')
          ..write('notifyTaskCompletion: $notifyTaskCompletion, ')
          ..write('notifyDownloads: $notifyDownloads, ')
          ..write('notifyReminders: $notifyReminders, ')
          ..write('launchBehavior: $launchBehavior, ')
          ..write('hapticFeedback: $hapticFeedback, ')
          ..write('soundEffects: $soundEffects, ')
          ..write('confirmBeforeDeleting: $confirmBeforeDeleting, ')
          ..write('appLanguage: $appLanguage, ')
          ..write('aiLanguage: $aiLanguage, ')
          ..write('developerMode: $developerMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    themeMode,
    messageDensity,
    activeModelId,
    responseStyle,
    reasoningMode,
    streamingTokens,
    localAiOnly,
    allowInternetForDownloads,
    sendDiagnostics,
    saveChatHistory,
    autoDeleteChats,
    bunjiMemory,
    enterToSend,
    showAiIndicator,
    autoScroll,
    codeSyntaxHighlighting,
    markdownRendering,
    autoNameConversations,
    reduceMotion,
    enableNotifications,
    notifyTaskCompletion,
    notifyDownloads,
    notifyReminders,
    launchBehavior,
    hapticFeedback,
    soundEffects,
    confirmBeforeDeleting,
    appLanguage,
    aiLanguage,
    developerMode,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.messageDensity == this.messageDensity &&
          other.activeModelId == this.activeModelId &&
          other.responseStyle == this.responseStyle &&
          other.reasoningMode == this.reasoningMode &&
          other.streamingTokens == this.streamingTokens &&
          other.localAiOnly == this.localAiOnly &&
          other.allowInternetForDownloads == this.allowInternetForDownloads &&
          other.sendDiagnostics == this.sendDiagnostics &&
          other.saveChatHistory == this.saveChatHistory &&
          other.autoDeleteChats == this.autoDeleteChats &&
          other.bunjiMemory == this.bunjiMemory &&
          other.enterToSend == this.enterToSend &&
          other.showAiIndicator == this.showAiIndicator &&
          other.autoScroll == this.autoScroll &&
          other.codeSyntaxHighlighting == this.codeSyntaxHighlighting &&
          other.markdownRendering == this.markdownRendering &&
          other.autoNameConversations == this.autoNameConversations &&
          other.reduceMotion == this.reduceMotion &&
          other.enableNotifications == this.enableNotifications &&
          other.notifyTaskCompletion == this.notifyTaskCompletion &&
          other.notifyDownloads == this.notifyDownloads &&
          other.notifyReminders == this.notifyReminders &&
          other.launchBehavior == this.launchBehavior &&
          other.hapticFeedback == this.hapticFeedback &&
          other.soundEffects == this.soundEffects &&
          other.confirmBeforeDeleting == this.confirmBeforeDeleting &&
          other.appLanguage == this.appLanguage &&
          other.aiLanguage == this.aiLanguage &&
          other.developerMode == this.developerMode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> id;
  final Value<String> themeMode;
  final Value<String> messageDensity;
  final Value<String> activeModelId;
  final Value<String> responseStyle;
  final Value<bool> reasoningMode;
  final Value<bool> streamingTokens;
  final Value<bool> localAiOnly;
  final Value<bool> allowInternetForDownloads;
  final Value<bool> sendDiagnostics;
  final Value<bool> saveChatHistory;
  final Value<String> autoDeleteChats;
  final Value<bool> bunjiMemory;
  final Value<bool> enterToSend;
  final Value<bool> showAiIndicator;
  final Value<bool> autoScroll;
  final Value<bool> codeSyntaxHighlighting;
  final Value<bool> markdownRendering;
  final Value<bool> autoNameConversations;
  final Value<bool> reduceMotion;
  final Value<bool> enableNotifications;
  final Value<bool> notifyTaskCompletion;
  final Value<bool> notifyDownloads;
  final Value<bool> notifyReminders;
  final Value<String> launchBehavior;
  final Value<bool> hapticFeedback;
  final Value<bool> soundEffects;
  final Value<bool> confirmBeforeDeleting;
  final Value<String> appLanguage;
  final Value<String> aiLanguage;
  final Value<bool> developerMode;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.messageDensity = const Value.absent(),
    this.activeModelId = const Value.absent(),
    this.responseStyle = const Value.absent(),
    this.reasoningMode = const Value.absent(),
    this.streamingTokens = const Value.absent(),
    this.localAiOnly = const Value.absent(),
    this.allowInternetForDownloads = const Value.absent(),
    this.sendDiagnostics = const Value.absent(),
    this.saveChatHistory = const Value.absent(),
    this.autoDeleteChats = const Value.absent(),
    this.bunjiMemory = const Value.absent(),
    this.enterToSend = const Value.absent(),
    this.showAiIndicator = const Value.absent(),
    this.autoScroll = const Value.absent(),
    this.codeSyntaxHighlighting = const Value.absent(),
    this.markdownRendering = const Value.absent(),
    this.autoNameConversations = const Value.absent(),
    this.reduceMotion = const Value.absent(),
    this.enableNotifications = const Value.absent(),
    this.notifyTaskCompletion = const Value.absent(),
    this.notifyDownloads = const Value.absent(),
    this.notifyReminders = const Value.absent(),
    this.launchBehavior = const Value.absent(),
    this.hapticFeedback = const Value.absent(),
    this.soundEffects = const Value.absent(),
    this.confirmBeforeDeleting = const Value.absent(),
    this.appLanguage = const Value.absent(),
    this.aiLanguage = const Value.absent(),
    this.developerMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String id,
    this.themeMode = const Value.absent(),
    this.messageDensity = const Value.absent(),
    this.activeModelId = const Value.absent(),
    this.responseStyle = const Value.absent(),
    this.reasoningMode = const Value.absent(),
    this.streamingTokens = const Value.absent(),
    this.localAiOnly = const Value.absent(),
    this.allowInternetForDownloads = const Value.absent(),
    this.sendDiagnostics = const Value.absent(),
    this.saveChatHistory = const Value.absent(),
    this.autoDeleteChats = const Value.absent(),
    this.bunjiMemory = const Value.absent(),
    this.enterToSend = const Value.absent(),
    this.showAiIndicator = const Value.absent(),
    this.autoScroll = const Value.absent(),
    this.codeSyntaxHighlighting = const Value.absent(),
    this.markdownRendering = const Value.absent(),
    this.autoNameConversations = const Value.absent(),
    this.reduceMotion = const Value.absent(),
    this.enableNotifications = const Value.absent(),
    this.notifyTaskCompletion = const Value.absent(),
    this.notifyDownloads = const Value.absent(),
    this.notifyReminders = const Value.absent(),
    this.launchBehavior = const Value.absent(),
    this.hapticFeedback = const Value.absent(),
    this.soundEffects = const Value.absent(),
    this.confirmBeforeDeleting = const Value.absent(),
    this.appLanguage = const Value.absent(),
    this.aiLanguage = const Value.absent(),
    this.developerMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<UserSetting> custom({
    Expression<String>? id,
    Expression<String>? themeMode,
    Expression<String>? messageDensity,
    Expression<String>? activeModelId,
    Expression<String>? responseStyle,
    Expression<bool>? reasoningMode,
    Expression<bool>? streamingTokens,
    Expression<bool>? localAiOnly,
    Expression<bool>? allowInternetForDownloads,
    Expression<bool>? sendDiagnostics,
    Expression<bool>? saveChatHistory,
    Expression<String>? autoDeleteChats,
    Expression<bool>? bunjiMemory,
    Expression<bool>? enterToSend,
    Expression<bool>? showAiIndicator,
    Expression<bool>? autoScroll,
    Expression<bool>? codeSyntaxHighlighting,
    Expression<bool>? markdownRendering,
    Expression<bool>? autoNameConversations,
    Expression<bool>? reduceMotion,
    Expression<bool>? enableNotifications,
    Expression<bool>? notifyTaskCompletion,
    Expression<bool>? notifyDownloads,
    Expression<bool>? notifyReminders,
    Expression<String>? launchBehavior,
    Expression<bool>? hapticFeedback,
    Expression<bool>? soundEffects,
    Expression<bool>? confirmBeforeDeleting,
    Expression<String>? appLanguage,
    Expression<String>? aiLanguage,
    Expression<bool>? developerMode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (messageDensity != null) 'message_density': messageDensity,
      if (activeModelId != null) 'active_model_id': activeModelId,
      if (responseStyle != null) 'response_style': responseStyle,
      if (reasoningMode != null) 'reasoning_mode': reasoningMode,
      if (streamingTokens != null) 'streaming_tokens': streamingTokens,
      if (localAiOnly != null) 'local_ai_only': localAiOnly,
      if (allowInternetForDownloads != null)
        'allow_internet_for_downloads': allowInternetForDownloads,
      if (sendDiagnostics != null) 'send_diagnostics': sendDiagnostics,
      if (saveChatHistory != null) 'save_chat_history': saveChatHistory,
      if (autoDeleteChats != null) 'auto_delete_chats': autoDeleteChats,
      if (bunjiMemory != null) 'bunji_memory': bunjiMemory,
      if (enterToSend != null) 'enter_to_send': enterToSend,
      if (showAiIndicator != null) 'show_ai_indicator': showAiIndicator,
      if (autoScroll != null) 'auto_scroll': autoScroll,
      if (codeSyntaxHighlighting != null)
        'code_syntax_highlighting': codeSyntaxHighlighting,
      if (markdownRendering != null) 'markdown_rendering': markdownRendering,
      if (autoNameConversations != null)
        'auto_name_conversations': autoNameConversations,
      if (reduceMotion != null) 'reduce_motion': reduceMotion,
      if (enableNotifications != null)
        'enable_notifications': enableNotifications,
      if (notifyTaskCompletion != null)
        'notify_task_completion': notifyTaskCompletion,
      if (notifyDownloads != null) 'notify_downloads': notifyDownloads,
      if (notifyReminders != null) 'notify_reminders': notifyReminders,
      if (launchBehavior != null) 'launch_behavior': launchBehavior,
      if (hapticFeedback != null) 'haptic_feedback': hapticFeedback,
      if (soundEffects != null) 'sound_effects': soundEffects,
      if (confirmBeforeDeleting != null)
        'confirm_before_deleting': confirmBeforeDeleting,
      if (appLanguage != null) 'app_language': appLanguage,
      if (aiLanguage != null) 'ai_language': aiLanguage,
      if (developerMode != null) 'developer_mode': developerMode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? themeMode,
    Value<String>? messageDensity,
    Value<String>? activeModelId,
    Value<String>? responseStyle,
    Value<bool>? reasoningMode,
    Value<bool>? streamingTokens,
    Value<bool>? localAiOnly,
    Value<bool>? allowInternetForDownloads,
    Value<bool>? sendDiagnostics,
    Value<bool>? saveChatHistory,
    Value<String>? autoDeleteChats,
    Value<bool>? bunjiMemory,
    Value<bool>? enterToSend,
    Value<bool>? showAiIndicator,
    Value<bool>? autoScroll,
    Value<bool>? codeSyntaxHighlighting,
    Value<bool>? markdownRendering,
    Value<bool>? autoNameConversations,
    Value<bool>? reduceMotion,
    Value<bool>? enableNotifications,
    Value<bool>? notifyTaskCompletion,
    Value<bool>? notifyDownloads,
    Value<bool>? notifyReminders,
    Value<String>? launchBehavior,
    Value<bool>? hapticFeedback,
    Value<bool>? soundEffects,
    Value<bool>? confirmBeforeDeleting,
    Value<String>? appLanguage,
    Value<String>? aiLanguage,
    Value<bool>? developerMode,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      messageDensity: messageDensity ?? this.messageDensity,
      activeModelId: activeModelId ?? this.activeModelId,
      responseStyle: responseStyle ?? this.responseStyle,
      reasoningMode: reasoningMode ?? this.reasoningMode,
      streamingTokens: streamingTokens ?? this.streamingTokens,
      localAiOnly: localAiOnly ?? this.localAiOnly,
      allowInternetForDownloads:
          allowInternetForDownloads ?? this.allowInternetForDownloads,
      sendDiagnostics: sendDiagnostics ?? this.sendDiagnostics,
      saveChatHistory: saveChatHistory ?? this.saveChatHistory,
      autoDeleteChats: autoDeleteChats ?? this.autoDeleteChats,
      bunjiMemory: bunjiMemory ?? this.bunjiMemory,
      enterToSend: enterToSend ?? this.enterToSend,
      showAiIndicator: showAiIndicator ?? this.showAiIndicator,
      autoScroll: autoScroll ?? this.autoScroll,
      codeSyntaxHighlighting:
          codeSyntaxHighlighting ?? this.codeSyntaxHighlighting,
      markdownRendering: markdownRendering ?? this.markdownRendering,
      autoNameConversations:
          autoNameConversations ?? this.autoNameConversations,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      notifyTaskCompletion: notifyTaskCompletion ?? this.notifyTaskCompletion,
      notifyDownloads: notifyDownloads ?? this.notifyDownloads,
      notifyReminders: notifyReminders ?? this.notifyReminders,
      launchBehavior: launchBehavior ?? this.launchBehavior,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      confirmBeforeDeleting:
          confirmBeforeDeleting ?? this.confirmBeforeDeleting,
      appLanguage: appLanguage ?? this.appLanguage,
      aiLanguage: aiLanguage ?? this.aiLanguage,
      developerMode: developerMode ?? this.developerMode,
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
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (messageDensity.present) {
      map['message_density'] = Variable<String>(messageDensity.value);
    }
    if (activeModelId.present) {
      map['active_model_id'] = Variable<String>(activeModelId.value);
    }
    if (responseStyle.present) {
      map['response_style'] = Variable<String>(responseStyle.value);
    }
    if (reasoningMode.present) {
      map['reasoning_mode'] = Variable<bool>(reasoningMode.value);
    }
    if (streamingTokens.present) {
      map['streaming_tokens'] = Variable<bool>(streamingTokens.value);
    }
    if (localAiOnly.present) {
      map['local_ai_only'] = Variable<bool>(localAiOnly.value);
    }
    if (allowInternetForDownloads.present) {
      map['allow_internet_for_downloads'] = Variable<bool>(
        allowInternetForDownloads.value,
      );
    }
    if (sendDiagnostics.present) {
      map['send_diagnostics'] = Variable<bool>(sendDiagnostics.value);
    }
    if (saveChatHistory.present) {
      map['save_chat_history'] = Variable<bool>(saveChatHistory.value);
    }
    if (autoDeleteChats.present) {
      map['auto_delete_chats'] = Variable<String>(autoDeleteChats.value);
    }
    if (bunjiMemory.present) {
      map['bunji_memory'] = Variable<bool>(bunjiMemory.value);
    }
    if (enterToSend.present) {
      map['enter_to_send'] = Variable<bool>(enterToSend.value);
    }
    if (showAiIndicator.present) {
      map['show_ai_indicator'] = Variable<bool>(showAiIndicator.value);
    }
    if (autoScroll.present) {
      map['auto_scroll'] = Variable<bool>(autoScroll.value);
    }
    if (codeSyntaxHighlighting.present) {
      map['code_syntax_highlighting'] = Variable<bool>(
        codeSyntaxHighlighting.value,
      );
    }
    if (markdownRendering.present) {
      map['markdown_rendering'] = Variable<bool>(markdownRendering.value);
    }
    if (autoNameConversations.present) {
      map['auto_name_conversations'] = Variable<bool>(
        autoNameConversations.value,
      );
    }
    if (reduceMotion.present) {
      map['reduce_motion'] = Variable<bool>(reduceMotion.value);
    }
    if (enableNotifications.present) {
      map['enable_notifications'] = Variable<bool>(enableNotifications.value);
    }
    if (notifyTaskCompletion.present) {
      map['notify_task_completion'] = Variable<bool>(
        notifyTaskCompletion.value,
      );
    }
    if (notifyDownloads.present) {
      map['notify_downloads'] = Variable<bool>(notifyDownloads.value);
    }
    if (notifyReminders.present) {
      map['notify_reminders'] = Variable<bool>(notifyReminders.value);
    }
    if (launchBehavior.present) {
      map['launch_behavior'] = Variable<String>(launchBehavior.value);
    }
    if (hapticFeedback.present) {
      map['haptic_feedback'] = Variable<bool>(hapticFeedback.value);
    }
    if (soundEffects.present) {
      map['sound_effects'] = Variable<bool>(soundEffects.value);
    }
    if (confirmBeforeDeleting.present) {
      map['confirm_before_deleting'] = Variable<bool>(
        confirmBeforeDeleting.value,
      );
    }
    if (appLanguage.present) {
      map['app_language'] = Variable<String>(appLanguage.value);
    }
    if (aiLanguage.present) {
      map['ai_language'] = Variable<String>(aiLanguage.value);
    }
    if (developerMode.present) {
      map['developer_mode'] = Variable<bool>(developerMode.value);
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
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('messageDensity: $messageDensity, ')
          ..write('activeModelId: $activeModelId, ')
          ..write('responseStyle: $responseStyle, ')
          ..write('reasoningMode: $reasoningMode, ')
          ..write('streamingTokens: $streamingTokens, ')
          ..write('localAiOnly: $localAiOnly, ')
          ..write('allowInternetForDownloads: $allowInternetForDownloads, ')
          ..write('sendDiagnostics: $sendDiagnostics, ')
          ..write('saveChatHistory: $saveChatHistory, ')
          ..write('autoDeleteChats: $autoDeleteChats, ')
          ..write('bunjiMemory: $bunjiMemory, ')
          ..write('enterToSend: $enterToSend, ')
          ..write('showAiIndicator: $showAiIndicator, ')
          ..write('autoScroll: $autoScroll, ')
          ..write('codeSyntaxHighlighting: $codeSyntaxHighlighting, ')
          ..write('markdownRendering: $markdownRendering, ')
          ..write('autoNameConversations: $autoNameConversations, ')
          ..write('reduceMotion: $reduceMotion, ')
          ..write('enableNotifications: $enableNotifications, ')
          ..write('notifyTaskCompletion: $notifyTaskCompletion, ')
          ..write('notifyDownloads: $notifyDownloads, ')
          ..write('notifyReminders: $notifyReminders, ')
          ..write('launchBehavior: $launchBehavior, ')
          ..write('hapticFeedback: $hapticFeedback, ')
          ..write('soundEffects: $soundEffects, ')
          ..write('confirmBeforeDeleting: $confirmBeforeDeleting, ')
          ..write('appLanguage: $appLanguage, ')
          ..write('aiLanguage: $aiLanguage, ')
          ..write('developerMode: $developerMode, ')
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
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $UserAiModelsTable userAiModels = $UserAiModelsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    userAiModels,
    userSettings,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String name,
      Value<DateTime?> dob,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> gender,
      Value<String?> avatarUrl,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime?> dob,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> gender,
      Value<String?> avatarUrl,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<DateTime> get dob => $composableBuilder(
    column: $table.dob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
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
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get dob => $composableBuilder(
    column: $table.dob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
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

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get dob =>
      $composableBuilder(column: $table.dob, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> dob = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                name: name,
                dob: dob,
                email: email,
                phone: phone,
                gender: gender,
                avatarUrl: avatarUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<DateTime?> dob = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                name: name,
                dob: dob,
                email: email,
                phone: phone,
                gender: gender,
                avatarUrl: avatarUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProfilesTable, UserProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProfilesTable,
                    UserProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$UserAiModelsTableCreateCompanionBuilder =
    UserAiModelsCompanion Function({
      required String id,
      required String displayName,
      required String tier,
      Value<String> version,
      required String filePath,
      required BigInt fileSizeBytes,
      required String sha256,
      Value<bool> isVerified,
      Value<bool> isActive,
      Value<DateTime> installedAt,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });
typedef $$UserAiModelsTableUpdateCompanionBuilder =
    UserAiModelsCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> tier,
      Value<String> version,
      Value<String> filePath,
      Value<BigInt> fileSizeBytes,
      Value<String> sha256,
      Value<bool> isVerified,
      Value<bool> isActive,
      Value<DateTime> installedAt,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });

class $$UserAiModelsTableFilterComposer
    extends Composer<_$AppDatabase, $UserAiModelsTable> {
  $$UserAiModelsTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserAiModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserAiModelsTable> {
  $$UserAiModelsTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserAiModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserAiModelsTable> {
  $$UserAiModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<BigInt> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$UserAiModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserAiModelsTable,
          UserAiModel,
          $$UserAiModelsTableFilterComposer,
          $$UserAiModelsTableOrderingComposer,
          $$UserAiModelsTableAnnotationComposer,
          $$UserAiModelsTableCreateCompanionBuilder,
          $$UserAiModelsTableUpdateCompanionBuilder,
          (
            UserAiModel,
            BaseReferences<_$AppDatabase, $UserAiModelsTable, UserAiModel>,
          ),
          UserAiModel,
          PrefetchHooks Function()
        > {
  $$UserAiModelsTableTableManager(_$AppDatabase db, $UserAiModelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserAiModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserAiModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserAiModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<BigInt> fileSizeBytes = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<bool> isVerified = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserAiModelsCompanion(
                id: id,
                displayName: displayName,
                tier: tier,
                version: version,
                filePath: filePath,
                fileSizeBytes: fileSizeBytes,
                sha256: sha256,
                isVerified: isVerified,
                isActive: isActive,
                installedAt: installedAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String tier,
                Value<String> version = const Value.absent(),
                required String filePath,
                required BigInt fileSizeBytes,
                required String sha256,
                Value<bool> isVerified = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserAiModelsCompanion.insert(
                id: id,
                displayName: displayName,
                tier: tier,
                version: version,
                filePath: filePath,
                fileSizeBytes: fileSizeBytes,
                sha256: sha256,
                isVerified: isVerified,
                isActive: isActive,
                installedAt: installedAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserAiModelsTable, UserAiModel>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserAiModelsTable,
                    UserAiModel
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserAiModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserAiModelsTable,
      UserAiModel,
      $$UserAiModelsTableFilterComposer,
      $$UserAiModelsTableOrderingComposer,
      $$UserAiModelsTableAnnotationComposer,
      $$UserAiModelsTableCreateCompanionBuilder,
      $$UserAiModelsTableUpdateCompanionBuilder,
      (
        UserAiModel,
        BaseReferences<_$AppDatabase, $UserAiModelsTable, UserAiModel>,
      ),
      UserAiModel,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      required String id,
      Value<String> themeMode,
      Value<String> messageDensity,
      Value<String> activeModelId,
      Value<String> responseStyle,
      Value<bool> reasoningMode,
      Value<bool> streamingTokens,
      Value<bool> localAiOnly,
      Value<bool> allowInternetForDownloads,
      Value<bool> sendDiagnostics,
      Value<bool> saveChatHistory,
      Value<String> autoDeleteChats,
      Value<bool> bunjiMemory,
      Value<bool> enterToSend,
      Value<bool> showAiIndicator,
      Value<bool> autoScroll,
      Value<bool> codeSyntaxHighlighting,
      Value<bool> markdownRendering,
      Value<bool> autoNameConversations,
      Value<bool> reduceMotion,
      Value<bool> enableNotifications,
      Value<bool> notifyTaskCompletion,
      Value<bool> notifyDownloads,
      Value<bool> notifyReminders,
      Value<String> launchBehavior,
      Value<bool> hapticFeedback,
      Value<bool> soundEffects,
      Value<bool> confirmBeforeDeleting,
      Value<String> appLanguage,
      Value<String> aiLanguage,
      Value<bool> developerMode,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<String> id,
      Value<String> themeMode,
      Value<String> messageDensity,
      Value<String> activeModelId,
      Value<String> responseStyle,
      Value<bool> reasoningMode,
      Value<bool> streamingTokens,
      Value<bool> localAiOnly,
      Value<bool> allowInternetForDownloads,
      Value<bool> sendDiagnostics,
      Value<bool> saveChatHistory,
      Value<String> autoDeleteChats,
      Value<bool> bunjiMemory,
      Value<bool> enterToSend,
      Value<bool> showAiIndicator,
      Value<bool> autoScroll,
      Value<bool> codeSyntaxHighlighting,
      Value<bool> markdownRendering,
      Value<bool> autoNameConversations,
      Value<bool> reduceMotion,
      Value<bool> enableNotifications,
      Value<bool> notifyTaskCompletion,
      Value<bool> notifyDownloads,
      Value<bool> notifyReminders,
      Value<String> launchBehavior,
      Value<bool> hapticFeedback,
      Value<bool> soundEffects,
      Value<bool> confirmBeforeDeleting,
      Value<String> appLanguage,
      Value<String> aiLanguage,
      Value<bool> developerMode,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
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

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageDensity => $composableBuilder(
    column: $table.messageDensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeModelId => $composableBuilder(
    column: $table.activeModelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseStyle => $composableBuilder(
    column: $table.responseStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reasoningMode => $composableBuilder(
    column: $table.reasoningMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get streamingTokens => $composableBuilder(
    column: $table.streamingTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get localAiOnly => $composableBuilder(
    column: $table.localAiOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowInternetForDownloads => $composableBuilder(
    column: $table.allowInternetForDownloads,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sendDiagnostics => $composableBuilder(
    column: $table.sendDiagnostics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get saveChatHistory => $composableBuilder(
    column: $table.saveChatHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autoDeleteChats => $composableBuilder(
    column: $table.autoDeleteChats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bunjiMemory => $composableBuilder(
    column: $table.bunjiMemory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enterToSend => $composableBuilder(
    column: $table.enterToSend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showAiIndicator => $composableBuilder(
    column: $table.showAiIndicator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoScroll => $composableBuilder(
    column: $table.autoScroll,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get codeSyntaxHighlighting => $composableBuilder(
    column: $table.codeSyntaxHighlighting,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get markdownRendering => $composableBuilder(
    column: $table.markdownRendering,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoNameConversations => $composableBuilder(
    column: $table.autoNameConversations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reduceMotion => $composableBuilder(
    column: $table.reduceMotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableNotifications => $composableBuilder(
    column: $table.enableNotifications,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyTaskCompletion => $composableBuilder(
    column: $table.notifyTaskCompletion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyDownloads => $composableBuilder(
    column: $table.notifyDownloads,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyReminders => $composableBuilder(
    column: $table.notifyReminders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get launchBehavior => $composableBuilder(
    column: $table.launchBehavior,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hapticFeedback => $composableBuilder(
    column: $table.hapticFeedback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundEffects => $composableBuilder(
    column: $table.soundEffects,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confirmBeforeDeleting => $composableBuilder(
    column: $table.confirmBeforeDeleting,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appLanguage => $composableBuilder(
    column: $table.appLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiLanguage => $composableBuilder(
    column: $table.aiLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get developerMode => $composableBuilder(
    column: $table.developerMode,
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
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageDensity => $composableBuilder(
    column: $table.messageDensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeModelId => $composableBuilder(
    column: $table.activeModelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseStyle => $composableBuilder(
    column: $table.responseStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reasoningMode => $composableBuilder(
    column: $table.reasoningMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get streamingTokens => $composableBuilder(
    column: $table.streamingTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get localAiOnly => $composableBuilder(
    column: $table.localAiOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowInternetForDownloads => $composableBuilder(
    column: $table.allowInternetForDownloads,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sendDiagnostics => $composableBuilder(
    column: $table.sendDiagnostics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get saveChatHistory => $composableBuilder(
    column: $table.saveChatHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoDeleteChats => $composableBuilder(
    column: $table.autoDeleteChats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bunjiMemory => $composableBuilder(
    column: $table.bunjiMemory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enterToSend => $composableBuilder(
    column: $table.enterToSend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showAiIndicator => $composableBuilder(
    column: $table.showAiIndicator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoScroll => $composableBuilder(
    column: $table.autoScroll,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get codeSyntaxHighlighting => $composableBuilder(
    column: $table.codeSyntaxHighlighting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get markdownRendering => $composableBuilder(
    column: $table.markdownRendering,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoNameConversations => $composableBuilder(
    column: $table.autoNameConversations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reduceMotion => $composableBuilder(
    column: $table.reduceMotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableNotifications => $composableBuilder(
    column: $table.enableNotifications,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyTaskCompletion => $composableBuilder(
    column: $table.notifyTaskCompletion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyDownloads => $composableBuilder(
    column: $table.notifyDownloads,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyReminders => $composableBuilder(
    column: $table.notifyReminders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get launchBehavior => $composableBuilder(
    column: $table.launchBehavior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hapticFeedback => $composableBuilder(
    column: $table.hapticFeedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundEffects => $composableBuilder(
    column: $table.soundEffects,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confirmBeforeDeleting => $composableBuilder(
    column: $table.confirmBeforeDeleting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appLanguage => $composableBuilder(
    column: $table.appLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiLanguage => $composableBuilder(
    column: $table.aiLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get developerMode => $composableBuilder(
    column: $table.developerMode,
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

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get messageDensity => $composableBuilder(
    column: $table.messageDensity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeModelId => $composableBuilder(
    column: $table.activeModelId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseStyle => $composableBuilder(
    column: $table.responseStyle,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reasoningMode => $composableBuilder(
    column: $table.reasoningMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get streamingTokens => $composableBuilder(
    column: $table.streamingTokens,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get localAiOnly => $composableBuilder(
    column: $table.localAiOnly,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowInternetForDownloads => $composableBuilder(
    column: $table.allowInternetForDownloads,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sendDiagnostics => $composableBuilder(
    column: $table.sendDiagnostics,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get saveChatHistory => $composableBuilder(
    column: $table.saveChatHistory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get autoDeleteChats => $composableBuilder(
    column: $table.autoDeleteChats,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bunjiMemory => $composableBuilder(
    column: $table.bunjiMemory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enterToSend => $composableBuilder(
    column: $table.enterToSend,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showAiIndicator => $composableBuilder(
    column: $table.showAiIndicator,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoScroll => $composableBuilder(
    column: $table.autoScroll,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get codeSyntaxHighlighting => $composableBuilder(
    column: $table.codeSyntaxHighlighting,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get markdownRendering => $composableBuilder(
    column: $table.markdownRendering,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoNameConversations => $composableBuilder(
    column: $table.autoNameConversations,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reduceMotion => $composableBuilder(
    column: $table.reduceMotion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableNotifications => $composableBuilder(
    column: $table.enableNotifications,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyTaskCompletion => $composableBuilder(
    column: $table.notifyTaskCompletion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyDownloads => $composableBuilder(
    column: $table.notifyDownloads,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyReminders => $composableBuilder(
    column: $table.notifyReminders,
    builder: (column) => column,
  );

  GeneratedColumn<String> get launchBehavior => $composableBuilder(
    column: $table.launchBehavior,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hapticFeedback => $composableBuilder(
    column: $table.hapticFeedback,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get soundEffects => $composableBuilder(
    column: $table.soundEffects,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get confirmBeforeDeleting => $composableBuilder(
    column: $table.confirmBeforeDeleting,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appLanguage => $composableBuilder(
    column: $table.appLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aiLanguage => $composableBuilder(
    column: $table.aiLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get developerMode => $composableBuilder(
    column: $table.developerMode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSetting,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSetting,
            BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
          ),
          UserSetting,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> messageDensity = const Value.absent(),
                Value<String> activeModelId = const Value.absent(),
                Value<String> responseStyle = const Value.absent(),
                Value<bool> reasoningMode = const Value.absent(),
                Value<bool> streamingTokens = const Value.absent(),
                Value<bool> localAiOnly = const Value.absent(),
                Value<bool> allowInternetForDownloads = const Value.absent(),
                Value<bool> sendDiagnostics = const Value.absent(),
                Value<bool> saveChatHistory = const Value.absent(),
                Value<String> autoDeleteChats = const Value.absent(),
                Value<bool> bunjiMemory = const Value.absent(),
                Value<bool> enterToSend = const Value.absent(),
                Value<bool> showAiIndicator = const Value.absent(),
                Value<bool> autoScroll = const Value.absent(),
                Value<bool> codeSyntaxHighlighting = const Value.absent(),
                Value<bool> markdownRendering = const Value.absent(),
                Value<bool> autoNameConversations = const Value.absent(),
                Value<bool> reduceMotion = const Value.absent(),
                Value<bool> enableNotifications = const Value.absent(),
                Value<bool> notifyTaskCompletion = const Value.absent(),
                Value<bool> notifyDownloads = const Value.absent(),
                Value<bool> notifyReminders = const Value.absent(),
                Value<String> launchBehavior = const Value.absent(),
                Value<bool> hapticFeedback = const Value.absent(),
                Value<bool> soundEffects = const Value.absent(),
                Value<bool> confirmBeforeDeleting = const Value.absent(),
                Value<String> appLanguage = const Value.absent(),
                Value<String> aiLanguage = const Value.absent(),
                Value<bool> developerMode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(
                id: id,
                themeMode: themeMode,
                messageDensity: messageDensity,
                activeModelId: activeModelId,
                responseStyle: responseStyle,
                reasoningMode: reasoningMode,
                streamingTokens: streamingTokens,
                localAiOnly: localAiOnly,
                allowInternetForDownloads: allowInternetForDownloads,
                sendDiagnostics: sendDiagnostics,
                saveChatHistory: saveChatHistory,
                autoDeleteChats: autoDeleteChats,
                bunjiMemory: bunjiMemory,
                enterToSend: enterToSend,
                showAiIndicator: showAiIndicator,
                autoScroll: autoScroll,
                codeSyntaxHighlighting: codeSyntaxHighlighting,
                markdownRendering: markdownRendering,
                autoNameConversations: autoNameConversations,
                reduceMotion: reduceMotion,
                enableNotifications: enableNotifications,
                notifyTaskCompletion: notifyTaskCompletion,
                notifyDownloads: notifyDownloads,
                notifyReminders: notifyReminders,
                launchBehavior: launchBehavior,
                hapticFeedback: hapticFeedback,
                soundEffects: soundEffects,
                confirmBeforeDeleting: confirmBeforeDeleting,
                appLanguage: appLanguage,
                aiLanguage: aiLanguage,
                developerMode: developerMode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> themeMode = const Value.absent(),
                Value<String> messageDensity = const Value.absent(),
                Value<String> activeModelId = const Value.absent(),
                Value<String> responseStyle = const Value.absent(),
                Value<bool> reasoningMode = const Value.absent(),
                Value<bool> streamingTokens = const Value.absent(),
                Value<bool> localAiOnly = const Value.absent(),
                Value<bool> allowInternetForDownloads = const Value.absent(),
                Value<bool> sendDiagnostics = const Value.absent(),
                Value<bool> saveChatHistory = const Value.absent(),
                Value<String> autoDeleteChats = const Value.absent(),
                Value<bool> bunjiMemory = const Value.absent(),
                Value<bool> enterToSend = const Value.absent(),
                Value<bool> showAiIndicator = const Value.absent(),
                Value<bool> autoScroll = const Value.absent(),
                Value<bool> codeSyntaxHighlighting = const Value.absent(),
                Value<bool> markdownRendering = const Value.absent(),
                Value<bool> autoNameConversations = const Value.absent(),
                Value<bool> reduceMotion = const Value.absent(),
                Value<bool> enableNotifications = const Value.absent(),
                Value<bool> notifyTaskCompletion = const Value.absent(),
                Value<bool> notifyDownloads = const Value.absent(),
                Value<bool> notifyReminders = const Value.absent(),
                Value<String> launchBehavior = const Value.absent(),
                Value<bool> hapticFeedback = const Value.absent(),
                Value<bool> soundEffects = const Value.absent(),
                Value<bool> confirmBeforeDeleting = const Value.absent(),
                Value<String> appLanguage = const Value.absent(),
                Value<String> aiLanguage = const Value.absent(),
                Value<bool> developerMode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                id: id,
                themeMode: themeMode,
                messageDensity: messageDensity,
                activeModelId: activeModelId,
                responseStyle: responseStyle,
                reasoningMode: reasoningMode,
                streamingTokens: streamingTokens,
                localAiOnly: localAiOnly,
                allowInternetForDownloads: allowInternetForDownloads,
                sendDiagnostics: sendDiagnostics,
                saveChatHistory: saveChatHistory,
                autoDeleteChats: autoDeleteChats,
                bunjiMemory: bunjiMemory,
                enterToSend: enterToSend,
                showAiIndicator: showAiIndicator,
                autoScroll: autoScroll,
                codeSyntaxHighlighting: codeSyntaxHighlighting,
                markdownRendering: markdownRendering,
                autoNameConversations: autoNameConversations,
                reduceMotion: reduceMotion,
                enableNotifications: enableNotifications,
                notifyTaskCompletion: notifyTaskCompletion,
                notifyDownloads: notifyDownloads,
                notifyReminders: notifyReminders,
                launchBehavior: launchBehavior,
                hapticFeedback: hapticFeedback,
                soundEffects: soundEffects,
                confirmBeforeDeleting: confirmBeforeDeleting,
                appLanguage: appLanguage,
                aiLanguage: aiLanguage,
                developerMode: developerMode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserSettingsTable, UserSetting>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserSettingsTable,
                    UserSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSetting,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSetting,
        BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
      ),
      UserSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$UserAiModelsTableTableManager get userAiModels =>
      $$UserAiModelsTableTableManager(_db, _db.userAiModels);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
}
