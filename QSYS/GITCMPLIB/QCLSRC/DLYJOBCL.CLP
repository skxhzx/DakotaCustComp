/*-------------------------------------------------------------------*/
/*                                                                   */
/*  DLYJOBCL   Delay job                                             */
/*  26 December 2002                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    12/26/02  DAS  4.16                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 DLYJOBCL:   PGM        PARM(&SECONDS)

             DCL        VAR(&SECONDS) TYPE(*DEC) LEN(5 0)

             DLYJOB     DLY(&SECONDS)

             ENDPGM
