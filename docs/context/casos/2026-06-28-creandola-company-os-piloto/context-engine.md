# Caso piloto — Context Engine Manual Prototype

> Piloto interno para validar si el modelo del Context Engine produce contexto, decisiones, tareas, memoria y reporte antes de construir software.

## 1. Datos del caso

| Campo | Valor |
|---|---|
| Fecha | 2026-06-28 |
| Workspace | Creándola interno |
| Cliente / proyecto | Creándola — Company OS / Context Engine |
| Responsable Creándola | Dirección / estrategia |
| Fuente principal | RFCs y docs del repo |
| Tipo de caso | Interno / operación / producto |
| Estado | Validado parcial |

### Objetivo del caso

```txt
Validar si los RFCs, plantillas y documentos actuales pueden representar el flujo inicial del Context Engine sin construir software todavía.
```

### Resultado esperado

```txt
Debe quedar claro qué se decidió, qué documentos soportan la decisión, qué tareas siguen y qué memoria estratégica debe mantenerse.
```

---

## 2. Fuentes

| ID | Tipo | Título | URL / ubicación | Autor | Fecha | Confiabilidad |
|---|---|---|---|---|---|---|
| src_001 | repo_file | RFC 0001 — Company OS Foundations | docs/rfcs/0001-company-os-foundations.md | Creándola / Hermes | 2026-06-28 | alta |
| src_002 | repo_file | RFC 0002 — Company Ontology v1 | docs/rfcs/0002-company-ontology-v1.md | Creándola / Hermes | 2026-06-28 | alta |
| src_003 | repo_file | RFC 0003 — Context Engine Data Model | docs/rfcs/0003-context-engine-data-model.md | Creándola / Hermes | 2026-06-28 | alta |
| src_004 | repo_file | Plantilla manual Context Engine | docs/templates/context-engine-manual-prototype.md | Creándola / Hermes | 2026-06-28 | alta |
| src_005 | repo_file | Progreso Creándola | docs/progreso-creandola.md | Creándola / Hermes | 2026-06-28 | alta |
| src_006 | repo_file | Horizontales Creándola v1 | docs/horizontales-creandola.md | Creándola / Hermes | 2026-06-28 | alta |
| src_007 | repo_file | MVP Operativo Creándola | docs/mvp-operativo-creandola.md | Creándola / Hermes | 2026-06-28 | alta |

### Notas de procedencia

```txt
Este piloto no usa datos privados de clientes. Usa el propio trabajo estratégico del repo como caso interno para validar el modelo.
```

---

## 3. Entidades

| ID | Tipo | Título | Estado | Resumen | Fuente |
|---|---|---|---|---|---|
| ent_001 | client | Creándola interno | active | Workspace interno para validar Company OS antes de usarlo con clientes. | src_005 |
| ent_002 | project | Company OS / Context Engine Foundations | active | Proyecto de diseño conceptual y operativo del Company OS bajo Creándola. | src_001 |
| ent_003 | meeting | Sesión de definición Company OS | processed | Conversación estratégica donde se definió Context Engine, RFCs y validación manual antes de software. | src_005 |
| ent_004 | decision | Usar Context Engine como núcleo conceptual | approved | El valor es contexto conectado, no solo un knowledge graph ni IA aislada. | src_001 |
| ent_005 | decision | Validar manualmente antes de construir software | approved | Primero se diseñan RFCs, plantillas y pilotos; luego software. | src_001 |
| ent_006 | decision | Usar modelo relacional primero con comportamiento de grafo | approved | RFC 0003 decide no iniciar con graph DB especializada. | src_003 |
| ent_007 | task | Probar plantillas con un caso piloto | done | Crear caso interno para validar el flujo del Context Engine. | src_004 |
| ent_008 | task | Probar con primer cliente real | next | Usar las plantillas con un caso real o semi-real de cliente. | src_005 |
| ent_009 | document | RFCs 0001-0003 | active | Constitución, ontología y modelo de datos conceptual. | src_001 |
| ent_010 | document | Plantillas operativas horizontales | active | Diagnóstico, CRM, reporte mensual y propuesta horizontal. | src_004 |
| ent_011 | report | Reporte piloto interno Context Engine | draft | Reporte de validación interna del modelo. | src_005 |

---

## 4. Propiedades por entidad

