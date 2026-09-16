import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/item_layanan_model.dart';
import 'kartu_item_layanan.dart';

class KategoriLayanan extends StatelessWidget {
  final String judulKategori;
  final List<ItemLayananModel> itemLayanan;

  const KategoriLayanan({
    super.key,
    required this.judulKategori,
    required this.itemLayanan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          judulKategori,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth >= Responsive.mobileMax;
            if (isWide) {
              double cardWidth = (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: itemLayanan
                    .map(
                      (item) => SizedBox(
                        width: cardWidth,
                        child: KartuItemLayanan(item: item),
                      ),
                    )
                    .toList(),
              );
            }
            return Column(
              children:
                  itemLayanan.map((item) => KartuItemLayanan(item: item)).toList(),
            );
          },
        ),
      ],
    );
  }
}
