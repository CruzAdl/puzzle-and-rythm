

# Install required packages if missing
if (!require("rsconnect")) install.packages("rsconnect")
if (!require("shinyjs")) install.packages("shinyjs")

library(rsconnect)

rsconnect::setAccountInfo(name='coldruralt', token='75FC6BE4533E4935EE613849284E7254', secret='onJtnEb331242s1U11QdJzygP1eiHwrEWtCdegSX')
# 2. Deploy the app (assumes app.R is in the current directory)
deployApp(appDir = ".", appName = "puzzle-and-rythm")
