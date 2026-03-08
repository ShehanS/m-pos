import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EditableDropdown extends StatefulWidget {
  final TextEditingController controller;
  final List<String> options;
  final String label;
  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;
  final TextStyle? style;
  final ValueChanged<String>? onChange;

  const EditableDropdown({
    super.key,
    required this.controller,
    required this.options,
    required this.label,
    this.validator,
    this.decoration,
    this.style,
    this.onChange,
  });

  @override
  State<EditableDropdown> createState() => _EditableDropdownState();
}

class _EditableDropdownState extends State<EditableDropdown> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onTextChange() {
    final input = widget.controller.text.toLowerCase();
    setState(() {
      if (input.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions = widget.options.where((option) => option.toLowerCase().contains(input)).toList();
      }
    });
    if (_focusNode.hasFocus) {
      _updateOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            child: _filteredOptions.isEmpty
                ? const SizedBox.shrink()
                : ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredOptions.length,
                itemBuilder: (context, index) {
                  final option = _filteredOptions[index];
                  return InkWell(
                    onTap: () {
                      widget.controller.text = option;
                      widget.onChange?.call(option);
                      _focusNode.unfocus();
                      _removeOverlay();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        option,
                        style: widget.style?.copyWith(fontSize: 14) ??
                            const TextStyle(color: AppColors.black, fontSize: 14.0),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: widget.decoration,
        style: widget.style ?? const TextStyle(color: AppColors.black, fontSize: 15),
        validator: widget.validator ?? (v) => v == null || v.isEmpty ? 'Enter ${widget.label.toLowerCase()}' : null,
        onChanged: (val) {
          widget.onChange?.call(val);
        },
      ),
    );
  }
}