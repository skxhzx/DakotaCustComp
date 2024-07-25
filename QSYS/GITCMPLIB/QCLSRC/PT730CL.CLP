/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT730CL   FTP export closed replenishment trans - Host execute   */
/*  03 February 2005                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*   07/09/07  MLB  5.10                                             */
/*     - Fix: Revised program to add MONMSG's to DLTOVR cmd's.       */
/*   11/12/07  MLB  5.10a                                            */
/*     - Fix: Revised program to remove RCLRSC cmd.                  */
/*                                                                   */
/*   12/05/08  MLB  5.20                                             */
/*     - Enh: Added client custom code support to program.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: City Line Distributors                  */
/*                                                                   */
/*   12/04/08  MLB  CLDa                                             */
/*     - Revised program to add semaphore file to export processing. */
/*       Upon successful completion of populating file EXPFRPL, the  */
/*       program will create SEXPFRPL. Also, the pgm will check for  */
/*       existance of SEXPFRPL and if found, send a msg to the FTP   */
/*       log, then exit the program.                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*    This program can be used in place of normal export.            */
/*    That program would execute a program which                     */
/*    would generate and execute an ftp script to send the           */
/*    export files to the host system.                               */
/*                                                                   */
/*    Now, with this program, the host can perform the ftp export    */
/*    by doing a remote program call.                                */
/*                                                                   */
/*    &GTRN is used to re-export transactions with the trans group #.*/
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*    &MBR    -  Member to create. Must start with alpha character.  */
/*    &GTRN   -  Group transaction # to resend for export.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command sequence                                             */
/*                                                                   */
/*    QUOTE RCMD PIR/FTPLIBL *PROD                                   */
/*    QUOTE RCMD PT730CL ('001' 'R001' '')                           */
/*    GET PIRF/EXPFRPL.P001 C:\TRANSFER400\EXPFRPL.TXT               */
/*    DEL PIRF/EXPFRPL.P001                                          */
/*                                                                   */
/*    Note: The DEL statements are optional. This program will       */
/*          automatically clear the members before doing the export. */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Member name notes                                                */
/*                                                                   */
/*   - The first character of the member name must be an alpha       */
/*     character.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program is to be used by a host ftp script.                */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PT730CL:    PGM        PARM(&WHSE &MBR &GTRN)

/*  Client Custom Identifiers                                     /* (520 A) */
             DCL        VAR(&CITYLINE) TYPE(*CHAR) LEN(10) +
                          VALUE('CITYLINE  ')                     /* (CLDaA) */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT730)
  /* Re-Export program. */

             DCL        VAR(&REXPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT730B)

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPTRN')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPTRNERR')

  /* Import files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFRPL')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)      /* (520 A) */
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)      /* (520 A) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&FROMLIB)    TYPE(*CHAR) LEN(10)      /* (CLDaA) */
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&NBREXPRCD)  TYPE(*DEC)  LEN(10 0)    /* (CLD A) */
             DCL        VAR(&SAVMBR)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&SEMAPHORE)  TYPE(*CHAR) LEN(4)       /* (CLDaA) */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&GTRN)       TYPE(*CHAR) LEN(7)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get client identifier                                             (520 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (520 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Create members for export files. Reuse them if they exist. */

             IF         COND(&CLIENT = &CITYLINE) THEN(DO)        /* (CLDaA) */
               CHGVAR     VAR(&SEMAPHORE) VALUE('*YES')           /* (CLDaA) */
               CHKOBJ     OBJ(SEXPFRPL) OBJTYPE(*FILE) MBR(&MBR)  /* (CLDaA) */
               MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&SEMAPHORE) +
                            VALUE('*NO ')) /* File not found. ok     (CLDaA) */
               IF         COND(&SEMAPHORE = '*YES') THEN(DO)      /* (CLDaA) */
                 SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                              MSGDTA('*Info* Semaphore file found. +
                              Replenishment export processing skipped. +
                              Replenishment export processing to be +
                              attempted on next cycle.') +
                              TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)     /* (CLDaA) */
                 CHGVAR     VAR(&FINISHED) VALUE('1')             /* (CLDaA) */
                 GOTO       CMDLBL(BOTTOM)                        /* (CLDaA) */
               ENDDO                                              /* (CLDaA) */
             ENDDO                                                /* (CLDaA) */

