# Diagnóstico Horizontal — Piloto interno Company OS

## 1. Datos generales

| Campo | Valor |
|---|---|
| Fecha | 2026-06-28 |
| Cliente / negocio | Creándola interno |
| Contacto principal | Dirección Creándola |
| WhatsApp / canal principal | Interno / Hermes / repo docs |
| Ciudad / país | Medellín, Colombia |
| Tipo de negocio | Servicios de diseño, desarrollo, acompañamiento e IA |
| Responsable Creándola | Dirección / estrategia |
| Fuente del lead | Interno |
| Estado | Diagnosticado |

### Objetivo del diagnóstico

```txt
Validar si la visión Company OS / Context Engine ya puede pasar de RFCs a operación manual con plantillas, sin construir software todavía.
```

### Resultado esperado en 30-60 días

```txt
Usar el sistema con al menos un caso real o semi-real de cliente y obtener un reporte mensual útil con decisiones, tareas, documentos y memoria.
```

---

## 2. Contexto del negocio

Creándola vende diseño, desarrollo y acompañamiento estratégico-operativo con tecnología e IA. El proyecto está evolucionando desde una landing/posicionamiento hacia una arquitectura de Company OS interna basada en Context Engine.

El riesgo actual no es falta de ideas. El riesgo es construir software antes de validar procesos reales con clientes.

---

## 3. Mapa de horizontales

| Horizontal | Dolor observado | Evidencia | Prioridad |
|---|---|---|---|
| Captación | La landing ya comunica mejor, pero falta probar verticales/casos. | somoscreandola.co + docs | Media |
| Calificación | Se necesita decidir qué casos valen la pena para Company OS. | MVP operativo | Alta |
| Seguimiento / CRM | Falta operar oportunidades/casos con pipeline simple. | crm-horizontal.csv | Alta |
| Atención / WhatsApp | Se debe validar intake antes de automatizar. | horizontales + RFCs | Media |
| Documentación | Ya se produjo documentación fuerte; falta usarla en operación. | RFCs + plantillas | Alta |
| Procesos internos | El proceso de diagnóstico → decisión → tarea → reporte ya está naciendo. | caso piloto | Alta |
| Automatización | No debe activarse todavía. | RFC 0001-0003 | Baja |
| Reportes / analítica | Hace falta probar reporte mensual como evidencia de valor. | reporte template | Alta |

### Horizontal principal a intervenir primero

```txt
Documentación + Seguimiento / CRM + Reportes.
```

### Horizontales secundarias

```txt
Calificación y Procesos internos.
```

---

## 4. Captación

Hallazgo: la landing ya comunica horizontales y estilo Creándola. El siguiente paso no es más captación pública, sino validar si el mensaje se convierte en operación repetible.

### Hallazgos de captación

```txt
La promesa pública ya está alineada: estrategia, operación y tecnología. Falta conectar ese mensaje con un proceso de diagnóstico y reporte real.
```

---

## 5. Calificación

### Score simple

| Criterio | 0 | 1 | 2 | Puntaje |
|---|---|---|---|---:|
| Dolor | Curiosidad | Molestia clara | Problema costoso/urgente | 2 |
| Autoridad | No decide | Influye | Decide o co-decide | 2 |
| Presupuesto | No tiene | Puede conseguir | Tiene rango claro | 1 |
| Timing | Algún día | Este trimestre | Este mes / urgente | 2 |
| Encaje | Fuera de foco | Parcial | Encaja con horizontales | 2 |

Puntaje total:

```txt
9/10 — prioridad alta para validación interna y con primer cliente real.
```

---

## 6. Seguimiento / CRM

Hallazgo: el proyecto ya tiene commits y docs, pero el siguiente seguimiento debe ser operativo: caso real, próximas acciones, reporte y ajuste.

### Pipeline recomendado

```txt
Diagnosticado → Plantillas creadas → Piloto interno → Caso real elegido → Caso real ejecutado → Reporte → Ajuste de modelo
```

---

## 7. Atención / WhatsApp

No se debe automatizar WhatsApp todavía. Primero debe validarse un guion de intake con diagnóstico horizontal.

### Guiones o respuestas candidatas

```txt
Hola, antes de proponerte una solución queremos entender cómo llegan tus clientes, cómo haces seguimiento y dónde se pierde más tiempo o información. Te haremos unas preguntas cortas para mapear el proceso.
```

