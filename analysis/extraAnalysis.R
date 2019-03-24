
(aov_cont<- aov(commitmentData$Score ~ factor(commitmentData$KeyLength)))
ls(aov_cont)
summary(aov_cont)
confint(aov_cont, level = 0.9)
summary.lm(aov_cont)
plot(aov_cont)
outlierTest(aov_cont)

# perform Tukey test
(tuk<- TukeyHSD(aov_cont, conf.level = 0.95))
plot(tuk)

lmo <- lm(commitmentData$Score ~ commitmentData$KeyLength)
summary(lmo)
coef(lmo)
confint(lmo, level = 0.9)
anova(lmo)
plot(lmo)
outlierTest(lmo)

# discard outliers 
commitmentData$Score<-ifelse(commitmentData$Score==outlier(commitmentData$Score),NA,commitmentData$Score)
commitmentData

influence.measures(lmo)

ares <- aov(commitmentData$Score ~ factor(commitmentData$KeyLength), data = commitmentData)
TukeyHSD(ares)
plot(TukeyHSD(ares), las=0)
summary(ares)

kruskal.test(commitmentData$Score ~ commitmentData$KeyLength, commitmentData)

barplot(commitmentData$Score)

meansg <- aggregate(commitmentData$Score, by=list(commitmentData$KeyLength), FUN=mean)
meansg
barplot(meansg$x, names.arg=meansg$Group.1,main="Means bar plot", xlab="Key Length", ylab="Mean",          col=c("red", "yellow","green", "blue"))

plot(commitmentData$KeyLength)

res <- HSD.test(ares, 'commitmentData$KeyLength')
res
plot(res)

posthoc <- TukeyHSD(x=aov_cont, factor(commitmentData$KeyLength), conf.level=0.95)
plot(posthoc)

leveneTest(commitmentData$Score ~ factor(commitmentData$KeyLength), commitmentData)

(mean(commitmentData$Score, na.rm=TRUE))
(sd(commitmentData$Score, na.rm=TRUE))


# calculate quantiles
quantile(commitmentData$Score)
t.test(commitmentData$Score, mu=95)
pairwise.t.test(commitmentData$Score, commitmentData$KeyLength)

glimpse(commitmentData)

(totalMean <- mean(commitmentData$Score, na.rm=TRUE))