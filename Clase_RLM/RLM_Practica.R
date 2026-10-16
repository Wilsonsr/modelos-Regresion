# =============================================================================
#  REGRESIÓN LINEAL MÚLTIPLE — SCRIPT DE PRÁCTICA
#  Wilson Sandoval R.
#
#  Código esencial de la clase, en el mismo orden del documento RLM_Clase.Rmd.
#  El archivo trees.csv debe estar en el MISMO directorio que este script.
#  (En RStudio: Session > Set Working Directory > To Source File Location)
#
#  Secuencia:  PREGUNTA -> DATOS -> MODELO -> RESULTADOS -> DIAGNÓSTICO -> DECISIÓN
# =============================================================================

## -----------------------------------------------------------------------------
## 0. PAQUETES
## -----------------------------------------------------------------------------
# Imprescindibles: ninguno (todo el script corre con R base).
# Opcionales: car (vif, avPlots) y lmtest (bptest, dwtest). Si no están
# instalados, el script usa las versiones programadas a mano más abajo.

hay <- function(p) requireNamespace(p, quietly = TRUE)
c(car = hay("car"), lmtest = hay("lmtest"), ggplot2 = hay("ggplot2"))
# install.packages(c("car", "lmtest"))   # descomentar solo si hace falta


## -----------------------------------------------------------------------------
## 1. DATOS
##    Pregunta: ¿podemos explicar/predecir el volumen de un árbol usando
##    simultáneamente su diámetro (Girth) y su altura (Height)?
## -----------------------------------------------------------------------------

trees <- read.csv("trees.csv")
if (names(trees)[1] %in% c("X", "X.1", "")) trees <- trees[, -1]  # quitar índice del CSV

str(trees)
dim(trees)
summary(trees)
colSums(is.na(trees))          # sin valores faltantes

# Girth = DIÁMETRO en pulgadas (el nombre original del dataset está mal puesto)
# Height = altura en pies ; Volume = volumen de madera en pies cúbicos


## -----------------------------------------------------------------------------
## 2. EXPLORACIÓN
## -----------------------------------------------------------------------------

round(cor(trees), 4)
#        Girth  Height  Volume
# Girth  1.000   0.519   0.967   <- Volume-Girth muy fuerte
# Height 0.519   1.000   0.598   <- Volume-Height moderada
# Volume 0.967   0.598   1.000   <- OJO: Girth y Height están correlacionadas
#                                   ENTRE SÍ (0.519). Ese es el motivo por el
#                                   que los coeficientes parciales importan.

pairs(trees, pch = 19, col = "steelblue4", main = "Matriz de dispersión")

par(mfrow = c(1, 3))
for (v in names(trees)) hist(trees[[v]], main = v, xlab = v, col = "steelblue", border = "white")
for (v in names(trees)) boxplot(trees[[v]], main = v, col = "steelblue")
par(mfrow = c(1, 1))
# Volume es asimétrica a la derecha y hay un árbol muy grande (77 pies3).


## -----------------------------------------------------------------------------
## 3. MÍNIMOS CUADRADOS "A MANO": qué hace lm()
##    beta_hat = (X'X)^{-1} X'y
## -----------------------------------------------------------------------------

y <- trees$Volume
X <- cbind(Intercepto = 1, Girth = trees$Girth, Height = trees$Height)

XtX     <- t(X) %*% X
XtX_inv <- solve(XtX)
Xty     <- t(X) %*% y
beta_hat <- XtX_inv %*% Xty
beta_hat

modelo <- lm(Volume ~ Girth + Height, data = trees)
cbind(manual = as.vector(beta_hat), lm = coef(modelo))     # coinciden

# Matriz sombrero H = X(X'X)^-1 X' ; su diagonal son los leverages
H <- X %*% XtX_inv %*% t(X)
round(head(diag(H)), 4)


## -----------------------------------------------------------------------------
## 4. AJUSTE E INTERPRETACIÓN
## -----------------------------------------------------------------------------

summary(modelo)
confint(modelo, level = 0.95)

