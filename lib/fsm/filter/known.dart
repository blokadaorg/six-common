import '../../util/di.dart';
import 'filter.dart';
import 'model.dart';

List<Filter> getKnownFilters(Act act) {
  if (act.isFamily()) {
    return _family;
  } else if (act.getPlatform() == Platform.ios) {
    return _v6iOS;
  } else {
    return _v6Android;
  }
}

List<FilterSelection> getDefaultEnabled(Act act) {
  if (act.isFamily()) return _familyEnabled;
  return _v6Enabled;
}

final _v6Enabled = [
  FilterSelection("oisd", ["small"]),
];

final _familyEnabled = [
  FilterSelection("meta_safe_search", ["safe search"]),
  FilterSelection("meta_ads", ["standard"]),
];

final _v6iOS = [
  Filter("oisd", [
    Option("small", Action.list, [
      "oisd/light"
    ]), // change on oisd/small once backend doesnt force the former as default
    Option("big", Action.list, ["oisd/big"]),
    Option("nsfw", Action.list, ["oisd/nsfw"]),
  ]),
  Filter("stevenblack", [
    Option("unified", Action.list, ["stevenblack/unified"]),
    Option("fake news", Action.list, ["stevenblack/fake news"]),
    Option("adult", Action.list, ["stevenblack/adult"]),
    Option("social", Action.list, ["stevenblack/social"]),
    Option("gambling", Action.list, ["stevenblack/gambling"]),
  ]),
  Filter("goodbyeads", [
    Option("standard", Action.list, ["goodbyeads/standard"]),
    Option("youtube", Action.list, ["goodbyeads/youtube"]),
    Option("spotify", Action.list, ["goodbyeads/spotify"]),
  ]),
  Filter("adaway", [
    Option("standard", Action.list, ["adaway/standard"]),
  ]),
  Filter("phishingarmy", [
    Option("standard", Action.list, ["phishingarmy/standard"]),
    Option("extended", Action.list, ["phishingarmy/extended"]),
  ]),
  Filter("ddgtrackerradar", [
    Option("standard", Action.list, ["ddgtrackerradar/standard"]),
  ]),
  Filter("blacklist", [
    Option("adservers", Action.list, ["blacklist/adservers"]),
    Option("facebook", Action.list, ["blacklist/facebook"]),
  ]),
  Filter("developerdan", [
    Option("ads and tracking", Action.list, ["developerdan/ads and tracking"]),
    Option("facebook", Action.list, ["developerdan/facebook"]),
    Option("amp", Action.list, ["developerdan/amp"]),
    Option("hate and junk", Action.list, ["developerdan/hate and junk"]),
  ]),
  Filter("blocklist", [
    Option("ads", Action.list, ["blocklist/ads"]),
    Option("facebook", Action.list, ["blocklist/facebook"]),
    Option("malware", Action.list, ["blocklist/malware"]),
    Option("phishing", Action.list, ["blocklist/phishing"]),
    Option("tracking", Action.list, ["blocklist/tracking"]),
    Option("youtube", Action.list, ["blocklist/youtube"]),
  ]),
  Filter("spam404", [
    Option("standard", Action.list, ["spam404/standard"]),
  ]),
  Filter("hblock", [
    Option("standard", Action.list, ["hblock/standard"]),
  ]),
  Filter("cpbl", [
    Option("standard", Action.list, ["cpbl/standard"]),
    Option("mini", Action.list, ["cpbl/mini"]),
  ]),
  Filter("danpollock", [
    Option("standard", Action.list, ["danpollock/standard"]),
  ]),
  Filter("urlhaus", [
    Option("standard", Action.list, ["urlhaus/standard"]),
  ]),
  Filter("1hosts", [
    Option("lite", Action.list, ["1hosts/lite (wildcards)"]),
    Option("pro", Action.list, ["1hosts/pro (wildcards)"]),
    Option("xtra", Action.list, ["1hosts/xtra (wildcards)"]),
  ]),
  Filter("d3host", [
    Option("standard", Action.list, ["d3host/standard"]),
  ]),
];

