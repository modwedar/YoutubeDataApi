library youtube_data_api;

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:youtube_data_api/helpers/helpers_extention.dart';
import 'package:youtube_data_api/models/channel.dart';
import 'package:youtube_data_api/models/playlist.dart';
import 'package:youtube_data_api/models/video_page.dart';
import 'package:youtube_data_api/retry.dart';
import 'package:collection/collection.dart';
import 'package:xml2json/xml2json.dart';
import 'dart:convert';
import 'helpers/extract_json.dart';
import 'models/channel_data.dart';
import 'models/video.dart';
import 'models/video_data.dart';

class YoutubeDataApi {
  ///Continue token for load more videos on youtube search
  String? _searchToken;

  ///Continue token for load more videos on youtube channel
  String? _channelToken;

  ///Continue token for load more videos on youtube playlist
  String? _playListToken;

  ///Last search query on youtube search
  String? lastQuery;

  ///Get list of videos and playlists and channels from youtube search with query
  Future<List> fetchSearchVideo(String query, String API_KEY) async {
    List list = [];
    var client = http.Client();

    ///Check if new search query is the same of last search query and continue token is not null
    ///for load more videos with the search query
    if (_searchToken != null && query == lastQuery) {
      var url =
          'https://www.youtube.com/youtubei/v1/search?key=$API_KEY';

      return retry(() async {
        var body = {
          'context': const {
            'client': {
              'hl': 'en',
              'clientName': 'WEB',
              'clientVersion': '2.20200911.04.00'
            }
          },
          'continuation': _searchToken
        };
        var raw = await client.post(Uri.parse(url), body: json.encode(body));
        Map<String, dynamic> jsonMap = json.decode(raw.body);
        var contents = jsonMap
            .getList('onResponseReceivedCommands')
            ?.firstOrNull
            ?.get('appendContinuationItemsAction')
            ?.getList('continuationItems')
            ?.firstOrNull
            ?.get('itemSectionRenderer')
            ?.getList('contents');
        list = contents!.toList();
        _searchToken = _getContinuationToken(jsonMap);
        return list;
      });
    } else {
      lastQuery = query;
      var response = await client.get(
        Uri.parse(
          'https://www.youtube.com/results?search_query=$query',
        ),
      );
      var jsonMap = _getJsonMap(response);
      if (jsonMap != null) {
        var contents = jsonMap
            .get('contents')
            ?.get('twoColumnSearchResultsRenderer')
            ?.get('primaryContents')
            ?.get('sectionListRenderer')
            ?.getList('contents')
            ?.firstOrNull
            ?.get('itemSectionRenderer')
            ?.getList('contents');

        var contentList = contents?.toList();
        contentList?.forEach((element) {
          if (element.containsKey('videoRenderer')) {
            ///Element is Video
            Video video = Video.fromMap(element);
            list.add(video);
          } else if (element.containsKey('channelRenderer')) {
            ///Element is Channel
            Channel channel = Channel.fromMap(element);
            list.add(channel);
          } else if (element.containsKey('playlistRenderer')) {
            ///Element is Playlist
            PlayList playList = PlayList.fromMap(element);
            list.add(playList);
          }
        });
        _searchToken = _getContinuationToken(jsonMap);
      }
    }
    return list;
  }

