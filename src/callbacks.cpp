#include "tracer.h"
#include "callbacks.h"
#include "TracingState.hpp"
#include "utilities.h"
#include <instrumentr/instrumentr.h>


void process_parameter(ArgumentData& argument_data,
                       const std::string& package_name,
                       const std::string& function_name,
                       int call_id,
                       instrumentr_parameter_t parameter) {
    int parameter_id = instrumentr_object_get_id(parameter);
    int parameter_position = instrumentr_parameter_get_position(parameter);
    const std::string parameter_name(instrumentr_parameter_get_name(parameter));

    int vararg = instrumentr_parameter_is_vararg(parameter);

    int missing = instrumentr_parameter_is_missing(parameter);

    std::string expression_type;
    std::string value_type;
    int forced;

    if (missing) {
        expression_type = "";
        value_type = "";
        forced = NA_INTEGER;
    } else if (vararg) {
        expression_type = "";
        value_type = "";
        forced = true;

        int argument_count =
            instrumentr_parameter_get_argument_count(parameter);

        for (int index = 0; index < argument_count; ++index) {
            instrumentr_argument_t argument =
                instrumentr_parameter_get_argument_by_position(parameter,
                                                               index);
            if (!instrumentr_argument_is_evaluated(argument)) {
                forced = false;
                break;
            }
        }
    } else {
        instrumentr_argument_t argument =
            instrumentr_parameter_get_argument_by_position(parameter, 0);
        expression_type =
            get_type_as_string(instrumentr_argument_get_expression(argument));
        forced = instrumentr_argument_is_evaluated(argument);
        value_type =
            forced
                ? get_type_as_string(instrumentr_argument_get_value(argument))
                : "";
    }

    argument_data.push_back(parameter_id,
                            call_id,
                            package_name,
                            function_name,
                            parameter_position,
                            parameter_name,
                            vararg,
                            missing,
                            expression_type,
                            "",
                            value_type,
                            forced);
}

void call_exit_callback(instrumentr_tracer_t tracer,
                        instrumentr_callback_t callback,
                        instrumentr_application_t application,
                        instrumentr_package_t package,
                        instrumentr_function_t function,
                        instrumentr_call_t call) {
    TracingState* tracing_state = strictr_tracer_get_tracing_state(tracer);
    CallData& call_data = tracing_state->get_call_data();
    ArgumentData& argument_data = tracing_state->get_argument_data();

    const std::string package_name(instrumentr_package_get_name(package));
    const std::string function_name(instrumentr_function_get_name(function));

    int call_id = instrumentr_object_get_id(call);
    bool has_result = instrumentr_call_has_result(call);
    std::string result_type = "";
    if (has_result) {
        result_type = get_type_as_string(instrumentr_call_get_result(call));
    }

    call_data.push_back(
        call_id, package_name, function_name, has_result, result_type);

    int parameter_count = instrumentr_call_get_parameter_count(call);

    for (int index = 0; index < parameter_count; ++index) {
        instrumentr_parameter_t parameter =
            instrumentr_call_get_parameter_by_position(call, index);

        process_parameter(
            argument_data, package_name, function_name, call_id, parameter);
    }
}
