import 'package:flutter/material.dart';
import 'package:fluttter_document_list/database_helper.dart';
import 'package:fluttter_document_list/document_list_screen.dart';
import 'package:fluttter_document_list/document_model.dart';
import 'package:fluttter_document_list/main.dart';

class EditDocumentFormScreen extends StatefulWidget {
  const EditDocumentFormScreen({Key? key}) : super(key: key);

  @override
  State<EditDocumentFormScreen> createState() => _EditDocumentFormScreenState();
}

class _EditDocumentFormScreenState extends State<EditDocumentFormScreen> {
  var _documentNameController = TextEditingController();
  var _selectedPersonValue;
  var _personDropdownList = <DropdownMenuItem>[];
  bool originalDefaultValue = false;
  bool scanDefaultValue = false;
  bool copyDefaultValue = false;

  var _personNameController = TextEditingController();

//edit only
  bool firstTimeFlag = false;
  int _selectedId = 0;

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

  _deleteFormDialog(BuildContext context) {
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
                      _selectedId, DatabaseHelper.documentTable);

                  debugPrint('----------> Deleted Row ID : $result');

                  if (result > 0) {
                    _showSuccessSnackBar(context, 'Deleted');
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DocumentListScreen()));
                  }
                },
                child: const Text('Delete'),
              ),
            ],
            title: const Text('Are you want to Delete this?'),
          );
        });
  }

  @override
  Widget build(BuildContext context) {

    if (firstTimeFlag == false) {
      print('-------> once execute');
      firstTimeFlag = true;
      final document =
      ModalRoute.of(context)!.settings.arguments as DocumentModel;
      print('---------> Received Data:');
      print(document.id);
      print(document.docName);
      print(document.original);
      print(document.scan);
      print(document.copy);
      print(document.personName);

      _selectedId = document.id!;
      _documentNameController.text = document.docName;

      _selectedPersonValue = document.personName;

      if (document.original == 'true') {
        print('------------> set Original true');
        originalDefaultValue = true;
      } else {
        print('-----------> set Original false');
        originalDefaultValue = false;
      }

      if (document.scan == 'true') {
        print('-----------> set Scan true');
        scanDefaultValue = true;
      } else {
        print('------------> set Scan false');
        scanDefaultValue = false;
      }

      if (document.copy == 'true') {
        print('----------> set Copy true');
        copyDefaultValue = true;
      } else {
        print('----------> set Copy false');
        copyDefaultValue = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Document'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(value: 1, child: Text('Delete')),
            ],
            elevation: 2,
            onSelected: (value) {
              if (value == 1) {
                _deleteFormDialog(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
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
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () async {
                  _showFromDialog(context);
                },
                child: Text('Add Person Name'),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () async {
                  _update();
                },
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _update() async {
    print('--------> Update');

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
    print('-------------> ID : $_selectedId');

    Map<String, dynamic> row = {
      DatabaseHelper.columnId: _selectedId,
      DatabaseHelper.columnDocName: _documentNameController.text,
      DatabaseHelper.columnOriginal: tempOriginalValue,
      DatabaseHelper.columnScan: tempScanValue,
      DatabaseHelper.columnCopy: tempCopyValue,
      DatabaseHelper.columnPersonName: _selectedPersonValue,
    };

    final result = await dbHelper.update(row, DatabaseHelper.documentTable);

    debugPrint('-----------> Updated Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Updated');
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => DocumentListScreen()));
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
