# Diagnóstico Horizontal — Operación interna Creándola

> Diagnóstico aplicado a Creándola como cliente cero.

## 1. Datos generales

| Campo | Valor |
|---|---|
| Fecha | 2026-07-06 |
| Cliente / negocio | Creándola interno |
| Contacto principal | Dirección Creándola |
| WhatsApp / canal principal | Landing, WhatsApp, referidos, clientes actuales |
| Ciudad / país | Medellín, Colombia |
| Tipo de negocio | Acompañamiento estratégico-operativo con tecnología |
| Responsable Creándola | Dirección / estrategia |
| Fuente del lead | Interno |
| Estado | Diagnosticado inicial |

### Objetivo del diagnóstico

```txt
Entender qué necesita Creándola para gestionar su propia operación comercial y de entrega antes de adaptar el sistema a clientes externos.
```

### Resultado esperado en 30-60 días

```txt
Creándola debe tener pipeline interno, próximas acciones, decisiones documentadas, tareas visibles y un primer reporte mensual interno.
```

---

## 2. Contexto del negocio

Creándola ofrece diseño, desarrollo, acompañamiento estratégico-operativo, documentación, automatización e IA aplicada con contexto. La empresa ya tiene landing pública, captura de leads, integración inicial con WhatsApp y documentación estratégica del Company OS / Context Engine.

El problema principal no es falta de ideas ni falta de código. El problema es cerrar un sistema interno mínimo para vender, operar, documentar y reportar de forma repetible.

### Resumen del contexto

```txt
Creándola necesita convertirse en su propio primer caso real. La operación interna debe demostrar que las horizontales funcionan antes de empaquetarlas para clientes externos.
```

---

## 3. Mapa de horizontales

| Horizontal | Dolor observado | Evidencia | Prioridad |
|---|---|---|---|
| Captación | La landing ya capta, pero el seguimiento posterior debe conectarse mejor. | Landing + Supabase + WhatsApp existen. | Media |
| Calificación | Las oportunidades necesitan criterio de prioridad y encaje. | MVP operativo define score, pero falta uso interno real. | Alta |
| Seguimiento / CRM | Riesgo de que leads, clientes y proyectos dependan de memoria. | Plantilla CRM existe; falta operación privada activa. | Alta |
| Atención / WhatsApp | WhatsApp es canal clave y ya tiene base técnica. | Webhook, outbox y clasificación construidos. | Alta |
| Documentación | Hay mucha documentación estratégica, falta convertir operación diaria en memoria útil. | RFCs y plantillas existen. | Alta |
| Procesos internos | Se necesita flujo repetible de venta a entrega. | Flujo MVP definido. | Alta |
| Automatización | Hay candidatos, pero deben esperar validación manual. | Regla vigente: manual primero. | Media |
| Reportes / analítica | El valor mensual debe evidenciarse. | Plantilla de reporte existe. | Alta |

### Horizontal principal a intervenir primero

```txt
Seguimiento / CRM interno, conectado con documentación y reporte mensual.
```

### Horizontales secundarias

```txt
Calificación, Atención / WhatsApp, Procesos internos y Reportes.
```

---

## 4. Hallazgos por horizontal

### Captación

```txt
La captación pública ya tiene base: landing, formulario, WhatsApp y eventos. El siguiente problema no es crear más entrada, sino asegurar que cada entrada llegue a un sistema de seguimiento con responsable y próxima acción.
```

### Calificación

| Criterio | Puntaje | Lectura |
|---|---:|---|
| Dolor | 2 | Ordenar la operación propia es urgente para no construir piezas sueltas. |
| Autoridad | 2 | Creándola decide sobre su propia operación. |
| Presupuesto | 1 | Requiere tiempo y disciplina antes que inversión fuerte. |
| Timing | 2 | Debe hacerse antes de seguir con verticales externas. |
| Encaje | 2 | Encaja directamente con las horizontales. |

Puntaje total: `9/10 — prioridad alta`.

### Seguimiento / CRM

```txt
El repo ya contiene la estructura conceptual, pero falta usarla con datos operativos reales en una herramienta privada. El CSV del caso interno debe ser la forma inicial, no la base final.
```

### Atención / WhatsApp

```txt
La clasificación de WhatsApp ya existe técnicamente, pero debe validarse con mensajes reales y conectarse al pipeline interno.
```

### Documentación

| Documento / plantilla | Uso | Prioridad |
|---|---|---|
| CRM interno Creándola | Seguimiento semanal de oportunidades y clientes. | Alta |
| Reporte mensual interno | Evidencia de avance y aprendizaje. | Alta |
| Playbook de diagnóstico | Reutilizar con clientes. | Alta |
| Checklist de onboarding de cliente | Pasar de venta a operación. | Media |
| Plantilla de decisión | Capturar decisiones importantes con rationale. | Media |

---

## 5. Proceso recomendado

```txt
1. Lead entra por landing, WhatsApp, referido o cliente actual.
2. Se registra en CRM privado.
3. Se califica con score simple.
4. Se agenda diagnóstico o se pausa.
5. Se documenta diagnóstico.
6. Se envía propuesta o ruta de acompañamiento.
7. Si gana, se crea proyecto y tablero de tareas.
8. Se registran decisiones, documentos y próximos pasos.
9. Se revisa semanalmente.
10. Se reporta mensualmente.
```

## 6. Automatizaciones candidatas después de validar

| Automatización | Precondición |
|---|---|
| Lead de formulario → CRM privado | Campos definitivos validados. |
| Mensaje WhatsApp → clasificación → conversación | Clasificación probada con mensajes reales. |
| Oportunidad vencida → recordatorio | Pipeline usado al menos 3 semanas. |
| Tareas abiertas → reporte semanal | Tareas registradas consistentemente. |
| Reporte mensual semi-automático | Métricas mínimas estables. |

## 7. Recomendación

```txt
Priorizar durante julio 2026 el uso real de CRM interno + reporte mensual. No construir más producto hasta completar un ciclo operativo interno con evidencia.
```
