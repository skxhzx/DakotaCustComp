/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH394CL   Items details by pallet                                */
/*  31 August, 2000                                                  */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  03/03/05  DAS  500a                                              */
/*    - Revised to include warehouse in query select statement.      */
/*    - Added &WHSEA to parms.                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RH394CL:    PGM        PARM(&WHSEA &PRTID &PITEM)  /* 500aA */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&PRTID)  TYPE(*CHAR) LEN(5)
             DCL        VAR(&PITEM)  TYPE(*CHAR) LEN(15)
             DCL        VAR(&WHSEA)  TYPE(*CHAR) LEN(3)  /*500aA*/
             DCL        VAR(&QUOTE)  TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&QRYSLT) TYPE(*CHAR) LEN(2000)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('LBRTE *EQ ' *BCAT &QUOTE +
                        *CAT &PRTID *CAT &QUOTE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBITEM *EQ +
                          ' *BCAT &QUOTE *CAT &PITEM *CAT &QUOTE)
   /* 500aA Start */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBWHSE *EQ +
                          ' *BCAT &WHSEA)
   /* 500aA End */



             OPNQRYF    FILE((LABEL)) QRYSLT(&QRYSLT) +
                          KEYFLD((LBTRN#) (LBITEM) (LBSEQ))

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */

             OVRDBF     FILE(LABEL) SHARE(*YES)


/*  On with the show ... */

REPEAT:
             CALL       PGM(RH394) PARM(&UNQKEY &RETURN)

DONE:
/*  Clean up before leaving */

             CLOF       OPNID(LABEL)
             DLTOVR     FILE(LABEL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
