import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_list/helpers/task_helper.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/views/task_log.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> _taskList = [];
  TaskHelper _helper = TaskHelper();
  bool _loading = true;
  bool isChecked;

  @override
  void initState() {
    super.initState();
    _helper.getAll().then((list) {
      setState(() {
        _taskList = list;
        _loading = false;
      });
    });
    print('initState HomePage');
  }

  @override
  Widget build(BuildContext context) {
    print('build HomePage');

    return Scaffold(
      appBar: AppBar(title: Text('Minhas Tarefas')),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: _addNewTask),
      body: _buildTaskList(),
    );
  }

  Widget _buildTaskList() {
    print('buildTasklist HomePage');

    if (_taskList.isEmpty) {
      return Center(
        child: _loading ? CircularProgressIndicator() : Text("Não há tarefas!"),
      );
    } else {
      return ListView.builder(
        itemBuilder: _buildTaskItemSlidable,
        itemCount: _taskList.length,
      );
    }
  }

  Widget _buildTaskItem(BuildContext context, int index) {
    print('buildTaskItem HomePage');

    final task = _taskList[index];
    return CheckboxListTile(
      value: task.isDone,
      title: Text(task.title),
      subtitle: Text(task.description),
      onChanged: (isChecked) {
        setState(() {
          task.isDone = isChecked;
        });

        _helper.update(task);
      },
    );
  }

  Widget _buildTaskItemSlidable(BuildContext context, int index) {
    print('buildTaskItemSlidable HomePage');

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _buildTaskItem(context, index),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Editar',
          color: Colors.green,
          icon: Icons.edit,
          onTap: () {
            _addNewTask(editedTask: _taskList[index], index: index);
          },
        ),
        IconSlideAction(
          caption: 'Excluir',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            _deleteTask(deletedTask: _taskList[index], index: index);
          },
        ),
      ],
    );
  }

  Future _addNewTask({Task editedTask, int index}) async {
    print('addNewTask HomePage');

    final task = await showDialog<Task>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TaskDialog(task: editedTask);
      },
    );

    if (task != null) {
      setState(() {
        if (index == null) {
          _taskList.add(task);
          _helper.save(task);
        } else {
          _taskList[index] = task;
          _helper.update(task);
        }
      });
    }
  }

  void _deleteTask({Task deletedTask, int index}) {
    print('deleteTask HomePage');

    setState(() {
      _taskList.removeAt(index);
    });

    _helper.delete(deletedTask.id);

    Flushbar(
      titleText: Text("Removendo tarefa",
          style: TextStyle(
            color: Colors.black,
          )),
      messageText: Text("A tarefa \"${deletedTask.title}\" vai ser removida.",
          style: TextStyle(
            color: Colors.black,
          )),
      backgroundColor: Colors.yellow,
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 5),
      mainButton: FlatButton(
        child: Text(
          "Desfazer",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          setState(() {
            _taskList.insert(index, deletedTask);
            _helper.update(deletedTask);
          });
        },
      ),
    )..show(context);
    print('Flushbar um alerta da HomePage');
  }
}
