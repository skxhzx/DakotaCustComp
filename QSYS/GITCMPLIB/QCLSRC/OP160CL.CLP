/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP160CL   PIR options - General Picking                          */
/*  13 November 1998                                                 */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    11/13/98  DAS  4.05                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    11/30/20  MLB  7.40                                            */
/*      - Enh: Revised pgm to only allow authorized users access.    */
/*                                                                   */
/*    08/10/21  LMC  7.50a                                           */
/*      - Enh: Revised pgm to require user to use web options.       */
/*-------------------------------------------------------------------*/

 OP160CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP160)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE('General +
                           Picking Options')
             DCL        VAR(&GLOBAL) TYPE(*CHAR) LEN(4) VALUE(*NO)
/*7.40 */    DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')
/*7.50a*/    DCL        VAR(&USEWEB) TYPE(*CHAR) LEN(60) +
                          VALUE('   You must use Web genpick +
                          options.')
/*7.40 */    DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10)
/*7.40 */    DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)
/*7.40 */    DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)
/*7.40 */    DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

/*  7.40  Check if user is authorized to use this option */

             CHGVAR     VAR(&PGMID) VALUE(OP160CL)
             CHGVAR     VAR(&PGMOPT) VALUE('*ALL')
             RTVJOBA    USER(&PUSR)
             CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
             IF         COND(&PRTN *EQ '*NO')  THEN(DO)
               SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)
               RETURN
/*7.40 */    ENDDO
/*7.50a*/    CHKOBJ     OBJ(OSGENPICK1) OBJTYPE(*PGM) /*7.50a*/
/*7.50a*/    MONMSG     MSGID(CPF9801) EXEC(DO)
/*7.50a*/    GOTO USEGREEN
/*7.50a*/    ENDDO

/*7.50a*/    SNDPGMMSG  MSG(&USEWEB) MSGTYPE(*INFO)
/*7.50a*/    RETURN

USEGREEN:
             CALL       PGM(OP010) PARM(&PGM &DESC &GLOBAL &RETURN)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
