import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyTasksApp());
}

class MyTasksApp extends StatefulWidget {
  const MyTasksApp({super.key});

  @override
  State<MyTasksApp> createState() => _MyTasksAppState();
}

class _MyTasksAppState extends State<MyTasksApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseLight = ThemeData.light(useMaterial3: true);
    final baseDark = ThemeData.dark(useMaterial3: true);

    final lightTheme = baseLight.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      textTheme: GoogleFonts.poppinsTextTheme(baseLight.textTheme),
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      chipTheme: baseLight.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );

    final darkTheme = baseDark.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseDark.textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF90CAF9),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C2536),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );

    return MaterialApp(
      title: 'MyTasks',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: TaskManagerHome(onToggleTheme: _toggleThemeMode, themeMode: _themeMode),
    );
  }
}

enum Priority { low, medium, high }
enum TaskCategory { work, personal, shopping, health, education }

class Task {
  String id;
  String title;
  String description;
  bool isCompleted;
  Priority priority;
  TaskCategory category;
  DateTime createdAt;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.category = TaskCategory.personal,
    required this.createdAt,
    this.dueDate,
  });
}

class TaskManagerHome extends StatefulWidget {
  const TaskManagerHome({super.key, required this.onToggleTheme, required this.themeMode});

  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  @override
  State<TaskManagerHome> createState() => _TaskManagerHomeState();
}

