// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model_plain.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookingModelPlainCollection on Isar {
  IsarCollection<BookingModelPlain> get bookingModelPlains => this.collection();
}

const BookingModelPlainSchema = CollectionSchema(
  name: r'BookingModelPlain',
  id: -2280127003827615871,
  properties: {
    r'commission': PropertySchema(
      id: 0,
      name: r'commission',
      type: IsarType.double,
    ),
    r'currency': PropertySchema(
      id: 1,
      name: r'currency',
      type: IsarType.string,
    ),
    r'destinationId': PropertySchema(
      id: 2,
      name: r'destinationId',
      type: IsarType.string,
    ),
    r'firestoreId': PropertySchema(
      id: 3,
      name: r'firestoreId',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 4,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'priceUsd': PropertySchema(
      id: 5,
      name: r'priceUsd',
      type: IsarType.double,
    ),
    r'status': PropertySchema(
      id: 6,
      name: r'status',
      type: IsarType.string,
    ),
    r'tripDates': PropertySchema(
      id: 7,
      name: r'tripDates',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 8,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _bookingModelPlainEstimateSize,
  serialize: _bookingModelPlainSerialize,
  deserialize: _bookingModelPlainDeserialize,
  deserializeProp: _bookingModelPlainDeserializeProp,
  idName: r'id',
  indexes: {
    r'firestoreId': IndexSchema(
      id: 1863077355534729001,
      name: r'firestoreId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'firestoreId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bookingModelPlainGetId,
  getLinks: _bookingModelPlainGetLinks,
  attach: _bookingModelPlainAttach,
  version: '3.1.0+1',
);

int _bookingModelPlainEstimateSize(
  BookingModelPlain object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.destinationId.length * 3;
  bytesCount += 3 + object.firestoreId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.tripDates.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _bookingModelPlainSerialize(
  BookingModelPlain object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.commission);
  writer.writeString(offsets[1], object.currency);
  writer.writeString(offsets[2], object.destinationId);
  writer.writeString(offsets[3], object.firestoreId);
  writer.writeBool(offsets[4], object.isSynced);
  writer.writeDouble(offsets[5], object.priceUsd);
  writer.writeString(offsets[6], object.status);
  writer.writeString(offsets[7], object.tripDates);
  writer.writeString(offsets[8], object.userId);
}

BookingModelPlain _bookingModelPlainDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BookingModelPlain();
  object.commission = reader.readDouble(offsets[0]);
  object.currency = reader.readString(offsets[1]);
  object.destinationId = reader.readString(offsets[2]);
  object.firestoreId = reader.readString(offsets[3]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[4]);
  object.priceUsd = reader.readDouble(offsets[5]);
  object.status = reader.readString(offsets[6]);
  object.tripDates = reader.readString(offsets[7]);
  object.userId = reader.readString(offsets[8]);
  return object;
}

P _bookingModelPlainDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bookingModelPlainGetId(BookingModelPlain object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bookingModelPlainGetLinks(
    BookingModelPlain object) {
  return [];
}

void _bookingModelPlainAttach(
    IsarCollection<dynamic> col, Id id, BookingModelPlain object) {
  object.id = id;
}

extension BookingModelPlainQueryWhereSort
    on QueryBuilder<BookingModelPlain, BookingModelPlain, QWhere> {
  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BookingModelPlainQueryWhere
    on QueryBuilder<BookingModelPlain, BookingModelPlain, QWhereClause> {
  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterWhereClause>
      firestoreIdEqualTo(String firestoreId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firestoreId',
        value: [firestoreId],
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterWhereClause>
      firestoreIdNotEqualTo(String firestoreId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [],
              upper: [firestoreId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [firestoreId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [firestoreId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [],
              upper: [firestoreId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BookingModelPlainQueryFilter
    on QueryBuilder<BookingModelPlain, BookingModelPlain, QFilterCondition> {
  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      commissionEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commission',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      commissionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'commission',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      commissionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'commission',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      commissionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'commission',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      currencyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      currencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      currencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      currencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      currencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      currencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      destinationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'destinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      destinationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'destinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      destinationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'destinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      destinationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'destinationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      destinationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'destinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      destinationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'destinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      destinationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'destinationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      destinationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'destinationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      destinationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'destinationId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      destinationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'destinationId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      firestoreIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      firestoreIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      firestoreIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      firestoreIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firestoreId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      firestoreIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      firestoreIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      firestoreIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      firestoreIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'firestoreId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      firestoreIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firestoreId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      firestoreIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'firestoreId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      priceUsdEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priceUsd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      priceUsdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priceUsd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      priceUsdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priceUsd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      priceUsdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priceUsd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      tripDatesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tripDates',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      tripDatesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tripDates',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      tripDatesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tripDates',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      tripDatesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tripDates',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      tripDatesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tripDates',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      tripDatesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tripDates',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      tripDatesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tripDates',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      tripDatesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tripDates',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      tripDatesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tripDates',
        value: '',
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      tripDatesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tripDates',
        value: '',
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension BookingModelPlainQueryObject
    on QueryBuilder<BookingModelPlain, BookingModelPlain, QFilterCondition> {}

extension BookingModelPlainQueryLinks
    on QueryBuilder<BookingModelPlain, BookingModelPlain, QFilterCondition> {}

extension BookingModelPlainQuerySortBy
    on QueryBuilder<BookingModelPlain, BookingModelPlain, QSortBy> {
  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByCommission() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commission', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByCommissionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commission', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByDestinationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationId', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByDestinationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationId', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByFirestoreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByFirestoreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByPriceUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceUsd', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByPriceUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceUsd', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByTripDates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripDates', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByTripDatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripDates', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BookingModelPlainQuerySortThenBy
    on QueryBuilder<BookingModelPlain, BookingModelPlain, QSortThenBy> {
  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByCommission() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commission', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByCommissionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commission', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByDestinationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationId', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByDestinationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationId', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByFirestoreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByFirestoreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByPriceUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceUsd', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByPriceUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceUsd', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByTripDates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripDates', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByTripDatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripDates', Sort.desc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BookingModelPlainQueryWhereDistinct
    on QueryBuilder<BookingModelPlain, BookingModelPlain, QDistinct> {
  QueryBuilder<BookingModelPlain, BookingModelPlain, QDistinct>
      distinctByCommission() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commission');
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QDistinct>
      distinctByDestinationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'destinationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QDistinct>
      distinctByFirestoreId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firestoreId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QDistinct>
      distinctByPriceUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priceUsd');
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QDistinct>
      distinctByTripDates({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tripDates', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookingModelPlain, BookingModelPlain, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension BookingModelPlainQueryProperty
    on QueryBuilder<BookingModelPlain, BookingModelPlain, QQueryProperty> {
  QueryBuilder<BookingModelPlain, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BookingModelPlain, double, QQueryOperations>
      commissionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commission');
    });
  }

  QueryBuilder<BookingModelPlain, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<BookingModelPlain, String, QQueryOperations>
      destinationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'destinationId');
    });
  }

  QueryBuilder<BookingModelPlain, String, QQueryOperations>
      firestoreIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firestoreId');
    });
  }

  QueryBuilder<BookingModelPlain, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<BookingModelPlain, double, QQueryOperations> priceUsdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priceUsd');
    });
  }

  QueryBuilder<BookingModelPlain, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<BookingModelPlain, String, QQueryOperations>
      tripDatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tripDates');
    });
  }

  QueryBuilder<BookingModelPlain, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
