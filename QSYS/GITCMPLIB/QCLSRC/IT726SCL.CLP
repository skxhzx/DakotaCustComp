/*-------------------------------------------------------------------*/
/*   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   24 N. Washington Ave Suite 203                                  */
/*   Batavia, IL 60510                                               */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT726SCL   Stage Export - Export Item Adjustments                */
/*  02 March 2011                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    03/02/11  MLB  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    12/04/13  MLB  6.50                                            */
/*      - Enh: Revised program to call pgm, IT726S to export item    */
/*        adjustments to staging files.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Eastland Foods                          */
/*                                                                   */
/*    03/02/11  MLB  EFC                                             */
/*      - Revised program to call Java interface pgm, RunExportAdj.sh*/
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    12/04/13  MLB  DRY                                             */
/*      - Revised program to call Dairyland program, MTHENDCHKR      */
/*        to see if any period end processes are active. If pgm      */
/*        returns value of 1=Period end processing active, send      */
/*        message to user and cancel export. Per email from Kelly R. */
/*    08/11/16  RTR  DRYb                                            */
/*      - Revised program to call IT726SB instead of IT726S to       */
/*        export from LICADJ with the slot status.                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will call a Java program to process the            */
/*   adjustments that have not been exported. The adjustments will   */
/*   be written into the EXPSADJ file and then extracted and placed  */
/*   into a shared folder in the IFS for pickup and processing by    */
/*   the Host.                                                       */
/*   The expsadj file will be uniquely named so that it cannot be    */
/*   overwritten by subsequent export processes.                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT726SCL:    PGM        PARM(&WHSE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (510 A) */

             DCL        VAR(&Eastland) TYPE(*CHAR) LEN(10) +
                          VALUE('EASTLAND')                       /* (EFC A) */
             DCL        VAR(&Dairyland) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IT726S)
             DCL        VAR(&EXPPGM2) TYPE(*CHAR) LEN(8) +
                          VALUE(IT726SB)                          /* (DRYbA) */

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPADJ')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPADJERR')

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
             DCL        VAR(&HOSTLIB)    TYPE(*CHAR) LEN(10) +
                                              VALUE('DARLIB_TST') /* (DRY A) */
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
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

             CHGVAR     VAR(&PGM) VALUE('IT726SCL')

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
                              item adjustments Cancelled.') TOPGMQ(*EXT) +
                                                                  /* (DRY A) */
                Return                                            /* (DRY A) */
               ENDDO                                              /* (DRY A) */
/*             Check period-end processing pgm failed.               (DRY A) */
               When       COND(&MonthEnd *eq '2') THEN(DO)        /* (DRY A) */
                 SNDPGMMSG  MSG('Check Period end processing pgm failed. +
                              Export item adjustments Cancelled.') +
                              TOPGMQ(*EXT)                        /* (DRY A) */
                Return                                            /* (DRY A) */
               ENDDO                                              /* (DRY A) */
               ENDSELECT                                          /* (DRY A) */

             ENDDO                                                /* (DRY A) */
             ENDSELECT                                            /* (DRY A) */

             RMVMSG     CLEAR(*ALL)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Exporting adjustments into +
                          staging file. ') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

/*  Call program to move adjustments to staging file. */

             SELECT                                               /* (EFC A) */
             WHEN       COND(&CLIENT = &EASTLAND) THEN(DO)        /* (EFC A) */
             QSH        CMD('/PIRIFCDYNSL0700/RunExportAdj.sh')
             enddo                                                /* (EFC A) */
             WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRYbA) */
               OVRDBF FILE(STGBATCH) TOFILE(STGBATCH) FRCRATIO(1) /* (DRYbA) */
               OVRDBF FILE(EXPSADJ) TOFILE(EXPSADJ) FRCRATIO(1)   /* (DRYbA) */
               call it726SB parm(&whse)                           /* (DRYbA) */
             enddo                                                /* (DRYbA) */
             OTHERWISE  CMD(DO)                                   /* (650 A) */
               OVRDBF FILE(STGBATCH) TOFILE(STGBATCH) FRCRATIO(1) /* (650 A) */
               OVRDBF FILE(EXPSADJ) TOFILE(EXPSADJ) FRCRATIO(1)   /* (650 A) */
               call it726S parm(&whse)                            /* (650 A) */
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
