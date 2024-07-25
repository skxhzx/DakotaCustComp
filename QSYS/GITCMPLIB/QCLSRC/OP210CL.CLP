/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP210CL   PIR options - System                                   */
/*  06 September 1997                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    09/06/97  DAS  4.05                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    06/08/15  GJA  7.00a                                           */
/*      - Add CHKLIST                                                */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP210CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP210)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE('System +
                          Options')
             DCL        VAR(&GLOBAL) TYPE(*CHAR) LEN(4) VALUE(*YES)
/*7.00a*/    DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')
/*7.00a*/    DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10)
/*7.00a*/    DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)
/*7.00a*/    DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)
/*7.00a*/    DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

/*  7.00a Check if user is authorized to use this option */

               CHGVAR     VAR(&PGMID) VALUE(OP210CL)
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')
               RTVJOBA    USER(&PUSR)
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)
                 RETURN
/*7.00a*/      ENDDO

             CALL       PGM(OP010) PARM(&PGM &DESC &GLOBAL &RETURN)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
