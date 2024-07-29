/*import 'dart:io';
import 'dart:typed_data';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: "Gemini",
      profileImage:
          'https://kodefied.com/wp-content/uploads/2023/12/gemini-google-jpg.webp');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gemini Chatbot"),
        centerTitle: true,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
  return DashChat(
    messages: messages,
    onSend: _sendMessage,
    currentUser: currentUser,
    
  );
}

void _sendMessage(ChatMessage chatMessage) {
  setState(() {
    messages = [chatMessage, ...messages];
  });
  try {
    String question = chatMessage.text;
    gemini.streamGenerateContent(question).listen((event) {
      ChatMessage? lastMessage = messages.firstOrNull;
      if (lastMessage != null && lastMessage.user == geminiUser) {
        lastMessage = messages.removeAt(0);
        String response = event.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";
        lastMessage.text += response;
        setState(() {
          messages = [lastMessage!, ...messages];
        });
      } else {
        String response = event.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";
        ChatMessage message = ChatMessage(
          user: geminiUser, 
          createdAt: DateTime.now(), 
          text:response,
        );
        setState(() {
          messages = [message, ...messages];
        });
      }
    });
  } catch (e) {
    print(e);
  }
}

}*/

import 'dart:io';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(
      id: "0",
      firstName: "User",
      profileImage:
          'https://static.vecteezy.com/system/resources/thumbnails/005/129/844/small_2x/profile-user-icon-isolated-on-white-background-eps10-free-vector.jpg');
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: "Gemini",
      profileImage:
          'https://kodefied.com/wp-content/uploads/2023/12/gemini-google-jpg.webp');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gemini Chatbot"),
        centerTitle: true,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      messageOptions: MessageOptions(
        showTime: false,
        messageTextBuilder: (message, previousMessage, nextMessage) {
          Color textColor =
              message.user == currentUser ? Colors.white : Colors.black;
          return Text.rich(
            TextSpan(
              children: _parseText(message.text, textColor),
            ),
          );
        },
      ),
      messages: messages,
      onSend: _sendMessage,
      currentUser: currentUser,
      messageListOptions: MessageListOptions(
        chatFooterBuilder: Container(),
      ),
    );
  }

  List<TextSpan> _parseText(String text, Color textColor) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'<b>(.*?)</b>');

    int lastIndex = 0;
    for (Match match in boldPattern.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
            text: text.substring(lastIndex, match.start),
            style: TextStyle(color: textColor)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
          text: text.substring(lastIndex), style: TextStyle(color: textColor)));
    }

    return spans;
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;

      gemini.streamGenerateContent(question).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += convertMarkdownToHtml(response);
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: convertMarkdownToHtml(response),
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  String convertMarkdownToHtml(String text) {
    return text.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) {
      return '<b>${match.group(1)}</b>';
    });
  }
}
