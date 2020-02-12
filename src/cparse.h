#ifndef CPARSE_H
#define CPARSE_H 1

#ifdef __cplusplus
extern "C" {
#endif

struct drafter_parse_options;
struct drafter_serialize_options;

drafter_serialize_options* c_serialize_json_options();

char** c_buffer_ptr();

const char* c_buffer_string(const char**);

void c_free_buffer_ptr(char**);

int c_parse_to(const char*, char**, const drafter_parse_options*,
               const drafter_serialize_options*);

int c_validate_to(const char*, char**, const drafter_parse_options*);

#ifdef __cplusplus
}
#endif

#endif
