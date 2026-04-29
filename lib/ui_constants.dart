import 'package:flutter/material.dart';

// Colors
const Color kBrandPurple = Color(0xFF6A35C3);
const Color kHeaderDivider = Color(0xFFE6E6E6);
const Color kYesNoPurple = Color(0xFF7A45E5); // base for toggles/buttons/checkboxes

// Layout
const double kContentMaxWidth = 1600;
const double kDesktopBreakpoint = 1280;
const double kTopBarHeight = 56;

// Table
const double kHeaderPaddingV = 14;
const double kHeaderPaddingH = 12;
const double kFeatureCellPaddingH = 16;
const double kFeatureCellPaddingV = 12;

// Checkboxes/text
const double kCheckboxGlyph = 18;
const double kCheckboxToLabelGap = 6; // horizontal
const double kChecklistRowGap = 6; // vertical gap between rows
const double kLabelLineHeight = 1.35; // readability

// Borders
final TableBorder kTableBorder = TableBorder(
  horizontalInside: BorderSide(color: Colors.black26, width: 1),
  verticalInside: BorderSide(color: Colors.black26, width: 1),
  top: const BorderSide(color: Colors.black54, width: 1.5),
  bottom: const BorderSide(color: Colors.black54, width: 1.5),
  left: const BorderSide(color: Colors.black54, width: 1.5),
  right: const BorderSide(color: Colors.black54, width: 1.5),
); 