######################################################################
### Github version of the R code from the JSS manuscript 'Monitoring
### Count Time Series in R: Aberration Detection in Public Health
### Surveillance' (2015) by
### Salmon, Schumacher and Höhle (2015) -- see
### http://arxiv.org/abs/1411.1292 for a preprint of the article.
######################################################################

# Load packages
library("surveillance")
library('RColorBrewer')
library('gamlss')


###################################################

# This code is the one used for the Salmon et al. 2014 JSS article.
# Using this code all examples from the article can be reproduced.
# computeALL is FALSE to avoid the computationally intensive parts
# of the code (use of simulations to find a threshold value for categoricalCUSUM,
# use of boda) but one can set it to TRUE to have it run.
computeALL <- FALSE

###################################################

# Define plot parameters
#Add lines using grid by a hook function. Use NULL to align with tick marks
hookFunc <- function() { grid(NA,NULL,lwd=1) }
cex.text <- 1.7
cex.axis <- cex.text
cex.main <- cex.text
cex.lab <-  cex.text
cex.leg <- cex.text
line.lwd <- 2#1
stsPlotCol <- c("mediumblue","mediumblue","red2")
alarm.symbol <- list(pch=17, col="red2", cex=2,lwd=3)
#Define list with arguments to use with do.call("legend", legOpts)
legOpts <- list(x="topleft",legend=c(expression(U[t])),bty="n",lty=1,lwd=line.lwd,col=alarm.symbol$col,horiz=TRUE,cex=cex.leg)
#How should the par of each plot look?
parOpts <- list(mar=c(6,5,5,5),family="Times")
#Do this once
y.max <- 0
plotOpts <- list(col=stsPlotCol,ylim=c(0,y.max),
                 main='',lwd=c(1,line.lwd,line.lwd),
                 dx.upperbound=0, #otherwise the upperbound line is put 0.5 off
                 cex.lab=cex.lab, cex.axis=cex.axis, cex.main=cex.main,
                 ylab="No. of reports", xlab="Time (weeks)",lty=c(1,1,1),
                 legend.opts=legOpts,alarm.symbol=alarm.symbol,
                 xaxis.tickFreq=list("%V"=atChange,"%m"=atChange,"%G"=atChange),
                 xaxis.labelFreq=list("%Y"=atMedian),
                 xaxis.labelFormat="%Y",
                 par.list=parOpts,hookFunc=hookFunc)

###################################################
# Load data
data("salmNewport")


###################################################
# Plot
y.max <- max(aggregate(salmNewport,by="unit")@observed,na.rm=TRUE)
plotOpts2 <- modifyList(plotOpts,list(x=salmNewport,legend.opts=NULL,ylim=c(0,y.max),type = observed ~ time),keep.null=TRUE)
plotOpts2$xaxis.tickFreq <- list("%m"=atChange,"%G"=atChange)
do.call("plot",plotOpts2)

###################################################

y.max <- max(observed(salmNewport[,2]),observed(salmNewport[,3]),na.rm=TRUE)
plotOpts2 <- modifyList(plotOpts,list(x=salmNewport[,2],legend.opts=NULL,ylim=c(0,y.max)),keep.null=TRUE)
plotOpts2$xaxis.tickFreq <- list("%G"=atChange)
plotOpts2$parOpts <- list(mar=c(6,5,5,0),family="Times")
do.call("plot",plotOpts2)

###################################################

plotOpts2 <- modifyList(plotOpts,list(x=salmNewport[,3],legend.opts=NULL,ylim=c(0,y.max)),keep.null=TRUE)
plotOpts2$xaxis.tickFreq <- list("%G"=atChange)
plotOpts2$parOpts <- list(mar=c(6,5,5,0),family="Times")
do.call("plot",plotOpts2)

###################################################
# Range for the monitoring
in2011 <- which(isoWeekYear(epoch(salmNewport))$ISOYear==2011)
# Aggregate counts over Germany
salmNewportGermany <- aggregate(salmNewport,by="unit")
# Choose parameters
control <- list(range = in2011, method="C1", alpha=0.05)
# Apply earsC function
surv <- earsC(salmNewportGermany, control=control)
# Plot the results
y.max <- max(observed(surv),upperbound(surv),na.rm=TRUE)
do.call("plot",modifyList(plotOpts,list(x=surv,ylim=c(0,y.max)),keep.null=TRUE))

