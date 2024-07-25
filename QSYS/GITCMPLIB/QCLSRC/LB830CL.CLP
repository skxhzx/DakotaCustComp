/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LB830CL   Change label utility                                   */
/*  9 September 2000                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    11/09/06  JCJ  5.10                                            */
/*      - Added client custom code support to program.               */
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
/*  Client Custom Revisions: Sofo Foods                              */
/*                                                                   */
/*    10/04/21  MLB  SOF                                             */
/*      - Add user authorization check.                              */
/*      - Added SOF to CLD mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LB830CL:    PGM        PARM(&CMD)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                              (510 A)  */

/*CLD A*/    DCL        VAR(&CITYLINE) TYPE(*CHAR) LEN(10) +
                          VALUE('CITYLINE  ')
/*PCK A*/    DCL        VAR(&PACKERS) TYPE(*CHAR) LEN(10) +
                          VALUE('PACKERS   ')
/*SOF A*/    DCL        VAR(&SOF    ) TYPE(*CHAR) LEN(10) +
                          VALUE('SOFOFOODS ')

/*510 A*/    DCL        VAR(&PGM) TYPE(*CHAR) LEN(8) VALUE(LB830)


/* Informational message. */

/*CLD A*/    DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)    TYPE(*CHAR) LEN(8)
/*510 A*/    DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
/*510 A*/    DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
/*510 A*/    DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
/*510 A*/    DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
/*510 A*/    DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*510 A*/    CHGVAR     VAR(&PGMID) VALUE(LB830CL)
/*510 A*/    RTVJOBA    USER(&PUSR)
/*510 A*/    RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)

/*  Check if user is authorized to use this option              (CLD A) */

/*PCK D      IF         COND(&CLIENT *EQ &CITYLINE)  THEN(DO)           */
             IF         COND(&CLIENT *EQ &CITYLINE +
                         *OR &CLIENT *EQ &SOF +
                         *OR &CLIENT *EQ &PACKERS) THEN(DO)       /* (SOF M) */
/*CLD A*/    CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
/*CLD A*/    IF         COND(&PRTN *EQ '*NO')  THEN(DO)
/*CLD A*/               SNDPGMMSG  MSG(&NOAUTHRZE)   +
/*CLD A*/               MSGTYPE(*INFO)
/*CLD A*/    RETURN
/*CLD A*/    ENDDO
/*CLD A*/    ENDDO

             CALL       PGM(LB830) PARM(&CMD '')

             RCLRSC     LVL(*CALLER)

             ENDPGM
