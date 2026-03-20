import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_bloc.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_event.dart';
import 'package:flutter_bloc_app/bloc/user/user_bloc.dart';
import 'package:flutter_bloc_app/bloc/user/user_event.dart';
import 'package:flutter_bloc_app/bloc/user/user_state.dart';
import 'package:flutter_bloc_app/widgets/custom_dropdown.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/blocs.dart';
import '../../bloc/locale/app_locales.dart';
import '../../bloc/locale/locale_event.dart';
import '../../bloc/locale/locale_state.dart';
import '../../dtos/business.dart';
import '../../dtos/business_type.dart';
import '../../entities/user_entity.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BluetoothDevice? _selectedDevice;
  bool _showDeviceList = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionHeader(title: l10n.theme).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return _SettingsTile(
                icon: state.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: state.isDark ? l10n.darkMode : l10n.lightMode,
                trailing: Switch.adaptive(
                  value: state.isDark,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (_) =>
                      context.read<ThemeBloc>().add(ThemeToggleEvent()),
                ),
              );
            },
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05, end: 0, delay: 300.ms),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.language).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 12),
          BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, state) {
              return Column(
                children: AppLocales.supported.map((locale) {
                  final isSelected =
                      state.locale.languageCode == locale.languageCode;
                  return _LanguageTile(
                    locale: locale,
                    isSelected: isSelected,
                    onTap: () => context
                        .read<LocaleBloc>()
                        .add(LocaleChangeEvent(locale)),
                  );
                }).toList(),
              );
            },
          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.05, end: 0, delay: 500.ms),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.businessTemplate)
              .animate()
              .fadeIn(delay: 400.ms),
          const SizedBox(height: 12),
          _showBusinessConfig(user!.uid, l10n)
              .animate()
              .fadeIn(delay: 700.ms)
              .slideX(begin: -0.05, end: 0, delay: 700.ms),
          const SizedBox(height: 24),
          _SectionHeader(title: "Printer Setting")
              .animate()
              .fadeIn(delay: 400.ms),
          const SizedBox(height: 12),
          _buildDeviceSection(),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.account).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 24),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: l10n.signOut,
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () => _showSignOutDialog(context, l10n),
          ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.05, end: 0, delay: 700.ms),

        ],
      ),
    );
  }

  Widget _buildDeviceSection() {
    final selectedDevice = context.watch<ScannerBloc>().state.selectedDevice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              selectedDevice != null ? Icons.print : Icons.print_outlined,
              color: selectedDevice != null ? Colors.green : AppTheme.primaryColor,
            ),
            title: Text(
              selectedDevice != null
                  ? (selectedDevice.name ?? 'Unknown Device')
                  : 'No printer selected',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selectedDevice != null ? Colors.green : null,
              ),
            ),
            subtitle: Text(
              selectedDevice != null
                  ? selectedDevice.address
                  : 'Tap to scan and select a printer',
            ),
            trailing: TextButton.icon(
              onPressed: () =>
                  setState(() => _showDeviceList = !_showDeviceList),
              icon: Icon(_showDeviceList
                  ? Icons.expand_less
                  : Icons.bluetooth_searching),
              label: Text(_showDeviceList ? 'Hide' : 'Scan'),
            ),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (_showDeviceList) _buildDeviceList(),
      ],
    );
  }

  Widget _buildDeviceList() {
    final selectedDevice = context.watch<ScannerBloc>().state.selectedDevice;

    return Container(
      height: 220,
      margin: const EdgeInsets.only(top: 4),
      child: StreamBuilder(
        stream: FlutterBluetoothPrinter.discovery,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Scanning for devices...'),
                ],
              ),
            );
          }

          List<BluetoothDevice> devices = [];
          try {
            final dynamic d = snapshot.data;
            if (d?.devices != null) {
              devices = List<BluetoothDevice>.from(d.devices as List);
            }
          } catch (_) {
            devices = [];
          }

          if (devices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bluetooth_disabled, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No devices found',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              final isSelected =
                  selectedDevice?.address == device.address;

              return ListTile(
                dense: true,
                leading: Icon(
                  Icons.print,
                  color: isSelected ? Colors.green : Colors.grey,
                ),
                title: Text(device.name ?? 'Unknown Device'),
                subtitle: Text(
                  device.address,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.radio_button_unchecked,
                    color: Colors.grey),
                onTap: () {
                  context.read<ScannerBloc>().add(SelectDevice(device: device));
                  setState(() => _showDeviceList = false);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _showBusinessConfig(String uid, AppLocalizations l10n) {
    return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
      if (state.status == UserStatus.initial) {
        context.read<UserBloc>().add(GetUser(uid: uid));
        return const Center(child: CircularProgressIndicator());
      }

      if (state.status == UserStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state.status == UserStatus.loaded) {
        final businesses = state.user?.business ?? [];

        if (businesses.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.business_center_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(l10n.noBusinessTemplate,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showAddEditBusinessDialog(context, null, l10n),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addBusiness),
                  )
                ],
              ),
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0);
        }

        return Column(
          children: [
            ...businesses.map((b) => _SettingsTile(
              icon: Icons.business_rounded,
              title: b.businessName,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () =>
                        _showAddEditBusinessDialog(context, b, l10n),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    onPressed: () => _showDeleteBusinessDialog(
                        context, b, state.user!, l10n),
                  ),
                ],
              ),
              onTap: () => _showAddEditBusinessDialog(context, b, l10n),
            )),
            TextButton.icon(
              onPressed: () => _showAddEditBusinessDialog(context, null, l10n),
              icon: const Icon(Icons.add),
              label: Text(l10n.addBusiness),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  void _showDeleteBusinessDialog(BuildContext context, Business business,
      UserEntity currentUser, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text("${l10n.deleteMessage} \"${business.businessName}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final List<Business> updatedList =
              List.from(currentUser.business ?? [])
                ..removeWhere((e) => e.uid == business.uid);
              context.read<UserBloc>().add(UpdateUser(
                uid: currentUser.uid,
                user: currentUser.copyWith(business: updatedList),
              ));
              Navigator.pop(ctx);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<XFile?> _pickAndCropImage(
      ImageSource source, BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return null;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Logo',
          toolbarColor: AppTheme.primaryColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          hideBottomControls: false,
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: 'Crop Logo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
      ],
    );

    if (cropped == null) return null;
    return XFile(cropped.path);
  }

  void _showAddEditBusinessDialog(
      BuildContext context, Business? business, AppLocalizations l10n) {
    final nameController = TextEditingController(text: business?.businessName);
    final addressController = TextEditingController(text: business?.address);
    final contactController = TextEditingController(text: business?.contact);
    final emailController = TextEditingController(text: business?.email);
    final formKey = GlobalKey<FormState>();
    BusinessType? selectedBusinessType;
    XFile? pickedImage;
    String? existingLogoUrl = business?.logoUrl;
    bool isUploading = false;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setState) {
            return BlocBuilder<MasterDataBloc, MasterDataState>(
              builder: (context, masterState) {
                if (masterState.status == MasterDataStatus.initial ||
                    masterState.setting?.business == null) {
                  context.read<MasterDataBloc>().add(const LoadMasterData());
                }

                final List<BusinessType> businessTypes =
                    masterState.setting?.business ?? [];

                if (selectedBusinessType == null &&
                    business != null &&
                    businessTypes.isNotEmpty) {
                  selectedBusinessType = businessTypes.firstWhere(
                        (e) => e.uid == business.businessType.uid,
                    orElse: () => businessTypes.first,
                  );
                }

                Future<String?> uploadLogo(String businessUid) async {
                  if (pickedImage == null) return existingLogoUrl;
                  try {
                    final ref = FirebaseStorage.instance
                        .ref()
                        .child('business_logos/$businessUid.jpg');
                    await ref.putFile(File(pickedImage!.path));
                    return await ref.getDownloadURL();
                  } catch (e) {
                    return null;
                  }
                }

                void showImageSourceSheet() {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (_) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt_outlined),
                            title: const Text("Camera"),
                            onTap: () async {
                              Navigator.pop(context);
                              final file = await _pickAndCropImage(
                                  ImageSource.camera, context);
                              if (file != null) {
                                setState(() => pickedImage = file);
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library_outlined),
                            title: const Text("Gallery"),
                            onTap: () async {
                              Navigator.pop(context);
                              final file = await _pickAndCropImage(
                                  ImageSource.gallery, context);
                              if (file != null) {
                                setState(() => pickedImage = file);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                Future<void> onConfirm() async {
                  if (!formKey.currentState!.validate()) return;
                  if (selectedBusinessType == null) return;

                  setState(() => isUploading = true);

                  final businessUid = business?.uid ??
                      DateTime.now().millisecondsSinceEpoch.toString();
                  final logoUrl = await uploadLogo(businessUid);

                  final newBusiness = Business(
                    uid: businessUid,
                    businessName: nameController.text.trim(),
                    businessType: selectedBusinessType!,
                    address: addressController.text.trim(),
                    contact: contactController.text.trim(),
                    email: emailController.text.trim(),
                    logoUrl: logoUrl,
                  );

                  final currentUser = context.read<UserBloc>().state.user!;
                  final List<Business> updatedList =
                  List.from(currentUser.business ?? []);

                  if (business == null) {
                    updatedList.add(newBusiness);
                  } else {
                    final index =
                    updatedList.indexWhere((e) => e.uid == business.uid);
                    if (index != -1) updatedList[index] = newBusiness;
                  }

                  context.read<UserBloc>().add(UpdateUser(
                    uid: currentUser.uid,
                    user: currentUser.copyWith(business: updatedList),
                  ));

                  setState(() => isUploading = false);
                  Navigator.of(context).pop();
                }

                return Scaffold(
                  appBar: AppBar(
                    title: Text(business == null
                        ? l10n.addBusiness
                        : l10n.editBusiness),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed:
                      isUploading ? null : () => Navigator.of(context).pop(),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: isUploading
                            ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                        )
                            : TextButton(
                          onPressed: onConfirm,
                          child: Text(
                            l10n.confirm,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: Form(
                    key: formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: isUploading ? null : showImageSourceSheet,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppTheme.primaryColor
                                        .withOpacity(0.3)),
                              ),
                              child: pickedImage != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(pickedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : existingLogoUrl != null
                                  ? ClipRRect(
                                borderRadius:
                                BorderRadius.circular(16),
                                child: Image.network(
                                  existingLogoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _logoPlaceholder(),
                                ),
                              )
                                  : _logoPlaceholder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppTheme.primaryColor),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed:
                              isUploading ? null : showImageSourceSheet,
                              icon: const Icon(Icons.camera_alt_outlined,
                                  size: 18, color: AppTheme.primaryColor),
                              label: Text(
                                pickedImage == null && existingLogoUrl == null
                                    ? l10n.select
                                    : l10n.change,
                                style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 12),
                              ),
                            ),
                            if (pickedImage != null ||
                                existingLogoUrl != null) ...[
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: isUploading
                                    ? null
                                    : () => setState(() {
                                  pickedImage = null;
                                  existingLogoUrl = null;
                                }),
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red),
                                label: Text(l10n.remove,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomDropdown<BusinessType>(
                          prefixIcon: Icons.category,
                          label: l10n.businessType,
                          items: businessTypes.map((type) {
                            return DropdownMenuItem<BusinessType>(
                              value: type,
                              child: Text(type.name),
                            );
                          }).toList(),
                          value: selectedBusinessType,
                          onChanged: (value) {
                            setState(() => selectedBusinessType = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: nameController,
                          label: l10n.businessName,
                          prefixIcon: Icons.business,
                          validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: addressController,
                          label: l10n.address,
                          prefixIcon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: contactController,
                          label: l10n.contact,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: emailController,
                          label: l10n.email,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isUploading ? null : onConfirm,
                            child: isUploading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                                : Text(l10n.confirm),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _logoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 36, color: AppTheme.primaryColor.withOpacity(0.5)),
        const SizedBox(height: 8),
        Text(
          "Tap to add logo",
          style: TextStyle(
              fontSize: 12, color: AppTheme.primaryColor.withOpacity(0.5)),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOut),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLogoutEvent());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppTheme.primaryColor,
        letterSpacing: 1.0,
        fontSize: 12,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: titleColor,
          ),
        ),
        trailing: trailing ??
            (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Text(
          AppLocales.getFlag(locale),
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          AppLocales.getLanguageName(locale),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.primaryColor : null,
          ),
        ),
        subtitle: Text(
          locale.languageCode == 'en'
              ? 'English'
              : locale.languageCode == 'si'
              ? 'Sinhala'
              : 'Tamil',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded,
            color: AppTheme.primaryColor)
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}