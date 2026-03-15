import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../entities/form_field_entity.dart';
import '../../l10n/app_localizations.dart';
import '../theme/custom_text_style.dart';
import 'editable_dropdown.dart';

class DynamicFormController {
  VoidCallback? _submit;
  VoidCallback? _reset;

  void _attach(VoidCallback submit, VoidCallback reset) {
    _submit = submit;
    _reset = reset;
  }

  void submit() {
    _submit?.call();
  }

  void reset() {
    _reset?.call();
  }
}

class DynamicForm extends StatefulWidget {
  final List<FormFieldEntity> formData;
  final bool showSubmitButton;
  final bool isLoading;
  final bool fileUploaderState;
  final bool imageUploaderState;
  final bool isDark;
  final Color? textColor;
  final String buttonLabel;
  final Widget? button;
  final DynamicFormController? controller;
  final Map<String, dynamic>? initialValues;
  final Map<String, List<Map<String, dynamic>>>? dropdownOverrides;
  final List<String>? readOnlyKeys;
  final String? suffixCountryCode;
  final void Function(bool)? onChecked;
  final void Function(Map<String, dynamic>)? onChanged;
  final void Function(Map<String, dynamic>)? onClick;
  final void Function(String)? onRemoveFile;
  final void Function(String)? onRemoveImage;

  const DynamicForm({
    super.key,
    required this.formData,
    required this.buttonLabel,
    this.isDark = false,
    this.textColor,
    this.showSubmitButton = true,
    this.isLoading = false,
    this.fileUploaderState = false,
    this.imageUploaderState = false,
    this.button,
    this.controller,
    this.onClick,
    this.onChecked,
    this.onChanged,
    this.onRemoveFile,
    this.onRemoveImage,
    this.initialValues,
    this.dropdownOverrides,
    this.readOnlyKeys,
    this.suffixCountryCode,
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  bool isChecked = true;
  bool _submitted = false;
  final Map<String, Map<String, dynamic>?> _uploadedFiles = {};
  final ImagePicker _imagePicker = ImagePicker();

  Color get _primary => widget.textColor ?? AppColors.primaryPurple;

  Color get _inputText => widget.isDark ? Colors.white : Colors.black87;

  Color get _fillColor => Colors.transparent;

  Color get _fillReadOnly => widget.isDark
      ? Colors.grey[800]!.withOpacity(0.3)
      : Colors.grey[200]!.withOpacity(0.5);

  Color get _border => widget.isDark ? Colors.grey[700]! : Colors.grey.shade300;

  Color get _labelColor =>
      widget.isDark ? Colors.grey[400]! : Colors.grey[600]!;

  @override
  void initState() {
    super.initState();
    _initializeData();
    widget.controller?._attach(_submitForm, _resetForm);
  }

  void _submitForm() {
    for (var field in widget.formData) {
      final fieldName = field.name!;
      if (_controllers.containsKey(fieldName)) {
        _formData[fieldName] = _controllers[fieldName]!.text;
      }
    }

    setState(() => _submitted = true);

    bool filesValid = true;
    for (var field in widget.formData) {
      if (_isFieldVisible(field) &&
          field.required == true &&
          (field.type == 'fileUploader' || field.type == 'imageUploader')) {
        if (_uploadedFiles[field.name] == null) filesValid = false;
      }
    }

    final isFormValid = _formKey.currentState!.validate();

    if (isFormValid && filesValid) {
      setState(() => _submitted = false);
      _formKey.currentState!.reset();

      // build result: each field entity merged with its current value
      final Map<String, dynamic> result = {};
      for (var field in widget.formData) {
        final fieldName = field.name!;
        final fieldMap = field.toMap();
        fieldMap['value'] = _formData[fieldName];
        result[fieldName] = fieldMap;
      }

      widget.onClick?.call(result);
    }
  }

  void _resetForm() {
    setState(() {
      _submitted = false;
      _formKey.currentState?.reset();
    });
  }

  bool _isFieldReadOnly(String? fieldName) {
    if (fieldName == null) return false;
    return widget.readOnlyKeys?.contains(fieldName) ?? false;
  }

  bool _isFieldVisible(FormFieldEntity f) {
    if (f.dependOn == null || f.condition == null) return true;

    final condition = f.condition!;
    if (condition.contains('==')) {
      final parts = condition.split('==');
      final key = parts[0].trim();
      final value = parts[1].trim();
      return _formData[key]?.toString() == value;
    }
    return true;
  }

  void _initializeData() {
    if (widget.initialValues != null) {
      _formData.addAll(widget.initialValues!);
    }

    for (var field in widget.formData) {
      final fieldName = field.name!;
      final initialVal = _formData[fieldName] ?? field.defaultValue;

      _formData[fieldName] = initialVal;

      if (field.type == 'editableDropdown' ||
          field.type == 'text' ||
          field.type == 'number' ||
          field.type == 'email' ||
          field.type == 'telField' ||
          field.type == 'date' ||
          field.type == 'dateTime') {
        if (!_controllers.containsKey(fieldName)) {
          _controllers[fieldName] =
              TextEditingController(text: initialVal?.toString() ?? '');
        } else {
          _controllers[fieldName]!.text = initialVal?.toString() ?? '';
        }
      }
    }
  }

  Future<void> _pickFile(String fieldId) async {
    FilePickerResult? res = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
    if (res != null) {
      setState(() {
        _uploadedFiles[fieldId] = {
          'fileName': res.files.single.name,
          'fileSize': res.files.single.size,
          'mimeType': _getMimeType(res.files.single.name),
          'filePath': res.files.single.path,
          'needsUpload': true
        };
        _formData[fieldId] = _uploadedFiles[fieldId];
      });
      _triggerUpdate();
    }
  }

  Future<void> _pickImageFromSource(
      ImageSource s, String id, bool crop, List<String> types) async {
    final img = await _imagePicker.pickImage(source: s, imageQuality: 80);
    if (img != null) await _processImage(id, img, crop, types);
  }

  Future<void> _processImage(
      String id, XFile img, bool crop, List<String> types) async {
    File file = File(img.path);
    if (crop) {
      final cropped = await ImageCropper().cropImage(
          sourcePath: img.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop',
                toolbarColor: _primary,
                toolbarWidgetColor: Colors.white)
          ]);
      if (cropped != null) file = File(cropped.path);
    }
    final size = await file.length();
    setState(() {
      _uploadedFiles[id] = {
        'fileName': file.path.split('/').last,
        'fileSize': size,
        'mimeType': _getMimeType(file.path),
        'filePath': file.path,
        'needsUpload': true
      };
      _formData[id] = _uploadedFiles[id];
    });
    _triggerUpdate();
  }

