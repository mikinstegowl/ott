// In-App Purchase product identifiers.
//
// These are now only a FALLBACK. The live ids come from the server
// (GET /app/products) and are managed in the admin panel, so adding a plan or
// renaming a store product needs no app release and no store review.
//
// They still have to match exactly what exists in:
// 1. Google Play Console > Monetize > Products > Subscriptions
// 2. App Store Connect > your app > Subscriptions

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

  // Legal links. MANDATORY for App Store subscription approval — Apple rejects
  // a subscription screen without working Terms and Privacy links.
  // The server also returns these in /app/products ('legal'); prefer those.
  static const String termsOfServiceUrl = 'https://trebolplus.com/terms-of-use';
  static const String privacyPolicyUrl = 'https://trebolplus.com/privacy-policy';
}