###################################################
# Control slot for the original method
control1 <-  list(range=in2011,noPeriods=1,
                  b=4,w=3,weightsThreshold=1,pastWeeksNotIncluded=3,
                  pThresholdTrend=0.05,thresholdMethod="delta",alpha=0.05,
                  limit54=c(0,50))
# Control slot for the improved method
control2 <- list(range=in2011,noPeriods=10,
                 b=4,w=3,weightsThreshold=2.58,pastWeeksNotIncluded=26,
                 pThresholdTrend=1,thresholdMethod="nbPlugin",alpha=0.05,
                 limit54=c(0,50))

###################################################
library(ggplot2)
library(grid)
# for rectanges
widthRectangles <- 10
library(gridBase)
# dimensions for the ticks
heightTick <- 4
xTicks <- c(15,67,119)
yTicksStart <- rep(0,3)
yTicksEnd <- rep(0,3)
yTicksEnd2 <- rep(-5,3)
textTicks <- c("t-2*p","t-p","t[0]")
xBigTicks <- c(xTicks[1:2]-widthRectangles/2,xTicks[1:2]+widthRectangles/2,xTicks[3]-widthRectangles/2,xTicks[3])
yTicksBigEnd <- rep(0,6)
yTicksBigStart <- rep(heightTick,6)
# to draw the horizontal line
vectorDates <- rep(0,150)
dates <- seq(1:150)
data <- data.frame(dates,vectorDates)
xPeriods <- c(15,67,117,15+26,67+26)
################################################################################
p <- ggplot() +
  # white
  theme(axis.line = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border =element_blank(),
        panel.background =element_blank(),
        axis.line =element_blank(),
        axis.ticks = element_blank(),
        axis.title=element_blank(),
        axis.text=element_blank())+
  geom_segment(aes(x = 0, y = -20, xend = 200, yend = 10), size=2,
               arrow = arrow(length = unit(0.5, "cm")), colour ='white')   +
  # time arrow
  geom_segment(aes(x = 0, y = 0, xend = 150, yend = 0), size=1,
               arrow = arrow(length = unit(0.5, "cm")))   +
  # ticks
  geom_segment(aes(x = xTicks, y = yTicksEnd2, xend = xTicks, yend = yTicksStart ), arrow = arrow(length = unit(0.3, "cm")),size=1)+
  # big ticks
  geom_segment(aes(x = xBigTicks, y = yTicksBigStart, xend = xBigTicks, yend = yTicksBigEnd*2), size=1)+
  # time label
  annotate("text", label = "Time", x = 170, y = 0, size = 8, colour = "black",
           family="serif") +
  # ticks labels
  annotate('text',label=c("t[0]-2*freq","t[0]-freq","t[0]"),x = xTicks,
           y = yTicksEnd - 10, size = 8,family="serif",parse=T)
p+
  # periods labels

  annotate('text',label=c("A","A","A","B","B"),x = xPeriods,
           y = rep(6,5), size = 8,family="serif",parse=T)


###################################################

yTicksBigEnd2 <- rep(0,4)
yTicksBigStart2 <- rep(heightTick,4)
newX <- c(xTicks[1:2]+widthRectangles/2+52-widthRectangles,xTicks[1:2]+52/2)
xPeriods <- c(15,67,117,15+16,67+16,15+35,67+35)
p + geom_segment(aes(x = newX, y = yTicksBigStart2, xend = newX, yend = yTicksBigEnd2), size=1)+
  # periods labels

  annotate('text',label=c("A","A","A","B","B","C","C"),x = xPeriods,
           y = rep(6,7), size = 8,family="serif",parse=T)


###################################################

salm.farrington <- farringtonFlexible(salmNewportGermany, control1)
salm.noufaily <- farringtonFlexible(salmNewportGermany, control2)


###################################################

