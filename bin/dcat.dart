import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const lineNumber = 'line-number';

void main(List<String> arguments) {
  generatePdf();
}

Future<void> generatePdf() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text("Hello World"),
        ); // Center
      },
    ),
  );

  final file = File("example.pdf");
  await file.writeAsBytes(await pdf.save());
  print('Pdf generated');
}

Future<void> dcat(List<String> paths, {bool showLineNumbers = false}) async {
  if (paths.isEmpty) {
    // No files provided as arguments. Read from stdin and print each line.
    await stdin.pipe(stdout);
  } else {
    for (final path in paths) {
      var lineNumber = 1;
      final lines = utf8.decoder.bind(File(path).openRead()).transform(const LineSplitter());
      try {
        await for (final line in lines) {
          if (showLineNumbers) {
            stdout.write('${lineNumber++} ');
          }
          stdout.writeln(line);
        }
      } catch (_) {
        await _handleError(path);
      }
    }
  }
}

Future<void> _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('error: $path is a directory');
  } else {
    exitCode = 2;
  }
}
