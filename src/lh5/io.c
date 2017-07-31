/***********************************************************
        io.c -- input/output
***********************************************************/
#include "ar.h"
#include <stdlib.h>
#include <stdarg.h>

#define CRCPOLY  0xA001  /* ANSI CRC-16 */
                         /* CCITT: 0x8408 */
#define UPDATE_CRC(c) \
        crc = crctable[(crc ^ (c)) & 0xFF] ^ (crc >> CHAR_BIT)

FILE *arcfile, *infile, *outfile;
uint crc, bitbuf;

static ushort crctable[UCHAR_MAX + 1];
static uint  subbitbuf;
static int   bitcount;

void error(char *fmt, ...)
{
        va_list args;

        va_start(args, fmt);
        putc('\n', stderr);
        vfprintf(stderr, fmt, args);
        putc('\n', stderr);
        va_end(args);
        exit(EXIT_FAILURE);
}

void make_crctable(void)
{
        uint i, j, r;

        for (i = 0; i <= UCHAR_MAX; i++) {
                r = i;
                for (j = 0; j < CHAR_BIT; j++)
                        if (r & 1) r = (r >> 1) ^ CRCPOLY;
                        else       r >>= 1;
                crctable[i] = r;
        }
}

void fillbuf(int n)  /* Shift bitbuf n bits left, read n bits */
{
        bitbuf <<= n;
        while (n > bitcount) {
                bitbuf |= subbitbuf << (n -= bitcount);
                if (compsize != 0) {
                        compsize--;  subbitbuf = getc_arcfile(); // (uchar) getc(arcfile);
                } else subbitbuf = 0;
                bitcount = CHAR_BIT;
        }
        bitbuf |= subbitbuf >> (bitcount -= n);
}

uint getbits(int n)
{
        uint x;
        if (!n) return 0; /* shift by 32 gives error in MSVC 7.1 */

        x = bitbuf >> (BITBUFSIZ - n);  fillbuf(n);
        return x;
}

void putbits(int n, uint x)  /* Write rightmost n bits of x */
{
        if (n < bitcount) {
                subbitbuf |= x << (bitcount -= n);
        } else {
                if (compsize < origsize) {
                        putc(subbitbuf | (x >> (n -= bitcount)), outfile);
                        compsize++;
                } else unpackable = 1;
                if (n < CHAR_BIT) {
                        subbitbuf = x << (bitcount = CHAR_BIT - n);
                } else {
                        if (compsize < origsize) {
                                putc(x >> (n - CHAR_BIT), outfile);
                                compsize++;
                        } else unpackable = 1;
                        subbitbuf = x << (bitcount = 2 * CHAR_BIT - n);
                }
        }
}

int fread_crc(uchar *p, int n, FILE *f)
{
        int i;

        i = n = fread(p, 1, n, f);  origsize += n;
        while (--i >= 0) UPDATE_CRC(*p++);
        return n;
}

void fwrite_crc(uchar *p, int n, FILE *f)
{
		if (fwrite(p, 1, n, f) < n) error("Unable to write");
        while (--n >= 0) UPDATE_CRC(*p++);
}

void init_getbits(void)
{
        bitbuf = 0;  subbitbuf = 0;  bitcount = 0;
        fillbuf(BITBUFSIZ);
}

void init_putbits(void)
{
        bitcount = CHAR_BIT;  subbitbuf = 0;
}
