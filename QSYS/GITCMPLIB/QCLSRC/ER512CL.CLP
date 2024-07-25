/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER512CL   Employee Activity Report                               */
/*  04 Sept, 2001                                                    */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    09/04/01  HNK  4.16                                            */
/*      - Created                                                    */
/*                                                                   */
/*    11/21/01  HNK  4.16a                                           */
/*      - Fix dept selection.                                        */
/*                                                                   */
/*    01/21/11  GJA  6.40a                                           */
/*      - Fix:  Was not removing members                             */
/*    03/07/22  RH   7.50a                                           */
/*      - Added client custom code support to program.               */
/*      - Add User Auth and error msg to use Web Dakota program      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ER512CL:    PGM        PARM(&WHSE &RETURN &JOBQ &DEV &FORM &FMDT +
                            &TODT &VP &WHDP &SORT &ITEM &DISP &TASK)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                              (510 A)  */

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER512CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER512)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LABEL)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(ER513BPR)
             DCL        VAR(&PRTF2) TYPE(*CHAR) LEN(10) VALUE(ER513CPR)
             DCL        VAR(&PRTF3) TYPE(*CHAR) LEN(10) VALUE(ER513FPR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Item/Slot activity')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Item/Slot activity report'   )

/*750aA*/    DCL        VAR(&NOAUTHRZG) TYPE(*CHAR) LEN(60) +
                          VALUE('   Use Web Dakota EPM Task Detail +
                            by Zone.')
/*750aA*/    DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
/*750aA*/    DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
/*750 A*/    DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
/*750 A*/    DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
/*750 A*/    DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

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
             DCL        VAR(&TASK)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*750aA*/    CHGVAR     VAR(&PGMID) VALUE(ER360CL)
/*750aA*/    RTVJOBA    USER(&PUSR)
/*750aA*/    RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)

/*  Check if user is authorized to use this option              (750aA) */

/*750aA*/    CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
/*750aA*/    IF         COND(&PRTN *EQ '*NO')  THEN(DO)
/*750aA*/               SNDPGMMSG  MSG(&NOAUTHRZG)   +
/*750aA*/               MSGTYPE(*INFO)
/*750aA*/    RETURN
/*750aA*/    ENDDO

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

             IF (&JOBQ = 'Y') THEN(GOTO REPORT)

AGAIN:

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN &JOBQ &DEV +
                          &FORM &FMDT &TODT &VP &WHDP &SORT &ITEM +
                          &DISP &TASK)

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
                          &JOBQ &DEV &FORM &FMDT &TODT &VP &WHDP +
                          &SORT &ITEM &DISP &TASK)) +
                          JOB(AAER512CL)
         /*               JOB(&SBMPGM)          */
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

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

             IF         COND(&WHDP *NE *ALL) THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBWHDP +
                          *EQ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

             IF         COND(&DISP *NE *ALL) THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(LBDISP +
                          *EQ' *BCAT &QUOTE *CAT &DISP *CAT &QUOTE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBDSP2 +
                          *EQ' *BCAT &QUOTE *CAT &DISP *CAT &QUOTE +
                          *BCAT ')')
             ENDDO

             IF         COND(&TASK *NE *ALL) THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTTASK  +
                          *EQ' *BCAT &QUOTE *CAT &TASK *CAT &QUOTE)
             ENDDO


   /* Use OPNQRYF to select and order the records we need */

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */
                CALL       PGM(GETUNQMEM) PARM(*REUSE ER513A &MEMBER)
                CALL       PGM(GETWRKMEML) PARM(*REUSE ER513B +
                              ER513A &MEMBER)
                CALL       PGM(GETWRKMEML) PARM(*REUSE ER513C +
                              ER513A &MEMBER)

             OVRDBF     FILE(ER513A) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(ER513B) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(ER513C) MBR(&MEMBER) SHARE(*YES)

             OVRDBF     FILE(ER513) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (PIRTRAN) (PIRUSER)) +
                          FORMAT(ER513) QRYSLT(&QRYSLT) +
                          KEYFLD((LABEL/LBWHSE) (LABEL/LBITEM) +
                          (LABEL/LBRDTE) (LABEL/LBDISP)) +
                          JFLD((&FILE/LBTRN# PIRTRAN/PTTRN#) +
                          (PIRTRAN/PTEMP# PIRUSER/USEMP#)) +
                          JDFTVAL(*YES)
             CALL       PGM(ER513A) PARM(&DISP &RETURN)


 VIEW:

             IF (&VP = 'V') THEN(DO)
             IF (&SORT = '1') THEN(DO)
             CALL       PGM(ER514B) PARM(&WHSE &FMDT &TODT &ITEM +
                          &DISP &TASK)
             RCLRSC     LVL(*CALLER)
               GOTO       CMDLBL(AGAIN)
             ENDDO

             IF (&SORT = '2') THEN(DO)
             CALL       PGM(ER514C) PARM(&WHSE &FMDT &TODT &ITEM +
                          &DISP &TASK)
             RCLRSC     LVL(*CALLER)
               GOTO       CMDLBL(AGAIN)
             ENDDO

             IF (&SORT = '3') THEN(DO)
             CALL       PGM(ER514D) PARM(&WHSE &FMDT &TODT &ITEM +
                          &DISP &TASK)
             RCLRSC     LVL(*CALLER)
               GOTO       CMDLBL(AGAIN)
             ENDDO
             ENDDO


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)



   /* Override printer file. */

             IF (&SORT = '1') THEN(DO)
             OVRPRTF    FILE(&PRTF1) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(ER513B) PARM(&FMDT &TODT &ITEM &DISP &TASK)
             ENDDO

             IF (&SORT = '2') THEN(DO)
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */
                CALL       PGM(GETWRKMEML) PARM(*REUSE ER513B +
                              ER513A &MEMBER)

             OVRDBF     FILE(ER513B) MBR(&MEMBER) SHARE(*YES)
             OVRPRTF    FILE(&PRTF2) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(ER513C) PARM(&FMDT &TODT &ITEM &DISP &TASK)
             ENDDO

             IF (&SORT = '3') THEN(DO)
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */
                CALL       PGM(GETWRKMEML) PARM(*REUSE ER513C +
                              ER513A &MEMBER)

             OVRDBF     FILE(ER513C) MBR(&MEMBER) SHARE(*YES)
             OVRPRTF    FILE(&PRTF3) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(ER513D) PARM(&FMDT &TODT &ITEM &DISP &TASK)
             ENDDO

             DLTOVR     FILE(ER513A)
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
 OUT:
 NOMSG:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)
   /* 6.40a Clean up file members before leaving */
             CLOF       OPNID(ER513C)
             MONMSG     MSGID(CPF4519 CPF4520)
             DLTOVR     FILE(ER513C) LVL(*JOB)
             MONMSG     MSGID(CPF9841)
             CLOF       OPNID(ER513B)
             MONMSG     MSGID(CPF4519 CPF4520)
             DLTOVR     FILE(ER513B) LVL(*JOB)
             MONMSG     MSGID(CPF9841)
             CLOF       OPNID(ER513A)
             MONMSG     MSGID(CPF4519 CPF4520)
             DLTOVR     FILE(ER513A) LVL(*JOB)
             MONMSG     MSGID(CPF9841)
             RMVM       FILE(ER513C) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)
             RMVM       FILE(ER513B) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)
             RMVM       FILE(ER513A) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)
   /* 6.40a */


             ENDPGM