# Volume_hat = -57.988 + 4.708*Girth + 0.339*Height
#
# Girth  = 4.708 : entre árboles DE LA MISMA ALTURA, una pulgada más de diámetro
#                  son en promedio 4.71 pies3 más de volumen.  IC95 [4.17, 5.25]
# Height = 0.339 : entre árboles DEL MISMO DIÁMETRO, un pie más de altura son en
#                  promedio 0.34 pies3 más de volumen.          IC95 [0.07, 0.61]
# Intercepto     : SIN interpretación práctica (árbol de diámetro y altura 0).
# sigma  = 3.882 : error típico del modelo, en pies cúbicos.


## -----------------------------------------------------------------------------
## 5. EFECTO PARCIAL: qué significa "controlando por las demás"
## -----------------------------------------------------------------------------

m_simple <- lm(Volume ~ Girth, data = trees)

c(simple   = coef(m_simple)["Girth"],       # 5.066
  multiple = coef(modelo)["Girth"])         # 4.708
# La diferencia (0.358) es la parte del "efecto" del diámetro que en realidad
# era altura disfrazada, porque los árboles gruesos tienden a ser altos.

# Demostración (teorema de Frisch-Waugh-Lovell):
girth_res  <- residuals(lm(Girth  ~ Height, data = trees))
volume_res <- residuals(lm(Volume ~ Height, data = trees))
coef(lm(volume_res ~ girth_res))["girth_res"]        # = 4.708, idéntico

plot(girth_res, volume_res, pch = 19, col = "steelblue",
     main = "Regresión parcial: Girth | Height",
     xlab = "Girth ajustado por Height", ylab = "Volume ajustado por Height")
abline(lm(volume_res ~ girth_res), col = "firebrick", lwd = 2)
abline(h = 0, v = 0, lty = 3, col = "grey50")


## -----------------------------------------------------------------------------
## 6. SIGNIFICANCIA GLOBAL (prueba F) Y TABLA ANOVA
##    H0: beta_Girth = beta_Height = 0   vs   H1: al menos uno != 0
## -----------------------------------------------------------------------------

n <- nrow(trees); k <- 2; p <- k + 1

SCT <- sum((trees$Volume - mean(trees$Volume))^2)
SCR <- sum((fitted(modelo) - mean(trees$Volume))^2)
SCE <- sum(residuals(modelo)^2)

data.frame(
  Fuente = c("Regresión", "Error", "Total"),
  SC = c(SCR, SCE, SCT),
  gl = c(k, n - p, n - 1),
  CM = c(SCR/k, SCE/(n - p), NA),
  F  = c((SCR/k)/(SCE/(n - p)), NA, NA),
  p  = c(pf((SCR/k)/(SCE/(n - p)), k, n - p, lower.tail = FALSE), NA, NA)
)
# F = 254.97 con 2 y 28 gl, p ~ 1e-18

anova(modelo)                                  # OJO: sumas de cuadrados SECUENCIALES
anova(lm(Volume ~ 1, data = trees), modelo)    # prueba F global explícita

# La F global y las t individuales responden preguntas DISTINTAS:
#   F: ¿aporta algo el conjunto?
#   t: ¿aporta algo ESTA variable que las otras no aporten ya?
# Con 1 gl en el numerador, F = t^2:
anova(lm(Volume ~ Girth, data = trees), modelo)
summary(modelo)$coefficients["Height", "t value"]^2


## -----------------------------------------------------------------------------
## 7. CALIDAD DEL AJUSTE: R2 vs R2 AJUSTADO
## -----------------------------------------------------------------------------

c(R2 = summary(modelo)$r.squared, R2_aj = summary(modelo)$adj.r.squared)

# R2 NUNCA baja al agregar predictoras, aunque sean ruido puro:
set.seed(2026)
t_ruido <- trees
t_ruido$b1 <- rnorm(n); t_ruido$b2 <- rnorm(n); t_ruido$b3 <- rnorm(n)
m_ruido <- lm(Volume ~ Girth + Height + b1 + b2 + b3, data = t_ruido)

rbind(original = c(R2 = summary(modelo)$r.squared,  R2_aj = summary(modelo)$adj.r.squared),
      con_ruido = c(R2 = summary(m_ruido)$r.squared, R2_aj = summary(m_ruido)$adj.r.squared))
