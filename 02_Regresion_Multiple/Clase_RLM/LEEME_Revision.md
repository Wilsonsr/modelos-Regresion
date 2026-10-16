# Clase de Regresión Lineal Múltiple — nota de revisión

Este documento explica **qué se hizo con el material previo**: qué contenido se
conservó, qué se reorganizó, qué se corrigió y qué se dejó fuera (y por qué).

## Archivos entregados

| Archivo | Qué es |
|---|---|
| `RLM_Clase.Rmd` | La clase completa en R Markdown. Ejecutable de principio a fin (*Knit*). 25 secciones. |
| `RLM_Practica.R` | El código esencial de la práctica, en el mismo orden, comentado. Corre con `Rscript` sin errores. |
| `RLM_Clase.ipynb` | El gemelo en Python. Misma secuencia, mismos datos, mismos resultados. Se ejecuta de arriba hacia abajo. |
| `trees.csv` | El conjunto de datos, copiado aquí para que los tres materiales lo lean del mismo directorio. |

**Verificación realizada.** El `.Rmd` se renderizó completo sin errores; el `.R` se
ejecutó completo sin errores; el `.ipynb` se ejecutó completo sin errores ni
advertencias. La sección 22 del notebook incluye una **celda de control de calidad**
que compara 12 cantidades contra los valores de R: las 12 coinciden.

---

## 1. Inventario del material previo

| Archivo original | Contenido | Destino |
|---|---|---|
| `Regresión Lineal Simple (2).Rmd` y `ejemploreglinealsimple.Rmd` (idénticos) | RLS: ejemplo ruido-hipertensión; ejemplo `Boston` (`medv ~ lstat`) | El ejemplo de ruido pasa a la **Parte 0 (nivelación)**, corregido. El ejemplo `Boston` se deja fuera (ver §4). |
| `Regresion Lineal multiple-2.ipynb` | Teoría del modelo múltiple y notación matricial; `trees`; cálculo de $\hat\beta$ paso a paso con numpy; SCRes/SCReg; F crítico; `statsmodels`; predicción con IC/IP | Núcleo de las **secciones 2, 4, 5, 6, 8** del notebook nuevo. |
| `Supuestos Modelo.ipynb` | Variables categóricas (Piscina, `Cars93`); supuestos con `Advertising` (linealidad, media de residuos, homocedasticidad, normalidad, autocorrelación, multicolinealidad/VIF) | Reorganizado en las **secciones 9–15 y 19**, reescrito sobre `trees`. |
| `suspuestos del modelo.Rmd` | Tipos de residuales; ejemplo `marketing` (`sales ~ youtube`); gráficos de diagnóstico; outliers, leverage, Cook | Base conceptual de las **secciones 10, 12, 13, 16**, reescrito sobre `trees`. |
| `Analisis_Residual (1) (2).Rmd` | Muy buena exposición teórica de la matriz sombrero, $Var(e_i)=\sigma^2(1-h_{ii})$ y los cuatro tipos de residuo; ya usaba `trees` | **Conservado casi íntegro** en la sección 10, con la notación unificada. |
| `Practica3_Diagnostico _1_(1) (2).R` | Diagnóstico completo sobre `trees` con funciones propias (`Leverage.normal`, `Residuos.normal`, `Influyentes.normal`); comparación del modelo sin la obs. 31 | Su **lógica** es el esqueleto de las secciones 16 y 17, con el código simplificado (ver §3). |
| `trees.csv` | Datos | Conjunto principal de toda la clase. |

---

## 2. Errores corregidos

1. **Intercepto mal interpretado (crítico).** En los dos `.Rmd` de regresión simple,
   el ejemplo ruido-hipertensión decía: *"El valor promedio de y cuando x es 0 es de
   **34.5538** unidades"*. Ese número pertenece al ejemplo de `Boston`
   (`medv ~ lstat`) y se copió por error: el intercepto real es **−10.132**. Además,
   el intercepto de ese modelo **no tiene interpretación práctica** (no hay datos
   cerca de 0 dB). Corregido y señalado explícitamente en el material nuevo, porque
   el error es didácticamente útil.

