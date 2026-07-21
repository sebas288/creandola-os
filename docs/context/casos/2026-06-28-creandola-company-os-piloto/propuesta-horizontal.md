# Propuesta Horizontal — Piloto interno Company OS

> Documento interno. No es propuesta comercial para cliente externo.

# Propuesta para Creándola interno

## 1. Contexto

```txt
Creándola está construyendo una visión interna de Company OS basada en Context Engine. Ya existen RFCs, ontología, modelo conceptual y plantillas. Falta validar con casos reales antes de construir software.
```

### Lo que entendimos

```txt
1. La oportunidad está en conectar conocimiento, decisiones, procesos y herramientas, no en reemplazar Notion/HubSpot/Figma/GitHub.
2. El núcleo conceptual es Context Engine.
3. Las plantillas son el paso correcto antes de construir Creándola OS como software.
```

### Fuentes usadas

```txt
RFCs 0001-0003, progreso del proyecto, plantillas horizontales, piloto interno.
```

---

## 2. Problema principal

```txt
La visión está bien definida, pero todavía no hay validación con un flujo real de cliente. Construir software ahora podría adelantar complejidad antes de confirmar repetición, valor mensual y datos mínimos.
```

### Impacto del problema

| Área | Impacto |
|---|---|
| Ventas | Aún no se prueba cómo vender/explicar el sistema en diagnóstico real. |
| Tiempo | Riesgo de invertir tiempo en software prematuro. |
| Calidad del servicio | Las plantillas deben probar si mejoran diagnóstico y seguimiento. |
| Documentación | Ya hay buen avance, falta uso real. |
| Equipo / dueño | El sistema puede reducir dependencia de memoria, pero falta validación. |
| Reportes | Hay plantilla, falta reporte de cliente real. |

---

## 3. Resultado esperado

```txt
En 30 días, Creándola debe haber probado el sistema con al menos un caso real o semi-real y generado diagnóstico, CRM row, decisiones, tareas, reporte y recomendación/propuesta.
```

---

## 4. Sistema propuesto

```txt
Caso entra → se diagnostica → se registra → se decide → se crean tareas → se documenta → se reporta → se aprende
```

### Horizontales incluidas

| Horizontal | Incluida | Objetivo |
|---|---|---|
| Captación | Parcial | Usar origen del caso como fuente. |
| Calificación | Sí | Decidir si el caso merece acompañamiento. |
| Seguimiento / CRM | Sí | Registrar estado y próxima acción. |
| Atención / WhatsApp | Parcial | Validar guion si el caso viene por WhatsApp. |
| Documentación | Sí | Crear memoria y documentos. |
| Procesos internos | Sí | Validar flujo diagnóstico → reporte. |
| Automatización | Después | Solo si se repite. |
| Reportes | Sí | Mostrar valor mensual. |

---

## 5. Alcance inicial

### Incluye

```txt
1. Selección de caso piloto real o semi-real.
2. Diagnóstico horizontal.
3. Registro manual en Context Engine prototype.
4. CRM horizontal.
5. Reporte mensual.
6. Ajuste de plantillas según fricción.
```

### No incluye todavía

```txt
1. Dashboard.
2. CRM propio.
3. Graph database.
4. Agentes autónomos.
5. Integraciones profundas.
6. Automatizaciones completas.
```

---

## 6. Entregables

| Entregable | Descripción | Formato |
|---|---|---|
| Diagnóstico horizontal aplicado | Mapa del caso y horizontales | Markdown |
| Context Engine case | Entidades, relaciones, eventos, memorias | Markdown |
| CRM row | Seguimiento del caso | CSV |
| Reporte mensual | Avance, decisiones y próximos pasos | Markdown |
| Ajustes a plantillas | Cambios según fricción | Docs |

---

## 7. Cronograma sugerido

| Semana | Foco | Resultado |
|---|---|---|
| Semana 1 | Elegir caso y diagnosticar | Caso modelado |
| Semana 2 | Seguimiento y documentación | Tareas y memorias |
| Semana 3 | Reporte | Evidencia de valor |
| Semana 4 | Ajuste | Plantillas mejoradas |

---

## 8. Acompañamiento mensual

Para clientes reales, el acompañamiento mensual debe sostener:

- revisión de oportunidades,
- decisiones,
- tareas,
- documentos,
- reportes,
- mejoras del proceso.

---

## 9. Inversión

```txt
Piloto interno: tiempo estratégico de Creándola.
Cliente real: definir después del diagnóstico.
```

---

## 10. Responsabilidades

### Creándola

```txt
1. Elegir caso.
2. Aportar contexto real no sensible.
3. Validar si el reporte genera valor.
4. Decidir si se repite o se ajusta.
```

### Hermes

```txt
1. Completar plantillas.
2. Organizar contexto.
3. Proponer decisiones/tareas.
4. Actualizar docs.
5. Verificar y mantener progreso.
```

---

## 11. Riesgos y supuestos

| Riesgo / supuesto | Cómo se maneja |
|---|---|
| Piloto demasiado interno | Pasar a caso real pronto. |
| Exceso de documentación | Medir si genera decisiones y tareas reales. |
| Datos sensibles | Usar datos anonimizados/no sensibles. |
| Software prematuro | Mantener criterio manual-first. |

---

## 12. Cómo mediremos valor

| Métrica | Fuente | Frecuencia |
|---|---|---|
| Decisiones explícitas | Context prototype | Por caso |
| Tareas con responsable | CRM / prototype | Semanal |
| Documentos creados | Repo / Drive | Mensual |
| Memorias útiles | Prototype | Por caso |
| Reporte generado | Reporte mensual | Mensual |

---

## 13. Próximos pasos

```txt
1. Elegir caso real o semi-real.
2. Completar diagnóstico horizontal con ese caso.
3. Registrar contexto en plantilla Context Engine.
4. Crear CRM row.
5. Generar reporte/propuesta.
6. Ajustar plantillas.
```

---

## 14. Context Engine mapping interno

| Elemento | Entidad / relación |
|---|---|
| Creándola interno | Client / Workspace |
| Company OS | Project |
| Sesión estratégica | Meeting |
| Decisiones de RFCs | Decision |
| Próximas acciones | Task |
| RFCs / plantillas | Document / Source |
| Piloto | Report / Case |
| Aprendizajes | Memory |

---

## 15. Reuse analysis

```txt
Qué ya existía: propuesta-horizontal template, RFCs y progreso.
Qué se reutilizó: alcance, horizontales, criterio de no construir software todavía.
Qué se creó nuevo: propuesta interna para validar caso piloto real.
Qué docs o plantillas se actualizaron: progreso debe reflejar que el siguiente paso es caso real.
```
