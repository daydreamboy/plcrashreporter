/*
 * Author: Mike Ash <mikeash@plausiblelabs.com>
 *
 * Copyright (c) 2012 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef PLCrashAsyncObjCSection_h
#define PLCrashAsyncObjCSection_h

#include "PLCrashAsyncMachOImage.h"
#include "PLCrashAsyncMachOString.h"


/**
 * A context object that helps ObjC parsing go faster by caching information
 * across multiple calls.
 */
typedef struct pl_async_objc_context {
    bool gotObjC2Info;
    
    size_t classCacheSize;
    pl_vm_address_t *classCacheKeys;
    pl_vm_address_t *classCacheValues;
} pl_async_objc_context_t;

plcrash_error_t pl_async_objc_context_init (pl_async_objc_context_t *context);
void pl_async_objc_context_free (pl_async_objc_context_t *context);

/**
 * A callback to invoke when an Objective-C method is found.
 *
 * @param className A pointer to a string containing the class's name. Not NUL
 * terminated.
 * @param classNameLength The length of the class name string, in bytes.
 * @param methodName A pointer to a string containing the method's name. Not
 * NUL terminated.
 * @param methodNameLength The length of the method name string, in bytes.
 * @param imp The method's IMP (function pointer to the method's implementation).
 * @param ctx The context pointer specified by the original caller.
 */
typedef void (*pl_async_objc_found_method_cb)(bool isClassMethod, plcrash_async_macho_string_t *className, plcrash_async_macho_string_t *methodName, pl_vm_address_t imp, void *ctx);

plcrash_error_t pl_async_objc_parse (pl_async_macho_t *image, pl_async_objc_context_t *objcContext, pl_async_objc_found_method_cb callback, void *ctx);

plcrash_error_t pl_async_objc_find_method (pl_async_macho_t *image, pl_async_objc_context_t *objcContext, pl_vm_address_t imp, pl_async_objc_found_method_cb callback, void *ctx);

#endif // PLCrashAsyncObjCSection_h