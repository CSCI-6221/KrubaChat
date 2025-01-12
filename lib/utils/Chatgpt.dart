import 'package:dart_openai/openai.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

class ChatGPT {
  static final ChatGPT _instance = ChatGPT._();

  factory ChatGPT() => _getInstance();

  static ChatGPT get instance => _getInstance();

  ChatGPT._();

  static ChatGPT _getInstance() {
    return _instance;
  }

  static GetStorage storage = GetStorage();

  static String chatGptToken =
      dotenv.env['OPENAI_CHATGPT_TOKEN'] ?? ''; // token
  static String defaultModel = 'gpt-3.5-turbo';
  static List defaultRoles = [
    'system',
    'user',
    'assistant'
  ]; // generating | error

  static List chatModelList = [
    {
      "type": "chat",
      "name": "Kruba Chat",
      "desc": "Converse With Kruba!",
      "isContinuous": true,
      "content": "\nInstructions:"
          "\nYou are Kruba, a chat assistant envisioned in professor melo's class. The answer to each question should be as concise as possible. If you're making a list, don't have too many entries."
          " If possible, please format it in a friendly markdown format."
          '\n',
      "tips": [
        "Write me a wholesome quote",
        "I need a sarcastic joke?",
        "Help me plan a trip",
        "I need a pickup line!"
      ],
    },
        {
      "type": "storyteller",
      "name": "Kruba, the Storyteller",
      "desc":
          "AI will come up with interesting stories that are engaging, imaginative and captivating to the audience",
      "isContinuous": false,
      "content": "\nInstructions:"
          "\nI want you to act as a storyteller. You will come up with entertaining stories that are engaging, imaginative and captivating for the audience. It can be fairy tales, educational stories or any other type of stories which has the potential to capture people's attention and imagination. Depending on the target audience, you may choose specific themes or topics for your storytelling session e.g., if it’s children then you can talk about animals; If it’s adults then history-based tales might engage them better etc. "
          " If possible, please format it in a friendly markdown format."
          '\n',
      "tips": [
        "I need an story on how a rich man become poor due to his bad ethics",
      ],
    },
        {
      "type": "legalAdvisor",
      "name": "Kruba, as Legal Advisor",
      "desc":
          "AI as your legal advisor. You need to describe a legal situation and the AI will provide advice on how to handle it",
      "isContinuous": false,
      "content": "\nInstructions:"
          "\nI want you to act as my legal advisor. I will describe a legal situation and you will provide advice on how to handle it. You should only reply with your advice, and nothing else. Do not write explanations."
          " If possible, please format it in a friendly markdown format."
          '\n',
      "tips": [
        'I’m making surrealistic portrait paintings',
      ],
    },
        {
      "type": "positionInterviewer",
      "name": "Kruba, the Interviewer",
      "desc":
          "AI interviewer. As a candidate, AI will ask you interview questions for the position",
      "isContinuous": false,
      "content": "\nInstructions:"
          "\nI want you to act as an interviewer. I will be the candidate and you will ask me the interview questions for the position position. I want you to only reply as the interviewer. Do not write all the conservation at once. I want you to only do the interview with me. Ask me the questions and wait for my answers. Do not write explanations. Ask me the questions one by one like an interviewer does and wait for my answers."
          " If possible, please format it in a friendly markdown format."
          '\n',
      "tips": [
        "Hello, I'm a full stack javascript engineer",
        "Hello, I'm a marketing genius",
        "Hello, I'm a financial officer",
      ],
    },
    {
      "type": "translationLanguage",
      "name": "Kruba, The Translator",
      "desc": "Translate any language to any language",
      "isContinuous": false,
      "content": '\nnInstructions:\n'
          'I want you to act as a translator. You will recognize the language, translate it into the specified language and answer me. Please do not use an interpreter accent when translating, but to translate naturally, smoothly and authentically, using beautiful and elegant expressions. I will give you the format of "Translate A to B". If the format I gave is wrong, please tell me that the format of "Translate A to B" should be used. Please only answer the translation part, do not write the explanation.'
          " If possible, please format it in a friendly markdown format."
          '\n',
      "tips": [
        "Translate love to spanish",
        "Translate beautiful to bengali",
        "Translate How are you to german",
      ],
    },
    {
      "type": "frontEndHelper",
      "name": "Kruba, as Engineer",
      "desc": "Kruba, the front-end guide",
      "isContinuous": false,
      "content": '\nnInstructions:\n'
          "I want you to be an expert in front-end development. I'm going to provide some specific information about front-end code issues with Js, Node, etc., and your job is to come up with a strategy to solve the problem for me. This may include suggesting code, strategies for logical thinking about code."
          " If possible, please format it in a friendly markdown format."
          '\n',
      "tips": [
        "JavaScript recursive binary tree",
      ],
    },
    {
      "type": "javaScriptConsole",
      "name": "Kruba, as JavaScript Console",
      "desc":
          "As javascript console. Type the command and the AI will reply with what the javascript console should show",
      "isContinuous": false,
      "content": "\nInstructions:"
          "\nI want you to act as a javascript console. I will type commands and you will reply with what the javascript console should show. I want you to only reply with the terminal output inside one unique code block, and nothing else. do not write explanations. do not type commands unless I instruct you to do so. when I need to tell you something in english, I will do so by putting text inside curly brackets {like this}."
          " If possible, please format it in a friendly markdown format."
          '\n',
      "tips": [
        'console.log("Hello World");',
        'window.alert("Hello");',
      ],
    },
  ];

