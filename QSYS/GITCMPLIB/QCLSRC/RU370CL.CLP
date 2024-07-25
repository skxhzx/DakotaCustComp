/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RU370CL   Cleared flags report                                   */
/*  15 July 2004                                                     */
/*                                                                   */
/*  Jose Duque                                                       */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/20/05  MLB  5.00                                            */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*    05/20/09  RBD  5.20                                            */
/*     - Added call to GETWHSE to retrieve user whse.                */
/*     - Removed hardcoding of start and end times, will use         */
/*       new pgm GETLOARNG instead to retrieve *LOADER options.      */
/*                                                                   */
/*    07/17/12  RBD  6.40a                                           */
/*     - Fix: Sometimes the pgm runs so fast that the time hasn't    */
/*       changed between creation of FILNAM0 and FILNAM1, whose      */
/*       names consist of RU plus the time ... when this happens     */
/*       they end up with the same name and the program crashes.     */
/*       To correct, I changed the RU prefix on FILNAM1 to RA.       */
/*    01/02/13  MLB  6.40b                                           */
/*      - Fix: Revised pgm to delete temporary work files from       */
/*        library qtemp.                                             */
/*      - Fix: Revised pgm to change prefix for &FILNAM1 to RA       */
/*        from RU to prevent duplicate file names from being created.*/
/*      - Fix: Revised RUNQRY cmd to specify file name and *LIBL     */
/*        on RUNQRY cmd so that it would find file instead of using  */
/*        file/library specified in qry definition.                  */
/*    03/30/16  GJA  7.00a                                           */
/*      - Enh: Added option to include deleted flags                 */
/*    06/14/16  GJA  7.00b                                           */
/*      - ENH: Add F5 for refresh on view                            */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions: Cheney                                  */
/*                                                                   */
/*    08/06/04  CBIa-JGD                                             */
/*      OpnQry definition was changed to add more join               */
/*      fields: 'Rutrn#' and 'Pttrn#'                                */
/*                                                                   */
/*    10/09/04  CBIb-JGD                                             */
/*      Another step was added to report cleared flags by Route#     */
/*      the first one is by Dept and Item.                           */
/*                                                                   */
/*    03/29/05  CBIc-JGD                                             */
/*      Overhauled second half of program.                           */
/*                                                                   */
/*    11/10/05  CBId-JGD                                             */
/*      Change 'PTIME' value from 05:01:00 to 16:00:00               */
/*                                                                   */
/*    08/28/07  CBIe-JGD                                             */
/*      Another step was added to report Loader cleared              */
/*      flags only.                                                  */
/*                                                                   */
/*    09/06/07  CBIf-JGD                                             */
/*      Deleted exclusion of deleted flags from query selection.     */
/*      Flag deleted info would show on report created under         */
/*      print option 3 (Loader Flags) only. Also, changed 'RUTRN#'   */
/*      to 'RUOTRN' in OpenQry file joining criteria, this mod       */
/*      would allow the inclusion of all flags records including     */
/*      those that did not have a 'Flag Tran' created thru flag      */
/*      label printing process.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: City Line                               */
/*                                                                   */
/*    05/20/05  MLB  CLD                                             */
/*      - Changed field default for &PTIME to 120100 and &STIME to   */
/*        120000 from 050100 and 050000. These values control the    */
/*        start and end cutoff times when selecting runner entries.  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RU370CL:    PGM        PARM(&WHSE &SDATE &PDATE &SDTE6 &PDTE6 +
                             &RETURN &VP &JOBQ &DEV &FORM &SORT &DLT)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's                                            (500 A)  */

             DCL        VAR(&CITYLINE) TYPE(*CHAR) LEN(10) +
                          VALUE('CITYLINE  ')             /* (CLD A) */


  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RU370CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RU370)

  /* Report program and printer file names. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(RUNCPY)
             DCL        VAR(&PRTF)  TYPE(*CHAR) LEN(10) VALUE(RU371PR)
             DCL        VAR(&PRTF2) TYPE(*CHAR) LEN(10) VALUE(RU371APR)
             DCL        VAR(&PRTF3) TYPE(*CHAR) LEN(10) VALUE(RU371CPR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Cleared flags report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing cleared flags report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10) /* (500 A) */
             DCL        VAR(&CLOSED)     TYPE(*CHAR) LEN(1) VALUE('C')
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FILNAM0)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FILNAM1)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FILNAM2)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PTIME)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&SDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
/*520 D ***  DCL        VAR(&STIME)      TYPE(*CHAR) LEN(6)      ***/
             DCL        VAR(&TIME)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
