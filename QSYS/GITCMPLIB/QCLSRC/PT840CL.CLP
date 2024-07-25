/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT840CL   Work with transactions                                 */
/*  17 April 2001                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    11/09/06  JCJ  5.10                                            */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*    05/27/11  MLB  6.40                                            */
/*      - Fix: Added support for WORKOPT file that was missing.      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: City Line                               */
/*                                                                   */
/*    11/09/06  JCJ  CLD                                             */
/*      - Add user authorization check.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Packer's Provision                      */
/*                                                                   */
/*    03/16/10  MLB  PCK                                             */
/*      - Add user authorization check.                              */
/*      - Added PCK to CLD mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: SGC Foodservice                         */
/*                                                                   */
/*    05/10/18  MLB  SGC                                             */
/*      - Add user authorization check.                              */
/*      - Added SGC to CLD mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Sofo Foods                              */
/*                                                                   */
/*    10/04/21  MLB  SOF                                             */
/*      - Add user authorization check.                              */
/*      - Added SOF to CLD mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &CMD       *CHANGE Allow changes to be made.                   */
/*               *VIEW   Only allow user to view records.            */
/*                                                                   */
/*    &OPT       *ALL    All PIRTRAN records (default)               */
/*               *ENDED  Only PIRTRAN records with stat=3.           */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PT840CL:    PGM        PARM(&CMD &OPT)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                              (510 A)  */

/*CLD A*/    DCL        VAR(&CITYLINE) TYPE(*CHAR) LEN(10) +
                          VALUE('CITYLINE  ')
/*PCK A*/    DCL        VAR(&PACKERS) TYPE(*CHAR) LEN(10) +
                          VALUE('PACKERS   ')
/*SGC A*/    DCL        VAR(&SGC) TYPE(*CHAR) LEN(10) +
                          VALUE('SGC       ')
/*SOF A*/    DCL        VAR(&SOF) TYPE(*CHAR) LEN(10) +
                          VALUE('SOFOFOODS ')

/*510 A*/    DCL        VAR(&PGM) TYPE(*CHAR) LEN(8) VALUE(PT840)

/* Informational message. */

/*CLD A*/    DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&OPT)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
/*510 A*/    DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
/*510 A*/    DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
/*510 A*/    DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
/*510 A*/    DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
/*510 A*/    DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*510 A*/    CHGVAR     VAR(&PGMID) VALUE(PT840CL)
/*510 A*/    RTVJOBA    USER(&PUSR)
/*510 A*/    RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)

/*  Check if user is authorized to use this option              (CLD A) */

/*PCK D      IF         COND(&CLIENT *EQ &CITYLINE)  THEN(DO)           */
             IF         COND(&CLIENT *EQ &CITYLINE +
                         *OR &CLIENT *EQ &SGC +
                         *OR &CLIENT *EQ &SOF +
                         *OR &CLIENT *EQ &PACKERS) THEN(DO)       /* (SOF M) */
/*CLD A*/    CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
/*CLD A*/    IF         COND(&PRTN *EQ '*NO')  THEN(DO)
/*CLD A*/               SNDPGMMSG  MSG(&NOAUTHRZE)   +
/*CLD A*/               MSGTYPE(*INFO)
/*CLD A*/    RETURN
/*CLD A*/    ENDDO
/*CLD A*/    ENDDO

/*  Define work file to be used for display options.                 (640 A) */
/*    - Get unique member to use.                                    (640 A) */
/*    - Override file to use unique member.                          (640 A) */

             IF (&MEMBER = ' ') DO                                /* (640 A) */
               CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER) +
                                                                  /* (640 A) */
             ENDDO                                                /* (640 A) */

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)    /* (640 A) */

   /* Default selection to all records */

             CHGVAR     VAR(&QRYSLT) VALUE('*ALL')

   /* See if user wants a subset of records */

             IF (&OPT = '*ENDED') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE('PTSTAT *EQ ' *CAT &QUOTE +
                                           *CAT '3' *CAT &QUOTE)
             ENDDO

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(PIRTRAN) SHARE(*YES)
             OPNQRYF    FILE((PIRTRAN)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD(*FILE)


             CALL       PGM(PT840) PARM(&CMD)

             DLTOVR     FILE(PIRTRAN)
             RCLRSC     LVL(*CALLER)
             DLTOVR     FILE(WORKOPT)                             /* (640 A) */
             CLOF       OPNID(WORKOPT)                            /* (640 A) */
             MONMSG     MSGID(CPF4519 CPF4520)                    /* (640 A) */
             RMVM       FILE(WORKOPT) MBR(&MEMBER)                /* (640 A) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310 CPF0001)        /* (640 A) */

             ENDPGM
