/*********************************************************************/
/*                                                                   */
/*  STRSKTSCL   Start BFCSKTSCL socket client for Toledo Scales      */
/*  22 Janaury 2014                                                  */
/*  Kennethe Elder                                                   */
/*                                                                   */
/*  Command Processing Program: STRSKTSCL                            */
/*  Choice Options Program:     DSPSCLPOR    IP SOCKET SELECTION     */
/*  Validity Checking Program:  CHKSCLPOR    IP SOCKET SELECTION     */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    01/22/14  KDE  6.20                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &PORT        Port number to listen to                            */
/*  &PUTJOBQ     Place on job queue (*YES)                           */
/*  &JOBD        Job description (Name/Lib)                          */
/*  &JOBQ        Job queue (Name/Lib)                                */
/*  &LIBL        Library list to use                                 */
/*                                                                   */
/*********************************************************************/
             CMD        PROMPT('Start BFCSKTSCL Socket Client')

             PARM       KWD(PORT) TYPE(*CHAR) LEN(5) DFT(6001) +
                          CHOICE(*PGM) CHOICEPGM(DSPSCLPOR) +
                          PROMPT('Single IP Socket or *ALL')

             PARM       KWD(PUTJOBQ) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) PROMPT('Place +
                          on job queue')

             PARM       KWD(JOBD) TYPE(Q1) DFT(*USRPRF) +
                          SNGVAL((*USRPRF)) PMTCTL(JOBQCHK) +
                          PROMPT('Job Description')

             PARM       KWD(JOBQ) TYPE(Q2) SNGVAL((*JOBD)) +
                          PMTCTL(JOBQCHK) PROMPT('Job Queue')

             PARM       KWD(LIBL) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*CURRENT) VALUES(*CURRENT *JOBD) +
                          PMTCTL(JOBQCHK) PROMPT('Library List')

 Q1:         QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library:')

 Q2:         QUAL       TYPE(*NAME) LEN(10) DFT(QSYSNOMAX)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library:')

 JOBQCHK:    PMTCTL     CTL(PUTJOBQ) COND((*EQ *YES))
