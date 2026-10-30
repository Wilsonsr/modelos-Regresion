# Informe de cambios: `05_Introduccion_ANOVA.ipynb` → `05_Introduccion_ANOVA_Mejorado.ipynb`

**Fecha:** 30 de octubre de 2026
**Archivo original:** `05_ANOVA/05_Introduccion_ANOVA.ipynb` (se conserva sin modificaciones)
**Archivo nuevo:** `05_ANOVA/05_Introduccion_ANOVA_Mejorado.ipynb` (108 celdas: 51 Markdown y 57 de código; 21 figuras)

---

## 1. Auditoría del cuadernillo original

Se revisaron las 65 celdas del original (30 Markdown y 35 de código). Lo que sigue son los problemas encontrados, ordenados por gravedad.

### 1.1 Errores o inconsistencias estadísticas

| # | Problema en el original | Gravedad | Corrección |
|---|---|---|---|
| E1 | **Comparaciones post hoc incoherentes con el diagnóstico.** El original diagnosticó varianzas desiguales en `Cars93` (Levene $p<0{,}001$, diseño desbalanceado) y, aun así, aplicó **Tukey HSD**, que supone varianza común. Con base en Tukey afirmó que "*Midsize* es más caro que *Compact* y *Sporty*". Con **Games-Howell**, el procedimiento adecuado, ninguna de esas dos diferencias es significativa ($p=0{,}051$ y $p=0{,}19$). | Alta | Se implementó Games-Howell (validado contra `pingouin`: valores $p$ idénticos), se aplica al caso `Cars93` y se presenta una tabla que muestra en qué pares discrepan Tukey y Games-Howell y por qué. La conclusión se corrigió. |
| E2 | La fórmula $1-(1-\alpha)^m$ se presentaba como la tasa de error por familia sin explicitar que **supone pruebas independientes**, condición que no se cumple en las comparaciones por pares. | Media | Se declara explícitamente la condición, se explica por qué la fórmula exagera, se añade la cota de Bonferroni ($\text{FWER}\le m\alpha$) y la simulación compara la tasa real con y sin corrección. |
| E3 | Umbrales de Cohen para $\eta^2$ (0,01 / 0,06 / 0,14) presentados como "guía", sin contexto ni fuente precisa. | Media | Se aclara que Cohen (1988) los propuso para $f$ en ciencias del comportamiento como convención por defecto, se dan las equivalencias aproximadas y se insiste en juzgar la importancia en unidades del problema. Se añadió la $f$ de Cohen (con $\eta^2$ y con $\omega^2$). |
| E4 | Normalidad: tras la transformación logarítmica, Shapiro-Wilk $p=0{,}13$ se interpretó como "Aceptable" sin advertir que un $p>0{,}05$ no demuestra normalidad. | Media | Nueva sección 4.2 con tres advertencias (potencia limitada con $n$ pequeño, sobrepotencia con $n$ grande, robustez de $F$), una reflexión dedicada y la normalidad formulada como "normalidad condicional de los errores". |
| E5 | No había criterio para elegir entre ANOVA clásico y Welch; Bartlett aparecía sin advertir su sensibilidad a la no normalidad. | Media | Tabla de pruebas de homocedasticidad (Levene-mediana, Bartlett, Fligner-Killeen) con sus usos, y tabla de decisión clásico/Welch basada en el balance del diseño y en la heterogeneidad (sección 4.7). |
| E6 | Kruskal-Wallis presentado en una tabla como alternativa ante "no normalidad severa" que "compara distribuciones (rangos)", sin hipótesis ni limitaciones. | Media | Nueva sección 6.2: fórmula de $H$, hipótesis nula (igualdad de distribuciones), interpretación como dominancia estocástica, por qué **no** es una prueba de medianas con dispersiones distintas y por qué no corrige la heterocedasticidad. |
| E7 | En el ANCOVA, una interacción no significativa se leyó como "el supuesto de pendientes homogéneas es razonable", sin matizar. | Baja | Se matiza y se añade la sección "Ausencia de evidencia de interacción no es evidencia de ausencia", con una simulación de potencia y un intervalo de confianza para el contraste de interacción. |
| E8 | La interpretación del valor $p$ no se hacía explícita. | Baja | Interpretación correcta en el ejemplo a mano (2.5) y en el ejercicio I3, con dos interpretaciones incorrectas frecuentes. |
| E9 | No se distinguía **unidad experimental** de **unidad de observación**, ni se mencionaba la pseudorreplicación. | Media | Sección 1.2, ejemplo con piezas dentro de una orden y ejercicio B2. |

