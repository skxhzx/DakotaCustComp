/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT730CL   Export item quantities                                 */
/*  04 July 1999                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*      04/28/10  RH   5.30                                          */
/*        - ADDED CLIENT CUSTOM CODE SUPPORT TO PROGRAM.             */
/*                                                                   */
/*    03/02/11  MLB  6.40                                            */
/*      - Enh: Revised program to add support for calling staging    */
/*        export program.                                            */
/*    04/25/11  MLB  6.40a                                           */
/*      - Fix: Revised program to correct parms sent to IT736SCL.    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  CLIENT CUSTOM REVISIONS: TPC                                     */
/*    04/28/10  RH   TPC                                             */
/*      - ADD USER AUTHORIZATION CHECK.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Eastland Foods                          */
/*    04/25/11  MLB  EFC                                             */
/*      - Revised program to call IT740SCL Staging Export - Item     */
/*        Warehouse Qty w/Sub Totals.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT730CL:    PGM        PARM(&WHSE &WHDP &SECTN &INCL &RFLAG)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT730CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IT730)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IT735)

  /* Main FTP program. */

             DCL        VAR(&FTPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IT736CL)
             DCL        VAR(&STGPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT736SCL)                         /* (640 A) */
             DCL        VAR(&STGPGM2) TYPE(*CHAR) LEN(10) +
                          VALUE(IT740SCL)                         /* (EFC A) */

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Export item quantities')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Exporting item quantities')
  /* Client ID */
 /*TPC A*/    DCL        VAR(&TPC) TYPE(*CHAR) LEN(10) +
                           VALUE('TPC       ')
              DCL        VAR(&EASTLAND) TYPE(*CHAR) LEN(10) +
                           VALUE('EASTLAND  ')                    /* (EFC A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* INFORMATIONAL MESSAGE. */
 /*TPC A*/    DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                           VALUE('   YOU ARE NOT AUTHORIZED TO USE +
                           THIS OPTION.')
/*530 A*/    DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
/*530 A*/    DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
/*530 A*/    DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
/*530 A*/    DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
/*530 A*/    DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

             DCL        VAR(&FTP)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&INCL)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RFLAG)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*530 A*/    CHGVAR     VAR(&PGMID) VALUE(IT730CL)
/*530 A*/    RTVJOBA    USER(&PUSR)
/*530 A*/    RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)
/*  CHECK IF USER IS AUTHORIZED TO USE THIS OPTION              (TPC A)*/

 /*TPC A*/    IF         COND(&CLIENT *EQ &TPC) THEN(DO)
 /*TPC A*/    CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
 /*TPC A*/    IF         COND(&PRTN *EQ '*NO')  THEN(DO)
 /*TPC A*/               SNDPGMMSG  MSG(&NOAUTHRZE)   +
 /*TPC A*/               MSGTYPE(*INFO)
 /*TPC A*/    RETURN
 /*TPC A*/    ENDDO
 /*TPC A*/    ENDDO



/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO MAIN)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &SECTN &INCL +
                          &RFLAG &RETURN &JOBQ &FTP)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

     /* 411 A  Use FTP option to call appropriate program */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)
               SELECT                                             /* (640 A) */
/*             IF (&FTP = 'Y') THEN(DO)                              (640 D) */
               when (&FTP = 'Y') THEN(DO)                         /* (640 M) */
                 SBMJOB  CMD(CALL PGM(&FTPPGM) PARM(&WHSE &WHDP &SECTN +
                          &INCL &RFLAG)) JOB(&FTPPGM)
               ENDDO

/*             Staging File Export method in use.                    (640 A) */
               when (&FTP = 'S') THEN(DO)                         /* (EFC A) */
                 SELECT                                           /* (EFC A) */
                 when (&CLIENT = &Eastland) THEN(DO)              /* (EFC A) */
                   SBMJOB     CMD(CALL PGM(&STGPGM2) PARM(&WHSE)) +
                                JOB(&STGPGM2)                     /* (EFC A) */
                 Enddo                                            /* (EFC A) */
                 OTHERWISE  CMD(DO)                               /* (EFC A) */
                 SBMJOB     CMD(CALL PGM(&STGPGM) PARM(&WHSE)) +
                              JOB(&STGPGM)                        /* (640 A) */
                 ENDDO                                            /* (EFC A) */
                 ENDSELECT                                        /* (EFC A) */
               Enddo                                              /* (640 A) */

/*             IF (&FTP *NE 'Y') THEN(DO)                            (640 A) */
               OTHERWISE  CMD(DO)                                 /* (640 M) */
                 SBMJOB  CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP &SECTN +
                          &INCL &RFLAG)) JOB(&SBMPGM)
               ENDDO
               ENDSELECT                                          /* (640 A) */
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

     /* 411 A  FTP uses a different program */

             SELECT                                               /* (640 A) */
/*           IF (&FTP = 'Y') THEN(DO)                                (640 D) */
             When (&FTP = 'Y') THEN(DO)                           /* (640 M) */
               CALL PGM(&FTPPGM) PARM(&WHSE &WHDP &SECTN &INCL &RFLAG)
               GOTO GETOUT
             ENDDO

/*           Staging File Export method in use.                      (640 A) */
             WHEN       COND(&FTP = 'S') THEN(DO)                 /* (640 A) */
                 SELECT                                           /* (EFC A) */
                 when (&CLIENT = &Eastland) THEN(DO)              /* (EFC A) */
                   CALL PGM(&STGPGM2) PARM(&WHSE)                 /* (EFC A) */
                 Enddo                                            /* (EFC A) */
                 OTHERWISE  CMD(DO)                               /* (EFC A) */
               CALL       PGM(&STGPGM) PARM(&WHSE) +
                                                                  /* (640aM) */
                 ENDDO                                            /* (EFC A) */
                 ENDSELECT                                        /* (EFC A) */
               GOTO GETOUT                                        /* (640 A) */
             Enddo                                                /* (640 A) */
             ENDSELECT                                            /* (640 A) */
 MAIN:

   /* Export records */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&WHSE &WHDP &SECTN &INCL &RFLAG)

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

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
