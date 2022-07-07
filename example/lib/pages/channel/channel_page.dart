import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:youtube_data_api/models/channel_data.dart';
import 'package:youtube_data_api/youtube_data_api.dart';
import '/pages/channel/body.dart';

class ChannelPage extends StatefulWidget {
  final id;
  final title;

  const ChannelPage({Key? key, required this.id, required this.title})
      : super(key: key);

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  YoutubeDataApi youtubeDataApi = YoutubeDataApi();
  ChannelData? channelData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: (){},
            icon: Icon(LineIcons.rss, color: Colors.white),
          ),
          IconButton(
            onPressed: (){},
            icon: Icon(LineIcons.share, color: Colors.white),
          )
        ],
      ),
      body: body(),
    );
  }

  Widget body() {
    return  RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder(
        future: youtubeDataApi.fetchChannelData(widget.id),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return _loading();
            case ConnectionState.active:
              return _loading();
            case ConnectionState.none:
              return Container(child: Text("Connection None"));
            case ConnectionState.done:
              if (snapshot.error != null) {
                return Center(
                    child: Container(child: Text(snapshot.stackTrace.toString())));
              } else {
                if (snapshot.hasData) {
                  return Body(channelData: snapshot.data, title: widget.title, youtubeDataApi: youtubeDataApi, channelId: widget.id,);
                } else {
                  return Center(child: Container(child: Text("No data")));
                }
              }
          }
        },
      ),
    );
  }


  Widget _loading() {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<bool> _refresh() async {
    setState(() {});
    return true;
  }

}
