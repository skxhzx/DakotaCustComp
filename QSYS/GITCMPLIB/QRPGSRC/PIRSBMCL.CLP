/*-----------------------------------------------------------------*/
/*  Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved    */
/*  BFC Software, Inc.                                             */
/*  245 W. Roosevelt Rd.  Bldg 8, Suite 51                         */
/*  West Chicago, IL  60185                                        */
/*  (630) 562-0375                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  PIRIMPCL    Submit PIR Import Jobs                             */
/*  11 October 2006                                                */
/*  Max Blacknik                                                   */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Revisions                                                      */
/*                                                                 */
/*  10/11/06  MLB  5.10                                            */
/*    - Created.                                                   */
/*                                                                 */
/*  11/20/12  RTR  6.40                                            */
/*    - Added processing for *ITEM3, *SLOT3, and *ROUTE5           */
/*                                                                 */
/*  01/29/13  MLB  6.50                                            */
/*    - Enh: Added support for *ITEM4 - FTP Import Item Updates 4. */
/*                                                                 */
/*  01/29/13  MLB  6.50a                                           */
/*    - Enh: Added support for FTP Import Item Updates Misc. file, */
/*      IMPFITMM to Ver3, Ver4 FTP Import Item Updates processes.  */
/*  02/15/13  MLB  6.50b                                           */
/*    - Fix: Corrected references to "Import" instead of "Export". */
/*  08/06/13  MLB  6.50c                                           */
/*    - Fix: Revised CPYFRMIMPF cmd when copying Import Item MIsc. */
/*      file to IMPFFLAT to remove STMFCODPAG(*PCASCII). Was       */
/*      causing CPDA1CA error.                                     */
/*                                                                 */
/*-----------------------------------------------------------------*/

 PIRSBMCL:   PGM        PARM(&PCMD &WHSE &PATH1 &PATH2 &PATH3 &PATH4 +
                          &PATH5 &PATH6 &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.  */


  /* Message queues */

             DCL        VAR(&IMPMSGQ)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&IMPERRMSGQ) TYPE(*CHAR) LEN(10)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&IMPFORMTYP) TYPE(*CHAR) LEN(10)
             DCL        VAR(&IMPMBR)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&IMPMODE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&IMPOUTQ)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&JOBTYPE)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSG)        TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&PATH1)      TYPE(*CHAR) LEN(80)
             DCL        VAR(&PATH2)      TYPE(*CHAR) LEN(80)
             DCL        VAR(&PATH3)      TYPE(*CHAR) LEN(80)
             DCL        VAR(&PATH4)      TYPE(*CHAR) LEN(80)
             DCL        VAR(&PATH5)      TYPE(*CHAR) LEN(80)
             DCL        VAR(&PATH6)      TYPE(*CHAR) LEN(80)
             DCL        VAR(&PCMD)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&RECS)       TYPE(*DEC)  LEN(10 0)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TOFILE)     TYPE(*CHAR) LEN(500)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

   /* Standard message handling variables */


             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

             CHGVAR     VAR(&FINISHED) VALUE('0')

   /* Create interim copy file.                   */

             CRTPF      FILE(QTEMP/IMPFFLAT) RCDLEN(1024) +
                          SIZE(*NOMAX) WAITRCD(30) SHARE(*NO) +
                          REUSEDLT(*YES) AUT(*ALL)
             MONMSG     MSGID(CPF7302) EXEC(DO)
               CLRPFM     FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT)
             enddo

   /* Setup Standard Import Processing Variables. */

             CHGVAR     VAR(&IMPMODE) VALUE('*INTER')
             CHGVAR     VAR(&IMPOUTQ) VALUE('*JOB')
             CHGVAR     VAR(&IMPFORMTYP) VALUE('*STD')
             CHGVAR     VAR(&TOFILE) +
                          VALUE('/qsys.lib/qtemp.lib/impfflat.file/im+
                          pfflat.mbr')

/*-----------------------------------------------------------------*/
/*        Submit Item Updates for Processing.                      */
/*-----------------------------------------------------------------*/

             IF         COND(&PCMD = '*ITEM2') THEN(DO)
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPITEM')
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPITEMERR')

/*           Create member name */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
               CHGVAR     VAR(&MBR) VALUE('I' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)

/*           Create members for import files                         (650bM) */
               IF         COND(&PATH1 > ' ') THEN(DO)
                 ADDPFM     FILE(IMPFITMN) MBR(&MBR)
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                   CLRPFM     FILE(IMPFITMN) MBR(&MBR)
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                     GOTO       CMDLBL(GETOUT)
                   ENDDO
                 ENDDO


/*               CPYFRMIMPF cmd to be used at a later date. Does not work +
                            work well with flat text files.                  */
/*               CPYFRMIMPF FROMSTMF(&PATH1) TOFILE(IMPFITMN &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)           */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)            */
                 CPYFRMSTMF FROMSTMF(&PATH1) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) STMFCODPAG(*PCASCII)
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                   GOTO       CMDLBL(GETOUT)
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFITMN) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)
               ENDDO
               ENDDO

               IF         COND(&PATH2 > ' ') THEN(DO)
                 ADDPFM     FILE(IMPFITMM) MBR(&MBR)
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                   CLRPFM     FILE(IMPFITMM) MBR(&MBR)
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                     GOTO       CMDLBL(GETOUT)
                   ENDDO
                 ENDDO

