/*-------------------------------------------------------------------*/
/*   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   24 N. Washington Ave Suite 203                                  */
/*   Batavia, IL 60510                                               */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OI226SCL   Stage Import - Import Host Customer Orders            */
/*  16 May 2011                                                      */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    05/16/11  MLB  6.40                                            */
/*      - Created.                                                   */
/*    04/26/12  MLB  6.40a                                           */
/*      - Enh: Revised pgm to add 5 new parms being passed into pgm. */
/*        Delivery Date YYYYMMDD, From Route#, To Route#, Outq and   */
/*        Formtype.                                                  */
/*    08/11/11  MLB  6.40a                                           */
/*      - Revised program to ovrprtf cmd to direct QPRINT output     */
/*        to outq QPRINT.                                            */
/*    12/05/12  MLB  6.40b                                           */
/*      - Enh: Revised program to add library QSHELL before library  */
/*        QTEMP so that QSHELL msgs are issued correctly.            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Eastland Foods                          */
/*                                                                   */
/*    06/23/11  MLB  EFC                                             */
/*      - Revised program to add entries to system reply list        */
/*        for msgid RNQ1218 - Record already allocated to use        */
/*        R=Retry default reply.                                     */
/*      - Compile with *OWNER authority. This will allow the reply   */
/*        list cmds to function without granting authority to user.  */
/*    04/02/12  MLB  EFCa                                            */
/*      - Revised program to call test batch file to send orders to  */
/*        RMS module using RunGetCustomerOrdersTest.sh until pro-    */
/*        noted to Production.                                       */
/*    05/15/13  MLB  EFCb                                            */
/*      - Revised program to add MONMSG for CPF2556 on RMVRPYLE.     */
/*    12/06/13  GJA  EFCc                                            */
/*      - Took EFCa to run in production.                            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: HM Wagner                               */
/*                                                                   */
/*    04/20/12  MLB  HMW                                             */
/*      - Revised program to call batch file to run AFS import       */
/*        routes routine.                                            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will call a Java program to retrieve all active    */
/*   ordersthat are ready for import. The order updates will be      */
/*   written into IMPSORDH, IMPSORDD. Next, imported order updates   */
/*   will be extracted and written into IMPFORDH, IMPFORDD, IMPF-    */
/*   ORDHM, IMPFORDDM. FTP Import customer orders will be called     */
/*   to process the order updates.                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

/* OI226SCL:    PGM        PARM(&WHSE)                               (640aD) */
 OI226SCL:   PGM        PARM(&WHSE &DELDTE &RTEFR &RTETO &DEV &FORM) +
                                                                  /* (640aM) */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.                                                            */

             DCL        VAR(&EASTLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('EASTLAND')                       /* (EFC A) */
             DCL        VAR(&HMWagner) TYPE(*CHAR) LEN(10) +
                          VALUE('HMWAGNER')                       /* (HMW A) */

  /* Import program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OI226S)

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPORD')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPORDERR')

  /* Import files */

             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPSORDH')
             DCL        VAR(&FILED) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPSORDD')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&DELDTE)     TYPE(*CHAR) LEN(8)       /* (640aA) */
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&INQMSGRPY)  TYPE(*CHAR) LEN(10)      /* (EFC A) */
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RECS)       TYPE(*DEC)  LEN(10 0)
             DCL        VAR(&RTEFR)      TYPE(*CHAR) LEN(5)       /* (640aA) */
             DCL        VAR(&RTETO)      TYPE(*CHAR) LEN(5)       /* (640aA) */
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

             CHGVAR     VAR(&PGM) VALUE('OI226SCL')

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)
             RTVJOBA    INQMSGRPY(&INQMSGRPY)                     /* (EFC A) */
             ADDLIBLE   LIB(QSHELL) POSITION(*BEFORE QTEMP)       /* (640bA */
             MONMSG     MSGID(CPF2103)                            /* (640bA)*/

             RMVMSG     CLEAR(*ALL)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Importing customer order updates into +
                          staging file. ') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             IF         COND(&CLIENT = &EASTLAND) THEN(DO)        /* (EFC A) */
               ADDRPYLE   SEQNBR(151) MSGID(RNQ1218) RPY(R)
               MONMSG     MSGID(CPF2555)                          /* (EFC A) */
               CHGJOB     INQMSGRPY(*SYSRPYL)
             ENDDO                                                /* (EFC A) */
                                                                  /* (EFC A) */
/*  Call program to move customer orders to staging file. */

             OVRPRTF    FILE(QPRINT) TOFILE(QGPL/QPRINT) +
                          OUTQ(QPRINT)                            /* (640aA) */
 /*EFCcD    IF         COND(&CLIENT = &EASTLAND) THEN(DO)  */    /* (EFCaA) */
 /*EFCcD     QSH        CMD('/PIRIFCDYNSL0700/RunGetCustomerOrdersTest.sh') */
 /*EFCcD     ENDDO                                         */     /* (EFCaA) */
 /*EFCcD     ELSE       CMD(DO)                            */     /* (EFCaA) */
 /*EFCcD     QSH        CMD('/PIRIFCDYNSL0700/RunGetCustomerOrders.sh')      */
 /*EFCcD     ENDDO                                         */     /* (EFCaA) */

             SELECT                                               /* (HMW A) */
             WHEN       COND(&CLIENT = &HMWAGNER) THEN(DO)        /* (HMW A) */
               QSH      CMD('/PIRIFCAFS/RunImportRoutes.sh')      /* (HMW A) */
             enddo                                                /* (HMW A) */
             OTHERWISE  CMD(DO)                                   /* (HMW A) */
             QSH        CMD('/PIRIFCDYNSL0700/RunGetCustomerOrders.sh')
             enddo                                                /* (HMW A) */
             endselect                                            /* (HMW A) */

/*  Clean up before leaving */

             IF         COND(&CLIENT = &EASTLAND) THEN(DO)        /* (EFC A) */
               RMVRPYLE   SEQNBR(151)                             /* (EFC A) */
               MONMSG     MSGID(CPF2556)                          /* (EFCbA) */
               CHGJOB     INQMSGRPY(&INQMSGRPY)                   /* (EFC A) */
             ENDDO                                                /* (EFC A) */
                                                                  /* (EFC A) */
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