### 1.2 Problemas de código

| # | Problema | Corrección |
|---|---|---|
| C1 | Supresión global de advertencias (`warnings.filterwarnings("ignore")`). | Eliminada. El cuadernillo se ejecuta sin emitir advertencias en ninguna celda. |
| C2 | Un único generador aleatorio global `rng` compartido por todas las simulaciones: los resultados dependían del orden de ejecución de las celdas. | Cada simulación crea su propio generador con semilla fija; cualquier celda produce el mismo resultado se ejecute cuando se ejecute. |
| C3 | Simulaciones con bucles de miles de llamadas a `anova_oneway` (más de 2 minutos de ejecución). | Simulaciones vectorizadas con NumPy (Welch implementado y verificado contra `statsmodels`); el cuadernillo completo se ejecuta en 20–30 s. Se pudo así aumentar las repeticiones (hasta 20 000) y reducir el error de Monte Carlo. |
| C4 | `display()` usado sin importarlo; importaciones sin agrupar. | Importaciones ordenadas por tipo e importación explícita de `display`. |
| C5 | Nombres poco descriptivos (`m2`, `c`, `kw`, `res_t`). | Nombres descriptivos (`modelo_dos_factores`, `coeficientes_contraste`, `kruskal_cars`, …). |
| C6 | Uso de `DataFrame.style` (requiere `jinja2`, que no siempre está instalado). | Eliminado: en el equipo del usuario provocaba un error. |

### 1.3 Problemas pedagógicos

- La secuencia iba de la estructura matricial (identificabilidad, rango) a la descomposición de la variabilidad, es decir, de lo abstracto a lo concreto. Ahora la progresión va de la intuición a la formalización, y la parte matricial pasa a una unidad de profundización.
- No había un **ejemplo pequeño resuelto a mano**.
- Faltaban objetivos medibles, conocimientos previos, tabla de contenidos, preguntas de predicción antes de las simulaciones, ejercicios graduados y solucionario.
- No había un ejemplo aplicado de un factor con datos que cumplieran los supuestos (sólo `Cars93`, que los incumple), lo que impedía mostrar primero el procedimiento "limpio".

## 2. Contenidos conservados

Se conservó todo el contenido técnico del original, reubicado y ampliado: la competencia y su hilo conductor (la rigidez de la estructura paramétrica), la simulación del error por familia, los dos escenarios "mismas medias, distinto ruido", los modelos de medias de celda y de efectos, la identificabilidad con la matriz de rango incompleto, las parametrizaciones de referencia y de suma cero con las funciones estimables, la simulación de la distribución muestral de los estimadores, la descomposición de sumas de cuadrados a mano sobre `Cars93`, $\eta^2$ y $\omega^2$, la distribución $F$ con la región crítica, el diagnóstico de `Price` frente a `log(Price)`, la simulación de robustez con los escenarios A–D, Welch, Kruskal-Wallis, Tukey, el contraste planeado, la potencia, el experimento de dos factores con interacción y los efectos simples, las sumas de cuadrados tipo I/II/III, la celda vacía *Large/non-USA*, el diseño en bloques, el ANCOVA, los efectos aleatorios y el mapa del modelo lineal general.

## 3. Reorganización

| Original (5 unidades) | Mejorado (8 unidades + anexo) |
|---|---|
| 1. Fundamentos | **1. ¿Qué es ANOVA?** Problema aplicado, vocabulario, unidad experimental frente a unidad de observación, pruebas $t$ múltiples, hipótesis, variabilidad entre y dentro |
| 2. Estructura del modelo (incluía identificabilidad) | **2. Fundamento matemático:** modelo, descomposición, gl, CM, $F$, $E(CM)$, tabla, **ejemplo a mano** |
| 3. Análisis de varianza | **3. ANOVA de un factor con Python:** caso industrial (simulado) y `Cars93` (real), redacción de conclusiones |
| 4. Pruebas de hipótesis (incluía supuestos, post hoc y potencia) | **4. Validación y diagnóstico:** independencia, normalidad, homocedasticidad, atípicos, influencia, robustez, elección clásico/Welch |
| — | **5. Comparaciones múltiples y tamaños del efecto:** ANOVA no significativo, Tukey, **Games-Howell**, contrastes, $\eta^2$, $\omega^2$, $f$, potencia |
| 5. Extensiones | **6. Alternativas y extensiones:** Welch (fórmula), Kruskal-Wallis, dos factores, ausencia de evidencia de interacción, SC tipo I/II/III, bloques, **medidas repetidas**, ANCOVA, efectos aleatorios |
| (identificabilidad estaba en la unidad 2) | **7. Profundización matemática:** ANOVA como regresión, identificabilidad, restricciones, funciones estimables, $E(CM)$ por simulación |
| Ejercicios (5, sin solución) | **8. Taller práctico** (problema nuevo) y **12 ejercicios en 4 niveles** |
| — | **Anexo docente:** pistas de las reflexiones, solución completa del taller con código, pistas de los ejercicios |

