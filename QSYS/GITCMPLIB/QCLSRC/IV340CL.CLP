/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV340CL   Print inventory exceptions                             */
/*  29 April 1999                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*  04/04/96 HNK/RH V2.12                                            */
/*       Added IV125 called with parameter &RPRT for re-print.       */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*    05/14/02  RH   4.16a                                           */
/*      - Change to select if status is not closed (4)               */
/*    09/27/07  RH   5.10                                            */
/*      - Change to select department and/or aisle                   */
/*-------------------------------------------------------------------*/

 IV340CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV340CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV340)

  /*  OPNQRY file. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(INVEXCP)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Print Inventory Exceptions')

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
             DCL        VAR(&RPRT)       TYPE(*CHAR) LEN(1) VALUE('N')
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&ASLE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &ASLE &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/*  Print Exceptions. */

             MSGBFC     MESSAGE('Printing inventory exceptions')

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('IVEWHS *EQ ' *CAT &WHSE)
             IF         COND(&WHDP *NE *ALL) THEN(DO)                /* 510 */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVEWHD +
                          *EQ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO
             IF         COND(&ASLE *NE ALL) THEN(DO)                /*  510 */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVEASL +
                          *EQ' *BCAT &QUOTE *CAT &ASLE *CAT &QUOTE)
             ENDDO
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVESTA +
                          *NE' *BCAT &QUOTE *CAT '4' *CAT &QUOTE)
   /*  4.16A              *EQ' *BCAT &QUOTE *CAT '1' *CAT &QUOTE) */

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((IVEWHS) (IVEWHD) (IVEASL) +
                          (IVELOC) (IVELVL) (IVEHND))
  /*                      KEYFLD(*FILE)           */

   /* Call program to print exceptions */

             MSGBFC     MESSAGE('Printing inventory exceptions')
             CALL       PGM(IV345)

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