# Plot
y.max <- max(observed(salm.farrington),upperbound(salm.farrington),observed(salm.noufaily),upperbound(salm.noufaily),na.rm=TRUE)
do.call("plot",modifyList(plotOpts,list(x=salm.farrington,ylim=c(0,y.max))))
# Plot
y.max <- max(observed(salm.farrington),upperbound(salm.farrington),observed(salm.noufaily),upperbound(salm.noufaily),na.rm=TRUE)
do.call("plot",modifyList(plotOpts,list(x=salm.noufaily,ylim=c(0,y.max))))

###################################################
# Load data and create \code{sts}-object
data("campyDE")
cam.sts <- new("sts",epoch=as.numeric(campyDE$date),
               observed=campyDE$case,
               state=campyDE$state, epochAsDate=TRUE)
par(las=1)
# Plot
y.max <- max(observed(cam.sts),upperbound(cam.sts),na.rm=TRUE)
plotOpts3 <- modifyList(plotOpts,list(x=cam.sts,ylab="",legend.opts=NULL,ylim=c(0,y.max),type = observed ~ time),keep.null=TRUE)
plotOpts3$xaxis.tickFreq <- list("%m"=atChange,"%G"=atChange)
plotOpts3$parOpts <- list(mar=c(6,5,5,5),family="Times")
do.call("plot",plotOpts3)
par(las=0)
#mtext(side=2,text="No. of reports",
# las=0,line=3, cex=cex.text,family="Times")
par(family="Times")
text(-20, 2600, "No. of\n reports", pos = 3, xpd = T,cex=cex.text)
text(510, 2900, "Absolute humidity", pos = 3, xpd = T,cex=cex.text)
text(510, 2550, expression(paste("[",g/m^3,"]", sep='')), pos = 3, xpd = T,cex=cex.text)
lines(campyDE$hum*50, col="white", lwd=2)
axis(side=4, at=seq(0,2500,by=500),labels=seq(0,50,by=10),las=1,cex.lab=cex.text, cex=cex.text,cex.axis=cex.text,pos=length(epoch(cam.sts))+20)
#mtext(side=4,text=expression(paste("Absolute humidity [ ",g/m^3,"]", sep='')),
# las=0,line=1, cex=cex.text,family="Times")
###################################################

rangeBoda <- which(epoch(cam.sts)>=as.Date("2007-01-01"))

if (computeALL) {
  control.boda <- list(range=rangeBoda, X=NULL, trend=TRUE,
                       season=TRUE, prior='rw1', alpha=0.025,
                       mc.munu=10000, mc.y=1000)
  # boda without covariates: trend + spline + periodic spline
  boda <- boda(cam.sts, control=control.boda)
  save(file="boda.RData", list=c("boda"))
} else {
  load("boda.RData")
}
###################################################
if (computeALL) {
  # boda with covariates: trend + spline + lagged hum + indicator variables
  covarNames <- c(paste("l",1:4,".hum",sep=""),"newyears","christmas",
                  "O104period")
  control.boda2 <- modifyList(control.boda,
                              list(X=campyDE[,covarNames],season=FALSE))
  boda.covars <- boda(cam.sts, control=control.boda2)
  save(file="boda.covars.RData",list=c("boda.covars"))
} else {
  load("boda.covars.RData")
}
###################################################
# Plot with special function
y.max <- max(observed(boda.covars),upperbound(boda.covars),na.rm=TRUE)
plotOpts2 <- modifyList(plotOpts,list(x=boda.covars,ylim=c(0,y.max)),keep.null=TRUE)
plotOpts2$xaxis.tickFreq <- list("%m"=atChange,"%G"=atChange)
do.call("plot",plotOpts2)


###################################################
### code chunk number 17: bPlot
###################################################
# Plot with special function
y.max <- max(observed(boda.covars),upperbound(boda.covars),na.rm=TRUE)
plotOpts2 <- modifyList(plotOpts,list(x=boda.covars,ylim=c(0,y.max)),keep.null=TRUE)
plotOpts2$xaxis.tickFreq <- list("%m"=atChange,"%G"=atChange)
do.call("plot",plotOpts2)

