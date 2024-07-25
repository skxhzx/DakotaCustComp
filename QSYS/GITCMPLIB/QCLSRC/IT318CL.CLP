/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT318CL   Item activity report                                   */
/*  07 December, 2000                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    12/14/00  RH   V.15  CREATED                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT318CL:    PGM        PARM(&WHSE &RETURN &JOBQ &DEV &FORM &FMDT +
                            &TODT &ITEM)
   /*                       &TODT &VP &WHDP &SORT &ITEM &DISP) */
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT318CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT318)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LABEL)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(IT318BPR)
 /*          DCL        VAR(&PRTF2) TYPE(*CHAR) LEN(10) VALUE(IT313CPR)*/
 /*          DCL        VAR(&PRTF3) TYPE(*CHAR) LEN(10) VALUE(IT313FPR)*/

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Item activity report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Item activity report'        )

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
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
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN &JOBQ &DEV +
                          &FORM &FMDT &TODT &ITEM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &RETURN +
                          &JOBQ &DEV &FORM &FMDT &TODT &VP &ITEM)) +
                          JOB(AAIT318CL)
         /*               JOB(&SBMPGM)          */
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:  /* ( Chg 2.09 ) */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('LBWHSE *EQ ' *CAT &WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBITEM  +
                          *NE ' *CAT &QUOTE *CAT *PIRPICK *CAT &QUOTE))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBRDTE  +
                          *GE ' *CAT &FMDT))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBRDTE  +
                          *LE ' *CAT &TODT))
             IF         COND(&ITEM *NE *ALL) THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBITEM  +
                          *EQ' *BCAT &QUOTE *CAT &ITEM *CAT &QUOTE)
             ENDDO
        /*   IF         COND(&DISP *NE *ALL) THEN(DO)              */
        /*   CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')   */
        /*   CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBWHDP + */
        /*                *EQ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)*/
        /*   CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')   */
        /*   CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(LBDISP +*/
        /*                *EQ' *BCAT &QUOTE *CAT &DISP *CAT &QUOTE)*/
        /*   CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')    */
        /*   CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBDSP2 +  */
        /*                *EQ' *BCAT &QUOTE *CAT &DISP *CAT &QUOTE +*/
        /*                *BCAT ')')                                */
        /*   ENDDO                                                  */


   /* Use OPNQRYF to select and order the records we need */

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */
                CALL       PGM(GETUNQMEM) PARM(*REUSE IT318A &MEMBER)
 /*             CALL       PGM(GETWRKMEML) PARM(*REUSE IT318B +  */
 /*                           IT318A &MEMBER)                    */

             OVRDBF     FILE(IT318A) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(IT318B) MBR(&MEMBER) SHARE(*YES)

             OVRDBF     FILE(&FILE)  SHARE(*YES)
             OPNQRYF    FILE((&FILE)) +
                          QRYSLT(&QRYSLT) KEYFLD((LABEL/LBWHSE) +
                          (LABEL/LBITEM) (LABEL/LBRDTE))
             CALL       PGM(IT318A) PARM(&DISP &RETURN)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)


 /* REPORT:   ( Chg 2.09 ) */

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF1) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(IT318B) PARM(&FMDT &TODT &ITEM)

             DLTOVR     FILE(IT318A)
             DLTOVR     FILE(&FILE)
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
             RCLRSC     LVL(*CALLER)
 /*          CLRPFM     FILE(IT313A) MBR(&MEMBER)     */

             ENDPGM
