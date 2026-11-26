# taskflow

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Alcance de TaskFlow

Problema: necesito organizar actividades académicas y saber cuáles faltan.
Usuario objetivo: estudiante que planifica entregas semanales.

### Historias de usuario y criterios de aceptación
1. Como estudiante, quiero listar mis tareas para ver qué debo hacer.
   Criterio: la lista muestra título, prioridad y estado de cada tarea.
2. Como estudiante, quiero abrir una tarea para leer su descripción.
   Criterio: al tocar una tarjeta aparece el detalle de la tarea elegida.
3. Como estudiante, quiero crear una tarea para registrar un pendiente.
   Criterio: el formulario guarda una tarea válida y la lista la muestra.
4. Como estudiante, quiero editar una tarea para corregir sus datos.
   Criterio: los cambios guardados aparecen en lista y detalle.
5. Como estudiante, quiero eliminar una tarea terminada para limpiar la lista.
   Criterio: después de confirmar, la tarea desaparece de la lista.

### Modelo de datos
Task: id (entero único), title (texto), description (texto),
priority (Alta, Media o Baja), isCompleted (verdadero/falso),
userId (entero que identifica al usuario de prueba).

### Pantallas previstas
Lista: tarjetas de tareas y acción para crear.
Detalle: información completa y futuras acciones de editar o eliminar.
Formulario: campos de título, descripción y prioridad.

### Requisitos no funcionales
La navegación debe tener textos comprensibles.
Un id inexistente debe mostrar un mensaje en vez de cerrar la app.

### Contrato de API que necesitaremos
GET /tasks        listar tareas
GET /tasks/:id    consultar detalle
POST /tasks       crear tarea
PATCH /tasks/:id  actualizar tarea
DELETE /tasks/:id eliminar tarea

La API concreta se elegirá después. Estas rutas son requisitos, no
direcciones de un servidor ya conectado.

## API de tareas

* **URL exacta:** `https://jsonplaceholder.typicode.com/todos`
* **Parámetro de consulta (`userId`):** `6` (valor elegido dentro de los usuarios válidos `1`–`10` de la API para obtener sus 20 tareas asociadas).
* **Campos que llegan desde la API:** `id` (entero), `title` (texto), `completed` (booleano) y `userId` (entero).
* **Valores completados por defecto en TaskFlow:** Como la API externa no provee descripción ni prioridad, `Task.fromJson` asigna `'Sin descripción (API)'` a `description` y `'Sin prioridad (API)'` a `priority`, mapeando el campo remoto `completed` hacia `isCompleted`.
* **Persistencia actual:** La lectura de tareas se realiza desde el servidor remoto mediante Dio, mientras que marcar o desmarcar una tarea como completada aún opera únicamente en la memoria local de la aplicación.

## Estados de la interfaz (Carga, Éxito, Vacío y Error)

La pantalla `TaskListScreen` observa los cambios de `TasksViewModel` mediante `context.watch<TasksViewModel>()` y dispara la recarga de datos con `context.read<TasksViewModel>().loadTasks()`. Así se provocó y verificó cada estado:

* **Carga (`isLoading`):** Se observa al abrir la aplicación por primera vez o al pulsar el botón de actualizar/reintentar mientras se resuelve la petición HTTP. Muestra un `CircularProgressIndicator` acompañado del mensaje *"Sincronizando tus tareas desde el servidor..."*.
* **Éxito (Lista remota):** Con conexión a internet activa y `userId = 6` en `TaskApiService`, el servidor responde `HTTP 200` y se renderiza la lista interactiva con las 20 tareas del usuario, permitiendo entrar al detalle de cada una y volver conservando título e ID.
* **Vacío (`isEmpty`):** Se provocó cambiando temporalmente la constante `userId` a `9999` en `TaskApiService`. El servidor devuelve `HTTP 200` con una lista vacía `[]`, lo que activa la vista con el mensaje *"Todavía no tienes tareas asignadas en este perfil."* y el botón **Actualizar**.
* **Error y Reintento (`errorMessage`):** Se provocó activando el **Modo avión** (desactivando Wi-Fi y datos móviles) en el emulador Android y pulsando el ícono de **Actualizar** en la barra superior. Al fallar la petición en Dio, aparece el mensaje de error junto con el botón **Reintentar**; al reactivar internet y pulsar **Reintentar**, la lista vuelve a cargarse sin necesidad de reiniciar TaskFlow.

## Formulario de nueva tarea y validación

Se incorporó la ruta `/new` en `GoRouter` junto con la pantalla `TaskFormScreen`, accesible desde el `FloatingActionButton.extended` (**Nueva tarea**) en `TaskListScreen`:

* **Campos y controladores:** Utiliza un `Form` asociado a un `GlobalKey<FormState>` y controladores `TextEditingController` para título y descripción (liberados correctamente en `dispose()`), además de un selector `DropdownButtonFormField` para la prioridad (`Alta`, `Media`, `Baja`).
* **Validaciones personalizadas:** Exige que el título no esté vacío y tenga al menos 4 caracteres, y que la descripción contenga texto antes de permitir el envío.
* **Fecha límite opcional (`showDatePicker`):** Permite seleccionar o quitar una fecha límite sin bloquear el guardado cuando se deja sin definir.
* **Retorno del borrador:** Al validar correctamente, `TaskFormScreen` devuelve una instancia de `TaskDraft` mediante `context.pop(draft)` y `TaskListScreen` confirma la recepción mostrando un `SnackBar` con el título, prioridad y fecha elegida (sin persistir aún en la lista remota).