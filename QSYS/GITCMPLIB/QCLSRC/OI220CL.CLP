/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OI220CL   Import customer orders                                 */
/*  02 August 1994                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Notes:                                                           */
/*    Taken from OI210CL.                                            */
/*                                                                   */
/*  Revisions:                                                       */
/*    08/14/96  HNK  2.16                                            */
/*      - Size of warehouse number parameter (&WHSE) changed to      */
/*        15 long with 5 decimal.  Size is changed to 3 long with    */
/*        zero decimal in RPG programs called from here.             */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*    06/02/97  DAS  4.00                                            */
/*      - Added new constants &ORDTYPE to identify normal,           */
/*        transfer or Will Call.                                     */
/*      - Added &ORDTYPE to posting program parameters.              */
/*                                                                   */
/*    04/25/12  RTR  6.40                                            */
/*      - Added new parms for delivery date, from route, to route.   */
/*      - Added logic for &IFTP.                                     */
/*    05/08/12  MLB  6.40a                                           */
/*      - Fix: Change to 6.40 mod. Added goto GETOUT when staging    */
/*        import job submitted to batch.                             */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OI220CL:    PGM        PARM(&WHSE &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Program type. */

             DCL        VAR(&ORDTYPE) TYPE(*CHAR) LEN(1) +
                          VALUE(' ')

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OI220CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(OI220)

  /* Report program and printer file names. */

             DCL        VAR(&RPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(OI225)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) +
                          VALUE(OI225PR)

  /* Staging FTP program.                                            (640 A) */

             DCL        VAR(&STGPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OI226SCL)                         /* (640 A) */

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Import Customer Orders')
             DCL        VAR(&NOIMPMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Import Routes is not allowed.')  /* (640 A) */
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Importing Customer Orders')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DELDTE)     TYPE(*CHAR) LEN(8)       /* (640 A) */
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&IFTP)       TYPE(*CHAR) LEN(1)       /* (640 A) */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTEFR)      TYPE(*CHAR) LEN(5)       /* (640 A) */
             DCL        VAR(&RTETO)      TYPE(*CHAR) LEN(5)       /* (640 A) */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&WHSE15)     TYPE(*CHAR) LEN(15)      /* (640 A) */
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
             CALL       PGM(&OPTPGM) PARM(&RETURN &WHSE &IFTP +
                          &DELDTE &RTEFR &RTETO &DEV &FORM)       /* (640 M) */

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

             IF         COND(&RETURN *EQ '*NOIMP') THEN(DO)       /* (640 A) */
               SNDPGMMSG  MSGID(PIR9999) MSGF(PIRMSGF) +
                          MSGDTA(&NOIMPMSG) MSGTYPE(*INFO)        /* (640 A) */
               RETURN                                             /* (640 A) */
             ENDDO                                                /* (640 A) */

/*  See if user wants to put report on JOBQ. */

     /* 640 A  Use IFTP option to call appropriate program */
             IF (&RETURN *EQ '*JOBQ') THEN(DO)
               SELECT                                             /* (640 A) */

/*             Staging File Import method in use.                    (640 A) */
               WHEN (&IFTP = 'S') THEN(DO)                        /* (640 A) */
               CHGVAR     VAR(&WHSE15) VALUE(&WHSE)               /* (640 A) */
               CHGVAR     VAR(&WHSEA) VALUE(%SST(&whse15 7 3))    /* (640 A) */
               SBMJOB       CMD(CALL PGM(&STGPGM) PARM(&WHSEA &DELDTE +
                            &RTEFR &RTETO &DEV &FORM)) JOB(&STGPGM) +
                                                                  /* (640 A) */
                 GOTO    CMDLBL(GETOUT)                           /* (640aA) */
               ENDDO                                              /* (640 A) */

               OTHERWISE  CMD(DO)                                 /* (640 A) */
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &DEV +
                          &FORM)) JOB(&SBMPGM)                    /* (640 A) */
               GOTO    CMDLBL(GETOUT)
               ENDDO

               ENDSELECT
             ENDDO

/*  Otherwise, run program. */

             SELECT                                               /* (640 A) */
/*           Staging File Import method in use.                      (640 A) */
             WHEN       COND(&IFTP = 'S') THEN(DO)                /* (640 A) */
               CHGVAR     VAR(&WHSE15) VALUE(&WHSE)               /* (640 A) */
               CHGVAR     VAR(&WHSEA) VALUE(%SST(&whse15 7 3))    /* (640 A) */
               CALL PGM(&STGPGM) PARM(&WHSEA &DELDTE +
                    &RTEFR &RTETO &DEV &FORM)                     /* (640 A) */
               GOTO GETOUT                                        /* (640 A) */
             ENDDO                                                /* (640 A) */
             ENDSELECT                                            /* (640 A) */

 REPORT:

/* Get printer device to use and then execute print program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             CALL       PGM(&RPTPGM) PARM(&WHSE &ORDTYPE)

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
