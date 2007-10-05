/*
 * keygen.c
 *  WEP Key Generators
 *
 * This program generates WEP keys using de facto standard key
 * generators for 40 and 128 bit keys.
 *
 * I place this code in the public domain.
 * May 2001, Tim Newsham
 */

/* jmc: slight tweaks - uses md5.c instead of libcrypto */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include "md5.h"

#define WEPKEYSIZE          5
#define WEPSTRONGKEYSIZE    13
#define WEPKEYS             4
#define WEPKEYSTORE         (WEPKEYSIZE * WEPKEYS)

/*
 * generate four subkeys from a seed using the defacto standard
 */
void
wep_seedkeygen(int val, u_char *keys)
{
    int i;

    for(i = 0; i < WEPKEYSTORE; i++) {
        val *= 0x343fd;
        val += 0x269ec3;
        keys[i] = val >> 16;
    }
    return;
}

/*
 * generate one key from a string using the de facto standard
 *
 * resultant key is stored in
 *   one 128 bit key: keys[0-15]
 *
 * (NOTE: I'm not sure why, but it seems that only values 0-12 are used,
 * resulting in 104 bits of keying, not 128)
 */
void
wep_keygen128(char *str, u_char *keys)
{
    md5_ctx_t ctx;
    u_char buf[64];
    int i, j;

    /* repeat str until buf is full */
    j = 0;
    for(i = 0; i < 64; i++) {
        if(str[j] == 0)
            j = 0;
        buf[i] = str[j++];
    }

    md5_begin(&ctx);
    md5_hash(buf, sizeof buf, &ctx);
    md5_end(buf, &ctx);

    memcpy(keys, buf, WEPKEYSTORE);

    for(i = 0; i < WEPSTRONGKEYSIZE; i++) {
        keys[i] = buf[i];
    }

    for(; i < WEPKEYSTORE; i++) {
        keys[i] = 0;
    }

    return;
}

/*
 * generate four subkeys from a string using the defacto standard
 *
 * resultant keys are stored in
 *   four 40 bit keys: keys[0-4], keys[5-9], keys[10-14] and keys[15-20]
 */
void
wep_keygen40(char *str, u_char *keys)
{
    int val, i, shift;

    /*
     * seed is generated by xor'ing in the keystring bytes
     * into the four bytes of the seed, starting at the little end
     */
    val = 0;
    for(i = 0; str[i]; i++) {
        shift = i & 0x3;
        val ^= (str[i] << (shift * 8));
    }

    wep_seedkeygen(val, keys);
    return;
}

void
wep_keyprint(u_char *keys)
{
    int i;
    char sepchar;

    for(i = 0; i < WEPKEYSTORE; i++) {
        sepchar = (i % WEPKEYSIZE == WEPKEYSIZE - 1) ? '\n' : ':';
        printf("%02x%c", keys[i], sepchar);
    }
    return;
}

void
usage(char *prog)
{
    printf("Usage:  %s [-s] keystring\n", prog);
    exit(1);
}

int
main(int argc, char **argv)
{
    u_char keys[WEPKEYSTORE];
    char *prog, *genstr;
    int strong, ch;

    prog = argv[0];
    strong = 0;
    while((ch = getopt(argc, argv, "s")) != EOF) {
        switch(ch) {
        case 's':
            strong ++;
            break;
        default:
            usage(prog);
        }
    }
    argc -= optind;
    argv += optind;

    if(argc != 1)
        usage(prog);
    genstr = argv[0];

    if(strong)
        wep_keygen128(genstr, keys);
    else
        wep_keygen40(genstr, keys);

    wep_keyprint(keys);
    return 0;
}