/*520 A*/    DCL        VAR(&WHSNUM)     TYPE(*DEC) LEN(3 0)
/*520 A*/    DCL        VAR(&STIME)      TYPE(*DEC) LEN(6 0)
/*520 A*/    DCL        VAR(&ETIME)      TYPE(*DEC) LEN(6 0)
/*520 A*/    DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
/*520 A*/    DCL        VAR(&TIME1)      TYPE(*CHAR) LEN(6)
/*520 A*/    DCL        VAR(&TIME2)      TYPE(*CHAR) LEN(6)
/*700a */    DCL        VAR(&DLT)        TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* 520 A   Get job information  */

             RTVJOBA    USER(&USER)

/* 520 A   Get user's warehouse information */

             CALL       PGM(GETWHSE) PARM(&USER &WHSNUM)
             CHGVAR     VAR(&WHSE)  VALUE(&WHSNUM)

/* 520 A   Get loader options, route loading start and end times */

             CALL       PGM(GETLOARNG) PARM(&WHSNUM &STIME &ETIME)
             CHGVAR     VAR(&TIME1)  VALUE(&STIME)
             CHGVAR     VAR(&TIME2)  VALUE(&ETIME)

             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)    /* (500 A) */
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &SDATE &PDATE &SDTE6 +
                        &PDTE6 &RETURN &VP &JOBQ &DEV &FORM &SORT &DLT)
/* 7.00a                    &PDTE6 &RETURN &VP &JOBQ &DEV &FORM &SORT)*/

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/* 520 A   Get loader options, route loading start and end times */
/* 520 A   using whse entered in options pgm.                    */

             CHGVAR     VAR(&WHSNUM)  VALUE(&WHSE)
             CALL       PGM(GETLOARNG) PARM(&WHSNUM &STIME &ETIME)
             CHGVAR     VAR(&TIME1)  VALUE(&STIME)
             CHGVAR     VAR(&TIME2)  VALUE(&ETIME)

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
               SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &SDATE +
               &PDATE &SDTE6 &PDTE6 &RETURN &VP &JOBQ &DEV &FORM  +
               &SORT &DLT)) JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

             MSGBFC     MESSAGE('Selecting records')


            /*  Temp file being created to be used as output */
            /*  file by query 'Runner' below.                */

             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)

             CHGVAR     VAR(&FILNAM0) VALUE('RU' || &TIME)

             CRTPF      FILE(QTEMP/&FILNAM0) +
                          SRCFILE(*LIBL/QDDSFILES) SRCMBR(RUNCPY) +
                          OPTION(*NOSOURCE *NOLIST) SIZE(*NOMAX)


   /* Qry reads 'Runner' file, brakes down datestamp field into 2   +
      fields 'date' and 'time', writes record out. This new file is +
      a mirror image of 'Runner' file, and it is used by the OpnQry.*/

/*           RUNQRY     QRY(RUNNER) OUTFILE(QTEMP/&FILNAM0)          (640bD) */
             RUNQRY     QRY(RUNNER) QRYFILE((*LIBL/RUNNER *FIRST)) +
                          OUTFILE(QTEMP/&FILNAM0)                 /* (640bM) */

   /* Create selection criteria string. */

