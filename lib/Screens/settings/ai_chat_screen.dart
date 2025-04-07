import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIChatScreen extends StatefulWidget {
  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  String apiKey =
      dotenv.env['API_KEY'] ?? ''; // تحميل مفتاح API بعد dotenv.load()
  bool _isBotTyping = false;

  void _simulateTypingEffect(String fullMessage) async {
    String currentText = "";
    messages.add({"sender": "bot", "text": ""}); // إضافة رسالة فارغة للبوت
    setState(() {
      _isBotTyping = true; // تعطيل الإرسال أثناء رد البوت
    });

    for (int i = 0; i < fullMessage.length; i++) {
      await Future.delayed(
          Duration(milliseconds: 50)); // تأخير لإضافة التأثير التدريجي
      currentText = fullMessage.substring(0, i + 1);

      setState(() {
        messages[messages.length - 1]["text"] = currentText; // تحديث آخر رسالة
      });

      scrollToBottom();
    }
    // إعادة تفعيل الإرسال بعد انتهاء الكتابة
    setState(() {
      _isBotTyping = false;
    });
  }

  Future<void> sendMessage(String userMessage) async {
    setState(() {
      messages.add({"sender": "user", "text": userMessage});
      _isBotTyping = true;
    });

    scrollToBottom();
    try {
      final response = await Dio().post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://myapp.test",
          },
        ),
        data: {
          "model": "openai/gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful medical assistant."
            },
            {"role": "user", "content": userMessage},
          ],
        },
      );

      final String botReply = response.data["choices"][0]["message"]["content"];

      // إظهار الرد بشكل تدريجي
      _simulateTypingEffect(botReply);
    } catch (e) {
      print("خطأ: $e");
      setState(() {
        _isBotTyping = false;
        messages.add({"sender": "bot", "text": "حدث خطأ: $e"});
      });
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).smart_assistant,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg["sender"] == "user"
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msg["sender"] == "user"
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dialogTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      msg["text"]!,
                      style: TextStyle(
                          color: msg["sender"] == "user"
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: S.of(context).type_question,
                        hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 133, 133, 133))),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _isBotTyping
                      ? null
                      : () {
                          if (_controller.text.isNotEmpty) {
                            sendMessage(_controller.text);
                            _controller.clear();
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
