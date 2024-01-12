import 'package:flutter/material.dart';

class MainMenuWidget extends StatelessWidget {
  final Function(String) onShowCameraPressed;
  final VoidCallback showSettingsPanel;

  const MainMenuWidget({
    Key? key,
    required this.onShowCameraPressed,
    required this.showSettingsPanel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
            height: 120, child: Image.asset('assets/ic_veryfi_logo_black.PNG')),
        Container(
          margin: const EdgeInsets.all(12.0),
          child: Material(
            color: Colors.white,
            elevation: 10,
            borderRadius: BorderRadius.circular(7.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20.0,),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Solutions',
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF171C3A)),
                    ),
                  ),
                ),
                ...menuOptions.map((option) => Padding(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      option['icon'],
                      size: 24.0,
                      color: const Color(0xFF171C3A),
                    ),
                    title: Text(
                      option['title'],
                      style: const TextStyle(
                          fontSize: 14.0, color: Color(0xFF171C3A)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.settings, size: 27.0, color: Color(0xFF171C3A)),
                      onPressed: showSettingsPanel,
                    ),
                    onTap: () => onShowCameraPressed(option['title']),
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final List<Map<String, dynamic>> menuOptions = [
  {
    'title': 'Lens for Receipts & Invoices',
    'icon': Icons.receipt_long,
  },
  {
    'title': 'Lens for Long Receipts',
    'icon': Icons.receipt,
  },
  {
    'title': 'Lens for Checks',
    'icon': Icons.account_balance_wallet,
  },
  {
    'title': 'Lens for Credit Cards',
    'icon': Icons.credit_card,
  },
  {
    'title': 'Lens for Business Cards',
    'icon': Icons.business_center,
  },
  {
    'title': 'Lens for OCR',
    'icon': Icons.text_fields,
  },
  {
    'title': 'Lens for W-2',
    'icon': Icons.library_books,
  },
  {
    'title': 'Lens for W-9',
    'icon': Icons.library_books,
  },
  {
    'title': 'Lens for Bank Statements',
    'icon': Icons.account_balance,
  },
  {
    'title': 'Lens for Barcodes',
    'icon': Icons.qr_code_scanner,
  },
];

final List<Map<String, dynamic>> headlessOptions = [
  {
    'title': 'Headless Receipts',
    'icon': Icons.receipt_long,
  },
  {
    'title': 'Headless Credit Card',
    'icon': Icons.credit_card,
  },
];

