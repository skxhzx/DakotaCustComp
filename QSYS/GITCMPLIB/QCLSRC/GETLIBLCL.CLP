/*-------------------------------------------------------------------*/
/*                                                                   */
/*  GETLIBL      Get library list                                    */
/*  11 December 2009                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    12/11/09  DAS  6.10                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 GETLIBLCL:  PGM        PARM(&LIBL)

             DCL        VAR(&LIBL)       TYPE(*CHAR) LEN(1024)

             RTVJOBA    USRLIBL(&LIBL)

             ENDPGM
