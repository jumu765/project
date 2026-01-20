import 'package:flutter/material.dart';
import 'package:todo_app/login_page.dart';
import 'package:todo_app/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _todoController = TextEditingController();
  final _todosStream = supabase.from('todos').stream(primaryKey: ['id']).order('id', ascending: true);

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error signing out'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _addTodo() async {
    final text = _todoController.text.trim();
    if (text.isEmpty) return;

    try {
      await supabase.from('todos').insert({
        'user_id': supabase.auth.currentUser!.id,
        'task': text,
        'done': false,
      });
      _todoController.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error adding todo'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleTodo(Map<String, dynamic> todo) async {
    try {
      await supabase.from('todos').update({
        'done': !todo['done'],
      }).eq('id', todo['id']);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error updating todo'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteTodo(int id) async {
    try {
      await supabase.from('todos').delete().eq('id', id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error deleting todo'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                      hintText: 'Enter new todo',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTodo,
                  icon: const Icon(Icons.add),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _todosStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final todos = snapshot.data!;
                if (todos.isEmpty) {
                  return const Center(child: Text('No todos yet'));
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return ListTile(
                      leading: Checkbox(
                        value: todo['done'],
                        onChanged: (_) => _toggleTodo(todo),
                      ),
                      title: Text(
                        todo['task'],
                        style: TextStyle(
                          decoration: todo['done']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTodo(todo['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