2. **Durbin-Watson aplicado sin sentido.** `Practica3_Diagnostico.R` corría
   `dwtest(modelo)` sobre `trees`, donde el orden de las filas (por `Girth`) no tiene
   significado sustantivo. El $d = 1.27$ que sale no indica autocorrelación sino la
   **curvatura** del modelo. El material nuevo lo aplica, explica por qué **no** debe
   interpretarse, y lo demuestra barajando las filas ($d$ pasa de 1.27 a 2.03 con el
   mismo modelo).

3. **Orden de las variables inconsistente.** El notebook original construía
   `X = [unos, Height, Girth]` a mano pero ajustaba `smf.ols("Volume ~ Height + Girth")`,
   y en otros puntos `Girth + Height`. Unificado a **`Volume ~ Girth + Height`** en
   los tres materiales.

4. **Ruta absoluta de Deepnote.** `trees=pd.read_csv("/work/trees.csv")` y
   `/work/Cars93.csv`, `/work/Advertising.csv`. Reemplazadas por rutas relativas.
   Igual con `trees.drop("Unnamed: 0", axis=1)`, que falla si la columna no existe:
   ahora se elimina con un filtro seguro por patrón.

5. **`attach(trees)` seguido de un segundo `attach(trees)`.** En el script original
   esto deja dos copias en el path de búsqueda y las variables `Girth`/`Height`
   apuntan a la copia vieja. Eliminado: el script nuevo no usa `attach()`.

6. **Codificación de umbrales.** `n=31` y `k=2` estaban escritos a mano en el script
   original; si cambia el conjunto de datos, los umbrales quedan mal. Ahora se
   calculan de los datos (`n <- nrow(trees)`).

7. **Falta de acentos y caracteres rotos** (`?ndice`, `Est?ndar`) por problemas de
   codificación. Todo en UTF-8.

8. **`sns.boxplot(trees)`** graficaba las tres variables en el mismo eje pese a tener
   escalas muy distintas (63–87 vs. 8–20). Ahora son tres paneles con escala propia.

9. **`sns.distplot()`** está obsoleto en seaborn ≥ 0.14. Reemplazado.

10. **`size=` en `sns.pairplot`** está obsoleto (es `height=`). Reemplazado.

---

## 3. Modernizaciones y simplificaciones

* **`!pip install` dentro de los notebooks** (`dataprep`, `statsmodels`): eliminados.
  Se declaran las librerías al inicio y `seaborn` es opcional con un `try/except`.
* **`dataprep.eda.create_report()`**: retirado. Es una dependencia pesada, poco
  estable, y oculta el trabajo exploratorio que el estudiante debe hacer a mano.
* **Las tres funciones propias** de `Practica3_Diagnostico.R` (`Leverage.normal`,
  `Residuos.normal`, `Influyentes.normal`) reimplementaban `hatvalues()`,
  `rstudent()` y `cooks.distance()`, que ya vienen en R base. Se conserva **su
  lógica de umbrales y etiquetado** pero usando las funciones estándar, en 5 líneas
  en lugar de 40.
* **`_dntk.DeepnoteChart(...)`**: celda propia de Deepnote, no ejecutable fuera de
  esa plataforma. Eliminada.
* **Gráficos base R + ggplot2 mezclados sin criterio**: ahora ggplot2 para lo
  expositivo y base R para los paneles de diagnóstico (donde `plot(modelo)` es más
  directo). `ggfortify`, `GGally` y `car` son **opcionales**: el documento detecta si
  están instalados y, si no, usa una implementación equivalente a mano — lo que además
  sirve para mostrar qué calcula el paquete.
* **`par(mfrow=c(1,2)); plot(modelo)`** producía 4 gráficos en una rejilla de 2:
  corregido a `c(2,2)`.

---

## 4. Contenido dejado fuera (y por qué)

* **Ejemplo `Boston` (`medv ~ lstat`), paquetes `MASS`/`ISLR`.** Es un ejemplo de
  **regresión simple** con 506 observaciones y 13 variables. Ampliarlo bien exigiría
  una clase propia, y compite por atención con `trees`. El prompt pedía que R y Python
  usaran **principalmente el mismo conjunto**: mantener `Boston` habría roto esa
  simetría (no está disponible en Python sin dependencias extra). *Se puede recuperar
  como ejercicio de ampliación.*
