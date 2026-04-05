// lib/features/marketplace/presentation/pages/add_product_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../domain/entities/seller.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String _category = 'Vegetables';
  String _unit = 'kg';
  File? _imageFile;
  bool _uploading = false;

  final _imageService = ImageUploadService();

  static const _categories = [
    'Vegetables', 'Fruits', 'Grains', 'Legumes', 'Herbs', 'Dairy', 'Other'
  ];
  static const _units = ['kg', 'g', 'bunch', 'piece', 'litre', 'bottle', 'bag'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _imageService.pickImage(source: source);
    if (file != null) setState(() => _imageFile = File(file.path));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.photo_library_outlined,
                    color: AppColors.primaryGreen),
              ),
              title: const Text('Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.camera_alt_outlined,
                    color: AppColors.primaryGreen),
              ),
              title: const Text('Take a Photo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_imageFile != null)
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: const Text('Remove Photo',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imageFile = null);
                },
              ),
          ]),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) return;

    setState(() => _uploading = true);

    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _imageService.uploadProductImage(
          imageFile: _imageFile!,
          userId: auth.uid,
        );
      }

      if (!mounted) return;

      final product = ProductEntity(
        id: '',
        name: _nameCtrl.text.trim(),
        category: _category.toLowerCase(),
        pricePerUnit: double.parse(_priceCtrl.text.trim()),
        unit: _unit,
        availableQuantity: double.parse(_qtyCtrl.text.trim()),
        sellerId: auth.uid,
        sellerName: auth.displayName ?? 'Farmer',
        location: _locationCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageUrl: imageUrl,
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      context.read<MarketplaceBloc>().add(CreateProductEvent(product: product));
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MarketplaceBloc, MarketplaceState>(
      listener: (context, state) {
        if (state is ProductCreatedState) {
          setState(() => _uploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Your crop has been listed successfully!'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          Navigator.pop(context, true); // return true → caller can refresh
        } else if (state is MarketplaceErrorState) {
          setState(() => _uploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4F5F7),
          elevation: 0,
          title: const Text('List a Crop',
              style: TextStyle(fontWeight: FontWeight.w700)),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // ── Photo picker ──────────────────────────────────────
              _sectionLabel('Product Photo'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _imageFile != null
                          ? AppColors.primaryGreen
                          : const Color(0xFFE0E0E0),
                      width: _imageFile != null ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _imageFile != null
                      ? Stack(fit: StackFit.expand, children: [
                          Image.file(_imageFile!, fit: BoxFit.cover),
                          Positioned(
                            bottom: 8, right: 8,
                            child: GestureDetector(
                              onTap: _showImageSourceSheet,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.edit,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ])
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primaryGreen.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_photo_alternate_outlined,
                                  size: 36, color: AppColors.primaryGreen),
                            ),
                            const SizedBox(height: 10),
                            const Text('Tap to add a photo',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen)),
                            const SizedBox(height: 4),
                            const Text('Gallery or Camera  •  Optional',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Basic details ─────────────────────────────────────
              _sectionLabel('Crop Details'),
              const SizedBox(height: 8),
              _card(Column(children: [
                _field(
                  controller: _nameCtrl,
                  label: 'Crop Name',
                  hint: 'e.g. Tomatoes, Coconut, Rice',
                  icon: Icons.eco_outlined,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter crop name' : null,
                ),
                const Divider(height: 1),
                _dropdownField(
                  label: 'Category',
                  icon: Icons.category_outlined,
                  value: _category,
                  items: _categories,
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const Divider(height: 1),
                _field(
                  controller: _descCtrl,
                  label: 'Description',
                  hint: 'Quality, growing conditions, harvest date…',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                ),
              ])),
              const SizedBox(height: 16),

              // ── Pricing & quantity ────────────────────────────────
              _sectionLabel('Pricing & Quantity'),
              const SizedBox(height: 8),
              _card(Column(children: [
                _field(
                  controller: _priceCtrl,
                  label: 'Price per Unit (Rs.)',
                  hint: 'e.g. 120',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter price';
                    if (double.tryParse(v.trim()) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const Divider(height: 1),
                _dropdownField(
                  label: 'Unit',
                  icon: Icons.scale_outlined,
                  value: _unit,
                  items: _units,
                  onChanged: (v) => setState(() => _unit = v!),
                ),
                const Divider(height: 1),
                _field(
                  controller: _qtyCtrl,
                  label: 'Available Quantity',
                  hint: 'e.g. 50',
                  icon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter quantity';
                    if (double.tryParse(v.trim()) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ])),
              const SizedBox(height: 16),

              // ── Location ─────────────────────────────────────────
              _sectionLabel('Location'),
              const SizedBox(height: 8),
              _card(_field(
                controller: _locationCtrl,
                label: 'Your Location',
                hint: 'e.g. Kandy, Central Province',
                icon: Icons.location_on_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter location' : null,
              )),
              const SizedBox(height: 28),

              // ── Submit ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _uploading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor:
                        AppColors.primaryGreen.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _uploading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('List My Crop',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper widgets ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.5));

  Widget _card(Widget child) => Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8))),
      child: child);

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      );

  Widget _dropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                labelText: null,
              ),
              isExpanded: true,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ]),
      );
}
