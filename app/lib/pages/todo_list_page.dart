import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/list_view_item.dart';
import 'package:app/models/todo.dart';
import 'package:app/repositories/todoRepository.dart';

class TodoListApp extends StatefulWidget {
  const TodoListApp({super.key});

  @override
  State<TodoListApp> createState() => _TodoListAppState();
}

class _TodoListAppState extends State<TodoListApp> {
  final TextEditingController todoControler = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;

  void onDelete(Todo todo) {
    setState(() {
      deletedTodo = todo;
      deletedTodoPos = todos.indexOf(todo);
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Tarefa ${todo.title} removida com sucesso',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      action: SnackBarAction(
        label: 'Desfazer',
        textColor: const Color(0xff00d7f3),
        onPressed: () {
          setState(() {
            todos.insert(deletedTodoPos!, deletedTodo!);
          });
          todoRepository.saveTodoList(todos);
        },
      ),
      duration: Duration(seconds: 5),
    ));
  }

  void showDeleteAllTodosDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar todas as tarefas ?'),
        content: Text('Você tem certeza que deseja apagar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(212, 236, 59, 59)),
            child: Text(
              'Cancelar',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTodos();
            },
            style: TextButton.styleFrom(foregroundColor: Color(0xff00d7f3)),
            child: Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void deleteAllTodos() {
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
    errorText = null;
  }

  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Lista de Tarefas',
                  style: GoogleFonts.exo(
                    textStyle: TextStyle(
                      fontSize: 35,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: todoControler,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color(0xff00d7f3),
                          width: 2,
                        )),
                        border: OutlineInputBorder(),
                        labelText: 'Adicione uma tarefa',
                        labelStyle: GoogleFonts.exo(
                          textStyle: TextStyle(color: Color(0xff00d7f3)),
                        ),
                        hintText: 'Ex: Estudar',
                        hintStyle: TextStyle(
                          fontSize: 20,
                        ),
                        errorText: errorText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15),
                        backgroundColor: Color(0xff00d7f3)),
                    onPressed: () {
                      String text = todoControler.text;

                      if (text.isEmpty) {
                        setState(() {
                          errorText = 'A tarefa está vazia.';
                        });
                        return;
                      }
                      errorText = null;

                      setState(() {
                        Todo newTodo = Todo(
                          title: text,
                          dateTime: DateTime.now(),
                        );

                        todos.add(newTodo);
                      });
                      todoControler.clear();
                      todoRepository.saveTodoList(todos);
                    },
                    child: Icon(
                      Icons.add,
                      size: 30,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (Todo todo in todos.reversed)
                      ListViewItem(
                        todo: todo,
                        onDelete: onDelete,
                      )
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      todos.length == 1
                          ? 'Você possui ${todos.length} tarefa pendentes'
                          : 'Você possui ${todos.length} tarefas pendentes',
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff00d7f3),
                    ),
                    onPressed: showDeleteAllTodosDialog,
                    child: Text('Limpar tarefas!'),
                  )
                ],
              )
            ],
          ),
        )),
      ),
    );
  }
}
