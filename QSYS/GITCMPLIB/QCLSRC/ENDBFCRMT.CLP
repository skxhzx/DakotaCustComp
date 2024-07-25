/*-----------------------------------------------------------------*/
/*                                                                 */
/*  ENDBFCRMT  End client communication objects                    */
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
/*    This program varies *OFF the necessary communication objects */
/*    need for BFC to communicate to the client's machine.         */
/*                                                                 */
/*    The following objects are varied *OFF:                       */
/*                                                                 */
/*              BFC *LIN                                           */
/*              BFC *CTL                                           */
/*                                                                 */
/*-----------------------------------------------------------------*/

 ENDBFCRMT:  PGM

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Vary *OFF device description  */

             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA('Varying +
                          *OFF BFC device description') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             VRYCFG     CFGOBJ(BFC) CFGTYPE(*DEV) STATUS(*OFF)

/*  Vary *OFF contoller description  */

             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA('Varying +
                          *OFF BFC controller description') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             VRYCFG     CFGOBJ(BFC) CFGTYPE(*CTL) STATUS(*OFF)

/*  Clean up message line before leaving */

             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA(' ') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

END:         ENDPGM
