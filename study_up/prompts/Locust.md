Actúa como un experto en QA Automation, Python y Firebase. Necesito un script completo de `locustfile.py` para realizar pruebas de carga y estrés.

1.  Contexto y Restricción "Coste Cero":

- Estoy probando el backend de una App Flutter.
- IMPORTANTE: El script debe atacar EXCLUSIVAMENTE al Firebase Local Emulator Suite. No debe tocar la nube real.
- Host de Firestore: `localhost:8080`.
- Host de Auth: `localhost:9099`.
- ID del Proyecto: `demo-proyecto-flutter` (o cualquiera genérico).

2.  Requisitos Técnicos del Script:

- Usa la librería `locust` para la carga.
- Usa la librería `firebase_admin` para interactuar con los emuladores.
- Configura las variables de entorno dentro del script (`FIRESTORE_EMULATOR_HOST` y `FIREBASE_AUTH_EMULATOR_HOST`) antes de inicializar la app de Firebase.
- Usa `credentials.AnonymousCredentials()` o credenciales dummy, ya que es el emulador.

3.  Flujo del Usuario (User Journey) - Implementar en la clase `User`:

- On Start (Inicio de sesión): Cada usuario virtual que nace debe crear una cuenta nueva en el Auth Emulator (o generar un UID único y simular que se ha logueado).
- Task A (Crear Materia): El usuario escribe un documento en la colección `users/{uid}/materias`. El documento debe tener campos como `nombre_materia` (string) y `fecha` (timestamp).
- Task B (Agregar Calificación): Inmediatamente después, el usuario agrega una calificación a esa materia. Puede ser actualizando el documento anterior con un campo `nota` o agregando un documento a una subcolección `calificaciones`.

4.  Escenarios de Carga (Load Shapes):

- Necesito que el script sea compatible con dos modos de ejecución (explicar en comentarios cómo ejecutarlos por línea de comandos):
  - Modo A (Constante): 100 usuarios concurrentes estables.
  - Modo B (Spike/Estrés): De 0 a 1000 usuarios en 10 segundos (Ramp-up agresivo).

Salida Esperada:

- Código completo de `locustfile.py`.
- Lista de librerías a instalar (`pip install...`).
- Comandos exactos de terminal para ejecutar el escenario A y el escenario B apuntando a la web UI de Locust.
