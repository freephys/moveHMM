
#' Plot states
#'
#' Plot the states and states probabilities.
#'
#' @param m A \code{\link{moveHMM}} object
#' @param animals Vector of indices or IDs of animals for which states will be plotted.
#' @param ask If \code{TRUE}, the execution pauses between each plot.
#'
#' @examples
#' # m is a moveHMM object (as returned by fitHMM), automatically loaded with the package
#' m <- example$m
#'
#' # plot states for first and second animals
#' plotStates(m,animals=c(1,2))
#'
#' @export

plotStates <- function(m,animals=NULL,ask=TRUE)
{
    if(!is.moveHMM(m))
        stop("'m' must be a moveHMM object (as output by fitHMM)")

    nbAnimals <- length(unique(m$data$ID))
    nbStates <- ncol(m$mle$stepPar)

    if(nbStates==1)
        stop("Only one state.")

    cat("Decoding states sequence... ")
    states <- viterbi(m)
    cat("DONE\n")
    cat("Computing states probabilities... ")
    sp <- stateProbs(m)
    cat("DONE\n")

    # define animals to be plotted
    if(is.null(animals)) # all animals are plotted
        animalsInd <- 1:nbAnimals
    else {
        if(is.character(animals)) { # animals' IDs provided
            animalsInd <- NULL
            for(zoo in 1:length(animals)) {
                if(length(which(unique(m$data$ID)==animals[zoo]))==0) # ID not found
                    stop("Check animals argument.")

                animalsInd <- c(animalsInd,which(unique(m$data$ID)==animals[zoo]))
            }
        }

        if(is.numeric(animals)) { # animals' indices provided
            if(length(which(animals<1))>0 | length(which(animals>nbAnimals))>0) # index out of bounds
                stop("Check animals argument.")

            animalsInd <- animals
        }
    }

    par(mfrow=c(nbStates+1,1))
    par(ask=ask)

    for(zoo in animalsInd) {
        ind <- which(m$data$ID==unique(m$data$ID)[zoo])

        # plot the states
        par(mar=c(5,4,4,2)-c(2,0,0,0))
        plot(states[ind],main=paste("Animal ID: ",unique(m$data$ID)[zoo],sep=""),ylim=c(0.5,nbStates+0.5),
             yaxt="n",xlab="",ylab="State")
        axis(side=2,at=1:nbStates,labels=as.character(1:nbStates))

        # plot the states probabilities
        par(mar=c(5,4,4,2)-c(0,0,2,0))
        for(i in 1:nbStates) {
            plot(sp[ind,i],type="l",xlab="Observation index",ylab=paste("Pr(State=",i,")",sep=""))
            abline(h=0.5,lty=2,col="darkgrey")
        }
    }

    # back to default
    par(mar=c(5,4,4,2)) # bottom, left, top, right
    par(mfrow=c(1,1))
    par(ask=FALSE)
}
