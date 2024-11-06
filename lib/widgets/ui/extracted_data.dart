import 'package:flutter/material.dart';
import 'package:veryfi_flutter_lens_demo/models/extracted_data_model.dart';

class ExtractedDataWidget extends StatelessWidget {
  final ExtractedData? _extractedData;

  const ExtractedDataWidget(this._extractedData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9ECE4),
      body: _buildExtractedDataView(),
    );
  }

  Widget _buildExtractedDataView() {
    if (_extractedData == null) {
      return const Center(child: Text('No extracted data'));
    }

    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Material(
        elevation: 10,
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Extracted fields',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Color(0xFF171C3A)),
              ),
            ),
            _buildListTile('ID', _extractedData.id ?? "Not available"),
            _buildListTile('Invoice Number',
                _extractedData.invoiceNumber ?? "Not available"),
            _buildListTile('Currency Code',
                _extractedData.currencyCode ?? "Not available"),
            _buildListTile('Tax',
                _extractedData.tax?.toStringAsFixed(2) ?? "Not available"),
            _buildListTile(
                'Category', _extractedData.category ?? "Not available"),
            _buildListTile('Image File Name',
                _extractedData.imgFileName ?? "Not available"),
            _buildListTile(
                'Reference', _extractedData.reference ?? "Not available"),
            _buildListTile(
                'Created Date', _extractedData.createdDate ?? "Not available"),
            _buildListTile('Thumbnail Url',
                _extractedData.imgThumbNail ?? "Not available",
                isUrl: true),
            _buildListTile(
                'Image Url', _extractedData.imgUrl ?? "Not available",
                isUrl: true),
            _buildListTile('Pdf Url', _extractedData.pdfUrl ?? "Not available",
                isUrl: true),
            _buildListTile(
                'Store Number', _extractedData.storeNumber ?? "Not available"),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String value, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF171C3A)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: isUrl
                ? SelectableText(
                    value,
                    style: const TextStyle(color: Color(0xFF171C3A)),
                    textAlign: TextAlign.right,
                  )
                : Text(
                    value,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.right,
                  ),
          ),
        ],
      ),
    );
  }
}

