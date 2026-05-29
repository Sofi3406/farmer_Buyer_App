import 'package:flutter/material.dart';

class LocationPicker extends StatefulWidget {
  final Function(String) onLocationSelected;
  const LocationPicker({super.key, required this.onLocationSelected});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Farm Location',
            hintText: 'Enter your village, town, or area',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your farm location' : null,
          onChanged: (value) {
            widget.onLocationSelected(value.trim());
          },
        ),
      ],
    );
  }
}