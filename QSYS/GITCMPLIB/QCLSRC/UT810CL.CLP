/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UT810CL   Recalculate item quantity from slots                   */
/*  07 July 1997                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    01/24/20  MLB  7.40                                            */
/*    - Enh:  Add client custom code support.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Westside Foods                          */
/*                                                                   */
/*    02/12/20  MLB  WST                                             */
/*    - Enh: Revised pgm to add authorization check.                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UT810CL:    PGM        PARM(&WHSE &ITEM &JOBQ)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(UT810CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(UT810)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Recalculate Item Quantity from Slots')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)      /* (740 A) */
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)      /* (740 A) */
             DCL        VAR(&WESTSIDE) TYPE(*CHAR) LEN(10) +
                          VALUE('WESTSIDE  ')                    /* (WST A) */
             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)          /* (740 A) */
             DCL        VAR(&PGMCL) TYPE(*CHAR) LEN(10)  VALUE(UT810CL) +
                                                                  /* (740 A) */
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)           /* (740 A) */
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)          /* (740 A) */
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (740 A) */
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTNMSG)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get Client ID */                                               /* (740 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (740 A) */

/*  Check if user is authorized to use this option                /* (WST A) */

             SELECT                                               /* (WST A) */
             WHEN       COND(&CLIENT = &WESTSIDE) THEN(DO)        /* (WST A) */
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')              /* (WST A) */
               RTVJOBA    USER(&PUSR)                             /* (Wst A) */
               CALL       PGM(CHKLIST) PARM(&PGMCL &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (WST A) */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)        /* (WST A) */
                 RETURN                                           /* (WST A) */
               ENDDO                                              /* (WST A) */
             ENDDO                                                /* (WST A) */
             ENDSELECT                                            /* (WST A) */

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    USER(&USER) TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO RECALC)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &ITEM &JOBQ &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &ITEM +
                          &JOBQ)) JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 RECALC:

             CALL       PGM(UT812) PARM(&WHSE &ITEM &TYPE &SBMPGM +
                          &RETURN &RTNMSG)


 /* Receive any messages and pass them on */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOUSR(&USER) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
