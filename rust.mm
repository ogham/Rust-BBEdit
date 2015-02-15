#include <cstring>
#include <stack>

#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <ApplicationServices/ApplicationServices.h>

#include "BBLMInterface.h"
#include "BBLMTextIterator.h"

#define kMaxLineLength  256

static NSString* const identifierColour = @"me.bsago.bblm.rust.identifier";
static NSString* const lifetimeColour = @"me.bsago.bblm.rust.lifetime";
static NSString* const functionColour = @"me.bsago.bblm.rust.function";
static NSString* const moduleColour = @"me.bsago.bblm.rust.module";

static bool addRun(NSString *kind, int  start,int len , const BBLMCallbackBlock& bblm_callbacks)
{
    if (len > 0)
    {
        return bblmAddRun(&bblm_callbacks, 'Rust', kind, start, len, false);
    }
    else
    {
        return true;
    }
}

SInt32 skipString(BBLMTextIterator &iter)
{
    SInt32 length = 1;
    UniChar terminator = iter.GetNextChar();
    UniChar ch;

    while ((ch = iter.GetNextChar()))
    {
        length++;
        if (ch == terminator)
        {
            break;
        }

        if (ch == '\\')
        {
            iter++;
            length++;
        }
    }

    return length;
}

SInt32 skipLineComment(BBLMTextIterator &iter)
{
    SInt32 length = 2;
    UniChar ch;

    iter += 2;
    while ((ch = iter.GetNextChar()))
    {
        if (ch == '\n' || ch == '\r')
        {
            iter--;
            break;
        }
        else
        {
            length++;
        }
    }

    return length;
}

SInt32 skipBlockComment(BBLMTextIterator &iter)
{
    SInt32 length = 2;
    iter += 2;

    while (iter.strcmp("*/", 2) != 0)
    {
        iter++;
        length++;
    }

    iter += 2;
    length += 2;

    return length;
}

SInt32 skipWhitespace(BBLMTextIterator &iter)
{
    SInt32 length = 0;
    UniChar ch;

    while ((ch = iter.GetNextChar()))
    {
        if (isspace(ch))
        {
            length++;
        }
        else
        {
            iter--;
            break;
        }
    }

    return length;
}

SInt32 skipWord(BBLMTextIterator &iter)
{
    SInt32 length = 0;
    UniChar ch;

    while ((ch = iter.GetNextChar()))
    {
        if (isalpha(ch) || ch == '_' || (length > 0 && isdigit(ch)))
        {
            length++;
        }
        else
        {
            iter--;
            break;
        }
    }

    return length;
}

SInt32 skipAttribute(BBLMTextIterator &iter)
{
    SInt32 length = 1;
    UniChar ch;

    iter++;
    while ((ch = iter.GetNextChar()))
    {
        if (ch == '\n' || ch == '\r')
        {
            break;
        }
        else
        {
            length++;
        }
    }

    return length;
}

