/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV380CL   Print inventory catch wt ovrrid                        */
/*  07 June, 2006                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*  06/07/06 RH  V5.10                                               */
/*    - Created                                                      */
/*-------------------------------------------------------------------*/

 IV380CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV370CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV380)

  /*  OPNQRY file. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(INVSCW)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Print Inv Catch Wt Ovrrides')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RPRT)       TYPE(*CHAR) LEN(1) VALUE('N')

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/*  Print Exceptions. */

             MSGBFC     MESSAGE('Printing inv catch wt override')

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('IVWWHS *EQ ' *CAT &WHSE)
             IF (&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVWWHD *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((IVWWHS) (IVWWHD) (IVWASL) +
                          (IVWLOC) (IVWLVL) (IVWHND))
  /*                      KEYFLD(*FILE)           */

   /* Call program to print exceptions */

             MSGBFC     MESSAGE('Printing inv catch wt override')
             CALL       PGM(IV385)

 /* Receive any messages and pass them on */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                        MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 OUT:
 NOMSG:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
