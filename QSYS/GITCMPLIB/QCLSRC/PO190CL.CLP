/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PO190CL   PO Display - Qty Received <> Qty Ordered               */
/*  13 November 2006                                                 */
/*  Randy Haselhorst                                                 */
/*   - Created   5.10                                                */
/*   - Copy of PO120CL                                               */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PO190CL:    PGM        PARM(&CMD &UNQKEY &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)    TYPE(*CHAR) LEN(8)    /* 5.00b  */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(PO190)  PARM(&CMD &UNQKEY &RETURN)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
