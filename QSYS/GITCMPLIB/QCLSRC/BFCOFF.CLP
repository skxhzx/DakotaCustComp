/*-----------------------------------------------------------------*/
/*                                                                 */
/*  BFCOFF      Send BFC signoff message                           */
/*  07 October 1999                                                */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &USER     User to send message to                        */
/*        &MSG      Message                                        */
/*                                                                 */
/*-----------------------------------------------------------------*/

 BFCOFF:     PGM        PARM(&USER &MSG)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&MSG)      TYPE(*CHAR) LEN(255)
             DCL        VAR(&USER)     TYPE(*CHAR) LEN(10)

             SNDMSG     MSG(&MSG) TOUSR(&USER)

             ENDPGM
