/*-------------------------------------------------------------------*/
/*                                                                   */
/*  GETLIBL250   Get library list - 250 libs                         */
/*  10 May 2020                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    05/10/20  DAS  7.40                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 GETLIBL250: PGM        PARM(&LIBL)

             DCL        VAR(&LIBL)       TYPE(*CHAR) LEN(2750)

             RTVJOBA    USRLIBL(&LIBL)

             ENDPGM
