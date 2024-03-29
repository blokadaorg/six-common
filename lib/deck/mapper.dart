import 'package:collection/collection.dart';

import '../util/trace.dart';
import 'channel.pg.dart';
import 'deck.dart';
import '../fsm/filter/json.dart';

abstract class DeckMapper {
  // Will return a map of decks, that users can enable/disable.
  // Depending on the mapper, the decks may be virtual.
  // If so, the ids have to be translated (expanded) into actual lists.
  Map<DeckId, Deck> bundleDeckItems(Trace trace, List<DeckItem> items);

  // Used by mappers that return virtual decks, this will translate given
  // virtual list id, into an actual (one or more) list tag. Null means no
  // translation is needed for this mapper. Take note that it will return list
  // tags, not list ids directly, as they are fetched from api by the store.
  List<String>? expandListBundle(Trace trace, ListId id);

  Map<DeckId, Deck> syncEnabledStates(Trace trace, Map<DeckId, Deck> decks,
      List<ListId> enabledByUser, Map<String, ListId> listTagToId);

  // Used by the UI to reverse map a ListId to an user-actionable deck tag.
  // Tags are used by the UI to display Deck name.
  // For non-virtual mappers, this will simply return the 1:1 mapping.
  Map<ListId, String> mapDeckItemTags(Trace trace, List<DeckItem> items);
}

// The Cloud flavor simply displays lists and their configurations. In other
// words, bundling happens only by 'author'.
class CloudDeckMapper implements DeckMapper {
  @override
  Map<DeckId, Deck> bundleDeckItems(Trace trace, List<DeckItem> items) {
    final Map<DeckId, Deck> decks = {};
    for (var i in items) {
      final deckId = i.getDeckId();
      final deck = decks[deckId];
      if (deck != null) {
        decks[deckId] = deck.add(i.id, i.tag, false);
      } else {
        decks[deckId] = Deck(
          deckId: deckId,
          items: {i.id: DeckItem(id: i.id, tag: i.tag, enabled: false)},
          enabled: false,
        );
      }
    }
    return decks;
  }

  @override
  List<String>? expandListBundle(Trace trace, ListId id) {
    return null;
  }

  @override
  Map<DeckId, Deck> syncEnabledStates(Trace trace, Map<DeckId, Deck> decks,
      List<ListId> enabledByUser, Map<String, ListId> listTagToId) {
    for (var deck in decks.values) {
      for (var item in deck.items.values) {
        if (item == null) continue;
        if (enabledByUser.contains(item.id) && !item.enabled) {
          decks[deck.deckId] = deck.changeEnabled(item.id, true);
        } else if (!enabledByUser.contains(item.id) && item.enabled) {
          decks[deck.deckId] = deck.changeEnabled(item.id, false);
        }
      }
    }
    return decks;
  }

  @override
  Map<ListId, String> mapDeckItemTags(Trace trace, List<DeckItem> items) {
    final listIdToTag = items.map((e) => MapEntry(e.id, e.tag));
    return {for (var m in listIdToTag) m.key: m.value};
  }
}

// The Family flavor will bundle some lists into more generic decks (e.g.
// malware, gambling, etc). They may mix lists from different decks / authors.
class FamilyDeckMapper implements DeckMapper {
  @override
  Map<DeckId, Deck> bundleDeckItems(Trace trace, List<DeckItem> items) {
    final decks = <String, Deck>{};

    _familyMap.forEach((deckId, innerMap) {
      final deckItems = <String, DeckItem>{};

      innerMap.forEach((tag, items) {
        deckItems["$deckId/$tag"] = DeckItem(
          id: "$deckId/$tag",
          tag: "$deckId/$tag",
          enabled: false,
        );
      });

      decks[deckId] = Deck(
        deckId: deckId,
        items: deckItems,
        enabled: false,
      );
    });

    return decks;
  }

  @override
  List<String>? expandListBundle(Trace trace, ListId id) {
    final ids = id.split("/");
    return _familyMap[ids[0]]?[ids[1]];
  }

  @override
  Map<DeckId, Deck> syncEnabledStates(Trace trace, Map<DeckId, Deck> decks,
      List<ListId> enabledByUser, Map<String, ListId> listTagToId) {
    for (var deck in decks.values) {
      for (var item in deck.items.values) {
        if (item == null) continue;
        final allEnabled = _areAllEnabled(item, enabledByUser, listTagToId);
        if (allEnabled && !item.enabled) {
          decks[deck.deckId] = deck.changeEnabled(item.id, true);
        } else if (!allEnabled && item.enabled) {
          decks[deck.deckId] = deck.changeEnabled(item.id, false);
        }
      }
    }
    return decks;
  }

  bool _areAllEnabled(DeckItem item, List<ListId> enabledByUser,
      Map<String, ListId> listTagToId) {
    final ids = item.id.split("/");
    final listTags = _familyMap[ids[0]]?[ids[1]];
    if (listTags == null) return false;
    for (var listTag in listTags) {
      if (!enabledByUser.contains(listTagToId[listTag])) return false;
    }
    return true;
  }

