# Create the profit and risk variables
profit<-seq(-5000,10000,by=1000)
risk<-seq(0.01,0.1,by=0.01)

# Create the array to contour
profit.risk<-expand.grid(profit=profit,risk=risk)

# Function to calculate utility
# current.value: representa la cantidad inicial de dinero que tendrá un inversionista hipotético.
# profit.risk es la matriz donde se guardarán los resultados
calc.utility<-function(current.value,time.horizon,profit.risk)
              {
			max(0,(current.value+(time.horizon*profit.risk["profit"])) * (1-profit.risk["risk"])^time.horizon)
		  }

# Create an array containing utility values
# Returns a vector or array or list of values obtained by applying a function to margins of an array or matrix.
# Por tanto devuelve una matriz con valores al aplicar "calc.utility" a las filas de profit.risk.
# El '1' indica que se procede por filas.
# Luego siguen los parámetros de la función.
utility<-apply(profit.risk,1,calc.utility,current.value=0,time.horizon=15)

# Draw the contour plot
filled.contour(profit,risk,matrix(utility,ncol=length(risk)),col=grey(0:24/24),xlab="profit",ylab="risk")
