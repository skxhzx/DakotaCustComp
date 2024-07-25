/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV120CL   Print inventory sheets                                 */
/*  31 January 1996                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*  04/04/96 HNK/RH V2.12                                            */
/*       Added IV125 called with parameter &RPRT for re-print.       */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*    09/16/02  RH   4.16                                            */
/*      - Add &WHDP parameter.                                       */
/*      - Add &WHDP to qry select.                                   */
/*                                                                   */
/*    09/13/06  JCJ  5.10                                            */
/*      - Added client custom code support to program.               */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: BiRite                                  */
/*                                                                   */
/*  12/02/05  MLB  BIR                                               */
/*    - Revised program to change first OPNQRYF sort to put IVSLOC   */
/*      before IVSLVL. This will cause all slots in a given bay to   */
/*      be counted from level 1 to the top.                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: CityLine                                */
/*                                                                   */
/*  Client Custom Revisions: City Line                               */
/*    - Revised program to change first OPNQRYF sort to put IVSLOC   */
/*      before IVSLVL for PIR.  Will cause all slots in a given bay  */
/*      to be counted from level 1 to the top.                       */
/*    - Revised program process PIR slots first                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: VIP                                     */
/*                                                                   */
/*  09/13/06  JCJ  VIP                                               */
/*    - Revised program process pick slots first and overflow slots  */
/*      last for VIP                                                 */
/*  06/07/07  RH   JOR                                               */
/*    - Revised program process pick slots first then overflow       */
/*      print by dept/section/aisle/level/side                       */
/*  11/28/16  RH   CDI                                               */
/*    - Add CDI to BIR mod, print by dept, section, aisle, side, loc */
/*      Applied for Jacksonville only,                               */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IV120CL:    PGM

/*-------------------------------------------------------------------*/
/* 510 A - Client ID's                                               */
/*-------------------------------------------------------------------*/

/* 510 A */  DCL        VAR(&VIP)      TYPE(*CHAR)  LEN(10) +
                          VALUE('VIP       ')
/* 510 A */  DCL        VAR(&BIRITE)   TYPE(*CHAR)  LEN(10) +
                          VALUE('BIRITE    ')
/* CLD A */  DCL        VAR(&CITYLN)   TYPE(*CHAR)  LEN(10) +
                          VALUE('CITYLINE  ')
/* 510 A */  DCL        VAR(&JORDAN)   TYPE(*CHAR)  LEN(10) +
                          VALUE('JORDANOS  ')
/* CDI A */  DCL        VAR(&CDI)   TYPE(*CHAR)  LEN(10) +
                          VALUE('CDI       ')
/* 510 A */  DCL        VAR(&CLIENT)    TYPE(*CHAR) LEN(10)
/* 510 A */  DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)
/* 510 A */  DCL        VAR(&PASS)      TYPE(*DEC)  LEN(1 0) VALUE(1)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV120CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV120)
 /* 510 A */ DCL        VAR(&OPTPGM2) TYPE(*CHAR) LEN(10) +
                          VALUE(IV120a)

  /*  OPNQRY file. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(INVSLOT)
             DCL        VAR(&FILE2) TYPE(*CHAR) LEN(10) VALUE(INVSLOT1)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Print Inventory Sheets')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

/* 510 A */  DCL        VAR(&YES)        TYPE(*CHAR) LEN(1) VALUE('Y')
/* 510 A */  DCL        VAR(&NO)         TYPE(*CHAR) LEN(1) VALUE('N')
/* 510 A */  DCL        VAR(&QRYSLT2)    TYPE(*CHAR) LEN(2000)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RPRT)       TYPE(*CHAR) LEN(1) VALUE('N')

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/* 510 A */    CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)

/*  Assign sheet numbers to slot records. */

/* 510 A */  IF         COND(&CLIENT *NE &VIP *AND &CLIENT *NE +
/* CLD M */             &CITYLN *AND &CLIENT *NE &JORDAN) THEN(DO)
/* CLD D                &JORDAN) THEN(DO)    */
             MSGBFC     MESSAGE('Assigning sheet numbers to slots')
