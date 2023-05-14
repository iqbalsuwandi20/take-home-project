import 'package:flutter/material.dart';
import 'package:take_home_project/screens/add_page.dart';
import 'package:take_home_project/services/todo_service.dart';
import 'package:take_home_project/widget/todo_card.dart';

import '../utils/snackbar_helper.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List"),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: Center(child: CircularProgressIndicator()),
        child: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                'No Todo Item',
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
                padding: EdgeInsets.all(8),
                itemBuilder: (context, index) {
                final item = items[index] as Map;
                  return TodoCard(
                      index: index,
                      item: item,
                      navigateEdit: navigateToEditPage,
                      deleteById: deleteById
                  );
                }
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage,
          label: Text('Add Todo'),
      ),
    );
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
        builder: (context) => AddTodoPage()
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
        builder: (context) => AddTodoPage(todo: item)
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    final isSuccess = await TodoService.deleteById(id);
    if(isSuccess) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showErrorMessage(context, message: 'Delection Failed');
    }
  }

  Future<void> fetchTodo() async {
    final response = await TodoService.fetchTodos();
    if(response != null) {
      setState(() {
        items = response;
      });
    } else {
      showErrorMessage(context, message: 'Something went wrong');
    }
    setState(() {
      isLoading = false;
    });
  }

}
