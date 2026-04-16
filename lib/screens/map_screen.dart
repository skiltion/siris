import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firestore_service.dart';
import '../models/insert_result.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirestoreService _firestore = FirestoreService();
  Set<Marker> markers = {};
  GoogleMapController? _mapController;
  LatLng _currentCenter = const LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    _checkPermissionAndTrack();
  }

  Future<void> _checkPermissionAndTrack() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        return;
      }
    }

    // 위치 스트리밍
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (!mounted) return;

      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
      });

      _moveToCurrentLocation();
    });
  }

  void _moveToCurrentLocation() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentCenter),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("위치 권한 필요"),
        content: const Text(
            "지도 기능을 사용하려면 위치 권한이 필요합니다. 설정에서 권한을 허용해주세요."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // 지도 생성 후, 초기 위치로 카메라 이동
    Future.delayed(const Duration(milliseconds: 300), () {
      _moveToCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("벌레 위치 지도"),
      backgroundColor: Colors.green[300],),
      body: StreamBuilder<List<InsectResult>>(
        stream: _firestore.getResultsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Firestore 마커 업데이트
          markers.clear();
          for (var res in snapshot.data!) {
            markers.add(
              Marker(
                markerId: MarkerId(res.timestamp.toIso8601String()),
                position: LatLng(res.latitude, res.longitude),
                infoWindow: InfoWindow(
                  title: res.className,
                  snippet:
                      '${res.insectType} (${(res.confidence * 100).toStringAsFixed(2)}%)',
                ),
              ),
            );
          }

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 14,
            ),
            markers: markers,
            myLocationEnabled: true,        // ← 내 위치 표시
            myLocationButtonEnabled: true,  // ← 내 위치 버튼 표시
            zoomControlsEnabled: false,
          );
        },
      ),
    );
  }
}
