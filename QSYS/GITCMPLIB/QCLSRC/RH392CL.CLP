/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH392CL   Items details by pallet                                */
/*  26 August, 2000                                                  */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revsions:                                                        */
/*  10/15/01  HNK  4.16                                              */
/*    - Add SEQONLY=*NO to open query file.                          */
/*  10/14/10  RH   5.30                                              */
/*    - FIX: CHANGE QUERY TO NOT SELECT RECORDS WITH 0 TRANS #.      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RH392CL:    PGM        PARM(&PTRN# &RETURN)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&PTRN#)  TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT) TYPE(*CHAR) LEN(2000)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('LBTRN# *EQ ' *CAT &PTRN# +
                         *CAT ' *AND LBTRN# *GT 0')       /* 5.30 */
             OPNQRYF    FILE((LABEL)) QRYSLT(&QRYSLT) +
                          KEYFLD((LBTRN#) (LBITEM) (LBSEQ)) +
                          SEQONLY(*NO)

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */

             OVRDBF     FILE(LABEL) SHARE(*YES)


/*  On with the show ... */

REPEAT:
             CALL       PGM(RH392) PARM(&UNQKEY &RETURN)

DONE:
/*  Clean up before leaving */

             CLOF       OPNID(LABEL)
             DLTOVR     FILE(LABEL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
