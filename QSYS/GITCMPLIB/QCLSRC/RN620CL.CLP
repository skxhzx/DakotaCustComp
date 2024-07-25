/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RN620CL  RF Customer returns w/UCI 16 X 22 screen                */
/*  08 August 2007                                                   */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    08/08/07  RH   5.10                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    08/08/07 HNK 5.10a                                             */
/*      - Add &psls for Alpha interface.                             */
/*                                                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RN620CL:    PGM        PARM(&QUICK &PSLS) /* Y/N for Quick return */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&QUICK) TYPE(*CHAR) LEN(1)
             DCL        VAR(&PSLS)  TYPE(*CHAR) LEN(4)
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/
             CALL       PGM(RN620) PARM('*RETURN ' &QUICK &PSLS)

             RCLRSC     LVL(*CALLER)

             ENDPGM
