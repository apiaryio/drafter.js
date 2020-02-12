#include "cparse.h"

#include <cstring>
#include <cstdlib>

#include "drafter.h"

drafter_serialize_options* c_serialize_json_options()
{
    drafter_serialize_options* result = drafter_init_serialize_options();
    drafter_set_format(result, DRAFTER_SERIALIZE_JSON);
    return result;
}

char** c_buffer_ptr()
{
    char** result = new char*(nullptr);
    return result;
}

const char* c_buffer_string(const char** buf) { return *buf; }

void c_free_buffer_ptr(char** ptr)
{
    if (ptr) free(*ptr);
    delete ptr;
}

int c_parse_to(const char* source, char** result,
               const drafter_parse_options* parseOpts,
               const drafter_serialize_options* serializeOpts)
{
    return drafter_parse_blueprint_to(source, result, parseOpts, serializeOpts);
}

int c_validate_to(const char* source, char** result,
                  const drafter_parse_options* parseOpts)
{
    drafter_result* checkResult = nullptr;
    int checkError = drafter_check_blueprint(source, &checkResult, parseOpts);

    if (!checkResult) return checkError;

    drafter_serialize_options* serializeOpts = c_serialize_json_options();

    drafter_set_sourcemaps_included(serializeOpts);
    *result = drafter_serialize(checkResult, serializeOpts);

    drafter_free_result(checkResult);
    drafter_free_serialize_options(serializeOpts);

    return 1;
}
