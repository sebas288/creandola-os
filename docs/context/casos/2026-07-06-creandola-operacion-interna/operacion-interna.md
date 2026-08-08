# Operación interna Creándola — Cliente cero

> Sistema mínimo para gestionar Creándola por dentro antes de adaptar el modelo a clientes externos.

## 1. Tesis

Creándola no debe construir piezas aisladas para cada cliente. Primero debe operar su propia empresa con el sistema que quiere vender.

```txt
Gestionar Creándola → validar horizontales → crear playbooks → adaptar a clientes
```

Esto evita que cada cliente produzca una solución distinta y obliga a que las capacidades nazcan desde problemas reales de operación.

## 2. Objetivo del caso

Ordenar la operación comercial y de entrega de Creándola para que cada lead, cliente, proyecto, decisión, tarea, documento y reporte tenga un lugar claro.

## 3. Flujo operativo base

```txt
Lead llega
→ se registra
→ se califica
→ se agenda diagnóstico
→ se define propuesta o descarte
→ se gana / pierde / pausa
→ se crea proyecto
→ se documentan decisiones y tareas
→ se entrega valor
→ se reporta mensualmente
→ se identifican mejoras y automatizaciones candidatas
```

## 4. Horizontales prioritarias para Creándola

| Horizontal | Prioridad | Motivo |
|---|---|---|
| Captación | Media | La landing ya existe, pero debe conectarse mejor con seguimiento interno. |
| Calificación | Alta | Cada oportunidad debe priorizarse antes de consumir tiempo estratégico. |
| CRM / seguimiento | Alta | Ninguna oportunidad, cliente o proyecto debe quedar sin responsable ni próxima acción. |
| Atención / WhatsApp | Alta | WhatsApp (Meta Cloud API) ya tiene app; es el **canal de entrada prioritario** del cliente cero (RFC 0005) y debe alimentar triage CRM. |
| Documentación | Alta | Las decisiones y aprendizajes deben convertirse en activos reutilizables. |
| Procesos internos | Alta | La operación debe ser repetible antes de venderse como sistema. |
| Automatización | Media | Solo automatizar después de validar el flujo manual. |
| Reportes / analítica | Alta | El valor mensual debe evidenciarse en reportes simples. |

## 5. Objetos mínimos del sistema interno

### Lead / oportunidad

| Campo | Uso |
|---|---|
| ID | Identificador interno. |
| Fuente | Web, WhatsApp, referido, cliente actual, contenido, networking. |
| Necesidad principal | Qué quiere ordenar o mejorar. |
| Dolor | Qué pierde hoy por no resolverlo. |
| Urgencia | Baja, media, alta. |
| Encaje | Bajo, medio, alto. |
| Estado | Pipeline comercial. |
| Responsable | Quién responde por la próxima acción. |
| Próxima acción | Siguiente paso concreto. |
| Fecha de próxima acción | Control de seguimiento. |

### Cliente / proyecto

| Campo | Uso |
|---|---|
| Cliente anonimizado o privado | No guardar datos sensibles en el repo. |
| Objetivo del acompañamiento | Resultado esperado. |
| Horizontales involucradas | Capacidades que se están trabajando. |
| Alcance actual | Qué sí incluye. |
| No alcance | Qué no se hará todavía. |
| Estado | Activo, pausado, cerrado, en riesgo. |
| Decisiones abiertas | Lo que falta definir. |
| Documentos activos | Plantillas, propuestas, reportes, SOPs. |

## 6. Ritmo operativo mínimo

| Ritmo | Acción | Resultado esperado |
|---|---|---|
| Diario ligero | Registrar leads, mensajes importantes y tareas nuevas. | No depender de memoria. |
| Semanal | Revisar pipeline, oportunidades vencidas y tareas abiertas. | Próximas acciones claras. |
| Quincenal | Revisar documentación y procesos repetidos. | Plantillas y SOPs candidatos. |
| Mensual | Generar reporte interno de operación. | Evidencia de valor y foco del mes siguiente. |

## 7. Regla para convertir operación interna en producto reutilizable

| Señal | Decisión |
|---|---|
| Se repite 2 o más veces en Creándola | Crear plantilla o checklist. |
| Se repite con 2 o más clientes | Convertir en horizontal formal. |
| El flujo manual funciona 3 ciclos | Evaluar automatización. |
| Produce una métrica mensual útil | Incluir en reporte estándar. |
| Depende de un sector específico | Convertir en adaptación vertical, no en core. |

## 8. No construir todavía

No construir software pesado para esto hasta validar:

1. qué campos realmente se usan,
2. qué estados del pipeline son suficientes,
3. qué reporte mensual demuestra valor,
4. qué información se repite entre Creándola y clientes,
5. qué automatización reduce trabajo real.

## 9. Próximas acciones inmediatas

| ID | Acción | Responsable | Prioridad |
|---|---|---|---|
| ci_task_001 | Cargar oportunidades y clientes actuales en una herramienta privada usando `crm-horizontal.csv` como estructura. | Dirección Creándola | Alta |
| ci_task_002 | Revisar pipeline una vez por semana durante julio 2026. | Dirección Creándola | Alta |
| ci_task_003 | Generar el primer reporte mensual interno al cierre de julio. | Dirección Creándola | Alta |
| ci_task_004 | Identificar qué partes del flujo sirven como plantilla para clientes. | Dirección Creándola / Hermes | Alta |
| ci_task_005 | Definir si el prototipo privado vive en Sheets, Airtable, Notion u otra herramienta antes de construir software. | Dirección Creándola | Media |
