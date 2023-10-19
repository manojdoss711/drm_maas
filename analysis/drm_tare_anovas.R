setwd("~/Dropbox/TARE/drm/analysis")
options(contrasts=c("contr.sum","contr.poly"))
library(ez)
library(lsr)
library(car)
library(heplots)
library(BayesFactor)
library(ggplot2)

#Upload
drm_all_rates <- read.csv("drm_TARE_all_rates.csv")
drm_corr_rates <- read.csv("drm_TARE_corr_rates.csv")

# drop subjects
drm_all_rates <- subset(drm_all_rates,subject != "TARE8") # drop s8
drm_corr_rates <- subset(drm_corr_rates,subject != "TARE8") # drop s8
# # caffeine at encoding subjects
# drm_all_rates <- subset(drm_all_rates,subject != "TARE1")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE15")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE17")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE18")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE4")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE6")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE7")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE9")
# # caffeine at retrieval subjects
# drm_all_rates <- subset(drm_all_rates,subject != "TARE1")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE15")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE17")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE6")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE7")
# drm_all_rates <- subset(drm_all_rates,subject != "TARE9")

drm_all_fa_rates <- subset(drm_all_rates,item_cond == "crit_lure" | item_cond == "unrel_lure")

t.test(subset(subset(drm_all_rates,drug_cond == "placebo"),item_cond == "target")$p.yes,subset(subset(drm_all_rates,drug_cond == "drug"),item_cond == "target")$p.yes,alternative = "two.sided",paired=T)
cohensD(subset(subset(drm_all_rates,drug_cond == "placebo"),item_cond == "target")$p.yes,subset(subset(drm_all_rates,drug_cond == "drug"),item_cond == "target")$p.yes,method = "paired")

ezANOVAResult<-ezANOVA(drm_all_rates, dv = p.yes, wid = subject, within = .(drug_cond,item_cond), detailed = T)
ezANOVAResult
ezANOVAResult$ANOVA$SSn/(ezANOVAResult$ANOVA$SSn+ezANOVAResult$ANOVA$SSd)

ezANOVAResult<-ezANOVA(drm_all_fa_rates, dv = p.yes, wid = subject, within = .(drug_cond,item_cond), detailed = T)
ezANOVAResult
ezANOVAResult$ANOVA$SSn/(ezANOVAResult$ANOVA$SSn+ezANOVAResult$ANOVA$SSd)

t.test(subset(subset(drm_corr_rates,drug_cond == "placebo"),item_cond == "corr_hit_rate")$p.yes,subset(subset(drm_corr_rates,drug_cond == "drug"),item_cond == "corr_hit_rate")$p.yes,alternative = "two.sided",paired=T)
cohensD(subset(subset(drm_corr_rates,drug_cond == "placebo"),item_cond == "corr_hit_rate")$p.yes,subset(subset(drm_corr_rates,drug_cond == "drug"),item_cond == "corr_hit_rate")$p.yes,method = "paired")

t.test(subset(subset(drm_corr_rates,drug_cond == "placebo"),item_cond == "corr_fa_rate")$p.yes,subset(subset(drm_corr_rates,drug_cond == "drug"),item_cond == "corr_fa_rate")$p.yes,alternative = "two.sided",paired=T)
cohensD(subset(subset(drm_corr_rates,drug_cond == "placebo"),item_cond == "corr_fa_rate")$p.yes,subset(subset(drm_corr_rates,drug_cond == "drug"),item_cond == "corr_fa_rate")$p.yes,method = "paired")

ezANOVAResult<-ezANOVA(drm_corr_rates, dv = p.yes, wid = subject, within = .(drug_cond,item_cond), detailed = T)
ezANOVAResult
ezANOVAResult$ANOVA$SSn/(ezANOVAResult$ANOVA$SSn+ezANOVAResult$ANOVA$SSd)

