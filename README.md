

# 🚀 LATAM Airlines DevSecOps/SRE Challenge

## ✨ Descripción del Proyecto
Este proyecto implementa un sistema en la nube para ingestar, almacenar y exponer datos a través de una API HTTP para que puedan ser consumidos por terceros, utilizando infraestructura como código (IaC) con Terraform y flujos de CI/CD con GitHub Actions. Además, se incorporaron pruebas de integración, carga, monitoreo y propuestas de alertas para garantizar la resiliencia y escalabilidad del sistema.

---

## 🏗️ Parte 1: Infraestructura e IaC

### **1. Identificar la infraestructura necesaria para ingestar, almacenar y exponer datos**

#### **1.1 Ingesta, almacenamiento y exposición de datos**

##### **1.1.a Utilizar el esquema Pub/Sub para ingesta de datos**
El sistema implementa un esquema de mensajería asíncrona utilizando **Google Cloud Pub/Sub** para garantizar la ingesta eficiente de datos. La arquitectura incluye:

- **Tópico:** `datos-topic`
  - Este tópico recibe los mensajes publicados por el sistema o usuarios externos.
  - Ejemplo de mensaje publicado:
    ```json
    {
      "id": "123",
      "contenido": "Este es un mensaje de prueba",
      "timestamp": "2025-01-14T10:00:00Z"
    }
    ```

- **Suscripción:** `datos-subscription`
  - Procesa los mensajes del tópico y envía los datos para su almacenamiento en BigQuery.

**Ventajas del esquema Pub/Sub:**
- Desacopla la producción y el consumo de datos, lo que facilita la escalabilidad.
- Proporciona resiliencia ante fallos temporales.
- Admite altos volúmenes de datos de manera eficiente.

##### **1.1.b Base de datos para el almacenamiento enfocado en analítica de datos**
Se utiliza **Google BigQuery** como base de datos principal para almacenar los datos. 

- **Dataset:** `latam_dataset`
- **Tabla:** `datos`
  - Esquema definido:
    ```json
    [
      {
        "name": "id",
        "type": "STRING",
        "mode": "REQUIRED",
        "description": "Identificador único del dato"
      },
      {
        "name": "contenido",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Contenido del dato"
      },
      {
        "name": "timestamp",
        "type": "TIMESTAMP",
        "mode": "REQUIRED",
        "description": "Marca de tiempo del registro"
      }
    ]
    ```

**Beneficios de BigQuery:**
- Es ideal para tareas analíticas debido a su alta velocidad de consulta.
- Escalabilidad automática para grandes volúmenes de datos.
- Fácil integración con otros servicios de GCP.

##### **1.1.c Endpoint HTTP para servir parte de los datos almacenados**
Se implementó una API utilizando **FastAPI** desplegada en **Google Cloud Run**. Esta API expone los datos almacenados en BigQuery y ofrece dos endpoints principales:

- **Endpoint `/health`:** 
  - Devuelve el estado del sistema.
  - Ejemplo de respuesta:
    ```json
    {
      "status": "ok"
    }
    ```

- **Endpoint `/datos`:**
  - Devuelve los últimos 10 registros almacenados en BigQuery.
  - Ejemplo de respuesta:
    ```json
    {
      "datos": [
        {
          "id": "789",
          "contenido": "Prueba automática",
          "timestamp": "2024-01-14T14:00:00+00:00"
        }
      ]
    }
    ```

---

#### **1.2 Deployar infraestructura mediante Terraform**

Se utilizó **Terraform** para automatizar la creación y gestión de la infraestructura en Google Cloud Platform. Los recursos desplegados incluyen:

- **Google Cloud Pub/Sub:**
  - Tópico: `datos-topic`
  - Suscripción: `datos-subscription`

- **Google BigQuery:**
  - Dataset: `latam_dataset`
  - Tabla: `datos`

- **Google Cloud Run:**
  - API desplegada para exposición de datos.

---
## 🔄 Parte 2: Aplicaciones y flujo CI/CD

### **2.1 API HTTP**

La API HTTP fue desarrollada utilizando **FastAPI** para garantizar un alto rendimiento y facilidad de implementación. Los endpoints principales permiten la exposición de datos almacenados en la base de datos.

#### **Endpoints implementados:**
- **GET `/health`:** 
  - Verifica la salud de la API y confirma que está operativa.
  - **Respuesta de ejemplo:**
    ```json
    {
      "status": "ok"
    }
    ```

