#' @title Search for full text
#' 
#' @description `ft_search` is a one stop shop for searching for articles 
#' across many publishers and repositories. We currently support search for 
#' PLOS via the  \pkg{rplos} package, Crossref via the \pkg{rcrossref} 
#' package, Entrez via the \pkg{rentrez} package, arXiv via the \pkg{aRxiv} 
#' package, and BMC, Biorxiv, EueroPMC, and Scopus via internal helper 
#' functions in this package. 
#' 
#' Many publishers content is searchable via Crossref and Entrez - of course 
#' this doesn't mean that we can get full text for those articles. In the 
#' output objects of this function, we attempt to help by indicating what 
#' license is used for articles.  
#'
#' @export
#' @param query (character) Query terms
#' @param from (character) Source to query, one of more of plos, bmc, crossref,
#' entrez, arxiv, biorxiv, europmc, scopus, or ma
#' @param limit (integer) Number of records to return. default: 10
#' @param start (integer) Record number to start at. Only used for 
#' 'scopus' right now. default: 0
#' @param plosopts (list) PLOS options. See [rplos::searchplos()]
#' @param bmcopts (list) BMC options. See [bmc_search()]
#' @param crossrefopts (list) Crossref options. See [rcrossref::cr_works()]
#' @param entrezopts (list) Entrez options. See [rentrez::entrez_search()]
#' @param arxivopts (list) arxiv options. See [aRxiv::arxiv_search()]
#' @param biorxivopts (list) biorxiv options. See [biorxiv_search()]
#' @param euroopts (list) Euro PMC options. See [eupmc_search()]
#' @param scopusopts (list) Scopus options. See [scopus_search()]
#' @param maopts (list) Microsoft Academic options. See 
#' [microsoft_search()]
#' @param ... ignored right now
#' 
#' @details Each of `plosopts`, `scopusopts`, etc. expect 
#' a named list.
#' 
#' @details See **Rate Limits** and **Authentication** in 
#' [fulltext-package] for rate limiting and authentication information,
#' respectively
#'
#' @return An object of class `ft`, and objects of class `ft_ind`
#' within each source. You can access each data source with `$`
#'
#' @examples 
#' # List publishers included
#' ft_search_ls()
#' 
#' \dontrun{
#' # Plos
#' (res1 <- ft_search(query='ecology', from='plos'))
#' res1$plos
#' ft_search(query='climate change', from='plos', limit=500, 
#'   plosopts=list(
#'    fl=c('id','author','eissn','journal','counter_total_all',
#'    'alm_twitterCount')))
#'
#' # Crossref
#' (res2 <- ft_search(query='ecology', from='crossref'))
#' res2$crossref
#'
#' # BioRxiv
#' (res <- ft_search(query='owls', from='biorxiv'))
#' res$biorxiv
#'
#' # Entrez
#' (res <- ft_search(query='ecology', from='entrez'))
#' res$entrez
#'
#' # arXiv
#' (res <- ft_search(query='ecology', from='arxiv'))
#' res$arxiv
#'
#' # BMC - can be very slow
#' (res <- ft_search(query='ecology', from='bmc'))
#' res$bmc
#' 
#' # Europe PMC
#' (res <- ft_search(query='ecology', from='europmc'))
#' res$europmc
#' 
#' # Scopus
#' (res <- ft_search(query = 'ecology', from = 'scopus', limit = 100,
#'    scopusopts = list(key = Sys.getenv('ELSEVIER_SCOPUS_KEY'))))
#' res$scopus
#' ## pagination
#' (res <- ft_search(query = 'ecology', from = 'scopus', 
#'    scopusopts = list(key = Sys.getenv('ELSEVIER_SCOPUS_KEY')), limit = 5))
#' (res <- ft_search(query = 'ecology', from = 'scopus', 
#'    scopusopts = list(key = Sys.getenv('ELSEVIER_SCOPUS_KEY')), 
#'    limit = 5, start = 5))
#' ## lots of results
#' (res <- ft_search(query = "ecology community elk cow", from = 'scopus', 
#'    limit = 100,
#'    scopusopts = list(key = Sys.getenv('ELSEVIER_SCOPUS_KEY'))))
#' res$scopus
#'
#' # PLOS, Crossref, and arxiv
#' (res <- ft_search(query='ecology', from=c('plos','crossref','arxiv')))
#' res$plos
#' res$arxiv
#' res$crossref
#' 
#' # Microsoft academic search
#' key <- Sys.getenv("MICROSOFT_ACADEMIC_KEY")
#' (res <- ft_search("Y='19'...", from = "microsoft", maopts = list(key = key)))
#' res$ma
#' res$ma$data$DOI
#' }