  static Future<void> setOpenAIKey(String key) async {
    await storage.write('OpenAIKey', key);
    await initChatGPT();
  }

  static String getCacheOpenAIKey() {
    String? key = storage.read('OpenAIKey');
    if (key != null && key != '' && key != chatGptToken) {
      return key;
    }
    return '';
  }

  static Future<void> setOpenAIBaseUrl(String url) async {
    await storage.write('OpenAIBaseUrl', url);
    await initChatGPT();
  }

  static String getCacheOpenAIBaseUrl() {
    String? key = storage.read('OpenAIBaseUrl');
    return (key ?? "").isEmpty ? "" : key!;
  }

  static Set chatModelTypeList =
      chatModelList.map((map) => map['type']).toSet();


  static getAiInfoByType(String chatType) {
    return chatModelList.firstWhere(
      (item) => item['type'] == chatType,
      orElse: () => null,
    );
  }

  static Future<void> initChatGPT() async {
    String cacheKey = getCacheOpenAIKey();
    String cacheUrl = getCacheOpenAIBaseUrl();
    var apiKey = cacheKey != '' ? cacheKey : chatGptToken;
    OpenAI.apiKey = apiKey;
    if (apiKey != chatGptToken) {
      OpenAI.baseUrl =
          cacheUrl.isNotEmpty ? cacheUrl : "https://api.openai.com";
    }
  }

  static getRoleFromString(String role) {
    if (role == "system") return OpenAIChatMessageRole.system;
    if (role == "user") return OpenAIChatMessageRole.user;
    if (role == "assistant") return OpenAIChatMessageRole.assistant;
    return "unknown";
  }

  static convertListToModel(List messages) {
    List<OpenAIChatCompletionChoiceMessageModel> modelMessages = [];
    for (var element in messages) {
      modelMessages.add(OpenAIChatCompletionChoiceMessageModel(
        role: getRoleFromString(element["role"]),
        content: element["content"],
      ));
    }
    return modelMessages;
  }

  static List filterMessageParams(List messages) {
    List newMessages = [];
    for (var v in messages) {
      if (defaultRoles.contains(v['role'])) {
        newMessages.add({
          "role": v["role"],
          "content": v["content"],
        });
      }
    }
    return newMessages;
  }

  static Future<bool> checkRelation(
    List beforeMessages,
    Map message, {
    String model = '',
  }) async {
    beforeMessages = filterMessageParams(beforeMessages);
    String text = "\nInstructions:"
        "\nCheck whether the problem is related to the given conversation. If yes, return true. If no, return false. Please return only true or false. The answer length is 5."
        "\nquestion：$message}"
        "\nconversation：$beforeMessages"
        "\n";
    OpenAIChatCompletionModel chatCompletion = await sendMessage(
      [
        {
          "role": 'user',
          "content": text,
        }
      ],
      model: model,
    );
    debugPrint('---text $text---');
    String content = chatCompletion.choices.first.message.content ?? '';
    bool hasRelation = content.toLowerCase().contains('true');
    debugPrint('--- $hasRelation---');
    return hasRelation;
  }

  static Future<OpenAIChatCompletionModel> sendMessage(
    List messages, {
    String model = '',
  }) async {
    messages = filterMessageParams(messages);
    List<OpenAIChatCompletionChoiceMessageModel> modelMessages =
        convertListToModel(messages);
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: model != '' ? model : defaultModel,
      messages: modelMessages,
    );
    return chatCompletion;
  }

  static Future sendMessageOnStream(
    List messages, {
    String model = '',
    Function? onProgress,
  }) async {
    messages = filterMessageParams(messages);
    List<OpenAIChatCompletionChoiceMessageModel> modelMessages =
        convertListToModel(messages);

    Stream<OpenAIStreamChatCompletionModel> chatStream =
        OpenAI.instance.chat.createStream(
      model: defaultModel,
      messages: modelMessages,
    );
    print(chatStream);

    chatStream.listen((chatStreamEvent) {
      print('---chatStreamEvent---');
      print('$chatStreamEvent');
      print('---chatStreamEvent end---');
      if (onProgress != null) {
        onProgress(chatStreamEvent);
      }
    });
  }

  static Future<OpenAIImageModel> genImage(String imageDesc) async {
    debugPrint('---genImage starting: $imageDesc---');
    OpenAIImageModel image = await OpenAI.instance.image.create(
      prompt: imageDesc,
      n: 1,
      size: OpenAIImageSize.size1024,
      responseFormat: OpenAIImageResponseFormat.url,
    );
    debugPrint('---genImage success: $image---');
    return image;
  }
}
