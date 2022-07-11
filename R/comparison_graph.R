
rm(list=ls())

load('areas_fin.RData')
#areas_f%>%group_by(year,src)%>%summarise(a_sum=sum(count)
#Calculate area in ha                                         
areas_f <- areas_f%>%mutate(area_ha = count*0.09)
#drop NA values (in all maps is the same, not necessary anymore)
areas_f <- areas_f%>%drop_na(value)
#add column with class names
areas_f <- areas_f%>%mutate(clase= case_when(value==0 ~'no Bosque',
                                             value==1 ~'Bosque',
                                             value==3 ~'sin información')) 
                                             

require(scales)                                       
#graph without "sin información"                                             
#save(areas_f, file= 'areas_f.RData') 
#jpeg(file='plot2c.jpeg',
#width = 16, height=9, units= 'in', res=300) # this exports the ggplots as jpegs, 
# and sets the size and resolution. ayou can plot inside Rstudio instead  # by dropping this 
# here, i created line graps, but ypu will need to use barplots
ggplot (areas_f%>%filter(value!=3), aes(x = year, y= area_ha, color= interaction(clase,src), group=interaction(value,src)))+
 geom_line(size=1.5)+
geom_point(size=4)+
scale_y_continuous(labels = comma)+
labs (
title = "Bosque/no Bosque 2000-2019",
subtitle = "SMBYC vs GLAD",
x = "Año",
 y = "Total Area (ha)"
 )
#stops graphic device. Necessary for new plots 
#dev.off()
#Graph with including "sin información"                                         
# jpeg(file='plot3c.jpeg',
#   width = 16, height=9, units= 'in', res=300) 
ggplot (areas_f, aes(x = year, y= area_ha, color= interaction(clase,src), group=interaction(value,src)))+
  geom_line(size=1.5)+
 geom_point(size=4)+
 scale_y_continuous(labels = comma)+
labs (
title = "Bosque/no Bosque 2000-2019",
subtitle = "SMBYC vs GLAD",
x = "Año",
y = "Total Area (ha)"
)
#dev.off()

# Filters:
 
#Mean sin información 2000-2015

mean_no_data00_15 <- areas_f%>%filter(clase =='sin información')%>%filter(year !=2019)%>%summarise(mean=mean(count))

# sin información 2019
mean_no_data19 <- areas_f%>%filter(clase =='sin información')%>%filter(year ==2019)%>%summarise(mean=mean(count))
