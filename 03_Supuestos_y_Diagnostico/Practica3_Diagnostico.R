library(MASS)
library(carData)
library(car)
data("trees")
?trees
attach(trees)

modelo <- lm(Volume~Girth+Height, data=trees)
summary(modelo)


### Residuales ordinarios 
trees$ordinarios=residuals(modelo)

### Residuales estandarizados (estudentizados internamente)
trees$estandarizados=rstandard(modelo)

### Residuales estudentizados (externamente)
trees$estudentizados=rstudent(modelo)

### Valores h
trees$h=hatvalues(modelo)

View(trees)
attach(trees)
k=2
n=31
umbral=2*(k+1)/n

# Graficos de residuales contra los valores estimados

plot(fitted.values(modelo),estudentizados)
plot(Girth,estudentizados)
plot(Height,estudentizados)

#Histograma
x<-seq(-4,4,length=100)
y<-dnorm(x)
plot(density(estudentizados),main="Densidad Residuales",xlab="",ylab="",lwd=2)
lines(x,y,lwd=2,col=gray.colors(1,start=0.3),lty=2)
leyenda<-c("Dens. Residuales","Dens. Normal Est?ndar")
legend(-3.8, 0.45, leyenda,col=c(1,gray.colors(1,start=0.3)),lty=c(1,2),lwd=3,bty="n")

#qqPlot
qqPlot(estudentizados,pch=20)

#Prueba de normalidad donde H0:Normalidad
shapiro.test(estudentizados)

#Homocedasticidad
## Prueba de Breusch-Pagan. H0:Homocedaticidad (Varianza constante)
library(lmtest)
bptest(modelo)

#Independencia
## Prueba de Durbin-Watson
dwtest(modelo)

plot(fitted.values(modelo),estudentizados)

## Diagn?stico de residuales

# Observaciones de alto leverage.

Leverage.normal <- function(objeto){
  y <- objeto$residuals + fitted(objeto)
  H <- lm.influence(objeto)$hat
  X <- model.matrix(objeto)
  maxy <- max(max(H),2*mean(H))
  plot(H, main="Puntos de alto Leverage", xlab="?ndice", ylim=c(0,maxy), ylab="h", cex=0.3, lwd=3)
  abline(2*mean(H),0,col=2,lty=3)
  alto.leverage=ifelse(H>2*mean(H),TRUE,FALSE)
  identificador=1:length(y)
  identificador[alto.leverage]
}
Leverage=Leverage.normal(modelo)
trees[Leverage,]

# Observaciones extremas en la respuesta
Residuos.normal <- function(objeto){
  y <- objeto$residuals + fitted(objeto)
  r <- rstudent(objeto)
  maxy <- max(max(r),3)
  miny <- min(min(r),-3)
  plot(fitted(objeto), r, main="Observaciones extremas en la respuesta", xlab="Media estimada", ylab="Residuo estudentizado", cex=0.3, lwd=3, ylim=c(miny,maxy))
  abline(2,0,col=2,lty=3)
  abline(0,0,lty=3)
  abline(-2,0,col=2,lty=3)
  extremo.respuesta=ifelse(abs(r)>2,TRUE,FALSE)
  identificador=1:length(y)
  identificador[extremo.respuesta]
}
Extremos=Residuos.normal(modelo)
trees[Extremos,]

# Observaciones influyentes
Influyentes.normal <- function(objeto){
  y <- objeto$residuals + fitted(objeto)
  n <- length(y)
  h <- lm.influence(objeto)$hat
  p <- ncol(model.matrix(objeto))
  s <- sqrt(deviance(objeto)/(n-p))
  ti <- objeto$residuals/(s*sqrt(1-h))
  DC <- (ti^2/p) * h/(1-h)
  maxy <- max(max(DC),3*mean(DC))
  plot(DC, main="Observaciones influyentes", xlab="?ndice", ylim=c(0,maxy), ylab="Distancia de Cook", cex=0.3, lwd=3)
  abline(3*mean(DC),0,col=2,lty=3)
  infl.glob=ifelse(DC>3*mean(DC),TRUE,FALSE)
  identificador=1:length(y)
  identificador[infl.glob]
}
Global=Influyentes.normal(modelo)
trees[Global,]

modelo_new=lm(Volume~Girth+Height, data=trees[-31,])
summary(modelo_new)
summary(modelo)