/* 520 A This code is no longer necessary, now using *LOADER times.      */
/* 520 D *** If         Cond(&CLIENT = &CITYLINE) Then(DO)    /* (CLD A) */
/* 520 D ***   CHGVAR     VAR(&PTIME) VALUE('120100')         /* (CLD A) */
/* 520 D ***   CHGVAR     VAR(&STIME) VALUE('120000')         /* (CLD A) */
/* 520 D *** enddo                                               (CLD A) */
/* 520 D *** Else       Cmd(DO)                               /* (CLD A) */
/* 520 D *** CHGVAR     VAR(&PTIME) VALUE('160000')               CBIdM  */
/* 520 D *** CHGVAR     VAR(&STIME) VALUE('063000')               CBIcM  */
/* 520 D *** enddo                                            /* (CLD A) */

             CHGVAR     VAR(&QRYSLT) VALUE('RUWHSE *EQ ' *CAT &WHSE)

/* CBIfD     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')  */
/* CBIfD     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUSTAT *EQ' *BCAT &QUOTE *CAT &CLOSED +
                           *CAT &QUOTE)                           */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTD *EQ' *BCAT &QUOTE *CAT &PDATE +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTT *GE' *BCAT &QUOTE *CAT &TIME1 +
                           *CAT &QUOTE)                        /*520 M*/

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUWHSE *EQ ' *CAT &WHSE)

/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')  */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUSTAT *EQ' *BCAT &QUOTE *CAT &CLOSED +
                           *CAT &QUOTE)                           */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTD *EQ' *BCAT &QUOTE *CAT &SDATE +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTT *LE' *BCAT &QUOTE *CAT &TIME2 +
                           *CAT &QUOTE)                        /* 520 M*/


             OVRDBF     FILE(RU371) TOFILE(&FILNAM0) SHARE(*YES)

/* CBIaD     OPNQRYF    FILE((&FILE) (LABEL) (RTEHED) +              */
/*                        (PIRITEM)) FORMAT(RU371) QRYSLT(&QRYSLT) + */
/*                        KEYFLD((&FILE/RUWHDP) (PIRITEM/ITITEM)) +  */
/*                        JFLD((&FILE/RULBL# LABEL/LBLBL#) +         */
/*                        (LABEL/LBRTE RTEHED/RHRTID) (LABEL/LBITEM +*/
/*                        PIRITEM/ITITEM)) OPTIMIZE(*FIRSTIO)       +*/
/*                        SEQONLY(*NO)                               */


