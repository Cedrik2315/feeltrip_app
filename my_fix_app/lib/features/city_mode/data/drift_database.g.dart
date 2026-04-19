// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $HitosTable extends Hitos with TableInfo<$HitosTable, Hito> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HitosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _radioMeta = const VerificationMeta('radio');
  @override
  late final GeneratedColumn<double> radio = GeneratedColumn<double>(
      'radio', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(50.0));
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
      'titulo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descripcionCortaMeta =
      const VerificationMeta('descripcionCorta');
  @override
  late final GeneratedColumn<String> descripcionCorta = GeneratedColumn<String>(
      'descripcion_corta', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _audioPathMeta =
      const VerificationMeta('audioPath');
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
      'audio_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _filtroMapaStyleMeta =
      const VerificationMeta('filtroMapaStyle');
  @override
  late final GeneratedColumn<String> filtroMapaStyle = GeneratedColumn<String>(
      'filtro_mapa_style', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descubiertoMeta =
      const VerificationMeta('descubierto');
  @override
  late final GeneratedColumn<bool> descubierto = GeneratedColumn<bool>(
      'descubierto', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("descubierto" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _puntosRecompensaMeta =
      const VerificationMeta('puntosRecompensa');
  @override
  late final GeneratedColumn<int> puntosRecompensa = GeneratedColumn<int>(
      'puntos_recompensa', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _categoriaMeta =
      const VerificationMeta('categoria');
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
      'categoria', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        lat,
        lng,
        radio,
        titulo,
        descripcionCorta,
        audioPath,
        imagePath,
        filtroMapaStyle,
        descubierto,
        puntosRecompensa,
        categoria
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hitos';
  @override
  VerificationContext validateIntegrity(Insertable<Hito> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('radio')) {
      context.handle(
          _radioMeta, radio.isAcceptableOrUnknown(data['radio']!, _radioMeta));
    }
    if (data.containsKey('titulo')) {
      context.handle(_tituloMeta,
          titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta));
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('descripcion_corta')) {
      context.handle(
          _descripcionCortaMeta,
          descripcionCorta.isAcceptableOrUnknown(
              data['descripcion_corta']!, _descripcionCortaMeta));
    } else if (isInserting) {
      context.missing(_descripcionCortaMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(_audioPathMeta,
          audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('filtro_mapa_style')) {
      context.handle(
          _filtroMapaStyleMeta,
          filtroMapaStyle.isAcceptableOrUnknown(
              data['filtro_mapa_style']!, _filtroMapaStyleMeta));
    }
    if (data.containsKey('descubierto')) {
      context.handle(
          _descubiertoMeta,
          descubierto.isAcceptableOrUnknown(
              data['descubierto']!, _descubiertoMeta));
    }
    if (data.containsKey('puntos_recompensa')) {
      context.handle(
          _puntosRecompensaMeta,
          puntosRecompensa.isAcceptableOrUnknown(
              data['puntos_recompensa']!, _puntosRecompensaMeta));
    }
    if (data.containsKey('categoria')) {
      context.handle(_categoriaMeta,
          categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta));
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Hito map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Hito(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      radio: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}radio'])!,
      titulo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}titulo'])!,
      descripcionCorta: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}descripcion_corta'])!,
      audioPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_path']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      filtroMapaStyle: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}filtro_mapa_style']),
      descubierto: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}descubierto'])!,
      puntosRecompensa: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}puntos_recompensa'])!,
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria'])!,
    );
  }

  @override
  $HitosTable createAlias(String alias) {
    return $HitosTable(attachedDatabase, alias);
  }
}

