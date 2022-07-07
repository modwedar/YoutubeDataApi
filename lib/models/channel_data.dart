import 'package:youtube_data_api/helpers/helpers_extention.dart';
import 'package:youtube_data_api/models/channel_page.dart';
import 'package:youtube_data_api/models/video.dart';

import 'package:collection/collection.dart';


class ChannelData {
  ChannelPage channel;
  List<Video> videosList;

  ChannelData({required this.channel, required this.videosList});

  factory ChannelData.fromMap(Map<String, dynamic> map) {
    var headers = map.get('header');
    String? subscribers = headers
        ?.get('c4TabbedHeaderRenderer')
        ?.get('subscriberCountText')?['simpleText'];
    var thumbnails = headers
        ?.get('c4TabbedHeaderRenderer')
        ?.get('avatar')
        ?.getList('thumbnails');
    String avatar = thumbnails?.elementAtSafe(thumbnails.length - 1)?['url'];
    String? banner = headers
        ?.get('c4TabbedHeaderRenderer')
        ?.get('banner')
        ?.getList('thumbnails')
        ?.first['url'];
    var contents = map
        .get('contents')
        ?.get('twoColumnBrowseResultsRenderer')
        ?.getList('tabs')?[1]
        .get('tabRenderer')
        ?.get('content')
        ?.get('sectionListRenderer')
        ?.getList('contents')
        ?.firstOrNull
        ?.get('itemSectionRenderer')
        ?.getList('contents')
        ?.firstOrNull
        ?.get('gridRenderer')
        ?.getList('items');
    var contentList = contents!.toList();
    List<Video> videoList = [];
    contentList.forEach((element) {
      Video video = Video.fromMap(element);
      videoList.add(video);
    });

    return ChannelData(videosList: videoList, channel: ChannelPage(subscribers: (subscribers != null) ? subscribers : " ", avatar: avatar, banner: banner));
  }
}
