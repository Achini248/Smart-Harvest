import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/crop.dart';

class CropForm extends StatefulWidget {
  final Crop? initialCrop;        // null = add mode, non-null = edit mode
  final String ownerId;
  final void Function(Crop crop) onSubmit;
  final bool isLoading;

  const CropForm({
    super.key,
    this.initialCrop,
    required this.ownerId,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<CropForm> createState() => _CropFormState();
}

class _CropFormState extends State<CropForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _notesCtrl;

  late CropType _selectedType;
  late CropStatus _selectedStatus;
  late String _selectedUnit;
  late DateTime _plantedDate;
  DateTime? _harvestDate;

  final List<String> _units = ['kg', 'g', 'tonnes', 'bags', 'crates', 'units'];

  bool get _isEditMode => widget.initialCrop != null;

  @override
  void initState() {
    super.initState();
    final crop = widget.initialCrop;
    _nameCtrl = TextEditingController(text: crop?.name ?? '');
    _quantityCtrl =
        TextEditingController(text: crop?.quantity.toString() ?? '');
    _locationCtrl = TextEditingController(text: crop?.location ?? '');
    _notesCtrl = TextEditingController(text: crop?.notes ?? '');

    _selectedType = crop != null
        ? CropTypeExtension.fromString(crop.type)
        : CropType.vegetable;
    _selectedStatus = crop != null
        ? CropStatusExtension.fromString(crop.status)
        : CropStatus.planted;
    _selectedUnit = crop?.unit ?? 'kg';
    _plantedDate = crop?.plantedDate ?? DateTime.now();
    _harvestDate = crop?.harvestDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final crop = Crop(
      id: widget.initialCrop?.id ?? '',
      name: _nameCtrl.text.trim(),
      type: _selectedType.name,
      quantity: double.parse(_quantityCtrl.text.trim()),
      unit: _selectedUnit,
      location: _locationCtrl.text.trim(),
      plantedDate: _plantedDate,
      harvestDate: _harvestDate,
      status: _selectedStatus.name,
      notes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
      ownerId: widget.ownerId,
      createdAt: widget.initialCrop?.createdAt ?? now,
      updatedAt: now,
    );

    widget.onSubmit(crop);
  }

  Future<void> _pickDate({required bool isHarvestDate}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isHarvestDate
          ? (_harvestDate ?? _plantedDate.add(const Duration(days: 30)))
          : _plantedDate,
      firstDate: isHarvestDate ? _plantedDate : DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isHarvestDate) {
          _harvestDate = picked;
        } else {
          _plantedDate = picked;
          // Clear harvest date if it's before planted date
          if (_harvestDate != null &&
              _harvestDate!.isBefore(_plantedDate)) {
            _harvestDate = null;
          }
        }
      });
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 13),
        labelStyle:
            TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.error, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Crop name ────────────────────────────────────────────────
          TextFormField(
            controller: _nameCtrl,
            enabled: !widget.isLoading,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Crop name is required.';
              }
              if (v.trim().length < 2) {
                return 'Name must be at least 2 characters.';
              }
              return null;
            },
            decoration: _inputDecoration(
              label: 'Crop Name',
              hint: 'e.g. Tomatoes',
              icon: Icons.grass,
            ),
          ),

          const SizedBox(height: 16),

          // ── Crop type dropdown ────────────────────────────────────────
          _SectionLabel(label: 'Crop Type'),
          const SizedBox(height: 8),
          DropdownButtonFormField<CropType>(
            value: _selectedType,
            decoration: _inputDecoration(
              label: '',
              hint: 'Select type',
              icon: Icons.category_outlined,
            ),
            items: CropType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.label),
              );
            }).toList(),
            onChanged: widget.isLoading
                ? null
                : (value) => setState(() => _selectedType = value!),
            validator: (v) =>
                v == null ? 'Please select a crop type.' : null,
          ),

          const SizedBox(height: 16),

          // ── Quantity + unit ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _quantityCtrl,
                  enabled: !widget.isLoading,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Required.';
                    }
                    final qty = double.tryParse(v.trim());
                    if (qty == null || qty <= 0) {
                      return 'Enter valid quantity.';
                    }
                    return null;
                  },
                  decoration: _inputDecoration(
                    label: 'Quantity',
                    hint: '100',
                    icon: Icons.straighten,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: _inputDecoration(
                    label: 'Unit',
                    hint: 'kg',
                    icon: Icons.scale_outlined,
                  ).copyWith(
                    prefixIcon: null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                  items: _units.map((unit) {
                    return DropdownMenuItem(
                        value: unit, child: Text(unit));
                  }).toList(),
                  onChanged: widget.isLoading
                      ? null
                      : (v) => setState(() => _selectedUnit = v!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Location ──────────────────────────────────────────────────
          TextFormField(
            controller: _locationCtrl,
            enabled: !widget.isLoading,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Location is required.';
              }
              return null;
            },
            decoration: _inputDecoration(
              label: 'Location / Field',
              hint: 'e.g. North Field, Gampaha',
              icon: Icons.location_on_outlined,
            ),
          ),

          const SizedBox(height: 16),

          // ── Planted date ──────────────────────────────────────────────
          _SectionLabel(label: 'Planted Date'),
          const SizedBox(height: 8),
          InkWell(
            onTap: widget.isLoading
                ? null
                : () => _pickDate(isHarvestDate: false),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.shade200, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 20, color: AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_plantedDate),
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down,
                      color: Colors.grey.shade500),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Expected harvest date ─────────────────────────────────────
          _SectionLabel(label: 'Expected Harvest Date (Optional)'),
          const SizedBox(height: 8),
          InkWell(
            onTap: widget.isLoading
                ? null
                : () => _pickDate(isHarvestDate: true),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.shade200, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 20,
                    color: _harvestDate != null
                        ? AppColors.primaryGreen
                        : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _harvestDate != null
                        ? DateFormat('dd MMMM yyyy').format(_harvestDate!)
                        : 'Tap to select',
                    style: TextStyle(
                      fontSize: 14,
                      color: _harvestDate != null
                          ? AppColors.textPrimary
                          : Colors.grey.shade400,
                    ),
                  ),
                  const Spacer(),
                  if (_harvestDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _harvestDate = null),
                      child: Icon(Icons.clear,
                          size: 18, color: Colors.grey.shade500),
                    )
                  else
                    Icon(Icons.arrow_drop_down,
                        color: Colors.grey.shade500),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Status (edit mode only) ───────────────────────────────────
          if (_isEditMode) ...[
            _SectionLabel(label: 'Status'),
            const SizedBox(height: 8),
            DropdownButtonFormField<CropStatus>(
              value: _selectedStatus,
              decoration: _inputDecoration(
                label: '',
                hint: 'Select status',
                icon: Icons.info_outline,
              ),
              items: CropStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.label),
                );
              }).toList(),
              onChanged: widget.isLoading
                  ? null
                  : (v) => setState(() => _selectedStatus = v!),
            ),
            const SizedBox(height: 16),
          ],

          // ── Notes ─────────────────────────────────────────────────────
          TextFormField(
            controller: _notesCtrl,
            enabled: !widget.isLoading,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              label: 'Notes (Optional)',
              hint: 'Any additional information...',
              icon: Icons.notes_outlined,
            ),
          ),

          const SizedBox(height: 28),

          // ── Submit button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                disabledBackgroundColor:
                    AppColors.primaryGreen.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: widget.isLoading ? null : _onSubmit,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _isEditMode ? 'Update Crop' : 'Add Crop',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }
}