class Hito extends DataClass implements Insertable<Hito> {
  final String id;
  final double lat;
  final double lng;
  final double radio;
  final String titulo;
  final String descripcionCorta;
  final String? audioPath;
  final String? imagePath;
  final String? filtroMapaStyle;
  final bool descubierto;
  final int puntosRecompensa;
  final String categoria;
  const Hito(
      {required this.id,
      required this.lat,
      required this.lng,
      required this.radio,
      required this.titulo,
      required this.descripcionCorta,
      this.audioPath,
      this.imagePath,
      this.filtroMapaStyle,
      required this.descubierto,
      required this.puntosRecompensa,
      required this.categoria});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['radio'] = Variable<double>(radio);
    map['titulo'] = Variable<String>(titulo);
    map['descripcion_corta'] = Variable<String>(descripcionCorta);
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || filtroMapaStyle != null) {
      map['filtro_mapa_style'] = Variable<String>(filtroMapaStyle);
    }
    map['descubierto'] = Variable<bool>(descubierto);
    map['puntos_recompensa'] = Variable<int>(puntosRecompensa);
    map['categoria'] = Variable<String>(categoria);
    return map;
  }

  HitosCompanion toCompanion(bool nullToAbsent) {
    return HitosCompanion(
      id: Value(id),
      lat: Value(lat),
      lng: Value(lng),
      radio: Value(radio),
      titulo: Value(titulo),
      descripcionCorta: Value(descripcionCorta),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      filtroMapaStyle: filtroMapaStyle == null && nullToAbsent
          ? const Value.absent()
          : Value(filtroMapaStyle),
      descubierto: Value(descubierto),
      puntosRecompensa: Value(puntosRecompensa),
      categoria: Value(categoria),
    );
  }

  factory Hito.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Hito(
      id: serializer.fromJson<String>(json['id']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      radio: serializer.fromJson<double>(json['radio']),
      titulo: serializer.fromJson<String>(json['titulo']),
      descripcionCorta: serializer.fromJson<String>(json['descripcionCorta']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      filtroMapaStyle: serializer.fromJson<String?>(json['filtroMapaStyle']),
      descubierto: serializer.fromJson<bool>(json['descubierto']),
      puntosRecompensa: serializer.fromJson<int>(json['puntosRecompensa']),
      categoria: serializer.fromJson<String>(json['categoria']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'radio': serializer.toJson<double>(radio),
      'titulo': serializer.toJson<String>(titulo),
      'descripcionCorta': serializer.toJson<String>(descripcionCorta),
      'audioPath': serializer.toJson<String?>(audioPath),
      'imagePath': serializer.toJson<String?>(imagePath),
      'filtroMapaStyle': serializer.toJson<String?>(filtroMapaStyle),
      'descubierto': serializer.toJson<bool>(descubierto),
      'puntosRecompensa': serializer.toJson<int>(puntosRecompensa),
      'categoria': serializer.toJson<String>(categoria),
    };
  }

  Hito copyWith(
          {String? id,
          double? lat,
          double? lng,
          double? radio,
          String? titulo,
          String? descripcionCorta,
          Value<String?> audioPath = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          Value<String?> filtroMapaStyle = const Value.absent(),
          bool? descubierto,
          int? puntosRecompensa,
          String? categoria}) =>
      Hito(
        id: id ?? this.id,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        radio: radio ?? this.radio,
        titulo: titulo ?? this.titulo,
        descripcionCorta: descripcionCorta ?? this.descripcionCorta,
        audioPath: audioPath.present ? audioPath.value : this.audioPath,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        filtroMapaStyle: filtroMapaStyle.present
            ? filtroMapaStyle.value
            : this.filtroMapaStyle,
        descubierto: descubierto ?? this.descubierto,
        puntosRecompensa: puntosRecompensa ?? this.puntosRecompensa,
        categoria: categoria ?? this.categoria,
      );
  @override
  String toString() {
    return (StringBuffer('Hito(')
          ..write('id: $id, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('radio: $radio, ')
          ..write('titulo: $titulo, ')
          ..write('descripcionCorta: $descripcionCorta, ')
          ..write('audioPath: $audioPath, ')
          ..write('imagePath: $imagePath, ')
          ..write('filtroMapaStyle: $filtroMapaStyle, ')
          ..write('descubierto: $descubierto, ')
          ..write('puntosRecompensa: $puntosRecompensa, ')
          ..write('categoria: $categoria')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      lat,
      lng,
      radio,
      titulo,
      descripcionCorta,
      audioPath,
      imagePath,
      filtroMapaStyle,
      descubierto,
      puntosRecompensa,
      categoria);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Hito &&
          other.id == this.id &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.radio == this.radio &&
          other.titulo == this.titulo &&
          other.descripcionCorta == this.descripcionCorta &&
          other.audioPath == this.audioPath &&
          other.imagePath == this.imagePath &&
          other.filtroMapaStyle == this.filtroMapaStyle &&
          other.descubierto == this.descubierto &&
          other.puntosRecompensa == this.puntosRecompensa &&
          other.categoria == this.categoria);
}

class HitosCompanion extends UpdateCompanion<Hito> {
  final Value<String> id;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double> radio;
  final Value<String> titulo;
  final Value<String> descripcionCorta;
  final Value<String?> audioPath;
  final Value<String?> imagePath;
  final Value<String?> filtroMapaStyle;
  final Value<bool> descubierto;
  final Value<int> puntosRecompensa;
  final Value<String> categoria;
  final Value<int> rowid;
  const HitosCompanion({
    this.id = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.radio = const Value.absent(),
    this.titulo = const Value.absent(),
    this.descripcionCorta = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.filtroMapaStyle = const Value.absent(),
    this.descubierto = const Value.absent(),
    this.puntosRecompensa = const Value.absent(),
    this.categoria = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HitosCompanion.insert({
    required String id,
    required double lat,
    required double lng,
    this.radio = const Value.absent(),
    required String titulo,
    required String descripcionCorta,
    this.audioPath = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.filtroMapaStyle = const Value.absent(),
    this.descubierto = const Value.absent(),
    this.puntosRecompensa = const Value.absent(),
    required String categoria,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        lat = Value(lat),
        lng = Value(lng),
        titulo = Value(titulo),
        descripcionCorta = Value(descripcionCorta),
        categoria = Value(categoria);
  static Insertable<Hito> custom({
    Expression<String>? id,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? radio,
    Expression<String>? titulo,
    Expression<String>? descripcionCorta,
    Expression<String>? audioPath,
    Expression<String>? imagePath,
    Expression<String>? filtroMapaStyle,
    Expression<bool>? descubierto,
    Expression<int>? puntosRecompensa,
    Expression<String>? categoria,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (radio != null) 'radio': radio,
      if (titulo != null) 'titulo': titulo,
      if (descripcionCorta != null) 'descripcion_corta': descripcionCorta,
      if (audioPath != null) 'audio_path': audioPath,
      if (imagePath != null) 'image_path': imagePath,
      if (filtroMapaStyle != null) 'filtro_mapa_style': filtroMapaStyle,
      if (descubierto != null) 'descubierto': descubierto,
      if (puntosRecompensa != null) 'puntos_recompensa': puntosRecompensa,
      if (categoria != null) 'categoria': categoria,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HitosCompanion copyWith(
      {Value<String>? id,
      Value<double>? lat,
      Value<double>? lng,
      Value<double>? radio,
      Value<String>? titulo,
      Value<String>? descripcionCorta,
      Value<String?>? audioPath,
      Value<String?>? imagePath,
      Value<String?>? filtroMapaStyle,
      Value<bool>? descubierto,
      Value<int>? puntosRecompensa,
      Value<String>? categoria,
      Value<int>? rowid}) {
    return HitosCompanion(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radio: radio ?? this.radio,
      titulo: titulo ?? this.titulo,
      descripcionCorta: descripcionCorta ?? this.descripcionCorta,
      audioPath: audioPath ?? this.audioPath,
      imagePath: imagePath ?? this.imagePath,
      filtroMapaStyle: filtroMapaStyle ?? this.filtroMapaStyle,
      descubierto: descubierto ?? this.descubierto,
      puntosRecompensa: puntosRecompensa ?? this.puntosRecompensa,
      categoria: categoria ?? this.categoria,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (radio.present) {
      map['radio'] = Variable<double>(radio.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (descripcionCorta.present) {
      map['descripcion_corta'] = Variable<String>(descripcionCorta.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (filtroMapaStyle.present) {
      map['filtro_mapa_style'] = Variable<String>(filtroMapaStyle.value);
    }
    if (descubierto.present) {
      map['descubierto'] = Variable<bool>(descubierto.value);
    }
    if (puntosRecompensa.present) {
      map['puntos_recompensa'] = Variable<int>(puntosRecompensa.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HitosCompanion(')
          ..write('id: $id, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('radio: $radio, ')
          ..write('titulo: $titulo, ')
          ..write('descripcionCorta: $descripcionCorta, ')
          ..write('audioPath: $audioPath, ')
          ..write('imagePath: $imagePath, ')
          ..write('filtroMapaStyle: $filtroMapaStyle, ')
          ..write('descubierto: $descubierto, ')
          ..write('puntosRecompensa: $puntosRecompensa, ')
          ..write('categoria: $categoria, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AportesUsuariosTable extends AportesUsuarios
    with TableInfo<$AportesUsuariosTable, AportesUsuario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AportesUsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _hitoIdMeta = const VerificationMeta('hitoId');
  @override
  late final GeneratedColumn<String> hitoId = GeneratedColumn<String>(
      'hito_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES hitos (id)'));
  static const VerificationMeta _comentarioMeta =
      const VerificationMeta('comentario');
  @override
  late final GeneratedColumn<String> comentario = GeneratedColumn<String>(
      'comentario', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
      'fecha', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _fotoLocalPathMeta =
      const VerificationMeta('fotoLocalPath');
  @override
  late final GeneratedColumn<String> fotoLocalPath = GeneratedColumn<String>(
      'foto_local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _condicionTemporalMeta =
      const VerificationMeta('condicionTemporal');
  @override
  late final GeneratedColumn<String> condicionTemporal =
      GeneratedColumn<String>('condicion_temporal', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, hitoId, comentario, fecha, fotoLocalPath, condicionTemporal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aportes_usuarios';
  @override
  VerificationContext validateIntegrity(Insertable<AportesUsuario> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hito_id')) {
      context.handle(_hitoIdMeta,
          hitoId.isAcceptableOrUnknown(data['hito_id']!, _hitoIdMeta));
    } else if (isInserting) {
      context.missing(_hitoIdMeta);
    }
    if (data.containsKey('comentario')) {
      context.handle(
          _comentarioMeta,
          comentario.isAcceptableOrUnknown(
              data['comentario']!, _comentarioMeta));
    } else if (isInserting) {
      context.missing(_comentarioMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    }
    if (data.containsKey('foto_local_path')) {
      context.handle(
          _fotoLocalPathMeta,
          fotoLocalPath.isAcceptableOrUnknown(
              data['foto_local_path']!, _fotoLocalPathMeta));
    }
    if (data.containsKey('condicion_temporal')) {
      context.handle(
          _condicionTemporalMeta,
          condicionTemporal.isAcceptableOrUnknown(
              data['condicion_temporal']!, _condicionTemporalMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AportesUsuario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AportesUsuario(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      hitoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hito_id'])!,
      comentario: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comentario'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha'])!,
      fotoLocalPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}foto_local_path']),
      condicionTemporal: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}condicion_temporal']),
    );
  }

  @override
  $AportesUsuariosTable createAlias(String alias) {
    return $AportesUsuariosTable(attachedDatabase, alias);
  }
}

class AportesUsuario extends DataClass implements Insertable<AportesUsuario> {
  final int id;
  final String hitoId;
  final String comentario;
  final DateTime fecha;
  final String? fotoLocalPath;
  final String? condicionTemporal;
  const AportesUsuario(
      {required this.id,
      required this.hitoId,
      required this.comentario,
      required this.fecha,
      this.fotoLocalPath,
      this.condicionTemporal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['hito_id'] = Variable<String>(hitoId);
    map['comentario'] = Variable<String>(comentario);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || fotoLocalPath != null) {
      map['foto_local_path'] = Variable<String>(fotoLocalPath);
    }
    if (!nullToAbsent || condicionTemporal != null) {
      map['condicion_temporal'] = Variable<String>(condicionTemporal);
    }
    return map;
  }

  AportesUsuariosCompanion toCompanion(bool nullToAbsent) {
    return AportesUsuariosCompanion(
      id: Value(id),
      hitoId: Value(hitoId),
      comentario: Value(comentario),
      fecha: Value(fecha),
      fotoLocalPath: fotoLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoLocalPath),
      condicionTemporal: condicionTemporal == null && nullToAbsent
          ? const Value.absent()
          : Value(condicionTemporal),
    );
  }

  factory AportesUsuario.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AportesUsuario(
      id: serializer.fromJson<int>(json['id']),
      hitoId: serializer.fromJson<String>(json['hitoId']),
      comentario: serializer.fromJson<String>(json['comentario']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      fotoLocalPath: serializer.fromJson<String?>(json['fotoLocalPath']),
      condicionTemporal:
          serializer.fromJson<String?>(json['condicionTemporal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'hitoId': serializer.toJson<String>(hitoId),
      'comentario': serializer.toJson<String>(comentario),
      'fecha': serializer.toJson<DateTime>(fecha),
      'fotoLocalPath': serializer.toJson<String?>(fotoLocalPath),
      'condicionTemporal': serializer.toJson<String?>(condicionTemporal),
    };
  }

  AportesUsuario copyWith(
          {int? id,
          String? hitoId,
          String? comentario,
          DateTime? fecha,
          Value<String?> fotoLocalPath = const Value.absent(),
          Value<String?> condicionTemporal = const Value.absent()}) =>
      AportesUsuario(
        id: id ?? this.id,
        hitoId: hitoId ?? this.hitoId,
        comentario: comentario ?? this.comentario,
        fecha: fecha ?? this.fecha,
        fotoLocalPath:
            fotoLocalPath.present ? fotoLocalPath.value : this.fotoLocalPath,
        condicionTemporal: condicionTemporal.present
            ? condicionTemporal.value
            : this.condicionTemporal,
      );
  @override
  String toString() {
    return (StringBuffer('AportesUsuario(')
          ..write('id: $id, ')
          ..write('hitoId: $hitoId, ')
          ..write('comentario: $comentario, ')
          ..write('fecha: $fecha, ')
          ..write('fotoLocalPath: $fotoLocalPath, ')
          ..write('condicionTemporal: $condicionTemporal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, hitoId, comentario, fecha, fotoLocalPath, condicionTemporal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AportesUsuario &&
          other.id == this.id &&
          other.hitoId == this.hitoId &&
          other.comentario == this.comentario &&
          other.fecha == this.fecha &&
          other.fotoLocalPath == this.fotoLocalPath &&
          other.condicionTemporal == this.condicionTemporal);
}

class AportesUsuariosCompanion extends UpdateCompanion<AportesUsuario> {
  final Value<int> id;
  final Value<String> hitoId;
  final Value<String> comentario;
  final Value<DateTime> fecha;
  final Value<String?> fotoLocalPath;
  final Value<String?> condicionTemporal;
  const AportesUsuariosCompanion({
    this.id = const Value.absent(),
    this.hitoId = const Value.absent(),
    this.comentario = const Value.absent(),
    this.fecha = const Value.absent(),
    this.fotoLocalPath = const Value.absent(),
    this.condicionTemporal = const Value.absent(),
  });
  AportesUsuariosCompanion.insert({
    this.id = const Value.absent(),
    required String hitoId,
    required String comentario,
    this.fecha = const Value.absent(),
    this.fotoLocalPath = const Value.absent(),
    this.condicionTemporal = const Value.absent(),
  })  : hitoId = Value(hitoId),
        comentario = Value(comentario);
  static Insertable<AportesUsuario> custom({
    Expression<int>? id,
    Expression<String>? hitoId,
    Expression<String>? comentario,
    Expression<DateTime>? fecha,
    Expression<String>? fotoLocalPath,
    Expression<String>? condicionTemporal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hitoId != null) 'hito_id': hitoId,
      if (comentario != null) 'comentario': comentario,
      if (fecha != null) 'fecha': fecha,
      if (fotoLocalPath != null) 'foto_local_path': fotoLocalPath,
      if (condicionTemporal != null) 'condicion_temporal': condicionTemporal,
    });
  }

  AportesUsuariosCompanion copyWith(
      {Value<int>? id,
      Value<String>? hitoId,
      Value<String>? comentario,
      Value<DateTime>? fecha,
      Value<String?>? fotoLocalPath,
      Value<String?>? condicionTemporal}) {
    return AportesUsuariosCompanion(
      id: id ?? this.id,
      hitoId: hitoId ?? this.hitoId,
      comentario: comentario ?? this.comentario,
      fecha: fecha ?? this.fecha,
      fotoLocalPath: fotoLocalPath ?? this.fotoLocalPath,
      condicionTemporal: condicionTemporal ?? this.condicionTemporal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (hitoId.present) {
      map['hito_id'] = Variable<String>(hitoId.value);
    }
    if (comentario.present) {
      map['comentario'] = Variable<String>(comentario.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (fotoLocalPath.present) {
      map['foto_local_path'] = Variable<String>(fotoLocalPath.value);
    }
    if (condicionTemporal.present) {
      map['condicion_temporal'] = Variable<String>(condicionTemporal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AportesUsuariosCompanion(')
          ..write('id: $id, ')
          ..write('hitoId: $hitoId, ')
          ..write('comentario: $comentario, ')
          ..write('fecha: $fecha, ')
          ..write('fotoLocalPath: $fotoLocalPath, ')
          ..write('condicionTemporal: $condicionTemporal')
          ..write(')'))
        .toString();
  }
}

class $ViajesTable extends Viajes with TableInfo<$ViajesTable, Viaje> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ViajesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _moodMusicalMeta =
      const VerificationMeta('moodMusical');
  @override
  late final GeneratedColumn<String> moodMusical = GeneratedColumn<String>(
      'mood_musical', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cancionGeneradaPathMeta =
      const VerificationMeta('cancionGeneradaPath');
  @override
  late final GeneratedColumn<String> cancionGeneradaPath =
      GeneratedColumn<String>('cancion_generada_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _artifactDesignPathMeta =
      const VerificationMeta('artifactDesignPath');
  @override
  late final GeneratedColumn<String> artifactDesignPath =
      GeneratedColumn<String>('artifact_design_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hasPurchasedArtifactMeta =
      const VerificationMeta('hasPurchasedArtifact');
  @override
  late final GeneratedColumn<bool> hasPurchasedArtifact = GeneratedColumn<bool>(
      'has_purchased_artifact', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_purchased_artifact" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fechaViajeMeta =
      const VerificationMeta('fechaViaje');
  @override
  late final GeneratedColumn<DateTime> fechaViaje = GeneratedColumn<DateTime>(
      'fecha_viaje', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nombre,
        moodMusical,
        cancionGeneradaPath,
        artifactDesignPath,
        hasPurchasedArtifact,
        fechaViaje
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'viajes';
  @override
  VerificationContext validateIntegrity(Insertable<Viaje> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('mood_musical')) {
      context.handle(
          _moodMusicalMeta,
          moodMusical.isAcceptableOrUnknown(
              data['mood_musical']!, _moodMusicalMeta));
    }
    if (data.containsKey('cancion_generada_path')) {
      context.handle(
          _cancionGeneradaPathMeta,
          cancionGeneradaPath.isAcceptableOrUnknown(
              data['cancion_generada_path']!, _cancionGeneradaPathMeta));
    }
    if (data.containsKey('artifact_design_path')) {
      context.handle(
          _artifactDesignPathMeta,
          artifactDesignPath.isAcceptableOrUnknown(
              data['artifact_design_path']!, _artifactDesignPathMeta));
    }
    if (data.containsKey('has_purchased_artifact')) {
      context.handle(
          _hasPurchasedArtifactMeta,
          hasPurchasedArtifact.isAcceptableOrUnknown(
              data['has_purchased_artifact']!, _hasPurchasedArtifactMeta));
    }
    if (data.containsKey('fecha_viaje')) {
      context.handle(
          _fechaViajeMeta,
          fechaViaje.isAcceptableOrUnknown(
              data['fecha_viaje']!, _fechaViajeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Viaje map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Viaje(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      moodMusical: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood_musical']),
      cancionGeneradaPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cancion_generada_path']),
      artifactDesignPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}artifact_design_path']),
      hasPurchasedArtifact: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}has_purchased_artifact'])!,
      fechaViaje: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha_viaje'])!,
    );
  }

  @override
  $ViajesTable createAlias(String alias) {
    return $ViajesTable(attachedDatabase, alias);
  }
}

class Viaje extends DataClass implements Insertable<Viaje> {
  final int id;
  final String nombre;
  final String? moodMusical;
  final String? cancionGeneradaPath;
  final String? artifactDesignPath;
  final bool hasPurchasedArtifact;
  final DateTime fechaViaje;
  const Viaje(
      {required this.id,
      required this.nombre,
      this.moodMusical,
      this.cancionGeneradaPath,
      this.artifactDesignPath,
      required this.hasPurchasedArtifact,
      required this.fechaViaje});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || moodMusical != null) {
      map['mood_musical'] = Variable<String>(moodMusical);
    }
    if (!nullToAbsent || cancionGeneradaPath != null) {
      map['cancion_generada_path'] = Variable<String>(cancionGeneradaPath);
    }
    if (!nullToAbsent || artifactDesignPath != null) {
      map['artifact_design_path'] = Variable<String>(artifactDesignPath);
    }
    map['has_purchased_artifact'] = Variable<bool>(hasPurchasedArtifact);
    map['fecha_viaje'] = Variable<DateTime>(fechaViaje);
    return map;
  }

  ViajesCompanion toCompanion(bool nullToAbsent) {
    return ViajesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      moodMusical: moodMusical == null && nullToAbsent
          ? const Value.absent()
          : Value(moodMusical),
      cancionGeneradaPath: cancionGeneradaPath == null && nullToAbsent
          ? const Value.absent()
          : Value(cancionGeneradaPath),
      artifactDesignPath: artifactDesignPath == null && nullToAbsent
          ? const Value.absent()
          : Value(artifactDesignPath),
      hasPurchasedArtifact: Value(hasPurchasedArtifact),
      fechaViaje: Value(fechaViaje),
    );
  }

  factory Viaje.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Viaje(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      moodMusical: serializer.fromJson<String?>(json['moodMusical']),
      cancionGeneradaPath:
          serializer.fromJson<String?>(json['cancionGeneradaPath']),
      artifactDesignPath:
          serializer.fromJson<String?>(json['artifactDesignPath']),
      hasPurchasedArtifact:
          serializer.fromJson<bool>(json['hasPurchasedArtifact']),
      fechaViaje: serializer.fromJson<DateTime>(json['fechaViaje']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'moodMusical': serializer.toJson<String?>(moodMusical),
      'cancionGeneradaPath': serializer.toJson<String?>(cancionGeneradaPath),
      'artifactDesignPath': serializer.toJson<String?>(artifactDesignPath),
      'hasPurchasedArtifact': serializer.toJson<bool>(hasPurchasedArtifact),
      'fechaViaje': serializer.toJson<DateTime>(fechaViaje),
    };
  }

  Viaje copyWith(
          {int? id,
          String? nombre,
          Value<String?> moodMusical = const Value.absent(),
          Value<String?> cancionGeneradaPath = const Value.absent(),
          Value<String?> artifactDesignPath = const Value.absent(),
          bool? hasPurchasedArtifact,
          DateTime? fechaViaje}) =>
      Viaje(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        moodMusical: moodMusical.present ? moodMusical.value : this.moodMusical,
        cancionGeneradaPath: cancionGeneradaPath.present
            ? cancionGeneradaPath.value
            : this.cancionGeneradaPath,
        artifactDesignPath: artifactDesignPath.present
            ? artifactDesignPath.value
            : this.artifactDesignPath,
        hasPurchasedArtifact: hasPurchasedArtifact ?? this.hasPurchasedArtifact,
        fechaViaje: fechaViaje ?? this.fechaViaje,
      );
  @override
  String toString() {
    return (StringBuffer('Viaje(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('moodMusical: $moodMusical, ')
          ..write('cancionGeneradaPath: $cancionGeneradaPath, ')
          ..write('artifactDesignPath: $artifactDesignPath, ')
          ..write('hasPurchasedArtifact: $hasPurchasedArtifact, ')
          ..write('fechaViaje: $fechaViaje')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, moodMusical, cancionGeneradaPath,
      artifactDesignPath, hasPurchasedArtifact, fechaViaje);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Viaje &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.moodMusical == this.moodMusical &&
          other.cancionGeneradaPath == this.cancionGeneradaPath &&
          other.artifactDesignPath == this.artifactDesignPath &&
          other.hasPurchasedArtifact == this.hasPurchasedArtifact &&
          other.fechaViaje == this.fechaViaje);
}

class ViajesCompanion extends UpdateCompanion<Viaje> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> moodMusical;
  final Value<String?> cancionGeneradaPath;
  final Value<String?> artifactDesignPath;
  final Value<bool> hasPurchasedArtifact;
  final Value<DateTime> fechaViaje;
  const ViajesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.moodMusical = const Value.absent(),
    this.cancionGeneradaPath = const Value.absent(),
    this.artifactDesignPath = const Value.absent(),
    this.hasPurchasedArtifact = const Value.absent(),
    this.fechaViaje = const Value.absent(),
  });
  ViajesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.moodMusical = const Value.absent(),
    this.cancionGeneradaPath = const Value.absent(),
    this.artifactDesignPath = const Value.absent(),
    this.hasPurchasedArtifact = const Value.absent(),
    this.fechaViaje = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Viaje> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? moodMusical,
    Expression<String>? cancionGeneradaPath,
    Expression<String>? artifactDesignPath,
    Expression<bool>? hasPurchasedArtifact,
    Expression<DateTime>? fechaViaje,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (moodMusical != null) 'mood_musical': moodMusical,
      if (cancionGeneradaPath != null)
        'cancion_generada_path': cancionGeneradaPath,
      if (artifactDesignPath != null)
        'artifact_design_path': artifactDesignPath,
      if (hasPurchasedArtifact != null)
        'has_purchased_artifact': hasPurchasedArtifact,
      if (fechaViaje != null) 'fecha_viaje': fechaViaje,
    });
  }

  ViajesCompanion copyWith(
      {Value<int>? id,
      Value<String>? nombre,
      Value<String?>? moodMusical,
      Value<String?>? cancionGeneradaPath,
      Value<String?>? artifactDesignPath,
      Value<bool>? hasPurchasedArtifact,
      Value<DateTime>? fechaViaje}) {
    return ViajesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      moodMusical: moodMusical ?? this.moodMusical,
      cancionGeneradaPath: cancionGeneradaPath ?? this.cancionGeneradaPath,
      artifactDesignPath: artifactDesignPath ?? this.artifactDesignPath,
      hasPurchasedArtifact: hasPurchasedArtifact ?? this.hasPurchasedArtifact,
      fechaViaje: fechaViaje ?? this.fechaViaje,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (moodMusical.present) {
      map['mood_musical'] = Variable<String>(moodMusical.value);
    }
    if (cancionGeneradaPath.present) {
      map['cancion_generada_path'] =
          Variable<String>(cancionGeneradaPath.value);
    }
    if (artifactDesignPath.present) {
      map['artifact_design_path'] = Variable<String>(artifactDesignPath.value);
    }
    if (hasPurchasedArtifact.present) {
      map['has_purchased_artifact'] =
          Variable<bool>(hasPurchasedArtifact.value);
    }
    if (fechaViaje.present) {
      map['fecha_viaje'] = Variable<DateTime>(fechaViaje.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ViajesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('moodMusical: $moodMusical, ')
          ..write('cancionGeneradaPath: $cancionGeneradaPath, ')
          ..write('artifactDesignPath: $artifactDesignPath, ')
          ..write('hasPurchasedArtifact: $hasPurchasedArtifact, ')
          ..write('fechaViaje: $fechaViaje')
          ..write(')'))
        .toString();
  }
}

class $AnomaliasEmocionalesTable extends AnomaliasEmocionales
    with TableInfo<$AnomaliasEmocionalesTable, AnomaliasEmocionale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnomaliasEmocionalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _tipoEmocionMeta =
      const VerificationMeta('tipoEmocion');
  @override
  late final GeneratedColumn<String> tipoEmocion = GeneratedColumn<String>(
      'tipo_emocion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _intensidadHrvMeta =
      const VerificationMeta('intensidadHrv');
  @override
  late final GeneratedColumn<int> intensidadHrv = GeneratedColumn<int>(
      'intensidad_hrv', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _audioAmbientalPathMeta =
      const VerificationMeta('audioAmbientalPath');
  @override
  late final GeneratedColumn<String> audioAmbientalPath =
      GeneratedColumn<String>('audio_ambiental_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaDeteccionMeta =
      const VerificationMeta('fechaDeteccion');
  @override
  late final GeneratedColumn<DateTime> fechaDeteccion =
      GeneratedColumn<DateTime>('fecha_deteccion', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        lat,
        lng,
        tipoEmocion,
        intensidadHrv,
        audioAmbientalPath,
        fechaDeteccion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anomalias_emocionales';
  @override
  VerificationContext validateIntegrity(
      Insertable<AnomaliasEmocionale> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('tipo_emocion')) {
      context.handle(
          _tipoEmocionMeta,
          tipoEmocion.isAcceptableOrUnknown(
              data['tipo_emocion']!, _tipoEmocionMeta));
    } else if (isInserting) {
      context.missing(_tipoEmocionMeta);
    }
    if (data.containsKey('intensidad_hrv')) {
      context.handle(
          _intensidadHrvMeta,
          intensidadHrv.isAcceptableOrUnknown(
              data['intensidad_hrv']!, _intensidadHrvMeta));
    } else if (isInserting) {
      context.missing(_intensidadHrvMeta);
    }
    if (data.containsKey('audio_ambiental_path')) {
      context.handle(
          _audioAmbientalPathMeta,
          audioAmbientalPath.isAcceptableOrUnknown(
              data['audio_ambiental_path']!, _audioAmbientalPathMeta));
    }
    if (data.containsKey('fecha_deteccion')) {
      context.handle(
          _fechaDeteccionMeta,
          fechaDeteccion.isAcceptableOrUnknown(
              data['fecha_deteccion']!, _fechaDeteccionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnomaliasEmocionale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnomaliasEmocionale(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      tipoEmocion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo_emocion'])!,
      intensidadHrv: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}intensidad_hrv'])!,
      audioAmbientalPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}audio_ambiental_path']),
      fechaDeteccion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_deteccion'])!,
    );
  }

  @override
  $AnomaliasEmocionalesTable createAlias(String alias) {
    return $AnomaliasEmocionalesTable(attachedDatabase, alias);
  }
}

class AnomaliasEmocionale extends DataClass
    implements Insertable<AnomaliasEmocionale> {
  final int id;
  final double lat;
  final double lng;
  final String tipoEmocion;
  final int intensidadHrv;
  final String? audioAmbientalPath;
  final DateTime fechaDeteccion;
  const AnomaliasEmocionale(
      {required this.id,
      required this.lat,
      required this.lng,
      required this.tipoEmocion,
      required this.intensidadHrv,
      this.audioAmbientalPath,
      required this.fechaDeteccion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['tipo_emocion'] = Variable<String>(tipoEmocion);
    map['intensidad_hrv'] = Variable<int>(intensidadHrv);
    if (!nullToAbsent || audioAmbientalPath != null) {
      map['audio_ambiental_path'] = Variable<String>(audioAmbientalPath);
    }
    map['fecha_deteccion'] = Variable<DateTime>(fechaDeteccion);
    return map;
  }

  AnomaliasEmocionalesCompanion toCompanion(bool nullToAbsent) {
    return AnomaliasEmocionalesCompanion(
      id: Value(id),
      lat: Value(lat),
      lng: Value(lng),
      tipoEmocion: Value(tipoEmocion),
      intensidadHrv: Value(intensidadHrv),
      audioAmbientalPath: audioAmbientalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioAmbientalPath),
      fechaDeteccion: Value(fechaDeteccion),
    );
  }

  factory AnomaliasEmocionale.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnomaliasEmocionale(
      id: serializer.fromJson<int>(json['id']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      tipoEmocion: serializer.fromJson<String>(json['tipoEmocion']),
      intensidadHrv: serializer.fromJson<int>(json['intensidadHrv']),
      audioAmbientalPath:
          serializer.fromJson<String?>(json['audioAmbientalPath']),
      fechaDeteccion: serializer.fromJson<DateTime>(json['fechaDeteccion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'tipoEmocion': serializer.toJson<String>(tipoEmocion),
      'intensidadHrv': serializer.toJson<int>(intensidadHrv),
      'audioAmbientalPath': serializer.toJson<String?>(audioAmbientalPath),
      'fechaDeteccion': serializer.toJson<DateTime>(fechaDeteccion),
    };
  }

  AnomaliasEmocionale copyWith(
          {int? id,
          double? lat,
          double? lng,
          String? tipoEmocion,
          int? intensidadHrv,
          Value<String?> audioAmbientalPath = const Value.absent(),
          DateTime? fechaDeteccion}) =>
      AnomaliasEmocionale(
        id: id ?? this.id,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        tipoEmocion: tipoEmocion ?? this.tipoEmocion,
        intensidadHrv: intensidadHrv ?? this.intensidadHrv,
        audioAmbientalPath: audioAmbientalPath.present
            ? audioAmbientalPath.value
            : this.audioAmbientalPath,
        fechaDeteccion: fechaDeteccion ?? this.fechaDeteccion,
      );
  @override
  String toString() {
    return (StringBuffer('AnomaliasEmocionale(')
          ..write('id: $id, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('tipoEmocion: $tipoEmocion, ')
          ..write('intensidadHrv: $intensidadHrv, ')
          ..write('audioAmbientalPath: $audioAmbientalPath, ')
          ..write('fechaDeteccion: $fechaDeteccion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lat, lng, tipoEmocion, intensidadHrv,
      audioAmbientalPath, fechaDeteccion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnomaliasEmocionale &&
          other.id == this.id &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.tipoEmocion == this.tipoEmocion &&
          other.intensidadHrv == this.intensidadHrv &&
          other.audioAmbientalPath == this.audioAmbientalPath &&
          other.fechaDeteccion == this.fechaDeteccion);
}

class AnomaliasEmocionalesCompanion
    extends UpdateCompanion<AnomaliasEmocionale> {
  final Value<int> id;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String> tipoEmocion;
  final Value<int> intensidadHrv;
  final Value<String?> audioAmbientalPath;
  final Value<DateTime> fechaDeteccion;
  const AnomaliasEmocionalesCompanion({
    this.id = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.tipoEmocion = const Value.absent(),
    this.intensidadHrv = const Value.absent(),
    this.audioAmbientalPath = const Value.absent(),
    this.fechaDeteccion = const Value.absent(),
  });
  AnomaliasEmocionalesCompanion.insert({
    this.id = const Value.absent(),
    required double lat,
    required double lng,
    required String tipoEmocion,
    required int intensidadHrv,
    this.audioAmbientalPath = const Value.absent(),
    this.fechaDeteccion = const Value.absent(),
  })  : lat = Value(lat),
        lng = Value(lng),
        tipoEmocion = Value(tipoEmocion),
        intensidadHrv = Value(intensidadHrv);
  static Insertable<AnomaliasEmocionale> custom({
    Expression<int>? id,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? tipoEmocion,
    Expression<int>? intensidadHrv,
    Expression<String>? audioAmbientalPath,
    Expression<DateTime>? fechaDeteccion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (tipoEmocion != null) 'tipo_emocion': tipoEmocion,
      if (intensidadHrv != null) 'intensidad_hrv': intensidadHrv,
      if (audioAmbientalPath != null)
        'audio_ambiental_path': audioAmbientalPath,
      if (fechaDeteccion != null) 'fecha_deteccion': fechaDeteccion,
    });
  }

  AnomaliasEmocionalesCompanion copyWith(
      {Value<int>? id,
      Value<double>? lat,
      Value<double>? lng,
      Value<String>? tipoEmocion,
      Value<int>? intensidadHrv,
      Value<String?>? audioAmbientalPath,
      Value<DateTime>? fechaDeteccion}) {
    return AnomaliasEmocionalesCompanion(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      tipoEmocion: tipoEmocion ?? this.tipoEmocion,
      intensidadHrv: intensidadHrv ?? this.intensidadHrv,
      audioAmbientalPath: audioAmbientalPath ?? this.audioAmbientalPath,
      fechaDeteccion: fechaDeteccion ?? this.fechaDeteccion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (tipoEmocion.present) {
      map['tipo_emocion'] = Variable<String>(tipoEmocion.value);
    }
    if (intensidadHrv.present) {
      map['intensidad_hrv'] = Variable<int>(intensidadHrv.value);
    }
    if (audioAmbientalPath.present) {
      map['audio_ambiental_path'] = Variable<String>(audioAmbientalPath.value);
    }
    if (fechaDeteccion.present) {
      map['fecha_deteccion'] = Variable<DateTime>(fechaDeteccion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnomaliasEmocionalesCompanion(')
          ..write('id: $id, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('tipoEmocion: $tipoEmocion, ')
          ..write('intensidadHrv: $intensidadHrv, ')
          ..write('audioAmbientalPath: $audioAmbientalPath, ')
          ..write('fechaDeteccion: $fechaDeteccion')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $HitosTable hitos = $HitosTable(this);
  late final $AportesUsuariosTable aportesUsuarios =
      $AportesUsuariosTable(this);
  late final $ViajesTable viajes = $ViajesTable(this);
  late final $AnomaliasEmocionalesTable anomaliasEmocionales =
      $AnomaliasEmocionalesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [hitos, aportesUsuarios, viajes, anomaliasEmocionales];
}