  String _getMimeType(String n) {
    final ext = n.toLowerCase().split('.').last;
    if (ext == 'pdf') return 'application/pdf';
    if (ext == 'png') return 'image/png';
    return 'image/jpeg';
  }

  @override
  void didUpdateWidget(DynamicForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValues != oldWidget.initialValues) {
      setState(() {
        if (widget.initialValues != null) {
          _formData.addAll(widget.initialValues!);
        }
        for (var field in widget.formData) {
          final fieldName = field.name!;
          final newValue = widget.initialValues?[fieldName];

          if (newValue != null &&
              newValue.toString() != _controllers[fieldName]?.text) {
            if (_controllers.containsKey(fieldName)) {
              _controllers[fieldName]!.text = newValue.toString();
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  IconData _getIconData(String? iconName, String? fieldType) {
    final key = (iconName ?? fieldType ?? '').toLowerCase();

    if (key.contains('person') ||
        key.contains('name') ||
        key.contains('user')) {
      return FontAwesomeIcons.user;
    }
    if (key.contains('type') || key.contains('productvariety')) {
      return FontAwesomeIcons.layerGroup;
    }
    if (key.contains('email')) {
      return FontAwesomeIcons.envelope;
    }
    if (key.contains('phone') ||
        key.contains('mobile') ||
        key.contains('contact') ||
        key.contains('tel')) {
      return FontAwesomeIcons.phone;
    }
    if (key.contains('calendar') || key.contains('date')) {
      return FontAwesomeIcons.calendarDays;
    }
    if (key.contains('number') ||
        key.contains('price') ||
        key.contains('amount')) {
      return FontAwesomeIcons.hashtag;
    }
    if (key.contains('list') ||
        key.contains('select') ||
        key.contains('dropdown')) {
      return FontAwesomeIcons.listCheck;
    }
    if (key.contains('search')) {
      return FontAwesomeIcons.magnifyingGlass;
    }
    if (key.contains('language')) {
      return FontAwesomeIcons.language;
    }
    if (key.contains('currency') || key.contains('money')) {
      return FontAwesomeIcons.moneyBillWave;
    }
    if (key.contains('lock') || key.contains('password')) {
      return FontAwesomeIcons.lock;
    }
    if (key.contains('edit') || key.contains('update')) {
      return FontAwesomeIcons.penToSquare;
    }
    if (key.contains('area') ||
        key.contains('map') ||
        key.contains('location') ||
        key.contains('village') ||
        key.contains('district') ||
        key.contains('province')) {
      return FontAwesomeIcons.mapLocation;
    }
    if (key.contains('moisture') ||
        key.contains('water') ||
        key.contains('humidity')) {
      return FontAwesomeIcons.droplet;
    }
    if (key.contains('country')) {
      return FontAwesomeIcons.flag;
    }
    if (key.contains('nic') || key.contains('license') || key.contains('id')) {
      return FontAwesomeIcons.idCard;
    }
    if (key.contains('purity') ||
        key.contains('verify') ||
        key.contains('approved') ||
        key.contains('valid')) {
      return FontAwesomeIcons.circleCheck;
    }
    if (key.contains('farmer')) {
      return FontAwesomeIcons.tractor;
    }
    if (key.contains('collector') ||
        key.contains('warehouse') ||
        key.contains('store')) {
      return FontAwesomeIcons.warehouse;
    }
    if (key.contains('miller') ||
        key.contains('mill') ||
        key.contains('industry')) {
      return FontAwesomeIcons.industry;
    }
    if (key.contains('role') || key.contains('roles')) {
      return FontAwesomeIcons.users;
    }
    if (key.contains('file') ||
        key.contains('document') ||
        (key.contains("fileUploader"))) {
      return FontAwesomeIcons.file;
    }
    if (key.contains('cost') || key.contains('price')) {
      return FontAwesomeIcons.moneyBill;
    }
    if (key.contains('quantity') || key.contains('weight')) {
      return FontAwesomeIcons.weightScale;
    }
    return FontAwesomeIcons.circleInfo;
  }

  String _getLocalizedText(dynamic data, String locale) {
    if (data is Map) {
      return data[locale]?.toString() ?? data['en']?.toString() ?? "";
    }
    return data?.toString() ?? "";
  }

  void _showImageSourceSheet(String fieldId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(FontAwesomeIcons.camera, color: _primary),
              title: Text('Camera',
                  style: CustomTextStyle.googleInter(
                      fontSize: 15, color: _inputText)),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromSource(
                    ImageSource.camera, fieldId, true, ['jpg', 'png']);
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.image, color: _primary),
              title: Text('Gallery',
                  style: CustomTextStyle.googleInter(
                      fontSize: 15, color: _inputText)),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromSource(
                    ImageSource.gallery, fieldId, true, ['jpg', 'png']);
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(
      {required String label, String? name, String? type, Widget? prefix}) {
    final isReadOnly = _isFieldReadOnly(name);

    return InputDecoration(
        labelText: label,
        labelStyle:
            CustomTextStyle.googleInter(color: _labelColor, fontSize: 14),
        floatingLabelStyle: CustomTextStyle.googleInter(
            color: _primary, fontSize: 14, fontWeight: FontWeight.w600),
        fillColor: isReadOnly ? _fillReadOnly : _fillColor,
        filled: true,
        prefixIcon: prefix ??
            Icon(_getIconData(name, type), color: _inputText.withOpacity(0.5)));
  }

  Widget _buildFieldByType(FormFieldEntity f, String locale) {
    switch (f.type) {
      case 'text':
        return _buildTextField(f, locale);
      case 'number':
        return _buildNumberField(f, locale);
      case 'email':
        return _buildEmailField(f, locale);
      case 'telField':
        return _buildTelField(f, locale);
      case 'select':
        return _buildSelectField(f, locale);
      case 'radio':
        return _buildRadioField(f, locale);
      case 'switch':
        return _buildSwitchField(f, locale);
      case 'date':
        return _buildDateField(f, locale);
      case 'dateTime':
        return _buildDateTimeField(f, locale);
      case 'editableDropdown':
        return _buildEditableDropdownField(f, locale);
      case 'fileUploader':
        return _buildFileUploadField(f, locale);
      case 'imageUploader':
        return _buildFileUploadField(f, locale);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextField(FormFieldEntity f, String locale) {
    return TextFormField(
      controller: _controllers[f.name!],
      readOnly: _isFieldReadOnly(f.name),
      style: CustomTextStyle.googleInter(color: _inputText, fontSize: 15),
      decoration: _getInputDecoration(
          label: _getLocalizedText(f.displayName, locale),
          name: f.name,
          type: f.type),
      validator: (v) => _submitted ? _basicValidator(f, v, locale) : null,
      onChanged: (val) {
        setState(() => _formData[f.name!] = val);
        _triggerUpdate();
      },
    );
  }

  Widget _buildTelField(FormFieldEntity f, String locale) {
    return TextFormField(
      controller: _controllers[f.name!],
      readOnly: _isFieldReadOnly(f.name),
      keyboardType: TextInputType.phone,
      style: CustomTextStyle.googleInter(color: _inputText, fontSize: 15),
      decoration: _getInputDecoration(
        label: _getLocalizedText(f.displayName, locale),
        name: f.name,
        type: 'tel',
        prefix: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
            Icon(_getIconData(f.name, 'tel'),
                color: _inputText.withOpacity(0.5), size: 20),
            if (widget.suffixCountryCode != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                child: Text(
                  widget.suffixCountryCode!,
                  style: CustomTextStyle.googleInter(
                      color: _inputText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
            Container(
                height: 24,
                width: 1,
                color: _border,
                margin: const EdgeInsets.symmetric(horizontal: 8)),
          ],
        ),
      ),
      validator: (v) => _submitted ? _basicValidator(f, v, locale) : null,
      onChanged: (val) {
        setState(() => _formData[f.name!] = val);
        _triggerUpdate();
      },
    );
  }

  Widget _buildNumberField(FormFieldEntity f, String locale) {
    return TextFormField(
      controller: _controllers[f.name!],
      readOnly: _isFieldReadOnly(f.name),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: CustomTextStyle.googleInter(color: _inputText, fontSize: 15),
      decoration: _getInputDecoration(
          label: _getLocalizedText(f.displayName, locale),
          name: f.name,
          type: 'number'),
      validator: (v) => _submitted ? _basicValidator(f, v, locale) : null,
      onChanged: (val) {
        setState(() => _formData[f.name!] = val);
        _triggerUpdate();
      },
    );
  }

  Widget _buildEmailField(FormFieldEntity f, String locale) {
    return TextFormField(
      controller: _controllers[f.name!],
      readOnly: _isFieldReadOnly(f.name),
      keyboardType: TextInputType.emailAddress,
      style: CustomTextStyle.googleInter(color: _inputText, fontSize: 15),
      decoration: _getInputDecoration(
          label: _getLocalizedText(f.displayName, locale),
          name: f.name,
          type: 'email'),
      validator: (v) => _submitted ? _basicValidator(f, v, locale) : null,
      onChanged: (val) {
        setState(() => _formData[f.name!] = val);
        _triggerUpdate();
      },
    );
  }

  Widget _buildSelectField(FormFieldEntity f, String locale) {
    final options = widget.dropdownOverrides?[f.name] ?? f.optionValue ?? [];
    final isReadOnly = _isFieldReadOnly(f.name);

    return DropdownButtonFormField<String>(
      value: options.any(
              (opt) => opt['id'].toString() == _formData[f.name]?.toString())
          ? _formData[f.name].toString()
          : null,
      isExpanded: true,
      dropdownColor: widget.isDark ? Colors.grey[850] : Colors.white,
      onChanged: isReadOnly
          ? null
          : (val) {
              setState(() {
                _formData[f.name!] = val;
                if (f.name == "country") {
                  final selectedOpt = options.firstWhere(
                      (opt) => opt['id'].toString() == val.toString());
                  _formData['selected_country_code'] = selectedOpt['code'];
                  _formData['selected_country_currency'] =
                      selectedOpt['currency'];
                }
              });
              _triggerUpdate();
            },
      style: CustomTextStyle.googleInter(color: _inputText, fontSize: 15),
      decoration: _getInputDecoration(
          label: _getLocalizedText(f.displayName, locale),
          name: f.name,
          type: 'select'),
      items: options
          .map((opt) => DropdownMenuItem(
              value: opt['id'].toString(),
              child: Text(_getLocalizedText(opt['value'], locale),
                  style: CustomTextStyle.googleInter(
                      color: _inputText, fontSize: 15))))
          .toList(),
      validator: (v) => _submitted ? _basicValidator(f, v, locale) : null,
    );
  }

  Widget _buildRadioField(FormFieldEntity f, String locale) {
    final options = widget.dropdownOverrides?[f.name] ?? f.optionValue ?? [];
    final isReadOnly = _isFieldReadOnly(f.name);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_getLocalizedText(f.displayName, locale),
          style: CustomTextStyle.googleInter(
              color: _inputText, fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: isReadOnly ? _fillReadOnly : _fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Column(
            children: options
                .map((opt) => RadioListTile<String>(
                      title: Text(_getLocalizedText(opt['value'], locale),
                          style: CustomTextStyle.googleInter(
                              color: _inputText, fontSize: 15)),
                      value: opt['id'].toString(),
                      groupValue: _formData[f.name]?.toString(),
                      activeColor: _primary,
                      onChanged: isReadOnly
                          ? null
                          : (v) {
                              setState(() => _formData[f.name!] = v);
                              _triggerUpdate();
                            },
                    ))
                .toList()),
      ),
    ]);
  }

  Widget _buildSwitchField(FormFieldEntity f, String locale) {
    final options = widget.dropdownOverrides?[f.name] ?? f.optionValue ?? [];
    final isReadOnly = _isFieldReadOnly(f.name);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_getLocalizedText(f.displayName, locale),
          style: CustomTextStyle.googleInter(
              color: _inputText, fontSize: 14, fontWeight: FontWeight.bold)),
      ...options.map((opt) {
        final key = '${f.name}_${opt['id']}';
        return SwitchListTile(
          title: Text(_getLocalizedText(opt['value'], locale),
              style:
                  CustomTextStyle.googleInter(color: _inputText, fontSize: 15)),
          value: _formData[key] ?? false,
          activeColor: _primary,
          onChanged: isReadOnly
              ? null
              : (v) {
                  setState(() => _formData[key] = v);
                  _triggerUpdate();
                },
        );
      }),
    ]);
  }

  Widget _buildDateField(FormFieldEntity f, String locale) {
    final isReadOnly = _isFieldReadOnly(f.name);
    return TextFormField(
      readOnly: true,
      controller: _controllers[f.name!],
      style: CustomTextStyle.googleInter(color: _inputText, fontSize: 15),
      decoration: _getInputDecoration(
          label: _getLocalizedText(f.displayName, locale),
          name: f.name,
          type: 'date'),
      validator: (v) => _submitted ? _basicValidator(f, v, locale) : null,
      onTap: isReadOnly
          ? null
          : () async {
              final p = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100));
              if (p != null) {
                final formatted = p.toString().split(' ')[0];
                setState(() {
                  _formData[f.name!] = formatted;
                  _controllers[f.name!]!.text = formatted;
                });
                _triggerUpdate();
              }
            },
    );
  }

  Widget _buildDateTimeField(FormFieldEntity f, String locale) {
    final isReadOnly = _isFieldReadOnly(f.name);
    return TextFormField(
      readOnly: true,
      controller: _controllers[f.name!],
      style: CustomTextStyle.googleInter(color: _inputText, fontSize: 15),
      decoration: _getInputDecoration(
          label: _getLocalizedText(f.displayName, locale),
          name: f.name,
          type: 'dateTime'),
      validator: (v) => _submitted ? _basicValidator(f, v, locale) : null,
      onTap: isReadOnly
          ? null
          : () async {
              final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100));
              if (d != null) {
                final t = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());
                if (t != null) {
                  final dt =
                      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
                  setState(() {
                    _formData[f.name!] = dt;
                    _controllers[f.name!]!.text = dt;
                  });
                  _triggerUpdate();
                }
              }
            },
    );
  }

  Widget _buildEditableDropdownField(FormFieldEntity f, String locale) {
    final options = widget.dropdownOverrides?[f.name] ?? f.optionValue ?? [];
    final isReadOnly = _isFieldReadOnly(f.name);

    return IgnorePointer(
      ignoring: isReadOnly,
      child: EditableDropdown(
        controller: _controllers[f.name!]!,
        style: CustomTextStyle.googleInter(color: _inputText, fontSize: 15),
        options: options
            .map((opt) => _getLocalizedText(opt['value'], locale))
            .toList(),
        label: _getLocalizedText(f.displayName, locale),
        decoration: _getInputDecoration(
            label: _getLocalizedText(f.displayName, locale),
            name: f.name,
            type: 'search'),
        onChange: (val) {
          setState(() => _formData[f.name!] = val);
          _triggerUpdate();
        },
      ),
    );
  }

  Widget _buildFileUploadField(FormFieldEntity f, String locale) {
    final fieldName = f.name!;
    final fileData = _uploadedFiles[fieldName];
    final isReadOnly = _isFieldReadOnly(fieldName);
    final label = _getLocalizedText(f.displayName, locale);
    final l10n = AppLocalizations.of(context)!;

    final String? errorText =
        (_submitted && f.required == true && fileData == null)
            ? '${l10n.required}: $label'
            : null;

    bool isImage = false;
    if (fileData != null && fileData['mimeType'] != null) {
      isImage = (fileData['mimeType'] as String).contains('image');
    }

    final bool isImageUploader =
        f.type == 'imageUploader' || fieldName.toLowerCase().contains('image');
    final bool currentLoadingState =
        isImageUploader ? widget.imageUploaderState : widget.fileUploaderState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: _getInputDecoration(
                  label: label, name: fieldName, type: 'fileUploader')
              .copyWith(errorText: errorText),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fileData != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: _fillReadOnly,
                        child: isImage && fileData['filePath'] != null
                            ? Image.file(File(fileData['filePath']),
                                fit: BoxFit.cover)
                            : Icon(
                                (fileData['mimeType'] == 'application/pdf')
                                    ? FontAwesomeIcons.filePdf
                                    : FontAwesomeIcons.file,
                                color: _primary,
                                size: 24,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fileData['fileName'] ?? "",
                              style: CustomTextStyle.googleInter(
                                  color: _primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(
                              "${((fileData['fileSize'] ?? 0) / 1024).toStringAsFixed(1)} KB",
                              style: CustomTextStyle.googleInter(
                                  fontSize: 11, color: _labelColor)),
                        ],
                      ),
                    ),
                    if (!isReadOnly)
                      IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent, size: 20),
                          onPressed: () {
                            if (f.type == 'imageUploader') {
                              widget.onRemoveImage?.call(fieldName);
                            } else {
                              widget.onRemoveFile?.call(fieldName);
                            }
                            setState(() {
                              _uploadedFiles.remove(fieldName);
                              _formData.remove(fieldName);
                            });
                            _triggerUpdate();
                          }),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (!isReadOnly)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: currentLoadingState
                        ? null
                        : () {
                            if (isImageUploader) {
                              _showImageSourceSheet(fieldName);
                            } else {
                              _pickFile(fieldName);
                            }
                          },
                    icon: currentLoadingState
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: _primary, strokeWidth: 2))
                        : Icon(
                            isImageUploader
                                ? Icons.camera_alt_outlined
                                : Icons.upload_file,
                            size: 18,
                            color: _primary),
                    label: Text(
                        currentLoadingState
                            ? ''
                            : (fileData == null ? l10n.select : l10n.change),
                        style: CustomTextStyle.googleInter(
                            fontSize: 12, color: _primary)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: (widget.fileUploaderState || widget.imageUploaderState)
            ? null
            : _submitForm,
        icon: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(
          widget.buttonLabel,
          style: CustomTextStyle.googleInter(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary.withOpacity(0.6),
          disabledForegroundColor: Colors.white,
          elevation: widget.isDark ? 0 : 2,
          shadowColor:
              widget.isDark ? Colors.transparent : _primary.withOpacity(0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  String? _basicValidator(FormFieldEntity f, String? v, String lang) {
    final l10n = AppLocalizations.of(context);
    return (f.validate == true &&
            f.required == true &&
            (v == null || v.isEmpty))
        ? '${l10n.required}: ${_getLocalizedText(f.displayName, lang)}'
        : null;
  }

  void _triggerUpdate() => widget.onChanged?.call(_formData);

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              ...widget.formData
                  .where((f) => _isFieldVisible(f))
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildFieldByType(f, locale),
                      )),
              if (widget.showSubmitButton) ...[
                const SizedBox(height: 10),
                widget.button ?? _buildDefaultButton(),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
