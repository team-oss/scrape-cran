################################
#### OpenHub orgs: analysis ####
################################
# This code runs plotting commands for organizations

#### Created by: sphadke
#### Creted on: 07/10/2017
#### Last edited on: 07/10/2017


####################
#### Cleanup
####################
rm(list=ls())
gc()
set.seed(312)


####################
#### R Setup
####################
library(ggplot2)
library(reshape2)
library(sdalr)

## Data import and rename
load("~/git/oss/data/oss/final/openhub/organizations/all_orgs_table_final.RData")


####################
#### Let's create cool plots!
####################
# cols <- c("Commercial" = "#80ced6", "Government" = "#d5f4e6",
#           "Education" = "#fefbd8", "Non-Profit" = "#618685")

#colors <- c("blue", "red", "dodgerblue4", "green")

## The main orgs plot
p0 <- ggplot(data = organization, aes(type, fill = type)) +
  geom_bar() +
  # scale_fill_manual(values = cols) +
  theme_minimal() +
  theme(legend.position="none") +
  ggtitle(paste("Organizations on OpenHub: Total=698")) +
  labs(x = "Organization type", y = "Count") +
  theme(plot.title = element_text(hjust = 0.5))


## Affiliated contributors
p1 <- ggplot(data = organization, aes(x = type, y = affiliators, fill = type)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  theme(legend.position="none") +
  ggtitle(paste0("Affiliators: Total=", sum(organization$affiliators))) +
  labs(x = "Organization type", y = "Affiliated contributors") +
  theme(plot.title = element_text(hjust = 0.5))


# ## Outside projects
# p2 <- ggplot(data = organization, aes(x = type, y = outside_projects, fill = type)) +
#   geom_bar(stat = "identity") +
#   theme_minimal() +
#   theme(legend.position="none") +
#   ggtitle(paste0("Outside projects committed to by affiliators: Total=",
#                  sum(organization$outside_projects))) +
#   labs(x = "Organization type", y = "Outside projects") +
#   theme(plot.title = element_text(hjust = 0.5))


## Portfolio projects
p3 <- ggplot(data = organization, aes(x = type, y = portfolio_projects_count, fill = type)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  theme(legend.position="none") +
  ggtitle(paste0("Portfolio projects: Total=",
                 sum(organization$portfolio_projects_count))) +
  labs(x = "Organization type", y = "Portflio projects") +
  theme(plot.title = element_text(hjust = 0.5))


# ## Outside contributors
# p4 <- ggplot(data = organization, aes(x = type, y = outside_committers, fill = type)) +
#   geom_bar(stat = "identity") +
#   theme_minimal() +
#   theme(legend.position="none") +
#   ggtitle(paste0("Outside committers committing to portfolio projects: Total=", sum(organization$outside_committers))) +
#   labs(x = "Organization type", y = "Outside contributors") +
#   theme(plot.title = element_text(hjust = 0.5))


# All committers to portfolio projects
committer_df <- melt(data = organization, id.vars = c('org_name','type'), measure.vars = c('affiliators_committing_to_portfolio_projects', 'outside_committers'))

colnames(committer_df)[3] <- "ContributorType"
levels(committer_df$ContributorType) <- c("Affiliated", "Outside")

p5 <- ggplot(data = committer_df, aes(x = type, y = value, fill = ContributorType)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  ggtitle(paste0("Committers to portfolio projects")) +
  labs(x = "Organization type", y = "Contributors") +
  theme(plot.title = element_text(hjust = 0.5))


# All projects for affiliators
project_df <- melt(data = organization, id.vars = c('org_name','type'), measure.vars = c('affiliators_commiting_projects', 'outside_projects'))

colnames(project_df)[3] <- "ProjectType"
levels(project_df$ProjectType) <- c("Portfolio", "Outside")

p6 <- ggplot(data = project_df, aes(x = type, y = value, fill = ProjectType)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  ggtitle(paste0("Project contributions by affiliators")) +
  labs(x = "Organization type", y = "Projects") +
  theme(plot.title = element_text(hjust = 0.5))


##
# Plot it!!!
##
p0
multiplot(p1, p6, p3, p5, cols=2)





