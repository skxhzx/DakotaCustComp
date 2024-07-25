/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV270CL   Inventory slot assignment                              */
/*  05 May, 2008                                                     */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*  05/07/08 RH V5.20a                                               */
/*      - Changed to only write to workfile, IV271CL & IV272CL       */
/*        will process and update INVSASN using QRYSLT.              */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions:                                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IV270CL:    PGM

/*-------------------------------------------------------------------*/
/*       - Client ID's                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PASS)      TYPE(*DEC)  LEN(1 0) VALUE(1)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV270CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV270)

  /*  OPNQRY file. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(INV270A)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Inventory slot assignment')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

/* 510 A */  DCL        VAR(&YES)        TYPE(*CHAR) LEN(1) VALUE('Y')
/* 510 A */  DCL        VAR(&NO)         TYPE(*CHAR) LEN(1) VALUE('N')
/* 510 A */  DCL        VAR(&QRYSLT2)    TYPE(*CHAR) LEN(2000)
             DCL        VAR(&CTDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&EVEN)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&FDSP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PICK)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TDSP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&TEAM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RPRT)       TYPE(*CHAR) LEN(1) VALUE('N')

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

AGAIN:
/*  options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN)


/*  See if error occured. */

             IF         COND(&RETURN = '*PGMQ') THEN(GOTO GETOUT)


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