# R2 sube (0.9480 -> 0.9494) pero R2 ajustado BAJA (0.9442 -> 0.9393).


## -----------------------------------------------------------------------------
## 8. PREDICCIÓN: intervalo de confianza vs intervalo de predicción
## -----------------------------------------------------------------------------

nuevos <- data.frame(Girth = c(11.0, 13.2, 16.0), Height = c(70, 76, 82))

predict(modelo, nuevos)                                        # puntual
predict(modelo, nuevos, interval = "confidence", level = 0.95) # MEDIA de todos
predict(modelo, nuevos, interval = "prediction", level = 0.95) # UN árbol nuevo

# El intervalo de PREDICCIÓN es mucho más ancho porque además de la
# incertidumbre en beta carga la variabilidad propia del individuo (sigma^2),
# que no desaparece aunque tuviéramos infinitos datos.
# Si preguntan "cuánta madera saco de ESTE árbol", la respuesta es el IP.

# No extrapolar: Girth en [8.3, 20.6], Height en [63, 87], y solo en
# combinaciones plausibles de AMBAS.


## =============================================================================
## ---------------------------  D I A G N Ó S T I C O  -------------------------
## =============================================================================

## -----------------------------------------------------------------------------
## 9. TABLA DE RESIDUOS Y MEDIDAS DE INFLUENCIA
## -----------------------------------------------------------------------------

diagnostico <- data.frame(
  obs             = 1:n,
  Girth           = trees$Girth,
  Height          = trees$Height,
  observado       = trees$Volume,
  estimado        = round(fitted(modelo), 3),
  residual        = round(residuals(modelo), 3),   # e_i = y_i - y_hat_i
  r_estandarizado = round(rstandard(modelo), 3),   # studentizado INTERNAMENTE
  r_studentizado  = round(rstudent(modelo), 3),    # studentizado EXTERNAMENTE
  leverage        = round(hatvalues(modelo), 4),   # h_ii
  cook            = round(cooks.distance(modelo), 4)
)
diagnostico

umbral_h    <- 2 * p / n        # 0.1935
umbral_cook <- 4 / (n - p)      # 0.1429

subset(diagnostico,
       abs(r_studentizado) > 2 | leverage > umbral_h | cook > umbral_cook)
# Obs. 2, 3, 18, 20 y 31. La 31 aparece en las TRES listas.


## -----------------------------------------------------------------------------
## 10. LINEALIDAD
##     Qué esperamos ver: nube sin forma alrededor de cero.
## -----------------------------------------------------------------------------

par(mfrow = c(1, 3))
plot(fitted(modelo), rstudent(modelo), pch = 19, col = "steelblue",
     xlab = "Ajustados", ylab = "Residuo studentizado", main = "vs. ajustados")
abline(h = 0); abline(h = c(-2, 2), lty = 2, col = "red")
lines(lowess(fitted(modelo), rstudent(modelo)), col = "darkorange", lwd = 2)

plot(trees$Girth, rstudent(modelo), pch = 19, col = "steelblue",
     xlab = "Girth", ylab = "", main = "vs. Girth")
abline(h = 0); abline(h = c(-2, 2), lty = 2, col = "red")
lines(lowess(trees$Girth, rstudent(modelo)), col = "darkorange", lwd = 2)

plot(trees$Height, rstudent(modelo), pch = 19, col = "steelblue",
     xlab = "Height", ylab = "", main = "vs. Height")
abline(h = 0); abline(h = c(-2, 2), lty = 2, col = "red")
lines(lowess(trees$Height, rstudent(modelo)), col = "darkorange", lwd = 2)
par(mfrow = c(1, 1))

# HAY CURVATURA EN U. No es ruido: es una señal de que falta estructura.

if (hay("car")) car::avPlots(modelo, pch = 19, col = "steelblue")   # gráficos parciales


## -----------------------------------------------------------------------------
## 11. NORMALIDAD DE LOS RESIDUOS
##     H0: los residuos son compatibles con la normalidad
## -----------------------------------------------------------------------------

