/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV110PCL  Remove pick or overflow slots from inventory scope     */
/*  24 October 2000                                                  */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    06/10/00  RH    4.15a                                          */
/*      - Added RCNT                                                 */
/*-------------------------------------------------------------------*/

 IV110PCL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV110PCL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV110P)

  /*  file. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(INVSLOT)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Remove slots from scope')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&PICK)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&CNT)        TYPE(*CHAR) LEN(5)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &PICK &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/*  Remove slots from inventory scope. */

             MSGBFC     MESSAGE('Removing slots from scope')

/*  Call program to remove pick slots. */

             IF (&PICK = 'Y') THEN(DO)

             MSGBFC     MESSAGE('Removing pick slot')
             CALL       PGM(IV112P) PARM(&WHSE &CNT &RETURN)
   /* 4.15   CALL       PGM(IV112P) PARM(&WHSE &RETURN)  */

   /*  See if error occured. */

             IF         COND(&RETURN = '*PGMQ') THEN(GOTO GETOUT)
               ENDDO
/*  Call program to remove overflow slots. */

             IF (&PICK = 'N') THEN(DO)


             MSGBFC     MESSAGE('Removing overflow slots')
             CALL       PGM(IV111P) PARM(&WHSE &CNT &RETURN)
  /* 4.15    CALL       PGM(IV111P) PARM(&WHSE &RETURN) */

   /*  See if error occured. */

             IF         COND(&RETURN = '*PGMQ') THEN(GOTO GETOUT)
               ENDDO


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
