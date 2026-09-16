import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/absensi_provider.dart';
import 'map_canvas_painter.dart';


class MapCard extends StatelessWidget {
  final AbsensiState state;
  final Animation<double> pulseAnimation;

  const MapCard({
    super.key,
    required this.state,
    required this.pulseAnimation,
  });

  Future<void> _bukaGoogleMaps(double lat, double lng) async {
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dalamJangkauan = state.dalamJangkauan;
    final jarak = state.jarakTerdekat;
    final kantorLat = state.lokasiTerdekat?.latitude ?? -4.178249;
    final kantorLng = state.lokasiTerdekat?.longitude ?? 121.610741;
    final userLat = state.posisiSaatIni?.latitude;
    final userLng = state.posisiSaatIni?.longitude;

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dalamJangkauan
              ? const Color(0xFF10B981)
              : const Color(0xFF475569),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CustomPaint(
                painter: MapCanvasPainter(
                  dalamJangkauan: dalamJangkauan,
                  kantorLat: kantorLat,
                  kantorLng: kantorLng,
                  userLat: userLat,
                  userLng: userLng,
                  jarak: jarak,
                  radius: state.lokasiTerdekat?.radius ?? 80.0,
                  pulseVal: pulseAnimation.value,
                ),
              ),
            ),
          ),

          
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dalamJangkauan
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          state.posisiSaatIni != null
                              ? 'GPS Aktif (±${state.akurasiGps?.toStringAsFixed(0) ?? "5"}m)'
                              : 'Mencari GPS...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    ],
                  ),
                ),

                
                GestureDetector(
                  onTap: () {
                    final lat = userLat ?? kantorLat;
                    final lng = userLng ?? kantorLng;
                    _bukaGoogleMaps(lat, lng);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.map, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Google Maps',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: dalamJangkauan
                              ? const Color(0xFF10B981).withOpacity(0.2)
                              : const Color(0xFFEF4444).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          dalamJangkauan
                              ? LucideIcons.mapPinCheck
                              : LucideIcons.mapPinOff,
                          size: 18,
                          color: dalamJangkauan
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.lokasiTerdekat?.nama ??
                                  'Kantor TJS Dawi-Dawi',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              jarak != null
                                  ? 'Jarak Anda: ${jarak.toStringAsFixed(1)}m (Radius: ${state.lokasiTerdekat?.radius.toStringAsFixed(0) ?? "80"}m)'
                                  : 'Mendapatkan posisi GPS...',
                              style: TextStyle(
                                color: dalamJangkauan
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFFFCA5A5),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