r_stud <- rstudent(modelo)

par(mfrow = c(1, 2))
hist(r_stud, breaks = 8, freq = FALSE, col = "steelblue", border = "white",
     main = "Densidad de los residuos", xlab = "Residuo studentizado")
lines(density(r_stud), lwd = 2, col = "darkorange")
curve(dnorm(x), add = TRUE, lwd = 2, lty = 2, col = "firebrick")
legend("topright", c("Residuos", "N(0,1)"), lty = c(1, 2),
       col = c("darkorange", "firebrick"), bty = "n", cex = .8)

qqnorm(r_stud, pch = 19, col = "steelblue"); qqline(r_stud, col = "firebrick", lwd = 2)
par(mfrow = c(1, 1))

shapiro.test(r_stud)     # W = 0.9732, p = 0.6122 -> sin evidencia contra normalidad

# ADVERTENCIAS:
#  - El p-valor no sustituye al gráfico (el Q-Q muestra la obs. 31; el test no).
#  - Con n grande los tests rechazan por desviaciones triviales.
#  - La normalidad NO es requisito para "poder hacer regresión": se necesita
#    para que las pruebas t/F y los intervalos sean exactos en muestras pequeñas.


## -----------------------------------------------------------------------------
## 12. HOMOCEDASTICIDAD
##     H0: varianza constante
## -----------------------------------------------------------------------------

par(mfrow = c(1, 2))
plot(fitted(modelo), rstudent(modelo), pch = 19, col = "steelblue",
     xlab = "Ajustados", ylab = "Residuo studentizado", main = "Residuos vs. ajustados")
abline(h = 0); abline(h = c(-2, 2), lty = 2, col = "red")
plot(fitted(modelo), sqrt(abs(rstandard(modelo))), pch = 19, col = "steelblue",
     xlab = "Ajustados", ylab = "sqrt(|r|)", main = "Scale-Location")
lines(lowess(fitted(modelo), sqrt(abs(rstandard(modelo)))), col = "darkorange", lwd = 2)
par(mfrow = c(1, 1))

if (hay("lmtest")) {
  print(lmtest::bptest(modelo))
} else {
  aux <- lm(residuals(modelo)^2 ~ Girth + Height, data = trees)
  LM  <- n * summary(aux)$r.squared
  cat("Breusch-Pagan (Koenker) LM =", round(LM, 4),
      " p =", round(pchisq(LM, k, lower.tail = FALSE), 4), "\n")
}
# BP = 2.468, gl = 2, p = 0.291 -> no se rechaza la homocedasticidad.
# (Con n = 31 la prueba tiene poca potencia: "no rechazar" no es "confirmar".)


## -----------------------------------------------------------------------------
## 13. INDEPENDENCIA — y por qué aquí NO se debe interpretar
## -----------------------------------------------------------------------------

if (hay("lmtest")) print(lmtest::dwtest(modelo))

e <- residuals(modelo)
dw <- function(e) sum(diff(e)^2) / sum(e^2)
dw(e)                                    # 1.2665

# Durbin-Watson DEPENDE DEL ORDEN DE LAS FILAS. En trees el archivo está
# ordenado por Girth, y ese orden no tiene significado sustantivo. Demostración:
set.seed(99)
m_barajado <- lm(Volume ~ Girth + Height, data = trees[sample(n), ])
c(orden_original = dw(e), orden_aleatorio = dw(residuals(m_barajado)))
# 1.27 vs 2.03: mismo modelo, estadístico totalmente distinto.
#
# Aplique DW solo si puede responder: "¿qué significa que la observación i
# venga antes que la i+1?". En series de tiempo, medidas repetidas o datos
# secuenciales, sí. En un corte transversal de árboles talados, no.


## -----------------------------------------------------------------------------
## 14. MULTICOLINEALIDAD
##     VIF_j = 1/(1 - R2_j), donde R2_j es el R2 de regresar X_j contra las demás
## -----------------------------------------------------------------------------