/* CBIaA */  OPNQRYF    FILE((&FILNAM0) (LABEL) (RTEHED)   +
                          (PIRITEM) (PIRTRAN))          +
                          FORMAT(RU371) QRYSLT(&QRYSLT) +
                          KEYFLD((&FILNAM0/RUWHDP) (PIRITEM/ITITEM)) +
                          JFLD((&FILNAM0/RULBL# LABEL/LBLBL#) +
                          (LABEL/LBRTE RTEHED/RHRTID) (LABEL/LBITEM +
                          PIRITEM/ITITEM) (&FILNAM0/RUOTRN +
                          PIRTRAN/PTTRN#)) SEQONLY(*NO) +
                          OPTIMIZE(*FIRSTIO)


      /*-----*  Modification 'CBIc' starts here  *-----*/

            /*  Temp file being created  */

             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)

/* 640aD     CHGVAR     VAR(&FILNAM1) VALUE('RU' || &TIME)           */
/* 640aM */  CHGVAR     VAR(&FILNAM1) VALUE('RA' || &TIME)

             CRTPF      FILE(QTEMP/&FILNAM1) +
                        SRCFILE(*LIBL/QDDSFILES) SRCMBR(RU371) +
                        OPTION(*NOSOURCE *NOLIST) SIZE(*NOMAX)

            /*  Copy query output file into temp file  */
            /*  organized by dept and item             */

             CPYFRMQRYF FROMOPNID(&FILNAM0) TOFILE(QTEMP/&FILNAM1) +
                        MBROPT(*ADD) CRTFILE(*NO) FMTOPT(*NOCHK)


            /*  Another temp file being created  */

             CHGVAR     VAR(&FILNAM2) VALUE('RB' || &TIME)

             CRTPF      FILE(QTEMP/&FILNAM2) +
                        SRCFILE(*LIBL/QDDSFILES) SRCMBR(RU371A) +
                        OPTION(*NOSOURCE *NOLIST) SIZE(*NOMAX)


             OVRDBF     FILE(RU371) TOFILE(QTEMP/&FILNAM1)
             OVRDBF     FILE(RU371A) TOFILE(QTEMP/&FILNAM2)


            /*  Calc diff between start & end times of an  */
            /*  item flag process.                         */

             CALL       PGM(RU371B)

            /*  Copy updated query output file into */
            /*  temp file organized by route#       */

             CPYF       FROMFILE(QTEMP/&FILNAM1) +
                        TOFILE(QTEMP/&FILNAM2) MBROPT(*ADD) +
                        CRTFILE(*NO) FMTOPT(*NOCHK)



            /*  Print report by item or route */

             IF         (&VP = 'P') THEN(DO)
             IF         (&SORT = '1') THEN(GOTO PRTITM)  /* Item  */
             IF         (&SORT = '2') THEN(GOTO PRTRTE)  /* Route */
             ELSE       GOTO PRTLDR  /* Loader Flags*/   /* CBIe  */
             ENDDO

 VIEW:
 REPEAT:
             CALL       PGM(RU372) PARM(&WHSE &PDATE &SDATE &RETURN)
             IF         (&RETURN = '*F21') GOTO CMDLBL(PRTITM)
/*700b*/     IF         (&RETURN = '*F5') DO
             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)
             IF         COND(&FILNAM0 > ' ') THEN(DO)
               DLTF       FILE(QTEMP/&FILNAM0)
               MONMSG     MSGID(CPF2105)
             ENDDO
             IF         COND(&FILNAM1 > ' ') THEN(DO)
               DLTF       FILE(QTEMP/&FILNAM1)
               MONMSG     MSGID(CPF2105)
             ENDDO
             IF         COND(&FILNAM2 > ' ') THEN(DO)
               DLTF       FILE(QTEMP/&FILNAM2)
               MONMSG     MSGID(CPF2105)
             ENDDO
             GOTO REPORT
             ENDDO

             IF         (&RETURN = '*F9') DO

             CALL       PGM(RU373) PARM(&WHSE &PDATE &SDATE &RETURN)
             IF         (&RETURN = '*F9')  GOTO CMDLBL(REPEAT)
             IF         (&RETURN = '*F21') GOTO CMDLBL(PRTRTE)
             ENDDO

             GOTO       CMDLBL(NOMSG)


/* Set printer device to use and print report by item. */

PRTITM:      RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)

             CALL       PGM(RU371) PARM(&SDTE6 &PDTE6 &DLT)
             GOTO       CMDLBL(NOMSG)


/* Set printer device to use and print report by route. */

PRTRTE:      RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             OVRPRTF    FILE(&PRTF2) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)

             CALL       PGM(RU371A) PARM(&SDTE6 &PDTE6)
             GOTO       CMDLBL(NOMSG)


/* Set printer device to use and print report Loader Flags only */

PRTLDR:      RMVMSG     CLEAR(*ALL)                 /* CBIe */
             MSGBFC     MESSAGE(&WORKINGMSG)

             OVRPRTF    FILE(&PRTF3) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)

             CALL       PGM(RU371C) PARM(&SDTE6 &PDTE6)



      /*-----*  Modification 'CBIc' ends here  *-----*/



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
             IF         COND(&FILNAM0 > ' ') THEN(DO)             /* (640bA) */
               DLTF       FILE(QTEMP/&FILNAM0)                    /* (640bA) */
               MONMSG     MSGID(CPF2105)                          /* (640bA) */
             ENDDO                                                /* (640bA) */
             IF         COND(&FILNAM1 > ' ') THEN(DO)             /* (640bA) */
               DLTF       FILE(QTEMP/&FILNAM1)                    /* (640bA) */
               MONMSG     MSGID(CPF2105)                          /* (640bA) */
             ENDDO                                                /* (640bA) */
             IF         COND(&FILNAM2 > ' ') THEN(DO)             /* (640bA) */
               DLTF       FILE(QTEMP/&FILNAM2)                    /* (640bA) */
               MONMSG     MSGID(CPF2105)                          /* (640bA) */
             ENDDO                                                /* (640bA) */


             ENDPGM
