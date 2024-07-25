/*-------------------------------------------------------------------*/
/*  RU372CL   Route Loading Analysis View/Print Report.              */
/*  April 9, 2008                                                    */
/*  Jose Duque   (Copy of RU370CL)                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    01/15/09  RBD  5.20                                            */
/*     - Added call to GETWHSE to retrieve user whse.                */
/*     - Removed hardcoding of start and end times, will use         */
/*       new pgm GETLOARNG instead to retrieve *LOADER options.      */
/*     - Added sort options.                                         */
/*                                                                   */
/*    01/02/13  MLB  6.40a                                           */
/*      - Fix: Revised pgm to delete temporary work files from       */
/*        library qtemp.                                             */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RU372CL:    PGM        PARM(&WHSE &SDATE &PDATE &SDTE6 &PDTE6 +
                             &RETURN &VP &JOBQ &DEV &FORM &SORT)  /*520 M*/

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RU372CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RU375)

  /* Report program and printer file names. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(RUNCPY)
             DCL        VAR(&PRTF2) TYPE(*CHAR) LEN(10) VALUE(RU376APR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Loading analysis report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing loading analysis report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLOSED)     TYPE(*CHAR) LEN(1) VALUE('C')
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FILNAM0)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FILNAM1)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FILNAM2)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FSEC)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME1)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RSEC)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&SDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME2)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
/*520 A*/    DCL        VAR(&WHSNUM)     TYPE(*DEC) LEN(3 0)
/*520 A*/    DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
/*520 A*/    DCL        VAR(&STIME)      TYPE(*DEC) LEN(6 0)
/*520 A*/    DCL        VAR(&ETIME)      TYPE(*DEC) LEN(6 0)
/*520 A*/    DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)

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

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &SDATE &PDATE &SDTE6 +
                            &PDTE6 &RETURN &VP &JOBQ &DEV &FORM &SORT) /*520 M*/

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
               &SORT)) JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

             MSGBFC     MESSAGE('Selecting records')


            /*  Temp files being created to be used as input- */
            /*  output files through this job.                */

             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)

             CHGVAR     VAR(&FILNAM0) VALUE('RN' || &TIME)
             CRTPF      FILE(QTEMP/&FILNAM0) +
                        SRCFILE(*LIBL/QDDSFILES) SRCMBR(RUNCPY) +
                        OPTION(*NOSOURCE *NOLIST) SIZE(*NOMAX)


             CHGVAR     VAR(&FILNAM1) VALUE('RU' || &TIME)
             CRTPF      FILE(QTEMP/&FILNAM1) +
                        SRCFILE(*LIBL/QDDSFILES) SRCMBR(RU376) +
                        OPTION(*NOSOURCE *NOLIST) SIZE(*NOMAX)


             CHGVAR     VAR(&FILNAM2) VALUE('RB' || &TIME)
             CRTPF      FILE(QTEMP/&FILNAM2) +
                        SRCFILE(*LIBL/QDDSFILES) SRCMBR(RU376A) +
                        OPTION(*NOSOURCE *NOLIST) SIZE(*NOMAX)

DOAGAIN:
           RCLRSC     LVL(*CALLER)
           RMVMSG     CLEAR(*ALL)

   /* Qry reads 'Runner' file, brakes down datestamp field into 2   +
      fields 'date' and 'time', writes record out. This new file is +
      a mirror image of 'Runner' file, and it is used by the OpnQry.*/

             RUNQRY     QRY(RUNNER) OUTFILE(QTEMP/&FILNAM0)


   /* Create selection criteria string. */

/** 520 D ** CHGVAR     VAR(&TIME1) VALUE('160000') ***/

/** 520 D ** CHGVAR     VAR(&TIME2) VALUE('063000') ***/

             CHGVAR     VAR(&QRYSLT) VALUE('RUWHSE *EQ ' *CAT &WHSE)