class _TaskManagerHomeState extends State<TaskManagerHome> with TickerProviderStateMixin {
  List<Task> tasks = [];
  TaskCategory selectedCategory = TaskCategory.work;
  bool showCompleted = true;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSampleTasks();
    _fabController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack));
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _initializeSampleTasks() {
    tasks = [
      Task(
        id: '1',
        title: 'Complete Flutter project',
        description: 'Finish the task management app with all features',
        priority: Priority.high,
        category: TaskCategory.work,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ),
      Task(
        id: '2',
        title: 'Buy groceries',
        description: 'Milk, bread, eggs, and vegetables',
        priority: Priority.medium,
        category: TaskCategory.shopping,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isCompleted: true,
      ),
      Task(
        id: '3',
        title: 'Morning workout',
        description: '30 minutes cardio and strength training',
        priority: Priority.low,
        category: TaskCategory.health,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<Task> get filteredTasks {
    return tasks.where((task) {
      if (!showCompleted && task.isCompleted) return false;
      return true;
    }).toList();
  }

  List<Task> get tasksByCategory {
    return filteredTasks.where((task) => task.category == selectedCategory).toList();
  }

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;
  int get totalTasksCount => tasks.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyTasks', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: showCompleted ? 'Hide completed' : 'Show completed',
            icon: Icon(showCompleted ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => showCompleted = !showCompleted),
          ),
          IconButton(
            tooltip: 'Statistics',
            icon: const Icon(Icons.analytics_outlined),
            onPressed: _showStatistics,
          ),
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(widget.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(context),
          _buildCategoryTabs(),
          Expanded(child: _buildTaskList()),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1C2536), const Color(0xFF0F172A)]
              : [const Color(0xFF3F51B5), const Color(0xFF63A4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  "Today's Tasks",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateTime.now().toString().split(' ')[0],
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                ),
              ]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$completedTasksCount/$totalTasksCount',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  Text('Completed', style: TextStyle(color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: totalTasksCount > 0 ? completedTasksCount / totalTasksCount : 0,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        children: TaskCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(_getCategoryIcon(category), size: 18, color: isSelected ? Colors.white : null),
                  const SizedBox(width: 8),
                  Text(
                    _getCategoryName(category),
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskList() {
    final categoryTasks = tasksByCategory;
    if (categoryTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 80, color: Theme.of(context).disabledColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No tasks in ${_getCategoryName(selectedCategory)}', style: TextStyle(color: Theme.of(context).hintColor)),
            const SizedBox(height: 8),
            Text('Tap + to add a new task', style: TextStyle(color: Theme.of(context).hintColor)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categoryTasks.length,
      itemBuilder: (context, index) => _buildTaskCard(categoryTasks[index]),
    );
  }

  Widget _buildTaskCard(Task task) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(task.id),
      tween: Tween(begin: 1, end: 1),
      duration: const Duration(milliseconds: 250),
      builder: (context, value, child) => AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: task.isCompleted ? 0.6 : 1,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: GestureDetector(
              onTap: () => _toggleTaskCompletion(task),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: task.isCompleted ? Colors.green : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted ? Colors.green : Theme.of(context).dividerColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: task.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(task.description),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _buildPriorityChip(task.priority),
                    Chip(
                      label: Text(_getCategoryName(task.category), style: const TextStyle(fontSize: 12)),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    ),
                    if (task.dueDate != null)
                      Chip(
                        label: Text('Due: ${task.dueDate!.toString().split(' ')[0]}', style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.orange.shade100,
                        labelStyle: TextStyle(color: Colors.orange.shade800),
                      ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditTaskDialog(task);
                } else if (value == 'delete') {
                  _deleteTask(task);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(Priority priority) {
    MaterialColor color;
    String text;
    switch (priority) {
      case Priority.high:
        color = Colors.red;
        text = 'High';
        break;
      case Priority.medium:
        color = Colors.orange;
        text = 'Medium';
        break;
      case Priority.low:
        color = Colors.green;
        text = 'Low';
        break;
    }
    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color.shade800),
    );
  }

  void _toggleTaskCompletion(Task task) {
    setState(() => task.isCompleted = !task.isCompleted);
  }

  void _deleteTask(Task task) {
    setState(() => tasks.removeWhere((t) => t.id == task.id));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
  }

  void _showAddTaskDialog() => _showTaskDialog();
  void _showEditTaskDialog(Task task) => _showTaskDialog(task: task);

  void _showTaskDialog({Task? task}) {
    final isEditing = task != null;
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(text: task?.description ?? '');
    Priority selectedPriority = task?.priority ?? Priority.medium;
    TaskCategory selectedTaskCategory = task?.category ?? selectedCategory;
    DateTime? selectedDueDate = task?.dueDate;

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Priority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                  items: Priority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))).toList(),
                  onChanged: (v) => setDialogState(() => selectedPriority = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskCategory>(
                  value: selectedTaskCategory,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: TaskCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(_getCategoryName(c)))).toList(),
                  onChanged: (v) => setDialogState(() => selectedTaskCategory = v!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due Date'),
                  subtitle: Text(selectedDueDate?.toString().split(' ')[0] ?? 'No due date'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate ?? DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030, 12, 31),
                    );
                    if (date != null) setDialogState(() => selectedDueDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a task title')));
                  return;
                }
                if (isEditing) {
                  setState(() {
                    task!.title = titleController.text.trim();
                    task.description = descriptionController.text.trim();
                    task.priority = selectedPriority;
                    task.category = selectedTaskCategory;
                    task.dueDate = selectedDueDate;
                  });
                } else {
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    priority: selectedPriority,
                    category: selectedTaskCategory,
                    createdAt: DateTime.now(),
                    dueDate: selectedDueDate,
                  );
                  setState(() => tasks.add(newTask));
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatistics() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatItem('Total Tasks', totalTasksCount.toString()),
            _buildStatItem('Completed', completedTasksCount.toString()),
            _buildStatItem('Pending', (totalTasksCount - completedTasksCount).toString()),
            _buildStatItem('Completion Rate', '${totalTasksCount > 0 ? ((completedTasksCount / totalTasksCount) * 100).toStringAsFixed(1) : 0}%'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }

  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.shopping:
        return 'Shopping';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.education:
        return 'Education';
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.shopping:
        return Icons.shopping_cart;
      case TaskCategory.health:
        return Icons.favorite;
      case TaskCategory.education:
        return Icons.school;
    }
  }
}
