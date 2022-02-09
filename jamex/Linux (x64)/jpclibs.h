/*-------------------------------------------------*/
/*-   Public header file for JPC shared library   -*/
/*-------------------------------------------------*/

/* --------------------------------------------------
   This file is part of the JPC shared library. This
   indended use of this library is used to communicate
   with Jamex JPC enabled vending device only. All
   other uses of this library will be deemed illegal
   and subject to legal and financial recourse.
   --------------------------------------------------*/

#ifndef JPCLIBS_H
#define JPCLIBS_H

#if defined(_MSC_VER)
    //  Microsoft
    #define JPC_API_EXPORT extern "C" __declspec(dllexport)
    #define JPC_API_IMPORT __declspec(dllimport)
#elif defined(__GNUC__)
    //  GCC
    #define JPC_API_EXPORT extern "C" __attribute__((visibility("default")))
    #define JPC_API_IMPORT
#else
    //  Other
    #define JPC_API_EXPORT
    #define JPC_API_IMPORT
    #pragma warning Unknown dynamic link import/export semantics.
#endif

JPC_API_EXPORT void*        jpc_get_handle();
JPC_API_EXPORT void         jpc_destroy(void* handle);
JPC_API_EXPORT bool         jpc_open(void* handle);
JPC_API_EXPORT bool         jpc_open_port(void* handle, const char* port);
JPC_API_EXPORT bool         jpc_close(void* handle);

JPC_API_EXPORT int          jpc_get_error(void* handle);
JPC_API_EXPORT int          jpc_get_funds_type(void* handle);

JPC_API_EXPORT double       jpc_read_value(void* handle);
JPC_API_EXPORT bool         jpc_add_value(void* handle, const double value);
JPC_API_EXPORT bool         jpc_deduct_value(void* handle, const double value);
JPC_API_EXPORT bool         jpc_return_value(void* handle);

JPC_API_EXPORT const char*  jpc_get_serial_number(void* handle);

JPC_API_EXPORT void         jpc_set_options(void* handle, const bool fundsReturn, const bool coinAccept, const bool billAccept, const bool cardAccept);
JPC_API_EXPORT void         jpc_display_message(void* handle, const char* message);
JPC_API_EXPORT void         jpc_print_receipt_line(void* handle, const char* line, int numOfCarriageReturns, bool cut);


JPC_API_EXPORT bool          jpc_validate_keys(void* handle, const char* deviceSN, const char* jamexSN, const char* regKey);


#endif // JPCLIBS_H
