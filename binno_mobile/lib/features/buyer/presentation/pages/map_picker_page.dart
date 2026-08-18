import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../../core/constants/map_const.dart';
import '../../../../core/services/yandex_map_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/widgets/binno_buttons.dart';
import '../../../shared/widgets/binno_chrome.dart';
import '../../../shared/widgets/binno_map.dart';

/// The result of picking an address on the map.
class PickedAddress {
  const PickedAddress({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;

  /// The reverse-geocoding result. `null` when there is no network.
  final String? address;

  String get coordinates =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  String get label => address ?? coordinates;
}

/// Picking the delivery address on the map.
///
/// The pin stays at the screen centre and the map slides under it, which
/// suits one-handed use and precise picking. When the camera stops, the
/// address text refreshes through reverse geocoding.
class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key, this.initialLat, this.initialLng});

  final double? initialLat;
  final double? initialLng;

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final _service = YandexMapService();

  YandexMapController? _controller;
  bool _moving = false;
  bool _resolving = false;

  /// Whether the picked point lies inside Uzbekistan (§15).
  bool _insideUz = true;

  String? _address;
  Point? _point;

  @override
  void initState() {
    super.initState();
    final point = Point(
      latitude: widget.initialLat ?? MapConst.defaultLat,
      longitude: widget.initialLng ?? MapConst.defaultLng,
    );
    _point = point;
    _insideUz = _service.isInsideUzbekistan(point);
  }

  Future<void> _moveTo(Point point, {bool animate = true}) async {
    if (!mounted) return;
    await _controller?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: MapConst.pickerZoom),
      ),
      animation: animate
          ? const MapAnimation(type: MapAnimationType.smooth, duration: 0.4)
          : null,
    );
  }

  /// Zooming the map in and out (§15).
  Future<void> _zoom({required bool zoomIn}) async {
    if (!mounted) return;
    await _controller?.moveCamera(
      zoomIn ? CameraUpdate.zoomIn() : CameraUpdate.zoomOut(),
      animation: const MapAnimation(
        type: MapAnimationType.linear,
        duration: 0.2,
      ),
    );
  }

  Future<void> _resolveAddress(Point point) async {
    if (!mounted) return;
    setState(() {
      _resolving = true;
      _point = point;
      _insideUz = _service.isInsideUzbekistan(point);
    });

    // No point geocoding outside the boundary: the user cannot pick
    // there anyway.
    if (!_insideUz) {
      setState(() {
        _address = null;
        _resolving = false;
      });
      return;
    }

    final address = await _service.addressOfPoint(point);
    if (!mounted) return;

    setState(() {
      _address = address;
      _resolving = false;
    });
  }

  Future<void> _goToMyLocation() async {
    final point = await _service.currentPoint();
    if (!mounted) return;

    if (point == null) {
      binnoSnack(
        context,
        'Joylashuvni aniqlab bo\'lmadi — GPS va ruxsatni tekshiring',
      );
      return;
    }

    await _moveTo(point);
  }

  void _submit() {
    final point = _point;
    if (point == null) return;

    Navigator.of(context).pop(
      PickedAddress(
        latitude: point.latitude,
        longitude: point.longitude,
        address: _address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      child: Stack(
        children: [
          Positioned.fill(
            child: YandexMap(
              onMapCreated: (controller) async {
                _controller = controller;
                final point = _point;
                if (point != null) {
                  await _moveTo(point, animate: false);
                  await _resolveAddress(point);
                }
              },
              onCameraPositionChanged: (position, reason, finished) {
                if (!finished) {
                  if (!_moving) setState(() => _moving = true);
                  return;
                }
                setState(() => _moving = false);
                _resolveAddress(position.target);
              },
            ),
          ),

          // The centre pin; the map slides under it. It turns red outside
          // the boundary.
          Center(
            child: Padding(
              // Slightly raised to account for the bottom panel height.
              padding: const EdgeInsets.only(bottom: 80),
              child: BinnoMapPin(lifted: _moving, valid: _insideUz),
            ),
          ),

          // The back button, top left.
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: _MapCircleButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ),

          // The vertical controls on the right: location and zoom +/- (§15).
          Positioned(
            right: 16,
            bottom: 250,
            child: Column(
              children: [
                _MapCircleButton(
                  icon: Icons.my_location_rounded,
                  onTap: _goToMyLocation,
                ),
                const SizedBox(height: 14),
                _MapCircleButton(
                  icon: Icons.add_rounded,
                  onTap: () => _zoom(zoomIn: true),
                ),
                const SizedBox(height: 8),
                _MapCircleButton(
                  icon: Icons.remove_rounded,
                  onTap: () => _zoom(zoomIn: false),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: _AddressSheet(
              address: _address,
              coordinates: _point == null
                  ? ''
                  : '${_point!.latitude.toStringAsFixed(5)}, '
                        '${_point!.longitude.toStringAsFixed(5)}',
              resolving: _resolving,
              insideUz: _insideUz,
              enabled: !_moving && _point != null && _insideUz,
              onSubmit: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCircleButton extends StatelessWidget {
  const _MapCircleButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppDimens.shadowCard,
      ),
      child: Material(
        color: AppColors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 24, color: AppColors.navy950),
          ),
        ),
      ),
    );
  }
}

class _AddressSheet extends StatelessWidget {
  const _AddressSheet({
    required this.address,
    required this.coordinates,
    required this.resolving,
    required this.insideUz,
    required this.enabled,
    required this.onSubmit,
  });

  final String? address;
  final String coordinates;
  final bool resolving;
  final bool insideUz;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.rSheet),
        ),
        boxShadow: AppDimens.shadowFloating,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.edge,
                    borderRadius: BorderRadius.circular(AppDimens.rPill),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('TANLANGAN NUQTA', style: AppText.eyebrow()),
              const SizedBox(height: 8),
              if (!insideUz) ...[
                // Outside the boundary: picking is not allowed (§15).
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'O\'zbekiston hududini tanlang',
                        style: AppText.s(
                          15,
                          FontWeight.w600,
                          color: AppColors.danger,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(coordinates, style: AppText.meta()),
              ] else if (resolving)
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ink3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Manzil aniqlanmoqda…', style: AppText.meta()),
                  ],
                )
              else ...[
                Text(
                  address ?? 'Manzil aniqlanmadi',
                  style: AppText.s(16, FontWeight.w600, height: 1.35),
                ),
                const SizedBox(height: 4),
                Text(coordinates, style: AppText.meta()),
              ],
              const SizedBox(height: 16),
              BinnoPrimaryButton(
                label: insideUz
                    ? 'Shu manzilni tanlash'
                    : 'Hudud O\'zbekistondan tashqarida',
                enabled: enabled,
                onPressed: enabled ? onSubmit : null,
              ),
              const SizedBox(height: 10),
              Text(
                'Sotuvchi qidiruv bosqichida faqat tumaningizni ko\'radi.',
                textAlign: TextAlign.center,
                style: AppText.note(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
