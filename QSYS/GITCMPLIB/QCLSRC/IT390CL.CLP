/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT390CL   Expired items report                                   */
/*  13 July 1993                                                     */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  NOTE:  Any changes need to be made to IT391CL also!              */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/20/95  DAS                                                  */
/*      - Revised OPNQRYF to include the warehouse along with the    */
/*        item as join fields.                                       */
/*    07/31/96  RH  2.14                                             */
/*      - Change to select items that will expire within entered     */
/*        # of days.                                                 */
/*      - Change select to include/exclude previously expired items. */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*    08/29/00  RH   4.14a                                           */
/*      - Change to select for one department or all.                */
/*    10/19/00  RH   4.14b                                           */
/*      - Change to select any date sensitive item with 0 date.      */
/*    03/26/01  RH   4.15a                                           */
/*      - Add &TODAY to Parms for Print/View.                        */
/*    06/05/01  RH   4.15b                                           */
/*      - Change OPNQRYF to sequential=*NO, had error for roll back  */
/*    07/02/01  RH   4.15c                                           */
/*      - Change OPNQRYF to not select records with 0 stock.         */
/*    08/25/03  HNK  4.17                                            */
/*      - Change to include Overflow slots, Pick slots or both.      */
/*    09/11/03  RH   4.17A                                           */
/*      - Add ITEMMSC TO OPNQRYF                                     */
/*    07/29/05  RH   5.00a                                           */
/*      - Add parm &SORT to sort by date or slot (slot is new)       */
/*    02/25/08  RH   5.20a                                           */
/*      - Fix: IMWHSE to select buyer for selected whse only         */
/*    11/13/12  RH   6.40b                                           */
/*      - Enh: Use ITEMQTY stock in place of SLOT stock              */
/*    08/20/14  LMC  6.50a                                           */
/*      - Enh: Reversed part of 640b, to eliminate 0 slots from      */
/*        displaying in view and print. If we find out what          */
/*        problem 640b was trying to resolve. We may need to         */
/*        revisit this.                                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*    10/29/10  GJA  GFCa                                            */
/*      - Enh: Add BUYER option to screen                            */
/*                                                                   */
/*    10/20/10  GJA  GFCB                                            */
/*      - Enh: Add new expiration report.                            */
/*-------------------------------------------------------------------*/

 IT390CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT390CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT390)

  /* Report program and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOT)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(IT391PR)
             DCL        VAR(&PRTS) TYPE(*CHAR) LEN(10) VALUE(IT393PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Expired items report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing expired items report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&PEXP)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&NEXP)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TODAY)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&PICK)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
/*GFCa*/     DCL        VAR(&BUYER)      TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */  /* 4.17 */

             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN &VP &JOBQ +
                          &DEV &FORM &PEXP &NEXP &TODAY &WHDP +
                          &PICK &SORT &BUYER)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
               SBMJOB     CMD(CALL PGM(&SBMPGM)) JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:
             IF (&VP *EQ 'C') THEN(DO)
             IF (&SORT = 'S') THEN(DO)
             OVRDBF     FILE(LICACTIVE2) TOFILE(LICACTIVE1) SHARE(*YES)
             ENDDO
             OVRPRTF    FILE(IT395PR) DEV(&DEV) OUTQ(COMPLEO) +
                          FORMTYPE(&FORM) USRDTA(IT395)
             CALL       PGM(IT395) PARM(&WHSE &PEXP &NEXP &TODAY +
                          &BUYER &PICK &WHDP)
             GOTO       CMDLBL(GETOUT)
             ENDDO

   /* Override printer file. */

             IF (&SORT = 'D') THEN(DO)
             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             ENDDO
             IF (&SORT = 'S') THEN(DO)                       /* 5.00a */
             OVRPRTF    FILE(&PRTS) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             ENDDO                                           /* 5.00a */

             MSGBFC     MESSAGE('Selecting records')

   /* 214 D  CALL       PGM(TODAY) PARM(&TODAY)          */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('SLWHSE *EQ ' *CAT &WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTAT *NE +
                          "V"')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTAT *NE +
                          "Z"')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(ITFLGD +
                          *EQ "Y")')
  /* 4.14b   CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(SLEXPD + */
  /* 4.14b                *NE 0)')                                  */
  /* 6.50a these lines have been reactivated 640b deleted them      */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(SLSTK1 +
                          *GT 0')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTK2 +
                          *GT 0')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTK3 +
                          *GT 0)')
  /* end of 6.50a                                                   */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(IQSTK1 +
                          *GT 0')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IQSTK2 +
                          *GT 0')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IQSTK3 +
                          *GT 0)')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             IF (&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             ENDDO

             IF         COND(&PEXP *EQ 'Y') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(SLEXPD +
                          *LE' *BCAT &NEXP *CAT ')')
             ENDDO
             IF         COND(&PEXP *NE 'Y') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(SLEXPD +
                          *GE' *BCAT &TODAY *CAT ')')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(SLEXPD +
                          *LE' *BCAT &NEXP *CAT ')')
             ENDDO
  /* 4.17 */
             IF (&PICK *EQ 'O') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(SLPICK +
                          *EQ "N")')
             ENDDO

  /* 4.17 */
             IF (&PICK *EQ 'P') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(SLPICK +
                          *EQ "Y")')
             ENDDO

  /* 4.17 */
             IF (&BUYER *NE '000') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(IMBNBR +
                          *EQ ' *BCAT &BUYER *CAT ')')
             ENDDO

  /* 5.00a */
             IF (&SORT *EQ 'D') THEN(DO)
             OVRDBF     FILE(IT391) TOFILE(&FILE) SHARE(*YES)
 /* 640b     OPNQRYF    FILE((SLOT) (PIRITEM) (ITEMMSC)) FORMAT(IT391) + */
             OPNQRYF    FILE((SLOT) (PIRITEM) (ITEMMSC) (ITEMQTY)) +
                          FORMAT(IT391) +
                          QRYSLT(&QRYSLT) KEYFLD((SLOT/SLWHSE) +
                          (ITEMMSC/IMBNBR) (SLOT/SLWHDP) (SLOT/SLEXPD) +
                          (SLOT/SLITEM)) JFLD((SLOT/SLWHSE +
                          PIRITEM/ITWHSE) (SLOT/SLITEM +
                          PIRITEM/ITITEM) (SLOT/SLWHSE +
 /* 5.20a */              ITEMMSC/IMWHSE) (SLOT/SLITEM +
 /* 6.40b */              ITEMMSC/IMITEM) (SLOT/SLWHSE +
 /* 6.40b */              ITEMQTY/IQWHSE) (SLOT/SLITEM +
                          ITEMQTY/IQITEM)) SEQONLY(*NO)
             ENDDO
  /* 5.00a */
             IF (&SORT *EQ 'S') THEN(DO)
             OVRDBF     FILE(IT393) TOFILE(&FILE) SHARE(*YES)
 /* 640B     OPNQRYF    FILE((SLOT) (PIRITEM) (ITEMMSC)) FORMAT(IT393) + */
             OPNQRYF    FILE((SLOT) (PIRITEM) (ITEMMSC) (ITEMQTY)) +
                          FORMAT(IT393) +
                          QRYSLT(&QRYSLT) KEYFLD((SLOT/SLWHSE) +
                          (SLOT/SLWHDP) (SLOT/SLDISP) (SLOT/SLEXPD) +
                          (SLOT/SLITEM)) JFLD((SLOT/SLWHSE +
                          PIRITEM/ITWHSE) (SLOT/SLITEM +
                          PIRITEM/ITITEM) (SLOT/SLWHSE +
 /* 5.20a */              ITEMMSC/IMWHSE) (SLOT/SLITEM +
 /* 6.40b */              ITEMMSC/IMITEM) (SLOT/SLWHSE +
 /* 6.40b */              ITEMQTY/IQWHSE) (SLOT/SLITEM +
                          ITEMQTY/IQITEM)) SEQONLY(*NO)
             ENDDO

 VIEW:

             IF (&VP = 'V') THEN(DO)
  /* 5.00a */
             IF (&SORT *EQ 'D') THEN(DO)
 /* 415a M   CALL       PGM(IT392) PARM(&WHSE &PEXP &NEXP)   */
             CALL       PGM(IT392) PARM(&WHSE &PEXP &NEXP &TODAY)
               GOTO       CMDLBL(NOMSG)
             ENDDO
  /* 5.00a */
             IF (&SORT *EQ 'S') THEN(DO)
             CALL       PGM(IT394) PARM(&WHSE &PEXP &NEXP &TODAY)
               GOTO       CMDLBL(NOMSG)
             ENDDO
             ENDDO

/* Get printer device to use and then execute print program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

  /* 5.00a */
             IF (&VP = 'P') THEN(DO)
             IF (&SORT *EQ 'D') THEN(DO)
/* 415a M    CALL       PGM(IT391) PARM(&PEXP &NEXP)        */
             CALL       PGM(IT391) PARM(&PEXP &NEXP &TODAY)
             ENDDO
  /* 5.00a */
             IF (&SORT *EQ 'S') THEN(DO)
             CALL       PGM(IT393) PARM(&PEXP &NEXP &TODAY)
             ENDDO
             ENDDO

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
