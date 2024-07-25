/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EPMMENUCL EPM security for menu                                  */
/*  01 December 2010                                                 */
/*  Ginger Andrews                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    12/01/10  GJA  5.30                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
 EPMMENUCL:  PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                              (510 A)  */

             DCL        VAR(&SGC) TYPE(*CHAR) LEN(10) +
                          VALUE('SGC       ')
/* Informational message. */
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this menu.')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */

             CHGVAR     VAR(&PGMID) VALUE(EPM)
             CHGVAR     VAR(&PGMOPT) VALUE('80')
             RTVJOBA    USER(&PUSR)
             RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)

/*  Check if user is authorized to use this option              (CLD A) */

             IF         COND(&CLIENT *EQ &SGC)  THEN(DO)
             CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
             IF         COND(&PRTN *EQ '*NO')  THEN(DO)
                        SNDPGMMSG  MSG(&NOAUTHRZE)   +
                        MSGTYPE(*INFO)
             RETURN
             ENDDO
             ENDDO
/*-------------------------------------------------------------------*/

/*  On with the show ... */

             GO         MENU(&PGMID)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
