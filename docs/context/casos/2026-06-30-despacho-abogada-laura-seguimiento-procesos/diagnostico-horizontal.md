# Diagnóstico Horizontal — Despacho Abogada Laura

> Caso real/semi-real para seguimiento de procesos de clientes. Usar solo datos no sensibles y clientes anonimizados.

## 1. Datos generales

| Campo | Valor |
|---|---|
| Fecha | 2026-06-30 |
| Cliente / negocio | Despacho Abogada Laura |
| Contacto principal | Laura |
| WhatsApp / canal principal | Por validar con Laura |
| Ciudad / país | Colombia / por validar |
| Tipo de negocio | Servicios legales |
| Responsable Creándola | Creándola / Hermes |
| Fuente del lead | Cliente real existente / definido por usuario |
| Estado | Diagnóstico inicial |

### Objetivo del diagnóstico

```txt
Entender cómo Laura hace seguimiento hoy a los procesos de sus clientes y diseñar una primera estructura manual para que ningún caso quede sin estado, próxima acción, documento pendiente o responsable claro.
```

### Resultado esperado en 30-60 días

```txt
Que Laura pueda ver en una sola tabla/reportes: procesos activos, etapa actual, documentos pendientes, próxima acción, fecha límite, bloqueos y prioridades.
```

---

## 2. Contexto del negocio

Laura presta servicios legales y necesita hacer seguimiento a procesos de sus clientes. El dolor principal no es captar más leads en este momento, sino controlar mejor el avance de cada proceso y evitar que la información quede dispersa entre WhatsApp, memoria, documentos y conversaciones.

Supuestos por validar:

1. Los procesos tienen etapas repetibles.
2. Hay documentos que se solicitan y quedan pendientes.
3. Parte del seguimiento ocurre por WhatsApp.
4. El despacho necesita una vista semanal/mensual de estado.
5. El cliente final pregunta por avances y requiere comunicación clara.
6. Existen fechas límite, requerimientos o tareas críticas.

---

## 3. Mapa de horizontales

| Horizontal | Dolor observado | Evidencia | Prioridad |
|---|---|---|---|
| Captación | No es el foco inicial. | Caso elegido es seguimiento de procesos. | Baja |
| Calificación | Puede servir para diagnosticar nuevos clientes/casos. | Servicios legales requieren decidir viabilidad/encaje. | Media |
| Seguimiento / CRM | Principal dolor: saber estado y próxima acción por proceso. | Pedido explícito del usuario. | Alta |
| Atención / WhatsApp | Probable canal de seguimiento con clientes. | Supuesto por validar con Laura. | Media / Alta |
| Documentación | Procesos legales dependen de documentos y requisitos. | Naturaleza del despacho. | Alta |
| Procesos internos | Se requiere flujo claro por etapa. | Necesidad de seguimiento. | Alta |
| Automatización | No todavía; primero validar estados/campos. | Regla Company OS. | Baja |
| Reportes / analítica | Laura necesita vista de procesos, bloqueos y próximos pasos. | Objetivo del caso. | Alta |

### Horizontal principal a intervenir primero

```txt
Seguimiento / CRM + Documentación + Reportes.
```

### Horizontales secundarias

```txt
Atención / WhatsApp + Calificación de nuevos casos.
```

---

## 4. Captación

No es la prioridad inicial. Sin embargo, si más adelante Laura quiere captar casos, el sistema de seguimiento puede conectarse con un intake legal.

### Hallazgos de captación

```txt
Postergar. Primero ordenar procesos existentes y seguimiento de clientes actuales.
```

---

## 5. Calificación

Preguntas candidatas para nuevos procesos:

1. ¿Qué tipo de proceso o necesidad legal tiene el cliente?
2. ¿Qué etapa trae actualmente?
3. ¿Ya existen documentos base?
4. ¿Hay fecha límite o urgencia?
5. ¿Quién es el responsable de entregar información?
6. ¿Qué resultado espera el cliente?
7. ¿Qué riesgos o bloqueos se ven desde el inicio?

### Score simple

