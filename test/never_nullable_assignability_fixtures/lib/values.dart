// Keep the written Never? annotation to test its normalization to Null.
// ignore_for_file: prefer_void_to_null, specify_nonobvious_property_types

class Values {
  late Never? value;
}

String? acceptNullableString(Never? value) => value;
