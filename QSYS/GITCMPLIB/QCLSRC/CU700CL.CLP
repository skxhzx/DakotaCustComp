/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CU700CL   Call all cleanup programs                              */
/*  05 October 2000                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    10/05/00  DAS  4.14                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    04/21/03  MLB  4.17                                            */
/*      - Fix: Moved Route cleanup before Misc. cleanup.             */
/*    07/21/04  RH   4.17b                                           */
/*      - ENH: Add Daily slot hit cleanup                            */
/*    10/26/09  GJA  6.00a                                           */
/*      - ENH: Add PASSTRAN, PHRASELOG, LABELDO cleanup              */
/*    03/16/11  RBD  6.40a                                           */
/*      - ENH: Added Trax directory and file cleanup                 */
/*    01/06/12  MLB  6.40b                                           */
/*      - Enh: Added call to cleanup mbrs from file WORKOPT          */
/*        via pgm, CU701CL.                                          */
/*    01/06/12  MLB  6.40c                                           */
/*      - Enh: Added client custom code support to program.          */
/*    01/18/12  LMC  6.40d                                           */
/*      - Enh: Added call to history cleanup program.                */
/*      - Enh: Added call to LICLOG cleanup program.                 */
/*      - Enh: Added call to MS700CL Misc cleanup for                */
/*        RTEUNDO, CWEXCP,VSLEXCP,ITMEXCP                            */
/*    05/09/12  LMC  6.40E                                           */
/*      - Fix: Add code to Initialize &date prior to PH750CL         */
/*    05/12/12  LMC  6.40F                                           */
/*      - Fix: MONMSG ON 6.40a needs to goto next step in cleanup    */
/*    08/10/12  LMC  6.40g                                           */
/*      - ENH: Added POASN directory and file cleanup                */
/*    04/10/13  LMC  6.50A                                           */
/*      - ENH: Added Repack Work Order file cleanup                  */
/*    05/28/13  LMC  CWDa                                            */
/*      - ENH: Added call to CU701CL for file TOTEEXP                */
/*    07/07/15  NLK  7.00aA                                          */
/*      - ENH: Added call to IFSTOMCLN to cleanup TOMCAT IFS logs    */
/*    03/31/16  RTR  7.00b                                           */
/*      - Enh: Added Interface Member cleanup.                       */
/*    05/16/19  KDE  7.30a                                           */
/*      - ENH: Added call to IFSDIRPUR and remove IFSTRAXLCN         */
/*             and IFSTOMCLN                                         */
/*    12/02/19  MLB  7.30b                                           */
/*      - Enh: Revised pgm to disable 6.40b mod cleanup of file      */
/*             WORKOPT. Was causing conflicts with clients active    */
/*             on weekends when job was scheduled.                   */
/*    10/22/20  LMC  7.40a                                           */
/*      - Enh: Added uciinfo cleanup                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Glazier Foods                           */
/*                                                                   */
/*    01/06/12  MLB  GFC                                             */
/*      - Revised program to call CU701CL for the following          */
/*        files to remove mbrs older than 7 days.                    */
/*      - EXPFPOH, EXPFPOD, EXPFPOE.                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Agar Supply                             */
/*                                                                   */
/*    10/02/12  RTR  ASC                                             */
/*      - Clear all LUCASEXPF members                                */
/*      - Clear all IFS files from /TBImport_backup                  */
/*      - Clear all IFS files from /TBImport_Test_backup             */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Kohl Wholesale                          */
/*                                                                   */
/*    09/02/16  MLB  KHL                                             */
/*      - Revised program to call CU701CL for the following          */
/*        files to remove mbrs older than 7 days.                    */
/*      - IMPFPCKQ.                                                  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Reinhart Foodservice                    */
/*                                                                   */
/*    04/02/13  RTR  RFSa                                            */
/*      - Clear all IFS files from path returned by UT882            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Presto Foods                            */
/*                                                                   */
/*    03/31/16  RTR  PFCa                                            */
/*      - Added member cleanup for IMPFPCKQ, IMPFCTARG, IMPFFLAT1.   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Fischer Foods                           */
/*                                                                   */
/*    10/19/16  RTR  FFCa                                            */
/*      - Delete extra virtual devices to prevent max virtual error. */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Holt Paper Co.                          */
/*                                                                   */
/*    07/03/20  MLB  HPC                                             */
/*      - Revised program to call CU701CL for the following          */
/*        files to remove mbrs older than 14 days.                   */
/*      - IMPFPCKQ.                                                  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CU700CL:    PGM        PARM(&CMD &WHSE &DATEIN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (640cA) */

             DCL        VAR(&GLAZIER) TYPE(*CHAR) LEN(10) +
                          VALUE('GLAZIER')                        /* (GFC A) */
             DCL        VAR(&AGAR) TYPE(*CHAR) LEN(10) +
                          VALUE('AGAR')                           /* (ASC A) */
             DCL        VAR(&RFS) TYPE(*CHAR) LEN(10) +
                          VALUE('RFS')                            /* (RFS A) */
             DCL        VAR(&CASHWA) TYPE(*CHAR) LEN(10) +
                          VALUE('CASHWA') /* (CWD A) */
             DCL        VAR(&KOHL) TYPE(*CHAR) LEN(10) +
                          VALUE('KOHL')                           /* (KHL A) */
             DCL        VAR(&PRESTO) TYPE(*CHAR) LEN(10) +
                          VALUE('PRESTOFOOD')                     /* (PFCaA) */
             DCL        VAR(&FISCHER) TYPE(*CHAR) LEN(10) +
                          VALUE('FISCHER')                        /* FFCa */
             DCL        VAR(&HOLTPAPER) TYPE(*CHAR) LEN(10) +
                          VALUE('HOLTPAPER ')                     /* (HPC A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (640cA) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (640cA) */
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATE)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATEIN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&DELPATH1)   TYPE(*CHAR) LEN(100)     /* (RFSaA) */
             DCL        VAR(&MSG)        TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TOMCAT)     TYPE(*CHAR) LEN(10)      /* (700aA) */
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (640cA) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (640cA) */


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information. */

             RTVJOBA    USER(&USER) TYPE(&TYPE)


