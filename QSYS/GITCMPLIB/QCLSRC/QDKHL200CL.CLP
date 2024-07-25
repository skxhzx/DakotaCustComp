/*-------------------------------------------------------------------*/
/*                                                                   */
/*  QDKHL200CL Start/Stop TCP Communications Traces.                 */
/*  20 August 2015                                                   */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    08/20/15  MLB  7.00                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 QDKHL200CL: PGM        PARM(&CMD &LINED)

             DCL        VAR(&CMD)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&LINED) TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

       SELECT
       WHEN       COND(&CMD = '*START') THEN(DO)
         STRCMNTRC  CFGOBJ(&LINED) CFGTYPE(*LIN) MAXSTG(32M) USRDTA(*MAX)
         MONMSG     MSGID(CPF0000)

         TRCCNN SET(*ON) TRCTYPE(*IP) TRCTBL(TCP) SIZE(500 *MB)
         MONMSG     MSGID(CPF0000)
       ENDDO

       WHEN       COND(&CMD = '*STOP') THEN(DO)
         ENDCMNTRC CFGOBJ(&LINED) CFGTYPE(*LIN)
         MONMSG     MSGID(CPF0000)

         TRCCNN SET(*OFF) TRCTBL(TCP)
         MONMSG     MSGID(CPF0000)
       ENDDO
       ENDSELECT

   /* Clean up before leaving */


ENDPGM
