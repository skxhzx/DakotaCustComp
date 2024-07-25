/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OI240CL   Import/pick will call orders                           */
/*  27 August 1997                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*    3-20-98  RH  V4.09                                             */
/*    -  Add order # to PARMS                                        */
/*                                                                   */
/*    05/04/99  DAS  4.11                                            */
/*      - Added &RTID field definition.                              */
/*      - Added &RTID to the following:                              */
/*          - Program parameters                                     */
/*          - OI245/RH220 program calls                              */
/*      - Revised JOBQ call to use correct parameters.               */
/*                                                                   */
/*    10/12/99  DAS  4.13                                            */
/*      - Created new input variable for order number that is        */
/*        defined as a 7 position character field. This field        */
/*        is then converted into the original numeric field.         */
/*        When sending in a number from the command line the         */
/*        field should be defined as 15.5 as &WHSE. The reason       */
/*        for changing this field into a character field is that     */
/*        the menu command used in menu PIRCUST3 has defined all     */
/*        of the parameters as alpha.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OI240CL:    PGM        PARM(&WHSE &DEV &FORM &IORDA) /* 413 M */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Program type. */

             DCL        VAR(&ORDTYPE) TYPE(*CHAR) LEN(1) +
                          VALUE('W')

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OI240CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(OI240)

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

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)    /* 411 A */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TRUCK)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&IORD)       TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&IORDA)      TYPE(*CHAR) LEN(7)    /* 413 A */

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

         IF (&IORDA = ' ') THEN(CHGVAR VAR(&IORD) VALUE(0))        /* 413 A */
         IF (&IORDA *NE ' ') THEN(CHGVAR VAR(&IORD) VALUE(&IORDA)) /* 413 A */

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&RETURN &WHSE &DEV &FORM +
                          &IORD)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)
            /* SBMJOB  CMD(CALL PGM(&SBMPGM) PARM(&WHSE &DEV +
                          &FORM &TRUCK)) JOB(&SBMPGM)               411 D */
               SBMJOB  CMD(CALL PGM(&SBMPGM) PARM(&WHSE &DEV +
                          &FORM &IORD)) JOB(&SBMPGM)             /* 411 M */
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

/* Get printer device to use and then execute print program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             CALL       PGM(&RPTPGM) PARM(&WHSE &ORDTYPE &TRUCK +
                          &IORD &RTID)                             /* 411 M */

/* Allocate, pick and print will call orders. */

             CALL       PGM(RH220) PARM(&WHSE &TRUCK &TYPE &SBMPGM +
                          &RTID &RETURN)                          /* 411 M */

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
