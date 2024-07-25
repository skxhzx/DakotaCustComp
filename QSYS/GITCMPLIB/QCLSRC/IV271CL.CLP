/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV271CL   Assign inventory slots by slot                         */
/*  09 May, 2008                                                     */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*  05/09/08 RH V5.20                                                */
/*      - Created using 5.10 IV270CL, to batch process slot assign-  */
/*        ment. Kept previous comments                               */
/*  06/10/07 RH V5.10                                                */
/*      - Created. Uses same sort process as assign and print sheets */
/*  06/19/07 RH V5.10a                                               */
/*      - Add &EVEN for side of aisle 1=odd 0=even                   */
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
/*  Client Custom Revisions: VIP                                     */
/*                                                                   */
/*  09/13/06  JCJ  VIP                                               */
/*    - Revised program process pick slots first and overflow slots  */
/*      last for VIP                                                 */
/*  06/07/07  RH   JOR                                               */
/*    - Revised program process pick slots first then overflow       */
/*      print by dept/section/aisle/level/side                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IV271CL:    PGM        PARM(&WHSE &CTDT &TEAM &WHDP &PICK +
                            &FDSP &TDSP &EVEN &RETURN)

/*-------------------------------------------------------------------*/
/* 510 A - Client ID's                                               */
/*-------------------------------------------------------------------*/

/* 510 A */  DCL        VAR(&VIP)      TYPE(*CHAR)  LEN(10) +
                          VALUE('VIP       ')
/* 510 A */  DCL        VAR(&BIRITE)   TYPE(*CHAR)  LEN(10) +
                          VALUE('BIRITE    ')
/* 510 A */  DCL        VAR(&JORDAN)   TYPE(*CHAR)  LEN(10) +
                          VALUE('JORDANOS  ')
/* 510 A */  DCL        VAR(&CLIENT)    TYPE(*CHAR) LEN(10)
/* 510 A */  DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)
/* 510 A */  DCL        VAR(&PASS)      TYPE(*DEC)  LEN(1 0) VALUE(1)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV271CL)

  /* Option program. */

  /*  OPNQRY file. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(INVSASN)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Assigning Inventory slots')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

/* 510 A */  DCL        VAR(&YES)        TYPE(*CHAR) LEN(1) VALUE('Y')
/* 510 A */  DCL        VAR(&NO)         TYPE(*CHAR) LEN(1) VALUE('N')
/* 510 A */  DCL        VAR(&QRYSLT2)    TYPE(*CHAR) LEN(2000)
             DCL        VAR(&CTDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&EVEN)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&FDSP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PICK)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TDSP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&TEAM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RPRT)       TYPE(*CHAR) LEN(1) VALUE('N')

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

AGAIN:
/*  options. */


/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/* 510 A */    CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)

/*  Assign inventory slots. */

             MSGBFC     MESSAGE('Assigning inventory slots')


/* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('IVGWHS *EQ ' *CAT &WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVGWHD +
                          *EQ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVGSID +
                          *EQ' *BCAT &QUOTE *CAT &EVEN *CAT &QUOTE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVGSTA *EQ +
                          ' *BCAT &QUOTE *CAT '1' *CAT &QUOTE)

/* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE) SHARE(*YES)

             IF         COND(&PICK = 'P') THEN(DO)
             MSGBFC     MESSAGE('Assigning inventory pick +
                          slots')
             CHGVAR     VAR(&QRYSLT2) VALUE(&QRYSLT)
             CHGVAR     VAR(&QRYSLT)  VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVGPCK +
                          *EQ' *BCAT &QUOTE *CAT &YES *CAT &QUOTE)
             ENDDO


/* 510 A */  IF         COND(&PICK = 'O') THEN(DO)
             MSGBFC     MESSAGE('Assigning inventory overflow +
                          slots')
             CHGVAR     VAR(&QRYSLT2) VALUE(&QRYSLT)
             CHGVAR     VAR(&QRYSLT)  VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVGPCK +
                          *EQ' *BCAT &QUOTE *CAT &NO *CAT &QUOTE)
             ENDDO

/* 510 A */  IF         COND(&CLIENT *NE &BIRITE *AND &CLIENT *NE +
                          &VIP *AND &CLIENT *NE &JORDAN) THEN(DO)
             OPNQRYF    FILE((&FILE)) +
                        OPTION(*ALL)  +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((IVGWHS) +
                               (IVGWHD) +
                               (IVGASL) +
                               (IVGSID *DESCEND) +
                               (IVGLVL) +
                               (IVGLOC) +
                               (IVGHND))
/* 510 A */  ENDDO

/* BIR   */  IF         COND(&CLIENT *EQ &BIRITE) THEN(DO)
             OPNQRYF    FILE((&FILE)) +
                        OPTION(*ALL)  +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((IVGWHS) +
                               (IVGWHD) +
                               (IVGASL) +
                               (IVGSID *DESCEND) +
                               (IVGLOC) +
                               (IVGLVL) +
                               (IVGHND))
/* BIR   */  ENDDO

/* VIP  */   IF         COND(&CLIENT *EQ &VIP) THEN(DO)
             OPNQRYF    FILE((&FILE)) +
                        OPTION(*ALL)  +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((IVGWHS) +
                               (IVGWHD) +
                               (IVGSTP) +
                               (IVGASL) +
                               (IVGSID *DESCEND) +
                               (IVGLOC) +
                               (IVGLVL) +
                               (IVGHND))
/* VIP */    ENDDO


/* JORDAN */ IF         COND(&CLIENT *EQ &JORDAN) THEN(DO)
             OPNQRYF    FILE((&FILE)) +
                        OPTION(*ALL)  +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((IVGWHS) +
                               (IVGWHD) +
                               (IVGSTP) +
                               (IVGASL) +
                               (IVGSID *DESCEND) +
                               (IVGLOC) +
                               (IVGHND))
/* JOR */    ENDDO
/* Call program to assign inventory slots */

/* 510 A */  IF         COND((&CLIENT = &VIP) *OR (&CLIENT = +
                          &BIRITE) *OR (&CLIENT = &JORDAN)) +
                          THEN(DO)
             CALL       PGM(IV271a) PARM(&WHSE &CTDT &TEAM &WHDP +
                          &PICK &FDSP &TDSP &RETURN)
/* 510 A */  GOTO       SKIP
/* 510 A */  ENDDO

             CALL       PGM(IV271) PARM(&WHSE &CTDT &TEAM &WHDP +
                          &PICK &FDSP &TDSP &RETURN)
SKIP:
/* 510 A */  CLOF       OPNID(&FILE)

/*  See if error occured. */


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
