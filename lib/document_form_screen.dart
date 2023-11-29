import 'package:flutter/material.dart';
import 'package:fluttter_document_list/database_helper.dart';
import 'package:fluttter_document_list/document_list_screen.dart';
import 'package:fluttter_document_list/main.dart';


class DocumentFormScreen extends StatefulWidget {
  const DocumentFormScreen({Key? key}) : super(key: key);

  @override
  State<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends State<DocumentFormScreen> {
  var _documentNameController = TextEditingController();
  var _selectedPersonValue;
  var _personDropdownList = <DropdownMenuItem>[];
  bool originalDefaultValue = false;
  bool scanDefaultValue = false;
  bool copyDefaultValue = false;

  var _personNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllPerson();
  }

  getAllPerson() async {
    var person = await dbHelper.queryAllRows(DatabaseHelper.personTable);

    person.forEach((row) {
      setState(() {
        _personDropdownList.add(DropdownMenuItem(
          child: Text(row['person_name']),
          value: row['person_name'],
        ));
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Document'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _documentNameController,
                decoration: InputDecoration(
                  labelText: 'Document Name',
                  hintText: 'Enter Document Name',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Original :',
                          style: TextStyle(fontSize: 17.0),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Checkbox(
                            value: this.originalDefaultValue,
                            onChanged: (value) {
                              setState(() {
                                this.originalDefaultValue = value!;
                                print(
                                    '---------> Original Checkbox Status: $value');
                              });
                            })
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Scan :',
                          style: TextStyle(fontSize: 17.0),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Checkbox(
                            value: this.scanDefaultValue,
                            onChanged: (value) {
                              setState(() {
                                this.scanDefaultValue = value!;
                                print(
                                    '----------> Scan Checkbox Status: $value');
                              });
                            }),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Card(
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Copy :',
                          style: TextStyle(
                            fontSize: 17.0,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Checkbox(
                            value: this.copyDefaultValue,
                            onChanged: (value) {
                              setState(() {
                                this.copyDefaultValue = value!;
                                print(
                                    '-----------> Copy Check Box Status: $value');
                              });
                            }),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              DropdownButtonFormField(
                  value: _selectedPersonValue,
                  items: _personDropdownList,
                  hint: Text('Person Name'),
                  onChanged: (value) {
                    setState(() {
                      _selectedPersonValue = value;
                      print(_selectedPersonValue);
                    });
                  }),
              SizedBox(height: 50,),
              ElevatedButton(onPressed: () async {
                _showFromDialog(context);
              },
                child: Text('Add Person Name'),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () async {
                  _save();
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _save() async {
    print('--------> Save');

    String tempOriginalValue = 'false';
    String tempScanValue = 'false';
    String tempCopyValue = 'false';

    if (originalDefaultValue == true) {
      print('------------> Save Original true');
      tempOriginalValue = 'true';
    } else {
      print('-----------> Save Original false');
      tempOriginalValue = 'false';
    }

    if (scanDefaultValue == true) {
      print('-----------> Save Scan true');
      tempScanValue = 'true';
    } else {
      print('------------> Save Scan false');
      tempScanValue = 'false';
    }

    if (copyDefaultValue == true) {
      print('----------> Save Copy true');
      tempCopyValue = 'true';
    } else {
      print('----------> Save Copy false');
      tempCopyValue = 'false';
    }

    print('-------> Document Name : ${_documentNameController.text}');
    print('--------> Original : $tempOriginalValue');
    print('--------> Scan : $tempScanValue');
    print('---------> Copy : $tempCopyValue');
    print('-----------> Person Name: $_selectedPersonValue');

    Map<String, dynamic> row = {
      DatabaseHelper.columnDocName: _documentNameController.text,
      DatabaseHelper.columnOriginal: tempOriginalValue,
      DatabaseHelper.columnScan: tempScanValue,
      DatabaseHelper.columnCopy: tempCopyValue,
      DatabaseHelper.columnPersonName: _selectedPersonValue,
    };

    final result = await dbHelper.insert(row, DatabaseHelper.documentTable);

    debugPrint('-----------> Inserted Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Saved');
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => DocumentListScreen()));
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
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
      _personDropdownList.clear();
      getAllPerson();
    }

    _personNameController.clear();
  }
}
