import '../util/trace.dart';
import 'channel.pg.dart';
import 'deck.dart';
import 'json.dart';

abstract class DeckMapper {
  // Will return a map of decks, that users can enable/disable.
  // Depending on the mapper, the decks may be virtual.
  // If so, the ids have then be translated (expanded) into actual lists.
  Map<DeckId, Deck> bundleDeckItems(Trace trace, List<DeckItem> items);

  // Used by mappers that return virtual decks, this will translate given
  // virtual list id, into an actual (one or more) list tag. Null means no
  // translation is needed for this mapper. Take note that it will return list
  // tags, not list ids directly, as they are fetched from api by the store.
  List<String>? expandListBundle(Trace trace, ListId id);

  Map<DeckId, Deck> syncEnabledStates(Trace trace, Map<DeckId, Deck> decks,
      List<ListId> enabledByUser, Map<String, ListId> listTagToId);
}

// The Cloud flavor simply displays lists and their configurations. In other
// words, bundling happens only by 'author'.
class CloudDeckMapper with DeckMapper {
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
}

// The Family flavor will bundle some lists into more generic decks (e.g.
// malware, gambling, etc). They may mix lists from different decks / authors.
class FamilyDeckMapper with DeckMapper {
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
}

const _familyMap = {
  "meta_adult": {
    "porn": ["stevenblack/adult"],
  },
  "meta_ads": {
    "standard": [
      "oisd/basic (wildcards)",
      "goodbyeads/standard",
      "adaway/standard",
      "1hosts/lite (wildcards)",
      "d3host/standard"
    ],
    "restrictive": [
      "oisd/extra (wildcards)",
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
  "meta_social": {
    "facebook": [
      "stevenblack/social",
      "blacklist/facebook",
      "developerdan/facebook",
      "blocklist/facebook",
    ],
  },
  "meta_gambling": {
    "standard": ["stevenblack/gambling"],
  },
};
