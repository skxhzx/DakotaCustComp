/*-------------------------------------------------------------------*/
/*                                                                   */
/*  FTPSTUFIT4  Gateway for FTP StuffIt Import 4                     */
/*  20 July 2009                                                     */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*   07/20/09  5.20  MLB                                             */
/*     - Created                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &CMD   -  *CLEAR   - Clear all slot fields. Delete all virtual */
/*                         slots.                                    */
/*           -  *NOCLR   - No slot fields are cleared. Only slots    */
/*                         sent in file are processed and updated.   */
/*    &MBR   -  Member to create. Must start with alpha character.   */
/*    &RUN   -  *INTER  Run interactively                            */
/*              *JOBQ   Run on Jobq                                  */
/*    &OUTQ  -  Printer output queue (Default is *JOB)               */
/*    &FORM  -  Printer form (Default is *STD)                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command sequence                                             */
/*                                                                   */
/*    PUT localfile PIRF/IMPFSTUF4.membername                        */
/*    QUOTE RCMD PIR/FTPLIBL libltype                                */
/*    QUOTE RCMD PIR/FTPSTUFIT4 (*CLEAR membername *INTER *JOB *STD) */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*   Notes:                                                          */
/*                                                                   */
/*    - 'command' can be *CLEAR, *NOCLR.                             */
/*                                                                   */
/*    - 'libltype' can be *PROD, *TEST, *900 or *BFC.                */
/*                                                                   */
/*    - 'localfile' is the name of the text file on the host system. */
/*                                                                   */
/*    - 'membername' is the name of the member where the data        */
/*     will be PUT.  This member will be renamed by this program.    */
/*     Therefore, it makes no difference to this program what name   */
/*     is used.  However, at the very least, each import type should */
/*     have its own name.                                            */
/*                                                                   */
/*     Also, when using a static name for all ftp's the host must    */
/*     ensure that only one ftp can be done at a time in order to    */
/*     prevent multiple ftp's from overwriting one another.          */
/*     Once this program has finished successfully, another          */
/*     ftp can be done because this program renames the member       */
/*     that is initially created.                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   FTP orders are sent into a special FTP import file.  Unlike     */
/*   the normal import where everything goes into a single member,   */
/*   the FTP import files contain multiple members.  The member      */
/*   that is used for a particular session is sent in as a           */
/*   parameter.                                                      */
/*                                                                   */
/*   This is designed to be called from the command line or as a     */
/*   remote command using the FTP Quote command. When called from    */
/*   the command line the user will be prompted for the necessary    */
/*   parameters.  When called as a remote command, the necessary     */
/*   parameters are passed in.                                       */
/*                                                                   */
/*   Normally this program is called as a remote FTP command after   */
/*   the data has been sent.  The option to call this from the       */
/*   command line is mainly for testing and the instances when       */
/*   something goes wrong with the import process.                   */
/*                                                                   */
/*   When called as a remote FTP command the job 'Type' is '0'       */
/*   which means it looks like a batch job.                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 FTPSTUFIT4: PGM        PARM(&CMD &MBR &RUN &OUTQ &FORM)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&FTPMSGQ)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&OUTQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&RUN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000) EXEC(GOTO GETOUT)
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

   /* Define message queues to use */

               CHGVAR     VAR(&FTPMSGQ) VALUE('IMPSTUF')
               CHGVAR     VAR(&FTPERRMSGQ) VALUE('IMPSTUFERR')

   /* Call program to do import */

               CALL  PGM(SI280CL) PARM(&CMD &MBR &RUN &OUTQ &FORM)

               CHGVAR     VAR(&FINISHED) VALUE('1')
               GOTO BOTTOM


/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          message(s):' *BCAT &MBR *TCAT '/' *CAT +
                          &RUN *TCAT '/' *CAT +
                          &JOB *TCAT '/' *CAT &USER) +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          message(s):' *BCAT &MBR *TCAT '/' *CAT +
                          &RUN *TCAT '/' *CAT +
                          &JOB *TCAT '/' *CAT &USER) +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

             IF COND(&TYPE = '1') THEN(DO)
               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             ENDDO

               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) TOMSGQ(&FTPMSGQ) MSGTYPE(*COMP)

               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOMSGQ(&FTPERRMSGQ) +
                          MSGTYPE(*COMP)

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 BOTTOM:

        /*  Send '*Escape' message to caller */

               IF COND(&FINISHED = '0') THEN(DO)
                 SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Error Occured Processing Member' +
                          *BCAT &MBR) MSGTYPE(*ESCAPE)
               ENDDO

               RCLRSC     LVL(*CALLER)

             ENDPGM
