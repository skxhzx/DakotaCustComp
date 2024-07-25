/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT312CL   Item/Slot activity report                              */
/*  26 June, 1996                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*    03/11/99  RH   4.11                                            */
/*      - Move DLTOVR to before GETOUT to correct msg looping error. */
/*      - Change JOB name to JOBQ, was getting error in GETUNQMEM    */
/*        because job name started with a number (312CL     )        */
/*      - Add call to GETWRKMEML before VIEW tag.                    */
/*    12/20/00  RH   4.15                                            */
/*      - Add code to allow PARMS to be sent in and bypass option    */
/*        program.                                                   */
/*    01/03/02  RH   4.16                                            */
/*      - Add code to use work file for linked items.                */
/*    01/07/02  RH   4.16b                                           */
/*      - Add parm $LINK Y/N Linked item exists.                     */
/*    12/17/02  RH/HNK 4.16c                                         */
/*      - Add wild card search to get virtual slots for base         */
/*      - Add $DISP1 for wild card slot (base with *)                */
/*                                                                   */
/*    01/03/03  DAS 4.16d                                            */
/*      - Revised key of OPNQRY statements to use work file fields.  */
/*        The result is that the optimizer uses the work file as the */
/*        primary join file. This in turn makes it necessary for     */
/*        query to create a temporary file of the results. The       */
/*        bottom line is that the query runs more quickly. In        */
/*        testing it seems the delay was in opening the work file    */
/*        in the main report programs. When the query used the Label */
/*        file as the primary join file, the open took much longer   */
/*        while the query was selecting the appropriate records.     */
/*    05/20/03  RH  4.17a                                            */
/*      - Move code that checks if being called and sent parms.      */
/*      - Calling progarm will send 'X' in &JOBQ to allow necessary  */
/*        code to execute and submit the job if &JOBQ='Y'            */
/*      - If called by program, calls IT312A to fill work file       */
/*    02/09/05  RLP 5.00                                             */
/*      - had a problem when submitted to jobq, was skipping over    */
/*        the 4.16-4.17a changes so it would either get error or     */
/*        do nothing if submitted and operate as expected if run     */
/*        interactively, incorporated 4.16-4.17a changes into the    */
/*        RTVJOBA command                                            */
/*    05/01/05  RLP 5.00a                                            */
/*      - change opnqry select to exclude label records where        */
/*        LBPCKQ = 0                                                 */
/*    09/30/05  RLP 5.00b                                            */
/*      - seems the 5.00 revision not quite good enough, when it     */
/*        submits to jobq it prints ALL slots for the time frame     */
/*        selected. Turns out that on the recursion back, &DISP1     */
/*        wild card variable is null so it prints all slots. Added   */
/*        &DISP1 variable to the parm list.                          */
/*        NOTE: this patch requires that you change the call command */
/*              in the menu source to match number of parms. ALSO    */
/*              affects number of parms in pgms IT480 & IT480B.      */
/*    02/20/06  RH  5.00c                                            */
/*      - Add sort 4 by item/close date/trans#, file IT313D          */
/*                                                                   */
/*    07/06/06  MLB  5.10                                            */
/*      - Enh: Revised program to redisplay options program when     */
/*        F12=Cancel pressed when View option is selected.           */
/*                                                                   */
/*    10/17/07  LMC  5.20a  P#00023                                  */
/*      - Enh: Added label history file - replaced opnqryf with sql  */
/*-------------------------------------------------------------------*/

 IT312CL:    PGM        PARM(&WHSE &RETURN &JOBQ &DEV &FORM &FMDT +
                          &TODT &VP &WHDP &SORT &ITEM &DISP &LINK +
                          &DISP1) /* 500b A */
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT312CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT312)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LABEL)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(IT313BPR)
             DCL        VAR(&PRTF2) TYPE(*CHAR) LEN(10) VALUE(IT313CPR)
             DCL        VAR(&PRTF3) TYPE(*CHAR) LEN(10) VALUE(IT313FPR)
             DCL        VAR(&PRTF4) TYPE(*CHAR) LEN(10) VALUE(IT313EPR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Item/Slot activity')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Item/Slot activity report'   )

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&DISP1)      TYPE(*CHAR) LEN(12)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER1)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&LINK)       TYPE(*CHAR) LEN(1)
/*  500a A  */
             DCL        VAR(&ZERO)       TYPE(*CHAR) LEN(1) VALUE('0')
             DCL        VAR(&HIST) TYPE(*CHAR) LEN(1) VALUE('Y') /* +
                          520a */
             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE(LABELH) /* 520a */
             DCLF       FILE(LABELH) /* 520a */

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
/* 5.00 D    IF (&TYPE = '0') THEN(GOTO REPORT)  change follows */
             IF (&TYPE = '0') THEN(DO)
                CALL       PGM(GETUNQMEM) PARM(*REUSE IT312 &MEMBER1)
                OVRDBF     FILE(IT312) MBR(&MEMBER1) SHARE(*YES)
                CALL       PGM(IT312A) PARM(&WHSE &ITEM &LINK &RETURN)
                GOTO       CMDLBL(REPORT)
             ENDDO