mean_rates<-matrix(c(
  mean(subset(subset(drm_all_rates,drug_cond == "placebo"),item_cond == "target")$p.yes),
  mean(subset(subset(drm_all_rates,drug_cond == "placebo"),item_cond == "crit_lure")$p.yes),
  mean(subset(subset(drm_all_rates,drug_cond == "placebo"),item_cond == "unrel_lure")$p.yes),
  mean(subset(subset(drm_all_rates,drug_cond == "drug"),item_cond == "target")$p.yes),
  mean(subset(subset(drm_all_rates,drug_cond == "drug"),item_cond == "crit_lure")$p.yes),
  mean(subset(subset(drm_all_rates,drug_cond == "drug"),item_cond == "unrel_lure")$p.yes)),
  nrow=2,ncol=3,byrow=T)

sem<-matrix(c(
  sd(subset(subset(drm_all_rates,drug_cond == "placebo"),item_cond == "target")$p.yes)/sqrt(23),
  sd(subset(subset(drm_all_rates,drug_cond == "placebo"),item_cond == "crit_lure")$p.yes)/sqrt(23),
  sd(subset(subset(drm_all_rates,drug_cond == "placebo"),item_cond == "unrel_lure")$p.yes)/sqrt(23),
  sd(subset(subset(drm_all_rates,drug_cond == "drug"),item_cond == "target")$p.yes)/sqrt(23),
  sd(subset(subset(drm_all_rates,drug_cond == "drug"),item_cond == "crit_lure")$p.yes)/sqrt(23),
  sd(subset(subset(drm_all_rates,drug_cond == "drug"),item_cond == "unrel_lure")$p.yes)/sqrt(23)),
  nrow=2,ncol=3,byrow=T)

mean_rates<-matrix(c(
  mean(subset(subset(drm_corr_rates,drug_cond == "placebo"),item_cond == "corr_hit_rate")$p.yes),
  mean(subset(subset(drm_corr_rates,drug_cond == "placebo"),item_cond == "corr_fa_rate")$p.yes),
  mean(subset(subset(drm_corr_rates,drug_cond == "drug"),item_cond == "corr_hit_rate")$p.yes),
  mean(subset(subset(drm_corr_rates,drug_cond == "drug"),item_cond == "corr_fa_rate")$p.yes)),
  nrow=2,ncol=2,byrow=T)

sem<-matrix(c(
  sd(subset(subset(drm_corr_rates,drug_cond == "placebo"),item_cond == "corr_hit_rate")$p.yes)/sqrt(23),
  sd(subset(subset(drm_corr_rates,drug_cond == "placebo"),item_cond == "corr_fa_rate")$p.yes)/sqrt(23),
  sd(subset(subset(drm_corr_rates,drug_cond == "drug"),item_cond == "corr_hit_rate")$p.yes)/sqrt(23),
  sd(subset(subset(drm_corr_rates,drug_cond == "drug"),item_cond == "corr_fa_rate")$p.yes)/sqrt(23)),
  nrow=2,ncol=2,byrow=T)

# Sex differences
ezANOVAResult<-ezANOVA(subset(drm_all_rates,item_cond == "target"), dv = p.yes, wid = subject, within = drug_cond, between = sex, type = 3, detailed = T)
ezANOVAResult
ezANOVAResult$ANOVA$SSn/(ezANOVAResult$ANOVA$SSn+ezANOVAResult$ANOVA$SSd)

ezANOVAResult<-ezANOVA(drm_all_fa_rates, dv = p.yes, wid = subject, within = .(drug_cond,item_cond), between = sex, type = 3, detailed = T)
ezANOVAResult
ezANOVAResult$ANOVA$SSn/(ezANOVAResult$ANOVA$SSn+ezANOVAResult$ANOVA$SSd)

ezANOVAResult<-ezANOVA(subset(drm_corr_rates,item_cond == "corr_hit_rate"), dv = p.yes, wid = subject, within = drug_cond, between = sex, type = 3, detailed = T)
ezANOVAResult
ezANOVAResult$ANOVA$SSn/(ezANOVAResult$ANOVA$SSn+ezANOVAResult$ANOVA$SSd)

