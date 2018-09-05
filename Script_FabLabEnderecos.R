# Abrir Bibliotecas/Open Libraries ----
library(httr)
library(jsonlite)

# Ler arquivo/Read File----
#Here you should point the file u want to read. In this case the file is called "usuarios"

usuarios <- data.frame(read_excel(paste(loc, file.list[1], sep="")), check.names= TRUE)

#Acessar jSon ----

nCep <- length(usuarios$CEP) # the length of the matrix of adresses that u want to read.

usuarios$Endereço <- ""   # An empty spot where u can store the full adress 
usuarios$Latitude <- ""   # An empty spot where u can store the latitude
usuarios$Longitude <- ""  # An empty spot where u can store the longitude

cont <- 0 # An empty spot for u to count the reading errors when you try to access the Maps API
ultimoReg <- 1 # The last line that u could succefully read.

#This is the loop that will keep accessing Google Maps API untill your adresses matrix is over.
for (i in ultimoReg:nCep) {
  if(!is.na(usuarios$CEP[i])){    # CEP is the column that gives me the adresses (in fact the postal codes) that I want to check
  url <- read_json(paste("https://maps.googleapis.com/maps/api/geocode/json?address=",usuarios$CEP[i],"&region=br", sep="")) #Acessing the google maps API "region=br" mean that I want to find places in Brazil.
  if(url$status=="OVER_QUERY_LIMIT"){    # This is the general error when u try to access Google Maps API
    while (url$status=="OVER_QUERY_LIMIT"){   # While this error persists (sometimes it occurs 5 times in a row without any apprent justification) try the same line again
      print(paste("Linha ",i," ","OVER_QUERY_LIMIT: Tentando de novo", sep="")) # Print an status saying that the same line will be read again
      Sys.sleep(2)    # Sleep 2seconds before trying again (usefull for free users). Read more: https://developers.google.com/maps/documentation/geocoding/usage-and-billing
      cont <- cont+1    # You should count the errors. Many errors in a row means that u have reached your daily quota (in this code, 15 errors in a row)
      url <- read_json(paste("https://maps.googleapis.com/maps/api/geocode/json?address=",usuarios$CEP[i],"&region=br", sep=""))
      if (cont==15){
        ultimoReg <- i # if you reach the daily quota u can:
        #stop(paste("Limite do dia atingido: ",Sys.time()," linha:",i,sep=""))    #stop running the code and beep.
        #beepr::beep()
        print(paste("Limite do dia atingido: ",Sys.time()," linha:",i,sep=""))    #or 'sleep' for X hours (in this case 8) and countinue running this code.
        Sys.sleep((60*60*8))
        }
    }
    if(url$status=="OK"){     # if u get an OK status, it meand u could succefully get an geocode with your adress.
    url.end <- url$results[[1]]$formatted_address     # get the full adress
    url.lat <- url$results[[1]]$geometry$location$lat   #get the latitude
    url.lng <- url$results[[1]]$geometry$location$lng   #get the longitude
    cont <- 0   # renew the error counter
    usuarios$Endereço[i] <- url.end   # set this adress in your data.frame
    usuarios$Latitude[i] <- url.lat   # set this latitude in your data.frame
    usuarios$Longitude[i] <- url.lng   # set this longitude in your data.frame
    print(paste("|Linha ",i,"| ",url.end, sep=""))  #print and sucessfull mesage with the full adress
    }else{
      print(paste("Linha ",i," ",url$status, sep=""))   #print any other error as "No Results" and go on
      cont <- cont+1
    }
    # From here the code is the same as already described.
  }else if(url$status=="OK"){
  url.end <- url$results[[1]]$formatted_address
  url.lat <- url$results[[1]]$geometry$location$lat
  url.lng <- url$results[[1]]$geometry$location$lng
  cont <- 0
  usuarios$Endereço[i] <- url.end
  usuarios$Latitude[i] <- url.lat
  usuarios$Longitude[i] <- url.lng
  print(paste("|Linha ",i,"| ",url.end, sep=""))
  }else{
    print(paste("Linha ",i," ",url$status, sep=""))
    cont <- cont+1
  }
  }
  Sys.sleep(2)
  if (cont==15){
    ultimoReg <- i
    #stop(paste("Limite do dia atingido: ",Sys.time()," linha:",i,sep=""))
    #beepr::beep()
    print(paste("Limite do dia atingido: ",Sys.time()," linha:",i,sep=""))
    Sys.sleep((60*60*8))
  }
}
