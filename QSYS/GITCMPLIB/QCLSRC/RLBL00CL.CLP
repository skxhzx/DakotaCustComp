/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RLBL00CL  Display receiving label spool file                     */
/*  02 May 1996                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RLBL00CL:   PGM        PARM(&SPLNBR)

             DCL        VAR(&SPLNBR) TYPE(*DEC) LEN(4 0)

             DSPSPLF    FILE(RLBL01PR) SPLNBR(&SPLNBR)

             ENDPGM
