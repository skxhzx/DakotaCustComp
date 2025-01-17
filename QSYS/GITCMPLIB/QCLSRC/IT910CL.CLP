/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT910CL   Item lookup                                            */
/*  28 August 2002                                                   */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    08/28/02  DAS  4.16                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT910CL:    PGM        PARM(&PITEM)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PITEM)      TYPE(*CHAR) LEN(15)
/*-------------------------------------------------------------------*/

             CALL       PGM(IT910) PARM(&PITEM)

             RCLRSC     LVL(*CALLER)

             ENDPGM
