/*-------------------------------------------------------------------*/
/*                                                                   */
/*  COCL      Display customer order detail                          */
/*  28 August 2002                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    08/28/02  DAS  4.16                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 COCL:       PGM        PARM(&CORD)

             DCL        VAR(&CORD) TYPE(*DEC) LEN(15 5)

             CALL       PGM(CO) PARM(&CORD)

             RCLRSC     LVL(*CALLER)

             ENDPGM
