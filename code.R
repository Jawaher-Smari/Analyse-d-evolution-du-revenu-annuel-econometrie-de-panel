library(plm)
library(lmtest)
library(car)
library(readxl)
library(dplyr)
library(gplots)
library(ggplot2)
library(tidyr)
library(GGally)
library(scales)
library(psych)
library(texreg)

theme_panel <- theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 13, hjust = 0.5),
    plot.subtitle = element_text(color = "grey40", hjust = 0.5, size = 10),
    axis.title    = element_text(size = 10),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

df <- read_excel("C:\\Users\\LENOVO\\Downloads\\Projet_R\\Base 1_oui.xlsx")

colnames(df) <- c("entreprise", "annee", "RG", "ADS", "DAQ",
                  "OI", "CFP", "DTS", "LSI", "RC")


cat("  Dimensions     :", nrow(df), "×", ncol(df), "\n")
cat("  Individus (N)  :", length(unique(df$entreprise)), "\n")
cat("  Périodes   (T) :", paste(sort(unique(df$annee)), collapse = " | "), "\n")
cat("  Manquants      :", sum(is.na(df)), "\n\n")

cat("Statistiques descriptives")
print(describe(df))

cor_matrix <- cor(df, method = "pearson")
print(cor_matrix)


N <- length(unique(df$entreprise))
print(N)
T <- length(unique(df$annee))
print(T)

df_means_time <- df %>%
  group_by(annee) %>%
  summarise(
    moyenne = mean(RG, na.rm = TRUE),
    ic_low  = mean(RG) - qt(0.975, N - 1) * sd(RG) / sqrt(N),
    ic_high = mean(RG) + qt(0.975, N - 1) * sd(RG) / sqrt(N)
  )

ggplot(df_means_time, aes(x = annee, y = moyenne)) +
  geom_line(linewidth = 1, color = "darkorange") +
  geom_point(size = 3, color = "darkorange") +
  geom_ribbon(aes(ymin = ic_low, ymax = ic_high),
              alpha = 0.2, fill = "darkorange") +
  geom_hline(yintercept = mean(df$RG), linetype = "dashed",
             color = "grey40") +
  labs(
    title    = "Hétérogénéité temporelle : moyenne de RG par année",
    subtitle = paste0(
      "Ruban = IC 95 %. ",
      "Une tendance marquée suggère des effets temporels à tester"),
    x = "Année", y = "RG moyen"
  ) +
  theme_panel

df_means_entreprise <- df %>%
  group_by(entreprise) %>%
  summarise(
    moyenne = mean(RG, na.rm = TRUE),
    ic_low  = mean(RG) - qt(0.975, N-1) * sd(RG) / sqrt(N),
    ic_high = mean(RG) + qt(0.975, N-1) * sd(RG) / sqrt(N)
  )

ggplot(df_means_entreprise, aes(x = entreprise, y = moyenne)) +
  geom_line(linewidth = 1, color = "darkorange") +
  geom_point(size = 3, color = "darkorange") +
  geom_ribbon(aes(ymin = ic_low, ymax = ic_high),
              alpha = 0.2, fill = "darkorange") +
  geom_hline(yintercept = mean(df$RG),
             linetype = "dashed", color = "grey40") +
  labs(
    title    = "Heterogeneite Individuelle",
    subtitle = "Tendance croissante commune : +0,358 log-pts sur 2017-2022",
    x = "Annee", y = "log(Revenu) moyen"
  ) + theme_panel

panel <- pdata.frame(df, index = c("entreprise", "annee"))

formule <- RG ~ ADS + DAQ + OI + CFP + DTS + LSI + RC

m_pooled <- plm(formule, data = panel, model = "pooling")
print(summary(m_pooled))

m_within <- plm(formule, data = panel, model = "within")
print(summary(m_within))

print(round(fixef(m_within), 2))

m_between <- plm(formule, data = panel, model = "between")
print(summary(m_between))

m_lsdv <- lm(RG ~ ADS + DAQ + OI + CFP + DTS + LSI + RC +
               factor(entreprise) - 1, data = df)
print(summary(m_lsdv))

m_lsdv1 <- lm(RG ~ ADS + DAQ + OI + CFP + DTS + LSI + RC +
                factor(entreprise), data = df)
print(summary(m_lsdv1))

m_random <- plm(formule, data = panel, model = "random")
print(summary(m_random))

print(ercomp(m_random))

screenreg(list("Pooled" = m_pooled, "Between" = m_between, "Within" = m_within, "Random" = m_random), digits = 2)

tf <- pFtest(m_within, m_pooled)
print(tf)
fisher_rejet <- tf$p.value < 0.05
cat("   ► Conclusion :", ifelse(fisher_rejet,
                                "p < 0,05 → REJET H0 : effets individuels significatifs, Pooling inadéquat.",
                                "p ≥ 0,05 → NON REJET : Pooling acceptable."), "\n")

tlm <- plmtest(m_pooled, type = "bp")
print(tlm)
lm_rejet <- tlm$p.value < 0.05
cat("   ► Conclusion :", ifelse(lm_rejet,
                                "p < 0,05 → REJET H0 : σ²u > 0, effets aléatoires significatives",
                                "p ≥ 0,05 → NON REJET : Pooling acceptable."), "\n")

th <- phtest(m_within, m_random)
print(th)
hausman_rejet <- th$p.value < 0.05
cat("   ► Conclusion :", ifelse(hausman_rejet,
                                "p < 0,05 → REJET H0 : corrélation détectée → EFFETS FIXES (Within).",
                                "p ≥ 0,05 → NON REJET : pas de corrélation → EFFETS ALÉATOIRES (MCQG)."), "\n")

bg <- pbgtest(m_random)
print(bg)
autocorr <- bg$p.value < 0.05
cat("   ► Conclusion :", ifelse(autocorr,
                                "p < 0,05 → Autocorrélation sérielle détectée.",
                                "p ≥ 0,05 → Pas d'autocorrélation sérielle."), "\n")

bp_hetero <- bptest(m_random)
print(bp_hetero)
hetero <- bp_hetero$p.value < 0.05
cat("   ► Conclusion :", ifelse(hetero,
                                "p < 0,05 → Hétéroscédasticité groupée détectée.",
                                "p ≥ 0,05 → Homoscédasticité."), "\n")

cd <- pcdtest(m_random, test = "cd")
print(cd)
dep_trans <- cd$p.value < 0.05
cat("   ► Conclusion :", ifelse(dep_trans,
                                "p < 0,05 → Dépendance transversale détectée.",
                                "p ≥ 0,05 → Pas de dépendance transversale."), "\n")


coeftest_dk <- coeftest(m_random, vcov = vcovSCC(m_random, type = "HC3", maxlag = NULL))
print(coeftest_dk)

coeftest_dk1 <- coeftest(m_random, vcov = vcovDC(m_random))
print(coeftest_dk1)

screenreg(list(
  "RE classique" = m_random,
  "RE + Driscoll-Kraay" = coeftest_dk,
  "RE + Double cluster" = coeftest_dk1
), digits = 3)