/*-----------------------------------------------------------------*/
/*                                                                 */
/*  STRBFCRMT  Start client communication objects                  */
/*  06 February 1997                                               */
/*  Dave Sommerville                                               */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Parameters                                                     */
/*                                                                 */
/*    None                                                         */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  About this program . . .                                       */
/*                                                                 */
/*    This program varies *ON the necessary communication objects  */
/*    need for BFC to communicate to the client's machine.  The    */
/*    objects were created with program CRTBFCRMT.                 */
/*                                                                 */
/*    The following objects are varied *ON:                        */
/*                                                                 */
/*          BFC *LIN *ON                                           */
/*          BFC *CTL *ON                                           */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Misc. . . .                                                    */
/*                                                                 */
/*    Start SNADS to allow objects to be received.                 */
/*                                                                 */
/*        STRSBS QSNADS                                            */
/*                                                                 */
/*    After connection has ended, vary *OFF the objects using      */
/*    program ENDBFCRMT.                                           */
/*                                                                 */
/*-----------------------------------------------------------------*/

 STRBFCRMT:  PGM

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Vary *ON line description  */

             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA('Varying +
                          *ON BFC line description') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             VRYCFG     CFGOBJ(BFC) CFGTYPE(*LIN) STATUS(*ON)

/*  Vary *ON contoller description  */

             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA('Varying +
                          *ON BFC controller description') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             VRYCFG     CFGOBJ(BFC) CFGTYPE(*CTL) STATUS(*ON)

/*  Clean up message line before leaving */

             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA(' ') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

END:         ENDPGM
