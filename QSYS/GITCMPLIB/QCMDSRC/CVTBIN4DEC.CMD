/* CVTBIN4DEC - Convert binary 4 value to decimal                  */
/*PARMS PGM(CVTBIN4DEC) ALLOW((*IPGM)(*BPGM)) PRDLIB(GFGTOOL)      */
/*                                                                 */
/* The CVTBIN4DEC command converts a 4 byte binary field to a      */
/*   decimal field of 9 digits and 0 decimals. The command is      */
/*   similar to the CVTBINDEC command in GFGTOOL which converts    */
/*   a 2 byte binary field.                                        */
/*                                                                 */
/*   The CPP is CVTBIN4DEC which is an RPG program.                */
/*                                                                 */
             CMD        PROMPT('Convert from Bin 4 to decimal')
             PARM       KWD(FROMBIN) TYPE(*CHAR) LEN(4) MIN(1) +
                          PROMPT('From character variable    (4)')
             PARM       KWD(TODEC) TYPE(*DEC) LEN(9 0) RTNVAL(*YES) +
                          MIN(1) PROMPT('To decimal variable      +
                          (9 0)')
             PARM       KWD(SETLR) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*OFF) VALUES('*OFF' '*ON') +
                          PROMPT('Set LR for program return')
