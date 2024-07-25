/******************************************************************************/
/*                                                                            */
/*  USRMSG    Send a message to specified user.                               */
/*  25 August 1998                                                            */
/*  R. Harrison                                                               */
/*  Created using PUTMSG                                                      */
/*                                                                            */
/*                                                                            */
/******************************************************************************/

             PGM        PARM(&MUSER &MSGDATA &PUSER &PJOB &MCORD)

             DCL        VAR(&MUSER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&PUSER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&PJOB)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&MCORD)     TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGDATA)   TYPE(*CHAR) LEN(128)
             DCL        VAR(&PMSDATA)   TYPE(*CHAR) LEN(128)
             CHGVAR     VAR(&PMSDATA) VALUE('Unable to notify +
                          selector' *BCAT &MUSER)

             SNDMSG MSG(&MCORD *BCAT &MSGDATA) TOUSR(&MUSER)
             MONMSG     MSGID(CPF0001) EXEC(SNDBRKMSG MSG(&PMSDATA) +
                          TOMSGQ(&PJOB))
 /*          MONMSG     MSGID(CPF0001) EXEC(SNDMSG MSG(&PMSDATA) + */
 /*                       TOUSR(&PUSER))                           */

             RETURN

             ENDPGM
