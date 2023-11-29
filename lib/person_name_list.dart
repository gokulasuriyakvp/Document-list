import 'package:flutter/material.dart';
import 'package:fluttter_document_list/database_helper.dart';
import 'package:fluttter_document_list/person_name_list_model.dart';
import 'main.dart';

class PersonNameListScreen extends StatefulWidget {
  const PersonNameListScreen({Key? key}) : super(key: key);

  @override
  State<PersonNameListScreen> createState() => _PersonNameListScreenState();
}

class _PersonNameListScreenState extends State<PersonNameListScreen> {
  var _personNameController = TextEditingController();

  late List<PersonNameListModel> _personNameList;

  @override
  initState() {
    super.initState();
    getAllPersonNameList();
  }

  getAllPersonNameList() async {
    _personNameList = <PersonNameListModel>[];

    var person = await dbHelper.queryAllRows(DatabaseHelper.personTable);

    if (person == null) {
      print('--------> Person Table is empty');
    } else {
      person.forEach((row) {
        print(row['_id']);
        print(row['person_name']);

        var personNameModel =
        PersonNameListModel(row['_id'], row['person_name']);

        setState(() {
          _personNameList.add(personNameModel);
        });
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Person Name List'),
      ),
      body: ListView.builder(
          itemCount: _personNameList.length,
          itemBuilder: (context, index) {
            return Padding(
                padding:
                const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: Card(
                  elevation: 8.0,
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        print('--------> Edit Clicked');
                        _editFormDialog(context, _personNameList[index].id);
                      },
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(_personNameList[index].personName),
                        IconButton(
                          onPressed: () {
                            print('----------> Delete Clicked');
                            _deleteFormDialog(
                                context, _personNameList[index].id);
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('------> Person Name List - FAB clicked');
          _showFromDialog(context);
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }

  void _savePersonName() async {
    print('-----------------> Save Person Name');
    print('-----------> Person Name = $_personNameController.text');

    Map<String, dynamic> row = {
      DatabaseHelper.columnPersonName: _personNameController.text,
    };

    final result = await dbHelper.insert(row, DatabaseHelper.personTable);

    debugPrint('-----------> inserted row id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Saved');
      getAllPersonNameList();
    }

    _personNameController.clear();
  }

  _showFromDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    print('-------> Cancel Invoked');
                    Navigator.pop(context);
                    _personNameController.clear();
                  },
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: () async {
                    print('--------> Save Invoked');
                    _savePersonName();
                  },
                  child: Text('Save')),
            ],
            title: Text('Person Name'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _personNameController,
                    decoration: InputDecoration(hintText: 'Enter Person Name'),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  _deleteFormDialog(BuildContext context, personId) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await dbHelper.delete(
                      personId, DatabaseHelper.personTable);

                  debugPrint('----------> Deleted Row Id : $result');

                  if (result > 0) {
                    _showSuccessSnackBar(context, 'Deleted');
                    Navigator.pop(context);
                    setState(() {
                      getAllPersonNameList();
                    });
                  }
                },
                child: const Text('Delete'),
              ),
            ],
            title: const Text('Are you want to delete this?'),
          );
        });
  }

  _editFormDialog(BuildContext context, personId) async {
    print(personId);

    var row = await dbHelper.readDataById(DatabaseHelper.personTable, personId);

    setState(() {
      _personNameController.text = row[0]['person_name'] ?? 'No Data';
    });

    _editPersonNameDialog(context, personId);
  }

  _editPersonNameDialog(BuildContext context, personId) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  print('-----------> Cancel Clicked');
                  Navigator.pop(context);
                  _personNameController.clear();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  print('--------> Update Clicked');
                  _updatePersonName(personId);
                },
                child: Text('Update'),
              ),
            ],
            title: const Text('Person Name'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _personNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter Person Name',
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _updatePersonName(int personId) async {
    print('-----------> Person Name : $_personNameController.text');
    print('------------> Person Id : $personId');

    Map<String, dynamic> row = {
      DatabaseHelper.columnId: personId,
      DatabaseHelper.columnPersonName: _personNameController.text,
    };

    final result = await dbHelper.update(row, DatabaseHelper.personTable);

    debugPrint('-----------> Updated Row Id : $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Updated');
      getAllPersonNameList();
    }

    _personNameController.clear();
  }
}