- **GET `/datos`:**
  - Recupera los últimos registros almacenados en **Google BigQuery**.
  - **Respuesta de ejemplo:**
    ```json
    {
      "datos": [
        {
          "id": "789",
          "contenido": "Prueba automática",
          "timestamp": "2024-01-14T14:00:00+00:00"
        }
      ]
    }
    ```

**Lógica implementada:**
- Conexión directa con **Google BigQuery** utilizando su cliente oficial de Python.
- Queries optimizadas para limitar los resultados y garantizar baja latencia.

---

### **2.2 Deployar API HTTP mediante CI/CD**

El despliegue de la API HTTP se realiza utilizando un flujo de **CI/CD con GitHub Actions**. Este pipeline automatiza los pasos de construcción, prueba y despliegue en **Google Cloud Run**.

#### **2.2.1 Flujo del pipeline CI/CD:**
1. **Build Docker Image:**
   - Construcción de la imagen Docker de la API.
   - Push de la imagen a **Google Container Registry (GCR)**.

2. **Deploy con Terraform:**
   - Terraform aplica los cambios para actualizar la infraestructura, incluyendo el despliegue de la API en **Google Cloud Run**.

3. **Pruebas Automáticas:**
   - Pruebas de integración y carga para validar los endpoints `/health` y `/datos`.

##### **Archivo GitHub Actions (`.github/workflows/deploy.yml`):**


### 📦 Evidencias
- Pipeline exitoso: Logs de GitHub Actions.
https://github.com/fernachbauer/latam-challenge/actions/runs/12771103343

---
### **2.3 (Opcional) Ingesta de datos desde Pub/Sub**

En esta etapa opcional, se implementó una lógica para procesar los mensajes recibidos en **Google Cloud Pub/Sub** y almacenarlos en la base de datos **Google BigQuery**.

#### **Objetivo:**
- Configurar una suscripción a **Pub/Sub** que permita:
  1. Recibir mensajes publicados en el tópico `datos-topic`.
  2. Procesar y validar los datos.
  3. Almacenar los datos recibidos en la tabla `datos` del dataset `latam_dataset` en **BigQuery**.


#### **Flujo del procesamiento:**

1. **Publicación de datos:**
   - Los datos son enviados al tópico `datos-topic` mediante el cliente de **Pub/Sub**.

2. **Procesamiento de mensajes:**
   - Se configura la suscripción `datos-subscription` para recibir los mensajes del tópico.
   - Los mensajes son procesados a través de un **callback** que:
     - Decodifica y valida los datos.
     - Inserta los registros en la tabla de **BigQuery**.

3. **Inserción en BigQuery:**
   - Los datos se insertan en la tabla `datos`, aprovechando las capacidades de la API de BigQuery.

#### Ventajas de esta implementación:
- **Escalabilidad:** Pub/Sub maneja un alto volumen de mensajes.
- **Flexibilidad:** Los datos malformados pueden ser gestionados en el callback.
- **Integración serverless:** La combinación de Pub/Sub y BigQuery simplifica la operación.

#### **Evidencias:**
Mensajes enviados a Pub/Sub:

gcloud pubsub topics publish datos-topic \
  --message '{"id":"123","contenido":"Mensaje de prueba","timestamp":"2025-01-14T12:00:00Z"}'

messageIds:
- '13531497031954997'
---
### **2.4 Diagrama de Arquitectura:**
- https://drive.google.com/file/d/1XTSk-mBAVAPTKsSG6DKX_VgDACknp_h8/view?usp=sharing

#### Infraestructura Propuesta

1. **Ingesta de Datos (Google Cloud Pub/Sub)**

Componentes:
- Tópico (datos-topic): Recibe los datos enviados por los productores.
- Suscripción (datos-subscription): Entrega los mensajes a los consumidores.

Razón: Desacopla productores y consumidores, garantiza entrega de mensajes y escala automáticamente.

2. **Almacenamiento de Datos (Google BigQuery)**

Componentes:
- Dataset (latam_dataset): Contiene la tabla datos.
- Tabla (datos): Almacena los datos con un esquema analítico optimizado.

Razón: BigQuery es ideal para consultas rápidas y escalables en grandes volúmenes de datos.

3. **Exposición de Datos (FastAPI en Google Cloud Run)**

Componentes:
- FastAPI: API con endpoints /health y /datos.
- Cloud Run: Despliega la API como un contenedor serverless.

Razón: Cloud Run escala automáticamente según la demanda, optimizando costos y garantizando disponibilidad.

4. **CI/CD con GitHub Actions**

