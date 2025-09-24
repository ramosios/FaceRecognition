## Descripción de la solución

Esta es una  aplicación para iOS desarrollada con SwiftUI que permite a los usuarios seleccionar dos imágenes de su galería de fotos y calcular la similitud entre los rostros detectados en ellas. La aplicación utiliza el `FaceSDK` de Regula para realizar el análisis y la comparación de rostros.

La interfaz de usuario consta de dos selectores de imágenes y dos botones: uno para iniciar el cálculo de similitud y otro para reiniciar la selección. Mientras el cálculo está en proceso, se muestra un indicador de carga. El resultado, ya sea el puntaje de similitud o un error, se presenta en una alerta.

## Patrones utilizados

-   **MVVM (Model-View-ViewModel):** La arquitectura de la aplicación se basa en el patrón MVVM.

## Decisiones técnicas destacadas

1.  **Encapsulación del SDK:** Toda la lógica relacionada con el `FaceSDK` (inicialización, comparación de rostros y desinicialización) está centralizada en `FaceSDKManager`. Esto facilita el mantenimiento y la sustitución del SDK en el futuro, ya que cualquier cambio solo afectaría a este archivo.

2.  **Inicialización y Desinicialización Automática:** El `FaceSDK` se inicializa justo antes de que se llame a la función `matchFaces` y se desinicializa inmediatamente después de que se completa la operación. Esto se gestiona internamente en `FaceSDKManager` para asegurar que el SDK solo esté activo cuando sea estrictamente necesario, optimizando el uso de recursos.

3.  **Gestión de Estado Asíncrono:** El estado de la interfaz de usuario (por ejemplo, `isLoading`) se gestiona en el `FaceRecognitionViewModel` y se publica a la `ContentView` mediante `@Published`. Esto permite que la interfaz de usuario muestre una vista de carga de forma reactiva mientras se realizan operaciones asíncronas en segundo plano.


## Aspectos que se podrían mejorar o extender

-   **Pruebas Unitarias:** El proyecto carece de pruebas. Se podrían añadir pruebas unitarias para el `FaceRecognitionViewModel` y el `FaceSDKManager` (utilizando mocks para el `FaceSDK.service`) para garantizar la fiabilidad y facilitar futuras refactorizaciones.

-   **Mejor manejo de respuesta del SDK:** : Mejorar el manejo de la respuesta del SDK  asignandolo a un modelo para poder representar mas información de la respuestas del SDK al usuario 

