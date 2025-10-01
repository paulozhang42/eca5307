#=========================================================================#
#  Simulate Choice Data
#  JP Dube and Sanjog Misra
#
#  12/18/2021
#=========================================================================#
# Header section with title, authors, and date of creation

#---------+---------+---------+---------+---------+---------+
# settings
#---------+---------+---------+---------+---------+---------+
if(.Platform$OS.type != "unix") {
  setwd("C:/Users/jdube/Dropbox/ZipProject/code/JPE replication package/")
} # Set working directory to Windows path if OS is not Unix
if(.Platform$OS.type == "unix") {
  setwd("~/ZipProject/code/JPE replication package/")
} # Set working directory to Unix path if OS is Unix

#---------+---------+---------+---------+---------+---------+
# FUNCTIONS	
#---------+---------+---------+---------+---------+---------+
share=function(p,aa,bb) {
  share = 1/(1+exp(-aa-bb*p)) # Define a function to compute logit choice probability: 1/(1 + exp(-aa - bb*p)), where p is price, aa is intercept, bb is price coefficient
  return(share) # Return the computed share (probability)
} # End of share function definition

#---------+---------+---------+---------+---------+---------+
# PRELIMINARIES
#---------+---------+---------+---------+---------+---------+
set.seed(1) # Set random seed for reproducibility

N = 8000 # Define total number of consumers (observations)
Nx = 133 # Define number of characteristics per consumer

#---------+---------+---------+---------+---------+---------+
# Preferences
#---------+---------+---------+---------+---------+---------+
betatrue = matrix(runif(Nx*2),ncol=2) # Create a matrix of true preference parameters (133 rows, 2 columns) with random uniform values [0,1]
betatrue[,1] = betatrue[,1]/2.5 # Scale the first column (intercepts) by dividing by 2.5 to adjust magnitude
betatrue[,2] = -abs(betatrue[,2])*2.5 # Scale the second column (price sensitivities) by taking absolute value and multiplying by -2.5 to ensure negative slopes
max(betatrue[betatrue[,2]<0,2]) # Check the maximum negative value in the second column (diagnostic)
# randomly select which features have non-zero weights
betatrue[-sample(1:Nx,30),1] = 0 # Set 103 randomly selected features (133 - 30) to zero in the first column for sparsity
betatrue[-sample(1:Nx,30),2] = 0 # Set 103 randomly selected features (133 - 30) to zero in the second column for sparsity
CholcovX = diag(Nx)+as.matrix(tril(matrix(runif(Nx*Nx),nrow=Nx))) # Create a lower triangular covariance matrix with random uniforms on and below diagonal, plus identity
X = abs(matrix(rnorm(N*Nx),nrow=N)%*%CholcovX) # Generate characteristic matrix (8000 x 133) from correlated normal distributions, take absolute values
X = X/max(X) # Scale X to [0, 1] by dividing by its maximum value
P = as.matrix(runif(N)/2) # Generate price vector (8000 x 1) with random uniform values in [0, 0.5]
atrue = X%*%betatrue[,1] # Compute individual intercepts as X times the first column of betatrue
btrue = X%*%betatrue[,2] # Compute individual price sensitivities as X times the second column of betatrue
Prob = 1/(1+exp(-btrue*P-atrue)) # Compute purchase probabilities using the logit model for each consumer
max(Prob) # Check the maximum probability (diagnostic)
min(Prob) # Check the minimum probability (diagnostic)
mean(Prob) # Check the mean probability (diagnostic)
median(Prob) # Check the median probability (diagnostic)

elastrue = btrue*(1-share(P,atrue,btrue))*P # Compute true price elasticities: btrue * (1 - share) * P
quantile(elastrue,c(.025,.5,.975)) # Compute quantiles (2.5%, 50%, 97.5%) of elasticities (diagnostic)

#---------+---------+---------+---------+---------+---------+
# Choices
#---------+---------+---------+---------+---------+---------+
Y = matrix(0,nrow=N,ncol=1) # Initialize choice matrix (8000 x 1) with zeros
oo = as.matrix(c(1,0)) # Define a vector [1, 0] for multinomial outcome mapping
for(ii in 1:N){Y[ii]=matrix(rmultinom(1,1,prob=as.matrix(c(Prob[ii],1-Prob[ii]))),nrow=1)%*%oo} # Simulate binary choices (1 or 0) for each consumer using multinomial draw based on Prob

#---------+---------+---------+---------+---------+---------+
# Save Data
#---------+---------+---------+---------+---------+---------+
datz = data.frame(Y,X,P) # Combine choices, characteristics, and prices into a data frame
save(datz,file="data/estimdata.Rdata") # Save the simulated data to a file
save(atrue,btrue,betatrue,elastrue,file="data/trueprefs.Rdata") # Save true preference parameters and elasticities to a file