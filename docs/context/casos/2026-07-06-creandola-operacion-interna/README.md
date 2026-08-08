# Caso interno — Operación Creándola

> Cliente cero para validar el sistema operativo de Creándola antes de adaptarlo a clientes externos.

## Propósito

Este caso existe para gestionar primero la operación interna de Creándola y convertir lo que funcione en activos reutilizables para otros clientes.

```txt
Creándola usa su propio sistema primero.
Lo que se repite y genera valor se convierte en horizontal.
Lo que depende de un sector se adapta después como vertical.
```

**Prioridad de producto (2026-08-08, RFC 0005):** este caso es la **primera presión de producción** del OS. El canal de entrada prioritario es **WhatsApp (Meta Cloud API)** hacia CRM / seguimiento. Los pilotos externos (p. ej. Laura) no desplazan este dogfooding.

## Archivos

| Archivo | Uso |
|---|---|
| `operacion-interna.md` | Mapa operativo de Creándola como cliente cero. |
| `context-engine.md` | Registro del caso en formato Context Engine. |
| `diagnostico-horizontal.md` | Diagnóstico de horizontales aplicado a Creándola. |
| `crm-horizontal.csv` | Estructura inicial para probar seguimiento interno sin datos sensibles. |
| `reporte-mensual.md` | Primer reporte mensual interno para evidenciar valor. |
| `propuesta-horizontal.md` | Propuesta interna del sistema que luego podrá empaquetarse para clientes. |

## Modelo CRM (borrador → mapear a Phase 1)

No expandir el enum `entity_type` ni crear tablas Message sin OpenSpec. Mientras tanto:

| Objeto de negocio | Uso | Mapeo tentativo |
|---|---|---|
| Contact | Persona que escribe por WhatsApp | Ontología Contact (RFC 0002); en DB Phase 1 usar `client` + `properties` (`phone`, `source`, `stage`) o extensión futura |
| Deal / Opportunity | Pipeline comercial (puede haber varios por contacto) | Lead/oportunidad de `operacion-interna.md`; `properties.stage`, `value`, `project_type` |
| Conversation / Message | Hilo y mensajes | Capas events/sources (RFC 0003) a futuro; payloads crudos **fuera del repo** |

Etapas borrador (confirmar contra el flujo real diario):

```txt
nuevo → calificando → propuesta_enviada → negociacion → cliente_activo → inactivo
```

## Regla de privacidad

Este directorio no debe contener datos privados de clientes reales, contratos, valores sensibles, credenciales, identificaciones, teléfonos, correos privados ni conversaciones completas.

Los datos reales deben vivir en una herramienta privada autorizada. El repo conserva estructura, decisiones, plantillas y aprendizaje reutilizable.

## Criterio de éxito

El caso se considera validado cuando Creándola pueda usar este sistema durante al menos un ciclo real para:

1. registrar oportunidades desde WhatsApp (idempotente),
2. calificar prioridades,
3. dar seguimiento con próxima acción,
4. documentar decisiones y tareas,
5. entregar un reporte mensual interno,
6. extraer una plantilla reutilizable para clientes.