###################################################
control.far <- list(range=rangeBoda,b=4,w=5,alpha=0.025*2)
far <- farrington(cam.sts,control=control.far)
#Both farringtonFlexible and algo.bayes uses a one-sided interval just as boda.
control.far2 <-modifyList(control.far,list(alpha=0.025))
farflex <- farringtonFlexible(cam.sts,control=control.far2)
bayes <- bayes(cam.sts,control=control.far2)

###################################################
# Small helper function to combine several equally long univariate sts objects
combineSTS <- function(stsList) {
  epoch <- as.numeric(epoch(stsList[[1]]))
  observed <- NULL
  alarm <- NULL
  for (i in 1:length(stsList)) {
    observed <- cbind(observed,observed(stsList[[i]]))
    alarm <- cbind(alarm,alarms(stsList[[i]]))
  }
  colnames(observed) <- colnames(alarm) <- names(stsList)
  res <- new("sts", epoch=as.numeric(epoch),
             observed=observed, alarm=alarm,epochAsDate=TRUE)
  return(res)
}

###################################################
# Make an artifical object containing two columns - one with the boda output
# and one with the farrington output

cam.surv <- combineSTS(list(boda.covars=boda.covars,boda=boda,bayes=bayes,
                            farrington=far,farringtonFlexible=farflex))
par(mar=c(4,8,2.1,2),family="Times")
plot(cam.surv,type = alarm ~ time,lvl=rep(1,ncol(cam.surv)),
     alarm.symbol=list(pch=17, col="red2", cex=1,lwd=3),
     cex.axis=1,xlab="Time (weeks)",cex.lab=1,xaxis.tickFreq=list("%m"=atChange,"%G"=atChange),xaxis.labelFreq=list("%G"=at2ndChange),
     xaxis.labelFormat="%G")

###################################################
# Define phase1 (reference values) and phase2 (monitoring)
phase1 <- which(isoWeekYear(epoch(salmNewportGermany))$ISOYear<2011)
phase2 <- in2011
# Choose the options for monitoring
control=list(range=phase2,mu0=list(
  S=1,
  trend=TRUE,
  refit=FALSE),c.ARL = 4,
             theta=log(2),ret="cases")
# Perform monitoring with glrnb
salmGlrnb <- glrnb(salmNewportGermany,control=control)

###################################################
# Plot
y.max <- max(observed(salmGlrnb),upperbound(salmGlrnb),na.rm=TRUE)
do.call("plot",modifyList(plotOpts,list(x=salmGlrnb,ylim=c(0,y.max))))


###################################################
# Load data
data("salmHospitalized")
# Define reference data and data under monitoring
phase1 <- which(isoWeekYear(epoch(salmHospitalized))$ISOYear<2013)
phase2 <- c(which(isoWeekYear(epoch(salmHospitalized))$ISOYear==2013),
            which(isoWeekYear(epoch(salmHospitalized))$ISOYear==2014
                  &isoWeekYear(epoch(salmHospitalized))$ISOWeek<=4))
# Prepare data for fitting the model
weekNumber <-  isoWeekYear(epoch(salmHospitalized))$ISOWeek
salmHospitalized.df <- cbind(as.data.frame(salmHospitalized),weekNumber)
colnames(salmHospitalized.df) <- c("y","t","state","alarm","n","freq",
                                   "epochInPeriod","weekNumber")


###################################################
vars <- c( "y", "n", "t", "epochInPeriod", "weekNumber")
m.bbin <- gamlss(cbind(y, n-y) ~ 1 + t
                 + sin(2 * pi * epochInPeriod) + cos(2 * pi * epochInPeriod)
                 + sin(4 * pi * epochInPeriod) + cos(4 * pi * epochInPeriod)
                 + I(weekNumber == 1) + I(weekNumber == 2),
                 sigma.formula =~ 1,
                 family = BB(sigma.link = "log"),
                 data = salmHospitalized.df[phase1, vars])


###################################################
# CUSUM parameters
R <- 2 #detect a doubling of the odds for a salmHospitalized being positive
h <- 2 #threshold of the cusum
# Compute \textit{in-control} and out of control mean
pi0 <- predict(m.bbin,newdata=salmHospitalized.df[phase2,vars],
               type="response")
