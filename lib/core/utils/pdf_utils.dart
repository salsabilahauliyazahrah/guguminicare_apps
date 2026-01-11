import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfUtils {
  static Future<PdfDocument> createPaymentReport({
    required List<Map<String, dynamic>> payments,
    required DateTime startDate,
    required DateTime endDate,
    required Map<String, dynamic> stats,
  }) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
    final PdfFont subtitleFont = PdfStandardFont(PdfFontFamily.helvetica, 14);
    final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfFont smallFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    
    // Add header with logo and title
    graphics.drawString(
      'GUGUMINI PET GROOMING',
      titleFont,
      bounds: Rect.fromLTWH(0, 40, page.getClientSize().width, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    
    graphics.drawString(
      'LAPORAN PEMBAYARAN',
      subtitleFont,
      bounds: Rect.fromLTWH(0, 80, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    graphics.drawString(
      'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
      normalFont,
      bounds: Rect.fromLTWH(0, 110, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    
    graphics.drawString(
      'Dibuat pada: ${dateFormat.format(DateTime.now())}',
      smallFont,
      bounds: Rect.fromLTWH(0, 130, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    
    // Add summary section
    graphics.drawString(
      'Ringkasan Statistik',
      PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(50, 170, page.getClientSize().width - 100, 20),
    );
    
    final summaryGrid = _createSummaryGrid(stats);
    summaryGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(50, 200, page.getClientSize().width - 100, 0),
    );
    
    // Add payments detail section
    final double startY = 300;
    graphics.drawString(
      'Detail Pembayaran',
      PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(50, startY, page.getClientSize().width - 100, 20),
    );
    
    final paymentsGrid = _createPaymentsGrid(payments);
    paymentsGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(50, startY + 30, page.getClientSize().width - 100, 0),
    );
    
    // Add footer
    graphics.drawString(
      '© ${DateTime.now().year} Gugumini Pet Grooming. All rights reserved.',
      smallFont,
      bounds: Rect.fromLTWH(0, page.getClientSize().height - 50, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    
    return document;
  }
  
  static PdfGrid _createSummaryGrid(Map<String, dynamic> stats) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 2);
    grid.style.cellPadding = PdfPaddings(left: 10, top: 8, right: 10, bottom: 8);
    grid.style.cellSpacing = 5;
    
    final numberFormat = NumberFormat('#,##0');
    
    final rows = [
      ['Total Pendapatan', 'Rp ${numberFormat.format(stats['totalRevenue'])}'],
      ['Transaksi Lunas', '${stats['completedCount']} transaksi'],
      ['Transaksi Pending', '${stats['pendingCount']} transaksi'],
      ['Transaksi Gagal', '${stats['failedCount']} transaksi'],
      ['Tingkat Penyelesaian', '${(stats['completionRate'] * 100).toStringAsFixed(1)}%'],
    ];
    
    for (var row in rows) {
      final gridRow = grid.rows.add();
      gridRow.cells[0].value = row[0];
      gridRow.cells[1].value = row[1];
      gridRow.cells[1].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right);
    }
    
    return grid;
  }
  
  static PdfGrid _createPaymentsGrid(List<Map<String, dynamic>> payments) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 7);
    grid.headers.add(1);
    grid.style.cellPadding = PdfPaddings(left: 5, top: 5, right: 5, bottom: 5);
    grid.style.cellSpacing = 3;
    
    // Header
    final PdfGridRow headerRow = grid.headers[0];
    final headers = ['No', 'ID', 'Pelanggan', 'Layanan', 'Jumlah', 'Metode', 'Status'];
    for (int i = 0; i < headers.length; i++) {
      headerRow.cells[i].value = headers[i];
      headerRow.cells[i].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
      headerRow.cells[i].style.backgroundBrush = PdfBrushes.lightGray;
    }
    
    // Data
    final numberFormat = NumberFormat('#,##0');
    // ignore: unused_local_variable
    final dateFormat = DateFormat('dd/MM/yy');
    
    for (int i = 0; i < payments.length; i++) {
      final payment = payments[i];
      final row = grid.rows.add();
      
      row.cells[0].value = (i + 1).toString();
      row.cells[1].value = payment['id'];
      row.cells[2].value = payment['customer_name'];
      row.cells[3].value = payment['service'];
      row.cells[4].value = 'Rp ${numberFormat.format(payment['amount'])}';
      row.cells[5].value = payment['method'];
      row.cells[6].value = payment['status_text'];
      
      // Format amount column to right alignment
      row.cells[4].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right);
    }
    
    return grid;
  }
}