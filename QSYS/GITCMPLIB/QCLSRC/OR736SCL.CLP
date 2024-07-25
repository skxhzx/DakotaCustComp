/*-------------------------------------------------------------------*/
/*   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   24 N. Washington Ave Suite 203                                  */
/*   Batavia, IL 60510                                               */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR736SCL   Staging Export Customer Returns                       */
/*  05 December 2012                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    12/05/12  MLB  6.40                                            */
/*      - Created.                                                   */
/*      - Copied from OR736CL.                                       */
/*    12/05/12  MLB  6.40a                                           */
/*      - Enh: Added DSPJOBLOG OUTPUT(*PRINT) if export fails.       */
/*                                                                   */
/*    04/14/16  MLB  7.00                                            */
/*      - Fix: Revised pgm to add OVRDBF file(EXPSRTN) with          */
/*        FRCRATIO(1). Discovered at Chefs.                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Eastland Foods                          */
/*                                                                   */
/*    12/05/12  MLB  EFC                                             */
/*      - Revised pgm to condition call to RunExportRtn.sh for       */
/*        Eastland only.                                             */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    04/04/16  MLB  DRY                                             */
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
/*   This program uses staging export files which have a single mbr  */
/*   to hold exported data. Data is kept in staging export files for */
/*   only a few days and then purged via a job schedule entry clean- */
/*   up job. Data in staging export files is retrieved using SQL     */
/*   via a job run from the Host or a BFC provided interface pgm.    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR736SCL:    PGM        PARM(&WHSE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (510 A) */

             DCL        VAR(&Eastland) TYPE(*CHAR) LEN(10) +
                          VALUE('EASTLAND')                       /* (EFC A) */
             DCL        VAR(&Dairyland) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR736S)

  /* Export files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPSRTN')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&HOSTLIB)    TYPE(*CHAR) LEN(10) +
                                              VALUE('DARLIB_TST') /* (DRY A) */
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MonthEnd)   TYPE(*CHAR) LEN(1)       /* (DRY A) */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
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

             CHGVAR     VAR(&PGM) VALUE('OR736SCL')

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
                              customer returns Cancelled.') TOPGMQ(*EXT) +
                                                                  /* (DRY A) */
                Return                                            /* (DRY A) */
               ENDDO                                              /* (DRY A) */
/*             Check period-end processing pgm failed.               (DRY A) */
               When       COND(&MonthEnd *eq '2') THEN(DO)        /* (DRY A) */
                 SNDPGMMSG  MSG('Check Period end processing pgm failed. +
                              Export customer returns Cancelled.') +
                              TOPGMQ(*EXT)                        /* (DRY A) */
                Return                                            /* (DRY A) */
               ENDDO                                              /* (DRY A) */
               ENDSELECT                                          /* (DRY A) */

             ENDDO                                                /* (DRY A) */
             ENDSELECT                                            /* (DRY A) */

             RMVMSG     CLEAR(*ALL)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Exporting returns into staging +
                          export files') TOPGMQ(*EXT) MSGTYPE(*STATUS)


/*  Call program to move returns to export staging file. */

             SELECT                                               /* (EFC A) */
             WHEN       COND(&CLIENT = &EASTLAND) THEN(DO)        /* (EFC A) */
               QSH        CMD('/PIRIFCDYNSL0700/RunExportRtn.sh') /* (EFC A) */
             ENDDO                                                /* (EFC A) */
             OTHERWISE  CMD(DO)                                   /* (EFC A) */
               OVRDBF     FILE(EXPSRTN) TOFILE(EXPSRTN) FRCRATIO(1) /*(700 A)*/
               CALL       PGM(&EXPPGM) PARM(&WHSE)
             ENDDO                                                /* (EFC A) */
             ENDSELECT                                            /* (EFC A) */

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')

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
                              MSGDTA('Error Occured Processing Staging +
                              Exports Returns') MSGTYPE(*ESCAPE)
               ENDDO

             ENDDO

             ENDPGM
