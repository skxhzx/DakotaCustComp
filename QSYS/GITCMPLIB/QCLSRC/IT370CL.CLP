/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT370CL   Warehouse short/out report                             */
/*  28 October, 1994                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/20/95  DAS                                                  */
/*      - Revised OPNQRYF to include the warehouse along with the    */
/*        item as join fields.                                       */
/*    08/19/96  HNK                                                  */
/*      - Warehpouse number length changed so that the program       */
/*        can run on JOBQ.                                           */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT370CL:    PGM   PARM(&WHSE15 &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT370CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT370)

  /* Report program and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(ITEMQTY)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(IT371PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Warehouse short/out report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing warehouse short/out report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TODAY)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE15)     TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&WHSE3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSE3A)     TYPE(*CHAR) LEN(3)

/*           MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))  */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE15 &RETURN +
                          &VP &JOBQ &DEV &FORM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE15 &DEV +
                          &FORM)) JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:
             CHGVAR     VAR(&WHSE3)    VALUE(&WHSE15)
             CHGVAR     VAR(&WHSE3A)   VALUE(&WHSE3)

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             MSGBFC     MESSAGE('Selecting records')

  /*         CALL       PGM(TODAY) PARM(&TODAY)     */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('IQWHSE *EQ ' *CAT &WHSE3A)


             OVRDBF     FILE(IT371) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((ITEMQTY) (PIRITEM)) FORMAT(IT371) +
                          QRYSLT(&QRYSLT) KEYFLD((ITEMQTY/IQWHSE) +
                          (ITEMQTY/IQITEM)) JFLD((ITEMQTY/IQWHSE +
                          PIRITEM/ITWHSE) (ITEMQTY/IQITEM +
                          PIRITEM/ITITEM))

 VIEW:

             IF (&VP = 'V') THEN(DO)
             CALL       PGM(IT372) PARM(&WHSE15)
               GOTO       CMDLBL(NOMSG)
             ENDDO


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)


             CALL       PGM(IT371)

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
