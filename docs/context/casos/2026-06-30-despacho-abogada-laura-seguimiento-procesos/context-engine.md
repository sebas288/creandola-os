# Caso real — Context Engine: Despacho Abogada Laura

> Piloto real/semi-real para validar el Context Engine en un despacho legal, usando solo datos no sensibles y clientes anonimizados.

## 1. Datos del caso

| Campo | Valor |
|---|---|
| Fecha | 2026-06-30 |
| Workspace | Despacho Abogada Laura |
| Cliente / proyecto | Seguimiento de procesos de clientes |
| Responsable Creándola | Creándola / Hermes |
| Fuente principal | Definición del usuario + plantillas Context Engine |
| Tipo de caso | Cliente real / legal / operación |
| Estado | Borrador operativo v1 |

### Objetivo del caso

```txt
Diseñar y validar un sistema manual para que el despacho de la abogada Laura pueda hacer seguimiento claro a los procesos de sus clientes sin perder contexto, documentos, próximas acciones ni estados.
```

### Resultado esperado

```txt
Debe quedar una primera estructura de seguimiento por proceso: cliente anonimizado, etapa, documentos, próxima acción, responsable, fecha límite, decisión tomada y reporte periódico.
```

---

## 2. Principio de privacidad

Este caso representa un cliente real, pero **no debe guardar datos sensibles en el repo**.

Reglas:

```txt
1. No registrar nombres reales de clientes finales.
2. No registrar cédulas, números de proceso, direcciones, deudas, juzgados, expedientes ni datos financieros.
3. Usar identificadores anonimizados: cliente_001, proceso_001, documento_001.
4. Guardar solo estructura operativa y campos necesarios para diseñar el sistema.
5. Los datos reales deben vivir en la herramienta operativa privada que Laura autorice: Sheet, Airtable, Notion, CRM o sistema interno.
```

---

## 3. Fuentes

| ID | Tipo | Título | URL / ubicación | Autor | Fecha | Confiabilidad |
|---|---|---|---|---|---|---|
| src_001 | manual_entry | Caso elegido por usuario: despacho abogada Laura | Conversación Hermes | Usuario / Creándola | 2026-06-30 | alta |
| src_002 | repo_file | Plantilla Context Engine Manual Prototype | docs/templates/context-engine-manual-prototype.md | Creándola | 2026-06-28 | alta |
| src_003 | repo_file | Diagnóstico horizontal | docs/templates/diagnostico-horizontal.md | Creándola | 2026-06-28 | alta |
| src_004 | repo_file | CRM horizontal | docs/templates/crm-horizontal.csv | Creándola | 2026-06-28 | alta |
| src_005 | repo_file | RFC 0002 — Company Ontology v1 | docs/rfcs/0002-company-ontology-v1.md | Creándola | 2026-06-28 | alta |
| src_006 | repo_file | RFC 0003 — Context Engine Data Model | docs/rfcs/0003-context-engine-data-model.md | Creándola | 2026-06-28 | alta |

### Notas de procedencia

```txt
La información específica sobre el despacho es mínima todavía. Este documento establece una estructura inicial con supuestos explícitos que deben validarse con Laura.
```

---

## 4. Entidades

| ID | Tipo | Título | Estado | Resumen | Fuente |
|---|---|---|---|---|---|
| ent_001 | client | Despacho Abogada Laura | active | Despacho legal que necesita seguimiento operativo de procesos de clientes. | src_001 |
| ent_002 | project | Sistema de seguimiento de procesos de clientes | draft | Piloto horizontal/vertical para ordenar casos, documentos, tareas y reportes. | src_001 |
| ent_003 | process | Proceso jurídico de cliente | draft | Unidad central de seguimiento: cada cliente/caso debe tener estado, documentos, próxima acción y responsable. | src_001 |
| ent_004 | decision | Usar datos anonimizados en repo | approved | Evita exposición de datos legales o personales sensibles. | src_001 |
| ent_005 | decision | Validar manualmente antes de software | approved | Primero se prueba con tabla/plantilla y 3-5 procesos anonimizados. | src_002 |
| ent_006 | task | Levantar etapas reales del despacho | next | Preguntar a Laura cuáles son las etapas reales de sus procesos. | src_001 |
| ent_007 | task | Crear tablero de seguimiento v1 | next | Convertir campos mínimos en Sheet/Airtable/Notion antes de software. | src_004 |
| ent_008 | document | Checklist documental por proceso | draft | Lista de documentos requeridos, recibidos y pendientes. | src_003 |
| ent_009 | report | Reporte semanal/mensual de procesos | draft | Vista ejecutiva para saber qué casos avanzan, cuáles están bloqueados y qué sigue. | src_003 |
| ent_010 | client_case | proceso_001 anonimizado | placeholder | Proceso ficticio/anonimizado para probar el esquema. | src_001 |
| ent_011 | client_case | proceso_002 anonimizado | placeholder | Proceso ficticio/anonimizado para probar el esquema. | src_001 |
| ent_012 | client_case | proceso_003 anonimizado | placeholder | Proceso ficticio/anonimizado para probar el esquema. | src_001 |