/*               CPYFRMIMPF cmd to be used at a later date. Does not work +
                            work well with flat text files.                  */
/*               CPYFRMIMPF FROMSTMF(&PATH2) TOFILE(IMPFITMM &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)           */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)            */
                 CPYFRMSTMF FROMSTMF(&PATH2) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) STMFCODPAG(*PCASCII)
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                   GOTO       CMDLBL(GETOUT)
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFITMM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)
               ENDDO
               ENDDO

               SBMJOB     CMD(CALL PGM(II260CL) PARM(&IMPMBR &IMPMODE +
                            &IMPOUTQ &IMPFORMTYP)) JOB(II260CL) +
                            JOBD(PIRJOBD) JOBQ(QS36EVOKE)

               CHGVAR     VAR(&FINISHED) VALUE('1')
               CHGVAR     VAR(&RETURN)   VALUE('*OK')
             ENDDO

/*-----------------------------------------------------------------*/   /* 640aA */
/*        Submit V3 Item Updates for Processing.                   */   /* 640aA */
/*-----------------------------------------------------------------*/   /* 640aA */

             IF         COND(&PCMD = '*ITEM3' *OR &PCMD = '*ITM3FUL' +
                          *OR &PCMD = '*ITM3PAR') THEN(DO)              /* 640aA */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPITEM')                /* 640aA */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPITEMERR')          /* 640aA */

/*           Create member name */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)                    /* 640aA */
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)                  /* 640aA */
               CHGVAR     VAR(&MBR) VALUE('I' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)                              /* 640aA */

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)                  /* 640aA */

/*           Create members for import files */                         /* 650bM */
               IF         COND(&PATH1 > ' ') THEN(DO)                   /* 640aA */
                 ADDPFM     FILE(IMPFITM3) MBR(&MBR)                    /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)             /* 640aA */
                   CLRPFM     FILE(IMPFITM3) MBR(&MBR)                  /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)           /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 640aA */
                     GOTO       CMDLBL(GETOUT)                          /* 640aA */
                   ENDDO                                                /* 640aA */
                 ENDDO                                                  /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH1) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                          /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO) /* 640aA */
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 640aA */
                   GOTO       CMDLBL(GETOUT)                            /* 640aA */
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                      /* 640aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFITM3) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 640aA */
               ENDDO                                                    /* 640aA */
               ENDDO                                                    /* 640aA */
                                                                        /* 650aA */
               IF         COND(&PATH2 > ' ') THEN(DO)                   /* 650aA */
                 ADDPFM     FILE(IMPFITMM) MBR(&MBR)                    /* 650aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)             /* 650aA */
                   CLRPFM     FILE(IMPFITMM) MBR(&MBR)                  /* 650aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)           /* 650aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 650aA */
                     GOTO       CMDLBL(GETOUT)                          /* 650aA */
                   ENDDO                                                /* 650aA */
                 ENDDO                                                  /* 650aA */
                                                                        /* 650aA */
/*               CPYFRMIMPF cmd to be used at a later date. Does not +
                            work well with flat text files.                650aA */