## 4. Nuevos ejemplos

1. **Ejemplo pequeño resuelto a mano** (3 métodos × 4 observaciones, con valores enteros elegidos para que las cuentas sean exactas: $SC_{Tr}=72$, $SC_E=30$, $F=10{,}8$), verificado luego con `pandas` y `statsmodels`.
2. **Comparación de tres métodos de producción según el tiempo de fabricación** (datos **simulados**, identificados como tales): diseño aleatorizado, orden de ejecución, exploración, ANOVA, diagnóstico (incluido Durbin-Watson frente al orden), Tukey, contraste planeado, tamaño del efecto y conclusión con alcance causal justificado por la aleatorización.
3. **ANOVA no significativo** con tres tipos de `Cars93`: qué reportar y por qué no buscar comparaciones significativas.
4. **Medidas repetidas** (12 operarios × 3 herramientas, simulado): `AnovaRM`, prueba de Mauchly, épsilon de Greenhouse-Geisser (ambos validados contra `pingouin`), Friedman y comparación con el análisis incorrecto que ignora la estructura.
5. **Taller**: resistencia de lámina de cuatro proveedores (simulado, desbalanceado y heterocedástico). Su solución muestra un punto didáctico importante: el proveedor con la media más baja no aparece significativamente distinto de los demás porque su variabilidad y su escasa muestra hacen los intervalos muy anchos.

`Cars93` se conservó y se contextualizó (fuente, unidad de observación, carácter observacional, alcance de la generalización). Se verificó su acceso desde `../datos/Cars93.csv`.

## 5. Nuevas visualizaciones

Boxplots con observaciones individuales (casos A, B y taller); histogramas por grupo; gráficos de medias con IC del 95 % (con la advertencia sobre el traslape); densidades por grupo; distribución $F$ con región crítica, valor $F$ crítico y área del valor $p$ (función reutilizable); histogramas de $F$ simulados frente a la $F$ teórica; residuos frente al orden de ejecución; panel de diagnóstico con residuos frente a ajustados, Q-Q, histograma y distancia de Cook; intervalos simultáneos de Tukey y Games-Howell; curva de potencia teórica con puntos simulados; gráficos de interacción.

## 6. Simulaciones (todas con pregunta de predicción previa e interpretación posterior)

| Simulación | Qué permite observar | Ubicación |
|---|---|---|
| 1. Pruebas $t$ múltiples | Error de tipo I por familia con y sin Bonferroni; diferencia entre la fórmula de independencia y la tasa real | 1.3 |
| 2. Distribución de $F$ | (a) medias iguales: $F$ sigue la distribución teórica y rechaza ≈5 %; (b) mayor separación; (c) mayor variabilidad interna | 1.5 |
| 3. Heterocedasticidad | Error de tipo I de la $F$ clásica y de Welch en 5 escenarios (20 000 repeticiones cada uno) | 4.6 |
| 4. Tamaño de muestra y potencia | Potencia simulada frente a la teórica ($F$ no central) | 5.6 |
| 5. Interacción en un piloto | Potencia de la prueba de interacción con pocas réplicas | 6.3 |
| 6. Distribución muestral y $E(CM)$ | Insesgamiento de $\hat\tau_i$ y de $CM_E$; comprobación de $E(CM_{Tr})$ | 7.4 |

En cada caso se distingue la **propiedad teórica** (que se puede demostrar) del **resultado particular de la simulación** (sujeto a error de Monte Carlo, que se cuantifica cuando es relevante).

