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
/*  11/20/12  RTR  6.40                                            */
/*    - Added processing for *ITEM3, *SLOT3, and *ROUTE5           */
/*                                                                 */
/*  02/07/14  MLB  6.50                                            */
/*    - Enh: Added support to submit Staging Import Jobs to        */
/*      batch for processing.                                      */
/*  08/13/14  MLB  6.50a                                           */
/*    - Enh: Added support to submit Staging Import *ORDQTY jobs   */
/*      to batch for processing.                                   */
/*                                                                 */
/*  09/28/20  MLB  7.40                                            */
/*    - Enh: Added support to submit Staging Import Jobs for       */
/*      multiple Dakota WMS versions. JobD library to be received  */
/*      via &RETURN field and moved into &JOBDLIB. Then &RETURN    */
/*      is cleared.                                                */
/*                                                                 */
/*  01/29/13  MLB  7.60  was 6.50 at SFP.                          */
/*    - Enh: Added support for *ITEM4 - FTP Import Item Updates 4. */
/*  01/29/13  MLB  7.60a  was 6.50a at Seashore                    */
/*    - Enh: Added support for FTP Import Item Updates Misc. file, */
/*      IMPFITMM to Ver3, Ver4 FTP Import Item Updates processes.  */
/*  02/15/13  MLB  7.60b  was 6.50b at Seashore                    */
/*    - Fix: Corrected references to "Import" instead of "Export". */
/*  08/06/13  MLB  7.60c  was 6.50c at Seashore                    */
/*    - Fix: Revised CPYFRMIMPF cmd when copying Import Item MIsc. */
/*      file to IMPFFLAT to remove STMFCODPAG(*PCASCII). Was       */
/*      causing CPDA1CA error.                                     */
/*  08/06/13  MLB  7.60d                                           */
/*    - Fix: Revised CPYFRMIMPF cmd when copying Import P/o files  */
/*      to IMPFFLAT to remove STMFCODPAG(*PCASCII). Was            */
/*      causing CPDA1CA error.                                     */
/*                                                                 */
/*-----------------------------------------------------------------*/

 PIRSBMCL:   PGM        PARM(&PCMD &WHSE &PATH1 &PATH2 &PATH3 &PATH4 +
                          &PATH5 &PATH6 &RETURN)

