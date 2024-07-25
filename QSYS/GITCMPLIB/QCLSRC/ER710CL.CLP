/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER710CL   Current Selection by crew                              */
/*  27 December, 2010                                                */
/*  Ginger Andrews                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*    12/27/10  GJA  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    02/16/12  RBD  6.40a                                           */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: City Line Distributors                  */
/*                                                                   */
/*    02/16/12  RBD  CLD                                             */
/*      - Revised program to only allow authorized users to run      */
/*        run this program.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ER710CL:    PGM        PARM(&PWHSE &PCREW &PDTE &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (640aA) */

             DCL        VAR(&CITYLINE) TYPE(*CHAR) LEN(10) +
                          VALUE('CITYLINE  ')                     /* (CLD A) */


  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(ER710)

  /* Report FILE names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(ER711)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Current Selection by crew')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Creating Current Selection by crew')
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (CLD A) */


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)      /* (CLD A) */
             DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)      /* (CLD A) */
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)       /* (CLD A) */
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)      /* (CLD A) */
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER2)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER3)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PCMD)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PCREW)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PDTE)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
                                                                  /* (640aA) */
/* Retrieve client id.                                               (640aA) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (640aA) */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Check if user is authorized to use this option                   (CLD A) */

             IF         COND(&CLIENT *EQ &CITYLINE)  THEN(DO)     /* (CLD A) */
               CHGVAR     VAR(&PGMID) VALUE(ER710CL)              /* (CLD A) */
               RTVJOBA    USER(&PUSR)                             /* (CLD A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR +
                            &PRTN)                                /* (CLD A) */
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (CLD A) */
                          SNDPGMMSG  MSG(&NOAUTHRZE)   +
                          MSGTYPE(*INFO)                          /* (CLD A) */
               RETURN                                             /* (CLD A) */
               ENDDO                                              /* (CLD A) */
             ENDDO                                                /* (CLD A) */

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER)
                ENDDO

             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)


 AGAIN:

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&PWHSE &PCREW &PDTE &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               GOTO       CMDLBL(GETOUT)
             ENDDO


 REFRESH:
             RCLRSC     LVL(*CALLER)
             RMVMSG     CLEAR(*ALL)

/*  Clear Work file. */

             CLRPFM     FILE(ER711) MBR(&MEMBER)

 REPORT:
             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(ER711) PARM(&PWHSE &PCREW &PDTE)

             CALL       PGM(ER711D) PARM(&PWHSE &PCREW &PDTE &RETURN)

             IF COND(&RETURN = '*REFRESH') THEN(DO)
             GOTO REFRESH
             ENDDO

             IF COND(&RETURN = '*CANCEL ') THEN(DO)
             RCLRSC     LVL(*CALLER)
             GOTO AGAIN
             ENDDO

/*  Clean up before leaving */

             RMVMSG     CLEAR(*ALL)

/*  Receive any messages and pass them on  */

 GETOUT:
             RCLRSC     LVL(*CALLER)
             DLTOVR     FILE(&FILE)
             MONMSG     MSGID(CPF9841)

             RMVM       FILE(&FILE) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF7301 CPF7310)

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

             ENDPGM