final _v6Android = [
  Filter("oisd", [
    Option("small", Action.list, [
      "oisd/light"
    ]), // change on oisd/small once backend doesnt force the former as default
    Option("big", Action.list, ["oisd/big"]),
    Option("nsfw", Action.list, ["oisd/nsfw"]),
  ]),
  Filter("stevenblack", [
    Option("unified", Action.list, ["stevenblack/unified"]),
    Option("fake news", Action.list, ["stevenblack/fake news"]),
    Option("adult", Action.list, ["stevenblack/adult"]),
    Option("social", Action.list, ["stevenblack/social"]),
    Option("gambling", Action.list, ["stevenblack/gambling"]),
  ]),
  Filter("goodbyeads", [
    Option("standard", Action.list, ["goodbyeads/standard"]),
    Option("samsung", Action.list, ["goodbyeads/samsung"]),
    Option("xiaomi", Action.list, ["goodbyeads/xiaomi"]),
    Option("spotify", Action.list, ["goodbyeads/spotify"]),
    Option("youtube", Action.list, ["goodbyeads/youtube"]),
  ]),
  Filter("adaway", [
    Option("standard", Action.list, ["adaway/standard"]),
  ]),
  Filter("phishingarmy", [
    Option("standard", Action.list, ["phishingarmy/standard"]),
    Option("extended", Action.list, ["phishingarmy/extended"]),
  ]),
  Filter("ddgtrackerradar", [
    Option("standard", Action.list, ["ddgtrackerradar/standard"]),
  ]),
  Filter("blacklist", [
    Option("adservers", Action.list, ["blacklist/adservers"]),
    Option("facebook", Action.list, ["blacklist/facebook"]),
  ]),
  Filter("developerdan", [
    Option("ads and tracking", Action.list, ["developerdan/ads and tracking"]),
    Option("facebook", Action.list, ["developerdan/facebook"]),
    Option("amp", Action.list, ["developerdan/amp"]),
    Option("hate and junk", Action.list, ["developerdan/hate and junk"]),
  ]),
  Filter("blocklist", [
    Option("ads", Action.list, ["blocklist/ads"]),
    Option("facebook", Action.list, ["blocklist/facebook"]),
    Option("malware", Action.list, ["blocklist/malware"]),
    Option("phishing", Action.list, ["blocklist/phishing"]),
    Option("tracking", Action.list, ["blocklist/tracking"]),
    Option("youtube", Action.list, ["blocklist/youtube"]),
  ]),
  Filter("spam404", [
    Option("standard", Action.list, ["spam404/standard"]),
  ]),
  Filter("hblock", [
    Option("standard", Action.list, ["hblock/standard"]),
  ]),
  Filter("cpbl", [
    Option("standard", Action.list, ["cpbl/standard"]),
    Option("mini", Action.list, ["cpbl/mini"]),
  ]),
  Filter("danpollock", [
    Option("standard", Action.list, ["danpollock/standard"]),
  ]),
  Filter("urlhaus", [
    Option("standard", Action.list, ["urlhaus/standard"]),
  ]),
  Filter("1hosts", [
    Option("lite", Action.list, ["1hosts/lite (wildcards)"]),
    Option("pro", Action.list, ["1hosts/pro (wildcards)"]),
    Option("xtra", Action.list, ["1hosts/xtra (wildcards)"]),
  ]),
  Filter("d3host", [
    Option("standard", Action.list, ["d3host/standard"]),
  ]),
];

