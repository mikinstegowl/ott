class SubscriptionModel {
  bool? success;
  bool? hasSubscription;
  Subscription? subscription;
  String? msgHeader;
  String? msgDesc;
  String? msgBtn;

  SubscriptionModel(
      {this.success,
      this.hasSubscription,
      this.subscription,
      this.msgHeader,
      this.msgDesc,
      this.msgBtn});

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    hasSubscription = json['has_subscription'];
    subscription = json['subscription'] != null
        ? Subscription.fromJson(json['subscription'])
        : null;
    msgHeader = json['msg_header'];
    msgDesc = json['msg_desc'];
    msgBtn = json['msg_btn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['has_subscription'] = hasSubscription;
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    data['msg_header'] = msgHeader;
    data['msg_desc'] = msgDesc;
    data['msg_btn'] = msgBtn;
    return data;
  }
}

class Subscription {
  int? id;
  String? paypalSubscriptionId;
  String? status;
  Plan? plan;
  String? startsAt;
  String? endsAt;
  String? nextBillingAt;
  String? cancelledAt;
  String? cancelReason;

  Subscription(
      {this.id,
        this.paypalSubscriptionId,
        this.status,
        this.plan,
        this.startsAt,
        this.endsAt,
        this.nextBillingAt,
        this.cancelledAt,
        this.cancelReason});

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paypalSubscriptionId = json['paypal_subscription_id'];
    status = json['status'];
    plan = json['plan'] != null ? Plan.fromJson(json['plan']) : null;
    startsAt = json['starts_at'];
    endsAt = json['ends_at'];
    nextBillingAt = json['next_billing_at'];
    cancelledAt = json['cancelled_at'];
    cancelReason = json['cancel_reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['paypal_subscription_id'] = paypalSubscriptionId;
    data['status'] = status;
    if (plan != null) {
      data['plan'] = plan!.toJson();
    }
    data['starts_at'] = startsAt;
    data['ends_at'] = endsAt;
    data['next_billing_at'] = nextBillingAt;
    data['cancelled_at'] = cancelledAt;
    data['cancel_reason'] = cancelReason;
    return data;
  }
}

class Plan {
  int? id;
  String? name;
  String? billingCycle;
  String? price;
  String? currency;
  String? maxQuality;
  int? maxScreens;

  Plan(
      {this.id,
        this.name,
        this.billingCycle,
        this.price,
        this.currency,
        this.maxQuality,
        this.maxScreens});

  Plan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    billingCycle = json['billing_cycle'];
    price = json['price'];
    currency = json['currency'];
    maxQuality = json['max_quality'];
    maxScreens = json['max_screens'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['billing_cycle'] = billingCycle;
    data['price'] = price;
    data['currency'] = currency;
    data['max_quality'] = maxQuality;
    data['max_screens'] = maxScreens;
    return data;
  }
}
