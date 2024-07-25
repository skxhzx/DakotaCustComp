/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TM810CL   Create Truck/Zone Definitions                          */
/*  13 June,1997                                                     */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TM810CL:    PGM        PARM(&WHSE15 &TTYPE &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(TM810CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(TM810)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Create Truck/Zone Definitions')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Creating Truck/Zone Definitions')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TTYPE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE15)     TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&WHSE3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSE3A)     TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO CREATE)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE15 &TTYPE &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

/*           IF (&JOBQ = 'Y') THEN(DO)                             */
/*           SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &RETURN  +*/
/*                        &DEV &FORM)) JOB(&SBMPGM)                */
/*           GOTO       CMDLBL(GETOUT)                             */
/*           ENDDO                                                 */

/*  Otherwise, run program. */

 CREATE:

             CHGVAR     VAR(&WHSE3)    VALUE(&WHSE15)
             CHGVAR     VAR(&WHSE3A)   VALUE(&WHSE3)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('SLWHSE *EQ ' *CAT &WHSE3A)

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(TM815) TOFILE(SLOT) SHARE(*YES)
             OPNQRYF    FILE((SLOT)) FORMAT(TM815) QRYSLT(&QRYSLT) +
                          KEYFLD((SLWHSE) (SLWHDP) (SLSTYP)) +
                          GRPFLD(SLWHSE SLWHDP SLSTYP)

 /*          CPYFRMQRYF FROMOPNID(SLOT) TOFILE(PIRWORKF/TST815) + */
 /*                       MBROPT(*ADD) CRTFILE(*YES)              */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(TM815) PARM(&WHSE15 &TTYPE &RETURN)

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
 NOMSG:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