pi1 <- plogis(qlogis(pi0) + log(R))
# Create matrix with in control and out of control proportions.
# Categories are D=1 and D=0, where the latter is the reference category
pi0m <- rbind(pi0, 1-pi0)
pi1m <- rbind(pi1, 1-pi1)

###################################################
# Create the \code{sts}-object with the counts for the 2 categories
population <- population(salmHospitalized)
observed <- observed(salmHospitalized)
salmHospitalized.multi <- new("sts", freq=52, start=c(2004,1),
                              epoch = as.numeric(epoch(salmHospitalized)),
                              epochAsDate=TRUE,
                              observed = cbind(observed,
                                               population-observed),
                              populationFrac = cbind(population,
                                                     population),
                              state=matrix(0, nrow=nrow(salmHospitalized),
                                           ncol = 2),
                              multinomialTS=TRUE)


###################################################
# Function to use as dfun in the categoricalCUSUM
dBB.cusum <- function(y, mu, sigma, size, log = FALSE) {
  return(dBB( if (is.matrix(y)) y[1,] else y, if (is.matrix(y)) mu[1,] else mu,
              sigma = sigma, bd = size, log = log))
}


###################################################
# Monitoring
controlCat <- list(range = phase2,h = 2,pi0 = pi0m, pi1 = pi1m, ret = "cases",
                   dfun = dBB.cusum)
salmHospitalizedCat <- categoricalCUSUM(salmHospitalized.multi,
                                        control = controlCat,
                                        sigma = exp(m.bbin$sigma.coef))


###################################################
y.max <- max(observed(salmHospitalized)/population(salmHospitalized),upperbound(salmHospitalized)/population(salmHospitalized),na.rm=TRUE)
plotOpts2 <- modifyList(plotOpts,list(x=salmHospitalized,legend.opts=NULL,ylab="",ylim=c(0,y.max)),keep.null=TRUE)
plotOpts2$xaxis.tickFreq <- list("%G"=atChange,"%m"=atChange)
plotOpts2$par.list <- list(mar=c(6,5,5,5),family="Times",las=1)
do.call("plot",plotOpts2)
lines(salmHospitalized@populationFrac/4000,col="grey80",lwd=2)
lines(campyDE$hum*50, col="white", lwd=2)
axis(side=4, at=seq(0,2000,by=500)/4000,labels=as.character(seq(0,2000,by=500)),las=1, cex=2,cex.axis=1.5,pos=length(observed(salmHospitalized))+20)
par(family="Times")
text(-20, 0.6, "Proportion", pos = 3, xpd = T,cex=cex.text)
text(520, 0.6, "Total number of \n reported cases", pos = 3, xpd = T,cex=cex.text)

###################################################
y.max <- max(observed(salmHospitalized)/population(salmHospitalized),upperbound(salmHospitalized)/population(salmHospitalized),na.rm=TRUE)
plotOpts2 <- modifyList(plotOpts,list(x=salmHospitalized,legend.opts=NULL,ylab="",ylim=c(0,y.max)),keep.null=TRUE)
plotOpts2$xaxis.tickFreq <- list("%G"=atChange,"%m"=atChange)
plotOpts2$par.list <- list(mar=c(6,5,5,5),family="Times",las=1)
do.call("plot",plotOpts2)
lines(salmHospitalized@populationFrac/4000,col="grey80",lwd=2)
lines(campyDE$hum*50, col="white", lwd=2)
axis(side=4, at=seq(0,2000,by=500)/4000,labels=as.character(seq(0,2000,by=500)),las=1, cex=2,cex.axis=1.5,pos=length(observed(salmHospitalized))+20)
par(family="Times")
text(-20, 0.6, "Proportion", pos = 3, xpd = T,cex=cex.text)
text(520, 0.6, "Total number of \n reported cases", pos = 3, xpd = T,cex=cex.text)

###################################################
# Values of the threshold to be investigated
h.grid <- seq(1,10,by=0.5)

