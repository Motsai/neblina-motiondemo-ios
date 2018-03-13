/***********************************************************************************
* Copyright (c) 2010 - 2018, Motsai
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
***********************************************************************************/

#pragma once

/**********************************************************************************/

#include <assert.h>

/**********************************************************************************/

#if defined(NDEBUG)
#define     NEBLINA_ASSERT(cond, msg)
#else
#define     NEBLINA_ASSERT(cond, msg)      assert(cond && msg)
#endif

/**********************************************************************************/

#if defined(_WIN32) || defined(_WIN64)
#define NEBLINA_WINDOWS
#elif defined(__APPLE__) || defined(__MACH__)
#define NEBLINA_APPLE
#elif defined(unix) || defined(__unix) || defined(__unix__)
#define NEBLINA_LINUX
#else
#define NEBLINA_EMBEDDED
#endif

/**********************************************************************************/

#if defined(NEBLINA_WINDOWS)
#define NEBLINA_EXPORT __declspec(dllexport)
#define NEBLINA_IMPORT __declspec(dllimport)
#else
#define NEBLINA_EXPORT
#define NEBLINA_IMPORT
#endif

#if defined(NEBLINA_DLL)
#define NEBLINA_EXTERN NEBLINA_EXPORT
#else
#define NEBLINA_EXTERN NEBLINA_IMPORT
#endif

/**********************************************************************************/

#if defined(__GNUC__)
#define NEBLINA_ATTRIBUTE_PACKED(X) __attribute__((packed)) X
#else
#define NEBLINA_ATTRIBUTE_PACKED(X) X
#endif

/**********************************************************************************/

#define     NEBLINA_PACKET_LENGTH_MAX                           40

/**********************************************************************************/
