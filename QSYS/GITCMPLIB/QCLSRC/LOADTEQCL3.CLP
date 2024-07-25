/*-------------------------------------------------------------------*/
/*  LOADTEQCL3 Closed Trailer Equip Report.                          */
/*  (Report can be axecuted thru menus:                              */
/*  Pirrtn/Opt # 16 OR Pirloadr/Opt # 10->Pirldrpt/Opt # 12).        */
/*                                                                   */
/*  November 17, 2008                                                */
/*  Jose G. Duque                                                    */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/10/11  JGD  6.40                                            */
/*      - Created                                                    */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    MM/DD/YY  CBI-XXX                                              */
/*      Text.....................                                    */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADTEQCL3: PGM        PARM(&WHSE &FDATE &TDATE &FDTE6 &TDTE6     +
                             &RETURN &JOBQ &DEV &FORM &SORT &RTYP  +
                             &INV &INVT)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/*----------------------*/
/* Name of this program */
/*----------------------*/

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LOADTEQCL3)

/*-----------------*/
/* Option program. */
/*-----------------*/

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LOADR58)


             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(LDRTEQ)

/** Dtl Prtf's **/

/* Loader */ DCL        VAR(&PRTF)  TYPE(*CHAR) LEN(10) VALUE(LOAD60PR)
/* Driver */ DCL        VAR(&PRTF2) TYPE(*CHAR) LEN(10) VALUE(LOAD60BPR)
/* Equip  */ DCL        VAR(&PRTF9) TYPE(*CHAR) LEN(10) VALUE(LOAD60JPR)

/** Invoice Prtf's **/

/* Invoic */ DCL        VAR(&PRTF3) TYPE(*CHAR) LEN(10) VALUE(LOAD60CPR)
/* Invoic */ DCL        VAR(&PRTF4) TYPE(*CHAR) LEN(10) VALUE(LOAD60DPR)

/** Summary Prtf's **/

/* Loader */ DCL        VAR(&PRTF6) TYPE(*CHAR) LEN(10) VALUE(LOAD60FPR)
/* Driver */ DCL        VAR(&PRTF7) TYPE(*CHAR) LEN(10) VALUE(LOAD60GPR)
/* Equip  */ DCL        VAR(&PRTF8) TYPE(*CHAR) LEN(10) VALUE(LOAD60HPR)


/*------------------------*/
/* Informational messages */
/*------------------------*/

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                            VALUE('Closed Trailer Equipment Audit')

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                           VALUE('Printing Closed''Trailer Equipment Audit')

/*--------------------*/
/* Field declarations */
/*--------------------*/

             DCL        VAR(&CLOSED)     TYPE(*CHAR) LEN(1) VALUE('C')
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&FDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&FILNAM)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&INV)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&INVT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RTE#)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTYP)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME1)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME2)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-----------*/
/* Main line */
/*-----------*/

 OPTNS:

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)

/*---------------------*/
/* Get report options. */
/*---------------------*/

             CALL       PGM(&OPTPGM) PARM(&WHSE &FDATE &TDATE &FDTE6 +
                        &TDTE6 &RETURN &JOBQ &DEV &FORM &SORT &RTYP  +
                        &INV &INVT)


/*-------------------------------*/
/* See if user wants to proceed. */
/*-------------------------------*/

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO


/*------------------------------------------*/
/* See if user wants to put report on JOBQ. */
/*------------------------------------------*/

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &FDATE +
                        &TDATE &FDTE6 &TDTE6 &RETURN &JOBQ &DEV +
                        &FORM &SORT &RTYP &INV &INVT)) JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*-------------------------*/
/* Otherwise, run program. */
/*-------------------------*/

 REPORT:

             MSGBFC     MESSAGE('Selecting records')


/*-----------------------------------*/
/* Create selection criteria string. */
/*-----------------------------------*/

SELECT:
/*           CHGVAR     VAR(&QRYSLT) VALUE('LTWHSE *EQ ' *CAT &WHSE) */