| Criterio | 0 | 1 | 2 | Puntaje |
|---|---|---|---|---:|
| Dolor | Consulta general | Necesidad clara | Urgente / proceso activo | 2 |
| Autoridad | No decide | Familiar/contacto | Cliente decide | 1 |
| Presupuesto | No tiene | Por definir | Tiene rango claro | 1 |
| Timing | Sin urgencia | Este trimestre | Este mes / fecha límite | 2 |
| Encaje | Fuera de foco | Parcial | Encaja con el despacho | 2 |

Puntaje total:

```txt
8/10 estimado — caso apto para piloto operativo. Validar con Laura.
```

---

## 6. Seguimiento / CRM

### Problema

El proceso legal puede quedar disperso entre:

```txt
WhatsApp + llamadas + documentos + memoria de Laura + correos + carpetas + notas.
```

### Vista recomendada v1

```txt
Consulta recibida → Diagnóstico inicial → Documentos solicitados → Documentos completos → En preparación → Radicado/presentado → En trámite → Requerimiento pendiente → Decisión/respuesta recibida → Cerrado / Pausado / Archivado
```

### Campos mínimos

```txt
proceso_id
cliente_anonimizado
tipo_proceso
estado_actual
estado_control
responsable
proxima_accion
fecha_proxima_accion
documentos_pendientes
bloqueo_actual
ultima_actualizacion
notas_no_sensibles
```

### Hallazgos de seguimiento

```txt
El seguimiento debe organizarse alrededor del proceso, no solo del lead. Cada proceso necesita próxima acción y fecha; si no tiene próxima acción, está en riesgo.
```

---

## 7. Atención / WhatsApp

Hipótesis: Laura recibe preguntas de clientes por WhatsApp sobre estado del proceso.

### Guiones o respuestas candidatas

```txt
Hola, ya tengo tu proceso registrado. Para darte una actualización clara, voy a revisar: etapa actual, documentos pendientes y próxima acción. Te respondo con el estado y qué necesitamos de tu parte.
```

```txt
Para avanzar necesitamos estos documentos: [lista]. Cuando estén completos, el proceso pasa a la siguiente etapa: [etapa].
```

```txt
Tu proceso está en etapa: [estado]. Próxima acción: [acción]. Fecha estimada de revisión: [fecha].
```

No automatizar aún; primero validar mensajes reales y lenguaje jurídico adecuado.

---

## 8. Documentación

### Documentos candidatos

| Documento / plantilla | Uso | Prioridad |
|---|---|---|
| Checklist de documentos por tipo de proceso | Saber qué falta y qué ya se recibió | Alta |
| Plantilla de actualización de estado al cliente | Responder consistentemente sin reescribir todo | Alta |
| Plantilla de resumen de proceso | Tener contexto rápido por cliente | Alta |
| Reporte semanal de procesos activos | Revisión operativa del despacho | Alta |
| Guion de intake legal | Calificar nuevos casos | Media |

---

## 9. Procesos internos

### Proceso actual supuesto

```txt
1. Cliente contacta a Laura.
2. Laura escucha el caso.
3. Se piden documentos.
4. Se revisa viabilidad/estado.
5. Se hacen actuaciones o trámites.
6. Cliente pregunta por avances.
7. Laura responde desde memoria/documentos/conversaciones.
```

### Proceso recomendado v1

```txt
1. Crear registro de proceso anonimizado.
2. Clasificar tipo de proceso.
3. Asignar etapa inicial.
4. Registrar documentos solicitados/recibidos/pendientes.
5. Definir próxima acción y fecha.
6. Marcar estado de control: al día / en riesgo / bloqueado.
7. Revisar tablero semanalmente.
8. Generar reporte mensual de procesos.
```

---

## 10. Automatización

Regla: no automatizar lo que aún no está entendido.

### Automatizaciones candidatas futuras