* **Ejemplo `marketing` / `Advertising` (`sales ~ youtube + ...`), paquete `datarium`.**
  Mismo motivo: son los datos con los que el material antiguo enseñaba los supuestos,
  pero eso ahora se hace sobre `trees` para tener un hilo único. La ventaja de `trees`
  es que **el incumplimiento del supuesto de linealidad tiene una explicación física**
  (el volumen de un sólido), lo que permite cerrar el ciclo diagnóstico → tratamiento
  → nuevo diagnóstico de forma convincente.
* **Ejemplo `Cars93` de variables categóricas.** Se sustituyó por un conjunto pequeño
  y controlado (`viviendas`, 15 filas) donde los coeficientes son transparentes y se
  puede demostrar **por qué la codificación 1-2-3 es incorrecta** —comparación que con
  `Cars93` se pierde entre seis niveles. Las interpretaciones de `Cars93` del material
  original eran correctas y están preservadas como *forma* de interpretar.
* **`train_test_split` de sklearn** al final de `Supuestos Modelo.ipynb`: quedaba
  colgando sin uso. Se menciona la validación fuera de muestra en la sección 21 como
  criterio de comparación, pero desarrollarla es materia de otra clase.
* **Gráfico 3D interactivo (`plotly.express.scatter_3d`)**: útil y bonito, pero añade
  una dependencia pesada y no se ve al exportar. Sugerido como ejercicio.

---

## 5. Contenido nuevo (no estaba en el material previo)

* **Parte 0 de nivelación** con el vocabulario mínimo y el puente RLS → RLM.
* **Sección 3, "¿qué significa controlar por otras variables?"**, con la demostración
  del teorema de Frisch-Waugh-Lovell y el gráfico de regresión parcial. Es la sección
  que da sentido a todo lo demás.
* **Multicolinealidad y VIF** (sección 15), con la fórmula de la varianza inflada y
  una discusión de por qué los umbrales 5/10 **no** son leyes.
* **La distinción explícita outlier ≠ leverage ≠ influencia** (sección 16), con la
  descomposición de la distancia de Cook y la comparación de cuatro reglas de umbral
  que dan cuatro respuestas distintas.
* **Análisis de sensibilidad formal** (sección 17) y la lista de cinco preguntas que
  hay que responder **antes** de considerar excluir una observación.
* **La tabla de decisión problema → detección → causas → tratamiento** (sección 18) y,
  sobre todo, **el tratamiento efectivamente aplicado**: el modelo log-log
  `log(V) ~ log(G) + log(H)`, cuyos coeficientes salen $1.98$ y $1.12$ —compatibles
  con el $2$ y el $1$ de la geometría de un cono. Ese modelo elimina la curvatura,
  cumple todos los supuestos, reduce el RMSE un 35 % **y hace desaparecer la
  observación influyente**. Es la lección central: *antes de sospechar del dato,
  sospeche del modelo*.
* **Demostración de por qué existe el $R^2$ ajustado** agregando tres columnas de
  ruido puro.
* **Interacciones** (sección 20) como puente a la clase siguiente.
* **Comparación sistemática de M0–M4** con la advertencia de que AIC y $R^2$ no se
  comparan entre modelos con distinta variable respuesta.
* **Tabla de equivalencias R ↔ Python** (sección 22), las 8 diferencias que hay que
  conocer, y la tabla de valores de control.
* **11 ejercicios propuestos, glosario y referencias.**

---

## 6. Nota sobre un detalle del material original

El notebook original ya advertía correctamente que en `trees` *"el diámetro está
erróneamente etiquetado como Circunferencia en los datos"*. Esa advertencia se
conserva y se repite, porque es la clase de detalle que arruina una interpretación
si se pasa por alto: el coeficiente de `Girth` se interpreta **por pulgada de
diámetro**, no de circunferencia.

---

## 7. Requisitos para ejecutar

**R** (≥ 4.1, por el uso del pipe nativo `|>`):

```r
install.packages(c("ggplot2", "dplyr", "broom"))          # imprescindibles
install.packages(c("car", "lmtest", "GGally", "ggfortify"))  # opcionales
```

**Python** (≥ 3.9):

```
pandas  numpy  matplotlib  scipy  statsmodels      # imprescindibles
seaborn                                            # opcional
```

En ambos casos, `trees.csv` debe estar en el mismo directorio que el archivo.
