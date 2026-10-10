
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/features/trip/order_details/data/models/update_delivery_location_request_body.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_customer_location.dart';


class OrderAddressEditSheet extends StatefulWidget {
  const OrderAddressEditSheet({
    super.key,
    required this.tripId,
    required this.orderId,
    required this.location,
  });

  final int tripId;
  final int orderId;
  final OrderCustomerLocation location;

  @override
  State<OrderAddressEditSheet> createState() =>
      _OrderAddressEditSheetState();
}

class _OrderAddressEditSheetState
    extends State<OrderAddressEditSheet> {
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;

  double? _latitude;
  double? _longitude;
  double? _accuracy;
  bool _saving = false;
  bool _locating = false;
  bool _review = false;

  @override
  void initState() {
    super.initState();

    _addressController = TextEditingController(
      text: widget.location.address,
    );
    _notesController = TextEditingController();

    if (widget.location.hasCoordinates) {
      _latitude = widget.location.latitude;
      _longitude = widget.location.longitude;
    }


    _phoneController = TextEditingController(
      text: widget.location.phone,
    );

    _cityController = TextEditingController();

    _countryController = TextEditingController(
      text: 'Egypt',
    );

  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }


  Future<void> _showSaveErrorDialog(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.red1,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.strings.order_location_save_failed,
                  style: Styles.textStyle18.copyWith(
                    color: AppColors.red1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textDirection: TextDirection.rtl,
            style: Styles.textStyle14.copyWith(
              color: AppColors.black1,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                context.strings.back,
              ),
            ),
          ],
        );
      },
    );
  }

  bool get _hasPosition =>
      _latitude != null && _longitude != null;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  // ======= Get Device Location ======= //
  Future<void> _useCurrentLocation() async {
    if (_locating) return;

    setState(() => _locating = true);

    try {
      final enabled =
      await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        if (mounted) {
          _showMessage(
            context.strings.trip_accept_location_disabled,
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showMessage(
            context.strings.order_location_permission_required,
          );
        }
        return;
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showMessage(
            context.strings.trip_accept_location_permission_denied,
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _accuracy = position.accuracy;
      });
    } catch (_) {
      if (mounted) {
        _showMessage(
          context.strings.order_location_fetch_failed,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }


// ======= Review Before Save ======= //
  void _goToReview() {
    if (_addressController.text.trim().isEmpty) {
      _showMessage(
        context.strings.order_address_required,
      );
      return;
    }

    if (!_hasPosition) {
      _showMessage(
        context.strings.order_location_required,
      );
      return;
    }

    setState(() {
      _review = true;
    });
  }


  Future<void> _confirmSave() async {
    if (_saving) return;

    final address = _addressController.text.trim();
    final latitude = _latitude;
    final longitude = _longitude;

    // ======= Validate Address ======= //
    if (address.isEmpty) {
      _showMessage(context.strings.order_address_required);
      return;
    }

    // ======= Validate Location ======= //
    if (latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      _showMessage(context.strings.order_location_required);
      return;
    }

    final cubit = context.read<OrderDetailsCubit>();

    final body = UpdateDeliveryLocationBody(
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: _phoneController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
    );

    setState(() => _saving = true);

    try {
      // ======= Execute PATCH ======= //
      final error = await cubit.updateDeliveryLocation(
        tripId: widget.tripId,
        orderId: widget.orderId,
        body: body,
      );

      if (!mounted) return;

      // ======= Failure ======= //
      if (error != null) {
        final message = error == 'order_location_save_failed'
            ? context.strings.order_location_save_failed
            : error;

        await _showSaveErrorDialog(message);
        return;
      }

      // ======= Success Only ======= //
      Navigator.of(context).pop();

      await cubit.getOrderDetails(
        tripId: widget.tripId,
        orderId: widget.orderId,
      );
    } catch (_) {
      if (!mounted) return;

      await _showSaveErrorDialog(
        context.strings.order_location_save_failed,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }



  String _formatCoordinate(double? value) {
    return value?.toStringAsFixed(7) ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final height = MediaQuery.sizeOf(context).height * .87;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: (height - bottomInset)
              .clamp(350.0, height)
              .toDouble(),
          child: Column(
            children: [
              // ======= Header ======= //
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20, 20, 20, 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.strings.order_update_address,
                        style: Styles.textStyle20.copyWith(
                          color: AppColors.black1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

              // ======= Content ======= //
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: _review
                      ? _buildReview()
                      : _buildEditor(),
                ),
              ),

              // ======= Fixed Actions ======= //
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20, 12, 20, 20,
                ),
                child: Column(
                  children: [

                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: ElevatedButton.icon(
                        onPressed: _saving
                            ? null
                            : _review
                            ? _confirmSave
                            : _goToReview,

                        icon: _saving
                            ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.white0,
                            strokeWidth: 2,
                          ),
                        )
                            : Icon(
                          _review
                              ? Icons.check_circle_outline_rounded
                              : Icons.save_outlined,
                        ),

                        label: Text(
                          _saving
                              ? context.strings.order_location_saving
                              : _review
                              ? context.strings.order_confirm_save
                              : context.strings.order_save_address,
                          style: Styles.textStyle18.copyWith(
                            color: AppColors.white0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),
                    if (_review)
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () {
                          setState(() => _review = false);
                        },
                        child: Text(
                          context.strings.order_back_to_edit,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ======= Existing Data ======= //
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.strings.order_current_saved_data,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.grey4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.location.hasAddress
                    ? widget.location.address
                    : context.strings.order_no_address,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.location.hasCoordinates
                    ? '${widget.location.latitude}, '
                    '${widget.location.longitude}'
                    : context.strings.order_customer_gps_missing,
                style: Styles.textStyle12.copyWith(
                  color: AppColors.grey4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          height: 62,
          child: ElevatedButton.icon(
            onPressed: _locating ? null : _useCurrentLocation,
            icon: _locating
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.my_location_rounded),
            label: Text(
              _hasPosition
                  ? context.strings.order_reselect_location
                  : context.strings.order_use_current_location,
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.blue4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ======= Real Map Preview ======= //
        if (_hasPosition) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 180,
              child: GoogleMap(
                key: ValueKey(
                  '${_latitude}_$_longitude',
                ),
                initialCameraPosition: CameraPosition(
                  target: LatLng(_latitude!, _longitude!),
                  zoom: 16,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('customer_location'),
                    position: LatLng(_latitude!, _longitude!),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                onTap: (coordinate) {
                  setState(() {
                    _latitude = coordinate.latitude;
                    _longitude = coordinate.longitude;

                    // Manual selection has no GPS accuracy value.
                    _accuracy = null;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _CoordinateValue(
                  label: context.strings.order_latitude,
                  value: _formatCoordinate(_latitude),
                ),
              ),
              Expanded(
                child: _CoordinateValue(
                  label: context.strings.order_longitude,
                  value: _formatCoordinate(_longitude),
                ),
              ),
            ],
          ),

          if (_accuracy != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '${context.strings.order_location_accuracy} '
                    '±${_accuracy!.toStringAsFixed(0)} '
                    '${context.strings.order_meters}',
                style: Styles.textStyle12.copyWith(
                  color: AppColors.orange0,
                ),
              ),
            ),

          const SizedBox(height: 10),
        ],

        // ======= Address Field ======= //
        Text(
          context.strings.order_correct_address,
          style: Styles.textStyle16.copyWith(
            color: AppColors.black1,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _addressController,
          textDirection: TextDirection.rtl,
          maxLines: 3,
          minLines: 2,
          decoration: _inputDecoration(),
        ),


        const SizedBox(height: 18),

// ======= Shop Phone ======= //
        Text(
          context.strings.order_delivery_phone,
          style: Styles.textStyle16.copyWith(
            color: AppColors.black1,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          decoration: _inputDecoration().copyWith(
            hintText: '01XXXXXXXXX',
          ),
        ),

        const SizedBox(height: 18),

// ======= City ======= //
        Text(
          context.strings.order_delivery_city,
          style: Styles.textStyle16.copyWith(
            color: AppColors.black1,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _cityController,
          textDirection: TextDirection.rtl,
          decoration: _inputDecoration().copyWith(
            hintText: context.strings.order_delivery_city_hint,
          ),
        ),

        const SizedBox(height: 18),

// ======= Country ======= //
        Text(
          context.strings.order_delivery_country,
          style: Styles.textStyle16.copyWith(
            color: AppColors.black1,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _countryController,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          decoration: _inputDecoration().copyWith(
            hintText: 'Egypt',
          ),
        ),

        const SizedBox(height: 18),

        Text(
          context.strings.order_optional_notes,
          style: Styles.textStyle16.copyWith(
            color: AppColors.black1,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _notesController,
          textDirection: TextDirection.rtl,
          minLines: 2,
          maxLines: 3,
          decoration: _inputDecoration(),
        ),

        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.strings.order_confirm_data_before_save,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.grey4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _ReviewRow(
                title: context.strings.order_correct_address,
                value: _addressController.text.trim(),
              ),
              _ReviewRow(
                title: 'Latitude',
                value: _formatCoordinate(_latitude),
              ),
              _ReviewRow(
                title: 'Longitude',
                value: _formatCoordinate(_longitude),
              ),
              if (_accuracy != null)
                _ReviewRow(
                  title: context.strings.order_location_accuracy,
                  value:
                  '±${_accuracy!.toStringAsFixed(0)} '
                      '${context.strings.order_meters}',
                ),

              _ReviewRow(
                title: context.strings.order_delivery_phone,
                value: _phoneController.text.trim().isEmpty
                    ? '—'
                    : _phoneController.text.trim(),
              ),

              _ReviewRow(
                title: context.strings.order_delivery_city,
                value: _cityController.text.trim().isEmpty
                    ? '—'
                    : _cityController.text.trim(),
              ),

              _ReviewRow(
                title: context.strings.order_delivery_country,
                value: _countryController.text.trim().isEmpty
                    ? '—'
                    : _countryController.text.trim(),
              ),

              if (_notesController.text.trim().isNotEmpty)
                _ReviewRow(
                  title: context.strings.order_optional_notes,
                  value: _notesController.text.trim(),
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Text(
          context.strings.order_confirm_location_warning,
          textAlign: TextAlign.center,
          style: Styles.textStyle14.copyWith(
            color: AppColors.grey4,
          ),
        ),
      ],
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.grey5,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.grey0,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: AppColors.grey3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: AppColors.grey3),
      ),
    );
  }
}

class _CoordinateValue extends StatelessWidget {
  const _CoordinateValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Styles.textStyle12),
        const SizedBox(height: 4),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: Styles.textStyle14.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: Styles.textStyle14.copyWith(
                color: AppColors.grey4,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Styles.textStyle14.copyWith(
                color: AppColors.black1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
