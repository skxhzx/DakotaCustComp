/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT725CL   Export route info.                                     */
/*  19 April 2006                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*                                                                   */
/*      - Revised to clear export members first. Re: can't clear     */
/*        them at end of program because they still need to be       */
/*        retrieved by the host.                                     */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: I-Supply                                */
/*                                                                   */
/*    04/27/06  RH   ISP                                             */
/*      - Revised program to call Host pgm, PIRWINSP.                */
/*    03/03/15  MLB  ISPa                                            */
/*      - Revised ISP mod to only call Host pgm, PIRWINSP           .*/
/*        for whse 001. Per Todd S. email dated 03/02/15.            */
/*    10/19/15  RTR  ISPb                                            */
/*      - Fixed message queues, should not have been EXPPO.         .*/
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*    &CMD    -  *SEND   Export                                      */
/*            -  *RESEND Re-export                                   */
/*                                                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*    &MBR    -  Member to create. Must start with alpha character.  */
/*    &RTID   -  Route ID to be exported.                            */
/*    &RTE    -  Route # to be exported.                             */
/*    &REEX   -  Value if re-export.                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Member name notes                                                */
/*                                                                   */
/*   - The first character of the member name must be an alpha       */
/*     character.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program is to be used by a host ftp script.                */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PT725CL:    PGM        PARM(&WHSE &RTID &RTE &REEX)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT725)
  /* RE-Export program. */

             DCL        VAR(&REXPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT725B)
  /* Status Update program. */

             DCL        VAR(&STSPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT725C)

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPORD')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPORDERR')

  /* Import files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFRTI')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&ID)         TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&SAVMBR)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&REEX)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*           CHGVAR     VAR(&WHSE) VALUE(&WHSEA)  */
             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Get Client Id */                                       /* 500 A */

             CALL       PGM(GETCLIENT) PARM(&ID)

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/*    - Get unique member to use.                                       (417) */
             CALL       PGM(GETUNQMEM) PARM(*REUSE PT725 &MBR)   /*     (417) */

/* Create members for export files. Reuse them if they exist. */

             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILE) +
                          MBR(&MBR))

/* Clear members       */

             CLRPFM     FILE(&FILE) MBR(&MBR)

/* Use OPNQRYF to select and order the records we need */

             MSGBFC     MESSAGE('Selecting records to export')

/* Select for EXPORT                                   */
             IF (&REEX =' ') DO
             OVRDBF     FILE(PT725) TOFILE(LABEL) SHARE(*YES)
             CHGVAR     VAR(&QRYSLT) VALUE('LBWHSE *EQ ' *CAT &WHSEA)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBRTE *EQ +
                          ' *BCAT &QUOTE *CAT &RTID *CAT &QUOTE)
             OPNQRYF    FILE((LABEL)) +
                          FORMAT(*LIBL/PT725) QRYSLT(&QRYSLT)
                ENDDO

/*  Call program to move records to export files */

             OVRDBF     FILE(&FILE) MBR(&MBR)

             IF (&REEX = ' ') DO
             CALL       PGM(&EXPPGM) PARM(&RTE)
             CHGVAR     VAR(&CMD) VALUE('*SEND   ')
                ENDDO
             IF (&REEX > ' ') DO
             CALL       PGM(&REXPGM) PARM(&RTE)
             CHGVAR     VAR(&CMD) VALUE('*RESEND ')
                ENDDO

             DLTOVR     FILE(&FILE)                                 /*  (417) */

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')
/* Call Host Program        */

             CHGVAR     VAR(&RETURN) VALUE('        ')
/*  If client is ISupply                             */
             IF         COND(&ID *EQ 'ISUPPLY') THEN(DO)
               IF         COND(&WHSEA = '001') THEN(DO)           /* (ISPaA) */
             CALL       PGM(ISUPPLY/PIRWINSP) PARM(&CMD &WHSEA +
                           &RTID &RTE &FILE &MBR &RETURN)
               ENDDO                                              /* (ISPaA) */
             ENDDO
/* Call Status Update Program  */

             CALL       PGM(&STSPGM) PARM(&CMD &WHSE +
                           &RTID &RTE)

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

/*  Send Successful message */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for member' +
                          *BCAT &MBR) TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             GOTO BOTTOM

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)

             ENDDO

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) TOMSGQ(&FTPMSGQ) MSGTYPE(*COMP)

             IF COND(&FINISHED = '0') THEN(DO)
               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOMSGQ(&FTPERRMSGQ) +
                          MSGTYPE(*COMP)
             ENDDO

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 BOTTOM:

               RCLRSC     LVL(*CALLER)

        /*  Send '*Escape' message to caller */

               IF COND(&FINISHED = '0') THEN(DO)
                 SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Error Occured Processing Member' +
                          *BCAT &MBR) MSGTYPE(*ESCAPE)
               ENDDO

             ENDPGM