---

## 8. Documentación

### Documentos candidatos

| Documento / plantilla | Uso | Prioridad |
|---|---|---|
| Context Engine Manual Prototype | Validar contexto antes de software | Alta |
| Diagnóstico horizontal | Diagnosticar cliente/caso | Alta |
| CRM horizontal | Seguir oportunidades | Alta |
| Reporte mensual horizontal | Mostrar valor | Alta |
| Propuesta horizontal | Convertir diagnóstico en oferta | Alta |

---

## 9. Procesos internos

### Proceso actual

```txt
1. Conversación estratégica.
2. RFCs.
3. Plantillas.
4. Piloto interno.
```

### Proceso recomendado v1

```txt
1. Elegir caso real o semi-real.
2. Completar diagnóstico horizontal.
3. Registrar caso en Context Engine manual prototype.
4. Crear CRM row y próximas acciones.
5. Generar reporte mensual.
6. Ajustar plantillas.
7. Solo después considerar software.
```

---

## 10. Automatización

No automatizar todavía.

### Automatizaciones candidatas

| Automatización | Trigger | Acción | Riesgo | Prioridad |
|---|---|---|---|---|
| Diagnóstico → CRM | Diagnóstico completado | Crear fila CRM | Campos incorrectos si el diagnóstico cambia | Media futura |
| Reunión → tareas | Resumen de reunión | Extraer decisiones/tareas | IA sin contexto puede inventar | Media futura |
| Reporte mensual | Cierre de mes | Generar borrador | Reportar sin evidencia | Media futura |

---

## 11. Reportes y valor mensual

### Métricas candidatas

| Métrica | Fuente | Frecuencia | Valor esperado |
|---|---|---|---|
| Casos diagnosticados | plantillas | mensual | Validar repetición |
| Decisiones registradas | context prototype | mensual | Evitar pérdida de contexto |
| Tareas con próxima acción | CRM/template | semanal | Mejor seguimiento |
| Documentos creados | repo/docs | mensual | Activos reutilizables |
| Memorias candidatas | context prototype | mensual | Aprendizaje acumulado |

---

## 12. Decisiones del diagnóstico

| ID | Decisión | Rationale | Fuente | Próxima acción |
|---|---|---|---|---|
| dec_001 | Probar con caso real antes de software | El piloto interno es parcial; falta fricción real. | caso piloto | Elegir cliente/caso |
| dec_002 | Mantener automatización en espera | El proceso aún se está validando. | RFC 0003 | Revisar tras 1-3 casos |

---

## 13. Próximas acciones

| ID | Tarea | Responsable | Fecha | Contexto |
|---|---|---|---|---|
| task_001 | Elegir primer caso real/semi-real | Creándola | 2026-06-29 | Validación operativa |
| task_002 | Completar diagnóstico con ese caso | Creándola / Hermes | 2026-06-29 | Usar esta plantilla |
| task_003 | Generar reporte mensual del caso | Creándola / Hermes | Después del piloto | Validar valor |

---

## 14. Memorias candidatas

| Tipo | Memoria | Fuente | ¿Guardar? |
|---|---|---|---|
| decisión | No construir software hasta validar con casos reales. | caso piloto | sí |
| proceso | Diagnóstico horizontal debe alimentar CRM, reporte y propuesta. | caso piloto | sí |
| producto | Context Engine necesita fuentes, decisiones, eventos y tareas para ser útil. | RFCs + piloto | sí |

---

## 15. Recomendación Creándola

### Problema principal

```txt
La visión Company OS está bien definida, pero necesita validación operativa con casos reales antes de convertirse en software.
```

### Horizontal inicial recomendada

```txt
Documentación + Seguimiento / CRM + Reportes.
```

### Paquete recomendado

```txt
Operación acompañada interna / piloto manual.
```

### Qué NO construir todavía

```txt
Dashboard, agentes autónomos, integraciones profundas, graph DB, CRM propio.
```

---

## 16. Reuse analysis

```txt
Qué ya existía: RFCs, plantillas, progreso, horizontales.
Qué se reutilizó: diagnóstico horizontal, Context Engine prototype, score de calificación.
Qué se creó nuevo: diagnóstico aplicado al propio proyecto Company OS.
Qué docs o plantillas se actualizaron: progreso debe registrar piloto.
```
