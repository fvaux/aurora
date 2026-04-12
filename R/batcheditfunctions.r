get_editable_columns <- function(df, protected_cols) {
  setdiff(colnames(df), protected_cols)
}


get_matchable_columns <- function(df, protected_cols) {
  setdiff(colnames(df), protected_cols)
}


bulk_preview_edit <- function(df, match_col, match_val, edit_col, new_val) {
  
  rows <- df[[match_col]] == match_val
  
  df_preview <- df
  
  df_preview[rows, edit_col] <- paste0("→ ", new_val)
  
  list(
    preview = df_preview,
    rows_changed = sum(rows, na.rm = TRUE)
  )
}


bulk_apply_edit <- function(df, match_col, match_val, edit_col, new_val) {
  
  rows <- df[[match_col]] == match_val
  
  df[rows, edit_col] <- new_val
  
  df
}