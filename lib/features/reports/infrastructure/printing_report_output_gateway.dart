import 'dart:typed_data';

import 'package:printing/printing.dart';

import '../application/report_service.dart';

/// Printing-package adapter for platform print and share capabilities.
class PrintingReportOutputGateway implements ReportOutputGateway {
  const PrintingReportOutputGateway();

  @override
  Future<bool> printPdf(Uint8List bytes, {required String documentName}) async {
    return Printing.layoutPdf(name: documentName, onLayout: (_) async => bytes);
  }

  @override
  Future<bool> sharePdf(Uint8List bytes, {required String fileName}) async {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
    return true;
  }
}
