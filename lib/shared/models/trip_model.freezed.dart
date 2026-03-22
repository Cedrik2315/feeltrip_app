// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Trip _$TripFromJson(Map<String, dynamic> json) {
  return _Trip.fromJson(json);
}

/// @nodoc
mixin _$Trip {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get destination => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  List<Review> get reviews => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  List<String> get highlights => throw _privateConstructorUsedError;
  List<String> get amenities => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  bool get isTransformative => throw _privateConstructorUsedError;
  String? get guide => throw _privateConstructorUsedError;
  String? get agencyId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
  DateTime? get endDate => throw _privateConstructorUsedError;
  int get maxParticipants => throw _privateConstructorUsedError;
  int get currentParticipants => throw _privateConstructorUsedError;
  String? get experienceType => throw _privateConstructorUsedError;
  List<String> get emotions => throw _privateConstructorUsedError;
  List<String> get learnings => throw _privateConstructorUsedError;
  String? get transformationMessage => throw _privateConstructorUsedError;
  List<String> get culturalConnections => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TripCopyWith<Trip> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripCopyWith<$Res> {
  factory $TripCopyWith(Trip value, $Res Function(Trip) then) =
      _$TripCopyWithImpl<$Res, Trip>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String destination,
      String country,
      double price,
      int duration,
      String difficulty,
      String category,
      double rating,
      List<Review> reviews,
      List<String> images,
      List<String> highlights,
      List<String> amenities,
      bool isFeatured,
      bool isTransformative,
      String? guide,
      String? agencyId,
      @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
      DateTime? startDate,
      @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
      DateTime? endDate,
      int maxParticipants,
      int currentParticipants,
      String? experienceType,
      List<String> emotions,
      List<String> learnings,
      String? transformationMessage,
      List<String> culturalConnections});
}

/// @nodoc
class _$TripCopyWithImpl<$Res, $Val extends Trip>
    implements $TripCopyWith<$Res> {
  _$TripCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? destination = null,
    Object? country = null,
    Object? price = null,
    Object? duration = null,
    Object? difficulty = null,
    Object? category = null,
    Object? rating = null,
    Object? reviews = null,
    Object? images = null,
    Object? highlights = null,
    Object? amenities = null,
    Object? isFeatured = null,
    Object? isTransformative = null,
    Object? guide = freezed,
    Object? agencyId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? maxParticipants = null,
    Object? currentParticipants = null,
    Object? experienceType = freezed,
    Object? emotions = null,
    Object? learnings = null,
    Object? transformationMessage = freezed,
    Object? culturalConnections = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviews: null == reviews
          ? _value.reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<Review>,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      highlights: null == highlights
          ? _value.highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<String>,
      amenities: null == amenities
          ? _value.amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      isTransformative: null == isTransformative
          ? _value.isTransformative
          : isTransformative // ignore: cast_nullable_to_non_nullable
              as bool,
      guide: freezed == guide
          ? _value.guide
          : guide // ignore: cast_nullable_to_non_nullable
              as String?,
      agencyId: freezed == agencyId
          ? _value.agencyId
          : agencyId // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      maxParticipants: null == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      currentParticipants: null == currentParticipants
          ? _value.currentParticipants
          : currentParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      experienceType: freezed == experienceType
          ? _value.experienceType
          : experienceType // ignore: cast_nullable_to_non_nullable
              as String?,
      emotions: null == emotions
          ? _value.emotions
          : emotions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      learnings: null == learnings
          ? _value.learnings
          : learnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      transformationMessage: freezed == transformationMessage
          ? _value.transformationMessage
          : transformationMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      culturalConnections: null == culturalConnections
          ? _value.culturalConnections
          : culturalConnections // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripImplCopyWith<$Res> implements $TripCopyWith<$Res> {
  factory _$$TripImplCopyWith(
          _$TripImpl value, $Res Function(_$TripImpl) then) =
      __$$TripImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String destination,
      String country,
      double price,
      int duration,
      String difficulty,
      String category,
      double rating,
      List<Review> reviews,
      List<String> images,
      List<String> highlights,
      List<String> amenities,
      bool isFeatured,
      bool isTransformative,
      String? guide,
      String? agencyId,
      @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
      DateTime? startDate,
      @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
      DateTime? endDate,
      int maxParticipants,
      int currentParticipants,
      String? experienceType,
      List<String> emotions,
      List<String> learnings,
      String? transformationMessage,
      List<String> culturalConnections});
}

