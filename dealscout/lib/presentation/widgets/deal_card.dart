import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class DealCard extends StatelessWidget {
  final Map<String, dynamic> deal;

  const DealCard({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    final discountPercent = deal['discountValue'] ?? 0;
    final expiryDate = deal['expiryDate'] != null 
        ? (deal['expiryDate'] as dynamic).toDate() 
        : DateTime.now().add(const Duration(days: 7));
    final isExpiringSoon = expiryDate.difference(DateTime.now()).inDays <= 2;

    return GestureDetector(
      onTap: () => context.push('/deal/${deal['id']}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          boxShadow: AppTheme.cardShadow(),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal Image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: deal['images'] != null && deal['images'].isNotEmpty
                      ? Image.network(
                          deal['images'][0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.store,
                                size: 40,
                                color: AppTheme.primary.withOpacity(0.5),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppTheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.store,
                            size: 40,
                            color: AppTheme.primary.withOpacity(0.5),
                          ),
                        ),
                ),
                
                // Discount Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.secondaryGradient,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Text(
                      '$discountPercent% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, size: 20),
                      onPressed: () {
                        // Toggle favorite
                      },
                      padding: const EdgeInsets.all(4),
                    ),
                  ),
                ),
                
                // Expiring Soon Badge
                if (isExpiringSoon)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Expiring Soon',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Deal Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Name
                    Text(
                      deal['merchantName'] ?? 'Unknown Store',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Deal Title
                    Text(
                      deal['title'] ?? 'Amazing Deal',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Distance and Rating
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppTheme.textSecondaryLight.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDistance(deal['distance']),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryLight.withOpacity(0.7),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star, size: 14, color: AppTheme.warning),
                        const SizedBox(width: 4),
                        Text(
                          NumberFormat('#,##0.0').format(deal['rating'] ?? 4.5),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(dynamic distance) {
    if (distance == null) return '? km';
    final d = distance is num ? distance.toDouble() : 1.0;
    if (d < 1) {
      return '${(d * 1000).round()} m';
    }
    return '${d.toStringAsFixed(1)} km';
  }
}