Pipeline:
- Construcción y despliegue de contenedores Docker.
- Infraestructura gestionada con Terraform.
- Pruebas de integración y carga automáticas.

Razón: Automatización completa para garantizar calidad y despliegues consistentes.

**Resumen del Proceso**
Publicación de Datos: Los datos ingresan a través de Pub/Sub.
Procesamiento: Se validan y almacenan en BigQuery.
Consumo: Los datos se exponen mediante una API HTTP desplegada en Cloud Run.
Automatización: CI/CD gestiona el flujo completo desde código hasta producción.

---

## 🧪 **Parte 3: Pruebas de Integración y Puntos Críticos de Calidad**

### **3.1 Implementar en el flujo CI/CD un test de integración que verifique que la API efectivamente está exponiendo los datos de la base de datos. Argumentación.**

- **Descripción**: Se incluyó un test de integración que valida si el endpoint `/datos` retorna datos almacenados en BigQuery.
- **Objetivo**: Garantizar que la API HTTP funcione correctamente y exponga los datos como se espera.
- **Implementación**: Los tests se ejecutan automáticamente en el pipeline CI/CD, aprovechando GitHub Actions.
- **Código de tests**: /latam-challenge/tests/integration/test_api.py
```python
  def test_health_endpoint():
    response = requests.get(f"{BASE_URL}/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
    
def test_datos_endpoint():
    response = requests.get(f"{BASE_URL}/datos")
    assert response.status_code == 200
    assert "datos" in response.json()
```
- **Justificación:**
Este test asegura que la conexión entre la API y BigQuery esté configurada correctamente.
Además, se verifica la estructura y contenido de la respuesta de la API.

https://github.com/fernachbauer/latam-challenge/actions/runs/12771103343/job/35597552427
Run pytest tests/

============================= test session starts ==============================
platform linux -- Python 3.9.21, pytest-8.3.4, pluggy-1.5.0
rootdir: /home/runner/work/latam-challenge/latam-challenge
plugins: anyio-4.8.0
collected 2 items

tests/integration/test_api.py ..                                         [100%]

============================== 2 passed in 1.09s ===============================
---
### **3.2 Proponer otras pruebas de integración que validen que el sistema está funcionando correctamente y cómo se implementarían**

* **Test de Ingesta de Datos:**

**Descripción:** Validar que los datos publicados en Pub/Sub se almacenen correctamente en BigQuery.

**Implementación propuesta:**
- Simular la publicación de un mensaje en el tópico datos-topic.
- Confirmar que los datos aparezcan en la tabla datos de BigQuery.

* **Test de validación de mensajes:**

**Descripción:** Verificar que los mensajes malformados enviados a Pub/Sub no se almacenen en BigQuery.

Implementación propuesta:
- Enviar un mensaje con formato incorrecto al tópico.
- Asegurar que no aparece en la tabla datos.

* **Test de Endpoint /health con Dependencias Externas:**

**Descripción:** Verificar que el endpoint /health no solo confirma la disponibilidad de la API, sino también la conectividad con servicios externos como BigQuery.

**Código Ejemplo:**
```python
def test_health_with_dependencies():
    response = requests.get(f"{BASE_URL}/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
    
    # Validar conectividad con BigQuery
    try:
        query = "SELECT 1"
        query_job = bigquery_client.query(query)
        assert query_job.result()
    except Exception as e:
        assert False, f"Error de conectividad con BigQuery: {e}"
```
---
### 3.3. ⚠️ Puntos Críticos Identificados y Pruebas de Rendimiento

📉 **Posibles Puntos Críticos:**

1. **Latencia en consultas a BigQuery:**  
   - Bajo cargas elevadas, las consultas a BigQuery presentan tiempos de respuesta variables.  
   - **Pruebas de carga** revelaron que la latencia promedio llegó hasta **~600ms**, superando el umbral óptimo.

2. **Errores de ingesta de datos por formatos inválidos:**  
   - La ausencia de validación previa de los datos provenientes de **Pub/Sub** podría derivar en errores al insertar registros en **BigQuery**.

3. **Sobrecarga de la API bajo alta demanda:**  
   - Las pruebas de carga mostraron que el endpoint `/datos` maneja correctamente múltiples solicitudes **GET**, pero:
     - El sistema registró un **11.98% de fallos** en intentos de inserción (**POST**) por falta de implementación de dicho endpoint.  
     - La latencia aumentó progresivamente, alcanzando picos de hasta **6 segundos** bajo carga continua.  
     - La **saturación** de recursos limitó la capacidad de respuesta eficiente.

