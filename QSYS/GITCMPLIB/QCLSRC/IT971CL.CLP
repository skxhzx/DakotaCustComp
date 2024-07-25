/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT971CL   Item Quantity Compare Report - Target                  */
/*  09 October 2014                                                  */
/*  Rod Roller                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    10/10/14  RTR  6.50                                            */
/*      - Created from IT970 and modified to convert Target          */
/*        slot quantity export file.                                 */
/*    09/29/15  RTR  7.00                                            */
/*      - Changed from LP17 to LP24 per Rhonda.                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT971CL:    PGM        PARM(&MBR &PATHFIL)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT971CL)

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPITEM')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPITEMERR')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PATHFIL)    TYPE(*CHAR) LEN(34)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHS)        TYPE(*CHAR) LEN(3) VALUE('001')

/* Get Client ID */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)

             CHGVAR     VAR(&ERRCNT) VALUE(0)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             CHGJOB     LOGCLPGM(*YES)

/* Verify import file mbrs exist, if not found, add them. */
             CHKOBJ     OBJ(IMPFCTARG) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(DO)
               ADDPFM     FILE(IMPFCTARG) MBR(&MBR)
             ENDDO
             CHKOBJ     OBJ(IMPFCQTY) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(DO)
               ADDPFM     FILE(IMPFCQTY) MBR(&MBR)
             ENDDO

/* Convert Host Onhand Qty file from flat file. */
             CPYFRMIMPF FROMFILE(IMPFFLAT1 &MBR) +
                          TOFILE(*LIBL/IMPFCTARG &MBR) +
                          MBROPT(*REPLACE) RCDDLM(*EOR) +
                          STRDLM(*NONE) FLDDLM(*TAB)
             MONMSG     MSGID(CPF2817)

             OVRDBF     FILE(IMPFCTARG) MBR(&MBR)
             OVRDBF     FILE(IMPFCQTY) MBR(&MBR)
             CALL       PGM(IT973) PARM(' ')
             DLTOVR     FILE(*ALL)
             CALL       PGM(IT970CL) PARM(*EXCPTN &MBR &WHS *INTER +
                          'LP24' *STD)

/* Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RMVMSG     CLEAR(*ALL)

/* Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

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

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 BOTTOM:

               RCLRSC     LVL(*CALLER)

             ENDPGM
