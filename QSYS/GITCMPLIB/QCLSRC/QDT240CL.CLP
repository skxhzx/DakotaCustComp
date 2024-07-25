/*-------------------------------------------------------------------*/
/*                                                                   */
/*  QDT240CL   *TEST* Import/pick will call orders                   */
/*  04 May 1999                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &IORDIN  -  Starting order number                              */
/*    &WHSE    -  Warehouse                                          */
/*    &DEV     -  Printer device                                     */
/*    &FORM    -  Printer form                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 QDT240CL:   PGM        PARM(&IORDIN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Defaults */

             DCL        VAR(&ORDTYPE) TYPE(*CHAR) LEN(1) +
                          VALUE('W')
             DCL        VAR(&WHSE) TYPE(*DEC) LEN(15 5) +
                          VALUE(900)
             DCL        VAR(&TRUCK) TYPE(*CHAR) LEN(10) +
                          VALUE('WILL900')
             DCL        VAR(&DEV) TYPE(*CHAR) LEN(10) +
                          VALUE('*JOB')
             DCL        VAR(&FORM) TYPE(*CHAR) LEN(10) +
                          VALUE('*STD')

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(QDT240CL)

  /* Report program and printer file names. */

             DCL        VAR(&RPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(OI245)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) +
                          VALUE(OI245PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Import/pick will call orders')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Importing/Picking will call orders')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&COUNT)      TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)    /* 411 A */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TRUCK)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&IORD)       TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&IORDIN)     TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&IORDA)      TYPE(*CHAR) LEN(7)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Otherwise, run program. */

 REPORT:

/* Get printer device to use and then execute print program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             CHGVAR     VAR(&IORD) VALUE(&IORDIN)
             CHGVAR     VAR(&COUNT) VALUE(10)

LOOP:

             CHGVAR     VAR(&COUNT) VALUE(&COUNT + 1)
             IF COND(&COUNT *EQ 10) THEN(DO)
               CHGVAR     VAR(&IORDA) VALUE(&IORD)
               CHGVAR     VAR(&WORKINGMSG) VALUE(&WORKINGMSG *TCAT &IORDA)
               MSGBFC     MESSAGE(&WORKINGMSG)
               CHGVAR     VAR(&COUNT) VALUE(0)
             ENDDO

             CALL       PGM(&RPTPGM) PARM(&WHSE &ORDTYPE &TRUCK +
                          &IORD &RTID)                             /* 411 M */

/* Allocate, pick and print will call orders. */

             CALL       PGM(RH220) PARM(&WHSE &TRUCK &TYPE &SBMPGM +
                          &RTID &RETURN)                          /* 411 M */


             IF COND(&IORD *LE 500) THEN(DO)
                CHGVAR     VAR(&IORD) VALUE(&IORD + 2)
                GOTO LOOP
             ENDDO


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

     /*      DLTOVR     FILE(&PRTF)       */
             RCLRSC     LVL(*CALLER)

             ENDPGM
