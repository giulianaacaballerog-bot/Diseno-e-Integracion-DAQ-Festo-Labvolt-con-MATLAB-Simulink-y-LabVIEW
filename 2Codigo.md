# Arquitectura del Sistema y Estructura del Código

Para garantizar la modularidad y el correcto procesamiento de los datos, el proyecto se diseñó bajo una **Arquitectura Orientada a Objetos (OO)** estructurada en 4 capas dinámicas. Esto permite aislar la interfaz gráfica de la complejidad de las librerías de bajo nivel del fabricante.

![Arquitectura del Sistema](arquitectura.jpeg)

### Descripción de las Capas:

1. **Capa de Aplicación (Usuario / GUI / Simulink):** Interfaces gráficas (MATLAB App) y modelos de simulación que interactúan directamente con el operador de forma intuitiva.
2. **Capa de Software (Clases MATLAB):** Núcleo lógico del proyecto que abstrae las funciones del SDK en componentes especializados:
   * **`LV9063`:** Clase principal encargada de la conexión y gestión del hardware.
   * **`AnalogOutput` & `Acquisition`:** Controladores de configuración de señales de entrada (lecturas, triggers, muestreo) y salida (amplitud, frecuencia).
   * **`Processing`:** Módulo matemático que calcula en tiempo real variables críticas como valores RMS, potencias (P, Q, S), armónicos e impedancias.
3. **Capa SDK (.NET):** El puente de comunicación que traduce las órdenes de MATLAB hacia el driver mediante las bibliotecas `LV9063SDK.dll` y `WinusbWrapper.dll`.
4. **Capa Hardware (LV9063):** El módulo físico de Festo Labvolt (entradas analógicas, relés, salidas digitales, encoder y puerto USB).

---

El archivo principal contiene varias funciones:

## GUI_Principal
Es la ventana principal del sistema:
- **Muestra** el estado de conexión.
- **Permite** seleccionar módulos LabVolt:
  - Tiristores (9063)
  - DC (9043)
  - AC (9053)
  - Control (9060)
- **Incluye** botón de configuración de puerto COM (simulado).
- **Permite** abrir interfaces secundarias.

## Configuración de comunicación
`function configurar_com(~,~)`
- Solicita el puerto COM.
- Simula una conexión exitosa.
- Cambia el estado visual a "Conectado".
> *Nota: Esta parte está preparada para ser reemplazada por la comunicación real con la DLL.*

## Apertura de módulos y evidencia del funcionamiento
A continuación se muestran capturas del sistema en ejecución
`function abrir_modulo(~,~)`
Dependiendo del módulo seleccionado, abre una ventana específica:
- GUI_Tiristores()
- GUI_DC()
- GUI_AC()
- GUI_Control()
- 
![Panel Principal](principal.png)

*(Panel principal)*

## Módulos implementados

### Módulo DC
Permite ajustar voltaje mediante campo de texto o slider y simular salida DC.

![Módulo DC](dc.png)

*(Módulo DC)*

### Módulo AC
Permite configurar amplitud y frecuencia para simular señal AC.

![Módulo AC](ac.png)

*(Módulo AC)*

### Módulo de Tiristores
Permite ajustar ángulo de disparo (0° – 180°) y simular comportamiento de fase.

![Módulo Tiristores](tiristor.png)

*(Módulo Tiristores)*

### Módulo de Control (9060)
Permite visualizar el modelo e iniciar el sistema de control (simulado).

![Módulo Control](control.png)

*(Módulo de control)* 

## Archivos utilizados
Todos los archivos necesarios ya se encuentran cargados en el repositorio:
- Código MATLAB de la interfaz.
- Funciones auxiliares.
- Base para integración con DLL.