/*               CPYFRMIMPF FROMSTMF(&PATH2) TOFILE(IMPFITMM &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)      /* 650aA */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)       /* 650aA */
                 CPYFRMSTMF FROMSTMF(&PATH2) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) STMFCODPAG(*PCASCII)     /* 650aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO) /* 650aA */
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 650aA */
                   GOTO       CMDLBL(GETOUT)                            /* 650aA */
                 ENDDO                                                  /* 650aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS) +
                                                                        /* 650aA */
               IF         COND(&RECS > 0) THEN(DO)                      /* 650aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFITMM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 650aA */
               ENDDO                                                    /* 650aA */
               ENDDO                                                    /* 650aA */

                            CALL PGM(PIRFTPIMP) PARM(&PCMD &IMPMBR +
                          &IMPMODE &IMPOUTQ &IMPFORMTYP)

               CHGVAR     VAR(&FINISHED) VALUE('1')                     /* 640aA */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')                   /* 640aA */
             ENDDO                                                      /* 640aA */

/*-----------------------------------------------------------------*/   /* 650 A */
/*        Submit V4 Item Updates for Processing.                   */   /* 650 A */
/*-----------------------------------------------------------------*/   /* 650 A */

             IF         COND(&PCMD = '*ITEM4' *OR &PCMD = '*ITM4FUL' +
                          *OR &PCMD = '*ITM4PAR') THEN(DO)              /* 650 A */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPITEM')                /* 650 A */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPITEMERR')          /* 650 A */

/*           Create member name */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)                    /* 650 A */
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)                  /* 650 A */
               CHGVAR     VAR(&MBR) VALUE('I' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)                              /* 650 A */

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)                  /* 650 A */

/*           Create members for import files */                         /* 650bM */
               IF         COND(&PATH1 > ' ') THEN(DO)                   /* 650 A */
                 ADDPFM     FILE(IMPFITM4) MBR(&MBR)                    /* 650 A */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)             /* 650 A */
                   CLRPFM     FILE(IMPFITM4) MBR(&MBR)                  /* 650 A */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)           /* 650 A */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 650 A */
                     GOTO       CMDLBL(GETOUT)                          /* 650 A */
                   ENDDO                                                /* 650 A */
                 ENDDO                                                  /* 650 A */

                 CPYFRMSTMF FROMSTMF(&PATH1) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                          /* 650 A */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO) /* 650 A */
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 650 A */
                   GOTO       CMDLBL(GETOUT)                            /* 650 A */
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                      /* 650 A */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFITM4) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 650 A */
               ENDDO                                                    /* 650 A */
               ENDDO                                                    /* 650 A */
                                                                        /* 650aA */
               IF         COND(&PATH2 > ' ') THEN(DO)                   /* 650aA */
                 ADDPFM     FILE(IMPFITMM) MBR(&MBR)                    /* 650aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)             /* 650aA */
                   CLRPFM     FILE(IMPFITMM) MBR(&MBR)                  /* 650aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)           /* 650aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 650aA */
                     GOTO       CMDLBL(GETOUT)                          /* 650aA */
                   ENDDO                                                /* 650aA */
                 ENDDO                                                  /* 650aA */
                                                                        /* 650aA */
/*               CPYFRMIMPF cmd to be used at a later date. Does not +
                            work well with flat text files.                650aA */
/*               CPYFRMIMPF FROMSTMF(&PATH2) TOFILE(IMPFITMM &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)      /* 650aA */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)       /* 650aA */
                 CPYFRMSTMF FROMSTMF(&PATH2) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) /* STMFCODPAG(*PCASCII)  /* 650cM */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO) /* 650aA */
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 650aA */
                   GOTO       CMDLBL(GETOUT)                            /* 650aA */
                 ENDDO                                                  /* 650aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS) +
                                                                        /* 650aA */
               IF         COND(&RECS > 0) THEN(DO)                      /* 650aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFITMM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 650aA */
               ENDDO                                                    /* 650aA */
               ENDDO                                                    /* 650aA */

                            CALL PGM(PIRFTPIMP) PARM(&PCMD &IMPMBR +
                          &IMPMODE &IMPOUTQ &IMPFORMTYP)

               CHGVAR     VAR(&FINISHED) VALUE('1')                     /* 650 A */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')                   /* 650 A */
             ENDDO                                                      /* 650 A */