  ///Get list of trending videos on youtube
  Future<List<Video>> fetchTrendingVideo() async {
    List<Video> list = [];
    var client = http.Client();
    var response = await client.get(
      Uri.parse(
        'https://www.youtube.com/feed/trending',
      ),
    );
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.firstOrNull
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var firstList = contents != null ? contents.toList() : [];
      var secondContents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.firstOrNull
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.elementAtSafe(3)
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var secondList = secondContents != null ? secondContents.toList() : [];
      var contentList = [...firstList, ...secondList];
      contentList.forEach((element) {
        Video video = Video.fromMap(element);
        list.add(video);
      });
    }
    return list;
  }

  ///Get list of trending music videos on youtube
  Future<List<Video>> fetchTrendingMusic() async {
    String params = "4gINGgt5dG1hX2NoYXJ0cw%3D%3D";
    List<Video> list = [];
    var client = http.Client();
    var response = await client.get(
      Uri.parse(
        'https://www.youtube.com/feed/trending?bp=$params',
      ),
    );
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.elementAtSafe(1)
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var contentList = contents != null ? contents.toList() : [];
      contentList.forEach((element) {
        Video video = Video.fromMap(element);
        list.add(video);
      });
    }
    return list;
  }

  ///Get list of trending gaming videos on youtube
  Future<List<Video>> fetchTrendingGaming() async {
    String params = "4gIcGhpnYW1pbmdfY29ycHVzX21vc3RfcG9wdWxhcg";
    List<Video> list = [];
    var client = http.Client();
    var response = await client.get(
      Uri.parse(
        'https://www.youtube.com/feed/trending?bp=$params',
      ),
    );
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.elementAtSafe(2)
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var contentList = contents != null ? contents.toList() : [];

      contentList.forEach((element) {
        Video video = Video.fromMap(element);
        list.add(video);
      });
    }
    return list;
  }

  Future<List<Video>> fetchTrendingMovies() async {
    String params = "4gIKGgh0cmFpbGVycw%3D%3D";
    List<Video> list = [];
    var client = http.Client();
    var response = await client.get(
      Uri.parse(
        'https://www.youtube.com/feed/trending?bp=$params',
      ),
    );
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
    scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.elementAtSafe(3)
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var contentList = contents != null ? contents.toList() : [];
      contentList.forEach((element) {
        Video video = Video.fromMap(element);
        list.add(video);
      });
    }
    return list;
  }

  ///Get list of suggestions search queries
  Future<List<String>> fetchSuggestions(String query) async {
    List<String> suggestions = [];
    String baseUrl =
        'http://suggestqueries.google.com/complete/search?output=toolbar&ds=yt&q=';
    var client = http.Client();
    final myTranformer = Xml2Json();
    var response = await client.get(Uri.parse(baseUrl + query));
    var body = response.body;
    myTranformer.parse(body);
    var json = myTranformer.toGData();
    List suggestionsData = jsonDecode(json)['toplevel']['CompleteSuggestion'];
    suggestionsData.forEach((suggestion) {
      suggestions.add(suggestion['suggestion']['data'].toString());
    });
    return suggestions;
  }

  ///Get channel data and videos in channel page
  Future<ChannelData?> fetchChannelData(String channelId) async {
    var client = http.Client();
    var response = await client.get(
      Uri.parse(
        'https://www.youtube.com/channel/$channelId/videos',
      ),
    );
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      ChannelData channelData = ChannelData.fromMap(jsonMap);
      _channelToken = _getContinuationToken(jsonMap);
      return channelData;
    }
    return null;
  }

  ///Get videos from playlist
  Future<List<Video>> fetchPlayListVideos(String id, int loaded) async {
    List<Video> videos = [];
    var url = 'https://www.youtube.com/playlist?list=$id&hl=en&persist_hl=1';
    var client = http.Client();
    var response = await client.get(
      Uri.parse(url),
    );
    var jsonMap = _getJsonMap(response);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.firstOrNull
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('playlistVideoListRenderer')
          ?.getList('contents');
      var contentList = contents!.toList();
      contentList.forEach((element) {
        Video video = Video.fromMap(element);
        videos.add(video);
      });
      _playListToken = _getPlayListContinuationToken(jsonMap);
    }
    return videos;
  }

  ///Get video data (videoId, title, viewCount, username, likeCount, unlikeCount, channelThumb,
  /// channelId, subscribeCount ,Related videos)
  Future<VideoData?> fetchVideoData(String videoId) async {
    VideoData? videoData;
    var client = http.Client();
    var response =
        await client.get(Uri.parse('https://www.youtube.com/watch?v=$videoId'));
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap.get('contents')?.get('twoColumnWatchNextResults');

      var contentList = contents
          ?.get('secondaryResults')
          ?.get('secondaryResults')
          ?.getList('results')
          ?.toList();

      List<Video> videosList = [];

      contentList?.forEach((element) {
        if(element['compactVideoRenderer']?['title']?['simpleText'] !=null){
          Video video = Video.fromMap(element);
          videosList.add(video);
        }
      });

      videoData = VideoData(
          video: VideoPage.fromMap(contents, videoId), videosList: videosList);
    }
    return videoData;
  }

  ///Load more videos in youtube channel
  Future<List<Video>> loadMoreInChannel(String API_KEY) async {
    List<Video> videos = [];
    var client = http.Client();
    var url =
        'https://www.youtube.com/youtubei/v1/browse?key=$API_KEY';
    var body = {
      'context': const {
        'client': {
          'hl': 'en',
          'clientName': 'WEB',
          'clientVersion': '2.20200911.04.00'
        }
      },
      'continuation': _channelToken
    };
    var raw = await client.post(Uri.parse(url), body: json.encode(body));
    Map<String, dynamic> jsonMap = json.decode(raw.body);
    var contents = jsonMap
        .getList('onResponseReceivedActions')
        ?.firstOrNull
        ?.get('appendContinuationItemsAction')
        ?.getList('continuationItems');
    if (contents != null) {
      var contentList = contents.toList();
      contentList.forEach((element) {
        Video video = Video.fromMap(element);
        videos.add(video);
      });
      _channelToken = _getChannelContinuationToken(jsonMap);
    }
    return videos;
  }

  ///Load more videos in youtube playlist
  Future<List<Video>> loadMoreInPlayList(String API_KEY) async {
    List<Video> list = [];
    var client = http.Client();
    var url =
        'https://www.youtube.com/youtubei/v1/browse?key=$API_KEY';
    var body = {
      'context': const {
        'client': {
          'hl': 'en',
          'clientName': 'WEB',
          'clientVersion': '2.20200911.04.00'
        }
      },
      'continuation': _playListToken
    };
    var raw = await client.post(Uri.parse(url), body: json.encode(body));
    Map<String, dynamic> jsonMap = json.decode(raw.body);
    var contents = jsonMap
        .getList('onResponseReceivedActions')
        ?.firstOrNull
        ?.get('appendContinuationItemsAction')
        ?.getList('continuationItems');
    if (contents != null) {
      var contentList = contents.toList();
      contentList.forEach((element) {
        Video video = Video.fromMap(element);
        list.add(video);
      });
      _playListToken = _getChannelContinuationToken(jsonMap);
    }
    return list;
  }

  String? _getChannelContinuationToken(Map<String, dynamic>? root) {
    return root!
        .getList('onResponseReceivedActions')
        ?.firstOrNull
        ?.get('appendContinuationItemsAction')
        ?.getList('continuationItems')
        ?.elementAtSafe(30)
        ?.get('continuationItemRenderer')
        ?.get('continuationEndpoint')
        ?.get('continuationCommand')
        ?.getT<String>('token');
  }

  String? _getPlayListContinuationToken(Map<String, dynamic>? root) {
    return root!
        .get('contents')
        ?.get('twoColumnBrowseResultsRenderer')
        ?.getList('tabs')
        ?.firstOrNull
        ?.get('tabRenderer')
        ?.get('content')
        ?.get('sectionListRenderer')
        ?.getList('contents')
        ?.firstOrNull
        ?.get('itemSectionRenderer')
        ?.getList('contents')
        ?.firstOrNull
        ?.get('playlistVideoListRenderer')
        ?.getList('contents')
        ?.elementAtSafe(100)
        ?.get('continuationItemRenderer')
        ?.get('continuationEndpoint')
        ?.get('continuationCommand')
        ?.getT<String>('token');
  }

  String? _getContinuationToken(Map<String, dynamic>? root) {
    if (root?['contents'] != null) {
      if (root?['contents']?['twoColumnBrowseResultsRenderer'] != null) {
        return root!
            .get('contents')
            ?.get('twoColumnBrowseResultsRenderer')
            ?.getList('tabs')
            ?.elementAtSafe(1)
            ?.get('tabRenderer')
            ?.get('content')
            ?.get('sectionListRenderer')
            ?.getList('contents')
            ?.firstOrNull
            ?.get('itemSectionRenderer')
            ?.getList('contents')
            ?.firstOrNull
            ?.get('gridRenderer')
            ?.getList('items')
            ?.elementAtSafe(30)
            ?.get('continuationItemRenderer')
            ?.get('continuationEndpoint')
            ?.get('continuationCommand')
            ?.getT<String>('token');
      }
      var contents = root!
          .get('contents')
          ?.get('twoColumnSearchResultsRenderer')
          ?.get('primaryContents')
          ?.get('sectionListRenderer')
          ?.getList('contents');

      if (contents == null || contents.length <= 1) {
        return null;
      }
      return contents
          .elementAtSafe(1)
          ?.get('continuationItemRenderer')
          ?.get('continuationEndpoint')
          ?.get('continuationCommand')
          ?.getT<String>('token');
    }
    if (root?['onResponseReceivedCommands'] != null) {
      return root!
          .getList('onResponseReceivedCommands')
          ?.firstOrNull
          ?.get('appendContinuationItemsAction')
          ?.getList('continuationItems')
          ?.elementAtSafe(1)
          ?.get('continuationItemRenderer')
          ?.get('continuationEndpoint')
          ?.get('continuationCommand')
          ?.getT<String>('token');
    }
    return null;
  }

  Map<String, dynamic>? _getJsonMap(http.Response response) {
    var raw = response.body;
    var root = parser.parse(raw);
    final scriptText = root
        .querySelectorAll('script')
        .map((e) => e.text)
        .toList(growable: false);
    var initialData =
        scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText
        .firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    return jsonMap;
  }
}
