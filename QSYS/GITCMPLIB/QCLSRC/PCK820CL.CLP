/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PCK820CL  Create IMPFITMO member from PIRITEM file               */
/*  22 August 2000                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    08/22/00  DAS  4.14                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PCK820CL:   PGM        PARM(&MBR &QTYFROM &QTYTO)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Import file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE(IMPFITMO)

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PCK820CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PCK820)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Create IMPFITMO member')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Creating IMPFITMO member')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&FILE)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QTYFROM)    TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&QTYTO)      TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&YNOPTS)     TYPE(*CHAR) LEN(20)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO SKIP1)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&MBR &QTYFROM &QTYTO &RETURN)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&MBR &QTYFROM +
                          &QTYTO)) JOB(&SBMPGM)
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 SKIP1:

/* Get printer device to use and then execute print program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)


/* See if member exists. */

             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

/* If member does exist, clear it */

             IF (&EXIST) DO
                CLRPFM  FILE(&FILE) MBR(&MBR)
             ENDDO

/* If member does not exist, create it */

             IF (*NOT &EXIST) DO
                ADDPFM  FILE(&FILE) MBR(&MBR)
             ENDDO

/* Override import file to correct member */

             OVRDBF     FILE(&FILE) TOFILE(*FILE) MBR(&MBR)

             CALL       PGM(PCK825) PARM(&TYPE &QTYFROM &QTYTO)

/*  Receive any messages and pass them on  */

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
 NOMSG:

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