📈 **Pruebas de Carga Implementadas:**

Se utilizó **Locust** para evaluar el rendimiento del sistema:

https://github.com/fernachbauer/latam-challenge/actions/runs/12771103343/job/35597552427

- **Usuarios concurrentes:** 50  
- **Tasa de incremento:** 10 usuarios/segundo  
- **Duración:** 2 minutos  

📄 **Resultados clave:**

- ✅ **GET /datos:** Respondió exitosamente con una latencia promedio aceptable de **400ms**.  
- ❌ **POST /datos:** El 100% de los intentos fallaron con error **405** (**Method Not Allowed**), evidenciando la **ausencia de un endpoint de ingesta directa**.  
- 📉 **Latencia creciente:** Se detectó un crecimiento sostenido en los tiempos de respuesta, alcanzando **hasta 6 segundos** en momentos críticos.

🔍 **Conclusiones:**

- La API soporta cargas moderadas para **lectura**, pero **no escala adecuadamente** bajo alta demanda sostenida.  
- La falta de un endpoint para inserción directa limita el flujo de ingesta eficiente.  
- La latencia creciente podría afectar la experiencia del usuario final y generar **timeouts** en sistemas integrados.

💡 **Acciones Correctivas:**

1. **Optimizar consultas a BigQuery:**  
   - Implementar **particiones** y **clustering** para mejorar el tiempo de respuesta.  

2. **Implementar validación de datos en la ingesta:**  
   - Prevenir fallos de inserción mediante validaciones estrictas antes de enviar datos a BigQuery.

3. **Incorporar balanceo de carga y autoescalado:**  
   - Desplegar instancias adicionales de la API en **Cloud Run** bajo demanda.  
   - Configurar balanceo de carga para distribuir el tráfico eficientemente.  

4. **Agregar el endpoint POST /datos:**  
   - Permitir la ingesta directa de datos y evitar sobrecargar el flujo Pub/Sub.
---

## **3.4 Proponer cómo robustecer técnicamente el sistema para compensar o solucionar dichos puntos críticos**

### **Optimización de Consultas en BigQuery:**

- Usar particiones y clustering para mejorar el rendimiento de las consultas.
- Limitar el número de registros retornados.

### **Validación de Mensajes en Pub/Sub:**

- Implementar lógica de validación en el suscriptor antes de insertar datos en BigQuery.
- Registrar errores en un sistema de monitoreo para su análisis.

### **Autoescalado y Balanceo de Carga:**

- Configurar Cloud Run para escalar automáticamente con base en las métricas de latencia o CPU.
- Utilizar un balanceador de carga para distribuir el tráfico de manera eficiente.

### **Monitoreo y Alertas:**

- Usar Google Cloud Monitoring para rastrear métricas clave como:
    * Latencia en BigQuery.
    * Errores en Pub/Sub.
    * Tiempo de respuesta de la API.
- Configurar alertas basadas en límites críticos (p. ej., latencia > 1s).

---
## 📊 **Parte 4: Métricas y Monitoreo**

### **4.1 Proponer 3 métricas críticas para entender la salud y rendimiento del sistema end-to-end**

1. **🚀 Tasa de Ingesta de Mensajes en Pub/Sub (Messages Published Rate)**  
   - **Descripción:** Número de mensajes publicados por segundo/minuto en el tópico `datos-topic`.  
   - **Objetivo:** Detectar cuellos de botella en la ingesta de datos.  

2. **⏱️ Latencia de Respuesta de la API (API Response Latency)**  
   - **Descripción:** Tiempo promedio de respuesta del endpoint `/datos` y `/health`.  
   - **Objetivo:** Identificar degradación en el rendimiento de la API bajo diferentes cargas.  

3. **❌ Tasa de Errores de Ingesta (Error Rate in Data Ingestion)**  
   - **Descripción:** Porcentaje de mensajes fallidos al ser insertados desde Pub/Sub a BigQuery.  
   - **Objetivo:** Detectar problemas en el procesamiento de datos y prevenir pérdida de información.  

---

### **4.2 Proponer una herramienta de visualización y describe textualmente qué métricas mostraría**

**🔍 Herramienta Propuesta:** *Google Cloud Monitoring (Stackdriver)*

**📊 Métricas a visualizar:**

