/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PLBL00CL  Display picking label spool file                       */
/*  02 May 1996                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PLBL00CL:   PGM        PARM(&SPLNBR)

             DCL        VAR(&SPLNBR) TYPE(*DEC) LEN(4 0)

             DSPSPLF    FILE(PLBL01PR) SPLNBR(&SPLNBR)

             ENDPGM