/*----------------------------------------------------------------   (650 A) */
/*  Notes                                                            (650 A) */
/*----------------------------------------------------------------   (650 A) */
/*    - When prefix of $pcmd = '*STG, Batch ID will be sent in       (650 A) */
/*      &path1 and Job Description will be sent in &path2.           (650 A) */

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

             DCL        VAR(&BATID)      TYPE(*CHAR) LEN(11)      /* (650 A) */
             DCL        VAR(&EXIST)      TYPE(*CHAR) LEN(1)       /* (650 A) */
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&IMPFORMTYP) TYPE(*CHAR) LEN(10)
             DCL        VAR(&IMPMBR)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&IMPMODE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&IMPOUTQ)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBD)       TYPE(*CHAR) LEN(10)      /* (650 A) */
             DCL        VAR(&JOBDLIB)    TYPE(*CHAR) LEN(10)      /* (740 A) */
             DCL        VAR(&JOBNAME)    TYPE(*CHAR) LEN(10)      /* (650 A) */
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&JOBQSTG)    TYPE(*CHAR) LEN(10)      /* (650 A) */
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
             DCL        VAR(&PMESSAGE)   TYPE(*CHAR) LEN(200)     /* (650 A) */
             DCL        VAR(&RECS)       TYPE(*DEC)  LEN(10 0)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RETURNS)    TYPE(*CHAR) LEN(10)      /* (650 A) */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TOFILE)     TYPE(*CHAR) LEN(500)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

   /* Standard message handling variables */


             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

             CHGVAR     VAR(&FINISHED) VALUE('0')
             CHGVAR     VAR(&JOBDLIB)  VALUE(&RETURN)             /* (740 A) */
             CHGVAR     VAR(&RETURN)   VALUE(' ')                 /* (740 A) */

             SELECT                                               /* (650 A) */
             WHEN       COND(%SST(&PCMD 1 4) *EQ '*STG') THEN(DO) /* (650 A) */
               CHGVAR     VAR(&BATID) VALUE(%sst(&path1 1 11))    /* (650 A) */
               CHGVAR     VAR(&JOBD) VALUE(%sst(&path2 1 10))     /* (650 A) */
               CHGVAR     VAR(&JOBQSTG) VALUE('IMPSTG' *cat &whse) /*(650 A) */

               CHGVAR     VAR(&EXIST) VALUE('1')                  /* (650 A) */
               CHKOBJ     OBJ(&JOBQSTG) OBJTYPE(*JOBQ)            /* (650 A) */
               MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                            VALUE('0'))                           /* (650 A) */
               IF         COND(&EXIST = '0') THEN(DO)             /* (650 A) */
                 CHGVAR     VAR(&JOBQSTG) VALUE('QBATCH')         /* (650 A) */
               Enddo                                              /* (650 A) */
             Enddo                                                /* (650 A) */

             WHEN       COND(%SST(&PCMD 1 4) *NE '*STG') THEN(DO) /* (650 A) */
   /* Create interim copy file.                   */

             CRTPF      FILE(QTEMP/IMPFFLAT) RCDLEN(1024) +
                          SIZE(*NOMAX) WAITRCD(30) SHARE(*NO) +
                          REUSEDLT(*YES) AUT(*ALL)
             MONMSG     MSGID(CPF7302) EXEC(DO)
               CLRPFM     FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT)
             enddo
             enddo                                                /* (650 A) */
             endselect                                            /* (650 A0 */

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

             SELECT                                               /* (650 A) */
             WHEN       COND(&PCMD = '*ITEM2') THEN(DO)           /* (650 M) */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPITEM')
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPITEMERR')

/*           Create member name */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
               CHGVAR     VAR(&MBR) VALUE('I' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)

/*           Create members for import files */
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
                              MBROPT(*REPLACE) /* STMFCODPAG(*PCASCII) /* 760cM */
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

/*----------------------------------------------------------------*/ /* 640aA */
/*        Submit V3 Item Updates for Processing.                  */ /* 640aA */
/*----------------------------------------------------------------*/ /* 640aA */

             WHEN       COND(&PCMD = '*ITEM3' *OR &PCMD = '*ITM3FUL' +
                          *OR &PCMD = '*ITM3PAR') THEN(DO)        /* (650 M) */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPITEM')             /* 640aA */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPITEMERR')       /* 640aA */

/*           Create member name */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)                 /* 640aA */
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)               /* 640aA */
               CHGVAR     VAR(&MBR) VALUE('I' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)                           /* 640aA */

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)               /* 640aA */

/*           Create members for import files */                      /* 760bM */
               IF         COND(&PATH1 > ' ') THEN(DO)                /* 640aA */
                 ADDPFM     FILE(IMPFITM3) MBR(&MBR)                 /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)          /* 640aA */
                   CLRPFM     FILE(IMPFITM3) MBR(&MBR)               /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)        /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')         /* 640aA */
                     GOTO       CMDLBL(GETOUT)                       /* 640aA */
                   ENDDO                                             /* 640aA */
                 ENDDO                                               /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH1) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                       /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO) +
                                                                     /* 640aA */
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')           /* 640aA */
                   GOTO       CMDLBL(GETOUT)                         /* 640aA */
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                   /* 640aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFITM3) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)        /* 640aA */
               ENDDO                                                 /* 640aA */
               ENDDO                                                 /* 640aA */
                                                                     /* 760aA */
               IF         COND(&PATH2 > ' ') THEN(DO)                /* 760aA */
                 ADDPFM     FILE(IMPFITMM) MBR(&MBR)                 /* 760aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)          /* 760aA */
                   CLRPFM     FILE(IMPFITMM) MBR(&MBR)               /* 760aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)        /* 760aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 760aA */
                     GOTO       CMDLBL(GETOUT)                          /* 760aA */
                   ENDDO                                                /* 760aA */
                 ENDDO                                                  /* 760aA */
                                                                        /* 760aA */
