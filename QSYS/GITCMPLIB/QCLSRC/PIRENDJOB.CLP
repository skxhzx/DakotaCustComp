/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PIRENDJOB   End server job                                       */
/*  13 August 2008                                                   */
/*  Dave Sommerville                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    08/13/08  MLB  5.20                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
 PIRENDJOB:  PGM        PARM(&JOBNAME &JOBUSER &JOBNUM &RETURN)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&JOBNAME)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBUSER)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBNUM)     TYPE(*CHAR) LEN(6)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&RETURN) VALUE('*OK')

             ENDJOB     JOB(&JOBNUM/&JOBUSER/&JOBNAME) OPTION(*IMMED)

    /*       MONMSG     MSGID(CPF0000) EXEC(DO)          */
    /*       CHGVAR     VAR(&RETURN) VALUE('*ERROR')     */
    /*       ENDDO                                       */

             ENDPGM