  @override
  Map<ListId, String> mapDeckItemTags(Trace trace, List<DeckItem> items) {
    Map<String, String> tagMapping = {};

    for (DeckItem item in items) {
      bool found = false;
      for (var familyDeck in _familyMap.entries) {
        for (var familyConfig in familyDeck.value.entries) {
          if (familyConfig.value.contains(item.tag)) {
            tagMapping[item.id] = "${familyDeck.key}/${familyConfig.key}";
            found = true;
            break;
          }
        }

        if (!found) {
          tagMapping[item.id] = item.tag;
        }
      }
    }

    return tagMapping;
  }
}

// The order here decides the UI order
const _familyMap = {
  "meta_safe_search": {
    "block unsupported": ["safesearch/nosafesearch"],
  },
  "meta_ads": {
    "standard": [
      "oisd/small",
      "goodbyeads/standard",
      "adaway/standard",
      "1hosts/lite (wildcards)",
      "d3host/standard"
    ],
    "restrictive": [
      "oisd/big",
      "ddgtrackerradar/standard",
      "1hosts/xtra (wildcards)",
      // Those below I'm not sure how to treat
      "cpbl/standard",
      "blacklist/adservers",
      "developerdan/ads and tracking",
      "blocklist/ads",
      "blocklist/tracking",
      "hblock/standard",
      "danpollock/standard",
    ],
  },
  "meta_malware": {
    "standard": [
      "phishingarmy/standard",
      "phishingarmy/extended",
      "blocklist/malware",
      "blocklist/phishing",
      "spam404/standard",
      "urlhaus/standard",
    ]
  },
  "meta_adult": {
    "porn": [
      "stevenblack/adult",
      "sinfonietta/porn",
      "tiuxo/porn",
      "mhxion/porn",
    ],
  },
  "meta_dating": {
    "dating": ["ut1/dating"],
  },
  "meta_gambling": {
    "standard": [
      "stevenblack/gambling",
      "ut1/gambling",
      "sinfonietta/gambling",
    ],
  },
  "meta_piracy": {
    "file hosting": [
      "ut1/warez",
      "ndnspiracy/file hosting",
      "ndnspiracy/proxies",
      "ndnspiracy/usenet",
      "ndnspiracy/warez",
    ],
    "torrent": [
      "ndnspiracy/dht bootstrap nodes",
      "ndnspiracy/torrent clients",
      "ndnspiracy/torrent trackers",
      "ndnspiracy/torrent websites",
    ],
    "streaming": [
      "ndnspiracy/streaming audio",
      "ndnspiracy/streaming video",
    ]
  },
  "meta_videostreaming": {
    "standard": [
      "ndnspiracy/streaming video",
    ]
  },
  "meta_apps_streaming": {
    "disney plus": ["ndnsapps/disneyplus"],
    "hbo max": ["ndnsapps/hbomax"],
    "hulu": ["ndnsapps/hulu"],
    "netflix": ["ndnsapps/netflix"],
    "primevideo": ["ndnsapps/primevideo"],
    "youtube": ["ndnsapps/youtube"],
  },
  "meta_social": {
    "social networks": [
      "stevenblack/social",
      "ut1/social",
      "sinfonietta/social",
    ],
    "facebook": [
      "blacklist/facebook",
      "developerdan/facebook",
      "blocklist/facebook",
      "ndnsapps/facebook",
    ],
    "instagram": ["ndnsapps/instagram"],
    "reddit": ["ndnsapps/reddit"],
    "snapchat": ["ndnsapps/snapchat"],
    "tiktok": ["ndnsapps/tiktok"],
    "twitter": ["ndnsapps/twitter"],
  },
  "meta_apps_chat": {
    "discord": ["ndnsapps/discord"],
    "messenger": ["ndnsapps/messenger"],
    "signal": ["ndnsapps/signal"],
    "telegram": ["ndnsapps/telegram"],
  },
  "meta_gaming": {
    "standard": ["ut1/gaming"],
  },
  "meta_apps_games": {
    "fortnite": ["ndnsapps/fortnite"],
    "league of legends": ["ndnsapps/leagueoflegends"],
    "minecraft": ["ndnsapps/minecraft"],
    "roblox": ["ndnsapps/roblox"],
    "steam": ["ndnsapps/steam"],
    "twitch": ["ndnsapps/twitch"],
  },
  "meta_apps_commerce": {
    "amazon": ["ndnsapps/amazon"],
    "ebay": ["ndnsapps/ebay"],
  },
  "meta_apps_other": {
    "9gag": ["ndnsapps/9gag"],
    "chat gpt": ["ndnsapps/chatgpt"],
    "imgur": ["ndnsapps/imgur"],
    "pinterest": ["ndnsapps/pinterest"],
    "tinder": ["ndnsapps/tinder"],
  },
};
