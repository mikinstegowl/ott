import 'package:flutter_test/flutter_test.dart';
import 'package:ottapp/Models/GeneralErrorModel.dart';
import 'package:ottapp/Models/PlayResponseModel.dart';
import 'package:ottapp/Models/SearchResponseModel.dart';
import 'package:ottapp/Models/SuggestionResponseModel.dart';

void main() {
  test('SuggestionResponseModel correctly parses shorts', () {
    final Map<String, dynamic> json = {
      "success": true,
      "data": {
        "contents": [],
        "shorts": [
          {
            "id": 1,
            "uuid": "d7c524d2-41dc-4797-a5c1-11166820b051",
            "slug": "bory-verticale",
            "title": "bory Verticale",
            "vertical_poster":
                "https://d97by8x3oqp1r.cloudfront.net/shorts/posters/01M1XC30Q6RDE7K0T0S2F1K9DZ.jpg"
          }
        ],
        "genres": [],
        "people": []
      }
    };

    final model = SuggestionResponseModel.fromJson(json);

    expect(model.success, true);
    expect(model.suggestionData?.shorts?.length, 1);
    expect(model.data?.length, 1);

    final short = model.suggestionData!.shorts!.first;
    expect(short.title, "bory Verticale");
    expect(short.slug, "bory-verticale");
    expect(short.uuid, "d7c524d2-41dc-4797-a5c1-11166820b051");
    expect(short.item_type, "shorts");
    expect(short.contentType, "Short Series");
    expect(
      short.thumbnail,
      "https://d97by8x3oqp1r.cloudfront.net/shorts/posters/01M1XC30Q6RDE7K0T0S2F1K9DZ.jpg",
    );
  });

  test('SearchResponseModel correctly parses shorts in search results', () {
    final Map<String, dynamic> json = {
      "success": true,
      "data": {
        "items": [],
        "shorts": [
          {
            "id": 1,
            "uuid": "d7c524d2-41dc-4797-a5c1-11166820b051",
            "slug": "bory-verticale",
            "title": "bory Verticale",
            "short_description": "Short description test",
            "vertical_poster":
                "https://d97by8x3oqp1r.cloudfront.net/shorts/posters/01M1XC30Q6RDE7K0T0S2F1K9DZ.jpg",
            "total_episodes": 52,
            "free_episode_count": 6,
            "is_trending": false,
            "genres": ["Drama"]
          }
        ],
        "pagination": {
          "current_page": 1,
          "last_page": 1,
          "per_page": 20,
          "total": 1,
          "has_more": false
        }
      }
    };

    final model = SearchResponseModel.fromJson(json);

    expect(model.success, true);
    expect(model.data?.shorts?.length, 1);
    expect(model.data?.items?.length, 1);

    final shortItem = model.data!.items!.first;
    expect(shortItem.title, "bory Verticale");
    expect(shortItem.slug, "bory-verticale");
    expect(shortItem.item_type, "shorts");
    expect(shortItem.contentType, "Short Series");
    expect(
      shortItem.thumbnail,
      "https://d97by8x3oqp1r.cloudfront.net/shorts/posters/01M1XC30Q6RDE7K0T0S2F1K9DZ.jpg",
    );
  });

  test('PlayResponseModel and GeneralErrorModel parse SUBSCRIPTION_REQUIRED error', () {
    final Map<String, dynamic> json = {
      "success": false,
      "message": "This episode isn't included with your current account.",
      "msg_header": "Members Only",
      "msg_desc": "This episode isn't included with your current account.",
      "msg_btn": "Manage Account",
      "code": "SUBSCRIPTION_REQUIRED",
      "data": {
        "plans": [
          {
            "id": 5,
            "name": "New Live Plan",
            "slug": "new-live-plan",
            "price": "4.99",
            "currency": "USD"
          }
        ]
      }
    };

    // Test PlayResponseModel
    final playModel = PlayResponseModel.fromJson(json);
    expect(playModel.success, false);
    expect(playModel.code, "SUBSCRIPTION_REQUIRED");
    expect(playModel.msgHeader, "Members Only");
    expect(playModel.msgDesc, "This episode isn't included with your current account.");
    expect(playModel.msgBtn, "Manage Account");

    // Test GeneralErrorModel
    final errorModel = GeneralErrorModel.fromJson(json);
    expect(errorModel.errorCode, "SUBSCRIPTION_REQUIRED");
    expect(errorModel.msgHeader, "Members Only");
    expect(errorModel.msgDesc, "This episode isn't included with your current account.");
    expect(errorModel.msgBtn, "Manage Account");
    expect(errorModel.message, "This episode isn't included with your current account.");
  });
}
