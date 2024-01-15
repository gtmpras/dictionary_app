import 'package:dictionary/model/api.dart';
import 'package:dictionary/model/response_model.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool inProgress = false;
  ResponseModel? responseModel;
  String noDataText = "Welcome, Start searching";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSearchWidget(),
              SizedBox(
                height: 20,
              ),
              if (inProgress)
                const LinearProgressIndicator()
              else if (responseModel != null)
                Expanded(child: _buildResponseWidget())
              else
                _noDataWidget()
            ],
          ),
        ),
      ),
    );
  }

  _buildResponseWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16,
        ),
        Text(
          responseModel!.word!,
          style: TextStyle(
            color: Colors.blue,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (responseModel!.phonetics != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: responseModel!.phonetics!.map((phonetic) {
              return Text(phonetic.text ?? "");
            }).toList(),
          ),
        const SizedBox(
          height: 20,
        ),
        Expanded(
            child: ListView.builder(
          itemBuilder: (context, index) {
            return _buildMeaningWidget(responseModel!.meanings![index]);
          },
          itemCount: responseModel!.meanings!.length,
        ))
      ],
    );
  }

  _buildMeaningWidget(Meanings meanings) {
    String definitionList = "";
    meanings.definitions?.forEach(
      (element) {
        int index = meanings.definitions!.indexOf(element);
        definitionList += "\n${index + 1}. ${element.definition}\n";
      },
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meanings.partOfSpeech!,
              style: TextStyle(
                  color: Colors.orange.shade500,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              "Definitions: ",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(definitionList),
            _buildSet("Synonyms", meanings.synonyms),
            _buildSet("Antonyms", meanings.antonyms),
          ],
        ),
      ),
    );
  }

  _noDataWidget() {
    return SizedBox(
      height: 100,
      child: Text(
        noDataText,
        style: TextStyle(fontSize: 25),
      ),
    );
  }

  _buildSet(String title, List<String>? setList) {
    if (setList?.isNotEmpty ?? false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(setList!
          .toSet()
          .toString()
          .replaceAll("{", "")
          .replaceAll("{", "")
          ),
          SizedBox(height: 10,),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  _buildSearchWidget() {
    return SearchBar(
      hintText: "Search word here",
      onSubmitted: (value) {
        //get meaning from api
        _getMeaningFromApi(value);
      },
    );
  }

  _getMeaningFromApi(String word) async {
    setState(() {
      inProgress = true;
    });
    try {
      responseModel = await API.fetchMeaning(word);
      setState(() {});
    } catch (e) {
      responseModel = null;
      noDataText="Meaning cannot be fetched.";
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