/*-----------------------------------------------------------------*/   /* 640aA */
/*        Submit V3 Slot Updates for Processing                    */   /* 640aA */
/*-----------------------------------------------------------------*/   /* 640aA */

             IF         COND(&PCMD = '*SLOT3F' *OR &PCMD = +
                          '*SLOT3P') THEN(DO)                           /* 640aA */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPITEM')                /* 640aA */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPITEMERR')          /* 640aA */

/*           Create member name */                                      /* 640aA */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)                    /* 640aA */
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)                  /* 640aA */
               CHGVAR     VAR(&MBR) VALUE('S' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)                              /* 640aA */

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)                  /* 640aA */

/*           Create members for import files */                         /* 640bM */
               IF         COND(&PATH1 > ' ') THEN(DO)                   /* 640aA */
                 ADDPFM     FILE(IMPFSTUF3) MBR(&MBR)                   /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)             /* 640aA */
                   CLRPFM     FILE(IMPFSTUF3) MBR(&MBR)                 /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)           /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 640aA */
                     GOTO       CMDLBL(GETOUT)                          /* 640aA */
                   ENDDO                                                /* 640aA */
                 ENDDO                                                  /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH1) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                          /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO) /* 640aA */
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 640aA */
                   GOTO       CMDLBL(GETOUT)                            /* 640aA */
                 ENDDO                                                  /* 640aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                      /* 640aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFSTUF3) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 640aA */
               ENDDO                                                    /* 640aA */
               ENDDO                                                    /* 640aA */

               IF         COND(&PCMD = '*SLOT3F') THEN(SBMJOB CMD(CALL +
                            PGM(FTPSTUFIT3) PARM('*FULL' &IMPMBR +
                            &IMPMODE &IMPOUTQ &IMPFORMTYP)) +
                            JOB(FTPSTUFIT3))                            /* 640aA */
               ELSE       CMD(SBMJOB CMD(CALL PGM(FTPSTUFIT3) +
                            PARM('*PARTIAL' &IMPMBR &IMPMODE &IMPOUTQ +
                            &IMPFORMTYP)) JOB(FTPSTUFIT3))              /* 640aA */

               CHGVAR     VAR(&FINISHED) VALUE('1')                     /* 640aA */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')                   /* 640aA */
             ENDDO                                                      /* 640aA */

/*-----------------------------------------------------------------*/
/*        Submit Purchase Order Updates for Processing             */
/*-----------------------------------------------------------------*/

             IF         COND(&PCMD = '*PO2') THEN(DO)
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPPO')
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPPOERR')

/*           Create member name */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
               CHGVAR     VAR(&MBR) VALUE('P' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)

/*           Create members for import files                         (650bM) */
               IF         COND(&PATH1 > ' ') THEN(DO)
                 ADDPFM     FILE(IMPFPOH2) MBR(&MBR)
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                   CLRPFM     FILE(IMPFPOH2) MBR(&MBR)
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                     GOTO       CMDLBL(GETOUT)
                   ENDDO
                 ENDDO

/*               CPYFRMIMPF cmd to be used at a later date. Does not work +
                            work well with flat text files.                  */
/*               CPYFRMIMPF FROMSTMF(&PATH1) TOFILE(IMPFPOH2 &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)           */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)            */
             CPYFRMSTMF FROMSTMF(&PATH1) TOMBR(&TOFILE) +
                          MBROPT(*REPLACE) /* STMFCCSID(*PCASCII) */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                   GOTO       CMDLBL(GETOUT)
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFPOH2) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)
               ENDDO
               ENDDO

               IF         COND(&PATH2 > ' ') THEN(DO)
                 ADDPFM     FILE(IMPFPOHM) MBR(&MBR)
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                   CLRPFM     FILE(IMPFPOHM) MBR(&MBR)
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                     GOTO       CMDLBL(GETOUT)
                   ENDDO
                 ENDDO

/*               CPYFRMIMPF cmd to be used at a later date. Does not work +
                            work well with flat text files.                  */