/*               CPYFRMIMPF cmd to be used at a later date. Does not +
                            work well with flat text files.                760aA */
/*               CPYFRMIMPF FROMSTMF(&PATH2) TOFILE(IMPFITMM &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)      /* 760aA */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)       /* 760aA */
                 CPYFRMSTMF FROMSTMF(&PATH2) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) /* STMFCODPAG(*PCASCII)    /* 760cM */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO) /* 760aA */
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 760aA */
                   GOTO       CMDLBL(GETOUT)                            /* 760aA */
                 ENDDO                                                  /* 760aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS) +
                                                                        /* 760aA */
               IF         COND(&RECS > 0) THEN(DO)                      /* 760aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFITMM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 760aA */
               ENDDO                                                    /* 760aA */
               ENDDO                                                    /* 760aA */

                            CALL PGM(PIRFTPIMP) PARM(&PCMD &IMPMBR +
                          &IMPMODE &IMPOUTQ &IMPFORMTYP)

               CHGVAR     VAR(&FINISHED) VALUE('1')                  /* 640aA */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')                /* 640aA */
             ENDDO                                                   /* 640aA */

/*-----------------------------------------------------------------*/   /* 760 A */
/*        Submit V4 Item Updates for Processing.                   */   /* 760 A */
/*-----------------------------------------------------------------*/   /* 760 A */

             When       COND(&PCMD = '*ITEM4' *OR &PCMD = '*ITM4FUL' +
                          *OR &PCMD = '*ITM4PAR') THEN(DO)              /* 760 A */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPITEM')                /* 760 A */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPITEMERR')          /* 760 A */

/*           Create member name */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)                    /* 760 A */
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)                  /* 760 A */
               CHGVAR     VAR(&MBR) VALUE('I' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)                              /* 760 A */

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)                  /* 760 A */

/*           Create members for import files */                         /* 760bM */
               IF         COND(&PATH1 > ' ') THEN(DO)                   /* 760 A */
                 ADDPFM     FILE(IMPFITM4) MBR(&MBR)                    /* 760 A */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)             /* 760 A */
                   CLRPFM     FILE(IMPFITM4) MBR(&MBR)                  /* 760 A */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)           /* 760 A */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 760 A */
                     GOTO       CMDLBL(GETOUT)                          /* 760 A */
                   ENDDO                                                /* 760 A */
                 ENDDO                                                  /* 760 A */

                 CPYFRMSTMF FROMSTMF(&PATH1) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                          /* 760 A */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO) /* 760 A */
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 760 A */
                   GOTO       CMDLBL(GETOUT)                            /* 760 A */
                 ENDDO
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                      /* 760 A */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFITM4) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 760 A */
               ENDDO                                                    /* 760 A */
               ENDDO                                                    /* 760 A */
                                                                        /* 760aA */
               IF         COND(&PATH2 > ' ') THEN(DO)                   /* 760aA */
                 ADDPFM     FILE(IMPFITMM) MBR(&MBR)                    /* 760aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)             /* 760aA */
                   CLRPFM     FILE(IMPFITMM) MBR(&MBR)                  /* 760aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)           /* 760aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')            /* 760aA */
                     GOTO       CMDLBL(GETOUT)                          /* 760aA */
                   ENDDO                                                /* 760aA */
                 ENDDO                                                  /* 760aA */
                                                                        /* 760aA */
/*               CPYFRMIMPF cmd to be used at a later date. Does not +
                            work well with flat text files.                760aA */
/*               CPYFRMIMPF FROMSTMF(&PATH2) TOFILE(IMPFITMM &MBR) +
                              MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)      /* 760aA */