---

## 5. Relaciones

| ID | Desde | Relación | Hacia | Fuente | Confianza | Notas |
|---|---|---|---|---|---|---|
| rel_001 | ent_002 | belongs_to | ent_001 | src_001 | alta | El sistema pertenece al despacho de Laura. |
| rel_002 | ent_003 | tracked_by | ent_002 | src_001 | media | Cada proceso se rastrea dentro del sistema. |
| rel_003 | ent_010 | instance_of | ent_003 | src_001 | media | Proceso anonimizado de prueba. |
| rel_004 | ent_011 | instance_of | ent_003 | src_001 | media | Proceso anonimizado de prueba. |
| rel_005 | ent_012 | instance_of | ent_003 | src_001 | media | Proceso anonimizado de prueba. |
| rel_006 | ent_008 | supports | ent_003 | src_003 | alta | El checklist documental soporta cada proceso. |
| rel_007 | ent_009 | summarizes | ent_003 | src_003 | alta | El reporte resume estado de procesos. |
| rel_008 | ent_005 | creates | ent_007 | src_002 | alta | Decisión de validar manualmente crea tarea de tablero v1. |
| rel_009 | ent_004 | constrains | ent_002 | src_001 | alta | La privacidad limita qué se guarda en repo. |

### Mapa textual del contexto

```txt
El despacho de Laura necesita seguimiento de procesos de clientes.
El proceso jurídico se convierte en la entidad principal.
Cada proceso debe tener estado, documentos, próxima acción, responsable, fecha límite y fuente.
Los clientes finales se anonimizan.
El primer entregable no es software: es un tablero/manual con 3-5 procesos anonimizados y reporte periódico.
```

---

## 6. Eventos

| ID | Evento | Entidad principal | Actor | Fecha | Fuente | Resumen |
|---|---|---|---|---|---|---|
| evt_001 | case.selected | ent_001 | Usuario / Creándola | 2026-06-30 | src_001 | Se eligió el despacho de Laura como primer caso real. |
| evt_002 | decision.made | ent_004 | Creándola | 2026-06-30 | src_001 | Se decidió usar datos no sensibles y clientes anonimizados. |
| evt_003 | decision.made | ent_005 | Creándola | 2026-06-30 | src_002 | Se decidió validar manualmente antes de software. |
| evt_004 | task.created | ent_006 | Creándola | 2026-06-30 | src_001 | Se debe levantar etapas reales del despacho. |
| evt_005 | task.created | ent_007 | Creándola | 2026-06-30 | src_004 | Se debe crear tablero de seguimiento v1. |

---

## 7. Decisiones

| ID | Decisión | Rationale | Quién decidió | Fuente | Estado | Próxima revisión |
|---|---|---|---|---|---|---|
| dec_001 | Elegir despacho de Laura como primer caso real | Es un caso concreto con dolor claro de seguimiento de procesos. | Usuario / Creándola | src_001 | approved | Después del primer diagnóstico |
| dec_002 | No guardar datos sensibles en repo | Los procesos legales contienen información personal y jurídica sensible. | Creándola | src_001 | approved | Permanente |
| dec_003 | Proceso jurídico como unidad central | El valor del sistema está en saber qué pasa con cada cliente/proceso. | Creándola | src_001 | draft | Validar con Laura |
| dec_004 | Empezar con CRM/manual, no software | Aún no se validan etapas, campos y reportes reales. | Creándola | src_002 | approved | Después de 3-5 procesos |

---

## 8. Estados candidatos del proceso

> Estos estados son una propuesta inicial. Deben validarse con Laura.

```txt
1. Consulta recibida
2. Diagnóstico inicial
3. Documentos solicitados
4. Documentos incompletos
5. Documentos completos
6. En preparación
7. Radicado / presentado
8. En trámite
9. Requerimiento pendiente
10. Audiencia / cita programada
11. Decisión / respuesta recibida
12. Cerrado
13. Pausado
14. Archivado
```

Estados de control:

