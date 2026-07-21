# Caso interno — Context Engine para Operación Creándola

> Registro manual del Context Engine aplicado a Creándola como cliente cero.

## 1. Datos del caso

| Campo | Valor |
|---|---|
| Fecha | 2026-07-06 |
| Workspace | Creándola interno |
| Cliente / proyecto | Creándola — Operación interna |
| Responsable Creándola | Dirección / estrategia |
| Fuente principal | Repo, progreso del proyecto, decisión estratégica de dogfooding |
| Tipo de caso | Interno / operación / producto |
| Estado | En proceso |

### Objetivo del caso

```txt
Gestionar primero la propia empresa Creándola para que el sistema operativo, las plantillas y los futuros componentes sean reutilizables con clientes.
```

### Resultado esperado

```txt
Debe quedar un flujo interno mínimo para leads, clientes, proyectos, decisiones, tareas, documentos y reportes mensuales.
```

---

## 2. Fuentes

| ID | Tipo | Título | URL / ubicación | Autor | Fecha | Confiabilidad |
|---|---|---|---|---|---|---|
| src_001 | repo_file | Progreso Creándola | docs/progreso-creandola.md | Creándola / Hermes | 2026-07-06 | alta |
| src_002 | repo_file | Horizontales Creándola v1 | docs/horizontales-creandola.md | Creándola / Hermes | 2026-06-28 | alta |
| src_003 | repo_file | MVP Operativo Creándola | docs/mvp-operativo-creandola.md | Creándola / Hermes | 2026-06-28 | alta |
| src_004 | repo_file | RFC 0001 — Company OS Foundations | docs/rfcs/0001-company-os-foundations.md | Creándola / Hermes | 2026-06-28 | alta |
| src_005 | repo_file | RFC 0002 — Company Ontology v1 | docs/rfcs/0002-company-ontology-v1.md | Creándola / Hermes | 2026-06-28 | alta |
| src_006 | repo_file | RFC 0003 — Context Engine Data Model | docs/rfcs/0003-context-engine-data-model.md | Creándola / Hermes | 2026-06-28 | alta |
| src_007 | manual_entry | Decisión de usar Creándola como cliente cero | Conversación 2026-07-06 | Sebastián / Hermes | 2026-07-06 | alta |

---

## 3. Entidades

| ID | Tipo | Título | Estado | Resumen | Fuente |
|---|---|---|---|---|---|
| ent_001 | client | Creándola interno | active | Cliente cero para validar el sistema operativo propio. | src_007 |
| ent_002 | project | Operación interna Creándola | active | Proyecto para ordenar comercial, entrega, documentación y reportes internos. | src_007 |
| ent_003 | decision | Creándola debe ser cliente cero | approved | El sistema debe resolver primero la operación propia antes de adaptarse a terceros. | src_007 |
| ent_004 | process | Lead → diagnóstico → propuesta → proyecto → reporte | draft | Flujo operativo mínimo que debe gestionar Creándola. | src_003 |
| ent_005 | document | Operación interna Creándola | active | Mapa operativo del caso interno. | src_007 |
| ent_006 | document | CRM horizontal interno | draft | Estructura para probar seguimiento sin datos sensibles. | src_003 |
| ent_007 | report | Reporte mensual interno | draft | Evidencia mensual de avance y valor de la propia operación. | src_003 |
| ent_008 | task | Cargar operación real en herramienta privada | next | Pasar de estructura documental a uso real sin exponer datos sensibles. | src_007 |
| ent_009 | feature | WhatsApp intake classification | built_needs_validation | Canal técnico que puede alimentar seguimiento interno. | src_001 |
| ent_010 | template | Plantillas horizontales | active | Diagnóstico, CRM, propuesta y reporte reutilizables. | src_002 |

---

## 4. Relaciones

| ID | Desde | Relación | Hacia | Fuente | Confianza | Notas |
|---|---|---|---|---|---|---|
| rel_001 | ent_002 | belongs_to | ent_001 | src_007 | alta | La operación interna pertenece a Creándola. |
| rel_002 | ent_003 | creates | ent_002 | src_007 | alta | La decisión de dogfooding crea este proyecto. |
| rel_003 | ent_004 | describes | ent_002 | src_003 | alta | El flujo operativo describe cómo se gestionará Creándola. |
| rel_004 | ent_010 | supports | ent_004 | src_002 | alta | Las plantillas horizontales soportan el flujo. |
| rel_005 | ent_006 | implements | ent_004 | src_003 | media | El CRM interno prueba seguimiento. |
| rel_006 | ent_007 | measures | ent_002 | src_003 | media | El reporte interno mide avance mensual. |
| rel_007 | ent_009 | supports | ent_004 | src_001 | media | WhatsApp puede alimentar captación y seguimiento. |
| rel_008 | ent_008 | implements | ent_002 | src_007 | alta | La siguiente acción lleva el caso a operación real. |