/// @nodoc
class __$$TripImplCopyWithImpl<$Res>
    extends _$TripCopyWithImpl<$Res, _$TripImpl>
    implements _$$TripImplCopyWith<$Res> {
  __$$TripImplCopyWithImpl(_$TripImpl _value, $Res Function(_$TripImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? destination = null,
    Object? country = null,
    Object? price = null,
    Object? duration = null,
    Object? difficulty = null,
    Object? category = null,
    Object? rating = null,
    Object? reviews = null,
    Object? images = null,
    Object? highlights = null,
    Object? amenities = null,
    Object? isFeatured = null,
    Object? isTransformative = null,
    Object? guide = freezed,
    Object? agencyId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? maxParticipants = null,
    Object? currentParticipants = null,
    Object? experienceType = freezed,
    Object? emotions = null,
    Object? learnings = null,
    Object? transformationMessage = freezed,
    Object? culturalConnections = null,
  }) {
    return _then(_$TripImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviews: null == reviews
          ? _value._reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<Review>,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      highlights: null == highlights
          ? _value._highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<String>,
      amenities: null == amenities
          ? _value._amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      isTransformative: null == isTransformative
          ? _value.isTransformative
          : isTransformative // ignore: cast_nullable_to_non_nullable
              as bool,
      guide: freezed == guide
          ? _value.guide
          : guide // ignore: cast_nullable_to_non_nullable
              as String?,
      agencyId: freezed == agencyId
          ? _value.agencyId
          : agencyId // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      maxParticipants: null == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      currentParticipants: null == currentParticipants
          ? _value.currentParticipants
          : currentParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      experienceType: freezed == experienceType
          ? _value.experienceType
          : experienceType // ignore: cast_nullable_to_non_nullable
              as String?,
      emotions: null == emotions
          ? _value._emotions
          : emotions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      learnings: null == learnings
          ? _value._learnings
          : learnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      transformationMessage: freezed == transformationMessage
          ? _value.transformationMessage
          : transformationMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      culturalConnections: null == culturalConnections
          ? _value._culturalConnections
          : culturalConnections // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripImpl implements _Trip {
  const _$TripImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.destination,
      required this.country,
      required this.price,
      required this.duration,
      required this.difficulty,
      this.category = 'General',
      this.rating = 0.0,
      final List<Review> reviews = const <Review>[],
      final List<String> images = const <String>[],
      final List<String> highlights = const <String>[],
      final List<String> amenities = const <String>[],
      this.isFeatured = false,
      this.isTransformative = false,
      this.guide,
      this.agencyId,
      @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
      this.startDate,
      @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime) this.endDate,
      this.maxParticipants = 0,
      this.currentParticipants = 0,
      this.experienceType,
      final List<String> emotions = const <String>[],
      final List<String> learnings = const <String>[],
      this.transformationMessage,
      final List<String> culturalConnections = const <String>[]})
      : _reviews = reviews,
        _images = images,
        _highlights = highlights,
        _amenities = amenities,
        _emotions = emotions,
        _learnings = learnings,
        _culturalConnections = culturalConnections;

  factory _$TripImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String destination;
  @override
  final String country;
  @override
  final double price;
  @override
  final int duration;
  @override
  final String difficulty;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final double rating;
  final List<Review> _reviews;
  @override
  @JsonKey()
  List<Review> get reviews {
    if (_reviews is EqualUnmodifiableListView) return _reviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reviews);
  }

  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final List<String> _highlights;
  @override
  @JsonKey()
  List<String> get highlights {
    if (_highlights is EqualUnmodifiableListView) return _highlights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_highlights);
  }

  final List<String> _amenities;
  @override
  @JsonKey()
  List<String> get amenities {
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amenities);
  }

  @override
  @JsonKey()
  final bool isFeatured;
  @override
  @JsonKey()
  final bool isTransformative;
  @override
  final String? guide;
  @override
  final String? agencyId;
  @override
  @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
  final DateTime? startDate;
  @override
  @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
  final DateTime? endDate;
  @override
  @JsonKey()
  final int maxParticipants;
  @override
  @JsonKey()
  final int currentParticipants;
  @override
  final String? experienceType;
  final List<String> _emotions;
  @override
  @JsonKey()
  List<String> get emotions {
    if (_emotions is EqualUnmodifiableListView) return _emotions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_emotions);
  }

  final List<String> _learnings;
  @override
  @JsonKey()
  List<String> get learnings {
    if (_learnings is EqualUnmodifiableListView) return _learnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_learnings);
  }

  @override
  final String? transformationMessage;
  final List<String> _culturalConnections;
  @override
  @JsonKey()
  List<String> get culturalConnections {
    if (_culturalConnections is EqualUnmodifiableListView)
      return _culturalConnections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_culturalConnections);
  }

  @override
  String toString() {
    return 'Trip(id: $id, title: $title, description: $description, destination: $destination, country: $country, price: $price, duration: $duration, difficulty: $difficulty, category: $category, rating: $rating, reviews: $reviews, images: $images, highlights: $highlights, amenities: $amenities, isFeatured: $isFeatured, isTransformative: $isTransformative, guide: $guide, agencyId: $agencyId, startDate: $startDate, endDate: $endDate, maxParticipants: $maxParticipants, currentParticipants: $currentParticipants, experienceType: $experienceType, emotions: $emotions, learnings: $learnings, transformationMessage: $transformationMessage, culturalConnections: $culturalConnections)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            const DeepCollectionEquality().equals(other._reviews, _reviews) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality()
                .equals(other._highlights, _highlights) &&
            const DeepCollectionEquality()
                .equals(other._amenities, _amenities) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.isTransformative, isTransformative) ||
                other.isTransformative == isTransformative) &&
            (identical(other.guide, guide) || other.guide == guide) &&
            (identical(other.agencyId, agencyId) ||
                other.agencyId == agencyId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.currentParticipants, currentParticipants) ||
                other.currentParticipants == currentParticipants) &&
            (identical(other.experienceType, experienceType) ||
                other.experienceType == experienceType) &&
            const DeepCollectionEquality().equals(other._emotions, _emotions) &&
            const DeepCollectionEquality()
                .equals(other._learnings, _learnings) &&
            (identical(other.transformationMessage, transformationMessage) ||
                other.transformationMessage == transformationMessage) &&
            const DeepCollectionEquality()
                .equals(other._culturalConnections, _culturalConnections));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        destination,
        country,
        price,
        duration,
        difficulty,
        category,
        rating,
        const DeepCollectionEquality().hash(_reviews),
        const DeepCollectionEquality().hash(_images),
        const DeepCollectionEquality().hash(_highlights),
        const DeepCollectionEquality().hash(_amenities),
        isFeatured,
        isTransformative,
        guide,
        agencyId,
        startDate,
        endDate,
        maxParticipants,
        currentParticipants,
        experienceType,
        const DeepCollectionEquality().hash(_emotions),
        const DeepCollectionEquality().hash(_learnings),
        transformationMessage,
        const DeepCollectionEquality().hash(_culturalConnections)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TripImplCopyWith<_$TripImpl> get copyWith =>
      __$$TripImplCopyWithImpl<_$TripImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripImplToJson(
      this,
    );
  }
}

