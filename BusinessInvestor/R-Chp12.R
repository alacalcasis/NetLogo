# Create the profit and risk variables
profit<-seq(-5000,10000,by=1000)
risk<-seq(0.01,0.1,by=0.01)

# Create the array to contour
profit.risk<-expand.grid(profit=profit,risk=risk)

# Function to calculate utility
calc.utility<-function(current.value,time.horizon,profit.risk)
              {
			max(0,(current.value+(time.horizon*profit.risk["profit"])) * (1-profit.risk["risk"])^time.horizon)
		  }

# Create an array containing utility values
utility<-apply(profit.risk,1,calc.utility,current.value=0,time.horizon=5)

# Draw the contour plot
filled.contour(profit,risk,matrix(utility,ncol=length(risk)),col=grey(0:24/24),xlab="profit",ylab="risk")
