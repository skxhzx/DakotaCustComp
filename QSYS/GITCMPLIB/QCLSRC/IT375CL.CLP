/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT375CL   Print Item Slot List                                   */
/*  17 January, 2002                                                 */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    01/17/02  RH   4.16                                            */
/*      - Created                                                    */
/*                                                                   */
/*    08/26/02  HNK  4.16a                                           */
/*      - Add override for print file.                               */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    03/08/06  CBI -JGD                                             */
/*      Loop back to options screen after pressing ENTER to          */
/*      submit report job.                                           */
/*                                                                   */
/*    08/25/08  CBIa-JGD                                             */
/*      If the number of items being reported is GE 50               */
/*      display 'LARGE REPORT' warning msg and send report           */
/*      to 'PRT01' outq.                                             */
/*                                                                   */
/*      If the number of items being reported is GT 20 and           */
/*      LT 50 display 'LARGE REPORT' warning msg.                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT375CL:    PGM        PARM(&WHSE &RETURN &JOBQ +
                            &DEV &FORM &ITEM &TITEM)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/
/* Client ID's                                                       (700 A) */

             DCL        VAR(&CHENEY) TYPE(*CHAR) LEN(10) +
                          VALUE('CHENEYBROS')                     /* (CBI0 ) */


  /* Name of this program. */

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)          /* (CBI0 ) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (CBI0A) */
             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT375CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT375)


  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Item Slot List')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Item Slot list')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
/* CBIa */   DCL        VAR(&NUMITM)     TYPE(*CHAR) LEN(6)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&TITEM)      TYPE(*CHAR) LEN(15)
/* CBIa */   DCL        VAR(&ITEMS)      TYPE(*DEC)  LEN(6 0)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (CBI0A) */

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

OPTNS:  /* CBI */
/* CBIa */   CHGVAR VAR(&NUMITM) VALUE('000000')
             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN  +
                          &JOBQ &DEV &FORM &ITEM &TITEM &NUMITM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)

              IF         COND(&CLIENT *EQ &CHENEY) THEN(DO)      /* CBI0  */
              GOTO GETOUT
              ENDDO

             RETURN
             ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &RETURN +
                          &JOBQ &DEV &FORM &ITEM &TITEM &NUMITM)) +
                          JOB(*JOBD)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

              IF         COND(&CLIENT *EQ &CHENEY) THEN(DO)      /* CBI0  */
/* CBIa */    CHGVAR VAR(&ITEMS) VALUE(&NUMITM)
              ENDDO

/* CBIa */   IF (&ITEMS *GE 50) THEN(CHGVAR VAR(&DEV) VALUE('PRT01'))

             OVRPRTF    FILE(IT376PR) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(IT376) PARM(&WHSE &ITEM &TITEM)

/* CBI0*/    IF         COND(&CLIENT *EQ &CHENEY *AND +
                        &TYPE *NE '0') THEN(DO)
/* CBI */    GOTO OPTNS
/* CBI0*/    ENDDO


 /* REPORT:    */

 /* Receive any messages and pass them on */

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
 OUT:
 NOMSG:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