/* To        IF         COND(&RTE# *NE *ALL)                    +    */
/* be used   THEN(DO)                                                */
/* if needed CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')     */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LTRTE+    */
/*                      *EQ ' *CAT &RTE#))                           */
/*           ENDDO                                                   */
/*-------------------------------------------------------------------*/
             CHGVAR     VAR(&QRYSLT) VALUE('LTWHSE *EQ ' *CAT &WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'LTLDTE *GE' *BCAT &QUOTE *CAT &FDATE +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'LTLDTE *LE' *BCAT &QUOTE *CAT &TDATE +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'LTSTAT *EQ' *BCAT &QUOTE *CAT &CLOSED +
                           *CAT &QUOTE)
/*-------------------------------------------------------------------*/


             OVRDBF     FILE(&FILE) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) QRYSLT(&QRYSLT) +
                        SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

             CALL       PGM(GETUNQMEM) PARM(*REUSE LDR26  &MEMBER)
             CALL       PGM(GETUNQMEM) PARM(*REUSE LDR26B &MEMBER)
             CALL       PGM(GETUNQMEM) PARM(*REUSE LDR26C &MEMBER)
             CALL       PGM(GETUNQMEM) PARM(*REUSE LDR27  &MEMBER)
             CALL       PGM(GETUNQMEM) PARM(*REUSE LDR27B &MEMBER)
             CALL       PGM(GETUNQMEM) PARM(*REUSE LDR27C &MEMBER)


/*---------------------------------------------------------------------*/
/* Delete, from qry file above, recs that do not fall into shift hours */
/*---------------------------------------------------------------------*/

             OVRDBF     FILE(LDR26)   TOFILE(LDR26) MBR(&MEMBER)

/* Delete unwanted records from query file.                            */
/* Loads detail file LDR26 indexed by loader.                          */
             CALL       PGM(LOADR59) PARM(&FDATE &TDATE)

/* Loads detail file LDR26B indexed by driver.                         */
             CPYF       FROMFILE(LDR26) TOFILE(LDR26B) +
                        FROMMBR(&MEMBER) TOMBR(&MEMBER) MBROPT(*ADD)

/* Loads detail file LDR26C indexed by equipment.                      */
             OVRDBF     FILE(LDR26C) TOFILE(LDR26C) MBR(&MEMBER)
             CALL       PGM(LOADR60I) PARM(&FDTE6 &TDTE6)


/* Loads summary file LDR27 indexed by loader.                         */
             OVRDBF     FILE(LDR27) TOFILE(LDR27) MBR(&MEMBER)
             CALL       PGM(LOADR60E) PARM(&FDTE6 &TDTE6)


/* Loads summary file LDR27B indexed by driver.                        */
             CPYF       FROMFILE(LDR27) TOFILE(LDR27B) +
                        FROMMBR(&MEMBER) TOMBR(&MEMBER) MBROPT(*ADD)

/* Loads Summary file LDR27C indexed by equipment.                     */
             CPYF       FROMFILE(LDR27) TOFILE(LDR27C) +
                        FROMMBR(&MEMBER) TOMBR(&MEMBER) MBROPT(*ADD)


/*--------*/
/*Reports */
/*--------*/

/* Detail report by Loader */
             IF         COND(&SORT = '1' *OR &SORT = '4') THEN(DO)
             IF (&RTYP = 'D' *OR &RTYP = 'B') THEN(DO)
             OVRDBF     FILE(LDR26) TOFILE(LDR26) MBR(&MEMBER)
             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)
             CALL       PGM(LOADR60) PARM(&FDTE6 &TDTE6)
             ENDDO

/* Summary report by Loader */
             IF (&RTYP = 'S' *OR &RTYP = 'B') THEN(DO)
             OVRDBF     FILE(LDR27) TOFILE(LDR27) MBR(&MEMBER)
             OVRPRTF    FILE(&PRTF6) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)
             CALL       PGM(LOADR60F) PARM(&FDTE6 &TDTE6)
             ENDDO

             ENDDO
