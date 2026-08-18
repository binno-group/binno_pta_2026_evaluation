// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Category extends Category {
  @override
  final int? id;
  @override
  final int? parentId;
  @override
  final String? nameUz;
  @override
  final String? nameRu;
  @override
  final String? slug;
  @override
  final BuiltList<Category>? children;

  factory _$Category([void Function(CategoryBuilder)? updates]) =>
      (CategoryBuilder()..update(updates))._build();

  _$Category._(
      {this.id,
      this.parentId,
      this.nameUz,
      this.nameRu,
      this.slug,
      this.children})
      : super._();
  @override
  Category rebuild(void Function(CategoryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CategoryBuilder toBuilder() => CategoryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Category &&
        id == other.id &&
        parentId == other.parentId &&
        nameUz == other.nameUz &&
        nameRu == other.nameRu &&
        slug == other.slug &&
        children == other.children;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, parentId.hashCode);
    _$hash = $jc(_$hash, nameUz.hashCode);
    _$hash = $jc(_$hash, nameRu.hashCode);
    _$hash = $jc(_$hash, slug.hashCode);
    _$hash = $jc(_$hash, children.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Category')
          ..add('id', id)
          ..add('parentId', parentId)
          ..add('nameUz', nameUz)
          ..add('nameRu', nameRu)
          ..add('slug', slug)
          ..add('children', children))
        .toString();
  }
}

class CategoryBuilder implements Builder<Category, CategoryBuilder> {
  _$Category? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _parentId;
  int? get parentId => _$this._parentId;
  set parentId(int? parentId) => _$this._parentId = parentId;

  String? _nameUz;
  String? get nameUz => _$this._nameUz;
  set nameUz(String? nameUz) => _$this._nameUz = nameUz;

  String? _nameRu;
  String? get nameRu => _$this._nameRu;
  set nameRu(String? nameRu) => _$this._nameRu = nameRu;

  String? _slug;
  String? get slug => _$this._slug;
  set slug(String? slug) => _$this._slug = slug;

  ListBuilder<Category>? _children;
  ListBuilder<Category> get children =>
      _$this._children ??= ListBuilder<Category>();
  set children(ListBuilder<Category>? children) => _$this._children = children;

  CategoryBuilder() {
    Category._defaults(this);
  }

  CategoryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _parentId = $v.parentId;
      _nameUz = $v.nameUz;
      _nameRu = $v.nameRu;
      _slug = $v.slug;
      _children = $v.children?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Category other) {
    _$v = other as _$Category;
  }

  @override
  void update(void Function(CategoryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Category build() => _build();

  _$Category _build() {
    _$Category _$result;
    try {
      _$result = _$v ??
          _$Category._(
            id: id,
            parentId: parentId,
            nameUz: nameUz,
            nameRu: nameRu,
            slug: slug,
            children: _children?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'children';
        _children?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Category', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
