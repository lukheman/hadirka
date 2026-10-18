import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/absensi_provider.dart';

class MapCard extends StatefulWidget {
  final AbsensiState state;

  const MapCard({
    super.key,
    required this.state,
  });

  @override
  State<MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  GoogleMapController? _mapController;
  LatLng? _kameraTerakhir;
  LatLng? _penggunaTerakhir;

  AbsensiState get state => widget.state;

  Future<void> _bukaGoogleMaps(double lat, double lng) async {
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void didUpdateWidget(covariant MapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _targetLatLng;
    final user = _userLatLng;
    if (target != null &&
        (target != _kameraTerakhir || user != _penggunaTerakhir)) {
      unawaited(_aturKamera(target, user));
    }
  }

  LatLng? get _targetLatLng {
    final lokasi = state.lokasiDipilih ?? state.lokasiTerdekat;
    if (lokasi == null ||
        !lokasi.latitude.isFinite ||
        !lokasi.longitude.isFinite ||
        lokasi.latitude.abs() > 90 ||
        lokasi.longitude.abs() > 180 ||
        (lokasi.latitude == 0 && lokasi.longitude == 0)) {
      return null;
    }
    return LatLng(lokasi.latitude, lokasi.longitude);
  }

  LatLng? get _userLatLng {
    final posisi = state.posisiSaatIni;
    if (posisi == null ||
        !posisi.latitude.isFinite ||
        !posisi.longitude.isFinite ||
        posisi.latitude.abs() > 90 ||
        posisi.longitude.abs() > 180) {
      return null;
    }
    return LatLng(posisi.latitude, posisi.longitude);
  }

  Future<void> _aturKamera(LatLng target, [LatLng? user]) async {
    final controller = _mapController;
    if (controller == null) return;

    _kameraTerakhir = target;
    _penggunaTerakhir = user ?? _userLatLng;
    try {
      if (user != null && user != target) {
        final southwest = LatLng(
          target.latitude < user.latitude ? target.latitude : user.latitude,
          target.longitude < user.longitude ? target.longitude : user.longitude,
        );
        final northeast = LatLng(
          target.latitude > user.latitude ? target.latitude : user.latitude,
          target.longitude > user.longitude ? target.longitude : user.longitude,
        );
        await controller.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(southwest: southwest, northeast: northeast),
            72,
          ),
        );
      } else {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 17),
          ),
        );
      }
    } catch (_) {
      // Camera can be unavailable briefly while native Google Map initializes.
    }
  }

  Set<Marker> _markers(LatLng? target, LatLng? user) {
    final markers = <Marker>{};
    final lokasi = state.lokasiDipilih ?? state.lokasiTerdekat;
    if (target != null && lokasi != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('site_absensi'),
          position: target,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: lokasi.nama),
        ),
      );
    }
    if (user != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('posisi_pengguna'),
          position: user,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: 'Posisi Anda',
            snippet: state.akurasiGps == null
                ? null
                : 'Akurasi ±${state.akurasiGps!.toStringAsFixed(0)}m',
          ),
        ),
      );
    }
    return markers;
  }

  Set<Circle> _circles(LatLng? target) {
    final lokasi = state.lokasiDipilih ?? state.lokasiTerdekat;
    if (target == null || lokasi == null) return const <Circle>{};
    final warna = state.dalamJangkauan
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    return {
      Circle(
        circleId: const CircleId('radius_absensi'),
        center: target,
        radius: lokasi.radius,
        fillColor: warna.withValues(alpha: 0.18),
        strokeColor: warna,
        strokeWidth: 2,
      ),
    };
  }

  Set<Polyline> _polylines(LatLng? target, LatLng? user) {
    if (target == null || user == null || target == user) {
      return const <Polyline>{};
    }
    return {
      Polyline(
        polylineId: const PolylineId('garis_jarak'),
        points: [target, user],
        color: const Color(0xFF2563EB),
        width: 3,
        patterns: [PatternItem.dash(12), PatternItem.gap(8)],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final dalamJangkauan = state.dalamJangkauan;
    final target = _targetLatLng;
    final user = _userLatLng;
    final initialTarget = target ?? user ?? const LatLng(0, 0);

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
            color: Colors.black.withValues(alpha: 0.2),
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
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: target == null ? (user == null ? 2 : 15) : 17,
                ),
                mapType: MapType.normal,
                compassEnabled: true,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                markers: _markers(target, user),
                circles: _circles(target),
                polylines: _polylines(target, user),
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (target != null) unawaited(_aturKamera(target, user));
                },
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: target == null
                    ? null
                    : () => _bukaGoogleMaps(target.latitude, target.longitude),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: target == null
                        ? const Color(0xFF64748B)
                        : const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.map, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Maps',
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
            ),
          ),
        ],
      ),
    );
  }
}
