# # IMPORTANT: THIS FUNCTION DOES NOT WORK ON WINDOWS
#' Loads csv, if not found will reach out to github
#' @param location (string) if the entire repo is present the file location 
#' @param repo (string) where the repo is hosted, defaulted to the repo where this is hosted
#' @export
smart_data_loader <- function(location, repo = "https://raw.githubusercontent.com/gadzygadz/R/master/Group%20Projects/Group%20Project%207/"){
    data <- 0 # populate the data with just something empty so returns fail less often
    tryCatch(
        {
            data <- read_csv(location) # check the local location
        }, error = function(e) {
            print(paste("Downloading ", location, sep= "")) 
            data <- read_csv(url(paste(repo, location, sep=""))) # reads from the web
        }
    )
    return(data)
}


#' Takes 2 tibbles and merges them together
#' @param one (tibble) the starting tibble
#' @param repo (tibble) the joined tibble
#' @export a joined, cleaned and pivioted tibble
get_tibble <- function(one,two) {
    
    #' loads a tibble and pivots it
    #' @param file (string) the location of the file, 
    #' @param val (string) the pivot system
    #' @export a cleaned data set
    clean <- function(file, val="variable") {
        gen_data <- smart_data_loader(file) # smart download the data, must be local on linux
        cols <- colnames(gen_data) # get my col names 
        gen_data <- gen_data %>% 
        pivot_longer(
            cols[-1],
            names_to="year",
            values_to=paste(val)
        ) # pivots

        # returns
        return(gen_data)
    }

    # gets the x and y clean data
    x <- clean(one, "x")
    y <- clean(two, "y")
     
    return(
        inner_join(x, y) %>% na.omit(y) # na.omits may return an empty dataframe but thats ok cause their is nothing to regress anyway
    )
}

#' Takes a file name and files a list of string changes to pretty print
#' @param file (string) the filename, may included "/", directories, and file extensions
#' @export a pretty printed string for use in graphing information
get_var_name <- function(file) {
    pretty_print <- function(file){
        # if the files have been gained through recursion it cuts off all of the routing information and leaves just the final aspect
        remove_dir <- function(file){
            # checks if their are /s
            if(grepl("/", file)){ 
                # splits completely
                file <- str_split(file,"/") 
                # only pulls the last of the of the spllit which would be just the file
                file <- file[[1]][length(file[[1]])]
            }
            
            return(file) # explict return if it doesn't make changes
        }
        # removes .csv from the end of the file
        remove_csv <- function(file){
            # checks to see if csv in is the file name
            if(grepl(".csv", file)){ 
                # if it is it splits in 2
                file <- str_split(file,".csv", 2)
                # pulls the first element (file name) 
                file <- file[[1]][1]
            }
            return(file)
        }
        
        # adds spaces instead of underscores
        add_spaces <- function(file){
            # keeps running while there is an _
            while(grepl("_", file)){
                # replaces
                file <- str_replace(file, "_", " ")
            }
            return(file)
        }

        # adds capitilization to the strings
        add_capitilzation <- function(file){
            # first run through is true so it capitlizes
            found_space <- TRUE
            # string saver
            new_str <- ""
            # splits the word per letter
            for(i in strsplit(file, "")[[1]]){
                # capitilzes after ever space
                if(found_space){
                    # appends the capital to the space
                    new_str <- paste(new_str, str_to_upper(i), sep="")
                    # stands down
                    found_space = FALSE
                    # `continue` doesn't run the remainder of this loop
                    next
                }
                
                # if its found a space force uppercase on next letter
                if(i == " "){
                    found_space = TRUE
                }

                # at end paste the string
                new_str <- paste(new_str, i, sep="")
            }

            # force the return
            return(new_str)

        }

        # this order is very important like don't change this
        return(
            add_capitilzation(
                remove_dir(
                    remove_csv(
                        add_spaces(
                            file
                        )
                    )
                )
            )
        )
    }

    return(pretty_print(file))
}
