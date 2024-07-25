/*********************************************************************/
/*                                                                   */
/*  SNDBRKMSGU  Send Break Message to User                           */
/*  12 August 2004                                                   */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: QEZSNDMG                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*  Revisions:                                                       */
/*                                                                  */
/*                                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &USER        User to send message to                             */
/*  &MSG         Message to send                                     */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Send Break Message to User') /* Send +
                          Break Message to User */
             PARM       KWD(MSGTYP) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*INFO) VALUES(*INFO *INQ) +
                          PROMPT('Message Type' 3)
             PARM       KWD(DLVRY) TYPE(*CHAR) LEN(10) CONSTANT(*BREAK)
             PARM       KWD(MSGTXT) TYPE(*CHAR) LEN(120) MIN(1) +
                          PROMPT('Message Text' 1)
             PARM       KWD(MSGTXTLEN) TYPE(*CHAR) LEN(4) +
                          CONSTANT(X'00000078')
             PARM       KWD(USRPRF) TYPE(*NAME) LEN(10) +
                          SPCVAL((*ALL) (*ALLACT)) MIN(1) +
                          PROMPT('Profile Name, *ALL, *ALLACT' 2)
             PARM       KWD(NBRELM) TYPE(*CHAR) LEN(4) +
                          CONSTANT(X'00000001')
             PARM       KWD(MSGSENT) TYPE(*CHAR) LEN(4) CONSTANT(' ')
             PARM       KWD(FNRQS) TYPE(*CHAR) LEN(4) CONSTANT(' ')
             PARM       KWD(ERRCDE) TYPE(*CHAR) LEN(26) +
                          CONSTANT(X'0000001A0000001A')
             PARM       KWD(SHOWDSP) TYPE(*CHAR) LEN(1) CONSTANT(N)
             PARM       KWD(QUALMSGQ) TYPE(*CHAR) LEN(20) CONSTANT(' ')
             PARM       KWD(NAMTYP) TYPE(*CHAR) LEN(4) CONSTANT(*USR)
