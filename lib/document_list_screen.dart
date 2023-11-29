import 'package:flutter/material.dart';
import 'package:fluttter_document_list/database_helper.dart';
import 'package:fluttter_document_list/drawer_navigation.dart';
import 'package:fluttter_document_list/main.dart';
import 'document_model.dart';
import 'simple_document_form_screen.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({Key? key}) : super(key: key);

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  late List<DocumentModel> _documentlist;

  @override
  void initState() {
    super.initState();
    getAllDocuments();
  }

  getAllDocuments() async {
    _documentlist = <DocumentModel>[];

    var documents = await dbHelper.queryAllRows(DatabaseHelper.documentTable);

    documents.forEach((row) {
      setState(() {
        print(row['_id']);
        print(row['doc_name']);
        print(row['original']);
        print(row['scan']);
        print(row['copy']);
        print(row['person_name']);

        var documentModel = DocumentModel(row['_id'], row['doc_name'],
            row['original'], row['scan'], row['copy'], row['person_name']);

        _documentlist.add(documentModel);
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerNavigation(),
      appBar: AppBar(
        title: Text('Document List'),
      ),
      body: ListView.builder(
          itemCount: _documentlist.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  onTap: () {
                    print('--------------->Edit or Delete invoked : Send Data');
                    print(_documentlist[index].id);
                    print(_documentlist[index].docName);
                    print(_documentlist[index].original);
                    print(_documentlist[index].scan);
                    print(_documentlist[index].copy);
                    print(_documentlist[index].personName);

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SimpleDocumentFormScreen(),
                      settings: RouteSettings(arguments: _documentlist[index]),
                    ));
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[Text(_documentlist[index].docName)],
                  ),
                  subtitle: Text(_documentlist[index].personName),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('---------> FAB clicked');
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => SimpleDocumentFormScreen()));
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