# Prepare function for simulations
simone <- function(sts, h) {
  # Draw observed values from the \textit{in-control} distribution
  y <- rBB(length(phase2), mu=pi0m[1,,drop=FALSE],
           bd=population(sts)[phase2,],
           sigma=exp(m.bbin$sigma.coef))
  observed(sts)[phase2,] <- cbind(y,sts@populationFrac[phase2,1] - y)
  # Perform monitoring
  one.surv <- categoricalCUSUM(sts, control=modifyList(controlCat, list(h=h)),
                               sigma=exp(m.bbin$sigma.coef))
  # Return 1 if there was at least one alarm
  return(any(alarms(one.surv)[,1]))
}
# Set random seed for reproducibility
set.seed(123)
if (computeALL) {
  # Number of simulations
  nSims=1000
  # Simulations over the possible h values
  pMC <- sapply(h.grid, function(h) {
    h <- h
    mean(replicate(nSims, simone(salmHospitalized.multi,h)))
  })
  # Distribution function to be used by LRCUSUM.runlength
  dBB.rl <- function(y, mu, sigma, size, log = FALSE) {
    dBB(y, mu = mu, sigma = sigma, bd = size, log = log)
  }
  # Markov Chain approximation over h.grid
  pMarkovChain <- sapply( h.grid, function(h) {
    TA <- LRCUSUM.runlength(mu=pi0m[1,,drop=FALSE], mu0=pi0m[1,,drop=FALSE],
                            mu1=pi1m[1,,drop=FALSE],
                            n=population(salmHospitalized.multi)[phase2,],
                            h=h, dfun=dBB.rl, sigma=exp(m.bbin$sigma.coef))
    return(tail(TA$cdf,n=1))
  })
  save(file="MarkovChain.RData",list=c("pMC.RData", "pMarkovChain.RData"))
} else {
  load("MarkovChain.RData")
}


###################################################

y.max <- max(observed(salmHospitalizedCat[,1])/population(salmHospitalizedCat[,1]),upperbound(salmHospitalizedCat[,1])/population(salmHospitalizedCat[,1]),na.rm=TRUE)
plotOpts3 <- modifyList(plotOpts,list(x=salmHospitalizedCat[,1],ylab="Proportion",ylim=c(0,y.max)))
plotOpts3$legend.opts <- list(x="top",bty="n",legend=c(expression(U[t])),lty=1,lwd=line.lwd,col=alarm.symbol$col,horiz=TRUE,cex=cex.leg)
do.call("plot",plotOpts3)

###################################################

par(mar=c(6,5,5,5),family="Times")
matplot(h.grid, cbind(pMC,pMarkovChain),type="l",ylab=expression(P(T[A] <= 56 * "|" * tau * "=" * infinity)),xlab="Threshold h",col=1,cex=cex.text,
        cex.axis =cex.text,cex.lab=cex.text)
prob <- 0.1
lines(range(h.grid),rep(prob,2),lty=5,lwd=2)
axis(2,at=prob,las=1,cex.axis=0.7,labels=FALSE)
par(family="Times")
legend(4,0.08,c("Monte Carlo","Markov chain"), lty=1:2,col=1,cex=cex.text,bty="n")

###################################################

# data("rotaBB")
data("rotaBB")


###################################################
par(mar=c(5.1,20.1,4.1,0),family="Times")
plot(rotaBB,xlab="Time (months)",ylab="",
     col="mediumblue",cex=cex.text,cex.lab=cex.text,cex.axis=cex.text,cex.main=cex.text,
     xaxis.tickFreq=list("%G"=atChange),
     xaxis.labelFreq=list("%G"=at2ndChange),
     xaxis.labelFormat="%G")
par(las=0,family="Times")
mtext("Proportion of reported cases", side=2, line=19, cex=1)

###################################################
# Select a palette for drawing
pal <- brewer.pal("Set1",n=ncol(rotaBB))