/* 510 A */  ENDDO

AGAIN:

/* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('IVSWHS *EQ ' *CAT &WHSE)
             IF         COND(&WHDP *NE *ALL) THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVSWHD +
                          *EQ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVSPAG *EQ +
                          0')

/* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE) SHARE(*YES)

/* 510 A */  IF         COND(&CLIENT = &VIP *OR &CLIENT =&JORDAN) +
/* 510 A */             THEN(DO)
             IF         COND(&PASS = 1) THEN(DO)
             MSGBFC     MESSAGE('Assigning sheet numbers to pick +
                          slots')
             CHGVAR     VAR(&QRYSLT2) VALUE(&QRYSLT)
             CHGVAR     VAR(&QRYSLT)  VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVSPCK +
                          *EQ' *BCAT &QUOTE *CAT &YES *CAT &QUOTE)
             ENDDO


/* 510 A */  IF         COND(&PASS = 2) THEN(DO)
             MSGBFC     MESSAGE('Assigning sheet numbers to overflow +
                          slots')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT2)
             CHGVAR     VAR(&QRYSLT)  VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVSPCK +
                          *EQ' *BCAT &QUOTE *CAT &NO *CAT &QUOTE)
             ENDDO
             ENDDO

/* 510 A */  IF         COND(&CLIENT *NE &BIRITE *AND &CLIENT *NE +
                          &VIP *AND &CLIENT *NE &JORDAN *AND +
/* CLD A */               &CLIENT *NE &CITYLN *AND +
/* CLD A */               &CLIENT *NE &CDI) THEN(DO)
/* CDI D                  &VIP *AND &CLIENT *NE &JORDAN) THEN(DO) */
             OPNQRYF    FILE((&FILE)) +
                        OPTION(*ALL)  +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((IVSWHS) +
                               (IVSWHD) +
                               (IVSASL) +
                               (IVSSID *DESCEND) +
                               (IVSLVL) +
                               (IVSLOC) +
                               (IVSHND))
/* 510 A */  ENDDO

/* BIR   */  IF         COND(&CLIENT *EQ &BIRITE) THEN(DO)
             OPNQRYF    FILE((&FILE)) +
                        OPTION(*ALL)  +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((IVSWHS) +
                               (IVSWHD) +
                               (IVSASL) +
                               (IVSSID *DESCEND) +
                               (IVSLOC) +
                               (IVSLVL) +
                               (IVSHND))
/* BIR   */  ENDDO

/* CLD   */  IF         COND(&CLIENT *EQ &CITYLN) THEN(DO)
             IF         COND(&PASS = 1) THEN(DO)
             CHGVAR     VAR(&QRYSLT2) VALUE(&QRYSLT)
             CHGVAR     VAR(&QRYSLT)  VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVSSTP +
                          *EQ' *BCAT &QUOTE *CAT P *CAT &QUOTE)
             OPNQRYF    FILE((&FILE)) +
                        OPTION(*ALL)  +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((IVSWHS) +
                               (IVSWHD) +
                               (IVSASL) +
                               (IVSLOC) +
                               (IVSLVL) +
                               (IVSHND))
/* CLD   */  ENDDO

/* CLD   */  IF         COND(&PASS = 2) THEN(DO)
             MSGBFC     MESSAGE('Assigning sheet numbers to FIXED +
                          slots')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT2)
             CHGVAR     VAR(&QRYSLT)  VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVSSTP +
                          *EQ' *BCAT &QUOTE *CAT F *CAT &QUOTE)
             OPNQRYF    FILE((&FILE)) +
                        OPTION(*ALL)  +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((IVSWHS) +
                               (IVSWHD) +
                               (IVSASL) +
                               (IVSSID *DESCEND) +
                               (IVSLVL) +
                               (IVSLOC) +
                               (IVSHND))
             ENDDO
/* CLD   */  ENDDO


/* CDI   */  IF         COND(&CLIENT *EQ &CDI) THEN(DO)
             OPNQRYF    FILE((&FILE)) +
                        OPTION(*ALL)  +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((IVSWHS) +
                               (IVSWHD) +
                               (IVSASL) +
                               (IVSSID *DESCEND) +
                               (IVSLOC) +
                               (IVSLVL) +
                               (IVSHND))
/* CDI   */  ENDDO

/* VIP  */   IF         COND(&CLIENT *EQ &VIP) THEN(DO)
             OPNQRYF    FILE((&FILE)) +
                        OPTION(*ALL)  +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((IVSWHS) +
                               (IVSWHD) +
                               (IVSSTP) +
                               (IVSASL) +
                               (IVSSID *DESCEND) +
                               (IVSLOC) +
                               (IVSLVL) +
                               (IVSHND))
/* VIP */    ENDDO


/* JORDAN */ IF         COND(&CLIENT *EQ &JORDAN) THEN(DO)
             OPNQRYF    FILE((&FILE)) +
                        OPTION(*ALL)  +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((IVSWHS) +
                               (IVSWHD) +
                               (IVSSTP) +
                               (IVSASL) +
                               (IVSSID *DESCEND) +
                               (IVSLOC) +
                               (IVSHND))
/* JOR */    ENDDO
/* Call program to assign sheet numbers */

/* 510 A */  IF         COND((&CLIENT = &VIP) *OR (&CLIENT = +
                          &BIRITE) *OR (&CLIENT = &JORDAN) +
/* CDI M */               *OR (&CLIENT = &CDI)) +
                          THEN(DO)
/* CDI D                  &BIRITE) *OR (&CLIENT = &JORDAN)) +  */
/* 510 A */  CALL       PGM(IV121a) PARM(&RETURN)
/* 510 A */  GOTO       SKIP
/* 510 A */  ENDDO

/* CLD A */  IF         COND(&CLIENT = &CITYLN) +
                          THEN(DO)
/* CLD   */  IF         COND(&PASS = 1) THEN(DO)
/* CLD A */  CALL       PGM(IV121a) PARM(&RETURN)
/* CLD A */  GOTO       SKIP
/* CLD A */  ENDDO
/* CLD A */  IF         COND(&PASS = 2) THEN(DO)
/* CLD A */  CALL       PGM(IV121) PARM(&RETURN)
/* CLD A */  GOTO       SKIP
/* CLD A */  ENDDO
/* CLD A */  ENDDO

             CALL       PGM(IV121) PARM(&RETURN)
SKIP:
/* 510 A */  CLOF       OPNID(&FILE)

/*  See if error occured. */

             IF         COND(&RETURN = '*PGMQ') THEN(GOTO GETOUT)

             IF         COND((&CLIENT *EQ &VIP) *AND (&PASS = 1)) +
                          THEN(DO)
             CHGVAR     VAR(&PASS) VALUE(&PASS + 1)
             GOTO       CMDLBL(AGAIN)
             ENDDO

             IF         COND((&CLIENT *EQ &JORDAN) *AND (&PASS = 1)) +
                          THEN(DO)
             CHGVAR     VAR(&PASS) VALUE(&PASS + 1)
             GOTO       CMDLBL(AGAIN)
             ENDDO

/* CLD  */   IF         COND((&CLIENT *EQ &CITYLN) *AND (&PASS = 1)) +
                          THEN(DO)
             CHGVAR     VAR(&PASS) VALUE(&PASS + 1)
             GOTO       CMDLBL(AGAIN)
/* CLD  */   ENDDO

/*  Print sheets. */

             MSGBFC     MESSAGE('Printing inventory sheets')

/* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('IVSWHS *EQ ' *CAT &WHSE)
             IF         COND(&WHDP *NE *ALL) THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVSWHD +
                          *EQ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVSPDT *EQ +
                          0')

/* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE2) SHARE(*YES)
             OPNQRYF    FILE((&FILE2)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD(*FILE)

/* Call program to print sheets */

             MSGBFC     MESSAGE('Printing inventory sheets')
             CALL       PGM(IV125) PARM(&RPRT)

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

             ENDPGM