/*               MONMSG     MSGID(CPF2817) CMPDTA(*NONE) EXEC(DO)       /* 760aA */
                 CPYFRMSTMF FROMSTMF(&PATH2) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE) /* STMFCODPAG(*PCASCII)  /* 760cM */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO) /* 760aA */
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')              /* 760aA */
                   GOTO       CMDLBL(GETOUT)                            /* 760aA */
                 ENDDO                                                  /* 760aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS) +
                                                                        /* 760aA */
               IF         COND(&RECS > 0) THEN(DO)                      /* 760aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFITMM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)           /* 760aA */
               ENDDO                                                    /* 760aA */
               ENDDO                                                    /* 760aA */

                            CALL PGM(PIRFTPIMP) PARM(&PCMD &IMPMBR +
                          &IMPMODE &IMPOUTQ &IMPFORMTYP)

               CHGVAR     VAR(&FINISHED) VALUE('1')                     /* 760 A */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')                   /* 760 A */
             ENDDO                                                      /* 760 A */

/*        Process Staging Import Item Updates.                       (650 A) */
             WHEN       COND(&PCMD = '*STGITEM') THEN(DO)         /* (650 A) */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPITEM')          /* (650 A) */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPITEMERR')    /* (650 A) */
               CHGVAR     VAR(&JOBNAME) VALUE('IMPITM' *cat &whse) /*(650 A) */

               SBMJOB     CMD(CALL PGM(II265S) PARM(&WHSE &BATID +
                            &RETURNS &PMESSAGE)) JOB(&JOBNAME) +
                            JOBD(&JOBDLIB/&JOBD) JOBQ(&JOBQSTG) INLLIBL(*JOBD) +
                                                                  /* (740 M) */
               CHGVAR     VAR(&FINISHED) VALUE('1')               /* (650 A) */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')             /* (650 A) */
             ENDDO                                                /* (650 A) */

/*----------------------------------------------------------------*/ /* 640aA */
/*        Submit V3 Slot Updates for Processing                   */ /* 640aA */
/*----------------------------------------------------------------*/ /* 640aA */

             WHEN       COND(&PCMD = '*SLOT3F' *OR &PCMD = +
                          '*SLOT3P') THEN(DO)                     /* (650 M) */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPITEM')             /* 640aA */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPITEMERR')       /* 640aA */

/*           Create member name */                                   /* 640aA */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)                 /* 640aA */
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)               /* 640aA */
               CHGVAR     VAR(&MBR) VALUE('S' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)                           /* 640aA */

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)               /* 640aA */

/*           Create members for import files */                      /* 760bM */
               IF         COND(&PATH1 > ' ') THEN(DO)                /* 640aA */
                 ADDPFM     FILE(IMPFSTUF3) MBR(&MBR)                /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)          /* 640aA */
                   CLRPFM     FILE(IMPFSTUF3) MBR(&MBR)              /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)        /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')         /* 640aA */
                     GOTO       CMDLBL(GETOUT)                       /* 640aA */
                   ENDDO                                             /* 640aA */
                 ENDDO                                               /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH1) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                       /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO) +
                                                                     /* 640aA */
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')           /* 640aA */
                   GOTO       CMDLBL(GETOUT)                         /* 640aA */
                 ENDDO                                               /* 640aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                   /* 640aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFSTUF3) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)        /* 640aA */
               ENDDO                                                 /* 640aA */
               ENDDO                                                 /* 640aA */

               IF         COND(&PCMD = '*SLOT3F') THEN(SBMJOB CMD(CALL +
                            PGM(FTPSTUFIT3) PARM('*FULL' &IMPMBR +
                            &IMPMODE &IMPOUTQ &IMPFORMTYP)) +
                            JOB(FTPSTUFIT3))                         /* 640aA */
               ELSE       CMD(SBMJOB CMD(CALL PGM(FTPSTUFIT3) +
                            PARM('*PARTIAL' &IMPMBR &IMPMODE &IMPOUTQ +
                            &IMPFORMTYP)) JOB(FTPSTUFIT3) +
                            JOBD(&JOBDLIB/&JOBD))                    /* (740 M) */

               CHGVAR     VAR(&FINISHED) VALUE('1')                  /* 640aA */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')                /* 640aA */
             ENDDO                                                   /* 640aA */