/*------------------------------------------------------------------------*/

/* Detail report by Driver */
             IF         COND(&SORT = '2' *OR &SORT = '4') THEN(DO)
             IF (&RTYP = 'D' *OR &RTYP = 'B') THEN(DO)
             OVRDBF     FILE(LDR26B) TOFILE(LDR26B) MBR(&MEMBER)
             OVRPRTF    FILE(&PRTF2) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)
             CALL       PGM(LOADR60B) PARM(&FDTE6 &TDTE6)
             ENDDO

/* Summary report by Driver */
             IF (&RTYP = 'S' *OR &RTYP = 'B') THEN(DO)
             OVRDBF     FILE(LDR27B) TOFILE(LDR27B) MBR(&MEMBER)
             OVRPRTF    FILE(&PRTF7) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)
             CALL       PGM(LOADR60G) PARM(&FDTE6 &TDTE6)
             ENDDO

             ENDDO
/*------------------------------------------------------------------------*/

/* Detail report by Equipment */
             IF         COND(&SORT = '3' *OR &SORT = '4') THEN(DO)
             IF (&RTYP = 'D' *OR &RTYP = 'B') THEN(DO)
             OVRDBF     FILE(LDR26C) TOFILE(LDR26C) MBR(&MEMBER)
             OVRPRTF    FILE(&PRTF9) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)
             CALL       PGM(LOADR60J) PARM(&FDTE6 &TDTE6)
             ENDDO

/* Summary report by Equipment */
             IF (&RTYP = 'S' *OR &RTYP = 'B') THEN(DO)
             OVRDBF     FILE(LDR27C) TOFILE(LDR27C) MBR(&MEMBER)
             OVRPRTF    FILE(&PRTF8) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)
             CALL       PGM(LOADR60H) PARM(&FDTE6 &TDTE6)
             ENDDO

             ENDDO
/**************************************************************************/


INVOICE:
             IF (&INV = 'Y') THEN(DO)     /* Invoices */

/* Loader invoice report */
             IF (&INVT = 'L' *OR &INVT = 'B') THEN(DO)
             OVRDBF     FILE(LDR26) TOFILE(LDR26) MBR(&MEMBER)
             OVRPRTF    FILE(&PRTF3) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)

             CALL       PGM(LOADR60C) PARM(&FDTE6 &TDTE6)
             ENDDO

/* Driver invoice report */
             IF (&INVT = 'D' *OR &INVT = 'B') THEN(DO)
             OVRDBF     FILE(LDR26B) TOFILE(LDR26B) MBR(&MEMBER)
             OVRPRTF    FILE(&PRTF4) DEV(&DEV) OUTQ(*DEV) +
                        FORMTYPE(&FORM)

             CALL       PGM(LOADR60D) PARM(&FDTE6 &TDTE6)
             ENDDO

             GOTO       CMDLBL(NOMSG)
             ENDDO



/*---------------------------------------*/
/* Receive any messages and pass them on */
/*---------------------------------------*/

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

/*-------------------------*/
/* Clean up before leaving */
/*-------------------------*/

             RMVM        FILE(LDR26) MBR(&MEMBER)
             MONMSG      MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                               CPF7301 CPF7310)

             RMVM        FILE(LDR26B) MBR(&MEMBER)
             MONMSG      MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                               CPF7301 CPF7310)

             RMVM        FILE(LDR26C) MBR(&MEMBER)
             MONMSG      MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                               CPF7301 CPF7310)

             RMVM        FILE(LDR27) MBR(&MEMBER)
             MONMSG      MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                               CPF7301 CPF7310)

             RMVM        FILE(LDR27B) MBR(&MEMBER)
             MONMSG      MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                               CPF7301 CPF7310)

             RMVM        FILE(LDR27C) MBR(&MEMBER)
             MONMSG      MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                               CPF7301 CPF7310)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)
             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