final _family = [
  Filter("meta_safe_search", [
    Option("safe search", Action.config, ["safeSearch"]),
    Option("block unsupported", Action.list, ["safesearch/nosafesearch"]),
  ]),
  Filter("meta_ads", [
    Option("standard", Action.list, [
      "oisd/small",
      "goodbyeads/standard",
      "adaway/standard",
      "1hosts/lite (wildcards)",
      "d3host/standard",
    ]),
    Option("restrictive", Action.list, [
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
    ]),
  ]),
  Filter("meta_malware", [
    Option("standard", Action.list, [
      "phishingarmy/standard",
      "phishingarmy/extended",
      "blocklist/malware",
      "blocklist/phishing",
      "spam404/standard",
      "urlhaus/standard",
    ]),
  ]),
  Filter("meta_adult", [
    Option("porn", Action.list, [
      "stevenblack/adult",
      "sinfonietta/porn",
      "tiuxo/porn",
      "mhxion/porn",
    ]),
  ]),
  Filter("meta_dating", [
    Option("standard", Action.list, [
      "ut1/dating",
    ]),
  ]),
  Filter("meta_gambling", [
    Option("standard", Action.list, [
      "stevenblack/gambling",
      "ut1/gambling",
      "sinfonietta/gambling",
    ]),
  ]),
  Filter("meta_piracy", [
    Option("file hosting", Action.list, [
      "ut1/warez",
      "ndnspiracy/file hosting",
      "ndnspiracy/proxies",
      "ndnspiracy/usenet",
      "ndnspiracy/warez",
    ]),
    Option("torrent", Action.list, [
      "ndnspiracy/dht bootstrap nodes",
      "ndnspiracy/torrent clients",
      "ndnspiracy/torrent trackers",
      "ndnspiracy/torrent websites",
    ]),
    Option("streaming", Action.list, [
      "ndnspiracy/streaming audio",
      "ndnspiracy/streaming video",
    ]),
  ]),
  Filter("meta_videostreaming", [
    Option("standard", Action.list, [
      "ndnspiracy/streaming video",
    ]),
  ]),
  Filter("meta_apps_streaming", [
    Option("disney plus", Action.list, [
      "ndnsapps/disneyplus",
    ]),
    Option("hbo max", Action.list, [
      "ndnsapps/hbomax",
    ]),
    Option("hulu", Action.list, [
      "ndnsapps/hulu",
    ]),
    Option("netflix", Action.list, [
      "ndnsapps/netflix",
    ]),
    Option("primevideo", Action.list, [
      "ndnsapps/primevideo",
    ]),
    Option("youtube", Action.list, [
      "ndnsapps/youtube",
    ]),
  ]),
  Filter("meta_social", [
    Option("social networks", Action.list, [
      "stevenblack/social",
      "ut1/social",
      "sinfonietta/social",
    ]),
    Option("facebook", Action.list, [
      "blacklist/facebook",
      "developerdan/facebook",
      "blocklist/facebook",
      "ndnsapps/facebook",
    ]),
    Option("instagram", Action.list, [
      "ndnsapps/instagram",
    ]),
    Option("reddit", Action.list, [
      "ndnsapps/reddit",
    ]),
    Option("snapchat", Action.list, [
      "ndnsapps/snapchat",
    ]),
    Option("tiktok", Action.list, [
      "ndnsapps/tiktok",
    ]),
    Option("twitter", Action.list, [
      "ndnsapps/twitter",
    ]),
  ]),
  Filter("meta_apps_chat", [
    Option("discord", Action.list, [
      "ndnsapps/discord",
    ]),
    Option("messenger", Action.list, [
      "ndnsapps/messenger",
    ]),
    Option("signal", Action.list, [
      "ndnsapps/signal",
    ]),
    Option("telegram", Action.list, [
      "ndnsapps/telegram",
    ]),
  ]),
  Filter("meta_gaming", [
    Option("standard", Action.list, [
      "ut1/gaming",
    ]),
  ]),
  Filter("meta_apps_games", [
    Option("fortnite", Action.list, [
      "ndnsapps/fortnite",
    ]),
    Option("league of legends", Action.list, [
      "ndnsapps/leagueoflegends",
    ]),
    Option("minecraft", Action.list, [
      "ndnsapps/minecraft",
    ]),
    Option("roblox", Action.list, [
      "ndnsapps/roblox",
    ]),
    Option("steam", Action.list, [
      "ndnsapps/steam",
    ]),
    Option("twitch", Action.list, [
      "ndnsapps/twitch",
    ]),
  ]),
  Filter("meta_apps_commerce", [
    Option("amazon", Action.list, [
      "ndnsapps/amazon",
    ]),
    Option("ebay", Action.list, [
      "ndnsapps/ebay",
    ]),
  ]),
  Filter("meta_apps_other", [
    Option("9gag", Action.list, [
      "ndnsapps/9gag",
    ]),
    Option("chat gpt", Action.list, [
      "ndnsapps/chatgpt",
    ]),
    Option("imgur", Action.list, [
      "ndnsapps/imgur",
    ]),
    Option("pinterest", Action.list, [
      "ndnsapps/pinterest",
    ]),
    Option("tinder", Action.list, [
      "ndnsapps/tinder",
    ]),
  ]),
];