/* 5.00 changes end */

/*    - Get unique member to use.              4.16   */
                CALL       PGM(GETUNQMEM) PARM(*REUSE IT312 &MEMBER1)
             OVRDBF     FILE(IT312) MBR(&MEMBER1) SHARE(*YES)

/*  4.15 Don't get options, if being called and sent parms. */
/*  4.17a    IF (&JOBQ = 'Y') THEN(GOTO REPORT)             */
/*  4.17a Changes follow                                    */
             IF (&JOBQ = 'X') THEN(DO)
                CALL       PGM(IT312A) PARM(&WHSE &ITEM &LINK &RETURN)
                GOTO       CMDLBL(REPORT)
               ENDDO
/*  4.17a Changes end                                       */

/*  Get report options. */

options:                                                          /* (510 A) */
             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN &JOBQ &DEV +
                          &FORM &FMDT &TODT &VP &WHDP &SORT &ITEM +
                          &DISP &LINK &DISP1)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
/*             RETURN                                                (510 D) */
               GOTO  CMDLBL(OUT)                                  /* (510 M) */
               ENDDO


/* See if user wants to put report on jobq. */
/* 500b added &DISP1 variable to parm of called progam below */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &RETURN +
                          &JOBQ &DEV &FORM &FMDT &TODT &VP &WHDP +
                          &SORT &ITEM &DISP &LINK &DISP1)) +
                          JOB(AAIT312CL)
         /*               JOB(&SBMPGM)          */
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:  /* ( Chg 2.09 ) */