# Show time series of monthly proportions (matplot does not work with dates)
plotTS <- function(prop=TRUE) {
  for (i in 1:ncol(rotaBB)) {
    fun <- if (i==1) plot else lines
    if (!prop) {
      fun(epoch(rotaBB),observed(rotaBB)[,i],type="l",xlab="Time (months)",ylab="Reported cases",ylim=c(0,max(observed(rotaBB))),col=pal[i],lwd=2)
    } else {
      fun(epoch(rotaBB),observed(rotaBB)[,i,drop=FALSE]/rowSums(observed(rotaBB)),type="l",xlab="Time (months)",ylab="Proportion of reported cases",ylim=c(0,max(observed(rotaBB)/rowSums(observed(rotaBB)))),col=pal[i],lwd=2)
    }
  }
  # Add legend
  axis(1,at=as.numeric(epoch(rotaBB)),label=NA,tck=-0.01)
  legend(x="left",colnames(rotaBB),col=pal,lty=1,lwd=2,bg="white")
}

###################################################
# Convert sts object to data.frame useful for regression modelling
rotaBB.df <- as.data.frame(rotaBB)

# Create matrix
X <- with(rotaBB.df,cbind(intercept=1,epoch,
                          sin1=sin(2*pi*epochInPeriod),cos1=cos(2*pi*epochInPeriod)))

# Fit model to 2002-2009 data
phase1 <- epoch(rotaBB) < as.Date("2009-01-01")
phase2 <- !phase1

# MGLMreg automatically takes the last class as ref so we reorder
order <- c(2:5, 1); reorder <- c(5, 1:4)

# Fit multinomial logit model (i.e. dist="MN") to phase1 data
library("MGLM")
m0 <- MGLMreg(as.matrix(rotaBB.df[phase1,order])~ -1 + X[phase1,], dist="MN")

###################################################
# Set threshold and option object
h <- 2

###################################################
m1 <- m0
# Out-of control model: shift in all intercept coeffs
m1$coefficients[1,] <- m0$coefficients[1,] + log(2)
# Proportion over time for phase2 based on fitted model (re-order back)
pi0 <- t(predict(m0, newdata=X[phase2,])[,reorder])
pi1 <-  t(predict(m1, newdata=X[phase2,])[,reorder])

###################################################
dfun <- function(y, size, mu, log = FALSE) {
  return(dmultinom(x = y, size = size, prob = mu, log = log))
}

control <- list(range = seq(nrow(rotaBB))[phase2], h = h, pi0 = pi0,
                pi1 = pi1, ret = "value", dfun = dfun)
surv <- categoricalCUSUM(rotaBB,control=control)

###################################################
#Number of MC samples
nSamples <- 1e4

#Do MC
simone.stop <- function(sts, control) {
  phase2Times <- seq(nrow(sts))[phase2]
  #Generate new phase2 data from the fitted in control model
  y <- sapply(1:length(phase2Times), function(i) {
    rmultinom(n=1, prob=pi0[,i],size=population(sts)[phase2Times[i],1])
  })
  observed(sts)[phase2Times,] <- t(y)
  one.surv <- categoricalCUSUM(sts, control=control)
  #compute P(S<=length(phase2))
  return(any(alarms(one.surv)[,1]>0))
}

if (computeALL) {
  set.seed(1233)
  rlMN <- replicate(nSamples, simone.stop(rotaBB, control=control))
  save(file="../Data/rlsims-multinom.RData", list=c("rlMN"))
} else {
  load(file="rlsims-multinom.RData")
}
mean(rlMN)

###################################################
alarmDates <- epoch(surv)[which(alarms(surv)[,1]==1)]
format(alarmDates,"%b %Y")

###################################################
m0.dm <- MGLMreg(as.matrix(rotaBB.df[phase1, 1:5]) ~ -1 + X[phase1, ],
                 dist = "DM")

c(m0$AIC, m0.dm$AIC)

###################################################
# Change intercept in the first class (for DM all 5 classes are modeled)
delta <- 2
m1.dm <- m0.dm
m1.dm$coefficients[1,] <- m0.dm$coefficients[1,] +
  c(-delta,rep(delta/4,4))
# Calculate the alphas of the multinomial-Dirichlet in the two cases
alpha0 <- exp(X[phase2,] %*% m0.dm$coefficients)
alpha1 <- exp(X[phase2,] %*% m1.dm$coefficients)

