#' @param id Name of person searching for e.g., osf_find_user("John Smith")
#' @return A data.frame of user_names and user_urls 
#' @import RCurl rjson
#' @export


build_search_term <- function(user_name, osf_url_base){
    search_term <- paste0(osf_url_base, "/api/v1/search/?q=user:")  
    name <- strsplit(user_name," ")

    for(part in name[[1]]){
        search_term <- paste0(search_term, part, "+AND+user:")
    }
    
    search_term <- substr(search_term, 1, nchar(search_term)-10) # remove lingering "+AND+user:"    
    
    return(search_term)
}


osf_find_user <- function(user_name){
    
    osf_url_base <- ifelse(is.null(got <- getOption('osf_url_base')), 'https://osf.io', got)
    
    returned <- getURL(build_search_term(user_name, osf_url_base))
    json_data <- fromJSON(returned, method = "C", unexpected.escape = "error" )
    
    df <- do.call('rbind', lapply(json_data$results, function(user_data){
        data.frame("user_name"=user_data$user, "user_id"=gsub("/profile/", "", user_data$user_url))
    }))

    return(df)
}