| Entity ID | Propiedad | Valor | Tipo | Fuente | Confianza |
|---|---|---|---|---|---|
| ent_001 | workspace_type | internal | enum | src_005 | alta |
| ent_002 | product_vision | Company Intelligence Platform / Context Engine | text | src_001 | alta |
| ent_004 | rationale | Context Engine describe valor de usuario mejor que Knowledge Graph. | text | src_001 | alta |
| ent_006 | rationale | Postgres/Supabase-style relational model is enough for v1 validation. | text | src_003 | alta |
| ent_008 | priority | alta | enum | src_005 | alta |

---

## 5. Relaciones

| ID | Desde | Relación | Hacia | Fuente | Confianza | Notas |
|---|---|---|---|---|---|---|
| rel_001 | ent_002 | belongs_to | ent_001 | src_005 | alta | Proyecto interno de Creándola. |
| rel_002 | ent_003 | relates_to | ent_002 | src_005 | alta | La sesión definió dirección del proyecto. |
| rel_003 | ent_003 | produced_by | ent_004 | src_001 | media | La conversación produjo la decisión Context Engine. |
| rel_004 | ent_003 | produced_by | ent_005 | src_001 | media | La conversación produjo decisión de validar manualmente. |
| rel_005 | ent_006 | supported_by | ent_009 | src_003 | alta | RFC 0003 soporta decisión de data model. |
| rel_006 | ent_005 | creates | ent_007 | src_004 | alta | Validar manualmente creó la tarea del piloto. |
| rel_007 | ent_007 | produces | ent_011 | src_005 | media | El piloto produce reporte interno. |
| rel_008 | ent_010 | supports | ent_008 | src_004 | alta | Plantillas soportan siguiente prueba real. |

### Mapa textual del contexto

```txt
Creándola tiene el proyecto Company OS / Context Engine.
La sesión de definición produjo decisiones sobre Context Engine, validación manual y modelo relacional primero.
Los RFCs soportan esas decisiones.
La decisión de validar manualmente creó la tarea de probar plantillas con un piloto.
El piloto interno produce un reporte y deja como siguiente acción probar con un cliente real.
```

---

## 6. Eventos

| ID | Evento | Entidad principal | Actor | Fecha/hora | Fuente | Resumen |
|---|---|---|---|---|---|---|
| evt_001 | project.created | ent_002 | Creándola / Hermes | 2026-06-28 | src_005 | Se formalizó Company OS / Context Engine como proyecto interno. |
| evt_002 | decision.made | ent_004 | Creándola | 2026-06-28 | src_001 | Se decidió usar Context Engine como núcleo conceptual. |
| evt_003 | decision.made | ent_005 | Creándola | 2026-06-28 | src_001 | Se decidió validar manualmente antes de construir software. |
| evt_004 | decision.made | ent_006 | Creándola | 2026-06-28 | src_003 | Se decidió un modelo relacional primero con comportamiento de grafo. |
| evt_005 | document.created | ent_009 | Hermes | 2026-06-28 | src_001 | Se crearon RFCs 0001-0003. |
| evt_006 | document.created | ent_010 | Hermes | 2026-06-28 | src_004 | Se crearon plantillas operativas y de validación. |
| evt_007 | task.completed | ent_007 | Hermes | 2026-06-28 | src_005 | Se creó este caso piloto interno. |

### Línea de tiempo

```txt
1. Se reposicionó Creándola como acompañamiento estratégico-operativo con tecnología.
2. Se definieron horizontales y MVP operativo.
3. La visión evolucionó a Company OS / Context Engine.
4. Se crearon RFCs 0001-0003.
5. Se crearon plantillas manuales y horizontales.
6. Se valida el modelo con este caso piloto interno.
```

---

## 7. Decisiones

| ID | Decisión | Rationale | Quién decidió | Fuente | Estado | Próxima revisión |
|---|---|---|---|---|---|---|
| dec_001 | No crear marca nueva | Evita dispersar la comunicación y mantiene Creándola como marca pública. | Creándola | src_001 | approved | Al tener tracción real de producto |
| dec_002 | Usar Context Engine | Describe mejor el valor que Knowledge Graph. | Creándola | src_001 | approved | RFC 0004 / evolución de producto |
| dec_003 | Validar manualmente antes de software | Reduce riesgo y evita construir workflows no probados. | Creándola | src_001 | approved | Después de 1-3 casos piloto |
| dec_004 | Relational-first with graph behavior | Suficiente para v1, menos complejo que graph DB especializada. | Creándola | src_003 | approved | Cuando haya consultas de relación reales |