/*********   CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUSTAT *EQ' *BCAT &QUOTE *CAT &CLOSED +
                           *CAT &QUOTE)                       *******/

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTD *EQ' *BCAT &QUOTE *CAT &PDATE +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTT *GE' *BCAT &QUOTE *CAT &TIME1 +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUWHSE *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTD *EQ' *BCAT &QUOTE *CAT &SDATE +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTT *LE' *BCAT &QUOTE *CAT &TIME2 +
                           *CAT &QUOTE)


             OVRDBF     FILE(RU376) TOFILE(&FILNAM0) SHARE(*YES)


             OPNQRYF    FILE((&FILNAM0) (LABEL) (RTEHED) (PIRITEM) +
                        (PIRTRAN)) FORMAT(RU376) QRYSLT(&QRYSLT)   +
                        KEYFLD((&FILNAM0/RUWHDP) (RTEHED/RHRTE)    +
                        (&FILNAM0/RUCDTS *DESCEND))                +
                        JFLD((&FILNAM0/RULBL# LABEL/LBLBL#)        +
                        (LABEL/LBRTE RTEHED/RHRTID) (LABEL/LBITEM  +
                        PIRITEM/ITITEM) (&FILNAM0/RUOTRN           +
                        PIRTRAN/PTTRN#)) SEQONLY(*NO)              +
                        OPTIMIZE(*FIRSTIO)



            /*  Copy query output file into temp file  */
            /*  organized by dept and item             */

             CPYFRMQRYF FROMOPNID(&FILNAM0) TOFILE(QTEMP/&FILNAM1) +
                        MBROPT(*REPLACE) CRTFILE(*NO) FMTOPT(*NOCHK)



             OVRDBF     FILE(RU376) TOFILE(QTEMP/&FILNAM1)


            /*  Calc diff between start & end times of an  */
            /*  item flag process.                         */

             CALL       PGM(RU376B) PARM(&PDATE &SDATE &FSEC &RSEC)

            /*  Copy updated query output file into */
            /*  temp file organized by route#       */

             CPYF       FROMFILE(QTEMP/&FILNAM1) +
                        TOFILE(QTEMP/&FILNAM2) MBROPT(*REPLACE) +
                        CRTFILE(*NO) FMTOPT(*NOCHK)

             OVRDBF     FILE(RU376A) TOFILE(QTEMP/&FILNAM2)

             IF         (&VP = 'P') THEN(DO)
                        GOTO PRTRTE
             ENDDO

 VIEW:
             CHGVAR     VAR(&RETURN) VALUE(' ')

/*520 A         View by export time   */
             IF         (&SORT = '1') THEN(DO)
             CALL       PGM(RU378) PARM(&WHSE &PDATE &SDATE &RETURN)
             ENDDO

/*520 A         View by route         */
             IF         (&SORT = '2') THEN(DO)
             CALL       PGM(RU379) PARM(&WHSE &PDATE &SDATE &RETURN)
             ENDDO

             IF         (&RETURN = '*REFRESH') THEN(DO)
                        GOTO CMDLBL(DOAGAIN)
             ENDDO

             IF         (&RETURN = '*F21') GOTO CMDLBL(PRTRTE)

             GOTO       CMDLBL(NOMSG)


/* Set printer device to use and print report by route. */

PRTRTE:      RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             OVRPRTF    FILE(&PRTF2) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)

/*520 A        Print by export time   */
             IF         (&SORT = '1') THEN(DO)
             CALL       PGM(RU376A) PARM(&SDTE6 &PDTE6 &FSEC &RSEC)
             ENDDO

/*520 A        Print by route         */
             IF         (&SORT = '2') THEN(DO)
             CALL       PGM(RU376AA) PARM(&SDTE6 &PDTE6 &FSEC &RSEC)
             ENDDO

             GOTO       CMDLBL(NOMSG)


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
             IF         COND(&FILNAM0 > ' ') THEN(DO)             /* (640aA) */
               DLTF       FILE(QTEMP/&FILNAM0)                    /* (640aA) */
               MONMSG     MSGID(CPF2105)                          /* (640aA) */
             ENDDO                                                /* (640aA) */
             IF         COND(&FILNAM1 > ' ') THEN(DO)             /* (640aA) */
               DLTF       FILE(QTEMP/&FILNAM1)                    /* (640aA) */
               MONMSG     MSGID(CPF2105)                          /* (640aA) */
             ENDDO                                                /* (640aA) */
             IF         COND(&FILNAM2 > ' ') THEN(DO)             /* (640aA) */
               DLTF       FILE(QTEMP/&FILNAM2)                    /* (640aA) */
               MONMSG     MSGID(CPF2105)                          /* (640aA) */
             ENDDO                                                /* (640aA) */

             ENDPGM