ft_search <- function(query, from = 'plos', limit = 10, start = 0,
                      plosopts = list(),
                      bmcopts = list(),
                      crossrefopts = list(),
                      entrezopts = list(),
                      arxivopts = list(),
                      biorxivopts = list(),
                      euroopts = list(),
                      scopusopts = list(),
                      maopts = list(),
                      ...) {

  from <- match.arg(from, 
                    c("plos", "bmc", "crossref", "entrez", "arxiv", 
                      "biorxiv", "europmc", "scopus", "microsoft"), 
                    several.ok = TRUE)
  plos_out <- plugin_search_plos(from, query, limit, start, plosopts)
  bmc_out <- plugin_search_bmc(from, query, limit, start, bmcopts)
  cr_out <- plugin_search_crossref(from, query, limit, start, crossrefopts)
  en_out <- plugin_search_entrez(from, query, limit, start, entrezopts)
  arx_out <- plugin_search_arxiv(from, query, limit, start, arxivopts)
  bio_out <- plugin_search_biorxivr(from, query, limit, start, biorxivopts)
  euro_out <- plugin_search_europe_pmc(from, query, limit, start, euroopts)
  scopus_out <- plugin_search_scopus(from, query, limit, start, scopusopts)
  ma_out <- plugin_search_ma(from, query, limit, start, maopts)

  res <- list(plos = plos_out, bmc = bmc_out, crossref = cr_out,
              entrez = en_out, arxiv = arx_out, biorxiv = bio_out, 
              europmc = euro_out, scopus = scopus_out, ma = ma_out)
  structure(res, class = "ft", query = query)
}

#' @export
#' @rdname ft_search
ft_search_ls <- function() {
  nms <- ls(getNamespace("fulltext"), all.names = TRUE, pattern = "plugin_search_")
  gsub("plugin_search_", "", nms)
}



#' @export
print.ft <- function(x, ...) {
  rows <- sum(sapply(x, function(y) NROW(y$data)))
  found <- sum(unlist(ft_compact(sapply(x, "[[", 'found'))))

  cat(sprintf("Query:\n  [%s]", attr(x, "query")), "\n")

  cat("Found:\n")
  cat(paste(
    sprintf("  [PLoS: %s", null_len(x$plos$found)),
    sprintf("BMC: %s", null_len(x$bmc$found)),
    sprintf("Crossref: %s", null_len(x$crossref$found)),
    sprintf("Entrez: %s", null_len(x$entrez$found)),
    sprintf("arxiv: %s", null_len(x$arxiv$found)),
    sprintf("biorxiv: %s", null_len(x$biorxiv$found)),
    sprintf("Europe PMC: %s", null_len(x$europmc$found)),
    sprintf("Scopus: %s", null_len(x$scopus$found)),
    sprintf("Microsoft: %s]", null_len(x$ma$found)),
    sep = "; "), "\n")

  cat("Returned:\n")
  cat(paste(
    sprintf("  [PLoS: %s", NROW(x$plos$data)),
    sprintf("BMC: %s", NROW(x$bmc$data)),
    sprintf("Crossref: %s", NROW(x$crossref$data)),
    sprintf("Entrez: %s", NROW(x$entrez$data)),
    sprintf("arxiv: %s", NROW(x$arxiv$data)),
    sprintf("biorxiv: %s", NROW(x$biorxiv$data)),
    sprintf("Europe PMC: %s", NROW(x$europmc$data)),
    sprintf("Scopus: %s", NROW(x$scopus$data)),
    sprintf("Microsoft: %s]", NROW(x$ma$data)),
    sep = "; "), "\n")
}

#' @export
print.ft_ind <- function(x, ..., n = 10) {
  rows <- NROW(x$data)
  found <- x$found
  cat(sprintf("Query: [%s]", attr(x, "query")), "\n")
  cat(sprintf("Records found, returned: [%s, %s]", found, rows), "\n")
  cat(sprintf("License: [%s]", x$license$type), "\n")
  print_if(x$data, n = n)
}

null_len <- function(x) if (is.null(x)) 0 else x

print_if <- function(x, n) {
  if (!is.null(x)) ft_trunc_mat(x, n)
}
