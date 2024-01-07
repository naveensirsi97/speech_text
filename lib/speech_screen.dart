import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_text/color.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  var text = "Hold the button and start speaking";
  var isListening = false;
  final SpeechToText speechToText = SpeechToText();
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<FormFieldState<String>> _textFieldKey = GlobalKey();
  final List<String> undoHistory = [];
  List<String> speechSegments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'Speech to Text',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showPopupMenu(context);
            },
            icon: const Icon(
              Icons.more_vert_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(
          top: 12,
          left: 12,
          right: 12,
          bottom: 8,
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: speechSegments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextFormField(
                      key: Key('segment_$index'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: const Color(0xFF676767),
                      controller:
                          TextEditingController(text: speechSegments[index]),
                      onChanged: (newText) {
                        setState(() {
                          speechSegments[index] = newText;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.only(left: 10, top: 10),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: bgColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: bgColor),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: _textFieldKey,
                    style: const TextStyle(
                      color: Color(0xFF676767),
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                    cursorColor: const Color(0xFF676767),
                    controller: _textEditingController,
                    onChanged: (newText) {
                      setState(() {
                        if (speechSegments.isNotEmpty) {
                          speechSegments[speechSegments.length - 1] = newText;
                        }
                        text = newText;
                        undoHistory.add(_textEditingController.text);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Hold the button and start speaking',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: bgColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: bgColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                AvatarGlow(
                  animate: isListening,
                  duration: const Duration(milliseconds: 2000),
                  glowColor: bgColor,
                  repeat: true,
                  child: GestureDetector(
                    onTapDown: (details) async {
                      if (!isListening) {
                        var available = await speechToText.initialize();
                        if (available) {
                          setState(() {
                            isListening = true;
                            speechSegments.add("");
                            speechToText.listen(onResult: (result) {
                              setState(() {
                                text = result.recognizedWords;
                                if (speechSegments.isNotEmpty) {
                                  speechSegments[speechSegments.length - 1] =
                                      result.recognizedWords;
                                } else {
                                  speechSegments.add(result.recognizedWords);
                                }
                                _textEditingController.text =
                                    result.recognizedWords;
                              });
                            });
                          });
                        }
                      }
                    },
                    onTapUp: (details) {
                      setState(() {
                        isListening = false;
                      });
                      speechToText.stop();
                    },
                    child: CircleAvatar(
                      backgroundColor: bgColor,
                      radius: 27,
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromCircle(
          center: const Offset(450, 5),
          radius: 0,
        ),
        Offset.zero & MediaQuery.of(context).size,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'cut',
          child: Text('Cut'),
        ),
        const PopupMenuItem<String>(
          value: 'copy',
          child: Text('Copy'),
        ),
        const PopupMenuItem<String>(
          value: 'paste',
          child: Text('Paste'),
        ),
        const PopupMenuItem<String>(
          value: 'undo',
          child: Text('Undo'),
        ),
      ],
    ).then((value) => onPopupMenuSelected(value!));
  }

  void onPopupMenuSelected(String value) {
    if (value == 'cut') {
      _cutText();
    } else if (value == 'copy') {
      _copyText();
    } else if (value == 'paste') {
      _pasteText();
    } else if (value == 'undo') {
      _undoText();
    }
  }

  void _cutText() {
    if (_textFieldKey.currentState != null) {
      Clipboard.setData(ClipboardData(text: _textEditingController.text));
      _textEditingController.text = '';
    }
  }

  void _copyText() {
    if (_textFieldKey.currentState != null) {
      Clipboard.setData(ClipboardData(text: _textEditingController.text));
    }
  }

  void _pasteText() {
    if (_textFieldKey.currentState != null) {
      Clipboard.getData(Clipboard.kTextPlain).then((value) {
        if (value != null) {
          _textEditingController.text = value.text!;
        }
      });
    }
  }

  void _undoText() {
    if (undoHistory.isNotEmpty) {
      setState(() {
        _textEditingController.text = undoHistory.removeLast();
      });
    }
  }
}
