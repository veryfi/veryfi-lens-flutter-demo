class ExtractedData {
  String? id;
  String? invoiceNumber;
  String? currencyCode;
  double? tax;
  String? category;
  String? imgFileName;
  String? reference;
  String? createdDate;
  String? imgThumbNail;
  String? imgUrl;
  String? pdfUrl;
  String? storeNumber;

  ExtractedData(
      {this.id,
        this.invoiceNumber,
        this.currencyCode,
        this.tax,
        this.category,
        this.imgFileName,
        this.reference,
        this.createdDate,
        this.imgThumbNail,
        this.imgUrl,
        this.pdfUrl,
        this.storeNumber});

  factory ExtractedData.fromJson(Map<String, dynamic> json) {
    return ExtractedData(
      id: json['id']?.toString(),
      invoiceNumber: json['invoice_number'],
      currencyCode: json['currency_code'],
      tax: json['tax'] != null ? double.tryParse(json['tax'].toString()) : null,
      category: json['category'],
      imgFileName: json['img_file_name'],
      reference: json['reference_number'],
      createdDate: json['created_date'],
      imgThumbNail: json['img_thumbnail_url'].toString(),
      imgUrl: json['img_url'].toString(),
      pdfUrl: json['pdf_url'].toString(),
      storeNumber: json['store_number'].toString(),
    );
  }
}