# Use alpha vector as mu magnitude
# (not possible to compute it from mu and size)
dfun <- function(y, size, mu, log=FALSE) {
  dLog <- ddirm(t(y), t(mu))
  if (log) { return(dLog) } else {return(exp(dLog))}
}

# Threshold
h <- 2
control <- list(range=seq(nrow(rotaBB))[phase2],h=h,pi0=t(alpha0),
                pi1=t(alpha1), ret="value",dfun=dfun)
surv.dm <- categoricalCUSUM(rotaBB,control=control)

###################################################
surv@observed[,1] <- 0
surv@multinomialTS <- FALSE
surv.dm@observed[,1] <- 0
surv.dm@multinomialTS <- FALSE
y.max <- max(observed(surv.dm[,1]),upperbound(surv.dm[,1]),observed(surv[,1]),upperbound(surv[,1]),na.rm=TRUE)
plotOpts3 <- modifyList(plotOpts,list(x=surv[,1],ylim=c(0,y.max),ylab=expression(C[t]),xlab=""))
plotOpts3$legend.opts <- list(x="topleft",bty="n",legend="R",lty=1,lwd=line.lwd,col=alarm.symbol$col,horiz=TRUE,cex=cex.leg)
do.call("plot",plotOpts3)
lines( c(0,1e99), rep(h,2),lwd=2,col="darkgray",lty=1)
par(family="Times")
mtext(side=1,text="Time (weeks)",
      las=0,line=3, cex=cex.text)

###################################################
plotOpts3 <- modifyList(plotOpts,list(x=surv.dm[,1],ylim=c(0,y.max),ylab=expression(C[t]),xlab=""))
plotOpts3$legend.opts <- list(x="topleft",bty="n",legend="R",lty=1,lwd=line.lwd,col=alarm.symbol$col,horiz=TRUE,cex=cex.leg)
y.max <- max(observed(surv.dm[,1]),upperbound(surv.dm[,1]),observed(surv[,1]),upperbound(surv[,1]),na.rm=TRUE)
do.call("plot",plotOpts3)
lines( c(0,1e99), rep(h,2),lwd=2,col="darkgray",lty=1)
par(family="Times")
mtext(side=1,text="Time (weeks)",
      las=0,line=3, cex=cex.text)


###################################################
# In this example the sts-object already exists.
# Supply the code with the date of a Monday and look for the
# corresponding index in the sts-object
today <- which(epoch(salmNewport)==as.Date("2013-12-23"))
# The analysis will be performed for the given week
# and the 4 previous ones
range <- (today-4):today
in2013 <- which(isoWeekYear(epoch(salmNewport))$ISOYear==2013)
# Control argument for using the improved method
control2 <- list(range=range,noPeriods=10,populationBool=FALSE,
                 b=4,w=3,weightsThreshold=2.58,pastWeeksNotIncluded=26,
                 pThresholdTrend=1,thresholdMethod="nbPlugin",alpha=0.05,
                 limit54=c(0,50))
# Run farringtonFlexible
results <- farringtonFlexible(salmNewport[,c("Baden.Wuerttemberg",
                                             "North.Rhine.Westphalia")],
                              control=control2)
# Export the results as a tex table
start <- isoWeekYear(epoch(salmNewport)[range(range)[1]])
end <- isoWeekYear(epoch(salmNewport)[range(range)[2]])
caption <- paste("Results of the analysis of reported S. Newport
                 counts in two German federal states for the weeks W-",
                 start$ISOWeek," ",start$ISOYear," - W-",end$ISOWeek,
                 " ",end$ISOYear," performed on ",Sys.Date(),
                 ". Bold upperbounds (thresholds) indicate weeks with alarms.",
                 sep="")
toLatex(results, table.placement="h", size = "normalsize",
        sanitize.text.function = identity,
        NA.string = "-",include.rownames=FALSE,
        columnLabels = c("Year","Week","Baden-Wuerttemberg","Threshold","North-Rhine-Westphalen","Threshold"),
        alarmPrefix = "\\textbf{\\textcolor{red}{",
        alarmSuffix = "}}",
        caption=caption,label="tableResults")

