class LabTestTemplate {
  final String name;
  final String category;
  final String unit;
  final double refMin;
  final double refMax;

  const LabTestTemplate({
    required this.name,
    required this.category,
    required this.unit,
    required this.refMin,
    required this.refMax,
  });
}

const List<LabTestTemplate> kCuratedLabTests = [
  LabTestTemplate(
    name: 'Fasting Blood Sugar (FBS)',
    category: 'Diabetes / Glycemia',
    unit: 'mg/dL',
    refMin: 70.0,
    refMax: 100.0,
  ),
  LabTestTemplate(
    name: 'Post-Prandial Blood Sugar (PPBS)',
    category: 'Diabetes / Glycemia',
    unit: 'mg/dL',
    refMin: 70.0,
    refMax: 140.0,
  ),
  LabTestTemplate(
    name: 'HbA1c (Glycated Hemoglobin)',
    category: 'Diabetes / Glycemia',
    unit: '%',
    refMin: 4.0,
    refMax: 5.6,
  ),
  LabTestTemplate(
    name: 'Serum Creatinine',
    category: 'Renal / Kidney Function',
    unit: 'mg/dL',
    refMin: 0.6,
    refMax: 1.2,
  ),
  LabTestTemplate(
    name: 'Blood Urea',
    category: 'Renal / Kidney Function',
    unit: 'mg/dL',
    refMin: 15.0,
    refMax: 40.0,
  ),
  LabTestTemplate(
    name: 'Serum Uric Acid',
    category: 'Renal / Gout',
    unit: 'mg/dL',
    refMin: 3.5,
    refMax: 7.2,
  ),
  LabTestTemplate(
    name: 'Thyroid Stimulating Hormone (TSH)',
    category: 'Thyroid Panel',
    unit: 'uIU/mL',
    refMin: 0.4,
    refMax: 4.5,
  ),
  LabTestTemplate(
    name: 'Total Cholesterol',
    category: 'Lipid Profile',
    unit: 'mg/dL',
    refMin: 125.0,
    refMax: 200.0,
  ),
  LabTestTemplate(
    name: 'Triglycerides',
    category: 'Lipid Profile',
    unit: 'mg/dL',
    refMin: 50.0,
    refMax: 150.0,
  ),
  LabTestTemplate(
    name: 'HDL Cholesterol',
    category: 'Lipid Profile',
    unit: 'mg/dL',
    refMin: 40.0,
    refMax: 60.0,
  ),
  LabTestTemplate(
    name: 'LDL Cholesterol',
    category: 'Lipid Profile',
    unit: 'mg/dL',
    refMin: 50.0,
    refMax: 100.0,
  ),
  LabTestTemplate(
    name: 'Hemoglobin (Hb)',
    category: 'Complete Blood Count (CBC)',
    unit: 'g/dL',
    refMin: 12.0,
    refMax: 16.0,
  ),
  LabTestTemplate(
    name: 'Total Leucocyte Count (TLC / WBC)',
    category: 'Complete Blood Count (CBC)',
    unit: '/mcL',
    refMin: 4000.0,
    refMax: 11000.0,
  ),
  LabTestTemplate(
    name: 'Platelet Count',
    category: 'Complete Blood Count (CBC)',
    unit: '/mcL',
    refMin: 150000.0,
    refMax: 450000.0,
  ),
  LabTestTemplate(
    name: 'Erythrocyte Sedimentation Rate (ESR)',
    category: 'Inflammatory Markers',
    unit: 'mm/hr',
    refMin: 0.0,
    refMax: 20.0,
  ),
  LabTestTemplate(
    name: 'SGPT / ALT (Alanine Aminotransferase)',
    category: 'Liver Function Test (LFT)',
    unit: 'U/L',
    refMin: 7.0,
    refMax: 56.0,
  ),
  LabTestTemplate(
    name: 'SGOT / AST (Aspartate Aminotransferase)',
    category: 'Liver Function Test (LFT)',
    unit: 'U/L',
    refMin: 10.0,
    refMax: 40.0,
  ),
  LabTestTemplate(
    name: 'Total Bilirubin',
    category: 'Liver Function Test (LFT)',
    unit: 'mg/dL',
    refMin: 0.2,
    refMax: 1.2,
  ),
  LabTestTemplate(
    name: 'Vitamin D (25-OH)',
    category: 'Vitamins & Minerals',
    unit: 'ng/mL',
    refMin: 30.0,
    refMax: 100.0,
  ),
  LabTestTemplate(
    name: 'Vitamin B12',
    category: 'Vitamins & Minerals',
    unit: 'pg/mL',
    refMin: 200.0,
    refMax: 900.0,
  ),
];

String computeLabFlag(double? value, double? min, double? max) {
  if (value == null) return 'Normal';
  if (max != null && value > max) return 'High';
  if (min != null && value < min) return 'Low';
  return 'Normal';
}
