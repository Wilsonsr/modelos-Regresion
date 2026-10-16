# Regresión y modelos lineales: material de clase

Repositorio del curso de regresión: cuadernillos de Jupyter (Python) y documentos R Markdown, organizados en el orden en que se enseñan.

## Estructura

```
Regresion/
├── datos/                          ← todas las bases (los cuadernillos las leen desde aquí)
├── 01_Regresion_Simple/            ← regresión lineal simple (R Markdown)
├── 02_Regresion_Multiple/          ← modelo de RLM, estimación, pruebas, intervalos
│   └── Clase_RLM/                  ← clase completa en R y Python (base trees)
├── 03_Supuestos_y_Diagnostico/     ← supuestos, residuos, influencia
├── 04_Seleccion_de_Variables/      ← forward, backward, stepwise, best subset  ★ NUEVO
├── 05_ANOVA/                       ← introducción al análisis de varianza      ★ NUEVO
├── 06_Complementos/                ← random forest
└── _archivo/                       ← versiones anteriores (no se usan en clase)
```

## Ruta sugerida

| # | Material | Archivo principal | Base |
|---|---|---|---|
| 1 | Regresión lineal simple | `01_Regresion_Simple/ejemploreglinealsimple.Rmd` | ruido/hipertensión |
| 2 | Regresión lineal múltiple | `02_Regresion_Multiple/Clase_RLM/RLM_Clase.ipynb` (o `.Rmd`) | `trees.csv` |
| 3 | Supuestos y diagnóstico | `03_Supuestos_y_Diagnostico/Supuestos_Modelo.ipynb` | `Advertising.csv`, `Cars93.csv` |
| 4 | **Selección de variables** | `04_Seleccion_de_Variables/04_Seleccion_de_Variables.ipynb` | `boston_house_prices.csv`, `Cars93.csv` |
| 4b | Proyecto completo de RLM (EDA → selección → regularización → validación) | `04_Seleccion_de_Variables/Cuadernillo_Regresion_Lineal_Multiple.ipynb` | configurable |
| 5 | **Introducción a ANOVA** | `05_ANOVA/05_Introduccion_ANOVA.ipynb` | `Cars93.csv` + simulaciones |
| 6 | Complemento: Random Forest | `06_Complementos/Random_Forest_1.ipynb` | — |

### 04 · Selección de variables (cuadernillo nuevo)
Por qué seleccionar (sobreajuste, parsimonia), EDA, división entrenamiento/prueba, modelo completo y diagnóstico (con transformación log), prueba *F* parcial, **forward paso a paso**, backward, stepwise, búsqueda exhaustiva (4096 modelos), selección con validación cruzada (regla 1-EE), comparación de métodos, advertencias (p-valores optimistas, inestabilidad por bootstrap), modelo final con errores robustos y ejercicio con `Cars93`.

### 05 · Introducción a ANOVA (cuadernillo nuevo)
1. Fundamentos (error por familia, variabilidad entre/dentro) · 2. Estructura del modelo (medias de celda, efectos, identificabilidad, funciones estimables, simulación) · 3. Análisis de varianza (SC a mano, tabla, η² y ω²) · 4. Pruebas de hipótesis (supuestos, **simulación de robustez**, Welch, Kruskal-Wallis, Tukey, contrastes, potencia) · 5. Extensiones (dos factores con interacción, SC tipo I/II/III, celdas vacías, bloques, ANCOVA, efectos aleatorios).

## Requisitos (Python)

```bash
pip install pandas numpy matplotlib seaborn statsmodels scikit-learn scipy jupyter
```

Abra Jupyter desde la carpeta del repositorio y ejecute cada cuadernillo de arriba hacia abajo. Los cuadernillos buscan los datos en `../datos/`.

## Notas
- La variable `B` de Boston no se usa como predictor por su codificación racial (ver nota en el cuadernillo 04).
- Las rutas `/work/...` de los cuadernillos exportados de Deepnote se cambiaron por `../datos/...`.
- `Regresion_Lineal_Simple.Rmd` y `ejemploreglinealsimple.Rmd` son casi idénticos; `Clase_RLM/LEEME_Revision.md` documenta las correcciones hechas sobre ellos.