abstract class _Trip implements Trip {
  const factory _Trip(
      {required final String id,
      required final String title,
      required final String description,
      required final String destination,
      required final String country,
      required final double price,
      required final int duration,
      required final String difficulty,
      final String category,
      final double rating,
      final List<Review> reviews,
      final List<String> images,
      final List<String> highlights,
      final List<String> amenities,
      final bool isFeatured,
      final bool isTransformative,
      final String? guide,
      final String? agencyId,
      @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
      final DateTime? startDate,
      @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
      final DateTime? endDate,
      final int maxParticipants,
      final int currentParticipants,
      final String? experienceType,
      final List<String> emotions,
      final List<String> learnings,
      final String? transformationMessage,
      final List<String> culturalConnections}) = _$TripImpl;

  factory _Trip.fromJson(Map<String, dynamic> json) = _$TripImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get destination;
  @override
  String get country;
  @override
  double get price;
  @override
  int get duration;
  @override
  String get difficulty;
  @override
  String get category;
  @override
  double get rating;
  @override
  List<Review> get reviews;
  @override
  List<String> get images;
  @override
  List<String> get highlights;
  @override
  List<String> get amenities;
  @override
  bool get isFeatured;
  @override
  bool get isTransformative;
  @override
  String? get guide;
  @override
  String? get agencyId;
  @override
  @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
  DateTime? get startDate;
  @override
  @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
  DateTime? get endDate;
  @override
  int get maxParticipants;
  @override
  int get currentParticipants;
  @override
  String? get experienceType;
  @override
  List<String> get emotions;
  @override
  List<String> get learnings;
  @override
  String? get transformationMessage;
  @override
  List<String> get culturalConnections;
  @override
  @JsonKey(ignore: true)
  _$$TripImplCopyWith<_$TripImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