- **Tasa de Ingesta de Mensajes (Pub/Sub):** Gráfica de líneas que muestra la cantidad de mensajes procesados por segundo.  
- **Latencia de Respuesta de la API:** Panel con tiempos de respuesta promedio, máximo y percentiles.  
- **Errores de BigQuery:** Conteo de errores de inserción de datos, diferenciando entre errores transitorios y críticos.  
- **Uso de Recursos (CPU/RAM):** Estado de utilización de recursos de Cloud Run.  

**📈 ¿Cómo ayuda esta información?**  
- **Rendimiento:** Detectar cuellos de botella y optimizar recursos.  
- **Estabilidad:** Identificar picos de latencia y prevenir fallos en la API.  
- **Disponibilidad:** Asegurar la ingesta continua de datos y reacción ante errores críticos.  

---

## **4.3 Implementación de la herramienta de monitoreo en la nube**

**🔧 Pasos de Implementación:**

1. **Activar Cloud Monitoring:**  
   - Configurar Google Cloud Monitoring para recolectar métricas de Pub/Sub, Cloud Run y BigQuery.  

2. **Configurar Exportación de Logs:**  
   - Exportar logs de errores y métricas de Pub/Sub a Cloud Monitoring.  

3. **Crear Dashboards Personalizados:**  
   - Diseñar paneles interactivos con gráficos de líneas, indicadores y tablas.  

4. **Configurar Alertas Automáticas:**  
   - Definir umbrales para alertas críticas (e.g., latencia > 1s, error rate > 5%).  

---

## **4.4 Escalamiento de la solución a 50 sistemas similares**

**🔄 Cambios en la Visualización:**

- **Segmentación por Proyecto/Sistema:** Agrupar métricas por cada instancia del sistema.  
- **Dashboard Global:** Vista consolidada para todas las instancias, destacando los sistemas críticos.  
- **Métricas Agregadas:**  
  - Tasa de ingesta global vs. individual.  
  - Latencia promedio global.  
  - Comparativa de errores entre sistemas.  

**🔓 Nuevas Métricas Desbloqueadas:**  
- **Balanceo de carga entre sistemas.**  
- **Uso de red entre regiones.**  
- **Distribución geográfica de usuarios y tráfico.**  

---

## **4.5 Dificultades o limitaciones en observabilidad por problemas de escalabilidad**

**⚠️ Riesgos Potenciales:**

1. **Sobrecarga de Monitoreo:**  
   - Aumento en costos por almacenamiento de logs y métricas.  
   - Saturación de dashboards con exceso de datos.  

2. **Falsos Positivos en Alertas:**  
   - Umbrales mal configurados pueden generar alertas innecesarias.  

3. **Fragmentación de Información:**  
   - Dificultad para correlacionar métricas si no se estandariza la recolección de datos.  

**🛠️ Propuestas de Mitigación:**  
- **Uso de métricas agregadas:** Consolidar datos para obtener insights globales.  
- **Optimizar reglas de alertas:** Definir umbrales dinámicos ajustados al contexto.  
- **Automatizar escalamiento:** Implementar autoescalado basado en métricas críticas.



---

# 🎉 **¡Gracias por la Oportunidad!** 🙌

Quiero expresar mi más sincero agradecimiento por la oportunidad de participar en el **LATAM Airlines DevSecOps/SRE Challenge**. 🌎✈️

Muchas gracias por recibir mi desafío, en el van muchas horas de esfuerzo y motivación por la oportunidad de formar parte del equipo.

Este proyecto ha sido una experiencia increíble, en la que he invertido muchas horas llenas de **motivación**, **aprendizaje** e **ilusión**. Cada línea de código, cada despliegue y cada prueba fueron pensados con el compromiso de entregar una solución robusta ,a la altura del desafío y la compañia. 💻 ✈️✈️✈️✈️✈️✈️

¡Estoy emocionado por todo lo aprendido y por seguir creciendo en el mundo de la tecnología! 🌐

---

## 🔧✨✈️ **¡Nos vemos en las nubes!** ☁️
           |
                       --====|====--
                             |  

                         .-"""""-. 
                       .'_________'. 
                      /_/_|__|__|_\_\
                     ;'-._       _.-';
,--------------------|    `-. .-'    |--------------------,
 ``""--..__    ___   ;       '       ;   ___    __..--""``
  jgs      `"-// \\.._\             /_..// \\-"`
              \\_//    '._       _.'    \\_//
               `"`        ``---``        `"`

📂 Repositorio
🔗 https://github.com/fernachbauer/latam-challenge

📧 Contacto
Nombre: Fernando Nachbauer R
Correo: fernachbauer@gmail.com