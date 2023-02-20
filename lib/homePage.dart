import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _userNameTextController = TextEditingController();
  final _repoTextController = TextEditingController();

  String userName = '';
  String repo = '';
  int perPage = 5;
  bool disableNextPage = true;
  int pageNo = 1;
  List<TableRow> tableRows = [];
  var myHeadingStyle = const TextStyle(color: Colors.white, fontSize: 30);
  var myTextStyle = const TextStyle(color: Colors.white, fontSize: 15);
  var myHintStyle = const TextStyle(color: Colors.grey, fontSize: 15);

  var myTableHeaderStyle = const TextStyle(
      color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[800],
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Find Closed PRs for a username and repository',
                        style: myHeadingStyle),
                  ],
                ),
              ),
            ),
            Wrap(spacing: 10, runSpacing: 1, children: [
              Container(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 400,
                      child: TextField(
                        controller: _userNameTextController,
                        style: myTextStyle,
                        decoration: InputDecoration(
                            hintText: "Enter UserName",
                            hintStyle: myHintStyle,
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white24)),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _userNameTextController.clear();
                              },
                              icon: const Icon(Icons.clear),
                              color: Colors.white24,
                            )),
                      ),
                    )
                  ],
                ),
              )),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: _repoTextController,
                          style: myTextStyle,
                          decoration: InputDecoration(
                              hintText: "Enter Repository",
                              hintStyle: myHintStyle,
                              border: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white24)),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _repoTextController.clear();
                                },
                                icon: const Icon(Icons.clear),
                                color: Colors.white24,
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        IconButton(
                           icon: const Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              userName = _userNameTextController.text;
                              repo = _repoTextController.text;
                            });
                            _fetchGitHubPRs();
                          },
                        ),
                      ]))
            ]),
            Row(children: [
              Expanded(
                flex: 8,
                child: Column(),
              ),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            color: Colors.blue,
                            onPressed: pageNo <= 1
                                ? null
                                : () => {
                                      setState(() {
                                        pageNo--;
                                      }),
                                      _fetchGitHubPRs()
                                    },
                            icon: const Icon(Icons.navigate_before),
                          )
                        ],
                      ))),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            color: Colors.blue,
                            onPressed: disableNextPage
                                ? null
                                : () => {
                                      setState(() {
                                        pageNo++;
                                      }),
                                      _fetchGitHubPRs()
                                    },
                            icon: const Icon(Icons.navigate_next),
                          )
                        ],
                      ))),
            ]),
            Expanded(
                // child: Container(
                //   color: Colors.red,
                // ),
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                border: TableBorder.all(color: Colors.white24, width: 2),
                columnWidths: const {
                  0: FlexColumnWidth(1.5),
                  1: FlexColumnWidth(4),
                  2: FlexColumnWidth(2),
                },
                children: [
                      TableRow(
                          decoration: const BoxDecoration(color: Colors.grey),
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Title",
                                style: myTableHeaderStyle,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Created on",
                                style: myTableHeaderStyle,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Closed on",
                                style: myTableHeaderStyle,
                              ),
                            ),
                          ]),
                    ] +
                    tableRows,
              ),
            ))
          ],
        ));
  }

  void _fetchGitHubPRs() async {
    String url =
        'https://api.github.com/repos/$userName/$repo/pulls?state=closed&page=$pageNo&per_page=$perPage';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    List<dynamic> json = jsonDecode(body);
    setState(() {
      tableRows.clear();
    });
    print('url is' + url);
    print('page no : ' + pageNo.toString());

    if (json.isNotEmpty) {
      for (int i = 0; i < perPage; i++) {
        if (i == json.length) {
          break;
        }
        setState(() {
          tableRows.add(TableRow(children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                json[i]['title'],
                style: myTextStyle,
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('HH:mm, dd/MM/yyyy')
                    .format(DateTime.parse(json[i]['created_at']))
                    .toString(),
                style: myTextStyle,
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('HH:mm, dd/MM/yyyy')
                    .format(DateTime.parse(json[i]['closed_at']))
                    .toString(),
                style: myTextStyle,
              ),
            ),
          ]));
        });
      }
    }

    setState(() {
      disableNextPage = tableRows.length < perPage ? true : false;
    });
  }
}