if (hay("car")) {
  print(car::vif(modelo))
} else {
  print(sapply(c("Girth", "Height"), function(v) {
    otras <- setdiff(c("Girth", "Height"), v)
    1 / (1 - summary(lm(reformulate(otras, response = v), data = trees))$r.squared)
  }))
}

r_gh <- cor(trees$Girth, trees$Height)
c(r = r_gh, VIF = 1/(1 - r_gh^2))        # 1.369 -> sin problema

# Cómo leerlo: sqrt(VIF) es cuántas veces más ancho es el ERROR ESTÁNDAR.
# sqrt(1.369) = 1.17 -> 17% más ancho: irrelevante.
# Los umbrales 5 o 10 son orientación, NO leyes. El VIF se lee junto al error
# estándar y junto al objetivo del modelo (predecir vs. interpretar).


## -----------------------------------------------------------------------------
## 15. OUTLIER != LEVERAGE != INFLUENCIA
## -----------------------------------------------------------------------------

par(mfrow = c(1, 3))
plot(rstudent(modelo), pch = 19, col = "steelblue", ylim = c(-3.5, 3.5),
     main = "Outliers en la respuesta", xlab = "Índice", ylab = "r studentizado")
abline(h = 0); abline(h = c(-2, 2), lty = 2, col = "red")

plot(hatvalues(modelo), pch = 19, col = "steelblue",
     main = "Leverage (h)", xlab = "Índice", ylab = "h")
abline(h = umbral_h, lty = 2, col = "red")

plot(cooks.distance(modelo), type = "h", lwd = 2, col = "steelblue",
     main = "Distancia de Cook", xlab = "Índice", ylab = "D")
abline(h = umbral_cook, lty = 2, col = "red")
par(mfrow = c(1, 1))

plot(modelo, which = 5, pch = 19, col = "steelblue")   # Residuals vs Leverage

# D_i = (r_i^2 / p) * h_ii/(1 - h_ii)  ->  influencia = residuo x leverage
#
# Obs. 20: leverage alto (0.211) pero residuo pequeño -> LEVERAGE SIN INFLUENCIA
#          (árbol grueso y bajo, pero bien predicho).
# Obs. 31: h = 0.227 (el mayor), r* = 2.77 (el mayor), D = 0.605 (3x el segundo).
#          ESTE es el caso serio.

# Las reglas de referencia NO coinciden entre sí:
sapply(c("4/(n-p)" = 4/(n-p), "4/n" = 4/n, "D>1" = 1,
         "3*media" = 3*mean(cooks.distance(modelo))),
       function(u) paste(which(cooks.distance(modelo) > u), collapse = ", "))
# Informativa no es la regla sino la SEPARACIÓN: la 31 está sola muy arriba.


## -----------------------------------------------------------------------------
## 16. ANÁLISIS DE SENSIBILIDAD
##     La pregunta no es "¿hay influyentes?" sino "¿cambia mi conclusión?"
## -----------------------------------------------------------------------------

modelo_sin31 <- lm(Volume ~ Girth + Height, data = trees[-31, ])

resumen <- function(m) c(
  Girth = coef(m)[2], ee_G = summary(m)$coefficients[2, 2],
  Height = coef(m)[3], ee_H = summary(m)$coefficients[3, 2],
  p_Height = summary(m)$coefficients[3, 4],
  R2_aj = summary(m)$adj.r.squared, sigma = summary(m)$sigma)

round(rbind(con_obs31 = resumen(modelo), sin_obs31 = resumen(modelo_sin31)), 4)

data.frame(nuevos,
           con_31 = round(predict(modelo, nuevos), 3),
           sin_31 = round(predict(modelo_sin31, nuevos), 3))

# ¿Cambió la conclusión? NO. Girth pasa de 4.708 a 4.478 (dentro del IC95
# original), Height sigue significativa, las predicciones se mueven < 2 pies3.
# => SE CONSERVA la observación 31.
#
# NUNCA eliminar automáticamente por Cook/leverage/residuo alto. Investigar:
#   1. ¿error de digitación?      -> corregir
#   2. ¿error de medición?        -> documentar
#   3. ¿caso válido excepcional?  -> CONSERVAR  (este es el caso)
#   4. ¿otra población?           -> separar el análisis
#   5. ¿el MODELO es insuficiente? -> ver el paso siguiente
# Y si se excluye algo: reportarlo, con y sin.