---

## 8. Tareas y próximas acciones

| ID | Tarea | Responsable | Estado | Prioridad | Fecha próxima acción | Fuente | Contexto |
|---|---|---|---|---|---|---|---|
| task_001 | Probar plantillas con caso piloto interno | Hermes | done | alta | 2026-06-28 | src_004 | Este documento. |
| task_002 | Elegir primer caso real o semi-real de cliente | Creándola | next | alta | 2026-06-29 | src_005 | Validar con cliente, no solo internamente. |
| task_003 | Ajustar plantillas según fricción del piloto real | Creándola / Hermes | backlog | media |  | src_005 | Evitar sobreconstruir. |
| task_004 | Definir si usar Sheets/Airtable para prototipo manual | Creándola | backlog | media |  | src_003 | El modelo recomienda validar manualmente. |

---

## 9. Documentos y artefactos

| ID | Tipo | Título | URL / ubicación | Estado | Relación principal |
|---|---|---|---|---|---|
| doc_001 | rfc | RFC 0001 — Foundations | docs/rfcs/0001-company-os-foundations.md | active | supports decisions |
| doc_002 | rfc | RFC 0002 — Ontology | docs/rfcs/0002-company-ontology-v1.md | active | describes ontology |
| doc_003 | rfc | RFC 0003 — Data Model | docs/rfcs/0003-context-engine-data-model.md | active | describes data model |
| doc_004 | template | Context Engine Manual Prototype | docs/templates/context-engine-manual-prototype.md | active | validates model |
| doc_005 | template | Diagnóstico / CRM / Reporte / Propuesta | docs/templates/ | active | supports operating workflow |

---

## 10. Memorias candidatas

| ID | Tipo | Título | Memoria | Fuente | Confianza | Revisar en |
|---|---|---|---|---|---|---|
| mem_001 | strategic | Context Engine core | Company OS debe centrarse en contexto, no en IA ni módulos sueltos. | src_001 | alta | 2026-09-01 |
| mem_002 | decision | No new brand | Creándola sigue siendo la marca pública; Company OS es visión interna hasta validación. | src_001 | alta | 2026-09-01 |
| mem_003 | process | Manual before software | Validar con plantillas y casos reales antes de construir Creándola OS/Company OS como producto. | src_003 | alta | 2026-09-01 |
| mem_004 | product | First wedge | El primer wedge es Clients + Projects + Meetings + Decisions + Tasks + Documents. | src_002 | alta | 2026-09-01 |

---

## 11. Context pack del caso

### Pregunta o tarea

```txt
¿Qué sabemos del proyecto Company OS / Context Engine y qué sigue antes de construir software?
```

### Items incluidos

| Tipo | ID | Razón para incluirlo | Prioridad |
|---|---|---|---|
| entity | ent_001 | Workspace interno | alta |
| entity | ent_002 | Proyecto central | alta |
| decision | ent_004 | Define núcleo conceptual | alta |
| decision | ent_005 | Define estrategia de validación | alta |
| document | ent_009 | RFCs base | alta |
| document | ent_010 | Plantillas operativas | alta |
| task | ent_008 | Próxima acción | alta |
| memory | mem_003 | Regla de no construir antes de validar | alta |

### Respuesta esperada

```txt
El proyecto ya tiene fundamentos, ontología, modelo conceptual y plantillas. El siguiente paso no es software: es probar las plantillas con un cliente real o un caso semi-real y ajustar el modelo.
```

---

## 12. Insights y recomendaciones

| ID | Tipo | Insight / recomendación | Evidencia | Acción sugerida | Confianza |
|---|---|---|---|---|---|
| ins_001 | insight | El modelo ya es suficientemente claro para validación manual. | src_001, src_002, src_003, src_004 | Pasar a caso real/semi-real. | alta |
| ins_002 | insight | Las plantillas convierten estrategia en operación, pero aún no han sido probadas con cliente real. | src_004, src_005 | No construir software todavía. | alta |
| rec_001 | recommendation | Elegir un primer caso piloto real con bajo riesgo y alto contexto. | task_002 | Usar cliente actual o caso interno con datos reales no sensibles. | alta |

---

## 13. Reporte manual del caso

### Resumen ejecutivo

```txt
El piloto interno muestra que el modelo puede representar fuentes, entidades, decisiones, tareas, documentos, memorias y próximas acciones sin requerir software todavía.
```

### Contexto relevante