/* Create members for export files. Reuse them if they exist. */

             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILE) +
                          MBR(&MBR))

/* Clear members       */

             CLRPFM     FILE(&FILE) MBR(&MBR)

/* Use OPNQRYF to select and order the records we need */

             MSGBFC     MESSAGE('Selecting records to export')

/* Select for EXPORT                                   */
             IF (&GTRN =' ') DO
               OVRDBF     FILE(PT730) TOFILE(PIRTRAN) SHARE(*YES)
               CHGVAR     VAR(&QRYSLT) VALUE('PTSTAT *EQ "4" *and +
                            (pttask = "REPL  " *or pttask = +
                            "REPLBK" *or pttask = "REPLTF")')
               OPNQRYF    FILE((PIRTRAN) (FLGTRAN)) +
                            FORMAT(*LIBL/PT730) QRYSLT(&QRYSLT) +
                            KEYFLD((PTTRN#)) JFLD((PIRTRAN/PTTRN# +
                            FLGTRAN/FGTRN# *EQ)) JDFTVAL(*ONLYDFT)
                ENDDO

/* Select for RE-EXPORT                                */
             IF (&GTRN >' ') DO
               OVRDBF     FILE(PT730) TOFILE(PIRTRAN) SHARE(*YES)
               CHGVAR     VAR(&QRYSLT) VALUE('FGGTRN *EQ ' *CAT &GTRN)
               OPNQRYF    FILE((PIRTRAN) (FLGTRAN)) +
                            FORMAT(*LIBL/PT730) QRYSLT(&QRYSLT) +
                            KEYFLD((PTTRN#)) JFLD((PIRTRAN/PTTRN# +
                            FLGTRAN/FGTRN# *EQ))
                ENDDO

/*  Call program to move records to export files */

             OVRDBF     FILE(&FILE) MBR(&MBR)

             IF (&GTRN = ' ') DO
             CALL       PGM(&EXPPGM)
                ENDDO
             IF (&GTRN > ' ') DO
             CALL       PGM(&REXPGM)
                ENDDO

             DLTOVR     FILE(&FILE)
             MONMSG     MSGID(CPF9841)                            /* (510 A) */

             RTVMBRD    FILE(EXPFRPL) MBR(&MBR) RTNLIB(&FROMLIB) +
                          NBRCURRCD(&NBREXPRCD)                   /* (CLDaA) */
             IF         COND(&NBREXPRCD > 0) THEN(DO)             /* (CLDaA) */
/*             Create semaphore file mbr to indicate all done.      (CLDaA) */
               ADDPFM     FILE(SEXPFRPL) MBR(&MBR)                /* (CLDaA) */
               MONMSG     MSGID(CPF5812 CPF7306)                  /* (CLDaA) */
             ENDDO                                                /* (CLDaA) */

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             MONMSG     MSGID(CPF9841)                            /* (510 A) */

/*  Send Successful message */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for member' +
                          *BCAT &MBR) TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             GOTO BOTTOM

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)

             ENDDO

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) TOMSGQ(&FTPMSGQ) MSGTYPE(*COMP)

             IF COND(&FINISHED = '0') THEN(DO)
               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOMSGQ(&FTPERRMSGQ) +
                          MSGTYPE(*COMP)
             ENDDO

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 BOTTOM:

/*             RCLRSC     LVL(*CALLER)                               (510aD) */

        /*  Send '*Escape' message to caller */

               IF COND(&FINISHED = '0') THEN(DO)
                 SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Error Occured Processing Member' +
                          *BCAT &MBR) MSGTYPE(*ESCAPE)
               ENDDO

             ENDPGM
