import os
import time
from datetime import datetime
from locust import HttpUser, task, between, events
import firebase_admin
from firebase_admin import firestore, auth
import random
import string
from google.cloud.firestore import SERVER_TIMESTAMP

# ========================================
# 🔧 CONFIGURACIÓN DEL EMULADOR DE FIREBASE
# ========================================
# IMPORTANTE: Estas variables DEBEN configurarse ANTES de inicializar Firebase
os.environ["FIRESTORE_EMULATOR_HOST"] = "localhost:8080"
os.environ["FIREBASE_AUTH_EMULATOR_HOST"] = "localhost:9099"

# Variable global para la app de Firebase
firebase_app = None
db = None


@events.init.add_listener
def on_locust_init(environment, **kwargs):
    """
    Se ejecuta una sola vez cuando Locust inicia.
    Inicializa Firebase Admin SDK apuntando a los emuladores.
    """
    global firebase_app, db

    try:
        # Inicializar Firebase con credenciales dummy para emulador
        firebase_app = firebase_admin.initialize_app(
            options={
                "projectId": "demo-proyecto-flutter",
            }
        )
        db = firestore.client()
        print("✅ Firebase Admin SDK inicializado correctamente con emuladores")
        print(f"   📍 Firestore: {os.environ.get('FIRESTORE_EMULATOR_HOST')}")
        print(f"   📍 Auth: {os.environ.get('FIREBASE_AUTH_EMULATOR_HOST')}")
    except Exception as e:
        print(f"❌ Error al inicializar Firebase: {e}")


