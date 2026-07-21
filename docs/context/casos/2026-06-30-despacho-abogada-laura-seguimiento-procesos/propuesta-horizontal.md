# Propuesta Horizontal — Despacho Abogada Laura

> Propuesta inicial para validar seguimiento de procesos legales sin construir software todavía.

# Propuesta para Laura

## 1. Contexto

```txt
Laura necesita hacer seguimiento claro a los procesos de sus clientes: saber en qué etapa está cada proceso, qué documentos faltan, cuál es la próxima acción, qué está bloqueado y qué debe revisarse esta semana.
```

### Lo que entendimos

```txt
1. El dolor principal no es crear una landing ni captar más leads todavía.
2. El foco es seguimiento operativo de procesos de clientes.
3. El sistema debe evitar pérdida de contexto entre WhatsApp, documentos, memoria y tareas.
4. Por tratarse de procesos legales, la información sensible debe manejarse con cuidado y fuera del repo.
```

### Fuentes usadas

```txt
Definición del usuario, plantillas horizontales de Creándola, RFCs del Context Engine.
```

---

## 2. Problema principal

```txt
Cuando un despacho maneja varios procesos, el avance puede quedar fragmentado: una parte en WhatsApp, otra en documentos, otra en memoria y otra en conversaciones. Eso dificulta saber qué caso necesita atención, qué documento falta y qué debe hacerse después.
```

### Impacto del problema

| Área | Impacto |
|---|---|
| Servicio al cliente | Respuestas menos consistentes sobre estado del proceso. |
| Tiempo de Laura | Más esfuerzo revisando conversaciones y documentos. |
| Documentación | Riesgo de documentos pendientes o dispersos. |
| Seguimiento | Casos sin próxima acción visible. |
| Reportes | Dificultad para ver carga y prioridades del despacho. |

---

## 3. Resultado esperado

```txt
En 2 semanas, Laura debe tener una vista inicial de procesos con estado, documentos, próxima acción, responsable y fecha de revisión, usando datos anonimizados para el piloto.
```

---

## 4. Sistema propuesto

No proponemos empezar por software. Proponemos ordenar primero el seguimiento.

```txt
Cliente/proceso entra → se clasifica → se solicitan documentos → se registra estado → se define próxima acción → se revisa semanalmente → se reporta avance
```

### Horizontales incluidas

| Horizontal | Incluida | Objetivo |
|---|---|---|
| Captación | No inicial | Postergar hasta ordenar operación. |
| Calificación | Parcial | Clasificar nuevos casos/procesos. |
| Seguimiento / CRM | Sí | Ver estado y próxima acción por proceso. |
| Atención / WhatsApp | Parcial | Crear mensajes de actualización, sin automatizar todavía. |
| Documentación | Sí | Checklist de documentos y pendientes. |
| Procesos internos | Sí | Definir etapas y revisión semanal. |
| Automatización | Después | Solo si el flujo se repite y el lenguaje está validado. |
| Reportes | Sí | Resumen semanal/mensual de procesos. |

---

## 5. Alcance inicial

### Incluye

```txt
1. Diagnóstico de flujo actual de seguimiento.
2. Mapa de etapas reales del proceso.
3. Tabla/CRM v1 de procesos anonimizados.
4. Campos mínimos por proceso.
5. Checklist documental inicial.
6. Reporte semanal inicial.
7. Recomendaciones de automatización futura.
```

### No incluye todavía

```txt
1. Software propio.
2. Portal de clientes.
3. Automatización de WhatsApp.
4. Integración con juzgados, correos o expedientes.
5. Manejo de datos sensibles en repo.
6. Agentes autónomos.
```

---

## 6. Entregables

