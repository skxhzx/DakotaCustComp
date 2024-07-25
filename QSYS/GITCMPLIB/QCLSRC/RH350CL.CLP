/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH350CL   Daily Route Weight Report                              */
/*  23 February, 2013                                                */
/*  Ginger Andrews                                                   */
/*                                                                   */
/*  Created  6.50                                                    */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RH350CL:    PGM
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RH350CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RH350)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Daily Route Weight Report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Daily Route Weight Report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&BTIM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&ETIM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)

             DCL        VAR(&ERRFLG)     TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRFLG) VALUE('0')
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&FMDT &TODT &WHSE &BTIM +
                          &ETIM &RETURN &DEV &FORM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/*  Otherwise, run program. */

 REPORT:

             OVRPRTF    FILE(RH355PR) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(RH355) PARM(&FMDT &TODT &WHSE &BTIM &ETIM)

             RMVMSG     CLEAR(*ALL)

 /* REPORT:    */

 /* Receive any messages and pass them on */

 GETOUT:
             IF         COND(&ERRFLG *EQ '1') THEN(GOTO BOTTOM)
             CHGVAR     VAR(&ERRFLG) VALUE('1')
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

 BOTTOM:
             RCLRSC     LVL(*CALLER)

             ENDPGM