# ========================================
# 🧪 CLASE DE USUARIO PARA PRUEBAS DE CARGA
# ========================================
class StudyUpUser(HttpUser):
    """
    Simula un usuario de la aplicación Study-UP.
    Cada usuario crea una cuenta, agrega materias y calificaciones.
    """

    # Tiempo de espera entre tareas (1-3 segundos)
    wait_time = between(1, 3)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.user_id = None
        self.user_email = None
        self.materias_ids = []

    def on_start(self):
        """
        🔐 Se ejecuta cuando el usuario virtual "nace".
        Crea una cuenta nueva en Auth Emulator.
        """
        # Generar credenciales únicas
        random_suffix = "".join(
            random.choices(string.ascii_lowercase + string.digits, k=8)
        )
        self.user_email = f"test_user_{random_suffix}@studyup.test"
        password = "Password123!"

        start_time = time.time()
        try:
            # Crear usuario en Auth Emulator
            user_record = auth.create_user(
                email=self.user_email, password=password, email_verified=True
            )
            self.user_id = user_record.uid

            # Registrar métrica de éxito
            total_time = int((time.time() - start_time) * 1000)
            events.request.fire(
                request_type="AUTH",
                name="Crear Usuario",
                response_time=total_time,
                response_length=0,
                exception=None,
                context={},
            )

            print(f"✅ Usuario creado: {self.user_email} (UID: {self.user_id})")

        except Exception as e:
            # Registrar métrica de fallo
            total_time = int((time.time() - start_time) * 1000)
            events.request.fire(
                request_type="AUTH",
                name="Crear Usuario",
                response_time=total_time,
                response_length=0,
                exception=e,
                context={},
            )
            print(f"❌ Error al crear usuario: {e}")

    @task(3)
    def crear_materia(self):
        """
        Crear una nueva materia en Firestore.
        Peso: 3 (se ejecuta más frecuentemente que agregar calificación).
        """
        if not self.user_id:
            return

        # Generar datos de materia
        materias_ejemplos = [
            "Matemáticas",
            "Física",
            "Química",
            "Biología",
            "Historia",
            "Literatura",
            "Inglés",
            "Programación",
            "Filosofía",
            "Economía",
        ]
        nombre_materia = random.choice(materias_ejemplos)

        materia_data = {
            "nombre_materia": f"{nombre_materia} {random.randint(1, 10)}",
            "fecha": SERVER_TIMESTAMP,
            "descripcion": f"Descripción de {nombre_materia}",
            "creditos": random.randint(2, 6),
            "profesor": f"Prof. {random.choice(['García', 'Martínez', 'López', 'Rodríguez'])}",
            "creado_en": datetime.now().isoformat(),
        }

        if db is None:
            print("⚠️ Error: Firestore client not initialized")
            return

        start_time = time.time()
        try:
            # Escribir en Firestore Emulator
            doc_ref = (
                db.collection("users")
                .document(self.user_id)
                .collection("materias")
                .add(materia_data)
            )
            materia_id = doc_ref[1].id
            self.materias_ids.append(materia_id)

            # Registrar métrica de éxito
            total_time = int((time.time() - start_time) * 1000)
            events.request.fire(
                request_type="FIRESTORE",
                name="Crear Materia",
                response_time=total_time,
                response_length=len(str(materia_data)),
                exception=None,
                context={},
            )

        except Exception as e:
            total_time = int((time.time() - start_time) * 1000)
            events.request.fire(
                request_type="FIRESTORE",
                name="Crear Materia",
                response_time=total_time,
                response_length=0,
                exception=e,
                context={},
            )

    @task(2)
    def agregar_calificacion(self):
        """
        Agregar una calificación a una materia existente.
        Peso: 2 (se ejecuta con menor frecuencia que crear materia).
        """
        if not self.user_id or not self.materias_ids:
            # Si no hay materias, crear una primero
            self.crear_materia()
            return

        if db is None:
            print("⚠️ Error: Firestore client not initialized")
            return

        # Seleccionar una materia aleatoria
        materia_id = random.choice(self.materias_ids)

        calificacion_data = {
            "nota": round(random.uniform(0, 10), 2),
            "tipo": random.choice(["Examen", "Tarea", "Proyecto", "Participación"]),
            "fecha": SERVER_TIMESTAMP,
            "comentario": "Calificación generada en test de carga",
            "peso": random.randint(10, 50),
        }

        start_time = time.time()
        try:
            # Opción 1: Agregar a subcolección de calificaciones
            db.collection("users").document(self.user_id).collection(
                "materias"
            ).document(materia_id).collection("calificaciones").add(calificacion_data)

            # Opción 2 (comentada): Actualizar documento principal con campo de nota
            # db.collection('users').document(self.user_id)\
            #     .collection('materias').document(materia_id)\
            #     .update({"nota_promedio": calificacion_data["nota"]})

            total_time = int((time.time() - start_time) * 1000)
            events.request.fire(
                request_type="FIRESTORE",
                name="Agregar Calificación",
                response_time=total_time,
                response_length=len(str(calificacion_data)),
                exception=None,
                context={},
            )

        except Exception as e:
            total_time = int((time.time() - start_time) * 1000)
            events.request.fire(
                request_type="FIRESTORE",
                name="Agregar Calificación",
                response_time=total_time,
                response_length=0,
                exception=e,
                context={},
            )

    @task(1)
    def listar_materias(self):
        """
        Listar todas las materias del usuario.
        Peso: 1 (se ejecuta ocasionalmente).
        """
        if not self.user_id:
            return

        if db is None:
            print("⚠️ Error: Firestore client not initialized")
            return

        start_time = time.time()
        try:
            # Leer documentos de Firestore
            materias_ref = (
                db.collection("users").document(self.user_id).collection("materias")
            )
            docs = materias_ref.stream()

            count = sum(1 for _ in docs)

            total_time = int((time.time() - start_time) * 1000)
            events.request.fire(
                request_type="FIRESTORE",
                name="Listar Materias",
                response_time=total_time,
                response_length=count * 100,  # Estimación
                exception=None,
                context={},
            )

        except Exception as e:
            total_time = int((time.time() - start_time) * 1000)
            events.request.fire(
                request_type="FIRESTORE",
                name="Listar Materias",
                response_time=total_time,
                response_length=0,
                exception=e,
                context={},
            )
