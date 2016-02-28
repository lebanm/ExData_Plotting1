#getwd to set wd at the end 
p_getwd <- getwd()

# set working directory (change this to fit your needs)
print('setwd')
setwd('../')

# make sure the plots folder exists
print('make sure the plots folder exists')
if (!file.exists('plots')) {
  dir.create('plots')
}

#### load data / this can  be done in library
print('required packages')
# required packages
library(data.table)
library(lubridate)

# make sure the sources data folder exists
print('make sure the sources data folder exists; if not create one')
if (!file.exists('sourcedata')) {
  dir.create('sourcedata')
}

# check to see if the existing tidy data set exists; if not, make it...
print('check to see if the existing; if not download one')
if (!file.exists('sourcedata/power_consumption.txt')) {
  
  # download the zip file and unzip
  file.url<-'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip'
  download.file(file.url,destfile='sourcedata/power_consumption.zip')
  unzip('sourcedata/power_consumption.zip',exdir='sourcedata',overwrite=TRUE)

  # read the raw table and limit to 2 days
  variable.class<-c(rep('character',2),rep('numeric',7))
  #define dates
  l_date_from <- '1/2/2007'
  l_date_to <- '2/2/2007'  
  power.consumption<-read.table('sourcedata/household_power_consumption.txt',header=TRUE,
                                sep=';',na.strings='?',colClasses=variable.class)
  power.consumption<-power.consumption[power.consumption$Date==l_date_from | power.consumption$Date==l_date_to,]

  # clean up the variable names and convert date/time fields
  cols<-c('Date','Time','GlobalActivePower','GlobalReactivePower','Voltage','GlobalIntensity',
          'SubMetering1','SubMetering2','SubMetering3')
  colnames(power.consumption)<-cols
  power.consumption$DateTime<-dmy(power.consumption$Date)+hms(power.consumption$Time)
  power.consumption<-power.consumption[,c(10,3:9)]
  
  # write a clean data set to the directory
  write.table(power.consumption,file='sourcedata/power_consumption.txt',sep='|',row.names=FALSE)
} else {
  
  power.consumption<-read.table('sourcedata/power_consumption.txt',header=TRUE,sep='|')
  power.consumption$DateTime<-as.POSIXlt(power.consumption$DateTime)

}

# remove the large raw data set 
print('remove the large raw data set ')
if (file.exists('sourcedata/household_power_consumption.txt')) {
  x<-file.remove('sourcedata/household_power_consumption.txt')
}


####
#making plot
# open device
png(filename='plots/plot2.png',width=480,height=480,units='px')

# plot data
plot(power.consumption$DateTime,power.consumption$GlobalActivePower,ylab='Global Active Power (kilowatts)', xlab='', type='l')

# close device
x<-dev.off()

# set working directory to begin one - to work with other scripts
setwd(p_getwd)