## -----------------------------------------------------------------------------
## 17. TRATAMIENTO DE LA NO LINEALIDAD
##     Un árbol es aproximadamente un cono: V ~ d^2 * h  (MULTIPLICATIVO)
##     log(V) = c + 2*log(d) + 1*log(h)                  (LINEAL en logs)
## -----------------------------------------------------------------------------

modelo_log <- lm(log(Volume) ~ log(Girth) + log(Height), data = trees)
summary(modelo_log)
confint(modelo_log)

# log(Girth)  = 1.983  IC95 [1.83, 2.14]  -> contiene 2  (teoría: 2)
# log(Height) = 1.117  IC95 [0.70, 1.54]  -> contiene 1  (teoría: 1)
# Los datos RECUPERAN la geometría del sólido.

par(mfrow = c(2, 2)); plot(modelo_log, pch = 19, col = "steelblue"); par(mfrow = c(1, 1))

shapiro.test(rstudent(modelo_log))                     # p = 0.278
if (hay("lmtest")) print(lmtest::bptest(modelo_log))   # p = 0.256
c(cook_max = max(cooks.distance(modelo_log)),
  obs = which.max(cooks.distance(modelo_log)))         # 0.224 en la obs. 18

# LA CURVATURA DESAPARECIÓ y el punto influyente dejó de serlo.
# La obs. 31 no era un dato malo: era el dato que delataba que el MODELO
# estaba mal especificado. ANTES DE SOSPECHAR DEL DATO, SOSPECHE DEL MODELO.

# Comparación en la ESCALA ORIGINAL (lo único justo entre estos dos modelos;
# NO comparar sus R2, porque la variable respuesta es distinta):
pred_lin <- fitted(modelo)
pred_log <- exp(fitted(modelo_log))
c(RMSE_lineal = sqrt(mean((trees$Volume - pred_lin)^2)),
  RMSE_loglog = sqrt(mean((trees$Volume - pred_log)^2)))     # 3.69 vs 2.42

# Interpretación log-log = ELASTICIDAD:
# 1% más de diámetro (a igual altura) -> 1.98% más de volumen.


## -----------------------------------------------------------------------------
## 18. VARIABLES CATEGÓRICAS
## -----------------------------------------------------------------------------

viviendas <- data.frame(
  Precio  = c(105, 112, 134, 137, 141, 164, 166, 176, 175, 191, 190, 200, 245, 227, 270),
  Area    = c( 60,  72,  85,  78,  95, 102,  88, 110, 125, 105, 130, 140, 148, 160, 170),
  Piscina = c("Sin","Sin","Sin","Pequena","Sin","Pequena","Grande","Pequena",
              "Sin","Grande","Pequena","Sin","Grande","Pequena","Grande")
)
viviendas$Piscina <- factor(viviendas$Piscina, levels = c("Sin", "Pequena", "Grande"))

# MAL: codificar 1, 2, 3 impone que las categorías están ordenadas y que los
#      saltos son IGUALES. Son supuestos del analista, no de los datos.
viviendas$Cod <- as.numeric(viviendas$Piscina)
m_malo  <- lm(Precio ~ Area + Cod,     data = viviendas)

# BIEN: R crea las variables dummy automáticamente a partir del factor.
m_bueno <- lm(Precio ~ Area + Piscina, data = viviendas)

rbind(codificacion_123 = c(sigma = summary(m_malo)$sigma,  R2_aj = summary(m_malo)$adj.r.squared),
      dummies          = c(sigma = summary(m_bueno)$sigma, R2_aj = summary(m_bueno)$adj.r.squared))
# 5.38 vs 4.01: forzar saltos iguales CUESTA ajuste.

head(model.matrix(m_bueno))     # la matriz de diseño con las dummies
summary(m_bueno)