/* Check to see if history files have data   520a    */
             RCVF       DEV(*FILE) /* 520a */
             MONMSG     MSGID(CPF0864) EXEC(CHGVAR VAR(&HIST) +
                          VALUE('N')) /* 520a */
   /* Create selection criteria string. */

 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE('LBWHSE *EQ ' *CAT &WHSE) */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')     */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBITEM  + */
 /* 520a                  *NE ' *CAT &QUOTE *CAT *PIRPICK *CAT &QUOTE)) */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')     */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBRDTE  + */
 /* 520a                  *GE ' *CAT &FMDT))                         */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')     */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBRDTE  + */
 /* 520a                  *LE ' *CAT &TODT))                         */
  /*  500a A  */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')     */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBQPCK  + */
 /* 520a                  *NE ' *CAT &ZERO))                         */
  /*  500a ends */

  /*         IF         COND(&ITEM *NE *ALL) THEN(DO)              */
  /*         CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')   */
  /*         CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBITEM  +*/
  /*                      *EQ' *BCAT &QUOTE *CAT &ITEM *CAT &QUOTE)*/
  /*         ENDDO                                                 */
 /* 520a     IF         COND(&DISP *NE *ALL) THEN(DO)                */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')     */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBWHDP +   */
 /* 520a                  *EQ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)  */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')     */
  /*         CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(LBDISP + */
  /*                      *EQ' *BCAT &QUOTE *CAT &DISP *CAT &QUOTE) */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('(LBDISP + */
 /* 520a                  *EQ %WLDCRD(' *BCAT &QUOTE *CAT &DISP1 *CAT + */
 /* 520a                  &QUOTE *BCAT ')'))                         */
 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')      */

 /* 520a     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('(LBDSP2 + */
 /* 520a                  *EQ %WLDCRD(' *BCAT &QUOTE *CAT &DISP1 *CAT + */
 /* 520a                  &QUOTE *BCAT ')' *CAT ')' *CAT ')'))       */
    /*       CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBDSP2 +   */
    /*                    *EQ' *BCAT &QUOTE *CAT &DISP *CAT &QUOTE + */
    /*                    *BCAT ')')                                 */

 /* 520a     ENDDO                                                   */


   /* Use OPNQRYF to select and order the records we need */

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */
 /* 520a        CALL       PGM(GETUNQMEM) PARM(*REUSE IT313A &MEMBER)*/
 /* 520a        CALL       PGM(GETWRKMEML) PARM(*REUSE IT313B +      */
 /* 520a                      IT313A &MEMBER)                        */
 /* 520a        CALL       PGM(GETWRKMEML) PARM(*REUSE IT313C +      */
 /* 520a                      IT313A &MEMBER)                        */
 /* 520a        CALL       PGM(GETWRKMEML) PARM(*REUSE IT313D +      */
 /* 520a                      IT313A &MEMBER)                        */

 /* 520a     OVRDBF     FILE(IT313A) MBR(&MEMBER) SHARE(*YES)        */
 /* 520a     OVRDBF     FILE(IT313B) MBR(&MEMBER) SHARE(*YES)        */
 /* 520a     OVRDBF     FILE(IT313C) MBR(&MEMBER) SHARE(*YES)        */
 /* 520a     OVRDBF     FILE(IT313D) MBR(&MEMBER) SHARE(*YES)        */

 /* 520a     OVRDBF     FILE(&FILE)  SHARE(*YES)                     */
 /* 520a     OVRDBF     FILE(IT312A) TOFILE(LABEL) SHARE(*YES)       */

 /* 520a     IF         COND(&ITEM *NE *ALL) THEN(DO)                */
/* 416dD     OPNQRYF    FILE((&FILE) (IT312 &MEMBER1)) +            */
/*                        FORMAT(IT312A) QRYSLT(&QRYSLT) +          */
/*                        KEYFLD((LABEL/LBWHSE) (LABEL/LBITEM) +    */
/*                        (LABEL/LBRDTE) (LABEL/LBDISP)) +          */
/*                        JFLD((&FILE/LBWHSE IT312/WKWHSE) +        */
/*                        (&FILE/LBITEM IT312/WKITEM)) JDFTVAL(*NO) */
 /* 520a     OPNQRYF    FILE((&FILE) (IT312 &MEMBER1)) +             */
 /* 520a                  FORMAT(IT312A) QRYSLT(&QRYSLT) +           */
 /* 520a                  KEYFLD((IT312/WKWHSE) (IT312/WKITEM) +     */
 /* 520a                  (LABEL/LBRDTE) (LABEL/LBDISP)) +           */
 /* 520a                  JFLD((&FILE/LBWHSE IT312/WKWHSE) +         */
 /* 520a                  (&FILE/LBITEM IT312/WKITEM)) JDFTVAL(*NO)  */
/*                        (&FILE/LBITEM IT312/WKITEM)) JDFTVAL(*NO)  */
 /* 520a     ENDDO                                                   */

 /* 520a     IF         COND(&ITEM *EQ *ALL) THEN(DO)                */
/* 416dD     OPNQRYF    FILE((&FILE) (IT312 &MEMBER1)) +            */
/*                        FORMAT(IT312A) QRYSLT(&QRYSLT) +          */
/*                        KEYFLD((LABEL/LBWHSE) (LABEL/LBITEM) +    */
/*                        (LABEL/LBRDTE) (LABEL/LBDISP)) +          */
/*                        JFLD((&FILE/LBWHSE IT312/WKWHSE) +        */
/*                        (&FILE/LBITEM IT312/WKITEM)) JDFTVAL(*YES)*/
 /* 520a     OPNQRYF    FILE((&FILE) (IT312 &MEMBER1)) +             */
 /* 520a                  FORMAT(IT312A) QRYSLT(&QRYSLT) +           */
 /* 520a                  KEYFLD((IT312/WKWHSE) (IT312/WKITEM) +     */
 /* 520a                  (LABEL/LBRDTE) (LABEL/LBDISP)) +           */
 /* 520a                  JFLD((&FILE/LBWHSE IT312/WKWHSE) +         */
 /* 520a                  (&FILE/LBITEM IT312/WKITEM)) JDFTVAL(*YES) */
 /* 520a     ENDDO                                                   */

   /* 520a This is where the new history logic starts   */
   /* 520a Call sql programs to create workfile. */
/*    - Override file to use unique member.           */
             CALL       PGM(GETUNQMEM) PARM(*REUSE IT312AH &MEMBER)
             OVRDBF     FILE(IT312AH) MBR(&MEMBER) SHARE(*YES)
             CALL       PGM(IT312S) PARM(&WHSE &FMDT &TODT &ITEM +
                          &DISP &HIST)

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */
                CALL       PGM(GETUNQMEM) PARM(*REUSE IT313A &MEMBER)
                CALL       PGM(GETWRKMEML) PARM(*REUSE IT313B +
                              IT313A &MEMBER)
                CALL       PGM(GETWRKMEML) PARM(*REUSE IT313C +
                              IT313A &MEMBER)
                CALL       PGM(GETWRKMEML) PARM(*REUSE IT313D +
                              IT313A &MEMBER)

             OVRDBF     FILE(IT313A) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(IT313B) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(IT313C) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(IT313D) MBR(&MEMBER) SHARE(*YES)

             OVRDBF     FILE(IT312A) TOFILE(IT312AH) MBR(&MEMBER) +
                          SHARE(*YES)

             CALL       PGM(IT313A) PARM(&DISP &RETURN)


 VIEW:

             IF (&VP = 'V') THEN(DO)
             IF (&SORT = '1') THEN(DO)
             CALL       PGM(IT314B) PARM(&WHSE &FMDT &TODT &ITEM +
                        &DISP &LINK &return)                      /* (510 M) */
/*             GOTO       CMDLBL(OUT)                                (510 D) */
             ENDDO

             IF (&SORT = '2') THEN(DO)
             CALL       PGM(IT314C) PARM(&WHSE &FMDT &TODT &ITEM +
                        &DISP &LINK &return)                      /* (510 M) */
/*             GOTO       CMDLBL(OUT)                                (510 D) */
             ENDDO

             IF (&SORT = '3') THEN(DO)
             CALL       PGM(IT314D) PARM(&WHSE &FMDT &TODT &ITEM +
                        &DISP &LINK &return)                      /* (510 D) */
/*             GOTO       CMDLBL(OUT)                                (510 D) */
             ENDDO

             IF (&SORT = '4') THEN(DO)
             CALL       PGM(IT314E) PARM(&WHSE &FMDT &TODT &ITEM +
                        &DISP &LINK &return)                      /* (510 M) */
/*             GOTO       CMDLBL(OUT)                                (510 D) */
             ENDDO
             IF         COND(&RETURN = '*CANCEL') THEN(DO)        /* (510 A) */
               CHGVAR     VAR(&RETURN) VALUE('        ')          /* (510 A) */
               DLTOVR     FILE(*ALL) LVL(*JOB)                    /* (510 A) */
               RCLRSC     LVL(*CALLER)                            /* (510 A) */
               MONMSG     MSGID(CPF9841)                          /* (510 A) */
               CALL       PGM(GETUNQMEM) PARM(*REUSE IT312 &MEMBER1) +
                                                                  /* (510 A) */
               GOTO       CMDLBL(OPTIONS)                         /* (510 A) */
             enddo                                                /* (510 A) */
             ELSE       CMD(DO)                                   /* (510 A) */
               GOTO       CMDLBL(OUT)                             /* (510 A) */
             enddo                                                /* (510 A) */
             ENDDO


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)


 /* REPORT:   ( Chg 2.09 ) */

   /* Override printer file. */

             IF (&SORT = '1') THEN(DO)
             OVRPRTF    FILE(&PRTF1) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(IT313B) PARM(&FMDT &TODT &ITEM &DISP &LINK)
             ENDDO

             IF (&SORT = '2') THEN(DO)
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */
                CALL       PGM(GETWRKMEML) PARM(*REUSE IT313B +
                              IT313A &MEMBER)

             OVRDBF     FILE(IT313B) MBR(&MEMBER) SHARE(*YES)
             OVRPRTF    FILE(&PRTF2) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(IT313C) PARM(&FMDT &TODT &ITEM &DISP &LINK)
             ENDDO

             IF (&SORT = '3') THEN(DO)
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */
                CALL       PGM(GETWRKMEML) PARM(*REUSE IT313C +
                              IT313A &MEMBER)

             OVRDBF     FILE(IT313C) MBR(&MEMBER) SHARE(*YES)
             OVRPRTF    FILE(&PRTF3) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(IT313D) PARM(&FMDT &TODT &ITEM &DISP &LINK)
             ENDDO
             IF (&SORT = '4') THEN(DO)
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */
                CALL       PGM(GETWRKMEML) PARM(*REUSE IT313D +
                              IT313A &MEMBER)

             OVRDBF     FILE(IT313D) MBR(&MEMBER) SHARE(*YES)
             OVRPRTF    FILE(&PRTF4) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(IT313E) PARM(&FMDT &TODT &ITEM &DISP &LINK)
             ENDDO

             DLTOVR     FILE(IT313A)
             DLTOVR     FILE(IT312)
 /* 520a     DLTOVR     FILE(&FILE)                                  */
             DLTOVR     FILE(IT312AH) /* 520a */
 /* Receive any messages and pass them on */

 GETOUT:
    /*       DLTOVR     FILE(&FILE)    */
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

 /*          DLTOVR     FILE(IT313A)          */
             DLTOVR     FILE(*ALL) LVL(*JOB)                      /* (510 A) */
             MONMSG     MSGID(CPF9841)                            /* (510 A) */
             RCLRSC     LVL(*CALLER)
 /*          CLRPFM     FILE(IT313A) MBR(&MEMBER)     */
             IF         COND(&MEMBER > ' ') THEN(DO)              /* (510 A) */
               RMVM       FILE(IT313B) MBR(&MEMBER)               /* (510 A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (510 A) */
               RMVM       FILE(IT313C) MBR(&MEMBER)               /* (510 A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (510 A) */
               RMVM       FILE(IT313D) MBR(&MEMBER)               /* (510 A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (510 A) */
               RMVM       FILE(IT313A) MBR(&MEMBER)               /* (510 A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (510 A) */
             RMVM       FILE(IT312AH) MBR(&MEMBER) /* 520a */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310) /* 520a */
             ENDDO                                                /* (510 A) */
             IF         COND(&MEMBER1 > ' ') THEN(DO)             /* (510 A) */
               RMVM       FILE(IT312)  MBR(&MEMBER1)              /* (510 A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (510 A) */
             ENDDO                                                /* (510 A) */

             ENDPGM
