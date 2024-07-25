/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR660CLWST  Westside Palley Summary call                        */
/*  09 Dec 2019                                                     */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    12/09/19  KDE  7.30                                            */
/*      -  Created                                                   */
/*         Westsdie will call this CL from their ERP to print the    */
/*         Pallet Summary at same time they print invoices and       */
/*         Manifests                                                 */
/*-------------------------------------------------------------------*/

               PGM        PARM(&WHSEA &RTID &PRTDEV)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&PRTDEV)     TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/
/*  Override if printer sent in and call OR660CL  */

             IF         COND(&PRTDEV = ' ') THEN(GOTO CMDLBL(NOOVR))
             OVRPRTF    FILE(OR660PR) DEV(BFCHP)

 NOOVR:

             CALL       PGM(OR660CL) PARM('*REPRINT' '*SUMMARY' +
                          &WHSEA &RTID ' ' ' ')

 GETOUT:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