| Entregable | Descripción | Formato |
|---|---|---|
| Mapa de etapas | Flujo real de los procesos de Laura | Documento |
| Tabla de seguimiento v1 | Procesos, estado, próxima acción, documentos | Sheet/Airtable/Notion privado |
| Checklist documental | Documentos requeridos/recibidos/pendientes | Documento / tabla |
| Guion de actualización | Mensaje base para responder estado al cliente | Documento |
| Reporte semanal | Procesos activos, bloqueados y próximos pasos | Documento |

---

## 7. Cronograma sugerido

| Semana | Foco | Resultado |
|---|---|---|
| Semana 1 | Diagnóstico + etapas + campos | Estructura validada con Laura |
| Semana 2 | Carga de 3-5 procesos anonimizados + reporte | Primer ciclo de seguimiento probado |
| Semana 3 | Ajustes | Mejorar campos, estados y reporte |
| Semana 4 | Decisión | Mantener manual, automatizar algo o ampliar |

---

## 8. Acompañamiento mensual futuro

Si el piloto funciona, el acompañamiento mensual puede incluir:

- revisión semanal de procesos,
- actualización de tablero,
- mejora de checklist documental,
- reporte mensual de carga/avance,
- ajustes de mensajes para clientes,
- automatizaciones pequeñas cuando el flujo esté validado.

---

## 9. Inversión

```txt
Por definir después de validar alcance y volumen de procesos.
```

Para el piloto, sugerencia interna:

```txt
Piloto corto de 2 semanas con alcance limitado a 3-5 procesos anonimizados.
```

---

## 10. Responsabilidades

### Creándola

```txt
1. Diseñar la estructura de seguimiento.
2. Crear tabla/plantilla inicial.
3. Ordenar etapas, campos y reporte.
4. Recomendar mejoras después del piloto.
```

### Laura

```txt
1. Validar etapas reales.
2. Aportar 3-5 procesos anonimizados.
3. Confirmar documentos frecuentes.
4. Probar la tabla en una revisión semanal.
5. Dar feedback sobre utilidad.
```

---

## 11. Riesgos y supuestos

| Riesgo / supuesto | Cómo se maneja |
|---|---|
| Exponer datos sensibles | Usar datos anonimizados y herramienta privada para datos reales. |
| Etapas incorrectas | Validar el pipeline con Laura antes de usarlo. |
| Demasiados campos | Empezar con campos mínimos. |
| Automatizar prematuramente | Dos semanas manuales antes de decidir automatización. |
| Reporte poco útil | Validar con Laura qué necesita ver semanalmente. |

---

## 12. Cómo mediremos valor

| Métrica | Fuente | Frecuencia |
|---|---|---|
| Procesos con próxima acción | Tabla de seguimiento | Semanal |
| Procesos bloqueados | Tabla de seguimiento | Semanal |
| Documentos pendientes | Checklist | Semanal |
| Procesos sin actualización | Tabla de seguimiento | Semanal |
| Procesos cerrados/avanzados | Reporte | Mensual |

---

## 13. Próximos pasos

```txt
1. Validar con Laura las etapas reales.
2. Elegir herramienta privada para datos reales: Google Sheets, Airtable, Notion o similar.
3. Cargar 3-5 procesos anonimizados.
4. Generar primer reporte semanal.
5. Ajustar campos y estados.
```

---

## 14. Context Engine mapping interno

| Elemento | Entidad / relación |
|---|---|
| Despacho Laura | Client / Workspace |
| Sistema de seguimiento | Project |
| Proceso de cliente | Process / ClientCase |
| Etapa actual | State |
| Documentos pendientes | Document / Evidence |
| Próxima acción | Task |
| Revisión semanal | Event / Meeting |
| Reporte | Report |
| Aprendizajes | Memory |

---

## 15. Reuse analysis

```txt
Qué ya existía: plantillas horizontales, Context Engine, diagnóstico y reporte.
Qué se reutilizó: seguimiento/CRM, documentación, reportes y reglas de privacidad.
Qué se creó nuevo: propuesta horizontal para el despacho de Laura.
Qué docs o plantillas se actualizaron: progreso debe registrar primer caso real.
```
