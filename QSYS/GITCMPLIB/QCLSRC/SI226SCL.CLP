/*-------------------------------------------------------------------*/
/*   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   24 N. Washington Ave Suite 203                                  */
/*   Batavia, IL 60510                                               */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SI226SCL   Stage Import - Import Slot StuffIt Updates            */
/*  20 April 2012                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    04/20/11  MLB  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    04/20/12  MLB  6.40                                            */
/*      - Created.                                                   */
/*    04/25/12  RTR  6.40a                                           */
/*      - Enh: Added options screen.                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: HM Wagner                               */
/*                                                                   */
/*    04/20/12  MLB  HMW                                             */
/*      - Revised program to call batch file to run AFS import slots */
/*        routine.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*    &DEV    -  Printer             (640aA)                         */
/*    &FORM   -  Formtype            (640aA)                         */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will call a Java program to retrieve all active    */
/*   items that are ready for import. The item updates will be       */
/*   written into IMPSITMN. Next, imported item updates will be      */
/*   extracted and written into IMPFITMN and then the Dakota import  */
/*   item updates will be called to complete the import process.     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 /* SI226SCL:    PGM        PARM(&WHSE)             /* 640aD */
 SI226SCL:   PGM        PARM(&WHSE &DEV &FORM)      /* 640aA */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.                                                            */

             DCL        VAR(&HMWagner) TYPE(*CHAR) LEN(10) +
                          VALUE('HMWAGNER')                       /* (HMW A) */

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SI226SCL)                       /* 640aA */

  /* Option program. */

       /*    DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) VALUE(SI250) +
                                                                  /* 640aD */
             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) VALUE(SI226) +
                                                                  /* 640aA */

  /* Import program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SI226S)

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPSTUF')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPSTUFERR')

  /* Import files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPSSTUF')

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Staging Slot Stuffit Import')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Importing Staging Slot Stuffit')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&IFTP)       TYPE(*CHAR) LEN(1)       /* (640aA) */
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RECS)       TYPE(*DEC)  LEN(10 0)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)       /* (640aA) */
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)

             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Don't get options if being run from JOBQ. */

             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

       /*    CALL       PGM(&OPTPGM) PARM(&RETURN &MBR &DEV &FORM) +
                                                              (640aD) */
             CALL       PGM(&OPTPGM) PARM(&RETURN &WHSE &DEV &FORM  +
                          &IFTP)                           /* (640aA) */

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)

               SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &DEV +
                          &FORM)) JOB(&SBMPGM)                    /* (640aA) */
               GOTO    CMDLBL(GETOUT)

             ENDDO

/*  Otherwise, run program. */

REPORT:                                                           /* (640aA) */
             RMVMSG     CLEAR(*ALL)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Importing slot stuffit updates into +
                          staging file. ') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

/*  Call program to move slots into to staging file. */

             SELECT                                               /* (HMW A) */
             WHEN       COND(&CLIENT = &HMWAGNER) THEN(DO)        /* (HMW A) */
               QSH        CMD('/PIRIFCAFS/RunImportSlots.sh')     /* (HMW A) */
             enddo                                                /* (HMW A) */
             OTHERWISE  CMD(DO)                                   /* (HMW A) */
             QSH        CMD('/PIRIFCDYNSL0700/RunImportSlots.sh')
             enddo                                                /* (HMW A) */
             endselect                                            /* (HMW A) */

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

             RMVMSG     CLEAR(*ALL)

             RETURN

/*  Receive any messages and pass them on  */

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
 NOMSG:
             OVRPRTF    FILE(QPJOBLOG) OUTQ(BFCEXCP)
             DSPJOBLOG  OUTPUT(*PRINT)

 BOTTOM:

             IF COND(&TYPE = '0') THEN(DO)

               RCLRSC     LVL(*CALLER)

        /*  Send '*Escape' message to caller */

               IF COND(&FINISHED = '0') THEN(DO)
                 SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Error Occured Processing Member' +
                          *BCAT &MBR) MSGTYPE(*ESCAPE)
               ENDDO

             ENDDO

             ENDPGM
