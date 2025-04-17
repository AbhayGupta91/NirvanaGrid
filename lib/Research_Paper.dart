import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

void ShowResearchPdf(BuildContext context) async {
  try {
    final pdfDocument = await PdfDocument.openAsset('assets/project_x_research.pdf');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: PdfView(controller: PdfController(document: Future.value(pdfDocument))), // ✅ Fix applied here
              ),
            ],
          ),
        ),
      ),
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to load PDF: $e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
