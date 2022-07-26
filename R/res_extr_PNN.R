#Result extraction and visualization Comparison PNN. Pending name change
#1. Load extracted Aggreement Table. 
load('~/agg_all.RDAta')
# Aggreement_metrics
#1. Get "omission" and "commision" for each class/location/year and add to the table

#Some data manipulation ,convert char into numeric
sum_agg_met <- function(aggp, classes){
aggp <- aggp%>%rowwise()%>%mutate(sum_row=sum(no_bosque+bosque))
aggp <- aggp%>%mutate(sum_row=sum(no_bosque+bosque))%>%group_by(year, pnn)%>%
  mutate(colsums_nb=sum(no_bosque))%>%mutate(colsums_b=sum(bosque))
return(aggp)}
# Obtain total pixel number
aggp <- aggp%>%rowwise()%>%mutate(sum_all=sum(colsums_nb+colsums_b))
# get sensitivity for both classes
aggp <- aggp%>%mutate(UAnb=sum(no_bosque/sum_row))%>%mutate(UAb=sum(bosque/sum_row))
# get specificity (PA)
aggp <- aggp%>%group_by(year, pnn)%>%mutate(PAnb=(no_bosque/colsums_nb))%>%mutate(PAb=(bosque/colsums_b))
return(aggp)}
#get OA (Coincidencia Agregada (lugar/clase))
#Get sum of all correctly classified pixels   
aggpoa <- aggp%>%filter(class=='no-bosque')
aggpoa <- aggpoa[c(1,2)]
names(aggpoa) <- c('class', 'sum_correct')
aggpoa2 <- aggp%>%filter(class=='bosque')
aggpoa2 <- aggpoa2[3]
names(aggpoa2) <- 'sum_correct'
aggpoa[2] <- (aggpoa[2]+aggpoa2[1])
rm(aggpoa2)
######
#GET OA
aggp <- aggp%>%mutate(OA=sum_correct/sum_all)
###### Remove unnecessary values
#UAnb for bosquem PAnb for bosque, UAb for no bosque. PAb for no bosque
#Not yet ready#####################
aggp%>%filter(class=='bosque', UAnb="NA")
df <- aggp %>% mutate(height = replace(height, height == 20, NA))
#Later #########################
#Plots
############################################
#Overall Agreement (lines)
ggplot(aggp%>%filter(class=='no-bosque'), aes(x=year,y=OA, color=pnn))+#, fill=algorithm))+
  geom_line()+
  #facet_grid(vars(pnn))+
ggtitle('Overall Agreement')

#Overall Agreement (lines/facets)
ggplot(aggp%>%filter(class=='no-bosque'), aes(x=year,y=OA, color=pnn))+#, fill=algorithm))+
  geom_line()+
  facet_grid(vars(pnn))+
  ggtitle('Overall Agreement')

#Overall Agreement (barplot)
ggplot(aggp%>%filter(class=='no-bosque'), aes(x=year,y=OA, color=pnn, fill=pnn))+#, fill=algorithm))+
  geom_bar(stat='identity', position = 'dodge')+
  #facet_grid(vars(pnn))+
  ggtitle('Overall Agreement')

# Specificity, no Bosque
ggplot(aggp%>%filter(class=='no-bosque'), aes(x=year,y=PAnb, color=pnn, fill=pnn))+#, fill=algorithm))+
  geom_bar(stat='identity', position = 'dodge')+
  #facet_grid(vars(pnn))+
  ggtitle('Specificity, no bosque')

# Specificity,  Bosque
ggplot(aggp%>%filter(class=='bosque'), aes(x=year,y=PAb, color=pnn, fill=pnn))+#, fill=algorithm))+
  geom_bar(stat='identity', position = 'dodge')+
  #facet_grid(vars(pnn))+
  ggtitle('Specificity, bosque')

# Sensitivity,  no Bosque
ggplot(aggp%>%filter(class=='no-bosque'), aes(x=year,y=UAnb, color=pnn, fill=pnn))+#, fill=algorithm))+
  geom_bar(stat='identity', position = 'dodge')+
  #facet_grid(vars(pnn))+
  ggtitle('Sensitivity, no bosque')

# Sensitivity, Bosque
ggplot(aggp%>%filter(class=='bosque'), aes(x=year,y=UAb, color=pnn, fill=pnn))+#, fill=algorithm))+
  geom_bar(stat='identity', position = 'dodge')+
  #facet_grid(vars(pnn))+
  ggtitle('Sensitivity, bosque')


#####SCRATCH#####################################################################################################################################
##########################################################################################################################################



pdf(file='test1.pdf',
    width = 16, height=9)
ggplot(accu_msk, aes(x=pixelcount, y=accuracy, color=interaction(threshold, type), shape=type, group=interaction(type,threshold,biome)))+
  geom_point()+
  facet_wrap(vars(threshold))+
  geom_smooth(method='lm', alpha=0.1, size=0.5)+
  ylim(0,1)+
  scale_x_continuous(labels = scales::percent_format(scale = 100))+
  labs(x='no-Change (share)')
dev.off()


pdf(file='acc_no_ch.pdf',
    width = 16, height=9)
ggplot(accu_msk, aes(x=algorithm,y=accuracy, color=user))+#, fill=algorithm))+
  geom_boxplot()+
  facet_grid(vars(location),vars(type))+
  ggtitle('Accuracies no-change')
dev.off()

#Boxplot change
pdf(file='acc_ch.pdf',
    width = 16, height=9)
ggplot(accu_ch, aes(x=algorithm,y=accuracy, color=user))+#, fill=algorithm))+
  geom_boxplot()+
  facet_grid(vars(location),vars(type))+
  ggtitle('Accuracies change')
dev.off()

#Acc/Area no change
pdf(file='acc_no_ch_area.pdf',
    width = 16, height=9)
ggplot(accu_no_ch, aes(x=pixels, y=accuracy, color=interaction(user, algorithm), shape=user, group=interaction(type,user,algorithm)))+
  geom_point()+
  facet_grid(vars(location),vars(type))+
  geom_smooth( method='lm', alpha=0.1, size=0.5)+
  ylim(0,1)+
  scale_x_continuous(labels = scales::percent_format(scale = 100))+
  labs(x='no-Change (share)')
dev.off()

#Acc/Area  change
pdf(file='acc_ch_area.pdf',
    width = 16, height=9)
ggplot(accu_ch, aes(x=pixels, y=accuracy, color=interaction(user, algorithm), shape=user, group=interaction(type,user,algorithm)))+
  geom_point()+
  facet_grid(vars(location),vars(type))+
  geom_smooth( method='lm', alpha=0.1, size=0.5)+
  ylim(0,1)+
  scale_x_continuous(labels = scales::percent_format(scale = 100))+
  labs(x='Change (share)')
dev.off()

# # GGplot from here 
aggp%>%filter(pnn=='Serrania_de Chiribiquete')
x <- 5773972+82755
