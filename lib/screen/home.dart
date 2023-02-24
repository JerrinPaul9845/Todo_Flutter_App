import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_task/Message/snackbar_help.dart';
import 'package:todo_task/addpage/add_page.dart';
import 'package:http/http.dart' as http;
import 'package:todo_task/todoServices/todo_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Application'),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                'No Todo Item',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(onSelected: (value) {
                      if (value == 'edit') {
                        // perform edit
                        navigateToEditPage(item);
                      } else if (value == 'delete') {
                        // perform delete
                        deleteById(id);
                      }
                    }, itemBuilder: (context) {
                      return [
                        PopupMenuItem(child: Text('Edit'), value: 'edit'),
                        PopupMenuItem(child: Text('Delete'), value: 'delete'),
                      ];
                    }),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage, label: const Text('Add Todo')),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    final route =
        MaterialPageRoute(builder: (context) => AddTodoPage(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(builder: (context) => const AddTodoPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    // delete item
    final isSuccess = await TodoServices.deleteById(id);
    if (isSuccess) {
      // remove item from list
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      // error message
      showFailMessage(context, message: 'Deletion Failed');
    }
  }

  Future<void> fetchTodo() async {
    setState(() {
      isLoading = true;
    });
    final getData = await TodoServices.fetchTodos();
    if (getData != null) {
      setState(() {
        items = getData;
      });
    } else {
      showFailMessage(context, message: 'Something went wrong');
    }
    setState(() {
      isLoading = false;
    });
  }
}