/*               CPYFRMIMPF FROMSTMF(&PATH2) TOFILE(IMPFPOHM &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)           */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)            */
                 CPYFRMSTMF FROMSTMF(&PATH2) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) /* STMFCODPAG(*PCASCII) */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                   GOTO       CMDLBL(GETOUT)
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFPOHM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)
               ENDDO
               ENDDO

               IF         COND(&PATH3 > ' ') THEN(DO)
                 ADDPFM     FILE(IMPFPOD2) MBR(&MBR)
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                   CLRPFM     FILE(IMPFPOD2) MBR(&MBR)
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                     GOTO       CMDLBL(GETOUT)
                   ENDDO
                 ENDDO

/*               CPYFRMIMPF cmd to be used at a later date. Does not work +
                            work well with flat text files.                  */
/*               CPYFRMIMPF FROMSTMF(&PATH3) TOFILE(IMPFPOD2 &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)           */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)            */
                 CPYFRMSTMF FROMSTMF(&PATH3) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) /* STMFCODPAG(*PCASCII) */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                   GOTO       CMDLBL(GETOUT)
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFPOD2) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)
               ENDDO
               ENDDO

               IF         COND(&PATH4 > ' ') THEN(DO)
                 ADDPFM     FILE(IMPFPODM) MBR(&MBR)
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                   CLRPFM     FILE(IMPFPODM) MBR(&MBR)
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                     GOTO       CMDLBL(GETOUT)
                   ENDDO
                 ENDDO

/*               CPYFRMIMPF cmd to be used at a later date. Does not work +
                            work well with flat text files.                  */
/*               CPYFRMIMPF FROMSTMF(&PATH4) TOFILE(IMPFPODM &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)           */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)            */
                 CPYFRMSTMF FROMSTMF(&PATH4) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) /* STMFCODPAG(*PCASCII) */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                   GOTO       CMDLBL(GETOUT)
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFPODM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)
               ENDDO
               ENDDO

               SBMJOB     CMD(CALL PGM(PI260CL) PARM(&IMPMBR &IMPMODE +
                            &IMPOUTQ &IMPFORMTYP)) JOB(PI260CL) +
                            JOBD(PIRJOBD) JOBQ(QS36EVOKE)

               CHGVAR     VAR(&FINISHED) VALUE('1')
               CHGVAR     VAR(&RETURN)   VALUE('*OK')
             ENDDO

/*-----------------------------------------------------------------*/
/*        Submit Customer Order Updates for Processing             */
/*-----------------------------------------------------------------*/

             IF         COND(&PCMD = '*ROUTE' *OR &PCMD = '*WILL') +
                          THEN(DO)
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPORD')
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPORDERR')

/*           Create member name */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
               IF         COND(&PCMD = '*WILL') THEN(DO)
                 CHGVAR     VAR(&MBR) VALUE('W' *CAT %SST(&WHSE 2 2) +
                              *CAT &NXTNUMA)
               ENDDO
               ELSE       CMD(DO)
                 CHGVAR     VAR(&MBR) VALUE('R' *CAT %SST(&WHSE 2 2) +
                              *CAT &NXTNUMA)
               ENDDO

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)

/*           Create members for import files                         (650bM) */
               IF         COND(&PATH1 > ' ') THEN(DO)
                 ADDPFM     FILE(IMPFORDH) MBR(&MBR)
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                   CLRPFM     FILE(IMPFORDH) MBR(&MBR)
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                     GOTO       CMDLBL(GETOUT)
                   ENDDO
                 ENDDO

/*               CPYFRMIMPF cmd to be used at a later date. Does not work +
                            work well with flat text files.                  */
/*               CPYFRMIMPF FROMSTMF(&PATH1) TOFILE(IMPFORDH &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)           */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)            */
                 CPYFRMSTMF FROMSTMF(&PATH1) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) STMFCODPAG(*PCASCII)
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                   GOTO       CMDLBL(GETOUT)
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDH) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)
               ENDDO
               ENDDO

               IF         COND(&PATH2 > ' ') THEN(DO)
                 ADDPFM     FILE(IMPFORDHM) MBR(&MBR)
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                   CLRPFM     FILE(IMPFORDHM) MBR(&MBR)
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                     GOTO       CMDLBL(GETOUT)
                   ENDDO
                 ENDDO

/*               CPYFRMIMPF cmd to be used at a later date. Does not work +
                            work well with flat text files.                  */
