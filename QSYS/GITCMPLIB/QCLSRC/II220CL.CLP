/*-------------------------------------------------------------------*/
/*                                                                   */
/*  II220CL   Import Item Updates                                    */
/*  19 May 1999                                                      */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Notes:                                                           */
/*    Taken from OI220CL.                                            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    03/02/11  MLB  6.40                                            */
/*      - Enh: Revised program to add support for calling staging    */
/*        import program.                                            */
/*                                                                   */
/*-------------------------------------------------------------------*/

 II220CL:    PGM        PARM(&WHSE &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(II220CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(II220)

  /* Report program and printer file names. */

             DCL        VAR(&RPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(II225)
             DCL        VAR(&STGPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(II226SCL)                         /* (640 A) */
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) +
                          VALUE(II225PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Import item updates')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Importing item updates')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&IFTP)       TYPE(*CHAR) LEN(1)       /* (640 A) */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&WHSE3)      TYPE(*DEC)  LEN(3 0)     /* (640 A) */
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)       /* (640 A) */

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

/*           CALL       PGM(&OPTPGM) PARM(&RETURN &WHSE &DEV &FORM)  (640 D) */
             CALL       PGM(&OPTPGM) PARM(&RETURN &WHSE &DEV &FORM +
                          &IFTP)                                  /* (640 M) */

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)

               SELECT                                             /* (640 A) */
/*             Staging File Import method in use.                    (640 A) */
               when (&IFTP = 'S') THEN(DO)                        /* (640 A) */
                 CHGVAR     VAR(&WHSE3) VALUE(&WHSE)              /* (640 A) */
                 CHGVAR     VAR(&WHSEA) VALUE(&WHSE3)             /* (640 A) */
                 SBMJOB     CMD(CALL PGM(&STGPGM) PARM(&WHSEA)) +
                              JOB(&STGPGM)                        /* (640 A) */
                 GOTO    CMDLBL(GETOUT)                           /* (640 A) */
               Enddo                                              /* (640 A) */

               OTHERWISE  CMD(DO)                                 /* (640 M) */
               SBMJOB  CMD(CALL PGM(&SBMPGM) PARM(&WHSE &DEV +
                          &FORM)) JOB(&SBMPGM)
               GOTO    CMDLBL(GETOUT)
               ENDDO                                              /* (640 A) */
             ENDSELECT                                            /* (640 A) */
             ENDDO

/*  Otherwise, run program. */

/*      Staging Import uses a different program.                     (640 A) */

             SELECT                                               /* (640 A) */
               WHEN       COND(&IFTP = 'S') THEN(DO)              /* (640 A) */
                 CALL PGM(&STGPGM) PARM(&WHSEA)                   /* (640 A) */
                 GOTO GETOUT                                      /* (640 A) */
               Enddo                                              /* (640 A) */
             ENDSELECT                                            /* (640 A) */

 REPORT:

/* Get printer device to use and then execute print program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             CALL       PGM(&RPTPGM) PARM(&WHSE)

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
