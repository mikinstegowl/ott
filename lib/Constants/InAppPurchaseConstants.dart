// In-App Purchase Product Identifiers & Configurations
// Make sure these IDs match EXACTLY what is created in:
// 1. Google Play Console > Monetize > Products > In-app products / Subscriptions
// 2. App Store Connect > Monetization > In-App Purchases / Subscriptions

class InAppPurchaseConstants {
  // Subscription Products (Auto-renewable)
  static const String monthlySubscriptionId = 'ott_subscription_monthly';
  static const String yearlySubscriptionId = 'ott_subscription_yearly';

  // Consumable Products (e.g. Coins / Credits for unlocking episodes or shorts)
  static const String coins100Id = 'ott_coins_100';
  static const String coins500Id = 'ott_coins_500';

  // Non-Consumable Products (e.g. Lifetime VIP Pass, Remove Ads)
  static const String lifetimeVipId = 'ott_lifetime_vip';

  // All product IDs to query from Google Play Store & Apple App Store
  static const Set<String> allProductIds = {
    monthlySubscriptionId,
    yearlySubscriptionId,
    coins100Id,
    coins500Id,
    lifetimeVipId,
  };

  // Consumable Product IDs Set
  static const Set<String> consumableProductIds = {
    coins100Id,
    coins500Id,
  };

  // Subscriptions Product IDs Set
  static const Set<String> subscriptionProductIds = {
    monthlySubscriptionId,
    yearlySubscriptionId,
  };

  // Legal Links (MANDATORY for Apple App Store Subscriptions approval)
  static const String termsOfServiceUrl = 'https://yourwebsite.com/terms';
  static const String privacyPolicyUrl = 'https://yourwebsite.com/privacy';
}
