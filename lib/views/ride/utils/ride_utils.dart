

class RideUtils {
  static double calculateRidePrice(double? distanceInKm) {
    if (distanceInKm == null || distanceInKm < 0) return 20.0;

    const double baseFare = 20;
    const double perKmRate = 20;

    return baseFare + (distanceInKm * perKmRate);
  }

  static Map<String, double> getNegotiablePriceRange(
    double? distanceInKm, {
    double marginPercent = 20,
  }) {
    if (distanceInKm == null || distanceInKm < 0) {
      return {'min': 0.0, 'max': 0.0, 'base': 0.0};
    }

    final double basePrice = calculateRidePrice(distanceInKm);
    final double margin = (marginPercent / 100) * basePrice;

    return {
      'min': basePrice - margin,
      'max': basePrice + margin,
      'base': basePrice,
    };
  }
}
