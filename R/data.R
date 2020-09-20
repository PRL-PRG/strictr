
#' @importFrom instrumentr set_data
initialize_tracing_data <- function(tracer) {
    calls <- hash_table()
    arguments <- hash_table()
    state <- hash_table()

    data <- hash_table(calls = calls,
                       arguments = arguments,
                       state = state)

    set_data(tracer, data)

    tracer
}

#' @importFrom instrumentr get_data
extract_tracing_data <- function(tracer) {
    data <- get_data(tracer)

    list(calls = to_data_frame(data$calls),
         arguments = to_data_frame(data$arguments))
}

#' @export
#' @importFrom purrr imap_chr
#' @importFrom fst write_fst
write_tracing_data <- function(data, dirpath = getwd()) {
    writer <- function(df, filename) {
        filepath <- file.path(dirpath, paste0(filename, ".fst"))
        write_fst(df, filepath)
        filepath
    }
    imap_chr(data, writer)
}

add_call_data <- function(data,
                          call_id = NA_integer_,
                          package_name = NA_character_,
                          function_name = NA_character_,
                          successful = NA_integer_,
                          result_type = NA_character_,
                          force_order = NA_character_,
                          c_call_count = NA_integer_,
                          r_call_count = NA_integer_,
                          c_execution_time = NA_real_,
                          r_execution_time = NA_real_) {

    row <- data.frame(call_id = call_id,
                      package_name = package_name,
                      function_name = function_name,
                      successful = successful,
                      result_type = result_type,
                      force_order = force_order,
                      c_call_count = c_call_count,
                      r_call_count = r_call_count,
                      c_execution_time = c_execution_time,
                      r_execution_time = r_execution_time)

    assign(as.character(call_id), row, envir = data$calls)

    data
}

add_argument_data <- function(data,
                              parameter_id = NA_integer_,
                              call_id = NA_integer_,
                              package_name = NA_character_,
                              function_name = NA_character_,
                              parameter_position = NA_integer_,
                              parameter_name = NA_character_,
                              vararg = NA_integer_,
                              missing = NA_integer_,
                              expression_type = NA_character_,
                              transitive_type = NA_character_,
                              value_type = NA_character_,
                              forced = NA_integer_,
                              metaprogrammed = NA_integer_,
                              lookup_count = NA_integer_,
                              force_depth = NA_integer_,
                              force_source = NA_integer_,
                              escaped = NA_integer_,
                              event_sequence = NA_character_,
                              evaluation_time = NA_real_) {

    row <- data.frame(parameter_id = parameter_id,
                      call_id = call_id,
                      package_name = package_name,
                      function_name = function_name,
                      parameter_position = parameter_position,
                      parameter_name = parameter_name,
                      vararg = vararg,
                      missing = missing,
                      expression_type = expression_type,
                      transitive_type = transitive_type,
                      value_type = value_type,
                      forced = forced,
                      metaprogrammed = metaprogrammed,
                      lookup_count = lookup_count,
                      force_depth = force_depth,
                      escaped = escaped,
                      event_sequence = event_sequence,
                      evaluation_time = evaluation_time)

    assign(as.character(parameter_id), row, envir = data$arguments)

    data
}