### Mapa textual del contexto

```txt
Creándola es el cliente cero.
La decisión de dogfooding crea el proyecto Operación interna Creándola.
Ese proyecto se gestiona con el flujo Lead → diagnóstico → propuesta → proyecto → reporte.
Las plantillas horizontales existentes soportan el flujo.
El CRM interno y el reporte mensual son los primeros instrumentos de validación.
WhatsApp y la landing son fuentes de entrada, no el centro del sistema.
```

---

## 5. Decisiones

| ID | Decisión | Rationale | Quién decidió | Fuente | Estado | Próxima revisión |
|---|---|---|---|---|---|---|
| dec_001 | Creándola será cliente cero | La operación propia debe validar el sistema antes de venderlo o adaptarlo. | Sebastián | src_007 | approved | Después del primer reporte mensual interno |
| dec_002 | No priorizar verticales externas todavía | Primero se debe cerrar el sistema interno reutilizable. | Sebastián / Hermes | src_007 | approved | Cuando Creándola complete un ciclo operativo interno |
| dec_003 | Mantener datos reales fuera del repo | Evita exponer información sensible de clientes y operación. | Creándola | src_001 | approved | Permanente |
| dec_004 | Automatizar solo después de uso manual | Evita construir sobre supuestos no validados. | Creándola | src_003 | approved | Después de 3 ciclos de uso |

---

## 6. Tareas y próximas acciones

| ID | Tarea | Responsable | Estado | Prioridad | Fecha próxima acción | Fuente | Contexto |
|---|---|---|---|---|---|---|---|
| task_001 | Crear caso interno de operación Creándola | Hermes | done | alta | 2026-07-06 | src_007 | Este directorio. |
| task_002 | Cargar oportunidades y clientes actuales en herramienta privada | Dirección Creándola | next | alta | 2026-07-08 | src_007 | Usar estructura de `crm-horizontal.csv`. |
| task_003 | Revisar pipeline interno semanalmente | Dirección Creándola | next | alta | 2026-07-13 | src_003 | Validar estados, campos y próximas acciones. |
| task_004 | Generar reporte mensual interno de julio | Dirección Creándola / Hermes | backlog | alta | 2026-07-31 | src_003 | Medir valor real del sistema. |
| task_005 | Extraer primera versión de playbook reutilizable | Dirección Creándola / Hermes | backlog | media | 2026-08-01 | src_002 | Convertir aprendizajes internos en oferta aplicable a clientes. |

---

## 7. Documentos y artefactos

| ID | Tipo | Título | URL / ubicación | Estado | Relación principal |
|---|---|---|---|---|---|
| doc_001 | guide | Operación interna Creándola | docs/context/casos/2026-07-06-creandola-operacion-interna/operacion-interna.md | active | describes operation |
| doc_002 | diagnostic | Diagnóstico horizontal interno | docs/context/casos/2026-07-06-creandola-operacion-interna/diagnostico-horizontal.md | draft | diagnoses horizontals |
| doc_003 | crm | CRM horizontal interno | docs/context/casos/2026-07-06-creandola-operacion-interna/crm-horizontal.csv | draft | tracks opportunities |
| doc_004 | report | Reporte mensual interno | docs/context/casos/2026-07-06-creandola-operacion-interna/reporte-mensual.md | draft | measures value |
| doc_005 | proposal | Propuesta horizontal interna | docs/context/casos/2026-07-06-creandola-operacion-interna/propuesta-horizontal.md | draft | packages system |

---

## 8. Evaluación inicial

| Pregunta | Respuesta inicial |
|---|---|
| ¿Genera claridad? | Sí, cambia el foco desde verticales externas hacia operación propia. |
| ¿Produce próximas acciones? | Sí, cargar operación real, revisar pipeline y generar reporte mensual. |
| ¿Evita sobreconstruir? | Sí, mantiene software pesado en pausa hasta validar uso manual. |
| ¿Puede reutilizarse con clientes? | Sí, si el ciclo interno demuestra valor y genera plantillas. |

## 9. Reuse analysis

| Elemento | Resultado |
|---|---|
| Qué ya existía | Horizontales, MVP operativo, RFCs, plantillas y caso piloto interno de Context Engine. |
| Qué se reutilizó | Plantillas de diagnóstico, CRM, reporte, propuesta y modelo Context Engine. |
| Qué se creó nuevo | Caso interno de operación Creándola como cliente cero. |
| Qué debe validarse | Uso real con oportunidades, clientes, tareas y reporte mensual interno. |
