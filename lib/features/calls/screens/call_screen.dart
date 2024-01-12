import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/widgtes/loader.dart';
import 'package:whats_app_clone/config/agora_config.dart';
import 'package:whats_app_clone/features/calls/controller/call_controller.dart';
import 'package:whats_app_clone/models/call_model.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final CallModel call;
  final bool isgroup;
  const CallScreen(this.channelId, this.call, this.isgroup, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  AgoraClient? client;
  String baseUrl =
      "007eJxTYFh3as8vr1+q+7NebZkn+LFvusqWB6c26LQKqx94+VpHnKVJgSHRKNEw2cLUwMzE3NLEIjUtMSXJ1NwyNckkOSXNNNE48cL8jtSGQEaGy1LHWBgZIBDEZ2MIyc9OzTNkYAAAffAjJQ==";

  @override
  void initState() {
    super.initState();
    client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
            appId: AgoraConfig.appId,
            channelName: widget.channelId,
            tokenUrl: baseUrl));
    initAgora();
  }

  void initAgora() async {
    await client!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: client == null
          ? const LoadingPage()
          : SafeArea(
              child: Stack(
                children: [
                  AgoraVideoViewer(client: client!),
                  AgoraVideoButtons(
                    client: client!,
                    disconnectButtonChild: IconButton(
                      onPressed: () async {
                        await client!.engine.leaveChannel();
                        // ignore: use_build_context_synchronously
                        ref.read(callControllerProvider).endCall(
                            widget.call.callerId,
                            widget.call.receiverId,
                            context);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.call_end),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