```txt
Al día
En riesgo
Bloqueado por cliente
Bloqueado por tercero
Bloqueado por despacho
Pendiente de decisión
```

---

## 9. Campos mínimos v1

```txt
proceso_id
cliente_anonimizado
materia / tipo de proceso
estado_actual
estado_control
responsable
fecha_ultima_actualizacion
proxima_accion
fecha_proxima_accion
documentos_pendientes
documentos_recibidos
bloqueo_actual
ultima_decision
fuente_contexto
notas_no_sensibles
```

Campos que NO deben estar en el repo:

```txt
nombre real del cliente
cédula
número de expediente
juzgado
monto de deudas
dirección
correo/teléfono del cliente final
detalles jurídicos sensibles
```

---

## 10. Tareas y próximas acciones

| ID | Tarea | Responsable | Estado | Prioridad | Fecha próxima acción | Fuente | Contexto |
|---|---|---|---|---|---|---|---|
| task_001 | Validar con Laura las etapas reales de sus procesos | Creándola | next | alta | 2026-07-01 | src_001 | No asumir flujo legal final. |
| task_002 | Elegir 3-5 procesos anonimizados para piloto | Laura / Creándola | next | alta | 2026-07-01 | src_001 | Sin datos sensibles. |
| task_003 | Completar CRM horizontal con esos procesos | Creándola | backlog | alta |  | src_004 | Usar campos mínimos v1. |
| task_004 | Crear checklist documental por tipo de proceso | Creándola / Laura | backlog | media |  | src_003 | Empezar con una materia principal. |
| task_005 | Generar primer reporte semanal de procesos | Creándola | backlog | media |  | src_003 | Validar valor mensual. |

---

## 11. Memorias candidatas

| ID | Tipo | Título | Memoria | Fuente | Confianza | Revisar en |
|---|---|---|---|---|---|---|
| mem_001 | client | Despacho Laura | El primer caso real del Context Engine será seguimiento de procesos de clientes para el despacho de la abogada Laura. | src_001 | alta | 2026-08-01 |
| mem_002 | privacy | Legal data | Los casos legales deben modelarse con clientes/procesos anonimizados y sin datos jurídicos sensibles en repo. | src_001 | alta | permanente |
| mem_003 | process | Legal tracking | La unidad central del piloto legal es el proceso jurídico, con estado, documentos, próxima acción y reporte. | src_001 | media | después del diagnóstico |

---

## 12. Context pack del caso

### Pregunta o tarea

```txt
¿Cómo puede el despacho de Laura hacer seguimiento claro a los procesos de sus clientes sin construir software todavía?
```

### Items incluidos

| Tipo | ID | Razón para incluirlo | Prioridad |
|---|---|---|---|
| client | ent_001 | Cliente real del piloto | alta |
| project | ent_002 | Sistema a validar | alta |
| process | ent_003 | Unidad central de seguimiento | alta |
| decision | dec_002 | Restricción de privacidad | alta |
| task | task_001 | Validar etapas reales | alta |
| task | task_002 | Seleccionar procesos anonimizados | alta |
| document | ent_008 | Checklist documental | media |
| report | ent_009 | Reporte periódico | media |

### Respuesta esperada

```txt
Empezar con un tablero manual de procesos anonimizados que registre estado, documentos, próxima acción, responsable, fecha y bloqueo. Validar con 3-5 procesos antes de automatizar.
```

---

## 13. Evaluación inicial

| Pregunta | Sí / No / Parcial | Evidencia |
|---|---|---|
| ¿El caso es real? | Sí | Definición del usuario. |
| ¿Usa datos no sensibles? | Sí | Se anonimiza explícitamente. |
| ¿Encaja con horizontales? | Sí | Seguimiento/CRM, documentación, reportes, WhatsApp. |
| ¿Se puede validar manualmente? | Sí | Con tablero y 3-5 procesos. |
| ¿Debe construirse software ahora? | No | Falta validar flujo real con Laura. |

Resultado:

```txt
Caso listo para diagnóstico con Laura. Siguiente paso: levantar etapas reales y 3-5 procesos anonimizados.
```

---

## 14. Reuse analysis del caso

```txt
Qué ya existía: RFCs 0001-0003, plantillas horizontales, piloto interno.
Qué se reutilizó: Context Engine manual prototype, CRM horizontal, diagnóstico horizontal, reporte mensual.
Qué se creó nuevo: caso real/semi-real para el despacho de la abogada Laura.
Qué docs o plantillas se actualizaron: debe actualizarse docs/progreso-creandola.md.
Qué no debe hacerse todavía: construir software o guardar datos sensibles.
```
