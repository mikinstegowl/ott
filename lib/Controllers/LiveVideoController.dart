import 'dart:async';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/Models/LiveVideoModel.dart';
import 'package:ottapp/Models/ChatMessage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LiveVideoController extends BaseController with WidgetsBindingObserver {
  late HomeChopperService _homeChopperService;
  LiveVideoController({required HomeChopperService homeChopperService}) {
    _homeChopperService = homeChopperService;
  }

  final Rx<LiveVideoModel?> liveVideoData = Rxn<LiveVideoModel>();

  // Chat State
  final DatabaseReference _chatRef =
      FirebaseDatabase.instance.ref().child('live_chats').child('main');
  final RxList<ChatMessage> chatMessages = <ChatMessage>[].obs;
  final TextEditingController chatController = TextEditingController();
  final RxBool isSendingMessage = false.obs;
  StreamSubscription? _chatSubscription;

  // Video Player state
  VideoPlayerController? videoPlayerController;
  final RxBool isInitialized = false.obs;
  final RxBool isBuffering = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // START OPTIMIZATION: Pre-fetch metadata immediately in background
    fetchLiveVideo(initPlayer: false);

    // START CHAT: Listen for new messages
    _listenToChat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      pausePlayback();
    }
  }

  void _listenToChat() {
    _chatSubscription = _chatRef.limitToLast(50).onValue.listen((event) {
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        final Map<dynamic, dynamic> messagesMap = event.snapshot.value as Map;
        final List<ChatMessage> loadedMessages = [];

        messagesMap.forEach((key, value) {
          if (value is Map) {
            loadedMessages.add(ChatMessage.fromMap(key.toString(), value));
          }
        });

        // Sort by timestamp
        loadedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        chatMessages.assignAll(loadedMessages);
      }
    }, onError: (error) {
      print("LiveChat: Error listening to messages: $error");
    });
  }

  Future<void> sendMessage() async {
    if (isGuest) {
      showLoginDialog();
      return;
    }

    if (isSendingMessage.value) return;

    final text = chatController.text.trim();
    if (text.isEmpty) return;

    isSendingMessage.value = true;
    final user = profileData.value;
    final message = ChatMessage(
      senderId: user?.data?.id?.toString() ?? 'anonymous',
      senderName: user?.data?.name ?? 'User',
      message: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isAdmin: user?.data?.role == 'admin', // Determine admin status by role
    );

    try {
      await _chatRef.push().set(message.toMap());
      chatController.clear();
    } catch (e) {
      print("LiveChat: Error sending message: $e");
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> lazyFetch() async {
    // Stage 2: Only initialize player if tab is active and data is ready
    if (liveVideoData.value != null && !isInitialized.value) {
      _initializePlayer(liveVideoData.value?.data?.link ?? "");
    } else if (liveVideoData.value == null || hasError.value) {
      await fetchLiveVideo(initPlayer: true);
    }
  }

  Future<void> fetchLiveVideo({bool initPlayer = true}) async {
    try {
      showLoader(true);
      final response = await _homeChopperService.getLiveVideoAPI();
      if (response.isSuccessful && response.body?.data != null) {
        liveVideoData.value = response.body;
        if (initPlayer) {
          _initializePlayer(liveVideoData.value?.data?.link ?? "");
        }
      } else {
        _setError("Unable to load live video details");
      }
    } catch (e) {
      _setError("Network Error: $e");
    } finally {
      showLoader(false);
    }
  }

  Future<void> _initializePlayer(String url) async {
    try {
      print("LiveVideo: Initializing Player with URL: $url");

      await videoPlayerController?.dispose();

      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Referer': 'https://tr3bolplus.com/',
        },
      );

      await videoPlayerController!.initialize();

      videoPlayerController!.addListener(() {
        if (!videoPlayerController!.value.isInitialized) return;
        isBuffering.value = videoPlayerController!.value.isBuffering;
        if (videoPlayerController!.value.hasError) {
          _setError(
              "Playback Error: ${videoPlayerController!.value.errorDescription}");
        }
      });

      await videoPlayerController!.play();

      isInitialized.value = true;
      print("LiveVideo: Player Initialized Successfully");
    } catch (e, s) {
      _setError("Player Initialization Failed: $e");
      print(s);
    }
  }

  void pausePlayback() {
    if (videoPlayerController != null && videoPlayerController!.value.isPlaying) {
      videoPlayerController!.pause();
      print("LiveVideo: Background Pause triggered");
    }
  }

  void resumePlayback() {
    if (videoPlayerController != null && 
        isInitialized.value && 
        !videoPlayerController!.value.isPlaying) {
      videoPlayerController!.play();
      print("LiveVideo: Foreground Resume triggered");
    }
  }

  void _setError(String msg) {
    hasError.value = true;
    errorMessage.value = msg;
    print("LiveVideoError: $msg");
  }

  void retry() {
    hasError.value = false;
    errorMessage.value = "";
    fetchLiveVideo();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatSubscription?.cancel();
    videoPlayerController?.dispose();
    chatController.dispose();
    super.onClose();
  }
}
