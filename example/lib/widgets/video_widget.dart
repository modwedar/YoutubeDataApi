import 'package:flutter/material.dart';
import 'package:youtube_data_api/models/video.dart';
import '/pages/video_detail_page.dart';


class VideoWidget extends StatelessWidget {
  final Video video;

  VideoWidget({
    required this.video,
  });


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        navigateToPlayer(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: InkWell(
                onTap: () {
                  navigateToPlayer(context);
                },
                child: Stack(
                  children: [
                    Container(
                      height: 80,
                      width: 140,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: Image.network(
                                      video.thumbnails![0].url!)
                                  .image,
                              fit: BoxFit.cover)),
                    ),
                    Positioned(
                      bottom: 4.0,
                      right: 4.0,
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 1, bottom: 1, left: 4, right: 4),
                        color: (video.duration == "Live")
                            ? Colors.red.withOpacity(0.88)
                            : Colors.black54,
                        child: Text(video.duration ?? '',
                            style:
                                const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontFamily: 'Cairo'
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 20, left: 15),
                child: Column(
                  children: [
                    Text(
                      video.title ?? '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Cairo'
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ), //video title
                    Text(
                      video.channelName ?? '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontFamily: 'Cairo'
                      ),
                    ), //video channel
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      video.views ?? '',
                      style: const TextStyle(color: Colors.white38,
                          fontSize: 12,
                          fontFamily: 'Cairo'
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  navigateToPlayer(BuildContext context){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => VideoDetailPage(
                videoId: video.videoId!)));
  }
}
