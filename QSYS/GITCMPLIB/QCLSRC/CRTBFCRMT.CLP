/*-----------------------------------------------------------------*/
/*                                                                 */
/*  CRTBFCRMT  Create BFC com objects on client's system           */
/*  06 February 1997                                               */
/*  Dave Sommerville                                               */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Parameters                                                     */
/*    None                                                         */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  About this program . . .                                       */
/*                                                                 */
/*    This program should be executed by the Security Officer.     */
/*                                                                 */
/*    This program creates the necessary communication objects     */
/*    that are needed for BFC to connect to a client's machine.    */
/*    The following objects are created:                           */
/*                                                                 */
/*          BFC *LIN                                               */
/*          BFC *CTL                                               */
/*          BFC *DEV                                               */
/*                                                                 */
/*    It is assumed that the above objects do not exist.           */
/*                                                                 */
/*    Also, it is assumed that hardware resource LIN011 exists     */
/*      and is to be used as the customer support line.            */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Before this program is run . . .                               */
/*                                                                 */
/*    The following steps need to be done by the Security Officer. */
/*                                                                 */
/*      Create a user profile for BFC on the customer's system:    */
/*                                                                 */
/*        CRTUSRPRF  USRPRF(BFC)                                   */
/*                   USRCLS(*PGMR)                                 */
/*                   TEXT('BFC Software, Inc.')                    */
/*                   GRPPRF(QPGMR)                                 */
/*                                                                 */
/*      Add the REMOTE user to the system directory:               */
/*                                                                 */
/*        ADDDIRE  USRID(BFC SUPPORT)                              */
/*                 USRD('BFC Software, Inc.')                      */
/*                 USER(BFC)                                       */
/*                                                                 */
/*    Configure secondary system name for customer's system:       */
/*                                                                 */
/*        CFGDSTSRV OPTION(3)                                      */
/*                                                                 */
/*        Fill in the prompts as shown:                            */
/*                                                                 */
/*        --Secondary System--                                     */
/*        Name       Group       Description                       */
/*        SUPPORT                Target for BFC Software, Inc.     */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Preparing to allow BFC to connect . . .                        */
/*                                                                 */
/*    Make sure any line using resource LIN011 is varied *OFF.     */
/*                                                                 */
/*    Make sure any modem and phone connection are physically made.*/
/*                                                                 */
/*    Vary on the BFC line, controller, and device:                */
/*                                                                 */
/*      VRYCFG BFC *LIN *ON                                        */
/*      VRYCFG BFC *CTL *ON                                        */
/*      VRYCFG BFC *DEV *ON                                        */
/*                                                                 */
/*    Start SNADS to allow objects to be received:                 */
/*                                                                 */
/*        STRSBS QSNADS                                            */
/*                                                                 */
/*    After connection has ended, vary devices *OFF.               */
/*                                                                 */
/*        VRYCFG BFC *LIN *OFF                                     */
/*        VRYCFG BFC *CTL *OFF                                     */
/*        VRYCFG BFC *DEV *OFF                                     */
/*                                                                 */
/*    Vary *ON any items that were varied off at the beginning     */
/*    of this procedure.                                           */
/*                                                                 */
/*-----------------------------------------------------------------*/

 CRTBFCRMT:  PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Create line description  */

             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) +
                          MSGDTA('Creating line description for BFC +
                          Software, Inc.') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CRTLINSDLC LIND(BFC) RSRCNAME(LIN011) ONLINE(*NO) +
                          ROLE(*SEC) INTERFACE(*RS232V24) +
                          CNN(*SWTPP) EXCHID(05600002) NRZI(*YES) +
                          SWTCNN(*ANS) AUTODIAL(*NO) STNADR(FA) +
                          DUPLEX(*FULL) RMTANSTMR(90) TEXT('BFC +
                          Software, Inc.') CTSTMR(60)

/*  Create contoller description  */

             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) +
                          MSGDTA('Creating controller description +
                          for BFC Software, Inc.') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CRTCTLAPPC CTLD(BFC) LINKTYPE(*SDLC) ONLINE(*NO) +
                          SWITCHED(*YES) APPN(*NO) SWTLINLST(BFC) +
                          MAXFRAME(521) RMTNETID(*NONE) +
                          EXCHID(05600001) INLCNN(*ANS) +
                          CNNNBR(16307908437) ROLE(*PRI) STNADR(FA) +
                          TEXT('BFC Software, Inc.')

/*  Clean up message line before leaving */

             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA(' ') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

END:         ENDPGM