/*-----------------------------------------------------------------*/
/*        Submit Purchase Order Updates for Processing             */
/*-----------------------------------------------------------------*/

             WHEN       COND(&PCMD = '*PO2') THEN(DO)             /* (650 M) */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPPO')
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPPOERR')

/*           Create member name */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
               CHGVAR     VAR(&MBR) VALUE('P' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)

/*           Create members for import files                      /* (760bM) */
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
                              MBROPT(*REPLACE) /* STMFCODPAG(*PCASCII) /* 760dM */
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
                              MBROPT(*REPLACE) /* STMFCODPAG(*PCASCII) /* 760dM */
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
                              MBROPT(*REPLACE) /* STMFCODPAG(*PCASCII) /* 760dM */
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

               SBMJOB     CMD(CALL PGM(PI260CL) PARM(&IMPMBR &IMPMODE +
                            &IMPOUTQ &IMPFORMTYP)) JOB(PI260CL) +
                            JOBD(PIRJOBD) JOBQ(QS36EVOKE)

               CHGVAR     VAR(&FINISHED) VALUE('1')
               CHGVAR     VAR(&RETURN)   VALUE('*OK')
             ENDDO

/*        Process Staging Import Purchase Order Updates.             (650 A) */
             WHEN       COND(&PCMD = '*STGPO') THEN(DO)           /* (650 A) */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPPO')            /* (650 A) */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPPOERR')      /* (650 A) */
               CHGVAR     VAR(&JOBNAME) VALUE('IMPPO' *cat &whse) /* (650 A) */

               SBMJOB     CMD(CALL PGM(PI265S) PARM(&WHSE &BATID +
                            &RETURNS &PMESSAGE)) JOB(&JOBNAME) +
                            JOBD(&JOBDLIB/&JOBD) JOBQ(&JOBQSTG) INLLIBL(*JOBD) +
                                                                  /* (740 M) */
               CHGVAR     VAR(&FINISHED) VALUE('1')               /* (650 A) */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')             /* (650 A) */
             ENDDO                                                /* (650 A) */

/*-----------------------------------------------------------------*/
/*        Submit Customer Order Updates for Processing             */
/*-----------------------------------------------------------------*/

             WHEN       COND(&PCMD = '*ROUTE' *OR &PCMD = '*WILL') +
                          THEN(DO)                                /* (650 M) */
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

/*           Create members for import files                      /* (760bM) */
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

/*        Process Staging Import Customer Orders Updates.            (650 A) */
             WHEN       COND(&PCMD = '*STGRTE') THEN(DO)          /* (650 A) */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPORD')           /* (650 A) */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPORDERR')     /* (650 A) */
               CHGVAR     VAR(&JOBNAME) VALUE('IMPORD' *cat &whse) /*(650 A) */

               SBMJOB     CMD(CALL PGM(OI285S) PARM(&WHSE &BATID +
                            &RETURNS &PMESSAGE)) JOB(&JOBNAME) +
                            JOBD(&JOBDLIB/&JOBD) JOBQ(&JOBQSTG) INLLIBL(*JOBD) +
                                                                  /* (740 M) */
               CHGVAR     VAR(&FINISHED) VALUE('1')               /* (650 A) */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')             /* (650 A) */
             ENDDO                                                /* (650 A) */
/*           ENDSELECT                                               (650aD) */

/*----------------------------------------------------------------*/ /* 640aA */
/*        Submit V5 Customer Order Updates for Processing         */ /* 640aA */
/*----------------------------------------------------------------*/ /* 640aA */

             WHEN       COND(&PCMD = '*ROUTE5' *OR &PCMD = '*WILL5') +
                          THEN(DO)                                /* (650 M) */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPORD')              /* 640aA */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPORDERR')        /* 640aA */