/*               CPYFRMIMPF FROMSTMF(&PATH2) TOFILE(IMPFORDHM &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)           */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)            */
                 CPYFRMSTMF FROMSTMF(&PATH2) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) STMFCODPAG(*PCASCII)
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                   GOTO       CMDLBL(GETOUT)
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDHM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)
               ENDDO
               ENDDO

               IF         COND(&PATH3 > ' ') THEN(DO)
                 ADDPFM     FILE(IMPFORDD) MBR(&MBR)
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                   CLRPFM     FILE(IMPFORDD) MBR(&MBR)
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                     GOTO       CMDLBL(GETOUT)
                   ENDDO
                 ENDDO

/*               CPYFRMIMPF cmd to be used at a later date. Does not work +
                            work well with flat text files.                  */
/*               CPYFRMIMPF FROMSTMF(&PATH3) TOFILE(IMPFORDD &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)           */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)            */
                 CPYFRMSTMF FROMSTMF(&PATH3) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) STMFCODPAG(*PCASCII)
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                   GOTO       CMDLBL(GETOUT)
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDD) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)
               ENDDO
               ENDDO

               IF         COND(&PATH4 > ' ') THEN(DO)
                 ADDPFM     FILE(IMPFORDM) MBR(&MBR)
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                   CLRPFM     FILE(IMPFORDM) MBR(&MBR)
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                     GOTO       CMDLBL(GETOUT)
                   ENDDO
                 ENDDO

/*               CPYFRMIMPF cmd to be used at a later date. Does not work +
                            work well with flat text files.                  */
/*               CPYFRMIMPF FROMSTMF(&PATH4) TOFILE(IMPFORDM &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)           */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)            */
                 CPYFRMSTMF FROMSTMF(&PATH4) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) STMFCODPAG(*PCASCII)
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                   GOTO       CMDLBL(GETOUT)
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)
               ENDDO
               ENDDO

               SBMJOB     CMD(CALL PGM(OI250CL) PARM(&IMPMBR &PCMD &IMPMODE +
                            &IMPOUTQ &IMPFORMTYP)) JOB(OI250CL) +
                            JOBD(PIRJOBD) JOBQ(QS36EVOKE)

               CHGVAR     VAR(&FINISHED) VALUE('1')
               CHGVAR     VAR(&RETURN)   VALUE('*OK')
             ENDDO

/*-----------------------------------------------------------------*/   /* 640aA */
/*        Submit V5 Customer Order Updates for Processing          */   /* 640aA */
/*-----------------------------------------------------------------*/   /* 640aA */

             IF         COND(&PCMD = '*ROUTE5' *OR &PCMD = '*WILL5') +
                          THEN(DO)                                      /* 640aA */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPORD')                 /* 640aA */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPORDERR')           /* 640aA */

/*           Create member name */                                      /* 640aA */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)                    /* 640aA */
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)                  /* 640aA */
               IF         COND(&PCMD = '*WILL') THEN(DO)                /* 640aA */
                 CHGVAR     VAR(&MBR) VALUE('W' *CAT %SST(&WHSE 2 2) +
                              *CAT &NXTNUMA)                            /* 640aA */
               ENDDO                                                    /* 640aA */
               ELSE       CMD(DO)                                       /* 640aA */
                 CHGVAR     VAR(&MBR) VALUE('R' *CAT %SST(&WHSE 2 2) +
                              *CAT &NXTNUMA)                            /* 640aA */
               ENDDO                                                    /* 640aA */

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)                  /* 640aA */

