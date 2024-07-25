/*-------------------------------------------------------------------*/
/*   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   24 N. Washington Ave Suite 203                                  */
/*   Batavia, IL 60510                                               */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PO726SCL   Stage Export - Export Item Adjustments                */
/*  02 March 2011                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    03/02/11  MLB  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    08/03/13  MLB  6.50                                            */
/*      - Enh: Revised program to call pgm, PO726S to export p/o's   */
/*        to staging files.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Eastland Foods                          */
/*                                                                   */
/*    03/04/11  MLB  EFC                                             */
/*      - Revised program to call Java interface pgm, RunExportPO.sh */
/*        to interface with Dynamics SL v7.00.                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    08/05/13  MLB  DRY                                             */
/*      - Revised program to call Dairyland program, MTHENDCHKR      */
/*        to see if any period end processes are active. If pgm      */
/*        returns value of 1=Period end processing active, send      */
/*        message to user and cancel export. Per email from Kelly R. */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will call a Java program to process the received   */
/*   purchase orders that have been marked for export. The p/o's     */
/*   will be written into EXPSPOH, EXPSPOD, EXPSPOE files. Next,     */
/*   the exported p/o's will be extracted and placed into a shared   */
/*   folder in the IFS for pickup and processing by the Host.        */
/*   The expspoh,expspod, expfspoe file will be uniquely named so    */
/*   that they cannot be overwritten by subsequent export processes. */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PO726SCL:    PGM        PARM(&WHSE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.                                                            */

             DCL        VAR(&Eastland) TYPE(*CHAR) LEN(10) +
                          VALUE('EASTLAND')                       /* (EFC A) */
             DCL        VAR(&Dairyland) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PO726S)

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPPO')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPPOERR')

  /* Import files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPSADJ')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&HOSTLIB)    TYPE(*CHAR) LEN(10) +
                                              VALUE('DARLIB_TST') /* (DRY A) */
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MonthEnd)   TYPE(*CHAR) LEN(1)       /* (DRY A) */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RECS)       TYPE(*DEC)  LEN(10 0)
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

             CHGVAR     VAR(&PGM) VALUE('PO726SCL')

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

             SELECT                                               /* (DRY A) */
             WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRY A) */

               CALL       PGM(&HOSTLIB/MTHENDCHKR)  PARM('00' +
                            &MonthEnd)                            /* (DRY A) */
               MONMSG     MSGID(CPF0000 CPF0001 CPF0005 CPF0006) +
                            EXEC(DO)                              /* (DRY A) */
                 CHGVAR     VAR(&MONTHEND) VALUE('2')             /* (DRY A) */
               Enddo                                              /* (DRY A) */
               Select                                             /* (DRY A) */
/*             Period end processing active, cancel export.          (DRY A) */
               When       COND(&MonthEnd *eq '1') THEN(DO)        /* (DRY A) */
                 SNDPGMMSG  MSG('Period end processing active. Export +
                              purchase orders Cancelled.') TOPGMQ(*EXT) +
                                                                  /* (DRY A) */
                Return                                            /* (DRY A) */
               ENDDO                                              /* (DRY A) */
/*             Check period-end processing pgm failed.               (DRY A) */
               When       COND(&MonthEnd *eq '2') THEN(DO)        /* (DRY A) */
                 SNDPGMMSG  MSG('Check Period end processing pgm failed. +
                              Export purchase orders Cancelled.') +
                              TOPGMQ(*EXT)                        /* (DRY A) */
                Return                                            /* (DRY A) */
               ENDDO                                              /* (DRY A) */
               ENDSELECT                                          /* (DRY A) */

             ENDDO                                                /* (DRY A) */
             ENDSELECT                                            /* (DRY A) */

             RMVMSG     CLEAR(*ALL)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Exporting purchase orders into +
                          staging file. ') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

/*  Call program to move adjustments to staging file. */

             SELECT                                               /* (EFC A) */
             WHEN       COND(&CLIENT = &EASTLAND) THEN(DO)        /* (EFC A) */
             QSH        CMD('/PIRIFCDYNSL0700/RunExportPO.sh')
             enddo                                                /* (EFC A) */
             OTHERWISE  CMD(DO)                                   /* (650 A) */
               OVRDBF FILE(STGBATCH) TOFILE(STGBATCH) FRCRATIO(1) /* (650 A) */
               OVRDBF FILE(EXPSPOH) TOFILE(EXPSPOH) FRCRATIO(1)   /* (650 A) */
               OVRDBF FILE(EXPSPOD) TOFILE(EXPSPOD) FRCRATIO(1)   /* (650 A) */
               OVRDBF FILE(EXPSPOE) TOFILE(EXPSPOE) FRCRATIO(1)   /* (650 A) */
               call po726S parm(&whse)                            /* (650 A) */
             enddo                                                /* (650 A) */
             endselect                                            /* (650 A) */

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