SInt32 skipNumber(BBLMTextIterator &iter)
{
    UInt32 length = 0;
    UniChar ch = iter.GetNextChar();
    bool hasSuffix = false;
    int base = 10;

    if (ch == '0')
    {
        ch = iter.GetNextChar();
        if (ch == 'x')
        {
            base = 16;
            length += 2;
        }
        else if (ch == 'b')
        {
            base = 2;
            length += 2;
        }
        else if (ch == 'o')
        {
            base = 8;
            length += 2;
        }
        else if (ch)
        {
            length++;
            iter--;
        }
    }
    else if (ch)
    {
        iter--;
    }

    while ((ch = iter.GetNextChar()))
    {
        if ((base == 10) && (isdigit(ch) || ((ch == '_' || ch == '.') && length > 0)))
        {
            length++;
        }
        else if ((base == 2) && (ch == '0' || ch == '1' || ((ch == '_' || ch == '.') && length > 0)))
        {
            length++;
        }
        else if ((base == 8) && ((ch >= '0' && ch <= '7') || ((ch == '_' || ch == '.') && length > 0)))
        {
            length++;
        }
        else if ((base == 16) && ((ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') || isdigit(ch) || ((ch == '_' || ch == '.') && length > 0)))
        {
            length++;
        }
        else if (ch == 'f' || ch == 'u' || ch == 'i')
        {
            length++;
            if (ch != 'f' && iter.strcmp("s", 1) == 0)
            {
                // Parse 'us' or 'is' machine-dependent suffixes
                length++;
            }
            else
            {
                // Otherwise, allow for numbers at the end
                hasSuffix = true;
            }
            break;
        }
        else
        {
            iter--;
            break;
        }
    }

    if (hasSuffix)
    {
        if (iter.strcmp("8", 1) == 0)
        {
            iter++;
            length++;
        }
        else if (iter.strcmp("16", 2) == 0 || iter.strcmp("32", 2) == 0 || iter.strcmp("64", 2) == 0)
        {
            iter += 2;
            length += 2;
        }
    }

    return length;
}

SInt32 skipToEndOfFunction(BBLMTextIterator &iter)
{
    SInt32 length = 0;
    UniChar ch;
    int braceLevel = 0, parenLevel = 0, bracketLevel = 0;

    while ((ch = iter.GetNextChar()))
    {
        length++;

        switch (ch) {
            case '/':
                ch = iter.GetNextChar();
                if (ch == '/')
                {
                    iter -= 2;
                    length += (skipLineComment(iter) - 1);
                }
                else if (ch == '*')
                {
                    iter -= 2;
                    length += (skipBlockComment(iter) - 1);
                }
                else if (ch)
                {
                    iter--;
                }
                break;

            case '{':
                braceLevel++;
                break;

            case '}':
                braceLevel--;
                if (braceLevel < 1) return length;
                break;

            case ';':
                // If the definition just ends with a semicolon, then it's
                // either a function in a trait definition, or a C function
                // definition in an extern, neither of which we want in the
                // function list.
                if (braceLevel < 1) return 0;
                break;

            case '(':
                parenLevel++;
                break;

            case ')':
                parenLevel--;
                break;

            case '[':
                bracketLevel++;
                break;

            case ']':
                bracketLevel--;
                break;
        }
    }

    return length;
}

SInt32 scanForSymbol(BBLMTextIterator &iter,
                     const char *keyword,
                     int typeIfSo,
                     int indentLevel,
                     BBLMParamBlock &params,
                     const BBLMCallbackBlock *callbacks)
{
    SInt32 whitespaceLen, wordLen;
    int keywordLen = strlen(keyword);

    if (iter.strcmp(keyword, keywordLen) == 0)
    {
        iter += keywordLen;
        if ((whitespaceLen = skipWhitespace(iter)))
        {
            bool is_test = iter.strcmp("test", 4) == 0;
            
            if ((wordLen = skipWord(iter)))
            {
                UInt32 funLen = skipToEndOfFunction(iter);
                
                // Skip over trait method definitions and extern functions
                if (funLen == 0)
                {
                    return 0;
                }
                
                // Ignore modules called 'test'
                if (strcmp(keyword, "mod") == 0 && is_test)
                {
                    return 0;
                }

                UInt32 tokenOffset, funIndex;
                UInt32 nameLen;
                BBLMProcInfo info;

                iter -= (wordLen + funLen);
                iter -= (keywordLen + whitespaceLen);

                nameLen = keywordLen + whitespaceLen + wordLen;

                bblmAddTokenToBuffer(callbacks, params.fFcnParams.fTokenBuffer, iter.Address(),
                                     nameLen, &tokenOffset);

                iter += (nameLen - wordLen);

                iter -= (keywordLen + whitespaceLen);
                info.fFirstChar   = info.fFunctionStart = iter.Offset();
                info.fSelStart    = iter.Offset() + keywordLen + whitespaceLen;
                info.fSelEnd      = info.fSelStart + wordLen;
                info.fFunctionEnd = info.fSelEnd + funLen;
                info.fIndentLevel = indentLevel;
                info.fKind        = typeIfSo;
                info.fFlags       = 0;
                info.fNameStart   = tokenOffset;
                info.fNameLength  = nameLen;
                bblmAddFunctionToList(callbacks, params.fFcnParams.fFcnList, info, &funIndex);
                bblmAddFoldRange(callbacks, info.fFunctionStart, funLen, kBBLMFunctionAutoFold);
                iter += (keywordLen + whitespaceLen);
                return info.fFunctionEnd;
            }
            else
            {
                iter -= (whitespaceLen + keywordLen);
            }
        }
        else
        {
            iter -= keywordLen;
        }
    }

    return 0;
}

static OSErr scanForFunctions(BBLMParamBlock &params, const BBLMCallbackBlock *callbacks)
{
    BBLMTextIterator iter(params);
    UniChar ch;
    std::stack<int> indents;
    SInt32 funEnd;

    while ((ch = iter.GetNextChar()))
    {
        while (!indents.empty() && iter.Offset() >= indents.top())
        {
            indents.pop();
        }

        const char* symbolToScanFor = NULL;
        int typeIfSo;

        switch (ch)
        {
            case '"':
                iter--;
                skipString(iter);
                break;

            case '/':
                ch = iter.GetNextChar();
                if (ch == '/')
                {
                    iter -= 2;
                    skipLineComment(iter);
                }
                else if (ch == '*')
                {
                    iter -= 2;
                    skipBlockComment(iter);
                }
                else if (ch)
                {
                    iter--;
                }
                break;

            case 'e':
                symbolToScanFor = "enum";
                typeIfSo = kBBLMFunctionMark;
                break;

            case 'f':
                symbolToScanFor = "fn";
                typeIfSo = kBBLMFunctionMark;
                break;

            case 'i':
                symbolToScanFor = "impl";
                typeIfSo = kBBLMTypedef;
                break;

            case 'm':
                symbolToScanFor = "mod";
                typeIfSo = kBBLMFunctionMark;
                break;

            case 's':
                symbolToScanFor = "struct";
                typeIfSo = kBBLMFunctionMark;
                break;

            case 't':
                symbolToScanFor = "trait";
                typeIfSo = kBBLMFunctionMark;
                break;
        }

        if (symbolToScanFor != NULL)
        {
            iter--;
            if ((funEnd = scanForSymbol(iter, symbolToScanFor, typeIfSo, indents.size(), params, callbacks)))
            {
                indents.push(funEnd);
            }
            else
            {
                iter++;
            }
        }
    }

    return noErr;
}

bool makeCodeRun(BBLMTextIterator &iter, SInt32 start, const BBLMCallbackBlock &callbacks)
{
    SInt32 len = iter.Offset() - start;
    if (len)
    {
        return addRun(kBBLMCodeRunKind, start, len, callbacks);
    }
    else
    {
        return true;
    }
}

OSErr calculateRuns(BBLMParamBlock &params, const BBLMCallbackBlock *callbacks)
{
    // BBLMTextIterator iter(params, params.fCalcRunParams.fStartOffset);
    BBLMTextIterator iter(params, 0);
    SInt32 runStart = iter.Offset();
    SInt32 runLen;

    UniChar ch;
    bool wordchr = false;
    while ((ch = iter.GetNextChar()))
    {
        if (ch == '"')
        {
            iter--;
            if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
            runStart = iter.Offset();
            runLen = skipString(iter);
            if (!addRun(kBBLMDoubleQuotedStringRunKind, runStart, runLen, *callbacks)) return noErr;
            runStart = iter.Offset();
        }

        // Have to distinguish the following things:
        // 'a'  (character)
        // '\a' (escaped character)
        // 'a   (lifetime)
        else if (ch == '\'')
        {
            ch = iter.GetNextChar();
            if (ch == '\\')
            {
                ch = iter.GetNextChar();
                if (ch)
                {
                    ch = iter.GetNextChar();
                    if (ch == '\'')
                    {
                        iter -= 4;
                        if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
                        runStart = iter.Offset();
                        runLen = 4;
                        iter += 4;
                        if (!addRun(kBBLMSingleQuotedStringRunKind, runStart, runLen, *callbacks)) return noErr;
                        runStart = iter.Offset();
                    }
                    else if (ch)
                    {
                        iter--;
                    }
                }
            }
            else if (ch)
            {
                ch = iter.GetNextChar();
                if (ch == '\'')
                {
                    iter -= 3;
                    if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
                    runStart = iter.Offset();
                    runLen = 3;
                    iter += 3;
                    if (!addRun(kBBLMSingleQuotedStringRunKind, runStart, runLen, *callbacks)) return noErr;
                    runStart = iter.Offset();
                }
                else if (ch)
                {
                    iter -= 3;
                    if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
                    runStart = iter.Offset();
                    iter++;
                    runLen = 1 + skipWord(iter);
                    if (!addRun(lifetimeColour, runStart, runLen, *callbacks)) return noErr;
                    runStart = iter.Offset();
                }
            }
        }

        else if (!wordchr && ch == 'm')
        {
            ch = iter.GetNextChar();
            if (ch == 'o')
            {
                ch = iter.GetNextChar();
                if (ch == 'd')
                {
                    ch = iter.GetNextChar();
                    if (isspace(ch))
                    {
                        if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
                        runStart = iter.Offset();
                        runLen = skipWhitespace(iter);
                        runLen += skipWord(iter);
                        if (!addRun(moduleColour, runStart, runLen, *callbacks)) return noErr;
                        runStart = iter.Offset();
                    }
                    else if (ch)
                    {
                        iter--;
                    }
                }
                else if (ch)
                {
                    iter--;
                }
            }
            else if (ch == 'a')
            {
                // I am ashamed of how nested this code is.
                ch = iter.GetNextChar();
                if (ch == 'c')
                {
                    ch = iter.GetNextChar();
                    if (ch == 'r')
                    {
                        ch = iter.GetNextChar();
                        if (ch == 'o')
                        {
                            ch = iter.GetNextChar();
                            if (ch == '_')
                            {
                                ch = iter.GetNextChar();
                                if (ch == 'r')
                                {
                                    ch = iter.GetNextChar();
                                    if (ch == 'u')
                                    {
                                        ch = iter.GetNextChar();
                                        if (ch == 'l')
                                        {
                                            ch = iter.GetNextChar();
                                            if (ch == 'e')
                                            {
                                                ch = iter.GetNextChar();
                                                if (ch == 's')
                                                {
                                                    ch = iter.GetNextChar();
                                                    if (ch == '!')
                                                    {
                                                        ch = iter.GetNextChar();
                                                        if (isspace(ch))
                                                        {
                                                            if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
                                                            runStart = iter.Offset();
                                                            runLen = skipWhitespace(iter);
                                                            runLen += skipWord(iter);
                                                            if (!addRun(functionColour, runStart, runLen, *callbacks)) return noErr;
                                                            runStart = iter.Offset();
                                                        }
                                                        else if (ch)
                                                        {
                                                            iter--;
                                                        }
                                                    }
                                                    else if (ch)
                                                    {
                                                        iter--;
                                                    }
                                                }
                                                else if (ch)
                                                {
                                                    iter--;
                                                }
                                            }
                                            else if (ch)
                                            {
                                                iter--;
                                            }
                                        }
                                        else if (ch)
                                        {
                                            iter--;
                                        }
                                    }
                                    else if (ch)
                                    {
                                        iter--;
                                    }
                                }
                                else if (ch)
                                {
                                    iter--;
                                }
                            }
                            else if (ch)
                            {
                                iter--;
                            }
                        }
                        else if (ch)
                        {
                            iter--;
                        }
                    }
                    else if (ch)
                    {
                        iter--;
                    }
                }
                else if (ch)
                {
                    iter--;
                }
            }
            else if (ch)
            {
                iter--;
            }
        }

        else if (!wordchr && ch == 'f')
        {
            ch = iter.GetNextChar();
            if (ch == 'n')
            {
                ch = iter.GetNextChar();
                if (isspace(ch))
                {
                    if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
                    runStart = iter.Offset();
                    runLen = skipWhitespace(iter);
                    runLen += skipWord(iter);
                    if (!addRun(functionColour, runStart, runLen, *callbacks)) return noErr;
                    runStart = iter.Offset();
                }
                else if (ch)
                {
                    iter--;
                }
            }
            else if (ch)
            {
                iter--;
            }
        }

        else if (!wordchr && ch == 'u')
        {
            ch = iter.GetNextChar();
            if (ch == 's')
            {
                ch = iter.GetNextChar();
                if (ch == 'e')
                {
                    ch = iter.GetNextChar();
                    if (isspace(ch))
                    {
                        skipWhitespace(iter);
                        if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;

                        runStart = iter.Offset();
                        runLen = 0;
                        bool spacey = false;

                        while ((ch = iter.GetNextChar()))
                        {
                            if (spacey && isupper(ch))
                            {
                                iter--;
                                if (!addRun(kBBLMFileIncludeRunKind, runStart, runLen, *callbacks)) return noErr;

                                runStart = iter.Offset();
                                runLen = skipWord(iter);
                                if (!addRun(identifierColour, runStart, runLen, *callbacks)) return noErr;

                                runStart = iter.Offset();
                                runLen = 0;
                            }
                            else if (ch == ';' || ch == '\n')
                            {
                                iter--;
                                if (!addRun(kBBLMFileIncludeRunKind, runStart, runLen, *callbacks)) return noErr;
                                break;
                            }
                            else
                            {
                                spacey = isspace(ch) || ch == ':' || ch == '{';
                                runLen++;
                            }
                        }

                        if (!addRun(kBBLMFileIncludeRunKind, runStart, runLen, *callbacks)) return noErr;

                        runStart = iter.Offset();
                        runLen = skipWord(iter);
                    }
                    else if (ch)
                    {
                        iter--;
                    }
                }
                else if (ch)
                {
                    iter--;
                }
            }
            else if (ch)
            {
                iter--;
            }
        }

        else if (ch == '/')
        {
            ch = iter.GetNextChar();
            if (ch == '/')
            {
                iter -= 2;
                if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
                runStart = iter.Offset();
                runLen = skipLineComment(iter);
                if (!addRun(kBBLMLineCommentRunKind, runStart, runLen, *callbacks)) return noErr;
                runStart = iter.Offset();
            }
            else if (ch == '*')
            {
                iter -= 2;
                if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
                runStart = iter.Offset();
                runLen = skipBlockComment(iter);
                if (!addRun(kBBLMBlockCommentRunKind, runStart, runLen, *callbacks)) return noErr;
                runStart = iter.Offset();
            }
            else if (ch)
            {
                iter--;
            }
        }

        else if (ch == '#')
        {
            iter--;
            if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
            runStart = iter.Offset();
            runLen = skipAttribute(iter);
            if (!addRun(kBBLMPreprocessorRunKind, runStart, runLen, *callbacks)) return noErr;
            runStart = iter.Offset();
        }
        
        else if (ch == '$')
        {
            iter--;
            if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
            runStart = iter.Offset();
            iter++;
            runLen = skipWord(iter) + 1;
            if (runLen > 1 && !addRun(kBBLMVariableRunKind, runStart, runLen, *callbacks)) return noErr;
            runStart = iter.Offset();
        }

        else if (!wordchr && isupper(ch))
        {
            iter--;
            if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
            runStart = iter.Offset();
            runLen = skipWord(iter);
            if (!addRun(identifierColour, runStart, runLen, *callbacks)) return noErr;
            runStart = iter.Offset();
        }

        else if (!wordchr && (ch == '+' || ch == '-'))
        {
            ch = iter.GetNextChar();
            if (isdigit(ch))
            {
                iter -= 2;
                if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
                iter++;
                runStart = iter.Offset() - 1;
                runLen = skipNumber(iter) + 1;
                if (!addRun(kBBLMNumberRunKind, runStart, runLen, *callbacks)) return noErr;
                runStart = iter.Offset();
            }
            else if (ch)
            {
                iter--;
            }
        }

        else if (!wordchr && isdigit(ch))
        {
            iter--;
            if (!makeCodeRun(iter, runStart, *callbacks)) return noErr;
            runStart = iter.Offset();
            runLen = skipNumber(iter);
            if (!addRun(kBBLMNumberRunKind, runStart, runLen, *callbacks)) return noErr;
            runStart = iter.Offset();
        }

        wordchr = isalpha(ch) || isdigit(ch) || ch == '_';
    }

    makeCodeRun(iter, runStart, *callbacks);
    return noErr;
}

/*static bool isSpecialKind(NSString* kind)
{
    return [kBBLMBlockCommentRunKind isEqualToString:kind]
        || [kBBLMLineCommentRunKind isEqualToString:kind]
        || [identifierColour isEqualToString:kind]
        || [attributeColour isEqualToString:kind]
        || [lifetimeColour isEqualToString:kind]
        || [functionColour isEqualToString:kind];
}*/

OSErr adjustRange(BBLMParamBlock &params, const BBLMCallbackBlock &callbacks)
{
    DescType language;
    NSString* kind;
    SInt32 charPos;
    SInt32 length;
    UInt32 index = params.fAdjustRangeParams.fStartIndex;

    while (index > 0 && bblmGetRun(&callbacks, index, language, kind, charPos, length)/* && isSpecialKind(kind)*/)
    {
        index--;
    }

    params.fAdjustRangeParams.fStartIndex = index;
    return noErr;
}

OSErr guessLanguage(BBLMParamBlock &params)
{
    BBLMTextIterator iter(params);

    if (iter.strcmp("use ", 4) == 0 || iter.strcmp("#![crate_id", 11) == 0)
    {
        params.fGuessLanguageParams.fGuessResult = kBBLMGuessDefiniteYes;
    }

    return noErr;
}

#pragma mark -

extern "C"
{
    OSErr rustMain(BBLMParamBlock &params, const BBLMCallbackBlock &bblmCallbacks);
    OSErr rustMain(BBLMParamBlock &params, const BBLMCallbackBlock &bblmCallbacks)
    {
        // Dispatch message.
        OSErr result = noErr;

        switch (params.fMessage)
        {
            case kBBLMDisposeMessage:
            case kBBLMSetCategoriesMessage:
                // Message understood, but no action required.
                break;

            case kBBLMInitMessage:
                break;

            case kBBLMScanForFunctionsMessage:
                result = scanForFunctions(params, &bblmCallbacks);
                break;

            case kBBLMCalculateRunsMessage:
                result = calculateRuns(params, &bblmCallbacks);
                break;

            case kBBLMGuessLanguageMessage:
                result = guessLanguage(params);
                break;

            case kBBLMAdjustRangeMessage:
                result = adjustRange(params, bblmCallbacks);
                break;

            default:
                result = paramErr;
        }

        return result;
    }
}
