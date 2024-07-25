/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PPBOMLVLCL - Build PBOMLVL file                                  */
/*  22 January 2019                                                  */
/*  Mike Rooker                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 P2PLIGHTCL: PGM  PARM(&WHSE)

    /* Variables */
             DCL        VAR(&WHSE) TYPE(*CHAR) LEN(3)

    /* Call program to rebuild PBOMLVL */
             CALL       PBLDBOMLVL (&WHSE)

    /* Reorganize PBOMLVL file */
             RGZPFM     FILE(PBOMLVL)

             ENDPGM