# Precio_hat = 31.22 + 1.178*Area + 10.94*[Pequena] + 36.30*[Grande]
#  - El nivel "Sin" es la REFERENCIA y queda absorbido en el intercepto.
#  - Cada coeficiente es una DIFERENCIA respecto a la referencia, a igual Área.
#  - 36.30 != 2*10.94 : los saltos NO son iguales (por eso la codificación 1-2-3
#    era incorrecta).
#  - Geométricamente: tres rectas PARALELAS.

# Cambiar la referencia NO cambia el modelo, solo con quién se compara:
m_ref <- lm(Precio ~ Area + relevel(Piscina, ref = "Grande"), data = viviendas)
c(R2_original = summary(m_bueno)$r.squared, R2_nueva_ref = summary(m_ref)$r.squared)

# Para preguntar "¿importa la piscina?" NO se miran las t individuales:
anova(lm(Precio ~ Area, data = viviendas), m_bueno)     # F = 85.2, p < 0.001


## -----------------------------------------------------------------------------
## 19. INTERACCIONES (introducción)
##     Y = b0 + b1*X1 + b2*X2 + b3*X1*X2  ->  el efecto de X1 depende de X2
## -----------------------------------------------------------------------------

modelo_inter <- lm(Volume ~ Girth * Height, data = trees)
summary(modelo_inter)

b <- coef(modelo_inter)
data.frame(Height = c(65, 76, 87),
           efecto_de_Girth = round(b["Girth"] + b["Girth:Height"] * c(65, 76, 87), 3))
# En un árbol de 65 pies una pulgada más vale ~2.9 pies3; en uno de 87, ~5.9.

# Advertencias:
#  - Si se incluye X1:X2 hay que mantener X1 y X2 (principio de jerarquía).
#  - Con interacción, el coeficiente de Girth ya NO es "el efecto de Girth":
#    es el efecto cuando Height = 0. Centrar devuelve la interpretabilidad.
#  - El modelo log-log capturaba la misma idea de forma más limpia.


## -----------------------------------------------------------------------------
## 20. COMPARACIÓN DE MODELOS Y DECISIÓN
## -----------------------------------------------------------------------------

M0 <- lm(Volume ~ 1,              data = trees)
M1 <- lm(Volume ~ Girth,          data = trees)
M2 <- lm(Volume ~ Height,         data = trees)
M3 <- lm(Volume ~ Girth + Height, data = trees)
M4 <- lm(log(Volume) ~ log(Girth) + log(Height), data = trees)

rmse <- function(pred) sqrt(mean((trees$Volume - pred)^2))

data.frame(
  modelo = c("M0: ~1", "M1: ~Girth", "M2: ~Height", "M3: ~Girth+Height", "M4: log-log"),
  R2     = round(sapply(list(M0,M1,M2,M3,M4), function(m) summary(m)$r.squared), 4),
  R2_aj  = round(sapply(list(M0,M1,M2,M3,M4), function(m) summary(m)$adj.r.squared), 4),
  sigma  = round(sapply(list(M0,M1,M2,M3,M4), function(m) summary(m)$sigma), 4),
  AIC    = round(sapply(list(M0,M1,M2,M3,M4), AIC), 2),
  RMSE   = round(c(rmse(fitted(M0)), rmse(fitted(M1)), rmse(fitted(M2)),
                   rmse(fitted(M3)), rmse(exp(fitted(M4)))), 4)
)

anova(M0, M1, M3)    # modelos anidados

# NO elegir por el R2 más alto. Pesan igual o más:
#  1. ¿Se cumplen los supuestos?  (un modelo con residuos curvados se equivoca
#     SISTEMÁTICAMENTE; eso no lo arregla tener más datos)
#  2. ¿Tienen sentido los coeficientes?
#  3. ¿Para qué es el modelo? (predecir -> RMSE; entender -> interpretabilidad)
#  4. ¿Es parsimonioso?
#  5. AIC/BIC solo comparan modelos con LA MISMA variable respuesta.
#
# DECISIÓN: M4 (log-log). Mejor RMSE en la escala original, supuestos cumplidos,
# sin puntos influyentes, y coeficientes que recuperan la geometría del problema.

# -----------------------------------------------------------------------------
sessionInfo()
# =============================================================================
