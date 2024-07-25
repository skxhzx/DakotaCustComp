/*-------------------------------------------------------------------*/
/*   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   24 N. Washington Ave Suite 203                                  */
/*   Batavia, IL 60510                                               */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PI216SCL   Stage Import - Import Purchase Orders                 */
/*  12 March 2011                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    03/12/11  MLB  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions:                                         */
/*                                                                   */
/*    mm/dd/yy  iii  ccc                                             */
/*      -                                                            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will call a Java program to retrieve the open      */
/*   purchase orders that are ready for import. The purchase orders  */
/*   will be written into IMPSPOH, IMPSPOD files. Next, imported     */
/*   p/o's will be extracted and written into IMPFPOH2, IMPFPOD2,    */
/*   IMPFPOHM, IMPFPODM files and then the Dakota p/o import pgm     */
/*   will be called to complete the import process into Dakota WMS.  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PI216SCL:    PGM        PARM(&WHSE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.                                                            */

             DCL        VAR(&cccccccccc) TYPE(*CHAR) LEN(10) +
                          VALUE('cccccccccc')                     /* (ccc A) */

  /* Import program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PI216S)

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPPO')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPPOERR')

  /* Import files */

             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPSPOH')
             DCL        VAR(&FILEHM) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPSPOHM')
             DCL        VAR(&FILED) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPSPOD')
             DCL        VAR(&FILEDM) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPSPODM')

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

             CHGVAR     VAR(&PGM) VALUE('PI216SCL')

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

             RMVMSG     CLEAR(*ALL)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Importing purchase orders into +
                          staging file. ') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

/*  Call program to move adjustments to staging file. */

             QSH        CMD('/PIRIFCDYNSL0700/RunImportPO.sh')

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
