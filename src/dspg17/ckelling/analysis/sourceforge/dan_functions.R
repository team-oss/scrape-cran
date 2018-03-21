library(dplyr)
library(DiagrammeR)

create_edges_3 <- function(x, y, z, freq) {
  data.frame('source' = c(x, y),
             'target' = c(y, z),
             'freq' = c(-1, freq),
             stringsAsFactors = FALSE
  )
}

create_edges_2 <- function(x, y, freq) {
  data.frame('source' = c(x),
             'target' = c(y),
             'freq' = c(freq),
             stringsAsFactors = FALSE
  )
}

create_edges_1 <- function(x, freq) {
  data.frame('source' = c(x),
             'target' = c(x),
             'freq' = c(freq),
             stringsAsFactors = FALSE
  )
}

create_edges_0 <- function(freq) {
  data.frame('source' = c('EMPTY'),
             'target' = c('EMPTY'),
             'freq' = c(freq),
             stringsAsFactors = FALSE
  )
}

create_edges <- function(x, y, z, freq) {
  num_complete <- 3 - sum(is.na(c(x, y, z)), na.rm = TRUE)

  if (num_complete == 0) {
    return(create_edges_0(freq))
  } else if (num_complete == 1) {
    return(create_edges_1(x, freq))
  } else if (num_complete == 2) {
    return(create_edges_2(x, y, freq))
  } else if (num_complete == 3) {
    return(create_edges_3(x, y, z, freq))
  } else {
    stop('got something i didnt expect')
  }
}


network_graph <- function(counts){#, title){
  edges <- mapply(FUN = create_edges,
                  x = counts$Category.1,
                  y = counts$Category.2,
                  z = counts$Category.3,
                  freq = counts$freq,
                  SIMPLIFY = FALSE)

  el <- dplyr::bind_rows(edges)


  c1_counts <- counts %>% group_by(Category.1) %>%
    dplyr::summarize(count = sum(freq))

  c2_counts <- counts %>% group_by(Category.1, Category.2) %>%
    dplyr::summarize(count = sum(freq))

  c3_counts <- counts %>% group_by(Category.1, Category.2, Category.3) %>%
    dplyr::summarize(count = sum(freq))

  c1_labels <- tibble::data_frame(
    'node' = c1_counts$Category.1,
    'count' = c1_counts$count,
    'label' = sprintf('%s\n%s', c1_counts$Category.1, c1_counts$count)
  ) %>%
    dplyr::filter(!is.na(node))

  c2_labels <- tibble::data_frame(
    'node' = c2_counts$Category.2,
    'count' = c2_counts$count,
    'label' = sprintf('%s\n%s', c2_counts$Category.2, c2_counts$count)
  ) %>%
    dplyr::filter(!is.na(node))

  c3_labels <- cbind(
    'node' = c3_counts$Category.3,
    'count' = c3_counts$count,
    'label' = sprintf('%s\n%s', c3_counts$Category.3, c3_counts$count)
  ) %>% tibble::as_data_frame() %>%
    dplyr::filter(!is.na(node))
  c3_labels$count <- as.numeric(c3_labels$count)


  labels <- dplyr::bind_rows(c1_labels, c2_labels, c3_labels)

  df <- data.frame(col1 = el$source,
                   col2 = el$target,
                   stringsAsFactors = FALSE)
  uniquenodes <- unique(c(df$col1, df$col2))

  all_labels <- merge(x = tibble::data_frame(uniquenodes), y = labels,
                      by.x = 'uniquenodes',
                      by.y = 'node')

  nodes <- create_node_df(n = length(uniquenodes),
                          nodes=seq(uniquenodes), type="number",
                          label=all_labels[match(uniquenodes, all_labels$uniquenodes), 'label'])

  edges <- create_edge_df(from=match(df$col1, uniquenodes), to=match(df$col2, uniquenodes),
                          rel="related")

  g <- create_graph(nodes_df=nodes, edges_df=edges)

  return(render_graph(g))#, title = title))
}

