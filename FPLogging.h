/*
 *  FPLogging.h
 *  FormulatePro
 *
 *  Created by Andrew de los Reyes on 9/3/07.
 *  Copyright 2007 Andrew de los Reyes. All rights reserved.
 *
 */

#import <os/log.h>

// from http://www.cocoabuilder.com/archive/message/cocoa/2002/2/7/50783
#if DEBUG
static inline void DLog(NSString *format, ...)
{
    va_list args;

    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
}
#else
static inline void DLog(NSString *format, ...) { }
#endif

// FPCheck — soft assertion. If `cond` is false, log an error via os_log and
// run `fallback_stmt` (e.g. `return nil;`, `continue;`, `return FPToolArrow;`).
// In Debug builds, also trips assert() so the failure stops a debugger.
//
// Use instead of assert(...) at site where the condition can plausibly fail
// in the wild (corrupt input, race, missing resource) and the program can
// keep running with a sane fallback. Pure invariants that can NEVER fail
// can stay as assert().
#if DEBUG
#define FPCheck(cond, fallback_stmt) \
    do { \
        if (__builtin_expect(!(cond), 0)) { \
            os_log_error(OS_LOG_DEFAULT, \
                         "FPCheck failed: %{public}s at %{public}s:%d", \
                         #cond, __FILE__, __LINE__); \
            assert(cond); \
            fallback_stmt; \
        } \
    } while (0)
#else
#define FPCheck(cond, fallback_stmt) \
    do { \
        if (__builtin_expect(!(cond), 0)) { \
            os_log_error(OS_LOG_DEFAULT, \
                         "FPCheck failed: %{public}s at %{public}s:%d", \
                         #cond, __FILE__, __LINE__); \
            fallback_stmt; \
        } \
    } while (0)
#endif
