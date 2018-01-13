# only 'stratum' assignment is necessary to generate strata
data(vaccinations)
ggplot(vaccinations,
       aes(weight = freq,
           x = survey, stratum = response,
           fill = response)) +
  stat_stratum(width = .5)

# lode data: positioning with weight labels
ggplot(vaccinations,
       aes(weight = freq,
           x = survey, stratum = response, alluvium = subject,
           label = freq)) +
  stat_stratum(geom = "errorbar") +
  geom_text(stat = "stratum")
# lode data: positioning with stratum labels
ggplot(vaccinations,
       aes(weight = freq,
           x = survey, stratum = response, alluvium = subject,
           label = response)) +
  stat_stratum(geom = "errorbar") +
  geom_text(stat = "stratum")

# use in tandem with ggfittext
ggplot(vaccinations,
       aes(x = survey, stratum = response, alluvium = subject,
           weight = freq,
           fill = response, label = response)) +
  geom_flow() +
  geom_stratum(alpha = .5) +
  ggfittext::geom_fit_text(stat = "stratum", angle = 90)

# alluvium data: positioning with weight labels
ggplot(as.data.frame(Titanic),
       aes(weight = Freq,
           axis1 = Class, axis2 = Sex, axis3 = Age, axis4 = Survived,
           label = Freq)) +
  geom_text(stat = "stratum") +
  stat_stratum(geom = "errorbar") +
  scale_x_continuous(breaks = 1:4,
                     labels = c("Class", "Sex", "Age", "Survived"))
# alluvium data: positioning with stratum labels
ggplot(as.data.frame(Titanic),
       aes(weight = Freq,
           axis1 = Class, axis2 = Sex, axis3 = Age, axis4 = Survived)) +
  geom_text(stat = "stratum", label.strata = TRUE) +
  stat_stratum(geom = "errorbar") +
  scale_x_continuous(breaks = 1:4,
                     labels = c("Class", "Sex", "Age", "Survived"))
