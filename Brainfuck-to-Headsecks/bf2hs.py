#!/usr/bin/env python3
import argparse
import sys
from random import randint

full = '0x0000-0x10FFFF'
latin = '0x0020-0x007E'
trigrams = '0x2630-0x2637'
chess = '0x2654-0x265F'
cyrillic = '0x0410-0x044F'
chinese = '0x4E00-0x9Fd5'
arabic = '0xFB50-0xFBA3'
gothic = '0x10330-0x1034A'

bf_ref = {
        '+' : 0,
        '-' : 1,
        '<' : 2,
        '>' : 3,
        '.' : 4,
        ',' : 5,
        '[' : 6,
        ']' : 7 }


# Check if selected unicode char is a surrogate
def validateChar(codepoint):
    if (codepoint >= 55296 and codepoint <= 56319) or (codepoint >= 56320 and codepoint <= 57343):
        return False
    else:
        return True

# Takes in brainfuck source code file, and a string denoting unicode character range
# returns headsecks code
def toHeadsecks(input_file, unicode_range):
    src = open(input_file, 'r')
    result = ''
    lower, upper = unicode_range.split('-')
    lower = int(lower, 16)
    upper = int(upper, 16)
    n = int((upper - lower) / 8)
   
   # Loop through lines
    for l in src:
        # Loop through characters
        for c in l.strip():
            # Check char is valid brainfuck char
            if c in bf_ref:
                # Pick random unicode char in allowed range. If surrogate char
                # is chosen, pick again
                while True:
                    uni_code = lower - (8 - (lower % 8)) + (8 * randint(0, n)) + bf_ref[c]

                    if uni_code > upper:
                        uni_code -= 8
                    elif uni_code < lower:
                        uni_code += 8

                    if validateChar(uni_code):
                        break
                    
                result += chr(uni_code)

    src.close()
    return result

# Takes in headsecks source code file, returns brainfuck code
def toBrainfuck(input_file):
    src = open(input_file, 'r')
    result = ''
    # Loop through lines
    for l in src:
        # Loop through characters
        for c in l.strip():
            uni = ord(c)
            mod_result = uni % 8
            for bf_c, mod_value in bf_ref.items():
                if mod_value == mod_result:
                    result += bf_c
                    continue
    src.close()
    return result


def main(args):
    if not (args.decode ^ args.encode):
        sys.exit('Select one of --encode --decode!')

    data = ''
    if args.decode:
        data = toBrainfuck(args.input_file)
    else:
        if args.trigram:
            data = toHeadsecks(args.input_file, trigrams)
        elif args.chess:
            data = toHeadsecks(args.input_file, chess)
        elif args.chinese:
            data = toHeadsecks(args.input_file, chinese)
        elif args.cyrillic:
            data = toHeadsecks(args.input_file, cyrillic)
        elif args.arabic:
            data = toHeadsecks(args.input_file, arabic)
        elif args.latin:
            data = toHeadsecks(args.input_file, latin)
        elif args.gothic:
            data = toHeadsecks(args.input_file, gothic)
        elif args.range != None:
            data = toHeadsecks(args.input_file, args.range)
        else:
            data = toHeadsecks(args.input_file, full)

    print(data)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('input_file', help='File containing the source code to convert')
    parser.add_argument('-d', '--decode', help='Decode source from Headsecks to Brainfuck', action='store_true')
    parser.add_argument('-e', '--encode', help='Encode source from Brainfuck to Headsecks', action='store_true')
    parser.add_argument('--random', help='Randomly select unicode characters upon encoding (default)', action='store_true')
    parser.add_argument('--trigram', help='Exclusively use trigram characters to encode', action='store_true')
    parser.add_argument('--chess', help='Exclusively use chess characters to encode', action='store_true')
    parser.add_argument('--latin', help='Exclusively use basic Latin characters to encode', action='store_true')
    parser.add_argument('--chinese', help='Exclusively use Chinese characters to encode', action='store_true')
    parser.add_argument('--cyrillic', help='Exclusively use Russian alphabet to encode', action='store_true')
    parser.add_argument('--arabic', help='Exclusively use Arabic characters to encode', action='store_true')
    parser.add_argument('--gothic', help='Exclusively use Gothic characters to encode', action='store_true')
    parser.add_argument('--range', help='User specified unicode characters to use for encoding. Input range of characters in form of a string e.g. \'0x1000-0x125D\'')

    args = parser.parse_args()
    main(args)