| Automatización | Trigger | Acción | Riesgo | Prioridad |
|---|---|---|---|---|
| Documento pendiente → recordatorio | Fecha límite próxima | Enviar recordatorio a cliente | Mensaje legal incorrecto o invasivo | Media futura |
| Proceso sin actualización | N días sin cambio | Alertar a Laura | Falsos positivos si el trámite depende de terceros | Media futura |
| Cambio de estado | Estado actualizado | Generar mensaje sugerido | Requiere lenguaje validado | Media futura |
| Reporte semanal | Viernes | Resumen de procesos por estado | Datos incompletos | Alta futura |

---

## 11. Reportes y valor mensual

### Métricas candidatas

| Métrica | Fuente | Frecuencia | Valor esperado |
|---|---|---|---|
| Procesos activos | CRM/tabla | semanal/mensual | Carga actual del despacho |
| Procesos sin próxima acción | CRM/tabla | semanal | Detectar riesgo |
| Documentos pendientes | checklist | semanal | Desbloquear avance |
| Procesos bloqueados por cliente | CRM/tabla | semanal | Seguimiento puntual |
| Procesos en riesgo | estado_control | semanal | Priorizar |
| Procesos cerrados | CRM/tabla | mensual | Medir avance |

---

## 12. Decisiones del diagnóstico

| ID | Decisión | Rationale | Fuente | Próxima acción |
|---|---|---|---|---|
| dec_001 | Usar procesos anonimizados | Evitar datos sensibles en repo. | diagnóstico | Crear 3-5 registros ficticios/anonimizados |
| dec_002 | Empezar por seguimiento, no captación | El dolor explícito es procesos de clientes. | usuario | Validar con Laura |
| dec_003 | No construir software todavía | Faltan etapas y campos reales. | RFCs | Probar tabla manual |
| dec_004 | Proceso jurídico como unidad principal | El valor está en controlar avance por proceso. | diagnóstico | Validar pipeline con Laura |

---

## 13. Próximas acciones

| ID | Tarea | Responsable | Fecha | Contexto |
|---|---|---|---|---|
| task_001 | Confirmar tipos de procesos principales de Laura | Creándola / Laura | 2026-07-01 | Insolvencia u otros, por validar |
| task_002 | Validar etapas reales del proceso | Creándola / Laura | 2026-07-01 | No imponer pipeline genérico |
| task_003 | Seleccionar 3-5 procesos anonimizados | Laura | 2026-07-01 | Sin datos sensibles |
| task_004 | Completar primera tabla CRM | Creándola | 2026-07-02 | Usar campos mínimos |
| task_005 | Revisar si reporte semanal le sirve a Laura | Creándola / Laura | 2026-07-05 | Validar valor real |

---

## 14. Memorias candidatas

| Tipo | Memoria | Fuente | ¿Guardar? |
|---|---|---|---|
| cliente | Primer caso real: despacho de abogada Laura para seguimiento de procesos. | usuario | sí |
| privacidad | No guardar datos sensibles de clientes legales en repo. | diagnóstico | sí |
| proceso | Seguimiento legal debe organizarse por proceso, etapa, documentos, próxima acción y fecha. | diagnóstico | sí |

---

## 15. Recomendación Creándola

### Problema principal

```txt
Laura necesita una vista operativa de sus procesos para saber qué está activo, qué está bloqueado, qué documentos faltan y cuál es la próxima acción con cada cliente.
```

### Horizontal inicial recomendada

```txt
Seguimiento / CRM + Documentación + Reportes.
```

### Paquete recomendado

```txt
Piloto manual de seguimiento legal — 2 semanas.
```

### Por qué ahora

```txt
Porque el despacho ya tiene procesos/clientes y el seguimiento manual puede mejorar sin desarrollar software todavía.
```

### Qué NO construir todavía

```txt
Software propio, portal de clientes, automatizaciones WhatsApp, dashboard avanzado, agentes IA autónomos.
```

---

## 16. Reuse analysis

```txt
Qué ya existía: horizontales, MVP operativo, RFCs, plantillas y piloto interno.
Qué se reutilizó: diagnóstico horizontal, CRM horizontal, Context Engine, reporte mensual.
Qué se creó nuevo: diagnóstico aplicado al despacho de Laura.
Qué docs o plantillas se actualizaron: docs/progreso-creandola.md debe registrar este primer caso real.
```
