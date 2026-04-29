import 'feature_row.dart';

const List<FeatureRow> kSwedeFeatures = [
  FeatureRow(
    id: 'aw_color',
    title: 'Color of Acetowhite\n(AW) Area',
    col0: [
      'Low Intensity Acetowhitening',
      'Snow White',
      'Shiny AW',
      'Indistinct AW',
      'Transparent AW',
      'AW Beyond Transformation Zone',
    ],
    col1: [
      'Intermediate shade - gray/white color AW and shiny surface (most lesions should be scored in this)',
    ],
    col2: [
      'Dull',
      'Opaque',
      'Oyster White',
      'Grey',
    ],
  ),
  FeatureRow(
    id: 'aw_margin',
    title: 'AW Lesion Margin\n& Surface\nConfiguration',
    col0: [
      'Feathered Margins',
      'Angular Lesions',
      'Jagged Lesions',
      'Flat Lesions with Indistinct Margins',
      'Microcondylomatous Surface',
      'Micropapillary Surface',
      'Satellite Lesions Beyond the Margin Transformation Zone',
    ],
    col1: [
      'Regular-shaped, symmetrical lesions with smooth straight outlines',
    ],
    col2: [
      'Rolled',
      'Peeling',
      'Internal demarcations (a central area of high-grade change and peripheral area of low-grade change)',
    ],
  ),
  FeatureRow(
    id: 'vessels',
    title: 'Vessels',
    col0: [
      'Fine/Uniform-Calibre Vessels',
      'Poorly Formed Patterns of FinePunctation and/or Fine Mosaic',
      'Vessels Beyond the Margin of the Transformation Zone',
      'Fine Vessels within Micro-condylomatous or Micropapillary',
    ],
    col1: [
      'Absent vessels',
    ],
    col2: [
      'Well defined coarsepunctation or mosaic',
      'Sharply demarcated and randomly and widely placed',
    ],
  ),
  FeatureRow(
    id: 'iodine',
    title: 'Iodine Staining',
    col0: [
      'Positive iodine uptake giving mahogany-brown color',
      'Negative uptake of insignificant lesion i.e., yellow staining by a lesion scoring 3 points or less on the first 3 criteria',
      'Areas beyond the margin of the transformation zone, conspicuous on colposcope, evident as iodine-negative',
    ],
    col1: [
      'Partial iodine uptake by a lesion scoring 4 or more points on above 3 categories - variegated',
      'Speckled Appearance',
    ],
    col2: [
      'Negative iodine uptake of significant lesion i.e., yellow staining by a lesion already scoring four points or more on the first three criteria',
    ],
  ),
];


