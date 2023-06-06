import 'package:flutter/material.dart';
import 'package:todo_task/Message/snackbar_help.dart';
import 'package:todo_task/addpage/add_page.dart';
import 'package:todo_task/search_page/search.dart';
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
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: MySearchDelegate());
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: Visibility(
        visible: isLoading,
        child: const Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: const Center(
              child: Text(
                'No Todo Item',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 25),
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                return _listItem(index);
              },
            ),
          ),
        ),
      ),

      ///floating action button that navigate to add todo page
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage, label: const Text('Add Todo')),
    );
  }

  ///Navigation to edit page
  Future<void> navigateToEditPage(Map item) async {
    final route =
        MaterialPageRoute(builder: (context) => AddTodoPage(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  ///Navigation to add page
  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(builder: (context) => const AddTodoPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  ///Navigation to delete page
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

  ///calling fetch function to extract data from server
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

  // showing data in a list view
  _listItem(index) {
    final item = items[index] as Map;
    final id = item['_id'];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ];
        }),
      ),
    );
  }
}