## 7. Material de referencia consultado

El artículo solicitado (`https://cienciadedatos.net/documentos/pystats09-analisis-de-varianza-anova-python`) **no pudo consultarse**: la política de red de la sesión bloqueó esa URL y no se encontró en los resultados de búsqueda, de modo que su contenido no se conoce ni se infirió. Como material complementario del mismo autor y sitio se consultaron:

- *ANOVA: análisis de varianza para comparar múltiples medias* (J. Amat Rodrigo, versión en R): https://cienciadedatos.net/documentos/19_anova
- *Análisis de homocedasticidad y heterocedasticidad con Python* (serie pystats): https://cienciadedatos.net/documentos/pystats07-test-homocedasticidad-heterocedasticidad-python.html

De ellos se tomaron, con redacción y ejemplos propios, estos enfoques: la secuencia de exploración → supuestos → ANOVA → tamaño del efecto → post hoc; la recomendación de Levene centrado en la mediana y Fligner-Killeen frente a Bartlett cuando la normalidad es dudosa; el reporte de $F$, gl, $p$ y tamaño del efecto; y el tratamiento de las medidas repetidas con esfericidad, Mauchly, Greenhouse-Geisser, Friedman y pruebas pareadas con Holm en lugar de Tukey. No se copió texto.

## 8. Dependencias

Ver `requirements.txt` en la raíz del repositorio. Versiones mínimas: `numpy>=1.23`, `pandas>=1.5`, `scipy>=1.11`, `statsmodels>=0.14`, `matplotlib>=3.6`, `seaborn>=0.13`, y `ipykernel` y `jupyter` para la ejecución. **No requiere** `pingouin` ni `jinja2`.

## 9. Pruebas de ejecución

| Prueba | Resultado |
|---|---|
| Validación del esquema `nbformat` v4 | Válido |
| Ejecución completa desde kernel limpio, entorno de nube (Python 3.13.16, numpy 2.5.3, pandas 3.0.5, scipy 1.18.1, statsmodels 0.15.0, matplotlib 3.11.2, seaborn 0.13.2) | 57/57 celdas de código sin errores ni advertencias; 21 figuras; ~27 s |
| Ejecución completa en el equipo del usuario (Python 3.10.12, numpy 2.2.6, pandas 2.3.3, scipy 1.15.3, statsmodels 0.15.0, matplotlib 3.10.9, seaborn 0.13.2) | 57/57 celdas sin errores; 21 figuras; ~23 s. Los resultados numéricos clave (Welch, Durbin-Watson, Mauchly, simulaciones con semilla) coinciden con los de la nube |
| Implementación propia de Welch | Coincide con `statsmodels.stats.oneway.anova_oneway` (F = 41,6834; gl2 = 36,80) |
| Implementación propia de Games-Howell | Coincide con `pingouin.pairwise_gameshowell` (valores $p$ idénticos a 4 decimales) |
| Implementación propia de Mauchly y Greenhouse-Geisser | Coincide con `pingouin.sphericity` y `pingouin.epsilon` |
| Concordancia texto-resultados | Se revisaron todas las cifras citadas en el texto frente a las salidas ejecutadas; se corrigieron las discrepancias encontradas durante la revisión |
| Reproducibilidad | Todas las simulaciones usan generadores con semilla propia; dos ejecuciones independientes producen las mismas salidas |

El cuadernillo se entrega **ejecutado** (con salidas actualizadas), para que pueda leerse sin ejecutarlo.

## 10. Limitaciones pendientes

- No se pudo consultar el artículo específico de cienciadedatos.net indicado (ver sección 7).
- Games-Howell, Mauchly y Greenhouse-Geisser se implementaron directamente para evitar una dependencia adicional; están validados, pero no cubren casos con datos faltantes en medidas repetidas.
- La prueba de Dunn (post hoc de Kruskal-Wallis) y la de Dunnett se mencionan pero no se implementan.
- Los tamaños del efecto se reportan como estimaciones puntuales; no se incluyen intervalos de confianza para $\eta^2$ y $\omega^2$.
- El taller y varios ejemplos usan datos simulados (identificados como tales). Para un taller con datos reales puede usarse el ejercicio I1 (`MPG_city` según `DriveTrain` en `Cars93`).
- En `Cars93` la posible dependencia entre modelos de un mismo fabricante se declara como limitación, pero no se modela.