/*  Remove exported item adjustments */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN)

             CHGVAR     VAR(&MSG) VALUE('** Begin Adjustments: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(IT750CL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End Adjustments: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove exported customer returns */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN)

             CHGVAR     VAR(&MSG) VALUE('** Begin Returns: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(OR760CL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End Returns: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove exported PO's */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN)

             CHGVAR     VAR(&MSG) VALUE('** Begin PO: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(PO750CL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End PO: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove route records */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN)

             CHGVAR     VAR(&MSG) VALUE('** Begin Route: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(RT750CL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End Route: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)


/*  Remove misc labels & transactions */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN)

             CHGVAR     VAR(&MSG) VALUE('** Begin Misc: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(PT780CL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End Misc: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove Daily slot hit records  4.17b */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN)

             CHGVAR     VAR(&MSG) VALUE('** Begin Daily Slot hits: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(HT750CL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End Daily Slot hits: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove PASSTRAN records  6.00a */

             DSPOBJD    OBJ(PASSTRAN) OBJTYPE(*FILE)
             MONMSG     MSGID(CPF2105) EXEC(GOTO CMDLBL(LA755))
             CHGVAR     VAR(&MSG) VALUE('** Begin PASSTRAN cleanup: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(PA750CL) PARM(&CMD &WHSE)

             CHGVAR     VAR(&MSG) VALUE('End PASSTRAN cleanup: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove LABELDO records  6.00a */
LA755:
             DSPOBJD    OBJ(LABELDO) OBJTYPE(*FILE)
             MONMSG     MSGID(CPF2105) EXEC(GOTO CMDLBL(PH755))
             CHGVAR     VAR(&MSG) VALUE('** Begin LABELDO cleanup: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(LA750CL) PARM(&CMD &WHSE)

             CHGVAR     VAR(&MSG) VALUE('End LABELDO cleanup: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove PHRASELOG records  6.00a */
PH755:
             CHGVAR     VAR(&DATE) VALUE('0') /* 6.40eA */
             DSPOBJD    OBJ(PHRASELOG) OBJTYPE(*FILE)
/* 6.40aD    MONMSG     MSGID(CPF2105) EXEC(GOTO CMDLBL(GETOUT))     ****/
/* 6.40aM */ MONMSG     MSGID(CPF2105) EXEC(GOTO CMDLBL(IFSTR))
             CHGVAR     VAR(&MSG) VALUE('** Begin PHRASELOG cleanup: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(PH750CL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End PHRASELOG cleanup: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove Trax directory objects and TTLOG records  6.40a */
IFSTR:
             DSPOBJD    OBJ(TTLOG) OBJTYPE(*FILE)
/* 6.40f     MONMSG     MSGID(CPF2105) EXEC(GOTO CMDLBL(GETOUT))   */
/* 7.30a     MONMSG     MSGID(CPF2105) EXEC(GOTO CMDLBL(MBRCLNSTR)) */
/* 7.30a */  GOTO       CMDLBL(MBRCLNSTR)
                          /* 6.40f */
             CHGVAR     VAR(&MSG) VALUE('** Begin Trax cleanup: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(IFSTRAXCLN) PARM(&WHSE)

             CHGVAR     VAR(&MSG) VALUE('End Trax cleanup: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove members from WORKOPT file.                             /* (640bA) */
MBRCLNSTR:
             CHGVAR     VAR(&MSG) VALUE('** Begin work file mbr +
                          cleanup: ' *CAT &CMD *BCAT '/' *CAT &WHSE +
                          *CAT '/' *CAT &DATE)                    /* (640bA) */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)                   /* (640bA) */

/*           CALL       PGM(CU701CL) PARM('WORKOPT')                 (730bD) */

             SELECT                                               /* (GFC A) */
             WHEN       COND(&CLIENT = &GLAZIER) THEN(DO)         /* (GFC A) */
               CALL       PGM(CU701CL) PARM('EXPFPOH')            /* (GFC A) */
               CALL       PGM(CU701CL) PARM('EXPFPOD')            /* (GFC A) */
               CALL       PGM(CU701CL) PARM('EXPFPOE')            /* (GFC A) */
             enddo                                                /* (GFC A) */
             WHEN       COND(&CLIENT = &CASHWA) THEN(DO)          /* (CWD A) */
               CALL       PGM(CU701CL) PARM('TOTEEXP')            /* (CWD A) */
             enddo                                                /* (CWD A) */
             WHEN       COND(&CLIENT = &KOHL +
                        *OR  &CLIENT = &HOLTPAPER) THEN(DO)       /* (HPC M) */
               CALL       PGM(CU701CL) PARM('IMPFPCKQ')           /* (KHL A) */
             enddo                                                /* (KHL A) */
             ENDSELECT                                            /* (GFC A) */

             CHGVAR     VAR(&MSG) VALUE('End work file cleanup: ' +
                          *CAT &CMD *BCAT '/' *CAT &WHSE *CAT '/' +
                          *CAT &DATE)                             /* (640bA) */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)                   /* (640bA) */
/*  Start LICLOG Cleanup                                          /* (640dA) */
Liclog:                                                           /* (640dA) */
             CHGVAR     VAR(&MSG) VALUE('** Begin LICLOG cleanup: ' +
                          *CAT &CMD *BCAT '/' *CAT &WHSE *CAT '/' +
                          *CAT &DATE) /* (640dA) */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE)) /* +
                          (640dA) */

             CALL       PGM(LL750CL) PARM(&CMD &WHSE &DATEIN) /* +
                          (640dA) */


             CHGVAR     VAR(&MSG) VALUE('End LICLOG cleanup: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE) /* (640dA) */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE)) /* +
                          (640dA) */

/*  Start UCIINFO Cleanup  */      /* 7.40a */


             CHGVAR     VAR(&MSG) VALUE('** Begin UCIINFO cleanup')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS780CL) PARM(&CMD &WHSE)

             CHGVAR     VAR(&MSG) VALUE('End UCIINFO cleanup')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove POASN directory objects 6.40g */
POASNIFSTR:
             DSPOBJD    OBJ(POASN) OBJTYPE(*FILE)
             MONMSG     MSGID(CPF2105) EXEC(GOTO CMDLBL(HISTORY)) +
                          /* 6.40G */
             CHGVAR     VAR(&MSG) VALUE('** Begin POASN cleanup:' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(IFSPOASNCL) PARM(&WHSE)

             CHGVAR     VAR(&MSG) VALUE('End POASN cleanup:' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)
/*  Start history cleanup                                         /* (640dA) */
History:                                                          /* (640dA) */
             CHGVAR     VAR(&MSG) VALUE('** Begin history cleanup: ' +
                          *CAT &CMD *BCAT '/' *CAT &WHSE *CAT '/' +
                          *CAT &DATE) /* (640dA) */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE)) /* +
                          (640dA) */

             CALL       PGM(CU700HCL) PARM(&CMD &WHSE &DATEIN) /* +
                          (640dA) */


             CHGVAR     VAR(&MSG) VALUE('End history cleanup: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE) /* (640dA) */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE)) /* +
                          (640dA) */

/*  Start Misc cleanup on RTEUNDO,CWEXCP,VSLEXCP,ITMEXCP          /* (640dA) */
Miscfiles:                                                        /* (640dA) */
             CHGVAR     VAR(&MSG) VALUE('** Begin Misc file cleanup: +
                          ' *CAT &CMD *BCAT '/' *CAT &WHSE *CAT '/' +
                          *CAT &DATE) /* (640dA) */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE)) /* +
                          (640dA) */

         /*  CALL       PGM(MS700CL) PARM(&CMD &WHSE &DATEIN)    +
                          (640dA)   REMOVED (ASCaA)    */
             CALL       PGM(MS700CL) PARM(&CMD)                   /* (ASCaA) */

             CHGVAR     VAR(&MSG) VALUE('End Misc file cleanup: ' +
                          *CAT &CMD *BCAT '/' *CAT &WHSE *CAT '/' +
                          *CAT &DATE) /* (640dA) */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE)) /* +
                          (640dA) */

/*  Start Custom Interface File Cleanups                          /* (ASCaA) */
Interfaces:                                                       /* (ASCaA) */
             CHGVAR     VAR(&MSG) VALUE('** Begin Interface cleanup: +
                          ' *CAT &CMD *BCAT '/' *CAT &WHSE *CAT '/' +
                          *CAT &DATE)                             /* (ASCaA) */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE))   /* (ASCaA) */

             SELECT                                               /* (ASC A) */
             WHEN       COND(&CLIENT = &RFS) THEN(DO)             /* (RFSaA) */
             CALL       PGM(UT882) PARM(&WHSE &DELPATH1)          /* (RFSaA) */
               DEL      OBJLNK(&DELPATH1)                         /* (RFSaA) */
             ENDDO                                                /* (RFSaA) */
             WHEN       COND(&CLIENT = &AGAR) THEN(DO)            /* (ASC A) */
               RMVM FILE(LUCASEXPF) MBR(*ALL)                     /* (ASC A) */
               DEL OBJLNK('/TBImport_backup/*')                   /* (ASC A) */
               DEL OBJLNK('/TBImport_Test_backup/*')              /* (ASC A) */
             ENDDO                                                /* (ASC A) */
             ENDSELECT                                            /* (ASC A) */

             /*  Remove Order Interface Members > 15 days */      /* (700bA) */
             CALL       PGM(UT770CL) PARM('IMPFORDH4' '015')      /* (700bA) */
             CALL       PGM(UT770CL) PARM('IMPFORDD4' '015')      /* (700bA) */
             CALL       PGM(UT770CL) PARM('IMPFORDH5' '015')      /* (700bA) */
             CALL       PGM(UT770CL) PARM('IMPFORDD5' '015')      /* (700bA) */
             CALL       PGM(UT770CL) PARM('IMPFORDHM' '015')      /* (700bA) */
             CALL       PGM(UT770CL) PARM('IMPFORDDM' '015')      /* (700bA) */
             CALL       PGM(UT770CL) PARM('IMPFORSF' '015')       /* (700bA) */
             CALL       PGM(UT770CL) PARM('EXPFORDASN' '015')     /* (700bA) */
             CALL       PGM(UT770CL) PARM('EXPFORDB' '015')       /* (700bA) */
             CALL       PGM(UT770CL) PARM('EXPFORDC' '015')       /* (700bA) */
             CALL       PGM(UT770CL) PARM('EXPFORDD' '015')       /* (700bA) */
             CALL       PGM(UT770CL) PARM('EXPFORDE' '015')       /* (700bA) */
             CALL       PGM(UT770CL) PARM('EXPFORDH' '015')       /* (700bA) */
             CALL       PGM(UT770CL) PARM('EXPFORDL' '015')       /* (700bA) */
             CALL       PGM(UT770CL) PARM('EXPFORDO' '015')       /* (700bA) */
             CALL       PGM(UT770CL) PARM('EXPFORDP' '015')       /* (700bA) */
             CALL       PGM(UT770CL) PARM('EXPFORDT' '015')       /* (700bA) */

             /*  Remove Other Interface Members > 30 days */      /* (PFCaA) */
             IF         COND(&CLIENT = &PRESTO) THEN(DO)          /* (PFCaA) */
               CALL     PGM(UT770CL) PARM('IMPFPCKQ' '030')       /* (PFCaA) */
               CALL     PGM(UT770CL) PARM('IMPFCTARG' '030')      /* (PFCaA) */
               CALL     PGM(UT770CL) PARM('IMPFFLAT1' '030')      /* (PFCaA) */
             ENDDO                                                /* (PFCaA) */

             CHGVAR     VAR(&MSG) VALUE('End Interface cleanup: ' +
                          *CAT &CMD *BCAT '/' *CAT &WHSE *CAT '/' +
                          *CAT &DATE)                             /* (ASCaA) */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE))   /* (ASCaA) */