/*           Create member name */                                   /* 640aA */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)                 /* 640aA */
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)               /* 640aA */
               IF         COND(&PCMD = '*WILL') THEN(DO)             /* 640aA */
                 CHGVAR     VAR(&MBR) VALUE('W' *CAT %SST(&WHSE 2 2) +
                              *CAT &NXTNUMA)                         /* 640aA */
               ENDDO                                                 /* 640aA */
               ELSE       CMD(DO)                                    /* 640aA */
                 CHGVAR     VAR(&MBR) VALUE('R' *CAT %SST(&WHSE 2 2) +
                              *CAT &NXTNUMA)                         /* 640aA */
               ENDDO                                                 /* 640aA */

               CHGVAR     VAR(&IMPMBR)     VALUE(&MBR)               /* 640aA */

/*           Create members for import files                         /* 760bM */
               IF         COND(&PATH1 > ' ') THEN(DO)                /* 640aA */
                 ADDPFM     FILE(IMPFORDH5) MBR(&MBR)                /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)          /* 640aA */
                   CLRPFM     FILE(IMPFORDH5) MBR(&MBR)              /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)        /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')         /* 640aA */
                     GOTO       CMDLBL(GETOUT)                       /* 640aA */
                   ENDDO                                             /* 640aA */
                 ENDDO                                               /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH1) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                       /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')           /* 640aA */
                   GOTO       CMDLBL(GETOUT)                         /* 640aA */
                 ENDDO                                               /* 640aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                   /* 640aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDH5) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)        /* 640aA */
               ENDDO                                                 /* 640aA */
               ENDDO                                                 /* 640aA */

               IF         COND(&PATH2 > ' ') THEN(DO)                /* 640aA */
                 ADDPFM     FILE(IMPFORDD5) MBR(&MBR)                /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)          /* 640aA */
                   CLRPFM     FILE(IMPFORDD5) MBR(&MBR)              /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)        /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')         /* 640aA */
                     GOTO       CMDLBL(GETOUT)                       /* 640aA */
                   ENDDO                                             /* 640aA */
                 ENDDO                                               /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH2) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                       /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')           /* 640aA */
                   GOTO       CMDLBL(GETOUT)                         /* 640aA */
                 ENDDO                                               /* 640aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                   /* 640aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDD5) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)        /* 640aA */
               ENDDO                                                 /* 640aA */
               ENDDO                                                 /* 640aA */

               IF         COND(&PATH3 > ' ') THEN(DO)                /* 640aA */
                 ADDPFM     FILE(IMPFORDHM) MBR(&MBR)                /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)          /* 640aA */
                   CLRPFM     FILE(IMPFORDHM) MBR(&MBR)              /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)        /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')         /* 640aA */
                     GOTO       CMDLBL(GETOUT)                       /* 640aA */
                   ENDDO                                             /* 640aA */
                 ENDDO                                               /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH3) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                       /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')           /* 640aA */
                   GOTO       CMDLBL(GETOUT)                         /* 640aA */
                 ENDDO                                               /* 640aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDHM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)        /* 640aA */
               ENDDO                                                 /* 640aA */
               ENDDO                                                 /* 640aA */

               IF         COND(&PATH4 > ' ') THEN(DO)                /* 640aA */
                 ADDPFM     FILE(IMPFORDDM) MBR(&MBR)                /* 640aA */
                 MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)          /* 640aA */
                   CLRPFM     FILE(IMPFORDDM) MBR(&MBR)              /* 640aA */
                   MONMSG     MSGID(CPF3204 CPF7306) EXEC(DO)        /* 640aA */
                     CHGVAR     VAR(&RETURN) VALUE('*ERROR')         /* 640aA */
                     GOTO       CMDLBL(GETOUT)                       /* 640aA */
                   ENDDO                                             /* 640aA */
                 ENDDO                                               /* 640aA */

                 CPYFRMSTMF FROMSTMF(&PATH4) TOMBR(&TOFILE) +
                              MBROPT(*REPLACE)                       /* 640aA */
                 MONMSG     MSGID(CPFA085 CPFA095) CMPDTA(*NONE) EXEC(DO)
                   CHGVAR     VAR(&RETURN) VALUE('*ERROR')           /* 640aA */
                   GOTO       CMDLBL(GETOUT)                         /* 640aA */
                 ENDDO                                               /* 640aA */
               RTVMBRD    FILE(QTEMP/IMPFFLAT) MBR(IMPFFLAT) NBRCURRCD(&RECS)
               IF         COND(&RECS > 0) THEN(DO)                   /* 640aA */
                 CPYF       FROMFILE(QTEMP/IMPFFLAT) TOFILE(IMPFORDDM) +
                              FROMMBR(IMPFFLAT) TOMBR(&MBR) +
                              MBROPT(*REPLACE) FMTOPT(*NOCHK)        /* 640aA */
               ENDDO                                                 /* 640aA */
               ENDDO                                                 /* 640aA */

               SBMJOB     CMD(CALL PGM(PIRFTPIMP) PARM('*ROUTE5' +
                            &IMPMBR &IMPMODE &IMPOUTQ &IMPFORMTYP)) +
                            JOB(PIRFTPIMP) JOBD(&JOBDLIB/&JOBD)      /* 740 M */

               CHGVAR     VAR(&FINISHED) VALUE('1')                  /* 640aA */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')                /* 640aA */
             ENDDO                                                   /* 640aA */

