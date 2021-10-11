import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String phoneError;
  final bool enabled;
  final bool isRequired;
  final Function(String v) onChanged;
  final Function(String v) onSaved;
  final Widget suffix;
  final TextInputAction textInputAction;

  const PhoneTextField({
    Key key,
    this.enabled = true,
    this.isRequired = true,
    this.onSaved,
    this.suffix,
    this.textInputAction,
    @required this.controller,
    @required this.phoneError,
    @required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction ?? TextInputAction.next,
      decoration: InputDecoration(
        // labelText: "Telefon belgisi",
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 2),
          child: Text(
            '+ 993  ',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        errorText: phoneError,
        hintText: '__ ______',
        suffixIcon: suffix,
      ),
      validator: isRequired
          ? (String value) {
              if (value == null || value.isEmpty) {
                return 'Telefon belgiňizi ýazyň';
              }
              return null;
            }
          : null,
      onChanged: onChanged,
      inputFormatters: [
        LengthLimitingTextInputFormatter(8),
        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
      ],
    );
  }
}