```txt
Creándola está incubando Company OS como visión interna bajo su marca pública. El núcleo es Context Engine y la validación debe suceder con servicio real antes de producto.
```

### Decisiones tomadas

```txt
1. Mantener Creándola como marca pública.
2. Usar Context Engine como núcleo conceptual.
3. Validar manualmente antes de construir software.
4. Usar modelo relacional primero con comportamiento de grafo.
```

### Tareas abiertas

```txt
1. [Creándola] Elegir primer caso real o semi-real de cliente.
2. [Creándola / Hermes] Completar diagnóstico horizontal del caso.
3. [Creándola / Hermes] Ajustar plantillas según fricción real.
```

### Riesgos o bloqueos

```txt
1. El piloto interno puede verse ordenado pero no revelar fricción real de cliente.
2. Hay riesgo de seguir documentando demasiado sin validar con operación real.
3. Hay riesgo de querer construir software antes de tener 1-3 casos repetidos.
```

### Documentos creados o actualizados

```txt
1. RFCs 0001-0003.
2. Plantilla manual Context Engine.
3. Plantillas horizontales operativas.
4. Este caso piloto interno.
```

### Recomendaciones

```txt
1. Usar el próximo caso real disponible como piloto.
2. Mantener datos sensibles fuera del repo.
3. Medir si el sistema produce reporte mensual útil.
4. Convertir fricción repetida en ajuste de plantilla antes de software.
```

### Qué cambió desde el inicio

```txt
Antes: la visión era conceptual y estaba en RFCs.
Después: existe un caso piloto que muestra cómo registrar contexto, decisiones, tareas, memoria y reporte.
```

---

## 14. Evaluación del prototipo

| Pregunta | Sí / No / Parcial | Evidencia |
|---|---|---|
| ¿El caso quedó más claro que antes? | Sí | El grafo interno queda expresado en entidades/relaciones/eventos. |
| ¿Se identificaron decisiones explícitas? | Sí | dec_001 a dec_004. |
| ¿Se crearon próximas acciones claras? | Sí | task_002 a task_004. |
| ¿Quedó evidencia/fuente de cada decisión importante? | Sí | RFCs 0001-0003. |
| ¿Se creó memoria útil para el futuro? | Sí | mem_001 a mem_004. |
| ¿Se puede generar un reporte mensual con esto? | Parcial | Sí para interno; falta cliente real. |
| ¿El flujo se repetiría en otros clientes? | Parcial | Probable, pero falta validación real. |
| ¿Vale la pena convertir esto en plantilla o software? | Plantilla sí; software todavía no | Necesita más casos. |

### Resultado de validación

```txt
Parcial: el modelo funciona en piloto interno, pero necesita validarse con un caso real o semi-real antes de construir software.
```

### Aprendizajes

```txt
1. El modelo obliga a separar fuentes, decisiones, tareas y memoria.
2. Las decisiones se vuelven mucho más claras cuando son entidades propias.
3. El siguiente paso debe ser un caso real, no más teoría.
```

### Cambios sugeridos al modelo

```txt
Agregar una guía de selección de caso piloto y una versión ligera del formulario para clientes pequeños.
```

---

## 15. Criterio para pasar de manual a software

- [ ] Se repite en más de un cliente/proyecto.
- [x] Ahorra tiempo real.
- [x] Evita pérdida de contexto.
- [x] Mejora seguimiento o calidad del servicio.
- [x] Produce memoria reutilizable.
- [x] Permite generar reportes mensuales.
- [x] Puede conectarse con una horizontal existente.

Resultado:

```txt
No construir software todavía. Falta validar repetición en más de un cliente/proyecto real.
```

---

## 16. Próxima acción después de completar esta plantilla

```txt
2. Crear o actualizar una plantilla horizontal.
5. Ajustar RFC 0002 / RFC 0003 si el primer caso real revela fricción.
```

---

## 17. Reuse analysis del caso

```txt
Qué ya existía: RFCs 0001-0003, plantillas, progreso, horizontales y MVP operativo.
Qué se reutilizó: wedge Client → Project → Meeting → Decision → Task → Document → Report.
Qué se creó nuevo: caso piloto interno con entidades, relaciones, eventos, memorias y reporte.
Qué docs o plantillas se actualizaron: docs/progreso-creandola.md debe registrar este piloto.
Qué debería repetirse: usar fuentes, decisiones, tareas, memorias y context packs.
Qué no debería repetirse: asumir validación completa sin cliente real.
```