/*  Remove Closed Repack work orders */    /* 650a */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN) /* 650a */

             CHGVAR     VAR(&MSG) VALUE('** Begin WR: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE) +
                          /* 650a */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE)) /* +
                          650a */

             CALL       PGM(WR750CL) PARM(&CMD &WHSE &DATE) /* 650a */

             CHGVAR     VAR(&MSG) VALUE('End WR: ' *CAT &CMD *BCAT +
                          '/' *CAT &WHSE *CAT '/' *CAT &DATE) /* +
                          650a */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE)) /* +
                          650a */

/* 7.30a  -  Cleanup IFS Directories per directory entries from M29100  */

/* 7.30aA */  CALL       PGM(IFSDIRPUR) PARM(&WHSE)

/*  Remove IFS TOMCAT logs           */                 /* 700aA */
/*  *blanks scan TOMCAT6036* for all clients */         /* 700aA */
/* 7.30aD  Replace with IFSDIRPUR call above             */

/* 7.30aD    CHGVAR     VAR(&TOMCAT) VALUE('       ')   */

/* 7.30aD    CALL       PGM(IFSTOMCLN) PARM(&TOMCAT)    */

/*  Remove extra virtual devices  */                              /* FFCa */

             SELECT                                               /* FFCa */
             WHEN       COND(&CLIENT = &FISCHER) THEN(DO)         /* FFCa */
              DLTDEVD    DEVD(QPADEV*)                            /* FFCa */
              MONMSG     MSGID(CPF2616)                           /* FFCa */
             ENDDO                                                /* FFCa */
             ENDSELECT                                            /* FFCa */

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             IF         COND(&TYPE = '0') THEN(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) TOUSR(&USER) MSGTYPE(*COMP)
                ENDDO
             ELSE       CMD(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) MSGTYPE(*COMP)
                ENDDO
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