/*           Create members for import files                         (650bM) */
               IF         COND(&PATH1 > ' ') THEN(DO)                   /* 640aA */
                 ADDPFM     FILE(IMPFORDH5) MBR(&MBR)                   /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)             /* 640aA */
                   CLRPFM     FILE(IMPFORDH5) MBR(&MBR)                 /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)           /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 640aA */
                     GOTO       CMDLBL(GETOUT)                          /* 640aA */
                   ENDDO                                                /* 640aA */
                 ENDDO                                                  /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH1) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                          /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 640aA */
                   GOTO       CMDLBL(GETOUT)                            /* 640aA */
                 ENDDO                                                  /* 640aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                      /* 640aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDH5) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 640aA */
               ENDDO                                                    /* 640aA */
               ENDDO                                                    /* 640aA */

               IF         COND(&PATH2 > ' ') THEN(DO)                   /* 640aA */
                 ADDPFM     FILE(IMPFORDD5) MBR(&MBR)                   /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)             /* 640aA */
                   CLRPFM     FILE(IMPFORDD5) MBR(&MBR)                 /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)           /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 640aA */
                     GOTO       CMDLBL(GETOUT)                          /* 640aA */
                   ENDDO                                                /* 640aA */
                 ENDDO                                                  /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH2) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                          /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 640aA */
                   GOTO       CMDLBL(GETOUT)                            /* 640aA */
                 ENDDO                                                  /* 640aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                      /* 640aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDD5) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 640aA */
               ENDDO                                                    /* 640aA */
               ENDDO                                                    /* 640aA */

               IF         COND(&PATH3 > ' ') THEN(DO)                   /* 640aA */
                 ADDPFM     FILE(IMPFORDHM) MBR(&MBR)                   /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)             /* 640aA */
                   CLRPFM     FILE(IMPFORDHM) MBR(&MBR)                 /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)           /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 640aA */
                     GOTO       CMDLBL(GETOUT)                          /* 640aA */
                   ENDDO                                                /* 640aA */
                 ENDDO                                                  /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH3) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                          /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 640aA */
                   GOTO       CMDLBL(GETOUT)                            /* 640aA */
                 ENDDO                                                  /* 640aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDHM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 640aA */
               ENDDO                                                    /* 640aA */
               ENDDO                                                    /* 640aA */

               IF         COND(&PATH4 > ' ') THEN(DO)                   /* 640aA */
                 ADDPFM     FILE(IMPFORDDM) MBR(&MBR)                   /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)             /* 640aA */
                   CLRPFM     FILE(IMPFORDDM) MBR(&MBR)                 /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)           /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 640aA */
                     GOTO       CMDLBL(GETOUT)                          /* 640aA */
                   ENDDO                                                /* 640aA */
                 ENDDO                                                  /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH4) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                          /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 640aA */
                   GOTO       CMDLBL(GETOUT)                            /* 640aA */
                 ENDDO                                                  /* 640aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                      /* 640aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDDM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 640aA */
               ENDDO                                                    /* 640aA */
               ENDDO                                                    /* 640aA */

               SBMJOB     CMD(CALL PGM(PIRFTPIMP) PARM('*ROUTE5' +
                            &IMPMBR &IMPMODE &IMPOUTQ &IMPFORMTYP)) +
                            JOB(PIRFTPIMP)                              /* 640aA */

               CHGVAR     VAR(&FINISHED) VALUE('1')                     /* 640aA */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')                   /* 640aA */
             ENDDO                                                      /* 640aA */

/*-----------------------------------------------------------------*/
/*        Nothing done.                                            */   /* 640aA */
/*-----------------------------------------------------------------*/

             GOTO       CMDLBL(NOMSG)                                   /* 640aA */

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

 GETOUT:
             IF COND(&FINISHED = '0') THEN(DO)

             IF         COND(&IMPMSGQ = ' ') THEN(CHGVAR +
                          VAR(&IMPMSGQ) VALUE('QSYSOPR'))               /* 640aA */
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&IMPMSGQ) MSGTYPE(*INFO)

             IF         COND(&IMPERRMSGQ = ' ') THEN(CHGVAR +
                          VAR(&IMPMSGQ) VALUE('QSYSOPR'))               /* 640aA */
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&IMPERRMSGQ) MSGTYPE(*INFO)      /* (650bM) */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          MSGTYPE(*INFO) KEYVAR(&MSGKEY)          /* (650bM) */
             ENDDO

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) MSGTYPE(*COMP)

               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) TOMSGQ(&IMPMSGQ) MSGTYPE(*COMP)

             IF COND(&FINISHED = '0') THEN(DO)
               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOMSGQ(&IMPERRMSGQ) +
                          MSGTYPE(*COMP)
               CHGVAR     VAR(&FINISHED) VALUE('1')                     /* 640aA */
             ENDDO

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

               RCLRSC     LVL(*CALLER)

             ENDPGM