ezANOVAResult<-ezANOVA(subset(drm_corr_rates,item_cond == "corr_fa_rate"), dv = p.yes, wid = subject, within = drug_cond, between = sex, type = 3, detailed = T)
ezANOVAResult
ezANOVAResult$ANOVA$SSn/(ezANOVAResult$ANOVA$SSn+ezANOVAResult$ANOVA$SSd)

t.test(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "placebo"),item_cond == "crit_lure")$p.yes,subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "drug"),item_cond == "crit_lure")$p.yes,alternative = "two.sided",paired=T)
cohensD(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "placebo"),item_cond == "crit_lure")$p.yes,subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "drug"),item_cond == "crit_lure")$p.yes,method = "paired")

t.test(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "placebo"),item_cond == "unrel_lure")$p.yes,subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "drug"),item_cond == "unrel_lure")$p.yes,alternative = "two.sided",paired=T)
cohensD(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "placebo"),item_cond == "unrel_lure")$p.yes,subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "drug"),item_cond == "unrel_lure")$p.yes,method = "paired")

t.test(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "placebo"),item_cond == "crit_lure")$p.yes,subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "drug"),item_cond == "crit_lure")$p.yes,alternative = "two.sided",paired=T)
cohensD(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "placebo"),item_cond == "crit_lure")$p.yes,subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "drug"),item_cond == "crit_lure")$p.yes,method = "paired")

t.test(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "placebo"),item_cond == "unrel_lure")$p.yes,subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "drug"),item_cond == "unrel_lure")$p.yes,alternative = "two.sided",paired=T)
cohensD(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "placebo"),item_cond == "unrel_lure")$p.yes,subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "drug"),item_cond == "unrel_lure")$p.yes,method = "paired")

mean_rates<-matrix(c(
  mean(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "placebo"),item_cond == "target")$p.yes),
  mean(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "placebo"),item_cond == "crit_lure")$p.yes),
  mean(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "placebo"),item_cond == "unrel_lure")$p.yes),
  mean(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "drug"),item_cond == "target")$p.yes),
  mean(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "drug"),item_cond == "crit_lure")$p.yes),
  mean(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "drug"),item_cond == "unrel_lure")$p.yes)),
  nrow=2,ncol=3,byrow=T)

sem<-matrix(c(
  sd(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "placebo"),item_cond == "target")$p.yes)/sqrt(12),
  sd(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "placebo"),item_cond == "crit_lure")$p.yes)/sqrt(12),
  sd(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "placebo"),item_cond == "unrel_lure")$p.yes)/sqrt(12),
  sd(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "drug"),item_cond == "target")$p.yes)/sqrt(12),
  sd(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "drug"),item_cond == "crit_lure")$p.yes)/sqrt(12),
  sd(subset(subset(subset(drm_all_rates,sex == "female"),drug_cond == "drug"),item_cond == "unrel_lure")$p.yes)/sqrt(12)),
  nrow=2,ncol=3,byrow=T)

mean_rates<-matrix(c(
  mean(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "placebo"),item_cond == "target")$p.yes),
  mean(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "placebo"),item_cond == "crit_lure")$p.yes),
  mean(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "placebo"),item_cond == "unrel_lure")$p.yes),
  mean(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "drug"),item_cond == "target")$p.yes),
  mean(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "drug"),item_cond == "crit_lure")$p.yes),
  mean(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "drug"),item_cond == "unrel_lure")$p.yes)),
  nrow=2,ncol=3,byrow=T)

sem<-matrix(c(
  sd(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "placebo"),item_cond == "target")$p.yes)/sqrt(11),
  sd(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "placebo"),item_cond == "crit_lure")$p.yes)/sqrt(11),
  sd(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "placebo"),item_cond == "unrel_lure")$p.yes)/sqrt(11),
  sd(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "drug"),item_cond == "target")$p.yes)/sqrt(11),
  sd(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "drug"),item_cond == "crit_lure")$p.yes)/sqrt(11),
  sd(subset(subset(subset(drm_all_rates,sex == "male"),drug_cond == "drug"),item_cond == "unrel_lure")$p.yes)/sqrt(11)),
  nrow=2,ncol=3,byrow=T)



