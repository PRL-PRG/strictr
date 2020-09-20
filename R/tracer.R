
#' @importFrom instrumentr create_context
create_strictness_tracer <- function() {
    tracer <- create_context(
        call_exit_callback = call_exit_callback,
        packages = setdiff(get_installed_packages(), c("base", "injectr"))
    )

    initialize_tracing_data(tracer)
}

#' @export
#' @importFrom instrumentr trace_code
trace_strictness <- function(code, environment = parent.frame(), quote = TRUE) {
    tracer <- create_strictness_tracer()

    if(quote) {
        code <- substitute(code)
    }

    trace_code(tracer, code, environment = environment, quote = FALSE)

    extract_tracing_data(tracer)
}

#' @importFrom instrumentr get_name get_id get_position
#' @importFrom instrumentr get_data is_successful get_result
#' @importFrom instrumentr get_parameters
call_exit_callback <- function(context,
                               application,
                               package,
                               fun,
                               call) {
    data <- get_data(context)

    package_name <- get_name(package)
    function_name <- get_name(fun)
    call_id <- get_id(call)
    successful <- is_successful(call)
    result_type <- if(successful) {
                       typeof(get_result(call))
                   } else {
                       NA_character_
                   }

    for(parameter in get_parameters(call)) {
        process_parameter(data, package_name, function_name, call_id, parameter)
    }

    add_call_data(data,
                  call_id = call_id,
                  package_name = package_name,
                  function_name = function_name,
                  successful = successful,
                  result_type = result_type)
}

#' @importFrom instrumentr get_name get_id get_position
#' @importFrom instrumentr is_vararg is_missing
#' @importFrom instrumentr get_arguments  get_argument
#' @importFrom instrumentr is_evaluated get_expression
process_parameter <- function(data, package_name, function_name, call_id, parameter) {

    parameter_id <- get_id(parameter)
    parameter_position <- get_position(parameter)
    parameter_name <- get_name(parameter)
    vararg <- is_vararg(parameter)
    param_missing <- is_missing(parameter)

    if(param_missing) {
        expression_type <- NA_character_
        value_type <- NA_character_
        forced <- NA_integer_
    }
    else if(vararg) {
        expression_type <- NA_character_
        value_type <- NA_character_
        forced <- all(sapply(get_arguments(parameter), is_evaluated))
    }
    else {
        argument <- get_argument(parameter, 1)
        expression_type <- typeof(get_expression(argument))
        forced <- is_evaluated(argument)
        value_type <- if(forced) {
                          typeof(get_expression(argument))
                      } else {
                          NA_character_
                      }
    }

    add_argument_data(data,
                      parameter_id = parameter_id,
                      call_id = call_id,
                      package_name = package_name,
                      function_name = function_name,
                      parameter_position = parameter_position,
                      parameter_name = parameter_name,
                      vararg = vararg,
                      missing = param_missing,
                      expression_type = expression_type,
                      value_type = value_type,
                      forced = forced)
}
