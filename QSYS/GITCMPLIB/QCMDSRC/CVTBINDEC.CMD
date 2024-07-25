/* CVTBIBDEC- Convert binary value to decimal - CVTBINDEC cmd       */
/*PARMS PGM(TAABINAR) ALLOW((*IPGM)(*BPGM))                        */
/*                                                                 */
/* The CVTBINDEC command converts a 2 byte binary field which      */
/*   is specified as character to a 5 byte decimal field. This     */
/*   command is useful for dealing with lists passed from          */
/*   commands.                                                     */
/*                                                                 */
/* The CPP is the RPG program CVTBINDEC                            */
/*                                                                 */
             CMD        PROMPT('Convert from binary to decimal')
             PARM       KWD(FROMBIN) TYPE(*CHAR) LEN(2) MIN(1) +
                          PROMPT('From character variable    (2)')
             PARM       KWD(TODEC) TYPE(*DEC) LEN(5 0) RTNVAL(*YES) +
                          MIN(1) +
                          PROMPT('To decimal variable      (5 0)')
