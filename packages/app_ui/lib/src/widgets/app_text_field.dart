import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.onChanged,
    required this.label,
    required this.hint,
    super.key,
  });

  final void Function(String)? onChanged;
  final String label;
  final String hint;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final borderRadius = BorderRadius.circular(context.radius.sm);

    OutlineInputBorder getBorder(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      autocorrect: false,
      minLines: 1,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        filled: true,
        fillColor: colors.surfaceContainerLow,
        enabledBorder: getBorder(colors.outline),
        focusedBorder: getBorder(colors.tertiary),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.cancel),
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              onPressed: _clear,
            );
          },
        ),
      ),
    );
  }
}
