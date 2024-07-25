/*********************************************************************/
/*                                                                   */
/*  MSG       Display message to user                                */
/*            Similar to using '// *' on the Sys/36                  */
/*                                                                   */
/*            NOTE: This should be called using command CMD          */
/*                                                                   */
/*  03 December 1990                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*********************************************************************/

 MSG:        PGM        PARM(&MESSAGE)

/*                                                                   */
/*  FIELD DECLARATION                                                */
/*                                                                   */

             DCL        VAR(&MESSAGE) TYPE(*CHAR) LEN(512)

/*                                                                   */
/*  DISPLAY MESSAGE                                                  */
/*                                                                   */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MESSAGE) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             ENDPGM