/*-----------------------------------------------------------------*/
/*        Check for Order Qty for Priority Replenishments.         */
/*-----------------------------------------------------------------*/


/*        Process Staging Import Customer Orders Updates.            (650aA) */
             WHEN       COND(&PCMD = '*STGQTYO') THEN(DO)         /* (650aA) */
               CHGVAR     VAR(&IMPMSGQ) VALUE('IMPQTY')           /* (650aA) */
               CHGVAR     VAR(&IMPERRMSGQ) VALUE('IMPQTYERR')     /* (650aA) */
               CHGVAR     VAR(&JOBNAME) VALUE('IMPQTYO' *cat &whse) /*(650aA)*/

               SBMJOB     CMD(CALL PGM(II255S) PARM(&WHSE &BATID +
                            &RETURNS &PMESSAGE)) JOB(&JOBNAME) +
                            JOBD(&JOBDLIB/&JOBD) JOBQ(&JOBQSTG) INLLIBL(*JOBD) +
                                                                  /* (740 M) */
               CHGVAR     VAR(&FINISHED) VALUE('1')               /* (650aA) */
               CHGVAR     VAR(&RETURN)   VALUE('*OK')             /* (650aA) */
             ENDDO                                                /* (650aA) */

             ENDSELECT                                            /* (650aA) */

/*----------------------------------------------------------------*/
/*        Nothing done.                                           */ /* 640aA */
/*----------------------------------------------------------------*/

             GOTO       CMDLBL(NOMSG)                                /* 640aA */

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

 GETOUT:

             IF COND(&FINISHED = '0') THEN(DO)

             IF         COND(&IMPMSGQ = ' ') THEN(CHGVAR +
                          VAR(&IMPMSGQ) VALUE('QSYSOPR'))            /* 640aA */
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&IMPMSGQ) MSGTYPE(*INFO)

             IF         COND(&IMPERRMSGQ = ' ') THEN(CHGVAR +
                          VAR(&IMPMSGQ) VALUE('QSYSOPR'))            /* 640aA */
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&IMPERRMSGQ) MSGTYPE(*INFO)         /* 760bM */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          MSGTYPE(*INFO) KEYVAR(&MSGKEY)            /* 760bM */
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
               CHGVAR     VAR(&FINISHED) VALUE('1')                  /* 640aA */
             ENDDO

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

               RCLRSC     LVL(*CALLER)

             ENDPGM
