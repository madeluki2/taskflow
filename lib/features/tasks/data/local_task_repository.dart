import '../domain/task.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  final List<Task> _tasks = [
    const Task(
      id: 1,
      title: 'Leer documentación',
      description: 'Revisar ListView.builder',
      priority: 'Alta',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 2,
      title: 'Diseñar la pantalla',
      description: 'Definir la tarjeta de tarea',
      priority: 'Media',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 3,
      title: 'Preparar evidencia',
      description: 'Tomar captura del avance',
      priority: 'Baja',
      isCompleted: true,
      userId: 1,
    ),
    const Task(
      id: 4,
      title: 'Organizar el backlog',
      description: 'Priorizar pendientes',
      priority: 'Alta',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 5,
      title: 'Revisar código',
      description: 'Ejecutar flutter analyze',
      priority: 'Media',
      isCompleted: false,
      userId: 1,
    ),
  ];

  @override
  List<Task> getTasks() => List.unmodifiable(_tasks);

  @override
  void save(Task task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) return;
    _tasks[index] = task;
  }
}
