// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_orders_id_proposals_post201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierOrdersIdProposalsPost201Response
    extends SupplierOrdersIdProposalsPost201Response {
  @override
  final String? proposalId;
  @override
  final int? round;
  @override
  final DateTime? expiresAt;

  factory _$SupplierOrdersIdProposalsPost201Response(
          [void Function(SupplierOrdersIdProposalsPost201ResponseBuilder)?
              updates]) =>
      (SupplierOrdersIdProposalsPost201ResponseBuilder()..update(updates))
          ._build();

  _$SupplierOrdersIdProposalsPost201Response._(
      {this.proposalId, this.round, this.expiresAt})
      : super._();
  @override
  SupplierOrdersIdProposalsPost201Response rebuild(
          void Function(SupplierOrdersIdProposalsPost201ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierOrdersIdProposalsPost201ResponseBuilder toBuilder() =>
      SupplierOrdersIdProposalsPost201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierOrdersIdProposalsPost201Response &&
        proposalId == other.proposalId &&
        round == other.round &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, proposalId.hashCode);
    _$hash = $jc(_$hash, round.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SupplierOrdersIdProposalsPost201Response')
          ..add('proposalId', proposalId)
          ..add('round', round)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class SupplierOrdersIdProposalsPost201ResponseBuilder
    implements
        Builder<SupplierOrdersIdProposalsPost201Response,
            SupplierOrdersIdProposalsPost201ResponseBuilder> {
  _$SupplierOrdersIdProposalsPost201Response? _$v;

  String? _proposalId;
  String? get proposalId => _$this._proposalId;
  set proposalId(String? proposalId) => _$this._proposalId = proposalId;

  int? _round;
  int? get round => _$this._round;
  set round(int? round) => _$this._round = round;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  SupplierOrdersIdProposalsPost201ResponseBuilder() {
    SupplierOrdersIdProposalsPost201Response._defaults(this);
  }

  SupplierOrdersIdProposalsPost201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _proposalId = $v.proposalId;
      _round = $v.round;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierOrdersIdProposalsPost201Response other) {
    _$v = other as _$SupplierOrdersIdProposalsPost201Response;
  }

  @override
  void update(
      void Function(SupplierOrdersIdProposalsPost201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierOrdersIdProposalsPost201Response build() => _build();

  _$SupplierOrdersIdProposalsPost201Response _build() {
    final _$result = _$v ??
        _$SupplierOrdersIdProposalsPost201Response._(
          proposalId: proposalId,
          round: round,
          expiresAt: expiresAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
