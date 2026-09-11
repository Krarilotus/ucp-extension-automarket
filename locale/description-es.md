# Automarket

Esta extensión proporciona un mercado automático.

## Funciones

La interfaz se integra directamente en el juego.

![Automarket](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/ui-automarket-button.png)

Funciona en multijugador si todos los participantes activan la extensión.

La versión 1.1.0 corrige un desbordamiento del paquete de ajustes multijugador y el cálculo de comisiones. Todos deben actualizar juntos. La comisión de cada jugador se sincroniza con **Save & Close**. Configura las mismas comisiones si todos deben pagar el mismo porcentaje. Al cargar una partida de 1.0.0, cada jugador debe confirmar sus ajustes existentes con **Save & Close** antes de que se reanude el comercio automático.

## Solución de problemas y errores conocidos

Hay un problema de estabilidad que puede cerrar el juego al azar después de cargarlo o más tarde. Una opción de Personalizaciones puede evitarlo si esa es la causa: **Desactivar la compilación en tiempo de ejecución de LuaJIT reduce el rendimiento**. Marca la casilla para evitar esa causa de cierre.

![LuaJIT](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/stability-debugging-setting.png)

Si el juego sigue cerrándose, comunícalo.

## Cómo funciona

Un botón añadido al mercado abre un menú con todos los bienes, sus existencias y los ajustes del mercado automático.

Cada semana de juego, el mercado primero vende y después compra. Haz clic en un producto, ajusta los controles y confirma los cambios con el icono de la marca de verificación.

El umbral de compra debe ser siempre inferior al de venta. De lo contrario, podrías gastar todo el oro vendiendo y volviendo a comprar inmediatamente. El código incluye medidas para evitarlo.
