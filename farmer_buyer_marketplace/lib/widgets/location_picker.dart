import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationPicker extends StatefulWidget {
  final Function(String) onLocationSelected;
  const LocationPicker({super.key, required this.onLocationSelected});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String? _selectedAddress;
  bool _isLoading = false;

  Future<void> _getCurrentLocation() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    try {
      final position = await LocationService.getCurrentPosition();
      final address = await LocationService.getAddressFromLatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _selectedAddress = address);
      widget.onLocationSelected(address);
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedAddress != null) Text('Location: $_selectedAddress'),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _getCurrentLocation,
          icon: const Icon(Icons.my_location),
          label: Text(_isLoading ? 'Getting location...' : 'Use Current Location'),
        ),
      ],
    );
  }
}