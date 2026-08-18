import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../core/constants/map_const.dart';
import '../../../core/theme/theme.dart';

/// The address pin at the map centre.
///
/// Yandex's `PlacemarkMapObject` requires an image asset; here the pin is
/// laid over the map as a Flutter widget instead, so no extra asset is
/// needed and the design-system colours apply.
class BinnoMapPin extends StatelessWidget {
  const BinnoMapPin({super.key, this.lifted = false, this.valid = true});

  /// The pin "lifts" slightly while the camera is moving.
  final bool lifted;

  /// When `false` (outside the boundary) the pin turns red.
  final bool valid;

  @override
  Widget build(BuildContext context) {
    final color = valid ? AppColors.navy950 : AppColors.danger;

    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppDimens.motionFast,
            transform: Matrix4.translationValues(0, lifted ? -8 : 0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 3),
                    boxShadow: AppDimens.shadowCard,
                  ),
                  child: Icon(
                    valid ? Icons.place_rounded : Icons.block_rounded,
                    size: 17,
                    color: AppColors.white,
                  ),
                ),
                Container(
                  width: 2,
                  height: 12,
                  color: color,
                ),
              ],
            ),
          ),
          // The ground shadow makes the exact point obvious.
          Container(
            width: 10,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.navy950.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppDimens.rPill),
            ),
          ),
        ],
      ),
    );
  }
}

/// The small map for a store, complex, or pickup point.
///
/// Not interactive (tapping opens the full map); used on list and detail
/// screens.
class BinnoMapPreview extends StatefulWidget {
  const BinnoMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 160,
    this.radius = AppDimens.rCardSm,
    this.onTap,
    this.zoom = MapConst.previewZoom,
  });

  final double latitude;
  final double longitude;
  final double height;
  final double radius;
  final VoidCallback? onTap;
  final double zoom;

  @override
  State<BinnoMapPreview> createState() => _BinnoMapPreviewState();
}

class _BinnoMapPreviewState extends State<BinnoMapPreview> {
  YandexMapController? _controller;

  Point get _point =>
      Point(latitude: widget.latitude, longitude: widget.longitude);

  // Note: we never call `YandexMapController.dispose()` ourselves; the
  // package does it in `_YandexMapState.dispose()`.

  Future<void> _center() async {
    if (!mounted) return;
    await _controller?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _point, zoom: widget.zoom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            YandexMap(
              // The preview is not interactive: the pin is a Flutter
              // overlay, so panning the map would drift it off the point.
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              onMapCreated: (controller) {
                _controller = controller;
                _center();
              },
            ),
            const Center(child: BinnoMapPin()),
            // The preview is not interactive: a tap opens the full map.
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: widget.onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
